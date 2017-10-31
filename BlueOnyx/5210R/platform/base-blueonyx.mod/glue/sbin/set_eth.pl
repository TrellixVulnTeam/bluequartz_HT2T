#!/usr/bin/perl -I/usr/sausalito/perl
# $Id: set_eth.pl
#
# Script to set Network config in CCE.
#
# Example Syntax:
# ./set_eth.pl configure eth0 10.1.224.1 255.255.0.0

use CCE;
my $cce = new CCE;

$cce->connectuds();

if (defined($ARGV[1])) {
    if ($ARGV[0] = "configure") {
        $device = $ARGV[1];
        $ipaddr = $ARGV[2];
        $netmask = $ARGV[3];
    }
}
if ((!$device) && (!$ipaddr) && (!$netmask)) {
    print "Syntax: /usr/sausalito/sbin/set_eth.pl configure <device> <IP> <Netmask> \n";
    $cce->bye('FAIL');
    exit 1;
}
else {

    # Check if this Network object already exists:
    @oids = $cce->find('Network', {'device' => $device});

    if ($#oids < 0) {
        # Object not yet in CCE. Creating it:
        ($ok) = $cce->create('Network', {
            "device" => $device,
            "bootproto" => "none",
            "ipaddr" => $ipaddr,
            "netmask" => $netmask,
            "enabled" => "1",
            "real" => "1"
        });
    }
    else {
        # Object in CCE. Updating it:
        ($ok) = $cce->set($oids[0], '',{
            "device" => $device,
            "bootproto" => "none",
            "ipaddr" => $ipaddr,
            "netmask" => $netmask,
            "enabled" => "1",
            "real" => "1"
        });
    }
}

$cce->bye('SUCCESS');
exit(0);

# 
# Copyright (c) 2014 Michael Stauber, SOLARSPEED.NET
# Copyright (c) 2014 Team BlueOnyx, BLUEONYX.IT
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