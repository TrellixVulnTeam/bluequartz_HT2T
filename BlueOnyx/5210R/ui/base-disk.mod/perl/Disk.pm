#!/usr/bin/perl
# $Id: Disk.pm,
#
# Based on Cobalt::DiskUtils written by Adrian Sun <asun@cobaltnet.com>
#
# Description:
# run perldoc /usr/sausalito/perl/Base/Disk.pm for documentation

=pod
=head1 NAME

Base::Disk - get information on the current disks

=head1 SYNOPSIS

 use Base::Disk;
 use Base::Disk qw(disk_getmounts);

 $df_info = Base::Disk::disk_get_usage_info(@partitions);
 $raidtab = Base::Disk::disk_getraidparts();
 $partitions = Base::Disk::disk_getpartitions();
 $mounts = Base::Disk::disk_getmounts();
 $umounts = Base::Disk::disk_getumounts();
 $unpartitioned = Base::Disk::disk_getunpartitioned();

=head1 DESCRIPTION

Base::Disk can be used to obtain generic information on mounted and unmounted
disk partitions.  It is not of much use to most modules, but it is an interface
that could be useful for writing disk utility modules such as the one used
to add and remove external storage devices.

=head1 EXPORTS

All of the methods provided by Base::Disk can be imported into the calling
namespace with the standard C<use Module qw(function1 function2 ...);> pragma.
No methods are exported by default.

=cut

package Base::Disk;

# use strict;
use lib qw(/usr/sausalito/perl /usr/sausalito/handlers/base/disk);
use vars qw(@ISA @EXPORT_OK $DEBUG);

use locale;
use POSIX qw(locale_h); # Imports setlocale() and the LC_ constants.
setlocale(LC_NUMERIC, "en_US") or die "Locale en_US not available";

# Debugging switch:
$DEBUG = "0";
if ($DEBUG)
{
        use Sys::Syslog qw( :DEFAULT setlogsock);
}

require Exporter;
@ISA    = qw(Exporter);
@EXPORT_OK = qw(
    disk_getpartitions   disk_getunpartitioned
    disk_getumounts      disk_getmounts   
    disk_getraidparts    disk_get_usage_info
    );

# I don't know why these methods exist, but haven't removed them yet.
# disk_lock            disk_unlock
# disk_checklock       

use DiskInfo;
use Base::HomeDir;


# private config info
my $MTAB = '/etc/mtab';
my $MDSTAT = '/proc/mdstat';
my $DEVICES = '/proc/devices';
my $PART_TAB = '/proc/partitions';


## exported routines
=pod

=head1 METHODS

=over 4

=item disk_get_usage_info([@partitions_or_dirs])

This will return a reference to a hash of the information returned by running
the df command.  It currently uses df, but this could possibly change in the
future.  By default, the method returns information for all currently mounted
filesystems if no arguments are passed to it.  It returns undef on failure
to gather the requested information.

All values in the hash reference are exactly the same as those displayed
when the df command is run.  The hash reference returned will have the 
following structure:

=over 4

$disk_info->{Filesystem}->{Total}
         |             |->{Used}
         |             |->{Available}
         |             |->{PercentUsed}
         |             |->{MountPoint}
         |
         |->{Filesystem}->...
         .
         .
         .

=item *

I<@partitions_or_dirs> is optional.  The argument can contain filesystem device
names (e.g. /dev/hda1) and directory names (e.g. /home).  The argument is only
needed if information about specific filesystems or the filesystem that a 
directory is located in is desired.

=back

=cut

sub old_disk_get_usage_info
{
    my @partitions = @_;

    my $hash = undef;

    $DEBUG && print STDERR join(' ', @partitions), "\n";

    # this funky open command is so, we can get a piped open of df
    # without worrying about shell metacharacters.
    # plus it takes care of labels with spaces in them
    my @df_cmd = ('/bin/df', '-kP');
    if (scalar(@partitions)) { push @df_cmd, @partitions; }
    if (not (open(DF, '-|') || exec(@df_cmd))) 
    { 
        return undef; 
    }
    while (<DF>)
    {
        if (m"^/dev/") 
        {
            /^([^\s]+)\s+([\d]+)\s+([\d]+)\s+([\d]+)\s+([^\s]+)\s+(.+)$/;
            $hash->{$1}->{Total} = $2;
            $hash->{$1}->{Used} = $3;
            $hash->{$1}->{Available} = $4;
            $hash->{$1}->{PercentUsed} = $5;
            $hash->{$1}->{MountPoint} = $6;
        }
    }
    close(DF);

    return $hash;
}

