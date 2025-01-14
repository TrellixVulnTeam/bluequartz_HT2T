#!/usr/bin/perl -w -I/usr/sausalito/perl
# $Id: vhost_addrem.pl 715 2006-03-12 15:26:40Z shibuya $
# Copyright 2000-2002 Sun Microsystems, Inc., All rights reserved.
#
# add or remove the include line for a vhost when creating or destroying,
#

use CCE;
use Sauce::Util;
use Base::Httpd qw(httpd_add_include httpd_remove_include);
use Sauce::Service;

my $cce = new CCE;

$cce->connectfd();

my ($ok, $vhost);
my $vhost_new = $cce->event_new();
if ($cce->event_is_create()) { 
	$vhost = $cce->event_object();
	Sauce::Util::addrollbackcommand("/etc/rc.d/init.d/httpd restart >/dev/null 2>&1 &");
	$ok = httpd_add_include("$Base::Httpd::vhost_dir/$vhost->{name}");

} elsif ($cce->event_is_destroy()) { 
	$vhost = $cce->event_old();
	Sauce::Util::addrollbackcommand("/etc/rc.d/init.d/httpd restart >/dev/null 2>&1 &");
	$ok = httpd_remove_include("$Base::Httpd::vhost_dir/$vhost->{name}");
	# don't remove the file here to avoid a race condition
}

if (not $ok) {
	$cce->bye('FAIL', '[[base-apache.cantEditHttpdConf]]');
	exit(1);
}

# perview config moves to last line
$ok = httpd_remove_include("$Base::Httpd::vhost_dir/preview");
$ok = httpd_add_include("$Base::Httpd::vhost_dir/preview");
if (not $ok) {
        $cce->bye('FAIL', '[[base-apache.cantEditHttpdConf]]');
        exit(1);
}

# always register a reload, to make sure apache knows the file is gone
service_run_init('httpd', 'reload');

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
