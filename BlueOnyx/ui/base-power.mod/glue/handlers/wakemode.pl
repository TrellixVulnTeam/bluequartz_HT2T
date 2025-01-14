#!/usr/bin/perl -I/usr/sausalito/perl -I/usr/sausalito/handlers/base/power
# $Id: wakemode.pl 259 2004-01-03 06:28:40Z shibuya $
# Copyright 2000, 2001 Sun Microsystems, Inc., All rights reserved.

use CCE;
use Sauce::Util;
use I18n;

my ($return1, $return2);
my $flag = 0;
my $port;
my $kernel_wakeutil = '/usr/sbin/ethtool';
my $eeprom_wakeutil = '/usr/sbin/enet_eeprom';
my $cce = new CCE("Namespace" => "Power");
$cce->connectfd();

my $old = $cce->event_old();
my $object = $cce->event_object();
my $new = $cce->event_new();

if (-e $kernel_wakeutil && -e $eeprom_wakeutil ) {
	# find out what IO port the ethernet controller uses.
	open PCI, '</proc/pci';
	while (<PCI>) {
		if (/Ethernet/) {
		$flag = 1;
		} elsif ($flag && /I\/O/) {
		/at (\w+)/;
		$port = $1;
		last;
		}
	}
	close(PCI);

	my @eeprom_args = ($eeprom_wakeutil, '-p', $port, '-d', 'natsemi', '-w', 'wol');
	my @kernel_args = ($kernel_wakeutil, '-s', 'eth0', 'wol');

	if ($new->{wakemode} || $new->{set_modes_now}) {
		if ($object->{wakemode} eq 'none') {
		push @kernel_args, ('d');
		push @eeprom_args, ('d');
		} elsif ($object->{wakemode} eq 'magic') {
		push @kernel_args, ('g');
		push @eeprom_args, ('g');
		}
    
		$return1 = system(@kernel_args);
		$return2 = system(@eeprom_args);

		if (($return1 != 0) || ($return2 != 0)) {
		$cce->warn("[[base-power.errSettingWakeMode]]");
		$cce->bye('FAIL');
		exit 1;
		}
	}
}

$cce->bye('SUCCESS');
exit 0;

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
