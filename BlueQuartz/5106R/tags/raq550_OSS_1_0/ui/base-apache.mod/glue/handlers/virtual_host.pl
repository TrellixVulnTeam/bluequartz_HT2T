#!/usr/bin/perl -I/usr/sausalito/perl
# $Id: virtual_host.pl 259 2004-01-03 06:28:40Z shibuya $
# Copyright 2000, 2001 Sun Microsystems, Inc., All rights reserved.
# handle the creation of configuration files for individual vhosts
#

use CCE;
use Sauce::Config;
use Sauce::Util;
use Base::Httpd qw(httpd_get_vhost_conf_file);

my $DEBUG = 0;

my $cce = new CCE;

$cce->connectfd();

my $vhost = $cce->event_object();
my $vhost_new = $cce->event_new();
my $vhost_old = $cce->event_old();

# make sure the directory exists before trying to edit the file
if (!-d $Base::Httpd::vhost_dir)
{
    Sauce::Util::makedirectory($Base::Httpd::vhost_dir);
    Sauce::Util::chmodfile(0751, $Base::Httpd::vhost_dir);
}

if (!Sauce::Util::editfile(
        httpd_get_vhost_conf_file($vhost->{name}), 
        *edit_vhost, $vhost))
{
    $cce->bye('FAIL', '[[base-apache.cantEditVhost]]');
    exit(1);
}

Sauce::Util::chmodfile(0644, httpd_get_vhost_conf_file($vhost->{name}));
$cce->bye('SUCCESS');
exit(0);


sub edit_vhost
{
    my ($in, $out, $vhost) = @_;

    my $user_root = $vhost->{documentRoot};
    $user_root =~ s#web$#users/\$1/web/\$3#;

    my $site_root = $vhost->{documentRoot};
    $site_root =~ s/\/web$//;

    my $vhost_conf =<<END;
# owned by VirtualHost
NameVirtualHost $vhost->{ipaddr}

# FrontPage needs the following four things to be here
# otherwise all the vhosts need to go in httpd.conf, which could
# get very large since there could be thousands of vhosts
Port 80
ServerRoot $Base::Httpd::server_root
ResourceConfig $Base::Httpd::srm_conf_file
AccessConfig $Base::Httpd::access_conf_file

<VirtualHost $vhost->{ipaddr}>
ServerName $vhost->{fqdn}
ServerAdmin $vhost->{serverAdmin}
DocumentRoot $vhost->{documentRoot}
ErrorDocument 401 /error/401-authorization.html
ErrorDocument 403 /error/403-forbidden.html
ErrorDocument 404 /error/404-file-not-found.html
ErrorDocument 500 /error/500-internal-server-error.html
RewriteEngine on
RewriteCond %{HTTP_HOST}                !^$vhost->{ipaddr}(:80)?\$
RewriteCond %{HTTP_HOST}                !^$vhost->{fqdn}(:80)?\$ [NC]
RewriteRule ^/(.*)                      http://$vhost->{fqdn}/\$1 [L,R]
RewriteOptions inherit
AliasMatch ^/~([^/]+)(/(.*))?           $user_root
</VirtualHost>

# FrontPage needs the following block in order to be able to use SSL on
# this virtual host.  Note: If this block occurs below the Port80 
# block, then the automatic Perl configuration in ../httpd.conf fails.
<IfDefine FrontPageSSLRequirements>
Port 443
 <VirtualHost $vhost->{ipaddr}:443>
ServerName $vhost->{fqdn}
DocumentRoot $vhost->{documentRoot}
SSLEngine on
 </VirtualHost>
</IfDefine>
END

    # append line marking the end of the section specifically owned by the VirtualHost
    my $end_mark = "# end of VirtualHost owned section\n";
    $vhost_conf .= $end_mark;

    my $conf_printed = 0;

    while (<$in>)
    {
    	if (!$conf_printed && /^$end_mark$/)
    	{
    		print $out $vhost_conf;
    		$conf_printed = 1;
    	}
    	elsif ($conf_printed)
    	{
    		# print out information entered by other objects
    		print $out $_;
    	}
    }

    if (!$conf_printed)
    {
    	print $out $vhost_conf;
    }

    return 1;
}
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
