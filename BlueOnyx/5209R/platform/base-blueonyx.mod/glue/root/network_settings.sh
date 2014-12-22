#!/bin/bash

: ${DIALOG=dialog}

CDTITLE="Team BluOnyx Presents - Network Reconfigure"
TITLE="Network Setup Utility"


IPADDRESS=`ifconfig  | grep 'inet '| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $2}'`
NETMASK=`ifconfig | grep $IPADDRESS | awk '{ print $4}'`
DEFAULTGW=`/sbin/ip route | awk '/default/ { print $3 }'`

function GetIP() {
MSG="Please Enter your IP Address\n\n"
exec 3>&1
IPADDRESS="`$DIALOG --nocancel --backtitle "$CDTITLE" --title "$TITLE"  \
  --inputbox "$MSG" 15 70 $IPADDRESS 2>&1 1>&3`"
retval=$?
exec 3>&-
RESET=0
}

function GetNM() {
MSG="Please Enter your Netmask\n\n"
exec 3>&1
NETMASK="`$DIALOG --nocancel --backtitle "$CDTITLE" --title "$TITLE"  \
  --inputbox "$MSG" 15 70 $NETMASK 2>&1 1>&3`"
retval=$?
exec 3>&-
RESET=0
}

function GetGW() {
MSG="Please Enter your Default Gateway\n\n"
exec 3>&1
DEFAULTGW="`$DIALOG --nocancel --backtitle "$CDTITLE" --title "$TITLE"  \
  --inputbox "$MSG" 15 70 $DEFAULTGW 2>&1 1>&3`"
retval=$?
exec 3>&-
RESET=0
}

function Confirm() {
MSG="
Please Confirm your Network Settings\n\n
IP Address : $IPADDRESS\n
Netmask    : $NETMASK\n
Gateway    : $DEFAULTGW\n
\n\n
Accept?"
$DIALOG --nocancel --backtitle "$CDTITLE" --title "$TITLE" \
  --yesno "$MSG" 0 0
NO=$?
}

NO=1

GetIP
GetNM
GetGW
Confirm
if [ "$IPADDRESS" == "" ]; then NO=1; fi
if [ "$NETMASK" == "" ]; then NO=1; fi
if [ "$DEFAULTGW" == "" ]; then NO=1; fi

if [ "$NO" == "0" ]; then

  # Change the default gateway
  /usr/bin/perl -pi -e "s#GATEWAY=.*#GATEWAY=$DEFAULTGW#" /etc/sysconfig/network

  # Find the Network ID & Broadcast ID
  NETWORKID=`/usr/sausalito/sbin/minicalc.pl id $IPADDRESS $NETMASK`
  BROADCAST=`/usr/sausalito/sbin/minicalc.pl bid $IPADDRESS $NETMASK`

  # Create/Update /etc/udev/rules.d/70-persistent-net.rules:
  if [ ! -f /etc/udev/rules.d/70-persistent-net.rules ]; then
    /usr/sausalito/sbin/write_udev.pl > /etc/udev/rules.d/70-persistent-net.rules
  fi

  # Configure up the init scripts for eth0 properly.
  /bin/echo "DEVICE=eth0" > /etc/sysconfig/network-scripts/ifcfg-eth0
  /bin/echo "BOOTPROTO=none" >> /etc/sysconfig/network-scripts/ifcfg-eth0
  /bin/echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-eth0
  /bin/echo "BROADCAST=$BROADCAST" >> /etc/sysconfig/network-scripts/ifcfg-eth0
  /bin/echo "NETWORK=$NETWORKID" >> /etc/sysconfig/network-scripts/ifcfg-eth0
  /bin/echo "NETMASK=$NETMASK" >> /etc/sysconfig/network-scripts/ifcfg-eth0
  /bin/echo "IPADDR=$IPADDRESS" >> /etc/sysconfig/network-scripts/ifcfg-eth0
  /bin/echo "USERCTL=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0

  # Convince Sausalito that we are using eth0 & have proper IP info already
  /usr/sausalito/sbin/set_eth.pl configure eth0 $IPADDRESS $NETMASK
  /usr/sausalito/sbin/set_gw.pl configure $DEFAULTGW

  # restart daemons
  echo "Restarting Daemons ... "
  services="network cced.init httpd admserv xinetd sendmail"
  for service in $services; do
    /sbin/chkconfig $service on > /dev/null 2>&1
    /sbin/service $service restart > /dev/null 2>&1
  done

fi

# 
# Copyright (c) 2014 Michael Stauber, SOLARSPEED.NET
# Copyright (c) 2014 Team BlueOnyx, BLUEONYX.IT
# All Rights Reserved.
# 
# 1. Redistributions of source code must retain the above copyright 
#   notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright 
#   notice, this list of conditions and the following disclaimer in 
#   the documentation and/or other materials provided with the 
#   distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its 
#   contributors may be used to endorse or promote products derived 
#   from this software without specific prior written permission.
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