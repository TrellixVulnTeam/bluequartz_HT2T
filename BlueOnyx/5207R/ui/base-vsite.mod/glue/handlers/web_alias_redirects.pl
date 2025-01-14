#!/usr/bin/perl -I/usr/sausalito/perl
# $Id: web_alias_redirects.pl

# This handler is run whenever 'Vsite' key 'webAliasRedirects' is set.
#
# When that happens, this script adds or removes the RewriteCond's of Web aliases
# which either allow aliases to run as sites with own URL, or which redirect to
# the main site instead.

# Debugging switch:
$DEBUG = "0";
if ($DEBUG)
{
        use Sys::Syslog qw( :DEFAULT setlogsock);
}


$whatami = "handler";

#
#### No configureable options below!
#

use CCE;
use Data::Dumper;
use Sauce::Service;
use Sauce::Util;
use Base::HomeDir qw(homedir_get_group_dir homedir_get_user_dir);
use Base::Httpd qw(httpd_get_vhost_conf_file);

my $cce = new CCE;
my $conf = '/var/lib/cobalt';

if ($whatami eq "handler") {
    $cce->connectfd();

    # Get our events from the event handler stack:
    $oid = $cce->event_oid();
    $obj = $cce->event_object();

    $old = $cce->event_old();
    $new = $cce->event_new();

    ($soid) = $cce->find('System');
    ($ok, $obj) = $cce->get($soid);

    # Get "System" . "Web":
    ($ok, $objWeb) = $cce->get($soid, 'Web');

    # HTTP and SSL ports:
    $httpPort = "80";
    if ($objWeb->{'httpPort'}) {
        $httpPort = $objWeb->{'httpPort'};
    }
    $sslPort = "443";
    if ($objWeb->{'sslPort'}) {
        $sslPort = $objWeb->{'sslPort'};
    }

    # Poll info about the Vsite in question:
    ($ok, $vsite) = $cce->get($oid);

    # Event is create or modify:
    if ((($cce->event_is_create()) || ($cce->event_is_modify()))) {

    # Edit the vhost container or die!:
    if(!Sauce::Util::editfile(httpd_get_vhost_conf_file($vsite->{"name"}), *edit_vhost, $vsite->{"webAliases"})) {
        $cce->bye('FAIL', '[[base-apache.cantEditVhost]]');
        exit(1);
    }

    # Restart Apache:
    &restart_apache;
    }
}

$cce->bye('SUCCESS');
exit(0);

sub restart_apache {
    # Restarts Apache - soft restart:
    service_run_init('httpd', 'reload');
}

sub edit_vhost {
    my ($in, $out, $php, $cgi, $ssi) = @_;

    # Build the webAlias Array:
    my $aliasRewrite, $aliasRewriteSSL;
    #SET  347 "webAliases" "=" "" "webAliasRedirects" "=" "0"
    #SET  347 "webAliases" "=" "&*.schulbus-tours.de&" "webAliasRedirects" "=" "1"
    &debug_msg("Before trigger.\n");

    #
    #### Build our output string:
    #

    #
    ### Non SSL:
    #

    # Basic Vsite related RewriteCond's first:
    $vhost_conf = "RewriteCond %{HTTP_HOST}                !^$vsite->{ipaddr}(:$httpPort)?\$\n";
    $vhost_conf .= "RewriteCond %{HTTP_HOST}                !^$vsite->{fqdn}(:$httpPort)?\$ [NC]\n";
    # Add aliases (if there are any!):
    if (($vsite->{webAliases}) && ($vsite->{webAliasRedirects} == "0")) {
        &debug_msg("webAliasRedirects is set to '0' - no separate RewriteCond's for Aliases!\n");
        my @webAliases = $cce->scalar_to_array($vsite->{webAliases});
        foreach my $alias (@webAliases) {
            &debug_msg("Alias alt: $alias\n");
            $alias =~ s/^\*/\\*/g;
            &debug_msg("Alias neu: $alias\n");
            $vhost_conf .= "RewriteCond %{HTTP_HOST}                !^$alias(:$httpPort)?\$ [NC]\n";
        }
    }
    $vhost_conf .= "\n";

    #
    ### For SSL:
    #

    # Basic Vsite related RewriteCond's first:
    $vhost_conf_SSL = "RewriteCond %{HTTP_HOST}                !^$vsite->{ipaddr}(:$sslPort)?\$\n";
    $vhost_conf_SSL .= "RewriteCond %{HTTP_HOST}                !^$vsite->{fqdn}(:$sslPort)?\$ [NC]\n";
    # Add aliases (if there are any!):
    if (($vsite->{webAliases}) && ($vsite->{webAliasRedirects} == "0")) {
        &debug_msg("webAliasRedirects is set to '0' - no separate RewriteCond's for Aliases!\n");
        my @webAliases = $cce->scalar_to_array($vsite->{webAliases});
        foreach my $alias (@webAliases) {
            &debug_msg("Alias alt: $alias\n");
            $alias =~ s/^\*/\\*/g;
            &debug_msg("Alias neu: $alias\n");
            $vhost_conf_SSL .= "RewriteCond %{HTTP_HOST}                !^$alias(:$sslPort)?\$ [NC]\n";
        }
    }
    $vhost_conf_SSL .= "\n";

    # Do the actual editing:
    my $vhost_content = '';
    $block_found = "0";
    $SSL_block_found = "0";
    while(<$in>) {
        if (/^RewriteEngine on/i) {
            # First block-start found:
            $block_found = '1';
            &debug_msg("block start found: $block_found\n");
            # Store the found line:
            $vhost_content .= $_;
            chomp($vhost_content);
        }
        elsif (/^SSLengine on/i) {
            &debug_msg("SSL VirtualHost found ... \n");
            # Found start of the SSL-VhostContainer:
            $SSL_block_found = '1';
            # Store the found line:
            $vhost_content .= $_;
        }
        elsif (/^RewriteRule/i) {
            # Block end found.
            $block_found = '0';
            &debug_msg("block end found: $block_found\n");
            # Print the correct replacement depending on where we are in the config:
            if ($SSL_block_found eq "0") {
                # Print non-SSL RewriteRule:
                $vhost_content .= $vhost_conf;
            }
            else {
                # Print SSL RewriteRule:
                $vhost_content .= $vhost_conf_SSL;
            }
            # Store the found line:
            $vhost_content .= $_;
        }
        elsif (/^RewriteCond/i) {
            # Ignore
            &debug_msg("Ignoring original RewriteCond: $_ \n");
            #next;
        }
        else {
            # Store the found line:
            $vhost_content .= $_;
        }
    }

    # Print out our new Config:
    print $out $vhost_content;

    ## preserve the remainder of the config file and write it out:
    #while(<$in>) {
    #    print $out $_;
    #}

    return 1;
}

sub debug_msg {
    if ($DEBUG) {
        my $msg = shift;
        $user = $ENV{'USER'};
        setlogsock('unix');
        openlog($0,'','user');
        syslog('info', "$ARGV[0]: $msg");
        closelog;
    }
}

$cce->bye('SUCCESS');
exit(0);

# 
# Copyright (c) 2016 Michael Stauber, SOLARSPEED.NET
# Copyright (c) 2016 Team BlueOnyx, BLUEONYX.IT
# Copyright (c) 2003 Sun Microsystems, Inc. 
# All Rights Reserved.
# 
# 1. Redistributions of source code must retain the above copyright 
#     notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright 
#     notice, this list of conditions and the following disclaimer in 
#     the documentation and/or other materials provided with the 
#     distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its 
#     contributors may be used to endorse or promote products derived 
#     from this software without specific prior written permission.
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