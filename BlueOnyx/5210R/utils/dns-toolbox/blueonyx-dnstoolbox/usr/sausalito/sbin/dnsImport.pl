#!/usr/bin/perl
# Author: Brian N. Smith
# $Id: dnsImport.pl

# This file is based off of Jeff Bilicki's dnsImport.  It has been modified in order
# to allow you to import files from a RaQ550 / TLAS or even CentOS.
#
# Secondary domain import re-implemented by Rickard Osser <rickard.osser@bluapp.com>
#

use lib "/usr/cmu/perl";
use Global;
use Switch;
use vars qw($cce);
require cmuCCE;
my $cce = new cmuCCE;

my $path = $ARGV[0];
if ( $path eq "" ) {
    print "\n\n";
    print "                         dnsImport.pl v2.2\n\n";
    print "Orginal written by; Jeff Bilicki \n";
    print "Modifications by;   Brian N. Smith & Team BlueOnyx\n\n";
    print "dnsImport.pl will import records from\n";
    print "\t\tCobalt RaQ 550\n";
    print "\t\tTurbo Linux Appliance Server (TLAS)\n";
    print "\t\tArgon Appliance Server\n";
    print "\t\tBlueQuartz Server\n";
    print "\t\tBlueOnyx Server\n\n";
    print "To Import records, you must copy Bind's zone files from your old server\n";
    print "and put them into a directory on this server.  Then run dnsImport.pl\n";
    print "against that directory\n\n";
    print $0 . " /path/to/bind/zone/files\n\n";
} else {
    $cce->connectuds();
    read_dir($path);
    commit_changes();
    $cce->bye("bye-bye miss american pie");
}

exit 0;

sub read_dir {
    my $dir = shift;
    if ( ! ($dir =~ m/\/$/) ) { $dir .= "/"; }

    if ( ! -d $dir ) {
	print "Path much be a directory!\n";
	return;
    }
    opendir(D, $dir);
    my @f = readdir(D);
    closedir(D);
    foreach my $file (@f) {
	if ( $file ne "." and $file ne ".." and file ne 'pri.0.0.127.in-addr.arpa' and file ne 'root.hint') {
	    if ( !($file =~ m/\.include$/) and !($file =~ m/~$/) and !($file =~ m/root\.hint/)) {
		my $filename = $dir . $file;
		import_record($dir, $file);
	    }
	}
    }
}