sub disk_get_usage_info
{

    # column headers to be used as hash keys
    my @headers = qw(name size used free capacity mount);

    my @df = `df -kP`;

    shift @df;  # get rid of the header

    my %devices;
    for my $line (@df) {
        my %info;
        @info{@headers} = split /\s+/, $line;  # note the hash slice
        $devices{ $info{name} } = \%info;
    }

    for $info (values %devices) {
        $i = $info->{name};
        $size = $info{size};
        $hash->{$i}->{Total} = $info->{size};
        $hash->{$i}->{Used} = $info->{used}; 
        $hash->{$i}->{Available} = $info->{capacity};
        $hash->{$i}->{PercentUsed} = $info->{capacity};
        $hash->{$i}->{MountPoint} = $info->{mount};

        &debug_msg("Base::Disk: Processing: ($i : $size)\n");
        &debug_msg("Base::Disk: Size: " . $info->{size} . "\n");
        &debug_msg("Base::Disk: Used: " . $info->{used} . "\n");
        &debug_msg("Base::Disk: Available: " . $info->{capacity} . "\n");
        &debug_msg("Base::Disk: MountPoint: " . $info->{mount} . "\n");
    }
    return $hash;
}

sub debug_msg {
    if ($DEBUG) {
        my $msg = shift;
        $user = $ENV{'USER'};
        setlogsock('unix');
        openlog($0,'','user');
        syslog('info', "$ARGV[0]: $msg");
        closelog;
    }
}

=pod

=item disk_getraidparts()

This method returns a reference to a hash indexed by filesystem device 
(e.g. /dev/hda1) and physical device (e.g. /dev/hda).  In addition, the value
of the hash for a device is a reference to a hash of information inluding the
raid partition to which the device belongs and the size of the device in blocks.

The structure of the returned hash reference is as follows:

=over 4

$raidtab->{/dev/hda1}->{Device}  
       |            |->{Size}    
       |
       |->{/dev/hda}->{Size}
       |
       .
       .

Device is the raid partition to which the device belongs.
Size is the size of the partition or device in blocks.

=back

=cut

sub disk_getraidparts
{
    my ($parts, %devices);
    my @devs;
    my ($md, $dev, $size);

    return undef unless open(DEVICES, $DEVICES);
    while (<DEVICES>) 
    {
        next unless /(\d+)\s+(\S+)/;
        $devices{int($1)} = $2;
    }
    close(DEVICES);

    return undef unless open(MDSTAT, $MDSTAT);
    my @mdstat = <MDSTAT>;
    close(MDSTAT);
    
    for(my $i = 0; $i < scalar(@mdstat); $i++)
    {
        next unless $mdstat[$i] =~ /^(md\d+)/;
        $md = $1;

        # deal with new mdstat format
        if ($mdstat[$i] =~ /\s+(\d+)\s+blocks/)
        {
            $size = $1;
        }
        elsif ($mdstat[$i + 1] =~ /\s+(\d+)\s+blocks/)
        {
            $size = $1;
        }
        else
        {
            next;
        }

        @devs = split /\[\d+\]/, $mdstat[$i];
        for my $key (@devs) 
        {
            if ($key =~ /\[dev (\d+):(\d+)\]$/) 
            {
                $dev = '/dev/' . $devices{int($1)} . int($2);
            } 
            elsif ($key =~ / (\S+\d+)$/) 
            {
                $dev = "/dev/$1";
            } 
            else 
            {
                next;
            }
            $parts->{$dev}->{Device} = $md;
            $parts->{$dev}->{Size} = $size;
            $dev =~ s/\d+//;
            $parts->{$dev}->{Size} += $size;
        }
    }

    return $parts;
}


# huh?, why is there locking for disks?
# sub disk_checklock
# {
#     return -e "$Lockdir/diskutils" ? 1 : 0;
# }
# 
# sub disk_lock
# {
#     if (not disk_checklock) {
#     open(LOCK, ">$Lockdir/diskutils");
#     close(LOCK);
#     return 0;
#     }
#     return -1;
# }
# 
# 
# sub disk_unlock
# {
#     my $lockfile = "$Lockdir/diskutils";
#     unlink($lockfile) if -e $lockfile;
# }

=pod

=item disk_getpartitions()

disk_getpartitions() returns a reference to hash with partitions as keys and
partition size in blocks as values.  Unlike disk_getraidparts(), this returns
all partitions and includes no information about raid.

The returned hash has the following structure:

=over 4

$partitions->{/dev/hda1}
          |->{/dev/hda2}
          |->{/dev/hdc}
          .
          .
          .

=back

=cut

