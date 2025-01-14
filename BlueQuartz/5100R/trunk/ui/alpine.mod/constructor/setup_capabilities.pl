#!/usr/bin/perl -w
# Copyright 2001 Sun Microsystems, Inc.  All rights reserved.
# $Id: setup_capabilities.pl,v 1.6 2001/11/15 22:02:36 pbaltz Exp $
# setup all necessary capability groups for the product
# this maybe should go elsewhere or the really detailed stuff should 
# be read in, maybe?

use strict;
use lib qw(/usr/sausalito/perl);
use CCE;

my $cce = new CCE;
$cce->connectuds();

# create all minor groups
my @groups = (
                {
                    'name' => 'powerOptions',
                    'shown' => 1,
                    'capabilities' => $cce->array_to_scalar(
                                        'controlPower')
                },
                {
                    'name' => 'serverBackup',
                    'shown' => 1,
                    'capabilities' => $cce->array_to_scalar(
					'modifyArkeia', 'modifyNetWorker',
					'modifyNetBackup')
                },
                {
                    'name' => 'systemMonitor',
                    'shown' => 1,
                    'capabilities' => ''
                },
                {
                    'name' => 'networkServices',
                    'shown' => 1,
                    'capabilities' => $cce->array_to_scalar(
                                        'modifyEmail', 'modifyFtp',
                                        'modifyTelnet', 'modifyHttpd',
					'modifySnmp')
                },
                {
                    'name' => 'webServices',
                    'shown' => 1,
                    'capabilities' => $cce->array_to_scalar(
                                        'modifyAsp', 'modifyJava')
                },
                {
                    'name' => 'serverConfig',
                    'shown' => 1,
                    'capabilities' => ''
                },
                {
                    'name' => 'siteAdmin',
                    'shown' => 1,
                    'capabilities' => ''
                },
		{
		    'name' => 'dnsAdmin',
		    'shown' => 1,
		    'capabilities' => $cce->array_to_scalar(
					'modifyDNS')
		},
                {
                    'name' => 'adminUser',
                    'shown' => 1,
                    'capabilities' => $cce->array_to_scalar(
                                        'siteAdmin', 'adminBlueLinq',
                                        'serverBackup', 'systemMonitor',
                                        'networkServices', 'webServices',
                                        'serverConfig', 'siteFrontpage',
                                        'siteSSL',
                                        'siteAnonFTP', 'siteShell',
                                        'modifySystemTime', 'scanDetection',
					'overflow',
					'dnsAdmin'
                                      )
                }
            );


# now loop through all the capability groups and create as necessary
for my $cap (@groups)
{
    my ($oid) = $cce->find('CapabilityGroup', { 'name' => $cap->{name} });

    if (not $oid)
    {
        my ($ok) = $cce->create('CapabilityGroup', $cap);
        if (not $ok)
        {
            print STDERR "Failed to create $cap->{name}\n";
        }
    } else {
    # reset capabilities
        my ($ok) = $cce->set($oid, "",
                                {
                                    capabilities => $cap->{capabilities}
                                });
        if (!$ok) {
            print STDERR "Failed to update $cap->{name}\n";
        }
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
