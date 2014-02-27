#!/usr/bin/perl
# $Id: user_desc.pl,v 1.3.2.1 2002/06/18 20:44:38 nelfarra Exp $
# Copyright 2000, 2001 Sun Microsystems, Inc., All rights reserved.
#
# handle changes to the description field. this also honors the
# desc_readonly field.
#
# author: asun@cobalt.com

use strict;
use lib qw( /usr/sausalito/perl );
use Sauce::Config;
use CCE;

my $cce = new CCE;
$cce->connectfd();

my $obj = $cce->event_object();

if ($obj->{desc_readonly}) {
    $cce->bye('FAIL', '[[base-user.descReadOnly]]');
    exit 1;
}

my ($uid, $gid, $path) = (getpwnam($obj->{name}))[2, 3, 7];
$path .= '/.plan';
Sauce::Util::modifyfile($path);
if (open(PLAN, ">$path")) {
    print PLAN "$obj->{description}";
    close(PLAN);
}
Sauce::Util::chownfile($uid, $gid, $path);
Sauce::Util::chmodfile(0644, $path);
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