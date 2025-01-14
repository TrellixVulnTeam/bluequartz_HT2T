#!/usr/bin/perl -I/usr/sausalito/perl
# $Id: config_nginx.pl

# Debugging switch:
$DEBUG = "0";
if ($DEBUG)
{
    use Sys::Syslog qw( :DEFAULT setlogsock);
}

use CCE;
use Sauce::Util;
use Sauce::Config;

my $cce = new CCE;
$cce->connectfd();

# Location of config file:
$nginx_conf = '/etc/nginx/nginx.conf';

@SysOID = $cce->find("System");

($ok, $System) = $cce->get($SysOID[0]);
($ok, $Nginx) = $cce->get($SysOID[0], 'Nginx');

#
### Assemble new config:
#

$new_conf = '#' . "\n";
$new_conf .= '# Do NOT edit this file. The GUI will replace this file on edits.' . "\n";
$new_conf .= '# Custom edits need to go into separate config files in one of' . "\n";
$new_conf .= '# the separate include directories under /etc/nginx/' . "\n";
$new_conf .= '#' . "\n";
$new_conf .= 'user  nginx;' . "\n";
$new_conf .= 'worker_processes  ' . $Nginx->{worker_processes} . ';' . "\n";
$new_conf .= '' . "\n";
$new_conf .= 'error_log  /var/log/nginx/error.log warn;' . "\n";
$new_conf .= 'pid        /var/run/nginx.pid;' . "\n";
$new_conf .= '' . "\n";
$new_conf .= '' . "\n";
$new_conf .= 'events {' . "\n";
$new_conf .= '    worker_connections  ' . $Nginx->{worker_connections} . ';' . "\n";
$new_conf .= '}' . "\n";
$new_conf .= '' . "\n";
$new_conf .= 'include /etc/nginx/conf/*.conf;' . "\n";
$new_conf .= '' . "\n";

# Edit the file:
if(!Sauce::Util::editfile($nginx_conf, *cfg_printer)) {
    &debug_msg("Failed to edit $nginx_conf through config_nginx.pl \n");
    $cce->bye('FAIL', '[[base-nginx.cantEditCfg]]');
    exit(1);
}
else {
    &debug_msg("Editing $nginx_conf through config_nginx.pl - DONE \n");
    system("/usr/bin/chmod 644 $nginx_conf");
}

$cce->bye('SUCCESS');
exit(0);

#
### Subroutines:
#

sub cfg_printer {
    ($in, $out) = @_;
    print $out $new_conf;
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

# 
# Copyright (c) 2018 Michael Stauber, SOLARSPEED.NET
# Copyright (c) 2018 Team BlueOnyx, BLUEONYX.IT
# All Rights Reserved.
# 
# 1. Redistributions of source code must retain the above copyright 
#    notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright 
#    notice, this list of conditions and the following disclaimer in 
#    the documentation and/or other materials provided with the 
#    distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its 
#    contributors may be used to endorse or promote products derived 
#    from this software without specific prior written permission.
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