sub import_record {
    my $dir = shift;
    my $file = shift;
    $domainname = $file;
    switch ( $domainname ) {
	case /^sec/ {
	    $domainname =~ s/sec\.//;
	    $recType = "sec";
	    $netmask = "255.255.255.0";
	    break;
	}
#
# Sorry, but this ain't working. I like the idea, but it doesn't cover all bases yet.
#
#	case /in-addr.arpa/ {
#	    $domainname =~ s/\.in-addr.arpa//;
#	    $domainname =~ s/^db//;
#	    $recType = "sec";
#	    my @domainname = split (/\./, $domainname);
#	    my ($padding);
#	    switch ( @domainname ) {
#		case "1" { $padding = "0.0.0"; $netmask = "255.0.0.0"; }
#		case "2" { $padding = "0.0"; $netmask = "255.255.0.0"; }
#		case "3" { $padding = "0"; $netmask = "255.255.255.0"; }
#	    }
#	    $domainname = "";
#	    for ( my $i = @domainname; $i > 0; $i--) {
#		$domainname .= $domainname[$i-1].".";
#	    }
#	    $domainname .= $padding;
#	    break;
#	}
	case /^db/ {
	    $domainname =~ s/db\.//;
	    break;
	}
        case /^pri/ {
            $domainname =~ s/pri\.//;
            break;
        }
    }
    $records_file = $dir . $file;
    my @records = read_records($records_file);
    my $soa = "";
    if ( $recType eq "sec") {
#    print "We need to do some funky stuff\n";
	$done = 0;
	foreach my $rec (@records) {
	    chomp $rec;
	    $rec =~ s/\s+/ /g;
	    $rec =~ tr/[A-Z]/[a-z]/;
	    if ( $rec =~ / ns / && !$done) {
		my @line = split(/ /, $rec);
		$primaryNS = $line[4];
		$primaryIP = `dig +short $primaryNS`;
		chomp $primaryIP;
		$done = 1;
	    }
	}
	if ($done) { 
	    print "Importing $domainname from $primaryIP as secondary\n";
	    $line[2] = $domainname;
	    $line[3] = $primaryIP;
	    add_SECONDARY(@line);
	}
    } else {
	foreach my $rec (@records) {
	    chomp $rec;
	    $org_rec = $rec;
	    $rec =~ s/\s+/ /g;
	    $rec =~ tr/[A-Z]/[a-z]/;
	    my @line = split(/ /, $rec);
	    if ( $line[2] eq "ptr" ) { add_PTR(@line); }
	    switch ( $line[2] ) {
		case "a" { add_A(@line); }
		case "ns" { add_NS(@line); }
		case "mx" { add_MX(@line); }
		case "cname" { add_CNAME(@line); }
		case "txt" { add_TXT($org_rec, @line); }
	    }
	    if ( $rec =~ m/in soa/ ) { $start = "1"; }
	    if ( ($rec eq "" and $start) or ( $rec =~/end soa header/ and $start) ) { $start = "0"; }
	    if ( $start ) { $soa .= $rec . "\n"; }
	}
	($s, $n) = split(/\)/, $soa);
	$s =~ s/;.*//g; $s =~ s/\n//g; $s =~ s/\s+/ /g;
	mod_SOA($s, $n);
	@records = ""; $n = $s = "";
    }
}

sub mod_SOA {
    my $sa = shift;
    my $dns = shift;
    my $hash = {};
    my $base = $domainname;

    if ( $base =~ /(\d+\.\d+\.\d+\.\d+)(\/\d+)/ ) {
	$base = $1;
	($oid) = $cce->find('DnsSOA', { ipaddr => $base });
    } else {
	($oid) = $cce->find('DnsSOA', { domainname => $base });
    }
    if(!$oid) {
	print "Cannot find DNS SOA record for $base\n";
	return;
    }

    my @soa = split(/ /, $sa);

    $email = ""; $email = $soa[4]; $email =~ s/\./\@/; $email =~ s/\.$//;
    $dns1 = ""; $dns1 = $soa[3];$dns1 =~ s/\.$//;

    @dns_servers = split("\n", $dns);
    foreach $server(@dns_servers) {
	$server =~ chomp;
	$server =~ s/\s+/ /g;
	$server =~ tr/[A-Z]/[a-z]/;
	if ( $server =~ /in ns/ ) {
	    @list = split(/ /, $server);
	    $ds = $list[3];
	    $ds =~ s/\.$//;
	    if ( $ds ne $dns1 ) {
		$hash->{secondary_dns} = $ds;
	    }
	}
    }
    @dns_servers = ""; $dns = "";

    $hash->{primary_dns} = $dns1;
    $hash->{domain_admin} = $email;
    $hash->{refresh} = $soa[7];
    $hash->{retry} = $soa[8];
    $hash->{expire} = $soa[9];
    $hash->{ttl} = $soa[10];

    my ($ok, $bad, @info) = $cce->set($oid, '', $hash);
    if($ok == 0) {
                # $cce->printReturn($ok, $bad, @info);
    } else {
	print "SOA record ", $base, " has been modified sucessfully\n";
    }
}

sub add_A {
    my @record = @_;
    my $hash = {};

    $hostname = $record[0];
    $hostname =~ s/\.$domainname\.//;
    if ($hostname eq "$domainname." ) { $hostname = ""; }

    $hash->{type} = 'A';
    $hash->{hostname} = $hostname;
    $hash->{domainname} = $domainname;
    $hash->{ipaddr} = $record[3];

    my ($ok, $bad, @info) = $cce->create('DnsRecord', $hash);
    if($ok == 0) {
                 # $cce->printReturn($ok, $bad, @info);
    } else {
	print "A record ", $hash->{hostname}, " ", $hash->{domainname},
	" => ", $hash->{ipaddr}, " has been created sucessfully\n";
    }
}

