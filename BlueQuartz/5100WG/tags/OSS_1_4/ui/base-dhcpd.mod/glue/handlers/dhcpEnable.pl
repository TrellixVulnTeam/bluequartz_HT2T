#!/usr/bin/perl -w -I/usr/sausalito/perl -I/usr/sausalito/handlers/base/dhcpd
#$Id: dhcpEnable.pl 3 2003-07-17 15:19:15Z will $
#
# DhcpParam.enable handler
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

my $enabled = $paramobj->{enabled};

my $old = $cce->event_old();
my $oldEnabled=$old->{enabled};

#print STDERR "$0: Enabled flag change ", $oldEnabled, " ", $enabled,"\n";

    if( $enabled ) { $ret=Dhcpd::set_dhcp_server_on( 1 ); }
    else { $ret=Dhcpd::set_dhcp_server_on( 0 ); }

if ($ret) {
	$cce->warn("[[base-dhcpd.cannotStartDhcp]]");
        $cce->bye('FAIL');
} else {
        $cce->bye('SUCCESS');
}

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
