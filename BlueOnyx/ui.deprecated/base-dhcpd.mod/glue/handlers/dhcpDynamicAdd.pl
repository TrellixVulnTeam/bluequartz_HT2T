#!/usr/bin/perl -w -I/usr/sausalito/perl -I/usr/sausalito/handlers/base/dhcpd
#$Id: dhcpDynamicAdd.pl,v 1.1.1.1 2003/07/17 15:15:49 will Exp $
#
# DhcpDynamic._CREATE handler
# author: Andrew Bose <andrew@cobalt.com>
# based off of Will DeHaan's Dhcp.pm
#
# generates the following i18n messages:

#use strict;
use Sauce::Config;
use FileHandle;
use CCE;
use Dhcpd;

my $cce = new CCE;
$cce->connectfd(\*STDIN,\*STDOUT);

# retreive user object data:
my $oid = $cce->event_oid();

if (!$oid) {
        # something is very, very wrong.
  $cce->bye('FAIL', 'Bad CSCP header');
  exit(1);
}

my $paramobj = $cce->event_object();
use Data::Dumper;
print STDERR Dumper($paramobj),"\n";

my $ipAddrHigh = $paramobj->{ipaddrhi};
my $ipAddrLow = $paramobj->{ipaddrlo};

print STDERR "$0: adding dynamic range ",$ipAddrLow, " ", $ipAddrHigh,"\n";

    # error check
    my $lowNotSmallerThanHigh=0;
    if( $ipAddrLow eq $ipAddrHigh ) { $lowNotSmallerThanHigh=1; }
    else {
        my @numbersHigh=split /\./, $ipAddrHigh;
        my @numbersLow=split /\./, $ipAddrLow;
        my $i;
        for( $i=0; $i<4; $i++ ) {
            if( $numbersLow[ $i ]>$numbersHigh[ $i ] ) {
                $lowNotSmallerThanHigh=1; last;
            }
        }
    }

    if( !$ipAddrLow || !$ipAddrHigh ) {
	$cce->warn("[[base-dhcpd.noIPAddrRange]]");
        $cce->bye('FAIL');
	exit;
    }
    elsif( $lowNotSmallerThanHigh ) {
	$cce->warn("[[base-dhcpd.ipAddrRangeNotValid]]");
        $cce->bye('FAIL');
	exit;
    }
    else {
        # everything is fine

        # add dynamic assignment
        my %ranges=Dhcpd::dhcpd_get_range();
        $ranges{ $ipAddrLow }=$ipAddrHigh;

	# create conf file if it does not exist
	Dhcpd::dhcpd_create_conf();

        my $err=Dhcpd::dhcpd_set_range( %ranges );
	if ($err) {
		$cce->warn("$err");
	        $cce->bye('FAIL');
	        exit;
	    }
    }


$cce->bye('SUCCESS');
exit(0);



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
