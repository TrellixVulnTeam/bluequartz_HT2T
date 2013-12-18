#!/usr/bin/perl
# $Id: check_pool.pl
#
# Description:
#	Runs on Network creation, or change of Network.ipaddr property.
#       If IP pooling enabled, checks that the given IP address is
#       within the pool of acceptable IPs.

use lib qw(/usr/sausalito/perl);
use lib qw(/usr/sausalito/handlers/base/network);
use CCE;
use IpPooling;

# FIXME. Passing in i18n domain, needed to proper I18n msgs
# and variable interpolation by cce client libs.
my $cce = new CCE('Domain' => 'base-network');

$cce->connectfd();

my $network_new = $cce->event_new();

my ($sysoid) = $cce->find('System');
my ($ok, $network) = $cce->get($sysoid, 'Network');
if (!$ok) {
    $cce->bye('FAIL');
    exit 1;
}

if ($network->{pooling} && $network_new->{ipaddr}) {
    my (@oids) = $cce->find('IPPoolingRange');
    if (!$oids) {
        # IP-Pooling is enabled. However, no IP-Pooling range has been set up YET.
        # If we don't exit here without failure, then this will prevent the creation
        # of the initial Network objects that we need for a functioning network.
        # So we exit here now and just be done with it until someone configures the
        # IP pooling ranges. Better safe than sorry.
        $cce->bye('SUCCESS');
        exit 0;        
    }
    my @ranges = ();

    # get ranges
    foreach $a_oid (@oids) {
    	my ($ok, $range) = $cce->get($a_oid);
    	if (!$ok) {
    	    $cce->bye('FAIL');
    	    exit 1;
    	}
    	push @ranges, $range;
    }
    
    my (@error_ips) = IpPooling::validate_pooling_state(\@ranges, [ $network_new->{ipaddr} ]);
    if (@error_ips) {
    	$cce->warn('ip_restricted', {'ipaddr' => $network_new->{ipaddr}});
    	$cce->bye('FAIL');
    	exit 1;
    }
}

$cce->bye('SUCCESS');
exit 0;

#
# Copyright (c) 2013 Michael Stauber, SOLARSPEED.NET
# Copyright (c) 2013 Team BlueOnyx, BLUEONYX.IT
# Copyright (c) 2003 Sun Microsystems, Inc. All  Rights Reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, 
# are permitted provided that the following conditions are met:
# 
# -Redistribution of source code must retain the above copyright notice, this  list of conditions and the following disclaimer.
# 
# -Redistribution in binary form must reproduce the above copyright notice, 
# this list of conditions and the following disclaimer in the documentation and/or 
# other materials provided with the distribution.
# 
# Neither the name of Sun Microsystems, Inc. or the names of contributors may 
# be used to endorse or promote products derived from this software without 
# specific prior written permission.
# 
# This software is provided "AS IS," without a warranty of any kind. ALL EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES, INCLUDING ANY IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR NON-INFRINGEMENT, ARE HEREBY EXCLUDED. SUN MICROSYSTEMS, INC. ("SUN") AND ITS LICENSORS SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES. IN NO EVENT WILL SUN OR ITS LICENSORS BE LIABLE FOR ANY LOST REVENUE, PROFIT OR DATA, OR FOR DIRECT, INDIRECT, SPECIAL, CONSEQUENTIAL, INCIDENTAL OR PUNITIVE DAMAGES, HOWEVER CAUSED AND REGARDLESS OF THE THEORY OF LIABILITY, ARISING OUT OF THE USE OF OR INABILITY TO USE THIS SOFTWARE, EVEN IF SUN HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
# 
# You acknowledge that  this software is not designed or intended for use in the design, construction, operation or maintenance of any nuclear facility.
# 