sub add_MX {
    my @record = @_;
    my $hash = {};

    $hostname = $record[0];
    $hostname =~ s/\.$domainname\.//;
    if ($hostname eq "$domainname." ) { $hostname = ""; }

    $msn = $record[4];
    $msn =~ s/\.$//;

    switch ($record[3]) {
	case "20" { $priority = "very_high"; }
	case "30" { $priority = "high"; }
	case "40" { $priority = "low"; }
	case "50" { $priority = "very_low"; }
    }

    $hash->{type} = 'MX';
    $hash->{hostname} = $hostname;
    $hash->{domainname} = $domainname;
    $hash->{mail_server_priority} = $priority;
    $hash->{mail_server_name} = $msn;

    my ($ok, $bad, @info) = $cce->create('DnsRecord', $hash);
    if($ok == 0) {
                # $cce->printReturn($ok, $bad, @info);
    } else {
	print "MX record ", $hash->{hostname}, " ", $hash->{domainname},
	" => ", $hash->{mail_server_name}, " with priority ",
	$hash->{mail_server_priority}, " has been created sucessfully\n";
    }
}

sub add_CNAME {
    my @record = @_;
    my $hash = {};

    $hostname = $record[0];
    $hostname =~ s/\.$domainname\.//;
    if ($hostname eq "$domainname." ) { $hostname = ""; }

    $alias = $record[3];
    ($host, $domain) = split(/\./, $alias, 2);
    $domain =~ s/\.$//;

    $hash->{type} = 'CNAME';
    $hash->{hostname} = $hostname;
    $hash->{domainname} = $domainname;
    $hash->{alias_hostname} = $host;
    $hash->{alias_domainname} = $domain;

    my ($ok, $bad, @info) = $cce->create('DnsRecord', $hash);
    if($ok == 0) {
                # $cce->printReturn($ok, $bad, @info);
    } else { 
	print "CNAME record ", $hash->{hostname}, " ", $hash->{domainname},
	" => ", $hash->{alias_hostname}, " ", $hash->{alias_domainname},
	" has been created sucessfully\n";
    }
}

sub add_TXT {
    my $line = shift;
    my @record = @_;
    my $hash = {};
    $line = $line;
    $line =~ s/^.*\"(.*)\"/\1/;
#    print "reg ex 1 = $line\n";

    $hostname = $record[0];
    $hostname =~ s/\.$domainname\.//;
    if ($hostname eq "$domainname." ) { $hostname = ""; }

    $alias = $record[3];
    ($host, $domain) = split(/\./, $alias, 2);
    $domain =~ s/\.$//;

    $hash->{type} = 'TXT';
    $hash->{hostname} = $hostname;
    $hash->{domainname} = $domainname;
    $hash->{strings} = $line;

    my ($ok, $bad, @info) = $cce->create('DnsRecord', $hash);
    if($ok == 0) {
                # $cce->printReturn($ok, $bad, @info);
    } else { 
	print "TXT record ", $hash->{hostname}, " ", $hash->{domainname},
	" => \"", $hash->{strings}, " ", "\" has been created sucessfully\n";
    }
}

