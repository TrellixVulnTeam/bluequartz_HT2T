#!/usr/bin/perl -I /usr/sausalito/perl
# Toggles the memcached on and off

use CCE;
use Sauce::Service;
use Sauce::Util;

my $cce = new CCE('Namespace' => 'memcache');
$cce->connectuds();

# Find out if memcached is enabled at the moment:
my @oids = $cce->find('System');
if (not @oids) {
    $cce->bye('FAIL');
    exit 1;
}
my ($ok, $obj) = $cce->get($oids[0], 'memcache');
unless ($ok and $obj) {
    $cce->bye('FAIL');
    exit 1;
}

my $sysconfig = '/etc/sysconfig/memcached';
if (!Sauce::Util::editfile($sysconfig, *update_sysconfig, $obj)) {
    $cce->warn("[[base-memcache.errorWritingConfFile]]");
}

service_toggle_init('memcached', $obj->{'enabled'});
if ($obj->{'enabled'} eq "1") {
    Sauce::Service::service_run_init('memcached', 'restart');
}
else {
    Sauce::Service::service_run_init('memcached', 'stop');
}

$cce->bye('SUCCESS');
exit(0);

sub update_sysconfig {
    my ($fin, $fout, $obj) = @_;

    my $cachesize = $obj->{'cachesize'};

    while (<$fin>) {
        if (/CACHESIZE/) {
            print $fout "CACHESIZE=\"$cachesize\"\n";
        }
        elsif (/OPTIONS/) {
            print $fout "OPTIONS=\"-l 127.0.0.1\"\n";
        }
        else {
            print $fout $_;
        }
    }
    return 1;
}

# 
# Copyright (c) 2015 Hisao Shibuya, Smack, Inc.
# Copyright (c) 2015 Team BlueOnyx, BLUEONYX.IT
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
