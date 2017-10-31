#!/usr/bin/perl -I/usr/sausalito/perl -I.
#
# original author: Kevin K.M. Chiu
# rewritten by: someone else
#
# There is no longer a System.Disk namespace, so now this runs on the 
# Disk.refresh property

use CCE;
use Base::Disk qw(disk_get_usage_info);

# Debugging switch:
$DEBUG = "0";
if ($DEBUG)
{
        use Sys::Syslog qw( :DEFAULT setlogsock);
}

my $cce = new CCE('Domain' => 'base-disk');
$cce->connectfd();

my $disk = $cce->event_object();

# don't bother if the disk isn't mounted
if (not $disk->{mounted})
{
    &debug_msg("SUCCESS: Not mounted, exiting. \n");
    $cce->bye('SUCCESS');
    exit(0);
}

# df.  use mountPoint in case it is a network file system
my $usage_info = disk_get_usage_info($disk->{mountPoint});

if ($usage_info == undef)
{
    &debug_msg("FAIL: [[base-disk.cantExecuteDf]] \n");
    $cce->bye('FAIL', '[[base-disk.cantExecuteDf]]');
    exit(1);
}

# write result to CCE
&debug_msg("Setting for " . $disk->{device} . ": total: " . $usage_info->{$disk->{device}}->{Total} . " - used: " . $usage_info->{$disk->{device}}->{Used} . " \n");
my ($ok) = $cce->set($cce->event_oid(), '', 
                {
                    'total' => $usage_info->{$disk->{device}}->{Total},
                    'used' => $usage_info->{$disk->{device}}->{Used}
                });

if (!$ok) 
{
    $cce->bye('FAIL', 'cantUpdateDiskInfo', { 'device' => $disk->{device} });
    exit(1);
}

$cce->bye('SUCCESS');
exit(0);

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
# Copyright (c) 2015 Michael Stauber, SOLARSPEED.NET
# Copyright (c) 2015 Team BlueOnyx, BLUEONYX.IT
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