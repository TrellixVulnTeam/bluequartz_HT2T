##---------------------------------------------------------------------------##
##  File:
##      @(#) mhlock.pl 1.2 99/07/13 00:48:29
##  Author:
##      Earl Hood       mhonarc@pobox.com
##  Description:
##	Lock functions for MHonArc.
##---------------------------------------------------------------------------##
##    MHonArc -- Internet mail-to-HTML converter
##    Copyright (C) 1997-1999	Earl Hood, mhonarc@pobox.com
##
##    This program is free software; you can redistribute it and/or modify
##    it under the terms of the GNU General Public License as published by
##    the Free Software Foundation; either version 2 of the License, or
##    (at your option) any later version.
##
##    This program is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY; without even the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##    GNU General Public License for more details.
##
##    You should have received a copy of the GNU General Public License
##    along with this program; if not, write to the Free Software
##    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
##    02111-1307, USA
##---------------------------------------------------------------------------##

package mhonarc;

#############################################################################
##	Constants
#############################################################################

sub MHA_LOCK_MODE_DIR ()	{ 0; }
    ## -- Directory method: Works on all platforms, but lock dir can be
    ##	    left around if abnormal termination.
sub MHA_LOCK_MODE_FLOCK ()	{ 1; }
    ## -- flock() method: Works on select platforms.  Can have problems
    ##	    if writing to an NFS mount depending on how perl is built.
    ##	    If available, and not writing to NFS (or reliable over NFS)
    ##	    this method is better than directory method.


#############################################################################
##	Variables
#############################################################################

my $_lock_file	= undef;
my $_flock_fh	= undef;

$LockFunc	= undef;
$UnlockFunc	= undef;

#############################################################################
##	Functions
#############################################################################

##---------------------------------------------------------------------------
##	set_lock_mode(): Set locking method used by MHonArc.
##
sub set_lock_mode {
    my $mode = shift;
    if ($mode =~ /\D/) {
	STR2NUM: {
	    if ($mode =~ /^\s*flock/) {
		$mode = &MHA_LOCK_MODE_FLOCK;
		last STR2NUM;
	    }
	    $mode = &MHA_LOCK_MODE_DIR;
	    last STR2NUM;
	}
    }
    if ($mode == &MHA_LOCK_MODE_FLOCK) {
	$LockFunc	= \&flock_file;
	$UnlockFunc	= \&unflock_file;
	return ;
    }
    $mode = &MHA_LOCK_MODE_DIR;
    $LockFunc	= \&create_lock_dir;
    $UnlockFunc	= \&remove_lock_dir;

    $mode;
}

#############################################################################
##	Directory Method of Locking Functions
#############################################################################

##---------------------------------------------------------------------------
##	create_lock_dir() creates a directory to act as a lock.
##
sub create_lock_dir {
    my($file, $tries, $sleep, $force) = @_;
    my $prtry = 0;
    my $ret = 0;
    $_lock_file = $file;
    while ($tries > 0) {
	if (mkdir($file, 0777)) { $ISLOCK = 1;  $ret = 1;  last; }
	sleep($sleep)  if $sleep > 0;
	$tries--;
	if (!$prtry && ($tries > 0)) {
	    print STDOUT qq/Trying to create lock ...\n/  unless $QUIET;
	    $prtry = 1;
	}
    }
    if ($force) { $ISLOCK = 1;  $ret = 1; }
    $ret;
}

##---------------------------------------------------------------------------
##	remove_lock_dir removes the lock directory
##
sub remove_lock_dir {
    if ($ISLOCK) {
	if (!rmdir($_lock_file)) {
	    warn "Warning: Unable to remove $LOCKFILE: $!\n";
	    return 0;
	}
	$ISLOCK = 0;
    }
    1;
}

#############################################################################
##	Flock Functions
#############################################################################

##---------------------------------------------------------------------------
##	flock_file(): Create archive lock using flock(2).
##
sub flock_file {
    my($file, $tries, $sleep, $force) = @_;

    eval {
	require Symbol;
	require Fcntl;
	Fcntl->import(':DEFAULT', ':flock');
    };
    if ($@) {
	warn qq/Warning: Unable to require modules for flock() lock method: /,
	     qq/$@\n/,
	     qq/\tFalling back to directory method.\n/;
	set_lock_mode(MHA_LOCK_MODE_DIR);
	return &$LockFunc(@_);
    }

    $_lock_file = $file;
    $_flock_fh	= Symbol::gensym;

    if (!sysopen($_flock_fh, $file, (&O_WRONLY|&O_CREAT), 0666)) {
	warn(qq/ERROR: Unable to create "$file": $!\n/);
	return 0;
    }

    my $prtry = 0;
    my $ret = 0;
    while ($tries > 0) {
	if (flock($_flock_fh, &LOCK_EX|&LOCK_NB)) {
	    $ISLOCK = 1;  $ret = 1;  last;
	}
	sleep($sleep)  if $sleep > 0;
	$tries--;
	if (!$prtry && ($tries > 0)) {
	    print STDOUT qq/Trying to create lock ...\n/  unless $QUIET;
	    $prtry = 1;
	}
    }
    if (!$ISLOCK && $force) { $_flock_fh = undef;  $ISLOCK = 1;  $ret = 1; }

    $ret;
}

##---------------------------------------------------------------------------

sub unflock_file {
    if (defined($_flock_fh)) {
	flock($_flock_fh, &LOCK_UN);
	close($_flock_fh);
	$_flock_fh = undef;
    }
    $ISLOCK = 0;
}


##---------------------------------------------------------------------------

#############################################################################

BEGIN {
    set_lock_mode(MHA_LOCK_MODE_DIR);
}

1;
# Copyright (c) 2003 Sun Microsystems, Inc. All  Rights Reserved.
# 
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
# 
# -Redistribution of source code must retain the above copyright notice, 
# this list of conditions and the following disclaimer.
# 
# -Redistribution in binary form must reproduce the above copyright notice, 
# this list of conditions and the following disclaimer in the documentation  
# and/or other materials provided with the distribution.
# 
# Neither the name of Sun Microsystems, Inc. or the names of contributors may 
# be used to endorse or promote products derived from this software without 
# specific prior written permission.
# 
# This software is provided "AS IS," without a warranty of any kind. ALL EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES, INCLUDING ANY IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR NON-INFRINGEMENT, ARE HEREBY EXCLUDED. SUN MICROSYSTEMS, INC. ("SUN") AND ITS LICENSORS SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES. IN NO EVENT WILL SUN OR ITS LICENSORS BE LIABLE FOR ANY LOST REVENUE, PROFIT OR DATA, OR FOR DIRECT, INDIRECT, SPECIAL, CONSEQUENTIAL, INCIDENTAL OR PUNITIVE DAMAGES, HOWEVER CAUSED AND REGARDLESS OF THE THEORY OF LIABILITY, ARISING OUT OF THE USE OF OR INABILITY TO USE THIS SOFTWARE, EVEN IF SUN HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
# 
# You acknowledge that  this software is not designed or intended for use in the design, construction, operation or maintenance of any nuclear facility.
