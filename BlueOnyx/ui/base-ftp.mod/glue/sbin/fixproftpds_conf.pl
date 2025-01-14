#!/usr/bin/perl -I/usr/sausalito/perl -I/usr/sausalito/handlers/base/vsite
# $Id: fixproftpds_conf.pl Sat 25 Jan 2014 15:40:02 PM COT mstauber $
#
# This script prints out the VirtualHost containers that are supposed to 
# be present in your /etc/proftpds.conf - based on the IPs your sites are
# using.

use CCE;
my $cce = new CCE;
$cce->connectuds();

# Root check:
my $id = `id -u`;
chomp($id);
if ($id ne "0") {
    print "$0 must be run by user 'root'!\n";

    $cce->bye('FAIL');
    exit(1);
}

# Find all Vsites:
my @vhosts = ();
my (@vhosts) = $cce->findx('Vsite');

# Walk through Vsites:
for my $vsite (@vhosts) {
    ($ok, my $my_vsite) = $cce->get($vsite);

	# Build an array containing all IPs of all Vsites:
	push(@ips, $my_vsite->{ipaddr});

	# Remove IP's that are listed more than once:
	@unique_ips=&del_double(@ips);
}

foreach $ip (@unique_ips) {
	if (($ip) && ($ip ne "127.0.0.1")) {
	    print "<VirtualHost $ip>\n";
	    print "		DefaultRoot     / wheel\n";
	    print "		DefaultRoot             / admin-users\n";
	    print "		DefaultRoot             ~/../../.. site-adm\n";
	    print "		DefaultRoot             ~ !site-adm\n";
	    print "		AllowOverwrite  on\n";
	    print "		DefaultChdir            /web\n";
	    print "		DisplayLogin    .ftphelp\n";
	    print "		TLSEngine on\n";
	    print "		TLSLog /var/log/proftpd/tls.log\n";
	    print "		TLSRequired off\n";
	    print "		TLSRSACertificateFile /etc/pki/dovecot/certs/dovecot.pem\n";
	    print "		TLSRSACertificateKeyFile /etc/pki/dovecot/private/dovecot.pem\n";
	    print "		TLSVerifyClient off\n";
	    print "		TLSOptions NoCertRequest NoSessionReuseRequired UseImplicitSSL\n";
	    print "		TLSRenegotiate required off\n";
	    print "</VirtualHost>\n";
	    print "\n"
	};
}

# Function to remove dublettes from an array:
sub del_double {
	my %all;
	$all{$_}=0 for @_;
	return (keys %all);
} 

$cce->bye('SUCCESS');
exit(0);

