#!/usr/bin/perl -w -I/usr/sausalito/perl -I/usr/sausalito/handlers/base/email
# $Id: access.pl

use strict;
use CCE;
use Email;
use Sauce::Util;

my $cce = new CCE( Domain => 'base-email' );

$cce->connectfd();

my $Sendmail_access = $Email::ACCESS;
my $sys_obj;
my $sys_oid;

# could have been triggered by a change in Network so check
if ($cce->event_object()->{CLASS} ne 'System') {
	($sys_oid) = $cce->find("System");
	(my $ok, $sys_obj) = $cce->get($sys_oid);

	if (not $ok) {
		$cce->bye('FAIL');
		exit(1);
	}
} else {
	$sys_oid = $cce->event_oid();
	$sys_obj = $cce->event_object();
}

my ($ok, $obj) = $cce->get($sys_oid, "Email");

if (not $ok) {
	$cce->bye('FAIL');
	exit(1);
}

# get network objects so we can allow relaying for the nets our interfaces
# are on
my @net_oids = $cce->find("Network");

my @interfaces = ();

for my $oid (@net_oids) {
	my ($ok, $interface) = $cce->get($oid);

#	if ($ok) {
#		push @interfaces, $interface;
#	}
}

# create the access file
my $access_list = &make_deny($obj, $sys_obj, \@interfaces);
if ( $obj->{relayFor} && $obj->{deniedHosts} ) {
	if (not $access_list) { 
		$cce->warn('duplicateKeys');
		$cce->bye('FAIL');
		exit(1);
	}
}

# add rollback so there is no need to copy access.db for rollback
Sauce::Util::addrollbackcommand("/usr/bin/newaliases >/dev/null 2>&1");

if (!Sauce::Util::replaceblock($Sendmail_access, 
	'# Cobalt Access Section Begin', $access_list, 
	'# Cobalt Access Section End')
   	) {
	$cce->warn('[[base-email.cantEditFile]]', { 'file' => $Email::ACCESS });
	$cce->bye('FAIL');
	exit(1);
}

$cce->bye('SUCCESS');
exit(0);


sub make_deny
{
	my $obj = shift;
	my $sys = shift;
	my $interfaces = shift;
	my $out = "";	
	my %spammers;
	my %relayAllow;

	map { $spammers{$_} = 1; } 
		( $cce->scalar_to_array($obj->{deniedHosts}), 
		$cce->scalar_to_array($obj->{deniedUsers}) );

	map { $relayAllow{$_} = 1; } $cce->scalar_to_array($obj->{relayFor});

	# relay for our domain in case we are the smtp server
	# but not if our domain is explicitly excluded in deniedHosts
#	if(($sys->{domainname} ne '') && !$spammers{$sys->{domainname}}) {
#		$relayAllow{$sys->{domainname}} = 1;
#	}
	
	# relay for any networks we are on
	for my $interface (@{ $interfaces }) {
		next unless( $interface->{enabled} ); 
		
		my $netmask = pack 'C4', (split /\./, $interface->{netmask});
		my $address = pack 'C4', (split /\./, $interface->{ipaddr});

		# now figure out our network
		my $network = join '.', unpack('C4', ($address & $netmask));

		# if network is all zeros, don't even bother to add it
		next if ($network =~ /^0\.0\.0\.0$/);

		# only add these if they aren't already specified in relayAllow
		# or spammers
		if(not ($spammers{$network} || $relayAllow{$network})) {
			$relayAllow{$network} = 1;
		}
	}

	foreach my $spammer ( keys %spammers ) {
		$out .= "$spammer\t550 Mail rejected due to possible SPAM\n";
	}

	foreach my $relay ( keys %relayAllow ) {
		# make sure someone isn't in both relay and spam list
		if ($spammers{$relay}) {
			return "";
		}

		$relay =~ s'(\.0)+$''g; # network support
		$out .= "$relay\tRELAY\n";
	}

	return $out;
}

# 
# Copyright (c) 2014 Michael Stauber, SOLARSPEED.NET
# Copyright (c) 2014 Team BlueOnyx, BLUEONYX.IT
# Copyright (c) 2003 Sun Microsystems, Inc. 
# All Rights Reserved.
# 
# 1. Redistributions of source code must retain the above copyright 
#	 notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright 
#	 notice, this list of conditions and the following disclaimer in 
#	 the documentation and/or other materials provided with the 
#	 distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its 
#	 contributors may be used to endorse or promote products derived 
#	 from this software without specific prior written permission.
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