sub add_PTR {
    my @record = @_;
    my $hash = {};

    $hostname = $record[3];
    ($host, $domain) = split(/\./, $hostname, 2);
    $domain =~ s/\.$//;

    $net = $domainname;
    $net =~ s/\.in-addr\.arpa//;
    @ar = split(/\./, $net);
    @ar = reverse(@ar);
    $net = "";
    foreach $i(@ar) {
	$net = $net . "." . $i;
    }
    $net =~ s/^\.//;

    $hash->{type} = 'PTR';
    $hash->{ipaddr} = $net . "." . $record[0];
    $hash->{hostname} = $host;
    $hash->{domainname} = $domain;
#    $hash->{netmask} = get_netmask();
    $hash->{netmask} = '255.255.255.0';

    my ($ok, $bad, @info) = $cce->create('DnsRecord', $hash);
    if($ok == 0) {
                # $cce->printReturn($ok, $bad, @info);
    } else {
	print "PTR record ", $hash->{ipaddr}, " => ", $hash->{hostname},
	" ", $hash->{domainname}, " has been created sucessfully\n";
    }
}

sub add_NS {
    my @record = @_;
    my $hash = {};

    $hostname = $record[0];
    $hostname =~ s/\.$domainname\.//;
    if ($hostname eq "$domainname." ) { return; }

    $dds = $record[3];
    $dds =~ s/\.$//;

    $hash->{type} = 'SN';
    $hash->{hostname} = $hostname;
    $hash->{domainname} = $domainname;
    $hash->{delegate_dns_servers} = $dds;

    my ($ok, $bad, @info) = $cce->create('DnsRecord', $hash);
    if($ok == 0) {
                # $cce->printReturn($ok, $bad, @info);
    } else {
	print "NS record ", $hash->{hostname}, ".", $hash->{domainname}, " => ", $hash->{delegate_dns_servers},
	" has been created sucessfully\n";
    }
}

sub get_netmask {
    if (-e "/proc/user_beancounters") {
	my $netmask = `ifconfig venet0:0 | grep "inet addr" | cut -f 5 -d":" | cut -f 1 -d" "`;
    }
    else {
	my $netmask = `ifconfig eth0 | grep "inet addr" | cut -f 4 -d":" | cut -f 1 -d" "`;
    }
    chomp($netmask);
    return $netmask;
}

sub add_SECONDARY
{
    my @record = @_;
    my $hash = {};

    if($record[2] =~ /\d+\.\d+\.\d+\.\d+/) {
	$hash->{ipaddr} = $record[2];
	$hash->{netmask} = get_netmask();
    } else {
	$hash->{domain} = $record[2];
    }
    $hash->{masters} = $record[3];

    # If the dig returned one of the root servers as master, then
    # discard that info and proceed:
    if ($hash->{masters} =~ /ROOT-SERVERS\.NET/) {
	$hash->{masters} = "";
    }
    
    my ($ok, $bad, @info) = $cce->create('DnsSlaveZone', $hash);
    if($ok == 0) {
	$cce->printReturn($ok, $bad, @info);
    } else { 
	print "Secondary record ", $hash->{domain}, $hash->{ipaddr}, 
	" => ", $hash->{masters}, " has been created sucessfully\n";
    }
}

sub read_records { 
    my $records = shift;
    if(!open(FH, "<$records")) {
	print "Could open records file: $records\n";
	exit 1;
    }
    my @data = <FH>;
    close(FH);
    my @inc_data;
    if(open(FH, "<$records.include")) {
        @inc_data = <FH>;
        close(FH);
    }
    push (@data,@inc_data);
    return @data;
}

sub commit_changes {
    my $time = time();
    my ($oid) = $cce->find('System');
    if(!$oid) {
	print "Could not find System OID, cannot commit changes\n";
	return;
    }
    $cce->set($oid, 'DNS', { commit => $time });
    $cce->commit();
}

# 
# Copyright (c) 2014 Michael Stauber, SOLARSPEED.NET
# Copyright (c) 2006, NuOnce Networks, Inc.
# Copyright (c) 2014 Team BlueOnyx, BLUEONYX.IT
# All Rights Reserved.
# 
# 1. Redistributions of source code must retain the above copyright 
#    notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright 
#    notice, this list of conditions and the following disclaimer in 
#    the documentation and/or other materials provided with the 
#    distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its 
#    contributors may be used to endorse or promote products derived 
#    from this software without specific prior written permission.
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