sub disk_getpartitions
{
    my $hash;

    open(PARTS, $PART_TAB) or return undef;
    # get partition information
    while (<PARTS>) 
    {
        if (/\d+\s+\d+\s+(\d+)\s+(\S+)/) 
        {
            my $part = '/dev/' . $2;
            my $size = $1;
            next if $size < 100; # minimum size requirements
            next if $2 =~ /^md/; # don't include non-physical partitions
            $hash->{$part} = $size;
        }
    }
    close (PARTS);
    return $hash;
}

=pod

=item disk_getmounts()

Returns a reference to a hash containing all currently mounted filesystems.  In
addition, each filesystems mount point and type are located in a hash pointed
to as the value of the filesystem hash.

The structure of the returned hash reference is as follows:

=over 4

$mounts->{/dev/hda1}->{mount_point} = '/'
      |            |->{fs_type} = 'ext2'
      .
      .
      .
      
=back

=cut

sub disk_getmounts
{
    my $hash;

    if (!open(MTAB, $MTAB))
    {
        return undef;
    }
   
    while (<MTAB>)
    {
        if (/^(\/dev\/\S+|\S+:\/\S+)\s+(\S+)\s+(\S+)/)
        {
            $hash->{$1}->{mount_point} = $2;
            $hash->{$1}->{fs_type} = $3;
        }
    }
    close(MTAB);

    return $hash;
}

=pod

=item disk_getumounts()

Returns a reference to a hash of the currently unmounted filesystems.  The hash
structure is the same as that returned by disk_getpartitions().

=cut

sub disk_getumounts 
{
    my $partitions = disk_getpartitions();
    my $raidtab = disk_getraidparts();
    my $mounts = disk_getmounts();
    my $key;
    my $value;

    my $hash = undef;
    while (($key, $value) = each %{$partitions}) 
    {
        unless ($mounts->{$key} || $raidtab->{$key})
        {
            # don't include the whole disk if the disk is partitioned
            # (eg don't include /dev/hdg when /dev/hdg1, etc. exist)
#             $key =~ /^(\/dev\/[^\d]+)(.*)$/;
#             my $dev = $1;
#             $DEBUG && print STDERR "$dev $key\n";
#             if ($hash->{$dev} && $2)
#             {
#                 $DEBUG && print STDERR "Removing $dev because it is partitioned.\n";
#                 delete($hash->{$dev});
#             }
#             elsif (!$2 && ($hash->{"${dev}1"} || $mounts->{"${dev}1"}))
#             {
#                 # if /dev/whatever1 exists and is mounted or unmouted, don't 
#                   # add the device as unmounted
#                 $DEBUG && print STDERR "Skipping $dev because ${dev}1 exists.\n";
#                 next;
#             }

            $DEBUG && print STDERR "Adding $key to umounts.\n";
            $hash->{$key} = $value;
        } # end unless
    }
    return $hash;
}

=pod

=item disk_getunpartitioned()

Use this to get all the unpartitioned devices and their size in 1 K blocks.
Returns a reference to a hash with the system device file as the key and the
device size in blocks as the value.  The structure of the hash is the same
as that for the hash reference returned by disk_getpartitions().

=cut

sub disk_getunpartitioned
# description: unpartitioned disks
#
# input: none
#
# output: hash of all the unpartitioned disks (key: device file,
#         value: size in bytes)
{
    my $partitions = disk_getpartitions();
    my @keys = keys %$partitions;
    my $list = join(",", @keys);
    my $hash = undef;
    my $key;
    
    for $key (@keys) 
    {
        if ($key =~ m/\D$/ and $list !~ m/$key\d+/)
        {
            $hash->{$key} = $partitions->{$key};
        }
    }
    return $hash;
}

=pod

=head1 COPYRIGHT

Copyright 2001 Sun Microsystems, Inc.  All rights reserved.

=head1 BUGS

Most of the methods are not guaranteed to do the right thing for CD devices
since they often have no partition number after the device name (e.g. /dev/hdc).

For networked filesystems, disk_get_usage_info must be passed the name of the
directory where the filesystem is mounted when getting information on that
filesystem alone.  All other methods ignore network filesystems.

=head1 SEE ALSO

=item df(1)

=cut
1;

# 
# Copyright (c) 2015 Michael Stauber, SOLARSPEED.NET
# Copyright (c) 2015 Team BlueOnyx, BLUEONYX.IT
# Copyright (c) 2003 Sun Microsystems, Inc. 
# All Rights Reserved.
# 
# 1. Redistributions of source code must retain the above copyright 
#     notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright 
#     notice, this list of conditions and the following disclaimer in 
#     the documentation and/or other materials provided with the 
#     distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its 
#     contributors may be used to endorse or promote products derived 
#     from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
# COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
# 
# You acknowledge that this software is not designed or intended for 
# use in the design, construction, operation or maintenance of any 
# nuclear facility.
# 