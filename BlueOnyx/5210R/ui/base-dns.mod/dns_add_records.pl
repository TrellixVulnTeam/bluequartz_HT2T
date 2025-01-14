dns_flush.pl                                                                                        0100755 0000000 0000156 00000000516 07363333662 011227  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   #!/usr/bin/perl -I /usr/sausalito/perl

use CCE;
my $cce = new CCE;
$cce->connectuds();

my @records = $cce->find('DnsRecord');
print "Found $#records DnsRecord class objects\n";

foreach my $oid (@records)
{
	next unless ($oid);
	print "oid: $oid... ";
	my $ret = $cce->destroy($oid);
	print "$ret, ";
}
print ".\n\nFIN\n";

exit 0;
                                                                                                                                                                                  glue/                                                                                               0042755 0000000 0000156 00000000000 07727667110 007643  5                                                                                                    ustar   root                                                                                                                                                                                                                                                   glue/conf/                                                                                          0042755 0000000 0000156 00000000000 07727667110 010570  5                                                                                                    ustar   root                                                                                                                                                                                                                                                   glue/conf/base-dns.conf                                                                             0100644 0000000 0000156 00000006536 07452204350 013124  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   #
# $Id: dns_add_records.pl 259 2004-01-03 06:28:40Z shibuya $
# Copyright 2000-2002 Sun Microsystems, Inc.  All rights reserved.
#
Network.ipaddr			perl:base/dns/dns_restart.pl CLEANUP
Network.netmask			perl:base/dns/dns_restart.pl CLEANUP

System.dns			perl:base/dns/dns_auto_enable.pl CLEANUP

System.hostname			perl:base/dns/dns_generate.pl CONFIGURE
System.domainname		perl:base/dns/dns_generate.pl CONFIGURE
System.DNS.enabled		perl:base/dns/dns_generate.pl CONFIGURE
System.DNS.caching		perl:base/dns/dns_generate.pl CONFIGURE
System.DNS.commit		perl:base/dns/dns_generate.pl CONFIGURE
System.DNS.zone_format		perl:base/dns/dns_generate.pl CONFIGURE
System.DNS.zone_format_24	perl:base/dns/dns_generate.pl CONFIGURE
System.DNS.zone_format_16	perl:base/dns/dns_generate.pl CONFIGURE
System.DNS.zone_format_8	perl:base/dns/dns_generate.pl CONFIGURE
System.DNS.zone_format_0	perl:base/dns/dns_generate.pl CONFIGURE
System.DNS.zone_xfer_ipaddr	perl:base/dns/dns_generate.pl CONFIGURE
System.DNS.forwarders		perl:base/dns/dns_generate.pl CONFIGURE

System.DNS.enabled		perl:base/dns/dns_restart.pl CLEANUP
System.DNS.caching		perl:base/dns/dns_restart.pl CLEANUP
System.DNS.commit		perl:base/dns/dns_restart.pl CLEANUP
System.DNS.zone_format		perl:base/dns/dns_restart.pl CLEANUP
System.DNS.zone_format_24	perl:base/dns/dns_restart.pl CLEANUP
System.DNS.zone_format_16	perl:base/dns/dns_restart.pl CLEANUP
System.DNS.zone_format_8	perl:base/dns/dns_restart.pl CLEANUP
System.DNS.zone_format_0	perl:base/dns/dns_restart.pl CLEANUP
System.DNS.zone_xfer_ipaddr	perl:base/dns/dns_restart.pl CLEANUP
System.DNS.forwarders		perl:base/dns/dns_restart.pl CLEANUP

# need to add timezone data to bind's chroot 
System.Time.timeZone		perl:base/dns/timezone.pl CLEANUP

System.DNS.commit		perl:base/dns/purge_db.pl CLEANUP

DnsRecord._CREATE		perl:base/dns/fixnetwork.pl EXECUTE
DnsRecord.ipaddr		perl:base/dns/fixnetwork.pl EXECUTE
DnsRecord.netmask		perl:base/dns/fixnetwork.pl EXECUTE

DnsRecord._CREATE		perl:base/dns/maintain_soa.pl CONFIGURE
DnsRecord._DESTROY		perl:base/dns/maintain_soa.pl CONFIGURE
DnsRecord.domainname		perl:base/dns/maintain_soa.pl CONFIGURE
DnsRecord.ipaddr		perl:base/dns/maintain_soa.pl CONFIGURE
DnsRecord.netmask		perl:base/dns/maintain_soa.pl CONFIGURE

DnsSOA._CREATE			perl:base/dns/unique_soa.pl VALIDATE
DnsSOA.ipaddr			perl:base/dns/unique_soa.pl VALIDATE
DnsSOA.netmask			perl:base/dns/unique_soa.pl VALIDATE
DnsSOA.domainname		perl:base/dns/unique_soa.pl VALIDATE

# maintain the dirty bit:
DnsSlaveZone.*			perl:base/dns/setdirty.pl EXECUTE
DnsSlaveZone._CREATE		perl:base/dns/setdirty.pl EXECUTE
DnsSlaveZone._DESTROY		perl:base/dns/setdirty.pl EXECUTE
DnsSOA.*			perl:base/dns/setdirty.pl EXECUTE
DnsSOA._CREATE			perl:base/dns/setdirty.pl EXECUTE
DnsSOA._DESTROY			perl:base/dns/setdirty.pl EXECUTE
DnsRecord.*			perl:base/dns/setdirty.pl EXECUTE
DnsRecord._CREATE		perl:base/dns/setdirty.pl EXECUTE
DnsRecord._DESTROY		perl:base/dns/setdirty.pl EXECUTE

ActiveMonitor.DNS.enabled	perl:base/am/am_enabled.pl EXECUTE
ActiveMonitor.DNS.monitor	perl:base/am/am_enabled.pl EXECUTE

System.DNS.enabled		perl:base/dns/enableAM.pl

DnsRecord._CREATE		perl:base/dns/validate_dnsrecords.pl VALIDATE
DnsRecord.*			perl:base/dns/validate_dnsrecords.pl VALIDATE
DnsSlaveZone._CREATE		perl:base/dns/validate_slavezones.pl VALIDATE
DnsSlaveZone.*			perl:base/dns/validate_slavezones.pl VALIDATE

                                                                                                                                                                  glue/Makefile                                                                                       0100644 0000000 0000156 00000001103 07443331353 011261  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   # $Id: dns_add_records.pl 259 2004-01-03 06:28:40Z shibuya $
# Makefile to whip some files into /etc
#

ifdef CCETOPDIR
include $(CCETOPDIR)/devel/defines.mk
else
include /usr/sausalito/devel/defines.mk
endif

SCRIPTS=named_enable.pl

INSTALL = /usr/bin/install -m 0644 -o root
PWD = $(shell pwd)

all:

install:
	mkdir -p $(PREFIX)/etc/
	mkdir -p $(CCESBINDIR)
	$(INSTALL) etc/cobaltdns.DION $(PREFIX)/etc/
	$(INSTALL) etc/cobaltdns.OCN-JT $(PREFIX)/etc/
	$(INSTALL) etc/cobaltdns.RFC2317 $(PREFIX)/etc/
	(cd sbin; $(INSTALL) $(INSTALL_BINFLAGS) $(SCRIPTS) $(CCESBINDIR) )

rpm:

                                                                                                                                                                                                                                                                                                                                                                                                                                                             glue/etc/                                                                                           0042755 0000000 0000156 00000000000 07727667110 010416  5                                                                                                    ustar   root                                                                                                                                                                                                                                                   glue/etc/cobaltdns.DION                                                                             0100644 0000000 0000156 00000001146 07334013417 013024  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   #
# Enter your zone format here
#
# zone-format-8 specify a >= 8-bit network zone format
# zone-format-16 specify a >= 16-bit network zone format
# zone-format-24 specify a >= 24-bit network zone format
#

# RFC 2317 format
# zone-format-8: %2/%n.%1.in-addr.arpa
# zone-format-16: %3/%n.%2.%1.in-addr.arpa
# zone-format-24: %4/%n.%3.%2.%1.in-addr.arpa

# OCN style
# zone-format-8: %2.%1.in-addr.arpa
# zone-format-16: %3.%2.%1.in-addr.arpa
# zone-format-24: %4.%3.%2.%1.in-addr.arpa

# DION style
zone-format-8: %2h.%1.in-addr.arpa
zone-format-16: %3h.%2.%1.in-addr.arpa
zone-format-24: %4h.%3.%2.%1.in-addr.arpa
                                                                                                                                                                                                                                                                                                                                                                                                                          glue/etc/cobaltdns.OCN-JT                                                                           0100644 0000000 0000156 00000001146 07443331353 013230  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   #
# Enter your zone format here
#
# zone-format-8 specify a >= 8-bit network zone format
# zone-format-16 specify a >= 16-bit network zone format
# zone-format-24 specify a >= 24-bit network zone format
#

# RFC 2317 format
# zone-format-8: %2/%n.%1.in-addr.arpa
# zone-format-16: %3/%n.%2.%1.in-addr.arpa
# zone-format-24: %4/%n.%3.%2.%1.in-addr.arpa

# OCN style
zone-format-8: %2.%1.in-addr.arpa
zone-format-16: %3.%2.%1.in-addr.arpa
zone-format-24: %4.%3.%2.%1.in-addr.arpa

# DION style
# zone-format-8: %2h.%1.in-addr.arpa
# zone-format-16: %3h.%2.%1.in-addr.arpa
# zone-format-24: %4h.%3.%2.%1.in-addr.arpa
                                                                                                                                                                                                                                                                                                                                                                                                                          glue/etc/cobaltdns.RFC2317                                                                          0100644 0000000 0000156 00000001146 07334013417 013222  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   #
# Enter your zone format here
#
# zone-format-8 specify a >= 8-bit network zone format
# zone-format-16 specify a >= 16-bit network zone format
# zone-format-24 specify a >= 24-bit network zone format
#

# RFC 2317 format
zone-format-8: %2/%n.%1.in-addr.arpa
zone-format-16: %3/%n.%2.%1.in-addr.arpa
zone-format-24: %4/%n.%3.%2.%1.in-addr.arpa

# OCN style
# zone-format-8: %2.%1.in-addr.arpa
# zone-format-16: %3.%2.%1.in-addr.arpa
# zone-format-24: %4.%3.%2.%1.in-addr.arpa

# DION style
# zone-format-8: %2h.%1.in-addr.arpa
# zone-format-16: %3h.%2.%1.in-addr.arpa
# zone-format-24: %4h.%3.%2.%1.in-addr.arpa
                                                                                                                                                                                                                                                                                                                                                                                                                          glue/handlers/                                                                                      0042755 0000000 0000156 00000000000 07727667110 011443  5                                                                                                    ustar   root                                                                                                                                                                                                                                                   glue/handlers/dns_auto_enable.pl                                                                    0100644 0000000 0000156 00000002400 07373067725 015114  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   #!/usr/bin/perl -w
# $Id: dns_add_records.pl 259 2004-01-03 06:28:40Z shibuya $
# Copyright 2000, 2001 Sun Microsystems, Inc., All rights reserved.
#
# Detects self-reference in DNS servers, enables named accordingly

my $DEBUG = 0;
$DEBUG && open(STDERR, ">>/tmp/dns_auto_enable");
$DEBUG && warn `date` .' '. $0;

use lib qw( /usr/sausalito/perl );
use CCE;
$cce = new CCE;
$cce->connectfd();

my ($sysoid) = $cce->find('System');
my ($ok, $obj) = $cce->get($sysoid, 'DNS');

# Do nothing if bind is already enabled
if($obj->{enabled})
{
	$DEBUG && warn "named already enabled, exiting\n";
	$cce->bye('SUCCESS');
	exit 0;
}

my ($sok, $system) = $cce->get($sysoid, "");
$DEBUG && warn 'system DNS servers: '.$system->{dns}."\n";
my $enable_named = 0;

# This special case is caught by the setup wizard
$enable_named = 1 if ($system->{dns} =~ /&127.0.0.1&/);

my (@netoids) = $cce->find('Network');
foreach my $oid (@netoids)
{
	last if ($enable_named);

	my ($ok, $net) = $cce->get($oid);
	my $search = '&'.$net->{ipaddr}.'&';
	$DEBUG && warn "Per-network match: $search\n";
	if($system->{dns} =~ /$search/)
	{
		$enable_named = 1;
	}
}

if($enable_named)
{
	$DEBUG && warn "Enabling bind...\n";
	$cce->set($sysoid, 'DNS', {'enabled' => 1});
}

$cce->bye('SUCCESS');
exit 0;

                                                                                                                                                                                                                                                                glue/handlers/dns_generate.pl                                                                       0100644 0000000 0000156 00000077755 07620550021 014436  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   #!/usr/bin/perl -w
# $Id: dns_add_records.pl 259 2004-01-03 06:28:40Z shibuya $
# Copyright 2000, 2001 Sun Microsystems, Inc., All rights reserved.
#
# Rewriting the code to generate the DNS db files 
#
# reminder: the Domain class is defined at the end of this file, and
# is not separate.

use strict;

my $TTL = 86400; # default failed lookup, delegation

my $DEBUG = 0;
$DEBUG && warn `date`." $0\n";

# global variables:
use vars qw( $cce $errors %workfiles );
$cce = undef;
$errors = 0;
%workfiles = ();
my $named_dir = '/etc/named';
my $named_conf = '/var/lib/named/etc/named.conf';
my $named_link = '/etc/named.conf';
my $real_dir = '/var/lib/named/etc/named';
my $db_cache = $named_dir.'/root.hint';
my $var_run = '/var/lib/named/var/run';
my $rndc_conf = '/etc/rndc.conf';
my $personal_id = $named_dir.'/pri.0.0.127.in-addr.arpa';

my $named_uid = (getpwnam('named'))[2];
my $named_gid = (getgrnam('named'))[2];

##############################################################################
# main:
##############################################################################

# connect to the configuration engine
use lib qw( /usr/sausalito/perl );
use Sauce::Util;
use CCE;
$cce = new CCE;
$cce->connectfd();

# environment audit & corrections
create_dir() unless (-d $real_dir);
unless(-l $named_dir) {
  # /etc/named is not a symlink
  rename($named_dir, "$named_dir.$$");
  symlink($real_dir, $named_dir);
}
unless(-l '/etc/named.conf') {
  # /etc/named.conf should be a symlink to the chroot'd named.conf
  rename($named_link, "$named_link.$$");
  symlink($named_conf, $named_link);
} 

create_var() unless (-d $var_run);
create_cache() unless (-e $db_cache);
# create_rndc_conf() unless (-e $rndc_conf);
create_selfid() unless (-e $personal_id);
chmod 0775, $named_dir;

# collate list of domains and networks
my $index = collate_domains_and_networks();

# create databases for domains
foreach my $domainname (keys %$index) {
  my $domain = $index->{$domainname};
  $domain->generate_db();
}

# create the master conf file:
generate_named_conf($index);

if (!$errors) {
  # almost done: do the file shuffle
  swap_links_into_place();
}

# finish
if ($errors) {
  $cce->bye("FAIL");
  exit(1);
} else {
  my ($oid) = $cce->find("System");
  $cce->set($oid, "DNS", { "dirty" => "0" });
  $cce->bye("SUCCESS");
  exit(0);
}

##############################################################################
# collate_domains_and_networks
##############################################################################

sub collate_domains_and_networks ()
{
  # my $cce is global
  my $index = {};
  my @oids;

  # look in all the DnsSOA objects: (this must happen first, so that
  # the SOA record is the first object in the object list.)
  @oids = $cce->find("DnsSOA");
  foreach my $oid (@oids) {
    my ($ok, $obj) = $cce->get($oid);
    if (!$ok) { print STDERR "Very Odd: Could not get object $oid\n"; next; }

    if ($obj->{domainname}) { 
      if (defined($index->{$obj->{domainname}})) {
      	print STDERR "Duplicate SOA for domain \"$obj->{domainname}\" in obj $oid\n";
      } else {
      	my $domobj = Domain->new_domain($obj->{domainname});
	$domobj->{soa} = $oid;

      	$index->{$obj->{domainname}} = $domobj;
      }
    }
    
    my $network = pack_network($obj->{ipaddr}, $obj->{netmask});
    if (defined($network)) { 
      if (defined($index->{$network})) {
      	print STDERR "Duplicate SOA for network \"$network\" in obj $oid\n";
      } else {
      	my $domobj = Domain->new_network($obj->{ipaddr}, $obj->{netmask});
	$domobj->{soa} = $oid;
	$index->{$network} = $domobj;
      }
    }
  }

  # look for all DnsSlaveZone objects:  
  @oids = $cce->find("DnsSlaveZone");
  foreach my $oid (@oids) 
  {
    my ($ok, $obj) = $cce->get($oid);
    if (!$ok) { print STDERR "Very Odd: Could not get object $oid\n"; next; }
    
    my @masters = $cce->scalar_to_array($obj->{masters});
    if ($obj->{domain}) { 
      if (defined($index->{$obj->{domain}})) {
      	print STDERR "Duplicate SOA for domain \"$obj->{domain}\" in obj $oid\n";
      } else {
      	my $domobj = Domain->new_domain($obj->{domain},
	  \@masters ); 
	$domobj->{soa} = $oid;
      	$index->{$obj->{domain}} = $domobj;
      }
    }
    
    my $network = pack_network($obj->{ipaddr}, $obj->{netmask});
    if (defined($network)) { 
      if (defined($index->{$network})) {
      	print STDERR "Duplicate SOA for network \"$network\" in obj $oid\n";
      } else {
      	my $domobj = Domain->new_network($obj->{ipaddr}, $obj->{netmask},
	  \@masters );
	$domobj->{soa} = $oid;
	$index->{$network} = $domobj;
      }
    }
  }
  
  # look in all the DnsRecord objects, seive them into the right domains:
  @oids = $cce->find("DnsRecord");
  foreach my $oid (@oids) {
    my ($ok, $obj) = $cce->get($oid);
    if (!$ok) { print STDERR "Very Odd: Could not get object $oid\n"; next; }

    $_ = $obj->{type};
    if (m/^(A)|(CNAME)|(MX)|(NS)|(SN)$/ && $obj->{domainname}) {
      $DEBUG && warn "Found record $oid $_ with domain: $obj->{domainname}\n";

      if (!defined($index->{$obj->{domainname}})) {
      	$index->{$obj->{domainname}} = Domain->new_domain($obj->{domainname});
      }
      $index->{$obj->{domainname}}->add_record($oid);
      next;
    } 
    elsif (m/^(PTR)|(NS)|(SN)$/)
    {
      $DEBUG && warn "Found record $oid $_ with network: $obj->{network}\n";

      my $network = pack_network($obj->{ipaddr}, $obj->{netmask});
      if (!defined($index->{$network})) {
      	$index->{$network} = Domain->new_network($obj->{ipaddr},
	  $obj->{netmask});
      }
      $index->{$network}->add_record($oid);
      next;
    } 
    else
    {
      print STDERR "type $_ not yet implemented, oid=$oid\n";
      next;
    }
  }
  
  return $index;
}

sub pack_network
{
  my ($ip, $nm) = (shift, shift);
  my (@orig) = ($ip, $nm);
  
  if (!$ip || !$nm) { return undef; }
  
  # normalize netmask to a bitcount: (handle bitcount or dotquad)
  if ($nm =~ m/^\s*(\d+)\s*$/) { 
    $nm = $1; 
  }
  elsif ($nm =~ m/^\s*(\d+)\.(\d+)\.(\d+)\.(\d+)\s*$/) { 
    my @bits = split(//,unpack("B32",pack("C4", $1, $2, $3, $4)));
    $nm = 0; while (@bits) { $nm += shift(@bits); };
  } else {
    return undef;
  }

  # normalize ip (mask out unneeded bits):  
  my $tmpstr = '1' x $nm . '0' x (32-$nm);
  my $mask = pack("B32", $tmpstr);
  my $ipbin = pack("C4", split(/\./, $ip));
  $ip = join(".", unpack("C4", $mask & $ipbin));
    
  # create a "n.n.n.n/m" format network string:
  return "$ip/$nm";
}


sub generate_named_conf()
{
  my $index = shift;
  
  my $fname = $named_conf; # use global definition
  my $tmpfname = $fname . '~';

  # get the system object:
  my $obj = undef;
  {
    my $ok;
    my ($oid) = $main::cce->find("System");
    return undef if (!$oid);
  
    ($ok, $obj) = $main::cce->get($oid, "DNS");
    return undef if (!$ok);
  }
  
  # create the new named.conf file:
  my $fh = new FileHandle(">${tmpfname}");
  if (!defined($fh)) {
    print STDERR "Couldn't write ${tmpfname}: $!\n";
    return 0;
  }
  
  # set up vars:
  my $now = scalar(localtime());
  my $forwarders = "// no forwarders defined";
  if ($obj->{forwarders}) {
    $forwarders = "forwarders { "
      . join("; ", $main::cce->scalar_to_array($obj->{forwarders}))
      . "; };";
  }

  # set up zone transfer access
  my $zoneTransferIps = "// zone transfer access denied\n";
  $zoneTransferIps .= "  allow-transfer { none; };";
  if ($obj->{zone_xfer_ipaddr}) {
    $zoneTransferIps = "allow-transfer { "
      . join("; ", $main::cce->scalar_to_array($obj->{zone_xfer_ipaddr}))
      . "; };";
  }
  
  # set up caching
  my $cache = '// recursion allowed';
  my $cache_hint =<<EOF;
zone "." {
  type hint;
  file "root.hint";
};
EOF

  if (!$obj->{caching}) {
    $cache = 'recursion no;';
    $cache_hint = '';
  }

  print $fh <<EOT;
// BIND9 configuration file
// automatically generated $now
//
// Do not edit this file by hand.  Your changes will be lost the
// next time this file is automatically re-generated.

options {
  directory "/etc/named";
  // spoof version for a little more security via obscurity
  version "100.100.100";
  $forwarders
  $zoneTransferIps
  $cache
};

// key rndc_key {
//   algorithm "hmac-md5";
//   secret "sample";
// };
//
// controls {
//   inet 127.0.0.1 allow { localhost; } keys { rndc_key; };
//   inet 127.0.0.1 allow { localhost; } keys { };
// };

$cache_hint

zone "0.0.127.in-addr.arpa" { 
  type master; 
  file "pri.0.0.127.in-addr.arpa";
  notify no; 
};

EOT

  # create zone entry for each domain
  foreach my $domkey (keys %$index) {
    my $domain = $index->{$domkey};
    print $fh $domain->generate_zone_conf();
  }
  
  print $fh "// end of file.\n\n";
  $fh->close();
  
  $main::workfiles{$tmpfname} = $fname;
    
  chown(0, $named_gid, $fname);
  chmod(0644, $fname);
  
  return 1;
}

#############################################################################
# swap_links_into_place
#
# swaps real files with temporary files in as close to an atomic
# operation as I can get.  Uses the %workfiles hash to determine
# which files to swap with what.  
#   key -- the file that was just generated
#   value -- the file that we should swap places with
#############################################################################
sub swap_links_into_place()
{
  foreach my $key (keys %workfiles) {
    if (!-e $key) {
      print STDERR "Missing file: $key\n";
      next;
    }
    if (Sauce::Util::switch_files($key, $workfiles{$key}) < 0) {
      print STDERR "Couldn't swap: $key $workfiles{$key}\n";
    }
  }
}

sub create_dir
{
      
    system("/bin/mkdir -p $real_dir > /dev/null 2>&1");
    chmod 0775, $real_dir;
    chown 0, $named_gid, $real_dir;
    
    return 1;
}

sub create_var
{
    my $dir;
    foreach $dir ('/var/lib/named/var', '/var/lib/named/var/run') {
      mkdir($dir, 0775);
      chmod(0775, $dir);
      chown(0, $named_gid, $dir);
    }
    return 1;
}

sub create_selfid
{
    open(LCL, "> $personal_id") || return 0;
    print LCL <<EOF;
\$TTL $TTL
0.0.127.in-addr.arpa. IN SOA localhost. admin.localhost. (
        2000081417
        10800
        3600
        604800
        $TTL
        )
0.0.127.in-addr.arpa.   IN      NS      localhost.
; End SOA Header
;
; Do Not edit BIND db files directly.
; Use the administrative web user interface /admin/ -> Control Panel -> DNS Parameters
; Custom additions may be made by creating a file of the same name as this but with a
; .include suffix.  Click Save Changes in the DNS web interface and the inclusion will be made.
; 
1       in      ptr     localhost.
EOF
    close(LCL);
    chmod(0644, $personal_id);
    chown(0, $named_gid, $personal_id);
}

sub create_cache
{
    open(DBC, "> $db_cache") || return 0;
    print DBC <<EOF;
; <<>> DiG 8.2 <<>> \@f.root-servers.net . ns 
; (1 server found)
;; res options: init recurs defnam dnsrch
;; got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 10
;; flags: qr aa rd; QUERY: 1, ANSWER: 13, AUTHORITY: 0, ADDITIONAL: 13
;; QUERY SECTION:
;;	., type = NS, class = IN

;; ANSWER SECTION:
.			6D IN NS	G.ROOT-SERVERS.NET.
.			6D IN NS	J.ROOT-SERVERS.NET.
.			6D IN NS	K.ROOT-SERVERS.NET.
.			6D IN NS	L.ROOT-SERVERS.NET.
.			6D IN NS	M.ROOT-SERVERS.NET.
.			6D IN NS	A.ROOT-SERVERS.NET.
.			6D IN NS	H.ROOT-SERVERS.NET.
.			6D IN NS	B.ROOT-SERVERS.NET.
.			6D IN NS	C.ROOT-SERVERS.NET.
.			6D IN NS	D.ROOT-SERVERS.NET.
.			6D IN NS	E.ROOT-SERVERS.NET.
.			6D IN NS	I.ROOT-SERVERS.NET.
.			6D IN NS	F.ROOT-SERVERS.NET.

;; ADDITIONAL SECTION:
G.ROOT-SERVERS.NET.	5w6d16h IN A	192.112.36.4
J.ROOT-SERVERS.NET.	5w6d16h IN A	192.58.128.30
K.ROOT-SERVERS.NET.	5w6d16h IN A	193.0.14.129
L.ROOT-SERVERS.NET.	5w6d16h IN A	198.32.64.12
M.ROOT-SERVERS.NET.	5w6d16h IN A	202.12.27.33
A.ROOT-SERVERS.NET.	5w6d16h IN A	198.41.0.4
H.ROOT-SERVERS.NET.	5w6d16h IN A	128.63.2.53
B.ROOT-SERVERS.NET.	5w6d16h IN A	128.9.0.107
C.ROOT-SERVERS.NET.	5w6d16h IN A	192.33.4.12
D.ROOT-SERVERS.NET.	5w6d16h IN A	128.8.10.90
E.ROOT-SERVERS.NET.	5w6d16h IN A	192.203.230.10
I.ROOT-SERVERS.NET.	5w6d16h IN A	192.36.148.17
F.ROOT-SERVERS.NET.	5w6d16h IN A	192.5.5.241

;; Total query time: 10 msec
;; FROM: power.rc.vix.com to SERVER: f.root-servers.net  192.5.5.241
;; WHEN: Thu Jun  3 14:55:57 1999
;; MSG SIZE  sent: 17  rcvd: 436

EOF
    close(DBC);

    chmod 0644, $db_cache;
    chown 0, $named_gid, $db_cache;

    return 1;
}

sub create_rndc_conf
{
    open(DBC, "> $rndc_conf") || return 0;
    print DBC <<EOF;
key rndc_key {
          algorithm "hmac-md5";
          secret "sample";
};
     options {
          default-server localhost;
          default-key    rndc_key;
};
EOF
    close(DBC);

    return 1;
}


############################################################################
############################################################################
############################################################################
############################################################################
############################################################################
############################################################################
# Domain
############################################################################

package Domain;

use vars qw( $DBDIR $SYSOBJ $HOSTNAME $DOMAINNAME );

BEGIN {
  $DBDIR = $named_dir;
  $SYSOBJ = undef;
  $HOSTNAME = undef;
  $DOMAINNAME = undef;
};

########################################
# new_domain
########################################
sub new_domain
{
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $self = {};
  bless($self, $class);
  return $self->init(@_);
}

########################################
# new_network
########################################
sub new_network
{
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $self = {};
  bless($self, $class);
  
  my ($ip, $nm) = (shift, shift);
  my $name = $self->network_to_zone($ip,$nm);
  
  return $self->init($name, @_);
}

sub network_to_zone
{
  my $self = shift;
  my $ip = shift;
  my $nmask = shift;
  my $nbits = netmask_to_netbits($nmask);
  my @ip = split(/\./, $ip);

  # add stuff of 0padded ips
  my @fip;
  for(my $i=0; $i<4; $i++){
    $fip[$i] = sprintf("%03d", $ip[$i]);
  }

  my %zone_formats;
  # define default zone format here (should match /etc/cobaltdns.RFC2317 !!!!)
  %zone_formats = (
    'zone-format-24' =>  "%4/%n.%3.%2.%1.in-addr.arpa",    # 24
    'zone-format-16' =>  "%3/%n.%2.%1.in-addr.arpa",       # 16
    'zone-format-8'  =>  "%2/%n.%1.in-addr.arpa",          # 8
    'zone-format-0'  =>  "%1/%n.in-addr.arpa",             # 0
  );
 
  # what zone format should we use?
  my $zone_format = 'RFC2317';          # nice happy default
  my ($lookfor,$returnpat,
         $zone_format_0,$zone_format_8,$zone_format_16,$zone_format_24,
  );
  if ($main::cce) {
    my $sysobj          = $self->load_system_object();
    $zone_format        = $sysobj->{zone_format};
    $zone_format_0      = $sysobj->{zone_format_0};
    $zone_format_8      = $sysobj->{zone_format_8};
    $zone_format_16     = $sysobj->{zone_format_16};
    $zone_format_24     = $sysobj->{zone_format_24};
  }

  #
  # Either the user has defined their own format (USER), or they are using
  # one of the standard ones RFC2317|DION|OCN-JT  (/etc/cobaltdns.*)
  #
  if ($zone_format eq 'USER') {         # are we using a user defined format?
    $zone_formats{'zone-format-8'}  = $zone_format_8;
    $zone_formats{'zone-format-16'} = $zone_format_16;
    $zone_formats{'zone-format-24'} = $zone_format_24;
    $zone_formats{'zone-format-0'}  = $zone_format_0;
  } elsif (open (CDC, "/etc/cobaltdns.$zone_format")) {
    while ($_ = <CDC> ) {
      chomp;
      ($lookfor, $returnpat) = split(/:\s+/);
      if ($lookfor !~ /^#/) {
        $zone_formats{$lookfor} = $returnpat;
      }
    }
  }
 
  my $domain = ip_to_domain($ip, $nmask);
  if ($zone_formats{$domain}){
    $returnpat = $zone_formats{$domain};
  } else {
    if ($nbits > 24) {
      $returnpat = $zone_formats{"zone-format-24"};
    } elsif ($nbits > 16) {
      $returnpat = $zone_formats{"zone-format-16"};
    } elsif ($nbits > 8) {
      $returnpat = $zone_formats{"zone-format-8"};
    } else {
      $returnpat = $zone_formats{"zone-format-0"};
    }
    $returnpat =~ s/%1/$ip[0]/;
    $returnpat =~ s/%2/$ip[1]/;
    $returnpat =~ s/%3/$ip[2]/;
    $returnpat =~ s/%4/$ip[3]/;
    $returnpat =~ s/%n/$nbits/;
    $returnpat =~ s/%01/$fip[0]/;
    $returnpat =~ s/%02/$fip[1]/;
    $returnpat =~ s/%03/$fip[2]/;
    $returnpat =~ s/%04/$fip[3]/;
    $returnpat =~ s/h// if ($nbits =~ /^(8|16|24)$/);
  }
  return $returnpat;
}

########################################
# init
########################################
sub init
{
  my $self = shift;
  my $name = shift;
  $name =~ s#^(\d+)/(24|16|8)\.#$1\.#g;
  $self->{name} = $name;
  $self->{soa} = undef;
  $self->{records} = [];
  $self->{masters} = shift; # defined if is a slave
  return $self;
}

########################################
# add_record
########################################
sub add_record
{
  my ($self, $oid) = @_;
  push (@{$self->{records}}, $oid);
}

########################################
# get_records
########################################
sub get_records
{
  my $self = shift;
  return @{$self->{records}};
}

########################################
# db_file_name
########################################
sub db_file_name
{
  my $self = shift;
  my $dom = $self->{name};
  $dom =~ tr/\//-/;
  return "db.${dom}"; 
}

########################################
# generate_db
########################################
sub generate_db
{
  my $self = shift;
  my ${DBDIR} = $named_dir;
 
  my $fname = $self->db_file_name();
  my $workfilename = $fname . '~';

  if (defined($self->{masters})) {
    # no need to do anything.
    return 1;
  }

  # verify that the include file exists:
  if (!-e "${DBDIR}/${fname}.include") {
    my $fh = new FileHandle(">${DBDIR}/${fname}.include");
    if ($fh) {
      print $fh "; ${DBDIR}/${fname}.include\n";
      print $fh "; user customizations can be added here.\n\n";
      $fh->close();
    }
    chmod 0644, "${DBDIR}/${fname}.include";
    chown 0, $named_gid, "${DBDIR}/${fname}.include";
  }
  
  # generate the db content:
  my $new_data = <<EOT ;
; ${fname}
;
; This file was automatically generated by dns_generate.pl.  Do not
; edit this file directly.  If you need to make additions to this
; file that CCE does not support, add your extra records to the
; ${fname}.include file.

EOT
  
  $new_data .= $self->generate_soa_record();
  
  foreach my $oid (@{$self->{records}}) {
    $new_data .= $self->generate_dns_record($oid);
  }
  
  $new_data .= <<EOT ;

; User customizations go in this include file:
\$INCLUDE ${fname}.include

EOT

  # open filehandle for new work file:
  my $fh = new FileHandle(">${DBDIR}/${workfilename}");
  if (!defined($fh)) {
    print STDERR "Could not write to ${DBDIR}/${workfilename}: $!\n";
    return 0;
  } else {
    # print STDERR "Writing to ${DBDIR}/${workfilename}\n";
  }
  print $fh $new_data;
  $fh->close();

  chmod 0644, "${DBDIR}/${workfilename}";
  chown 0, $named_gid, "${DBDIR}/${workfilename}";
  
  # store this for later:
  $main::workfiles{"${DBDIR}/${workfilename}"} = "${DBDIR}/${fname}";
  
  return 1;
}

########################################
# load_system_object
########################################
sub load_system_object
{
  my $self = shift;
  return $SYSOBJ if (defined($SYSOBJ));
  
  my ($oid) = $main::cce->find("System");
  return undef if (!$oid);
  
  my ($ok, $obj) = $main::cce->get($oid, "");
  return undef if (!$ok);
  $HOSTNAME = $obj->{hostname};
  $DOMAINNAME = $obj->{domainname};
  
  ($ok, $obj) = $main::cce->get($oid, "DNS");
  return undef if (!$ok);
  
  $SYSOBJ = $obj;
  return $SYSOBJ;
}

########################################
# generate_soa_record
########################################
sub generate_soa_record
{
  my $self = shift;

  chomp(my $serial_number = time());

  # load System objects for defaults:
  my $sys_obj = $self->load_system_object();

  my $oid = $self->{soa};
  my ($ok, $soa_obj) = $main::cce->get($oid, ""); # || {};

  # find values
  my $local_domain = $self->{name};
  my $ns1 = $soa_obj->{primary_dns} || "${HOSTNAME}.${DOMAINNAME}";
  my $email = $soa_obj->{domain_admin} || "admin\@${ns1}";
  $email =~ s/\@/\./; # BIND8 treats first . as the @ in the rp record
  my $refresh = $soa_obj->{refresh} || $sys_obj->{default_refresh};
  my $retry = $soa_obj->{retry} || $sys_obj->{default_retry};
  my $expire = $soa_obj->{expire} || $sys_obj->{default_expire};
  my $ttl = $soa_obj->{ttl} || $sys_obj->{default_ttl};

  # generate record:
  my( %duplicate_ns ); # ..causes named warnings
  $duplicate_ns{$ns1} = 1;
  my( $soa_record ) = <<EOF;
\$TTL $ttl
$local_domain. IN SOA $ns1. $email. (
	$serial_number ; serial number
        $refresh ; refresh
        $retry ; retry
        $expire ; expire
	$ttl ; ttl
        )
EOF
  # It would be nice to auto-gen glue records here, but we need IP addrs for the NSs
  $soa_record .= "$local_domain.	IN	NS	$ns1.\n";
  my @sec_ns = $main::cce->scalar_to_array($soa_obj->{secondary_dns});

  foreach my $ns2 (@sec_ns) {
    next if ($duplicate_ns{$ns2});
    $soa_record .= "$local_domain.	IN	NS	$ns2.\n";
    $duplicate_ns{$ns2} = 1;
  }
  $soa_record .= "\n";

  return $soa_record;
}

########################################
# generate_dns_record
########################################
sub generate_dns_record
{
  my $self = shift;
  my $oid = shift;

  my ($ok, $obj) = $main::cce->get($oid);
  return "; record skipped: could not read object $oid\n" if (!$ok || !$obj);
  
  if ($obj->{type} eq 'A') { return $self->generate_record_A($obj); }
  if ($obj->{type} eq 'PTR') { return $self->generate_record_PTR($obj); }
  if ($obj->{type} eq 'SN') { return $self->generate_record_SN($obj); }
  if ($obj->{type} eq 'CNAME') { return $self->generate_record_CNAME($obj); }
  if ($obj->{type} eq 'MX') { return $self->generate_record_MX($obj); }

  if ($obj->{type} eq 'NS') { 
    if ($self->{name} =~ m/in-addr.arpa$/) {
      return $self->generate_record_NS_network($obj); 
    } else {
      return $self->generate_record_NS_domain($obj); 
    }
  }
  
  return "; unknown record type \"$obj->{type}\" in object $oid\n";
}

########################################
# generate_record_A
########################################
sub generate_record_A
{
  my $self = shift;
  my $obj = shift;
  
  return formalize_hostname($obj->{hostname}, $obj->{domainname}) .
    "\tin a $obj->{ipaddr}\n";
}

########################################
# Convert IP address and netmask to a domain name
# eg. 192.168.1.70/26 -> 64/26.1.168.192.in-addr.arpa. 
# ..as per RFC2317.  Note we can use arbitrary assignments.
########################################
sub ip_to_domain
{
  my($ip, $nmask) = @_;
  my(@ipa) = split(/\./, $ip);
  my(@maska) = split(/\./, $nmask);
  my($nbits) = netmask_to_netbits($nmask);
  my($res, $i);

  for($i=3; $i>=0; $i--)
  {
    if($maska[$i])
    {
      $res .= '.' if ($res);
      $res .= (($maska[$i]+0) & ($ipa[$i]+0));
      $res .= "/$nbits" if ($maska[$i] != 255);
    }
  }
  return "$res.in-addr.arpa";
}

########################################
# generate_record_SN
########################################
sub generate_record_SN
{
  my $self = shift;
  my $obj = shift;

  my $db_data;
  my @remote_servers = $main::cce->scalar_to_array($obj->{delegate_dns_servers});

  $DEBUG && warn "generate_record_SN invoked, type $obj->{type}, hn $obj->{hostname}, dn $obj->{domainname}, nw $obj->{network}\n";
    
  my ($server, %arpa); 
  foreach $server (@remote_servers)
  {
    # terminate fqdn
    $server .= '.' unless (($server =~ /^[\d\.]+$/) || ($server =~ /\.$/));
      
    if($obj->{domainname}) 
    {
      # subdomain
      $db_data .= "; subdomain delegation for $obj->{hostname} to $server\n";
      $db_data .= formalize_hostname($obj->{hostname}, $obj->{domainname}) .
        "\tin ns $server\n";
    } 
    else 
    {
      # subnet
      $db_data .= "; subnet delegation for $obj->{network_delegate} to $server\n";

      my($net_baseip, $net_slash) = split('/', $obj->{network_delegate});
      my(@ip_frag) = split(/\./, $net_baseip);

      if ($net_slash == 16) # Octet Class B
      {
        $db_data .= "$ip_frag[1]\t$TTL\tIN\tNS\t$server\n";
      }
      elsif ($net_slash == 24) # Octet Class C
      {
        $db_data .= "$ip_frag[2]\t$TTL\tIN\tNS\t$server\n";
      }
      else                     
      {
        # Non-octect bounded
        my $node_base = get_network($net_baseip, $net_slash);
            
	my ($node, $node_low, $diff_mask, $for_node, $for_net);

        if ($net_slash > 23)
        {
          $node_base =~ s/\.\d+$/\.REP/;
          $node_low = (split(/\./,$net_baseip))[3];
          $diff_mask = 32;
        }
        elsif ($net_slash > 15)
        {
          $node_base =~ s/\.\d+\.\d+$/\.REP/;
          $node_low = (split(/\./,$net_baseip))[2];
          $diff_mask = 24;
        }
        elsif ($net_slash > 7)
        {
          $node_base =~ s/^(\d+\.)\d+\..*/$1REP/;
          $node_low = (split(/\./,$net_baseip))[1];
          $diff_mask = 16;
        }
        else
        {
          $node_base = 'REP';
          $node_low = (split(/\./,$net_baseip))[0];
          $diff_mask = 8;
        }

        $for_node = $node_base;
        my $node_hi = $node_low+2**($diff_mask-$net_slash) - 1;
        my $node_range = $node_low.'/'.$net_slash;
        $for_node =~ s/REP/$node_range/;
        $node_range = join('.', reverse( split(/\./, $for_node) ) ).'.in.addr.arpa.';

        $db_data .= "; RFC 2317 Compliant Subnet Delegation  <<$node_low-$node_hi>> /$net_slash\n";
        $db_data .= "$node_low/$net_slash\tIN\tNS\t$server\n";
        for ($node = $node_low + 1;
             $node < $node_low+2**($diff_mask-$net_slash); $node++)
        {
          $for_node = $node_base;
          $for_node =~ s/REP/$node/;
          $for_net = join('.', reverse( split(/\./, $for_node) ) ).'.in.addr.arpa.';
          $db_data .= "$node\tIN\tCNAME\t$node\.$node_range\n" unless 
            ($arpa{"$node\.$node_range"});
          $arpa{"$node\.$node_range"} = 1; # avoid duplicate entries for >1 NS
        }
        $db_data .= ";\n"; # db Readability
      }
    }
  }

  $DEBUG && warn "New data:\n$db_data";
  return $db_data;
}

########################################
# generate_record_PTR
########################################
sub generate_record_PTR
{
  my $self = shift;
  my $obj = shift;

  return ip_to_revname($obj->{ipaddr}, $obj->{netmask})
    . "\tin ptr "
    . formalize_hostname($obj->{hostname}, $obj->{domainname})
    . "\n";
}

########################################
# generate_record_CNAME
########################################
sub generate_record_CNAME
{
  my $self = shift;
  my $obj = shift;
  
  # alias:
  my $from = formalize_hostname($obj->{hostname}, $obj->{domainname});
  my $to = formalize_hostname($obj->{alias_hostname}, $obj->{alias_domainname});
  
  return "$from\tin cname $to\n";
}

########################################
# generate_record_MX
########################################
sub generate_record_MX
{
  my $self = shift;
  my $obj = shift;

  # this really should be more restrictive, but it isn't:  
  my $value = 10;
  if ($obj->{mail_server_priority} =~ m/^\s*(\d+)/) { $value = $1; }
  if ($obj->{mail_server_priority} =~ m/^\s*Very_Low/i) { $value = 50; }
  if ($obj->{mail_server_priority} =~ m/^\s*Low/i) { $value = 40; }
  if ($obj->{mail_server_priority} =~ m/^\s*High/i) { $value = 30; }
  if ($obj->{mail_server_priority} =~ m/^\s*Very_High/i) { $value = 20; }

  return
    formalize_hostname($obj->{hostname}, $obj->{domainname})
    . "\tin mx $value "
    . $obj->{mail_server_name} . '.'
    . "\n";
}  

########################################
# generate_record_NS_network
########################################
sub generate_record_NS_network
{
  my $self = shift;
  my $obj = shift;
  
  my $dom = formalize_hostmane($obj->{hostname}, $obj->{domainname}); 
  my $text = "";
  my @dns = $main::cce->scalar_to_array($obj->{delegate_dns_servers});
  foreach my $dns (@dns) {
    $text .= "$dom\tin ns $dns.\n";
  }
  
  return $text;
}

########################################
# generate_record_NS_domain
########################################
sub generate_record_NS_domain
{
  my $self = shift;
  my $obj = shift;
  
  my $dom = ip_to_revname($obj->{ipaddr}, $obj->{netmask}); 
  my $text = "";
  my @dns = $main::cce->scalar_to_array($obj->{delegate_dns_servers});
  foreach my $dns (@dns) {
    $text .= "$dom\tin ns $dns.\n";
  }
  
  return $text;
}  

sub get_zone_name
{
  my $self = shift;
  my ($zone_name) = $self->{name};
  return $zone_name;
}  

########################################
# generate_zone_conf
########################################
sub generate_zone_conf
{
  my $self = shift;
  
  my $zone = $self->get_zone_name();
  my $fname = $self->db_file_name();

  if (defined($self->{masters})) {
    my $masters = join("; ", @{$self->{masters}}) . ";";
    return <<EOT ;  #"
zone \"$zone\" {
  type slave;
  file \"$fname\";
  masters { $masters };
};

EOT
  #"
  } else {
    return <<EOT ; #"
zone \"$zone\" {
  type master;
  file \"$fname\"; 
};

EOT
  #"
  }
}

########################################
# parse_netmask
########################################
sub parse_netmask
{
  my $nbits = shift;
  if ($nbits =~ m/^\s*\d+\s*$/) {
    return unpack("C4",pack("B32", '1' x $nbits . '0' x (32 - $nbits) ));
  };
  if ($nbits =~ m/^\s*(\d+)\.(\d+)\.(\d+)\.(\d+)\s*$/) {
    return ($1,$2,$3,$4);
  }
  warn ("Invalid netmask: $nbits\n");
  return (255,255,255,255);
}

########################################
# netmask_to_netbits
#
# convert generalized netmask format to just a simple bit-count.
########################################
sub netmask_to_netbits
{
  my $nbits = shift;
  if ($nbits =~ m/^\s*(\d+)\s*$/) {
    return $1;
  };
  if ($nbits =~ m/^\s*(\d+)\.(\d+)\.(\d+)\.(\d+)\s*$/) {
    my @bits = split(//, unpack("B32", pack("C4",$1,$2,$3,$4)));
    $nbits = 0;
    while (@bits) { $nbits += shift(@bits); }
    return $nbits;
  }
  warn ("Invalid netmask: $nbits\n");
  return (32);
}

########################################
# formalize_hostname
########################################
sub formalize_hostname
{
  my ($hn, $dn) = (shift, shift);
  if ($hn eq '-') { $hn = ""; }
  if ($dn eq '-') { $dn = ""; }

  if ($hn && $dn) {
    return "${hn}.${dn}.";
  }
  if ($hn) {
    return "${hn}";
  }
  if ($dn) {
    return "${dn}.";
  }
  return "invalid.hostname.";
}  

#########################################################################
# Convert IP address to form appropriate to put in revhost auth file.	#
# For instance, 1.2.3.4 in an 8 bit network would be converted to 4.3.2	#
#########################################################################
sub ip_to_revname
{
    my( $ip, $nbits ) = @_;
    my( @ipa ) = split( /\./, $ip );
    my( @maska ) = parse_netmask($nbits);
    my( $res ) = "";
    my( $i );
    for( $i=3; $i>=0; $i-- )
	{
	if ($maska[$i] != 255 )
	    {
	    $res .= "." if ($res ne "" );
	    $res .= $ipa[$i];
	    }
	}
    return $res;
}

########################################
# get_network
#
# apply the netmask on the IP address to get the network IP address
# argument 0 is the IP address of the network
# argument 1 is the netmask of the network
# IP addresses not necessary have 4 octets
# netmask must have 4 octets
# return the IP address of the network
########################################
sub get_network
{
    my ($ipAddr, $netmask)=@_;

    my @bits_to_mask =
    (
    "0.0.0.0", "128.0.0.0", "192.0.0.0", "224.0.0.0",
    "240.0.0.0", "248.0.0.0", "252.0.0.0", "254.0.0.0",
    "255.0.0.0", "255.128.0.0", "255.192.0.0", "255.224.0.0",
    "255.240.0.0", "255.248.0.0", "255.252.0.0", "255.254.0.0",
    "255.255.0.0", "255.255.128.0", "255.255.192.0", "255.255.224.0",
    "255.255.240.0", "255.255.248.0", "255.255.252.0", "255.255.254.0",
    "255.255.255.0", "255.255.255.128", "255.255.255.192", "255.255.255.224",
    "255.255.255.240", "255.255.255.248", "255.255.255.252", "255.255.255.254",
    "255.255.255.255"
    );
    $netmask = $bits_to_mask[$netmask];

    my @ipAddrNums=split /\./, $ipAddr;
    my @netMaskNums=split /\./, $netmask;

    my $i;
    for( $i=0; $i<4; $i++ ) {
        # bitwise apply the netmask
        $ipAddrNums[ $i ]=( $ipAddrNums[ $i ]+0 ) & ( $netMaskNums[ $i ]+0 );
    }

    return join '.', @ipAddrNums;
}


                   glue/handlers/dns_restart.pl                                                                        0100644 0000000 0000156 00000005513 07506124176 014322  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   #!/usr/bin/perl -w
# $Id: dns_add_records.pl 259 2004-01-03 06:28:40Z shibuya $
# Copyright 2000, 2001 Sun Microsystems, Inc., All rights reserved.
#
#
# starts, stops, and restarts a service on demand, with some extra
# safety checks.  jm.


# configure here: (mostly)
my $SERVICE = "named";	# name of initd script for this daemon
my $CMDLINE = "named";  # contents of /proc/nnn/cmdline for this daemon
my $RESTART = "reload"; # restart action
my $DEBUG   = 0;

$DEBUG && warn `date` .' '. $0;

use lib qw( /usr/sausalito/perl );
use FileHandle;
use Sauce::Util;
use CCE;
$cce = new CCE;
$cce->connectfd();

my ($sysoid) = $cce->find("System");
my ($ok, $obj) = $cce->get($sysoid, "DNS");

# fix chkconfig information:
if ($obj->{enabled}) {
	Sauce::Service::service_set_init($SERVICE, 'on', '345');
} else {
	Sauce::Service::service_set_init($SERVICE, 'off', '345');
}

# check to see if the service is presently running;
my $running = 0;
{
  my $fh = new FileHandle("</var/lib/named/var/run/named/$SERVICE.pid");
  if ($fh) {
    my $pid = <$fh>; chomp($pid);
    $DEBUG && warn "old $SERVICE pid = $pid\n";
    $fh->close();
    
    $fh = new FileHandle("</proc/$pid/cmdline");
    if ($fh) {
      my $cmdline = <$fh>; chomp($cmdline);
      $DEBUG && warn "old $SERVICE cmdline = $cmdline\n";
      $fh->close();
      
      if ($cmdline =~ m/$CMDLINE/) { $running = 1; }
    }
  }
}

$DEBUG && warn "Running? $running, Enabled in CCE? ".$obj->{enabled};

# do the right thing
if (!$running && $obj->{enabled}) {
  system("/etc/rc.d/init.d/${SERVICE} start >/dev/null 2>&1");
  sleep(1); # wait for named to really start
}
elsif ($running && !$obj->{enabled}) {
  system("/etc/rc.d/init.d/${SERVICE} stop >/dev/null 2>&1");
}
elsif ($running && $obj->{enabled}) {
  system("/etc/rc.d/init.d/${SERVICE} $RESTART >/dev/null 2>&1");
}

# is it running now?
$running = 0;
{
  my $fh = new FileHandle("</var/lib/named/var/run/named/$SERVICE.pid");
  if ($fh) {
    my $pid = <$fh>; chomp($pid);
    $DEBUG && warn "new $SERVICE pid = $pid\n";
    $fh->close();
    
    $fh = new FileHandle("</proc/$pid/cmdline");
    if ($fh) {
      my $cmdline = <$fh>; chomp($cmdline);
      $DEBUG && warn "new $SERVICE name = $cmdline\n";
      $fh->close();
      
      if ($cmdline =~ m/$CMDLINE/) { $running = 1; }
    }
  }
}

$DEBUG && warn "Running? $running, Enabled in CCE? ".$obj->{enabled};

# proc test has delays that incur a race failure unless we wait at the
# direct expense of the UI.  If there is a failure, AM will catch 
# correct or report it accordingly
# 
# report the did-not-start error, if necessary:
# if ($obj->{enabled} && !$running) {
#   $DEBUG && warn "Kissing CCE goodbye, FAILURE";
#   $cce->warn("[[base-dns.${SERVICE}-did-not-start]]");
#   $cce->bye("FAIL");
#   exit 1;
# }

$DEBUG && warn "Kissing CCE goodbye, SUCCESS";
$cce->bye("SUCCESS");
exit 0;


                                                                                                                                                                                     glue/handlers/enableAM.pl                                                                           0100755 0000000 0000156 00000001461 07311722622 013431  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   #!/usr/bin/perl -w -I/usr/sausalito/perl -I.
# $Id: dns_add_records.pl 259 2004-01-03 06:28:40Z shibuya $
# Copyright 2000, 2001 Sun Microsystems, Inc., All rights reserved.
# 
#
use strict;
use CCE;

my $cce = new CCE;
$cce->connectfd();

# retreive object data:
my $oid = $cce->event_oid();
my $ns = $cce->event_namespace();
my $prop = $cce->event_property();
my ($ok, $newobj, $oldobj) = $cce->get($oid, $ns);

if (!$oid || !$ns ||!$prop) {
  $cce->bye('FAIL', 'Bad oid or namespace');
  exit(1);
}

my ($oldval, $newval);
$oldval = $oldobj->{$prop} ? 1 : 0;
$newval = $newobj->{$prop} ? 1 : 0;

# only set on a real change of boolean value, not just string value
if (!($oldval eq $newval)) {
	my @oids = $cce->find("ActiveMonitor");
	$cce->set($oids[0], "DNS", {enabled => $newval});
}

$cce->bye('SUCCESS');
exit(0);
                                                                                                                                                                                                               glue/handlers/fixnetwork.pl                                                                         0100644 0000000 0000156 00000002677 07311722622 014174  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   #!/usr/bin/perl -w
# $Id: dns_add_records.pl 259 2004-01-03 06:28:40Z shibuya $
# Copyright 2000, 2001 Sun Microsystems, Inc., All rights reserved.

use lib qw(/usr/sausalito/perl);
use CCE;
my $cce = new CCE;
$cce->connectfd();

my $oid = $cce->event_oid();
my $obj = $cce->event_object();

if (defined($obj->{ipaddr}) && defined($obj->{netmask})) {
  my $ipbin = pack("C4", split(/\./, $obj->{ipaddr}));
  my $ipnm = pack("C4", parse_netmask($obj->{netmask}));
  my $nbits = netmask_to_netbits($obj->{netmask});
  my $network = join(".",unpack("C4", $ipbin & $ipnm)) . "/" . $nbits;
  $cce->set($oid, "", { "network" => $network } );
}

$cce->bye("SUCCESS");
exit(0);

sub parse_netmask
{
  my $nbits = shift;
  if ($nbits =~ m/^\s*\d+\s*$/) {
    return unpack("C4",pack("B32", '1' x $nbits . '0' x (32 - $nbits) ));
  };
  if ($nbits =~ m/^\s*(\d+)\.(\d+)\.(\d+)\.(\d+)\s*$/) {
    return ($1,$2,$3,$4);
  }
  warn ("Invalid netmask: $nbits\n");
  return (255,255,255,255);
}

# netmask_to_netbits
#
# convert generalized netmask format to just a simple bit-count.
########################################
sub netmask_to_netbits
{
  my $nbits = shift;
  if ($nbits =~ m/^\s*(\d+)\s*$/) {
    return $1;
  };
  if ($nbits =~ m/^\s*(\d+)\.(\d+)\.(\d+)\.(\d+)\s*$/) {
    my @bits = split(//, unpack("B32", pack("C4",$1,$2,$3,$4)));
    $nbits = 0;
    while (@bits) { $nbits += shift(@bits); }
    return $nbits;
  }
  warn ("Invalid netmask: $nbits\n");
  return (32);
}
                                                                 glue/handlers/maintain_soa.pl                                                                       0100644 0000000 0000156 00000012511 07311722622 014422  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   #!/usr/bin/perl -w
# $Id: dns_add_records.pl 259 2004-01-03 06:28:40Z shibuya $
# Copyright 2000, 2001 Sun Microsystems, Inc., All rights reserved.
#
# automatically maintain an soa for every domain and network.  soa's are
# created and destroyed as needed.

use lib qw(/usr/sausalito/perl);
use CCE;
use Data::Dumper;
my $cce = new CCE;
$cce->connectfd();

my $oid = $cce->event_oid();
my $obj = $cce->event_object();
my $old = $cce->event_old();
my $new = $cce->event_new();

my $type = $new->{type} || $old->{type};
my $old_soa = undef;
my $new_soa = undef;

if ($type =~ m/^(A)|(CNAME)|(MX)|(NS)$/) {
  if ($cce->event_is_destroy() || defined($new->{domainname})) {
    $old_soa = $old->{domainname} 
	? { 'domainname' => $old->{domainname} }
	: undef;
  }
  if (defined($new->{domainname})) {
    $new_soa = { 'domainname' => $new->{domainname} };
  }
} 

if ($type =~ m/^(PTR)|(NS)$/) {
  if ($cce->event_is_destroy() 
    || defined($new->{ipaddr}) || defined($new->{netmask})) 
  {
    if (defined($old->{ipaddr}) && defined($old->{netmask})) {
      my ($ip,$nm) = normalize_network($old->{ipaddr}, $old->{netmask});
      $old_soa = { 
        'ipaddr' => $ip,
        'netmask' => $nm, 
      };
    }
  }
  if ( defined($new->{ipaddr}) || defined($new->{netmask}) )
  {
    my ($ip,$nm) = normalize_network(
      $new->{ipaddr} || $old->{ipaddr},
      $new->{netmask} || $old->{netmask} );
    $new_soa = { 
      'ipaddr' => $ip,
      'netmask' => $nm, 
    };
  }
}

if (defined($old_soa)) {
  garbage_collect_soa($old_soa);
}

if (defined($new_soa)) {
  maintain_soa($new_soa);
}

$cce->bye("SUCCESS");
exit(0);

sub garbage_collect_soa
{
  my $old_soa = shift;
  print STDERR "Garbage collecting soas:\n".Dumper($old_soa)."\n";  
  my $other_crit = undef;
  my @rec_oids;
  my @more_rec_oids;
 
  if (defined($old_soa->{netmask})) {

    # PTR records
    $other_crit->{network} = $old_soa->{ipaddr}.'/'.netmask_to_netbits($old_soa->{netmask});
    $other_crit->{type} = 'PTR';
    @rec_oids = $cce->find("DnsRecord", $other_crit);

    # subnet delegation
    $other_crit = undef;
    $other_crit->{ipaddr} = $old_soa->{ipaddr};
    $other_crit->{netmask} = $old_soa->{netmask};
    $other_crit->{type} = 'NS';
    @more_rec_oids = $cce->find("DnsRecord", $other_crit);
    push (@rec_oids, @more_rec_oids);

  } else {

    # A records
    $other_crit = undef;
    $other_crit->{domainname} = $old_soa->{domainname};
    $other_crit->{type}='A';
    @rec_oids = $cce->find("DnsRecord", $other_crit);

    # CNAME records
    $other_crit->{type}='CNAME';
    @more_rec_oids = $cce->find("DnsRecord", $other_crit);
    push (@rec_oids, @more_rec_oids);
  
    # MX records
    $other_crit->{type}='MX';
    @more_rec_oids = $cce->find("DnsRecord", $other_crit);
    push (@rec_oids, @more_rec_oids);

    # subdomain delegations
    $other_crit->{type} = 'NS';
    @more_rec_oids = $cce->find("DnsRecord", $other_crit);
    push (@rec_oids, @more_rec_oids);
  }
  print STDERR "Garbage collecting soas:\n".Dumper($old_soa)."\n";  
  
  my @soa_oids = $cce->find("DnsSOA", $old_soa);
  
  print STDERR "destroy soa record-in-use test found oids: ".join(' ',@soa_oids)."\n";

  # my @rec_oids = $cce->find("DnsRecord", $old_soa);

  # if (defined($other_crit)) {
  #   my @more_rec_oids = $cce->find("DnsRecord", $other_crit);
  #   push (@rec_oids, @more_rec_oids);
  # }

  print STDERR "found $#rec_oids DnsRecord's to match, guess we'll keep it\n";
 
  my $oid; 
  if ($#rec_oids < 0) {
    foreach $oid (@soa_oids) {
      $cce->destroy($oid);
    }
  }
}


sub maintain_soa
{
  my $new_soa = shift;
  my(@soa_oids);
    
  @soa_oids = $cce->find("DnsSOA", $new_soa);

  # load default SOA settings
  my ($dns_globalid) = $cce->find("System");
  my ($ok, $dnsdef) = $cce->get($dns_globalid, "DNS");
  if ($ok) {
    ($new_soa->{domain_admin}, $new_soa->{refresh}, $new_soa->{retry}, 
       $new_soa->{expire}, $new_soa->{ttl}) =
       ($dnsdef->{admin_email}, $dnsdef->{default_refresh}, $dnsdef->{default_retry}, 
       $dnsdef->{default_expire}, $dnsdef->{default_ttl});
  }

  if ($#soa_oids < 0) {
    $cce->create("DnsSOA", $new_soa);
  }
}

########################################
# parse_netmask
########################################
sub parse_netmask
{
  my $nbits = shift;
  if ($nbits =~ m/^\s*\d+\s*$/) {
    return unpack("C4",pack("B32", '1' x $nbits . '0' x (32 - $nbits) ));
  };
  if ($nbits =~ m/^\s*(\d+)\.(\d+)\.(\d+)\.(\d+)\s*$/) {
    return ($1,$2,$3,$4);
  }
  warn ("Invalid netmask: $nbits\n");
  return (255,255,255,255);
}

########################################
# netmask_to_netbits
#
# convert generalized netmask format to just a simple bit-count.
########################################
sub netmask_to_netbits
{
  my $nbits = shift;
  if ($nbits =~ m/^\s*(\d+)\s*$/) {
    return $1;
  };
  if ($nbits =~ m/^\s*(\d+)\.(\d+)\.(\d+)\.(\d+)\s*$/) {
    my @bits = split(//, unpack("B32", pack("C4",$1,$2,$3,$4)));
    $nbits = 0;
    while (@bits) { $nbits += shift(@bits); }
    return $nbits;
  }
  warn ("Invalid netmask: $nbits\n");
  return (32);
}

sub normalize_network
{
  my ($ip, $nm) = (shift, shift);
  
  # normalize netmask to a bitcount: (handle bitcount or dotquad)
  $nm = join(".",parse_netmask($nm));
  my $binmask = pack("C4", split(/\./, $nm));
  my $binip = pack("C4", split(/\./, $ip));
  $ip = join(".", unpack("C4", $binmask & $binip));
  
  return ($ip, $nm);
}


                                                                                                                                                                                       glue/handlers/purge_db.pl                                                                           0100755 0000000 0000156 00000001453 07332045501 013552  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   #!/usr/bin/perl
# $Id: dns_add_records.pl 259 2004-01-03 06:28:40Z shibuya $
# Copyright 2000, 2001 Sun Microsystems, Inc., All rights reserved.

# determine what db files are referenced in /etc/named.conf, 
# delete the unused from /etc/named/.
#
# Will DeHaan for Cobalt Networks, Inc. 2000 

# defs
my $conf = '/etc/named.conf';
my $db_dir = '/etc/named/';

# determine active db files
my %active;
open(CNF, $conf) || exit 0;
while(<CNF>) {
	if (/^\s*file\s*\"([^\"]+)\"/) {
		$active{$1} = 1;
		$active{$1.'.include'} = 1;
		$active{$1.'~'} = 1;
	}
}
close(CNF);

# List and purge existing db files
opendir(DBS, $db_dir) || exit 0;
my $dir;
while($dir = readdir(DBS)) {
	next if ($dir !~ /^db\./);
	Sauce::Util::unlinkfile ($db_dir.$dir) unless ($active{$dir});
}
closedir(DBS);

print "BYE SUCCESS\n";

exit 0;
                                                                                                                                                                                                                     glue/handlers/setdirty.pl                                                                           0100755 0000000 0000156 00000000527 07311722622 013636  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   #!/usr/bin/perl
# $Id: dns_add_records.pl 259 2004-01-03 06:28:40Z shibuya $
# Copyright 2000, 2001 Sun Microsystems, Inc., All rights reserved.

use lib qw( /usr/sausalito/perl );
use CCE;

my $cce = new CCE; $cce->connectfd();

my (@oids) = $cce->find("System");
$cce->set($oids[0], "DNS", { "dirty" => time() });

$cce->bye("SUCCESS");
exit(0);
                                                                                                                                                                         glue/handlers/timezone.pl                                                                           0100644 0000000 0000156 00000001355 07370632341 013621  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   #!/usr/bin/perl -w
# $Id: dns_add_records.pl 259 2004-01-03 06:28:40Z shibuya $
# Copyright 2000, 2001 Sun Microsystems, Inc., All rights reserved.
#
# Detects self-reference in DNS servers, enables named accordingly

my($timezone, $bindzone) = ('/etc/localtime', '/var/lib/named/etc/localtime');

my $DEBUG = 0;
$DEBUG && open(STDERR, ">>/tmp/dns_timezone");
$DEBUG && warn `date` .' '. $0;

use lib qw( /usr/sausalito/perl );
use CCE;
$cce = new CCE;
$cce->connectfd();

use File::Copy;

my @sysoids = $cce->find('System');

unlink($bindzone);
copy($timezone, $bindzone);
chmod(0644, $bindzone);

# hup named to pickup the updated timezone
my $time = time();
my $ok = $cce->set($sysoids[0], 'DNS', {'commit' => $time});

$cce->bye('SUCCESS');
exit 0;

                                                                                                                                                                                                                                                                                   glue/handlers/unique_soa.pl                                                                         0100644 0000000 0000156 00000004537 07311722622 014141  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   #!/usr/bin/perl -w
# $Id: dns_add_records.pl 259 2004-01-03 06:28:40Z shibuya $
# Copyright 2000, 2001 Sun Microsystems, Inc., All rights reserved.
#
# fails if SOA is not unique.

use lib qw(/usr/sausalito/perl);
use CCE;
use Data::Dumper;
my $cce = new CCE;
$cce->connectfd();

my $oid = $cce->event_oid();
my $obj = $cce->event_object();
my $old = $cce->event_old();
my $new = $cce->event_new();

my $type = $new->{type} || $old->{type};
my $old_soa = undef;
my $new_soa = undef;

my $crit = undef;

if (defined($obj->{ipaddr}) && $obj->{ipaddr} 
 && defined($obj->{netmask}) && $obj->{netmask}) {
  my ($ip, $nm) = normalize_network($obj->{ipaddr}, $obj->{netmask});
  $crit = { 'ipaddr' => $ip, 'netmask' => $nm };
} elsif (defined($obj->{domainname}) && $obj->{domainname}) {
  $crit = { 'domainname' => $obj->{domainname} };
}

if (!defined($crit)) {
  $cce->warn('[[base-dns.invalid-authority]]');
  $cce->bye('FAIL');
  exit(1);
}

my @oids = $cce->find('DnsSOA', $crit);
if ($#oids > 0) {
  $cce->warn('[[base-dns.SOA-already-exists-for-zone]]');
  $cce->bye('FAIL');
  exit(1);
}

$cce->bye('SUCCESS');
exit(0);

########################################
# parse_netmask
########################################
sub parse_netmask
{
  my $nbits = shift;
  if ($nbits =~ m/^\s*\d+\s*$/) {
    return unpack("C4",pack("B32", '1' x $nbits . '0' x (32 - $nbits) ));
  };
  if ($nbits =~ m/^\s*(\d+)\.(\d+)\.(\d+)\.(\d+)\s*$/) {
    return ($1,$2,$3,$4);
  }
  warn ("Invalid netmask: $nbits\n");
  return (255,255,255,255);
}

########################################
# netmask_to_netbits
#
# convert generalized netmask format to just a simple bit-count.
########################################
sub netmask_to_netbits
{
  my $nbits = shift;
  if ($nbits =~ m/^\s*(\d+)\s*$/) {
    return $1;
  };
  if ($nbits =~ m/^\s*(\d+)\.(\d+)\.(\d+)\.(\d+)\s*$/) {
    my @bits = split(//, unpack("B32", pack("C4",$1,$2,$3,$4)));
    $nbits = 0;
    while (@bits) { $nbits += shift(@bits); }
    return $nbits;
  }
  warn ("Invalid netmask: $nbits\n");
  return (32);
}

sub normalize_network
{
  my ($ip, $nm) = (shift, shift);
  
  # normalize netmask to a bitcount: (handle bitcount or dotquad)
  $nm = join(".",parse_netmask($nm));
  my $binmask = pack("C4", split(/\./, $nm));
  my $binip = pack("C4", split(/\./, $ip));
  $ip = join(".", unpack("C4", $binmask & $binip));
  
  return ($ip, $nm);
}


                                                                                                                                                                 glue/handlers/validate_dnsrecords.pl                                                                0100644 0000000 0000156 00000003755 07370625155 016021  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   #!/usr/bin/perl -I /usr/sausalito/perl
# $Id: dns_add_records.pl 259 2004-01-03 06:28:40Z shibuya $
# Copyright 2001 Sun Microsystems, Inc., All rights reserved.

use CCE;
use Base::Nettest qw(test_network_in_network);

my $cce = new CCE;
$cce->connectfd();

my $DEBUG = 0;
$DEBUG && open(STDERR, ">>/tmp/validate");
$DEBUG && warn `date`."$0\n";

my $obj = $cce->event_object();
my $new = $cce->event_new();
my $oid = $cce->event_oid();

# global error msgid set
my $error;

if(!$cce->event_is_destroy())
{
	# Duplicate test
	my $criteria = undef;

	foreach my $element ('type', 'ipaddr', 'hostname',
				'domainname', 'mail_server_name',
				'alias_domainname', 'alias_hostname')
	{
		$criteria->{$element} = $obj->{$element} if
			($obj->{$element});
		$criteria->{$element} = $new->{$element} if
			($new->{$element});
		$DEBUG && warn "$element: $new->{$element}, $obj->{element}\n";
	}
	my (@oids) = $cce->find('DnsRecord', $criteria);
	$DEBUG && warn join(', ', @oids)."\n";
	foreach my $oidstance (@oids)
	{
		next if ($oidstance == $oid);
		$error .= '[[base-dns.invalidDuplicate]]';
	}

	### Zone boundary tests

	# Check for existing DnsSlaveZone zones or zone overlap
	if($obj->{type} eq 'PTR') 
	{
		# Fetch all slave network zones, we'll match test each one
		$DEBUG && warn "Comparing slave networks...\n";
		my (@slaves) = $cce->find('DnsSlaveZone', {'domain'=>''});
		foreach my $oidinstance (@slaves) 
		{
			my($ok, $slave) = $cce->get($oidinstance);
			$error .= '[[base-dns.secondaryZoneOverlap]]'
				if( Base::Nettest::test_network_in_network(
					$obj->{ipaddr},
					$obj->{netmask},
					$slave->{ipaddr},
					$slave->{netmask},
				));
			$DEBUG && warn "$obj->{ipaddr}, $obj->{netmask}, $slave->{ipaddr}, $slave->{netmask}\n";
		}
	}
	else
	{
		my (@soa) = $cce->find('DnsSlaveZone', 
			{'domain'=>$obj->{domainname}});
		$error .= '[[base-dns.secondaryZoneDuplicate]]' if
			($#soa >=0);
	}

}

if($error)
{
	$cce->bye('FAIL', $error);
	exit 1;
} 
else
{
	$cce->bye('SUCCESS');
	exit 0;
}


                   glue/handlers/validate_slavezones.pl                                                                0100644 0000000 0000156 00000004215 07370625155 016034  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   #!/usr/bin/perl -I /usr/sausalito/perl
# $Id: dns_add_records.pl 259 2004-01-03 06:28:40Z shibuya $
# Copyright 2001 Sun Microsystems, Inc., All rights reserved.

use CCE;
use Base::Nettest qw(test_network_in_network);

my $cce = new CCE;
$cce->connectfd();

my $DEBUG = 0;
$DEBUG && open(STDERR, ">>/tmp/validate");
$DEBUG && warn `date`."$0\n";

my $obj = $cce->event_object();
my $new = $cce->event_new();
my $oid = $cce->event_oid();

# global error msgid set
my $error;

if(!$cce->event_is_destroy())
{
	### Duplicate test
	my $criteria = undef;

	foreach my $element ('ipaddr', 'domain', 'netmask')
	{
		$criteria->{$element} = $obj->{$element} if
			($obj->{$element});
		$criteria->{$element} = $new->{$element} if
			($new->{$element});
		$DEBUG && warn "$element: $new->{$element}, $obj->{element}\n";
	}
	my (@oids) = $cce->find('DnsSlaveZone', $criteria);
	$DEBUG && warn join(', ', @oids)."\n";
	foreach my $oidstance (@oids)
	{
		next if ($oidstance == $oid);
		$error .= '[[base-dns.invalidDuplicate]]';
	}

	### Zone boundary tests

	# Check for existing DnsSOA zones or zone overlap
	if($obj->{domain}) 
	{
		my (@soa) = $cce->find('DnsSOA', {'domainname'=>$obj->{domain}});
		$error .= '[[base-dns.primaryZoneDuplicate]]' if
			($#soa >=0);
	}
	else
	{
		# Fetch all primary network zones, we'll match test each one
		my (@soa) = $cce->find('DnsSOA', {'domainname'=>''});
		foreach my $oidinstance (@soa) 
		{
			my($ok, $soa) = $cce->get($oidinstance);
			$error .= '[[base-dns.primaryZoneOverlap]]'
				if( Base::Nettest::test_network_in_network(
					$obj->{ipaddr},
					$obj->{netmask},
					$soa->{ipaddr},
					$soa->{netmask},
					));
		}

		# Fetch all slave network zones
		my (@slaves) = $cce->find('DnsSlaveZone', {'domain'=>''});
		foreach my $oidinstance (@slaves) 
		{
			next if ($oidinstance == $oid);

			my($ok, $slave) = $cce->get($oidinstance);
			$error .= '[[base-dns.slaveZoneOverlap]]'
				if( Base::Nettest::test_network_in_network(
					$obj->{ipaddr},
					$obj->{netmask},
					$slave->{ipaddr},
					$slave->{netmask},
					));
		}
	}
}

if($error)
{
	$cce->bye('FAIL', $error);
	exit 1;
} 
else
{
	$cce->bye('SUCCESS');
	exit 0;
}


                                                                                                                                                                                                                                                                                                                                                                                   glue/sbin/                                                                                          0042755 0000000 0000156 00000000000 07727667110 010576  5                                                                                                    ustar   root                                                                                                                                                                                                                                                   glue/sbin/named_enable.pl                                                                           0100755 0000000 0000156 00000001121 07345216665 013517  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   #!/usr/bin/perl -I /usr/sausalito/perl
# $Id: dns_add_records.pl 259 2004-01-03 06:28:40Z shibuya $
# Copyright 2001 Sun Microsystems, Inc., All rights reserved.
# 
# Enables named using Sausalito/CCE from named init script

use CCE;
my $cce = new CCE;
$cce->connectuds();

my @sysoids = $cce->find('System');
die "Could not find System object in CCE, named initialization failed.\n"
	unless ($sysoids[0] =~ /^\d+$/);

my($ok) = $cce->set($sysoids[0], 'DNS', { 'enabled' => 1 });

die "Could not enable DNS service from CCE, named initialization failed.\n"
	unless ($sysoids[0] =~ /^\d+$/);



                                                                                                                                                                                                                                                                                                                                                                                                                                               glue/schemas/                                                                                       0042755 0000000 0000156 00000000000 07727667110 011266  5                                                                                                    ustar   root                                                                                                                                                                                                                                                   glue/schemas/dns-am.schema                                                                          0100644 0000000 0000156 00000002406 07345324365 013622  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   <!-- This is the AM Namespace for monitoring DNS -->
<class name="ActiveMonitor" namespace="DNS" version="1.1">
    <property name="enabled"    	type="boolean" 	default="0"/>
    <property name="monitor"	writeACL="ruleCapable(systemMonitor)"
	type="boolean" 	default="1"/>
    <property name="type"		type="scalar"	default="exec"/>
    <property name="typeData"		type="scalar"	
        default="/usr/sausalito/swatch/bin/am_dns.sh"/>

    <property name="restart"		type="scalar"	
	default="/etc/rc.d/init.d/named restart >/dev/null 2>&amp;1"/>
    <property name="retries"		type="int"	default="2"/>
    <property name="greenMsg"		type="scalar"	
	default="[[base-dns.amStatusOK]]"/>
    <property name="redMsg"		type="scalar"	
	default="[[base-dns.amNotRunning]]"/>

    <property name="currentState" 	type="amstate" 	default="N"/>
    <property name="lastChange"   	type="uint"     default="0"/>
    <property name="lastRun"      	type="uint"     default="0"/>
    <property name="currentMessage" 	type="scalar" 	default=""/>
    <property name="nameTag"      	type="scalar"  	
	default="[[base-dns.amDNSNameTag]]"/>

    <property name="URL"	 	type="scalar" 
 	default="/base/dns/dns_amdetails.php"/>
    <property name="UIGroup"            type="scalar"   default="service"/>
</class>
                                                                                                                                                                                                                                                          glue/schemas/dns.schema                                                                             0100644 0000000 0000156 00000015234 07441336731 013227  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   <!-- $Id: dns_add_records.pl 259 2004-01-03 06:28:40Z shibuya $ -->

<typedef name="dns_record_type" type="re"
  data="^(A|PTR|CNAME|MX|NS|SN)$"/>
<typedef name="dns_email" type="re" data="^[a-zA-Z0-9_-]+\@[a-zA-Z0-9\._-]+$"/>
<typedef name="dns_zone_format" type="re" data="^(RFC2317|DION|OCN-JT|USER)$"/>
<typedef name="mx_priority" type="re" data="^(very_high|high|low|very_low)$"/>

<!-- global DNS settings -->

<class name="System" namespace="DNS" version="1.0"
  createacl="ruleAll" destroyacl="ruleAll">

  <!-- Basic -->
  <property name="enabled" type="boolean" default="0"
    writeacl="ruleCapable(adminUser)"/>
  <property name="caching" type="boolean" default="1"
    writeacl="ruleCapable(adminUser)"/>
  <property name="commit" type="int" default="1974"
    writeacl="ruleCapable(adminUser)"/>
  <property name="auto_config" type="boolean" default="0"
    writeacl="ruleCapable(adminUser)"/>

  <property name="dirty" type="int" default="0"
    writeacl="ruleCapable(adminUser)"/>

  <!-- Advanced -->
  <property name="zone_xfer_ipaddr" type="ipaddr"
    array="yes" optional="true" default=""
    writeacl="ruleCapable(adminUser)"/>
  <property name="forwarders" type="ipaddr" 
    array="yes" optional="true" default=""
    writeacl="ruleCapable(adminUser)"/>

  <!-- Zone Format Tab -->
  <property name="zone_format" type="dns_zone_format"
    default="RFC2317" 
    writeacl="ruleCapable(adminUser)"/>
  <property name="zone_format_24" type="scalar"
    default="%4/%n.%3.%2.%1.in-addr.arpa"
    writeacl="ruleCapable(adminUser)"/>
  <property name="zone_format_16" type="scalar"
    default="%3/%n.%2.%1.in-addr.arpa"
    writeacl="ruleCapable(adminUser)"/>
  <property name="zone_format_8" type="scalar"
    default="%2/%n.%1.in-addr.arpa"
    writeacl="ruleCapable(adminUser)"/>
  <property name="zone_format_0" type="scalar"
    default="%1/%n.in-addr.arpa"
    writeacl="ruleCapable(adminUser)"/>

  <!-- needs default admin@fqdn -->
  <property name="admin_email" type="dns_email" optional="true" default=""
    writeacl="ruleCapable(adminUser)"/>
  <property name="default_refresh" type="int" default="10800"
    writeacl="ruleCapable(adminUser)"/>
  <property name="default_retry" type="int" default="3600"
    writeacl="ruleCapable(adminUser)"/>
  <property name="default_expire" type="int" default="604800"
    writeacl="ruleCapable(adminUser)"/>
  <property name="default_ttl" type="int" default="86400"
    writeacl="ruleCapable(adminUser)"/>
</class>

<class name="DnsSlaveZone" namespace="" version="1.0"
  createacl="ruleCapable(adminUser)" destroyacl="ruleCapable(adminUser)">

  <!-- identify the authority record by domain and/or network: -->
  <property name="domain" type="domainname" optional="true" default=""
    writeacl="ruleCapable(adminUser)"/>
  <property name="ipaddr" type="ipaddr" optional="true" default=""
    writeacl="ruleCapable(adminUser)"/>
  <property name="netmask" type="netmask" optional="true" default=""
    writeacl="ruleCapable(adminUser)"/>
  
  <!-- zone transfer from these servers: -->
  <property 
    name="masters" 
    type="ipaddr" 
    array="yes"
    writeacl="ruleCapable(adminUser)"/>
</class>

<!-- domain-specific DNS settings (ie. SOA stuff) -->

<class name="DnsSOA" namespace="" version="1.0"
  createacl="ruleCapable(adminUser)" destroyacl="ruleCapable(adminUser)">

  <!-- identify the authority record by domain and/or network: -->
  <property name="domainname" type="domainname" optional="true" default=""
    writeacl="ruleCapable(adminUser)"/>
  <property name="ipaddr" type="ipaddr" optional="true" default=""
    writeacl="ruleCapable(adminUser)"/>
  <property name="netmask" type="netmask" optional="true" default=""
    writeacl="ruleCapable(adminUser)"/>
  
  <!-- SOA properties, used to override the defaults -->
  <property name="primary_dns" type="fqdn" 
    optional="true" default=""
    writeacl="ruleCapable(adminUser)"/>
  <property name="secondary_dns" type="fqdn"
    optional="true" default="" array="yes"
    writeacl="ruleCapable(adminUser)"/>
  <property name="domain_admin" type="dns_email" 
    optional="true" default=""
    writeacl="ruleCapable(adminUser)"/>
  <property name="refresh" type="int" default="10800"
    writeacl="ruleCapable(adminUser)"/>
  <property name="retry" type="int" default="3600"
    writeacl="ruleCapable(adminUser)"/>
  <property name="expire" type="int" default="604800"
    writeacl="ruleCapable(adminUser)"/>
  <property name="ttl" type="int" default="86400"
    writeacl="ruleCapable(adminUser)"/>
</class>

<!-- specific DNS records -->
<!--
How the fields of DnsRecord are meant to be used:
 type A: hostname,domainname -> ipaddr
 type PTR: ipaddr,netmask -> hostname,domainname
 type CNAME: alias_hostname, alias_domainname -> hostname, domainname
 type MX: hostname,domainname,and/or ip -> mail_server_name (w/ mail_server_priority)
 type NS: hostname,domainname,and/or ip -> delegate_pri_dns, delegate_sec_dns
-->
<class name="DnsRecord" namespace="" version="1.0"
  createacl="ruleCapable(adminUser)" destroyacl="ruleCapable(adminUser)">
  
  <!-- common for all types of record: -->
  <property name="type" type="dns_record_type" default=""
    writeacl="ruleCapable(adminUser)"/>
  <property name="hostname" type="hostname" default="" optional="true"
    writeacl="ruleCapable(adminUser)"/>
  <property name="domainname" type="domainname" default="" optional="true"
    writeacl="ruleCapable(adminUser)"/>
  <property name="ipaddr" type="ipaddr" default="" optional="true"
    writeacl="ruleCapable(adminUser)"/>
  <property name="netmask" type="netmask" default="" optional="true"
    writeacl="ruleCapable(adminUser)"/>
  
  <!-- for MX record only: -->
  <property name="mail_server_name" type="fqdn" default="" optional="true"
    writeacl="ruleCapable(adminUser)"/>
  <property name="mail_server_priority" type="mx_priority" default="" optional="true"
    writeacl="ruleCapable(adminUser)"/>
  
  <!-- for CNAME record only: -->
  <!-- Note that these are the alias TARGETS, authority is tied to hostname and domainame -->
  <property name="alias_hostname" type="hostname" default="" optional="true"
    writeacl="ruleCapable(adminUser)"/>
  <property name="alias_domainname" type="domainname" default="" optional="true"
    writeacl="ruleCapable(adminUser)"/>

  <!-- for PTR and SUBNET only -->
  <property name="network" type="network" default="" optional="true"
    writeacl="ruleCapable(adminUser)"/>

  <!-- for SUBNET only -->
  <property name="network_delegate" type="network" default="" optional="true"
    writeacl="ruleCapable(adminUser)"/>
   
  <!-- for SUBNET AND SUBDOM records only: -->
  <property 
    name="delegate_dns_servers" 
    type="hostname" 
    default="" 
    array="yes" 
    writeacl="ruleCapable(adminUser)"/>

</class>

                                                                                                                                                                                                                                                                                                                                                                    locale/                                                                                             0042755 0000000 0000156 00000000000 07727667110 010146  5                                                                                                    ustar   root                                                                                                                                                                                                                                                   locale/de/                                                                                          0042755 0000000 0000156 00000000000 07727667110 010536  5                                                                                                    ustar   root                                                                                                                                                                                                                                                   locale/de/dns.po                                                                                    0100644 0000000 0000156 00000077567 07262643644 011703  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   # --- Menu

msgid "dns"
msgstr "DNS"

msgid "modifyDNS"
msgstr "Domain-Namen-System (DNS)-Einstellungen"

msgid "dns_help"	
msgstr "Hier k�nnen Sie [[base-dns.modifyDNS]] �ndern."


# --- Common

msgid "basic"
msgstr "Grundlegend"

msgid "advanced"	
msgstr "Erweitert"

msgid "basic_help"
msgstr "Hier k�nnen Sie grundlegende DNS-Server-Einstellungen konfigurieren."

msgid "advanced_help"
msgstr "Hier k�nnen Sie erweiterte DNS-Server-Einstellungen wie z. B. Datenformate, Sicherheitsbeschr�nkungen und Servervorgaben konfigurieren."


# --- Basic settings

msgid "enabled"
msgstr "Server aktivieren"

msgid "enabled_help"
msgstr "Aktivieren oder deaktivieren Sie die Domain-Namen-System (DNS)-Serverfunktionalit�t. Wenn Sie diese Funktion aktivieren, kann dieser Server f�r sich selbst und seine Clients als lokaler Dom�nennamen-Server fungieren. Ein Dom�nennamen-Server �bersetzt Texthostnamen und -dom�nennamen in numerische IP-Adressen und umgekehrt."


# --- Advanced settings

msgid "soa_defaults"
msgstr "Start of Authority (SOA)-Vorgabewerte"

msgid "soa_defaults_help"
msgstr "Hierbei handelt es sich um die Vorgabewerte, die verwendet werden, wenn neue Dom�nennamen-Datens�tze hinzugef�gt werden."

msgid "admin_email"
msgstr "Standard-E-Mail-Adresse des DNS-Administrators"

msgid "admin_email_rule"
msgstr "Bitte geben Sie eine E-Mail-Adresse im richtigen Format ein. Eine g�ltige Eingabe ist z. B. benutzer@cobalt."

msgid "admin_email_help"
msgstr "Geben Sie den Vorgabewert der E-Mail-Adresse der administrativen Kontaktperson f�r alle neu hinzugef�gten Dom�nen und Netzwerke ein. [[base-dns.admin_email_rule]]"

msgid "admin_email_invalid"
msgstr "[[VAR.invalidValue]] ist leider ein ung�ltiger Wert f�r das Feld [[base-dns.admin_email]]. [[base-dns.admin_email_rule]]"

msgid "default_refresh"
msgstr "Standard-Aktualisierungsintervall (Sekunden)"

msgid "default_refresh_rule"
msgstr "Bitte geben Sie eine Ganzzahl zwischen 1 und 4096000 ein. Der Vorgabewert betr�gt 10800."

msgid "default_refresh_help"	
msgstr "Geben Sie den Vorgabewert des Aktualisierungsintervalls f�r alle neu hinzugef�gten Dom�nen und Netzwerke ein.  Dabei handelt es sich um das Intervall, in dem der sekund�re Dom�nennamen-Server versucht, seine Datens�tze mit dem prim�ren Dom�nennamen-Server zu synchronisieren. [[base-dns.default_refresh_rule]]"

msgid "default_refresh_invalid"
msgstr "[[VAR.invalidValue]] ist leider ein ung�ltiger Wert f�r das Feld [[base-dns.default_refresh]]. [[base-dns.default_refresh_rule]]"

msgid "default_refresh_empty"	
msgstr "Sie haben keinen Wert im Feld [[base-dns.default_refresh]] eingegeben. [[base-dns.default_refresh_rule]]"

msgid "default_retry"	
msgstr "Standard-Wiederholungsintervall (Sekunden)"

msgid "default_retry_rule"
msgstr "Bitte geben Sie eine Ganzzahl zwischen 1 und 4096000 ein. Der Vorgabewert betr�gt 3600."

msgid "default_retry_help"
msgstr "Geben Sie den Vorgabewert des Wiederholungsintervalls f�r alle neu hinzugef�gten Dom�nen und Netzwerke ein. Wenn der sekund�re Dom�nennamen-Server aus irgendeinem Grund keinen Kontakt mit dem prim�ren Dom�nennamen-Server aufnehmen kann, um seine Datens�tze zu synchronisieren, ist dieser Wert das Intervall, in dem der sekund�re Dom�nennamen-Server wiederholt versucht, den prim�ren Dom�nennamen-Server zu kontaktieren. [[base-dns.default_retry_rule]]"

msgid "default_retry_invalid"
msgstr "[[VAR.invalidValue]] ist leider ein ung�ltiger Wert f�r das Feld [[base-dns.default_retry]]. [[base-dns.default_retry_rule]]"

msgid "default_retry_empty"	
msgstr "Sie haben keinen Wert f�r das Feld [[base-dns.default_retry]] eingegeben. [[base-dns.default_retry_rule]]"

msgid "default_expire"	
msgstr "Standard-Verfallsintervall (Sekunden)"

msgid "default_expire_rule"
msgstr "Bitte geben Sie eine Ganzzahl zwischen 1 und 4096000 ein. Der Vorgabewert betr�gt 604800."

msgid "default_expire_help"
msgstr "Geben Sie den Vorgabewert des Verfallsintervalls f�r alle neu hinzugef�gten Dom�nen und Netzwerke ein. Wenn der sekund�re Dom�nennamen-Server aus irgendeinem Grund wiederholt keinen Kontakt mit dem prim�ren Dom�nennamen-Server aufnehmen kann, um seine Datens�tze zu synchronisieren, ist dieser Wert das Intervall, nach dem der sekund�re Dom�nennamen-Server seine Dom�neninformationen nicht mehr als g�ltig betrachtet und so lange mit der �bertragung von Dom�neninformationen aufh�rt, bis der prim�re Dom�nennamen-Server wieder kontaktiert werden kann. [[base-dns.default_expire_rule]]"

msgid "default_expire_invalid"
msgstr "[[VAR.invalidValue]] ist leider ein ung�ltiger Wert f�r das Feld [[base-dns.default_expire]]. [[base-dns.default_expire_rule]]"

msgid "default_expire_empty"
msgstr "Sie haben keinen Wert im Feld [[base-dns.default_expire]] eingegeben. [[base-dns.default_expire_rule]]"

msgid "default_ttl"	
msgstr "Standard-G�ltigkeitsdauerintervall (Sekunden)"

msgid "default_ttl_rule"
msgstr "Bitte geben Sie eine Ganzzahl zwischen 1 und 4096000 ein. Der Vorgabewert betr�gt 86400."

msgid "default_ttl_help"	
msgstr "Geben Sie den Vorgabewert des G�ltigkeitsdauerintervalls f�r alle neu hinzugef�gten Dom�nen und Netzwerke ein. Dieser Wert ist der Zeitraum, f�r den andere Dom�nennamen-Server die von diesem Dom�nennamen-Server abgerufenen Dom�neninformationen im Cache-Speicher zwischenspeichern und annehmen, dass sie g�ltig sind, ohne bei diesem Dom�nennamen-Server noch einmal nachzupr�fen. [[base-dns.default_ttl_rule]]"

msgid "default_ttl_invalid"
msgstr "[[VAR.invalidValue]] ist leider ein ung�ltiger Wert f�r das Feld [[base-dns.default_ttl]]. [[base-dns.default_ttl_rule]]"

msgid "default_ttl_empty"
msgstr "Sie haben keinen Wert im Feld [[base-dns.default_ttl]] eingegeben. [[base-dns.default_ttl_rule]]"

msgid "global_settings"
msgstr "Server-Einstellungen"

msgid "global_settings_help"
msgstr "Hierbei handelt es sich um die Vorgabewerte f�r den Dom�nennamen-Server."

msgid "forwarders"	
msgstr "Weiterleitungs-Server"

msgid "forwarders_help"
msgstr "Geben Sie die IP-Adressen der weiterleitenden Dom�nennamen-Server ein. Weiterleitende Dom�nennamen-Server werden verwendet, wenn aufgrund einer beschr�nkten Internet-Verbindung nicht direkt auf die Root-Dom�nennamen-Server zugegriffen werden kann. [[base-dns.forwarders_rule]]"

msgid "forwarders_rule"
msgstr "Bitte geben Sie eine Reihe von vier Zahlen zwischen 0 und 255 ein, die mit Punkten getrennt werden. Eine g�ltige Eingabe ist z. B. 192.168.1.1."

msgid "forwarders_invalid"
msgstr "[[VAR.invalidValue]] ist leider ein ung�ltiger Wert f�r das Feld [[base-dns.forwarders]]. [[base-dns.forwarders_rule]]"

msgid "zone_xfer_domain"
msgstr "Zonen�bertragungs-Zugriff �ber Dom�ne"

msgid "zone_xfer_domain_help"
msgstr "Geben Sie die Host- oder Dom�nennamen ein, die alle von diesem Dom�nennamen-Server gepflegten Datens�tze mittels Zonen�bertragungen herunterladen k�nnen. Zonen�bertragungen werden von sekund�ren Dom�nennamen-Servern f�r die Synchronisierung ihrer Datens�tze mit prim�ren Dom�nennamen-Servern verwendet. Standardm�ssig wird dieses Feld leer gelassen, um unbeschr�nkte Zonen�bertragungen zu gestatten."

msgid "zone_xfer_domain_invalid"
msgstr "[[VAR.invalidValue]] ist leider ein ung�ltiger Wert f�r das Feld [[base-dns.zone_xfer_domain]]."

msgid "zone_xfer_ipaddr"
msgstr "Zonen�bertragungs-Zugriff"

msgid "zone_xfer_ipaddr_help"
msgstr "Geben Sie die Host- oder Dom�nennamen ein, die alle von diesem Dom�nennamen-Server gepflegten Datens�tze mittels Zonen�bertragungen herunterladen k�nnen. Zonen�bertragungen werden von sekund�ren Dom�nennamen-Servern f�r die Synchronisierung ihrer Datens�tze mit prim�ren Dom�nennamen-Servern verwendet. Standardm�ssig wird dieses Feld leer gelassen, um unbeschr�nkte Zonen�bertragungen zu gestatten."

msgid "zone_xfer_ipaddr_invalid"
msgstr "[[VAR.invalidValue]] ist leider ein ung�ltiger Wert f�r das Feld [[base-dns.zone_xfer_ipaddr]]."

msgid "zone_format"	
msgstr "Zonendateiformat"

msgid "zone_format_help"	
msgstr "W�hlen Sie ein Zonendateiformat f�r die Subvernetzung auf einer Nicht-Oktett-Grenze, die mit Ihrer lokalen umgekehrten Delegierungsmethode kompatibel ist. Das Standardformat ist RFC2317. DION und OCN-JT werden nicht so oft verwendet."

msgid "rfc2317"
msgstr "RFC2317"

msgid "dion"
msgstr "DION"

msgid "ocn-jt"
msgstr "OCN-JT"

# --- Record types (reused)

msgid "a_record"
msgstr "Weiterleitungsadressen (A)-Datensatz"

msgid "ptr_record"
msgstr "Umkehradressen (PTR)-Datensatz"

msgid "cname_record"
msgstr "Alias (CNAME)-Datensatz"

msgid "mx_record"
msgstr "Mail-Server (MX)-Datensatz"

msgid "records_title"
msgstr "Dom�neneinstellungen f�r "


# --- Primary services

msgid "primary_service_button"
msgstr "Prim�re Dienste bearbeiten"

msgid "primary_service_button_help"
msgstr "Verwalten Sie DNS-Datens�tze f�r Dom�nen und Netzwerke, f�r die dieser Server registriert ist. Ein prim�rer DNS-Dienst wird auch als Master-DNS-Dienst bezeichnet."

msgid "dnsSetting"	
msgstr "Liste prim�rer Dienste"

msgid "select_dom"
msgstr "Dom�ne ausw�hlen..."

msgid "select_net"	
msgstr "Netzwerk ausw�hlen..."

	# drop down menu
msgid "add_record"
msgstr "Datensatz hinzuf�gen..."

msgid "edit_soa"
msgstr "SOA modifizieren"

msgid "edit_soa_help"
msgstr "�ndern Sie den Start of Authority (SOA; Autorit�tsursprung)-Datensatz f�r die ausgew�hlte Dom�nen- oder Netzwerkinstanz."

msgid "confirm_delall"
msgstr "Wollen Sie wirklich ALLE angezeigten DNS-Datens�tze entfernen?"

msgid "del_records"
msgstr "Datens�tze entfernen"

msgid "del_records_help"
msgstr "Klicken Sie, um alle angezeigten DNS-Datens�tze zu entfernen. Dadurch werden alle auf dieser Seite angezeigten Datens�tze entfernt. Dieser Schritt kann nicht r�ckg�ngig gemacht werden."

msgid "source"
msgstr "Abfrage"

msgid "source_help"
msgstr "Dabei handelt es sich um die Abfrage oder Frage, die diesem Dom�nennamen-Server direkt gestellt wird."

msgid "direction"
msgstr "Datensatztyp"

msgid "direction_help"
msgstr "Dabei handelt es sich um den Datensatztyp, der die Abfrage an diesen Server mit der Antwort vom Server in Bezug bringt."

msgid "resolution"
msgstr "Antwort"

msgid "resolution_help"
msgstr "Dabei handelt es sich um die Antwort, die von diesem Dom�nennamen-Server direkt ausgegeben wird."

msgid "listAction"
msgstr "Aktion"

msgid "listAction_help"
msgstr "Dies sind die Schaltfl�chen, mit denen Dom�nennamen-Datens�tze ge�ndert oder entfernt werden k�nnen."

msgid "confirm_removal"
msgstr "Wollen Sie den Datensatz [[VAR.rec]] wirklich entfernen?"

	# general IP address rule
msgid "ipaddr_rule"
msgstr "Eine IP-Adresse ist eine Reihe von vier Zahlen zwischen 0 und 255, die mit Punkten getrennt werden. Eine g�ltige Eingabe ist z. B. 192.168.1.1."





# --- A record

msgid "create_dns_recA"
msgstr "Neuen [[base-dns.a_record]] hinzuf�gen"

msgid "modify_dns_recA"
msgstr "[[base-dns.a_record]] �ndern"

msgid "a_record_explain"
msgstr "Ein [[base-dns.a_record]] �bersetzt einen vollqualifizierten Dom�nennamen in eine IP-Adresse. Ein vollqualifizierter Dom�nenname kann sowohl aus einem Hostnamen und einem Dom�nennamen als auch nur aus einem Dom�nennamen bestehen."

msgid "a_host_name"
msgstr "Hostname"

msgid "a_host_name_help"
msgstr "Geben Sie den Hostnamen f�r diesen Datensatz ein. [[base-dns.a_record_explain]]"

msgid "a_host_name_invalid"
msgstr "Der angegebene Hostname enth�lt ung�ltige Zeichen."

msgid "a_domain_name"
msgstr "Dom�nenname"

msgid "a_domain_name_help"
msgstr "Geben Sie den Dom�nennamen f�r diesen Datensatz ein. [[base-dns.a_record_explain]]"

msgid "a_domain_name_invalid"
msgstr "Der angegebene Dom�nenname enth�lt ung�ltige Zeichen."

msgid "a_domain_name_empty"
msgstr "Geben Sie die Dom�ne f�r diesen Datensatz ein."

msgid "a_ip_address"
msgstr "IP-Adresse"

msgid "a_ip_address_help"
msgstr "Geben Sie die IP-Adresse f�r diesen Datensatz ein. [[base-dns.a_record_explain]]"

msgid "a_ip_address_invalid"
msgstr "Die angegebene IP-Adresse ist ung�ltig. [[base-dns.ipaddr_rule]]"

msgid "a_ip_address_empty"
msgstr "Geben Sie die IP-Adresse an, in die der Host- und der Dom�nenname aufgel�st werden. [[base-dns.ipaddr_rule]]"


# --- PTR  record

msgid "create_dns_recPTR"
msgstr "Neuen [[base-dns.ptr_record]] hinzuf�gen"

msgid "modify_dns_recPTR"
msgstr "[[base-dns.ptr_record]] �ndern"

msgid "ptr_explain"
msgstr "Ein [[base-dns.ptr_record]] �bersetzt eine IP-Adresse in einen vollqualifizierten Dom�nennamen. Ein vollqualifizierter Dom�nenname kann sowohl aus einem Hostnamen und einem Dom�nennamen als auch nur aus einem Dom�nennamen bestehen."

msgid "ptr_ip_address"
msgstr "IP-Adresse"

msgid "ptr_ip_address_help"
msgstr "Geben Sie die IP-Adresse f�r diesen Datensatz ein. [[base-dns.ptr_explain]]"

msgid "ptr_subnet_mask"
msgstr "Subnetzmaske"

msgid "ptr_subnet_mask_help"
msgstr "Geben Sie die Netzwerkmaske der IP-Adresse f�r diesen Datensatz ein. [[base-dns.ptr_explain]]"

msgid "ptr_host_name"
msgstr "Hostname"

msgid "ptr_host_name_help"
msgstr "Geben Sie den Hostnamen f�r diesen Datensatz ein. [[base-dns.ptr_explain]]"

msgid "ptr_domain_name"
msgstr "Dom�nenname"

msgid "ptr_domain_name_help"
msgstr "Geben Sie den Dom�nennamen f�r diesen Datensatz ein. [[base-dns.ptr_explain]]"

msgid "a_generate_ptr"
msgstr "Umkehradressen (PTR)-Datensatz erstellen"

msgid "ptr_generate_a"
msgstr "Weiterleitungsadressen (A)-Datensatz erstellen"

msgid "ptr_generate_a_help"
msgstr "F�gen Sie automatisch einen Weiterleitungsadressen-Datensatz hinzu, um den angegebenen Host- und Dom�nennamen aus der angegebenen IP-Adresse aufzul�sen."

msgid "ptr_subnet_mask_invalid"
msgstr "Die angegebene Subnetzmaske ist ung�ltig. Die Subnetzmaske muss im Quadpunkt-Format eingegeben werden, d. h. als Reihe von vier Zahlen zwischen 0 und 255, die mit Punkten getrennt werden. Eine g�ltige Eingabe ist z. B. 255.255.255.0."

msgid "ptr_ip_address_invalid"
msgstr "Die angegebene IP-Adresse ist ung�ltig. [[base-dns.ipaddr_rule]]"

msgid "ptr_host_name_invalid"
msgstr "Der angegebene Hostname enth�lt ung�ltige Zeichen."

msgid "ptr_domain_name_invalid"
msgstr "Der angegebene Dom�nenname enth�lt ung�ltige Zeichen."

msgid "ptr_ip_address_empty"
msgstr "Geben Sie die IP-Adresse an, die sich in den Host- und Dom�nennamen aufl�st. [[base-dns.ipaddr_rule]]"

msgid "ptr_domain_name_empty"
msgstr "Geben Sie den Dom�nennamen an, der der IP-Adresse entspricht."


# --- MX record

msgid "create_dns_recMX"
msgstr "Neuen [[base-dns.mx_record]] hinzuf�gen"

msgid "modify_dns_recMX"
msgstr "[[base-dns.mx_record]] �ndern"

msgid "mx_host_name"
msgstr "Hostname"

msgid "mx_explain"
msgstr "Ein [[base-dns.mx_record]] identifiziert den f�r E-Mail verantwortlichen Mail-Server f�r den angegebenen Host- und Dom�nennamen."

msgid "mx_host_name_help"
msgstr "Geben Sie den Hostnamen des Computers an, der alle an den im Feld [[base-dns.mx_target_server]] angegebenen Mail-Server gesendete E-Mail verarbeiten soll. [[base-dns.mx_explain]]"

msgid "mx_domain_name"
msgstr "Dom�nenname"

msgid "mx_domain_name_help"
msgstr "Geben Sie den Dom�nennamen des Computers an, f�r den E-Mail zum im Feld [[base-dns.mx_target_server]] angegebenen Mail-Server geleitet werden soll. [[base-dns.mx_explain]]"

msgid "mx_domain_name_empty"
msgstr "Geben Sie die Dom�ne f�r diesen Datensatz ein."

msgid "mx_target_server"
msgstr "Mail-Server-Name" 

msgid "mx_target_server_help"
msgstr "Geben Sie den vollqualifizierten Dom�nennamen des Mail-Servers an, der E-Mail f�r den angegebenen Host- und Dom�nennamen annimmt. [[base-dns.mx_explain]]"

msgid "mx_priority"
msgstr "�bertragungspriorit�t" 

msgid "mx_priority_help"
msgstr "W�hlen Sie die Priorit�t f�r die �bertragung von E-Mail-Nachrichten an den Mail-Server. Der Wert der �bertragungspriorit�t gibt die Reihenfolge an, in der versucht werden sollte, mit mehreren Mail-Servern zur �bertragung von E-Mail Kontakt aufzunehmen. Die Einstellung der �bertragungspriorit�t ist nur n�tzlich, wenn f�r eine Dom�ne oder ein Netzwerk mehrere MX-Datens�tze angegeben wurden. "

msgid "very_high"
msgstr "Sehr hoch (20)"

msgid "high"	
msgstr "Hoch (30)"

msgid "low"	
msgstr "Niedrig (40)"

msgid "very_low"
msgstr "Sehr niedrig (50)"

msgid "mx_host_name_invalid"
msgstr "Der angegebene Hostname enth�lt ung�ltige Zeichen."

msgid "mx_domain_name_invalid"
msgstr "Der angegebene Dom�nenname enth�lt ung�ltige Zeichen."

msgid "mx_target_server_invalid"
msgstr "Der angegebene vollqualifizierte Dom�nenname enth�lt ung�ltige Zeichen."

msgid "mx_target_server_empty"
msgstr "Geben Sie den vollqualifizierten Dom�nennamen des Mail-Servers an."


# --- CNAME record

msgid "create_dns_recCNAME"
msgstr "Neuen [[base-dns.cname_record]] hinzuf�gen"

msgid "modify_dns_recCNAME"
msgstr "[[base-dns.cname_record]] �ndern"

msgid "cname_explain"
msgstr "Ein Alias-Datensatz �bersetzt einen vollqualifizierten Dom�nennamen in einen anderen vollqualifizierten Dom�nennamen."

msgid "cname_host_name"
msgstr "Alias-Hostname"

msgid "cname_host_name_help"
msgstr "Geben Sie den Hostnamen ein, der als Alias f�r den echten Host- bzw. Dom�nennamen fungieren soll. [[base-dns.cname_explain]]"

msgid "cname_domain_name"
msgstr "Alias-Dom�nenname"

msgid "cname_domain_name_help"
msgstr "Geben Sie den Dom�nennamen ein, der als Alias f�r den echten Host- bzw. Dom�nennamen fungieren soll. [[base-dns.cname_explain]]"

msgid "cname_host_target"
msgstr "Echter Hostname"

msgid "cname_host_target_help"
msgstr "Geben Sie den echten oder kanonischen Hostnamen ein. [[base-dns.cname_explain]]"

msgid "cname_domain_target"
msgstr "Echter Dom�nenname"

msgid "cname_domain_target_help"
msgstr "Geben Sie den echten oder kanonischen Dom�nennamen ein. [[base-dns.cname_explain]]"



# --- SOA

msgid "create_soa"
msgstr "Start of Authority (SOA)-Datensatz hinzuf�gen"

msgid "modify_soa"
msgstr "Start of Authority (SOA)-Datensatz �ndern"

msgid "domain_soa"
msgstr "Dom�neninstanz"

msgid "domain_soa_help"
msgstr "Die Dom�neninstanz, f�r die dieser Start of Authority-Datensatz gilt."

msgid "network_soa"
msgstr "Netzwerkinstanz"

msgid "network_soa_help"
msgstr "Die Netzwerkinstanz, f�r die dieser Start of Authority-Datensatz gilt."

msgid "primary_dns"
msgstr "Prim�rer Namen-Server (NS)"

msgid "primary_dns_help"
msgstr "Geben Sie den vollqualifizierten Dom�nennamen des prim�ren Namen-Servers f�r die ausgew�hlte Dom�nen- oder Netzwerkinstanz ein."

msgid "secondary_dns"
msgstr "Sekund�rer Namen-Server (NS)"

msgid "secondary_dns_help"
msgstr "Geben Sie eine durch Leerzeichen getrennte Liste mit den vollqualifizierten Dom�nennamen der sekund�ren Namen-Server f�r die ausgew�hlte Dom�nen- oder Netzwerkinstanz ein."

msgid "domain_admin"
msgstr "E-Mail-Adresse des DNS-Administrators"

msgid "domain_admin_rule"
msgstr "Bitte geben Sie eine E-Mail-Adresse im richtigen Format ein. Der Vorgabewert wird im Abschnitt [[base-dns.soa_defaults]] eingestellt. Eine g�ltige Eingabe ist z. B. benutzer@cobalt."

msgid "domain_admin_help"
msgstr "Geben Sie den Wert der E-Mail-Adresse der administrativen Kontaktperson f�r alle neu hinzugef�gten Dom�nen und Netzwerke ein. [[base-dns.domain_admin_rule]]"

msgid "domain_admin_invalid"
msgstr "[[VAR.invalidValue]] ist leider ein ung�ltiger Wert f�r das Feld [[base-dns.domain_admin]]. [[base-dns.domain_admin_rule]]"

msgid "domain_admin_empty"
msgstr "Sie haben keinen Wert im Feld [[base-dns.domain_admin]] eingegeben. [[base-dns.domain_admin_rule]]"

msgid "refresh"
msgstr "Aktualisierungsintervall (Sekunden)"

msgid "refresh_rule"
msgstr "Bitte geben Sie eine Ganzzahl zwischen 1 und 4096000 ein. Der Vorgabewert wird im Abschnitt [[base-dns.soa_defaults]] eingestellt."

msgid "refresh_help"
msgstr "Geben Sie den Vorgabewert des Aktualisierungsintervalls f�r alle neu hinzugef�gten Dom�nen und Netzwerke ein.  Dabei handelt es sich um das Intervall, in dem der sekund�re Dom�nennamen-Server versucht, seine Datens�tze mit dem prim�ren Dom�nennamen-Server zu synchronisieren. [[base-dns.refresh_rule]]"

msgid "refresh_invalid"
msgstr "[[VAR.invalidValue]] ist leider ein ung�ltiger Wert f�r das Feld [[base-dns.refresh]]. [[base-dns.refresh_rule]]"

msgid "refresh_empty"
msgstr "Sie haben keinen Wert im Feld [[base-dns.refresh]] eingegeben. [[base-dns.refresh_rule]]"

msgid "retry"
msgstr "Wiederholungsintervall (Sekunden)"

msgid "retry_rule"
msgstr "Bitte geben Sie eine Ganzzahl zwischen 1 und 4096000 ein. Der Vorgabewert wird im Abschnitt [[base-dns.soa_defaults]] eingestellt."

msgid "retry_help"
msgstr "Geben Sie den Vorgabewert des Wiederholungsintervalls f�r alle neu hinzugef�gten Dom�nen und Netzwerke ein. Wenn der sekund�re Dom�nennamen-Server aus irgendeinem Grund keinen Kontakt mit dem prim�ren Dom�nennamen-Server aufnehmen kann, um seine Datens�tze zu synchronisieren, ist dieser Wert das Intervall, in dem der sekund�re Dom�nennamen-Server wiederholt versucht, den prim�ren Dom�nennamen-Server zu kontaktieren. [[base-dns.retry_rule]]"

msgid "retry_invalid"
msgstr "[[VAR.invalidValue]] ist leider ein ung�ltiger Wert f�r das Feld [[base-dns.retry]]. [[base-dns.retry_rule]]"

msgid "retry_empty"
msgstr "Sie haben keinen Wert im Feld [[base-dns.retry]] eingegeben. [[base-dns.retry_rule]]"

msgid "expire"
msgstr "Verfallsintervall (Sekunden)"

msgid "expire_rule"
msgstr "Bitte geben Sie eine Ganzzahl zwischen 1 und 4096000 ein. Der Vorgabewert wird im Abschnitt [[base-dns.soa_defaults]] eingestellt."

msgid "expire_help"
msgstr "Geben Sie den Vorgabewert des Verfallsintervalls f�r alle neu hinzugef�gten Dom�nen und Netzwerke ein. Wenn der sekund�re Dom�nennamen-Server aus irgendeinem Grund wiederholt keinen Kontakt mit dem prim�ren Dom�nennamen-Server aufnehmen kann, um seine Datens�tze zu synchronisieren, ist dieser Wert das Intervall, nach dem der sekund�re Dom�nennamen-Server seine Dom�neninformationen nicht mehr als g�ltig betrachtet und so lange mit der �bertragung von Dom�neninformationen aufh�rt, bis der prim�re Dom�nennamen-Server wieder kontaktiert werden kann. [[base-dns.expire_rule]]"

msgid "expire_invalid"
msgstr "[[VAR.invalidValue]] ist leider ein ung�ltiger Wert f�r das Feld [[base-dns.expire]]. [[base-dns.expire_rule]]"

msgid "expire_empty"
msgstr "Sie haben keinen Wert im Feld [[base-dns.expire]] eingegeben. [[base-dns.expire_rule]]"


msgid "ttl"
msgstr "G�ltigkeitsdauerintervall (Sekunden)"

msgid "ttl_rule"
msgstr "Bitte geben Sie eine Ganzzahl zwischen 1 und 4096000 ein. Der Vorgabewert wird im Abschnitt [[base-dns.soa_defaults]] eingestellt."

msgid "ttl_help"
msgstr "Geben Sie den Vorgabewert des G�ltigkeitsdauerintervalls f�r alle neu hinzugef�gten Dom�nen und Netzwerke ein. Dieser Wert ist der Zeitraum, f�r den andere Dom�nennamen-Server die von diesem Dom�nennamen-Server abgerufenen Dom�neninformationen im Cache-Speicher zwischenspeichern und annehmen, dass sie g�ltig sind, ohne bei diesem Dom�nennamen-Server noch einmal nachzupr�fen. [[base-dns.ttl_rule]]"

msgid "ttl_invalid"
msgstr "[[VAR.invalidValue]] ist leider ein ung�ltiger Wert f�r das Feld [[base-dns.ttl]]. [[base-dns.ttl_rule]]"

msgid "ttl_empty"
msgstr "Sie haben keinen Wert im Feld [[base-dns.ttl]] eingegeben. [[base-dns.ttl_rule]]"



# ---- Secondary Services

msgid "secondary_service_button"
msgstr "Sekund�re Dienste bearbeiten"

msgid "secondary_service_button_help"
msgstr "Verwalten Sie sekund�re DNS-Dienste f�r Dom�nen und Netzwerke. "

msgid "sec_list"
msgstr "Liste sekund�rer Dienste"

msgid "create_slave_rec"
msgstr "Sekund�ren Dienst hinzuf�gen"

msgid "modify_slave_rec"
msgstr "Sekund�ren Dienst �ndern"

msgid "slave_domain_but"
msgstr "Sekund�rer Dom�nennamen-Server f�r Dom�ne"

msgid "slave_domain"
msgstr "Dom�nenname"

msgid "slave_domain_help"
msgstr "Geben Sie den Namen der Dom�ne ein, f�r die dieser Computer ein sekund�rer Dom�nennamen-Server sein soll."

msgid "slave_dom_masters"
msgstr "IP-Adresse des prim�ren DNS-Servers"

msgid "slave_dom_masters_help"
msgstr "Geben Sie die IP-Adresse des prim�ren Dom�nennamen-Servers f�r diese Dom�ne ein."

msgid "slave_network_but"
msgstr "Sekund�rer Dom�nennamen-Server f�r Netzwerk"

msgid "slave_ipaddr"
msgstr "Netzwerk"

msgid "slave_ipaddr_help"
msgstr "Geben Sie die IP-Adresse des Netzwerks ein, f�r das dieser Computer ein sekund�rer Dom�nennamen-Server sein soll."

msgid "slave_netmask"
msgstr "Netzwerk-Subnetzmaske"

msgid "slave_netmask_help"
msgstr "Geben Sie die Subnetzmaske des Netzwerks ein, f�r das dieser Computer ein sekund�rer Dom�nennamen-Server sein soll."

msgid "slave_net_masters"
msgstr "IP-Adresse des prim�ren DNS-Servers"

msgid "slave_net_masters_help"
msgstr "Geben Sie die IP-Adresse des prim�ren Dom�nennamen-Servers f�r diese Dom�ne ein."

msgid "create_slave_rec"
msgstr "Sekund�ren Dienst hinzuf�gen"

msgid "sec_authority"
msgstr "Sekund�rer Dienst"

msgid "sec_authority_help"
msgstr "Die Dom�ne oder das Netzwerk, f�r die/das dieser Computer ein sekund�rer Dom�nennamen-Server sein soll."

msgid "sec_primaries"
msgstr "Prim�rer DNS-Server"

msgid "sec_primaries_help"
msgstr "Die IP-Adresse des prim�ren Dom�nennamen-Servers f�r diese Dom�ne oder dieses Netzwerk."

msgid "recordlist_action"
msgstr "Aktion"

msgid "recordlist_action_help"
msgstr "Dies sind die Schaltfl�chen, mit denen sekund�re DNS (Domain Name Service)-Datens�tze ge�ndert oder entfernt werden k�nnen."

	# end of sentence is completed
msgid "confirm_removal_of_sec"
msgstr "Wollen Sie den sekund�ren DNS (Domain Name Service)-Datensatz f�r [[VAR.rec]] wirklich entfernen?"

msgid "slave_ipaddr_invalid"
msgstr "Die angegebene IP-Adresse ist ung�ltig."

msgid "slave_netmask_invalid"
msgstr "Die angegebene Netzmaske ist ung�ltig. Netzmasken m�ssen im Quadpunkt-Format eingegeben werden."

msgid "slave_net_masters_invalid"
msgstr "Die IP-Adresse des prim�ren DNS-Servers ist ung�ltig."

msgid "slave_domain_invalid"
msgstr "Der angegebene Dom�nenname ist ung�ltig."

msgid "slave_dom_masters_invalid"
msgstr "Die IP-Adresse des prim�ren DNS-Servers ist ung�ltig."



msgid "apply_changes"
msgstr "�nderungen jetzt �bernehmen"

msgid "apply_changes_help"
msgstr "Klicken Sie hier, um alle an den Dom�nennamen-Server-Datens�tzen vorgenommenen �nderungen sofort wirksam zu machen. Alle an Ihren Dom�nennamen-Datens�tzen vorgenommenen �nderungen werden erst aktiv, wenn sie explizit auf dem Dom�nennamen-Server �bernommen wurden, wozu auf diese Schaltfl�che geklickt werden muss."

msgid "apply_changes_disabledHelp"
msgstr "Diese Schaltfl�che ist deaktiviert, weil Sie noch keine Dom�nennamen-Server-Datens�tze hinzugef�gt oder ge�ndert haben. Nach dem Hinzuf�gen oder �ndern von Dom�nennamen-Server-Datens�tzen klicken Sie hier, um alle �nderungen sofort wirksam zu machen. "

# ---- Active monitor

msgid "amDNSNameTag"
msgstr "DNS (Domain Name Service)-Server"

msgid "amDetailsTitle"
msgstr "DNS (Domain Name Service)-Server-Details"

msgid "amNotRunning"
msgstr "Der Dom�nennamen-Server ist nicht in Betrieb."

msgid "amStatusOK"
msgstr "Der Dom�nennamen-Server arbeitet normal."




# --- Drop-down menu
msgid "select_a_domain"	
msgstr "Dom�ne ausw�hlen..."

msgid "select_a_network"
msgstr "Netzwerk ausw�hlen..."

msgid "no_records"	
msgstr "Keine Dom�nen- oder Netzwerkinstanzen"

msgid "subdom_host_name"
msgstr "Name der untergeordneten Dom�ne"

msgid "subdom_host_name_help"
msgstr "Geben Sie den Namen der nicht qualifizierten untergeordneten Dom�ne an. Um z. B. die untergeordnete Dom�ne remote.meinbuero.de zu delegieren, muss dieser Server die Instanz f�r die Dom�ne meinbuero.de sein. Geben Sie als Namen f�r die untergeordnete Dom�ne nur remote an." 

msgid "subdom_domain_name"
msgstr "Name der �bergeordneten Dom�ne" 

msgid "subdom_domain_name_help"
msgstr "W�hlen Sie den Namen der �bergeordneten Dom�ne aus. Um z. B. die �bergeordnete Dom�ne remote.meinbuero.de zu delegieren, w�hlen Sie remote.meinbuero.de aus."
msgid "subdom_nameservers"
msgstr "Namen-Server" 

msgid "subdom_nameservers_help"
msgstr "Geben Sie eine durch Kommata getrennte Liste mit den IP-Adressen der Namen-Server an, die f�r die angegebene untergeordnete Dom�ne gelten. Es muss mindestens ein Namen-Server angegeben werden." 

msgid "subnet_ip_address"
msgstr "IP-Adresse des Subnetzes"

msgid "subnet_ip_address_help"
msgstr "Geben Sie eine IP-Adresse innerhalb des gew�nschten Subnetzes an, die an einen anderen DNS-Server delegiert wird."  

msgid "subnet_subnet_mask"
msgstr "Subnetz-Netzwerkmaske"

msgid "subnet_subnet_mask_help"
msgstr "Geben Sie die Subnetz-Netzwerkmaske im Quadpunkt-Format ein." 

msgid "subnet_nameservers"
msgstr "Namen-Server" 

msgid "subnet_nameservers_help"
msgstr "Geben Sie eine durch Kommata getrennte Liste mit den IP-Adressen der Namen-Server an, die f�r das angegebene Subnetz gelten. Es muss mindestens ein Namen-Server angegeben werden." 

msgid "create_dns_rec"
msgstr "DNS-Datensatz hinzuf�gen"

msgid "modify_dns_rec"	
msgstr "DNS-Datensatz �ndern"

msgid "authority"
msgstr "Instanz"

msgid "authority_help"
msgstr "DNS-Instanzen sind Dom�nen und Netzwerke. "

msgid "subnet"
msgstr "Subnetzdelegierung"

msgid "subdom"
msgstr "Delegierung der untergeordneten Dom�ne"

msgid "modify_dns_recSUBDOM"
msgstr "Delegierung einer untergeordneten Dom�ne �ndern"

msgid "create_dns_recSUBDOM"
msgstr "Delegierung einer untergeordneten Dom�ne hinzuf�gen"

msgid "modify_dns_recSUBNET"
msgstr "Subnetz-Delegierung �ndern"

msgid "create_dns_recSUBNET"
msgstr "Subnetz-Delegierung hinzuf�gen"



msgid "add_secondary"
msgstr "Sekund�ren Dienst hinzuf�gen..."


msgid "add_secondary_forward"
msgstr "Sekund�rer Dom�nendienst"

msgid "add_secondary_network"
msgstr "Sekund�rer Netzwerkdienst"

# --- Lots of error messages

msgid "cname_domain_name_invalid"
msgstr "Der angegebene Dom�nenname enth�lt ung�ltige Zeichen."

msgid "cname_domain_target_invalid"
msgstr "Der angegebene Dom�nenname enth�lt ung�ltige Zeichen."

msgid "cname_host_target_invalid"
msgstr "Der angegebene Hostname enth�lt ung�ltige Zeichen."

msgid "cname_domain_target_invalid"
msgstr "Der angegebene Dom�nenname enth�lt ung�ltige Zeichen."


msgid "subdom_host_name_invalid"
msgstr "Der angegebene Hostname enth�lt ung�ltige Zeichen."

msgid "subdom_domain_name_invalid"
msgstr "Der angegebene Dom�nenname enth�lt ung�ltige Zeichen."

msgid "subdom_namerservers_invalid"
msgstr "Der angegebene vollqualifizierte Dom�nenname f�r den prim�ren DNS-Server ist ung�ltig."

msgid "subnet_subnet_mask_invalid"
msgstr "Die angegebene Subnetzmaske ist ung�ltig. Die Subnetzmaske muss im Quadpunkt-Format eingegeben werden."

msgid "subnet_ip_address_invalid"
msgstr "Die angegebene IP-Adresse ist ung�ltig. "

msgid "subnet_nameservers_invalid"
msgstr "Der angegebene vollqualifizierte Dom�nenname f�r den prim�ren DNS-Server ist ung�ltig."


msgid "primary_dns_invalid"
msgstr "Der angegebene Hostname enth�lt ung�ltige Zeichen."

msgid "secondary_dns_invalid"
msgstr "Der Hostname eines sekund�ren Namen-Servers enth�lt ung�ltige Zeichen."

msgid "domain_admin_invalid"
msgstr "Die angegebene E-Mail-Adresse ist ung�ltig."

msgid "refresh_invalid"
msgstr "[[VAR.invalidValue]] ist leider ein ung�ltiger Wert f�r das Feld [[base-dns.default_refresh]]. [[base-dns.default_refresh_rule]]"

msgid "retry_invalid"
msgstr "[[VAR.invalidValue]] ist leider ein ung�ltiger Wert f�r das Feld [[base-dns.default_retry]]. [[base-dns.default_retry_rule]]"

msgid "expire_invalid"
msgstr "[[VAR.invalidValue]] ist leider ein ung�ltiger Wert f�r das Feld [[base-dns.default_expire]]. [[base-dns.default_expire_rule]]"

msgid "cname_domain_name_empty"
msgstr "Bitte geben Sie den Alias-Dom�nennamen ein."

msgid "cname_domain_target_empty"
msgstr "Geben Sie einen echten Dom�nennamen ein, in den sich der Alias-Host- und der Dom�nenname aufl�sen lassen."

msgid "slave_domain_empty"
msgstr "Geben Sie den Dom�nennamen an, f�r den dieser Server als sekund�rer DNS-Server fungieren wird."

msgid "slave_dom_masters_empty"
msgstr "Geben Sie die IP-Adresse des prim�ren DNS-Servers f�r den Dom�nennamen ein."

msgid "slave_ipaddr_empty"
msgstr "Geben Sie eine IP-Adresse an, die Mitglied der Netzwerkinstanz des prim�ren DNS-Servers ist."

msgid "slave_net_masters_empty"
msgstr "Geben Sie die IP-Adresse des prim�ren DNS-Servers f�r die Netzwerkinstanz ein."

msgid "slave_netmask_empty"
msgstr "Geben Sie die Netzmaske im Quadpunkt-Format ein, die neben der angegebenen Netzwerk-IP-Adresse das Netzwerk definiert, f�r das der prim�re DNS-Server die Instanz ist."

msgid "cname_host_name_empty"
msgstr "Bitte geben Sie den Hostnamen f�r diesen Datensatz an."

msgid "cname_host_name_invalid"
msgstr "Der angegebene Hostname enth�llt ung�ltige Zeichen."

                                                                                                                                         locale/en/                                                                                          0042755 0000000 0000156 00000000000 07727667110 010550  5                                                                                                    ustar   root                                                                                                                                                                                                                                                   locale/en/dns.po                                                                                    0100644 0000000 0000156 00000103620 07432341370 011657  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   # --- Menu

msgid "dns"
msgstr "DNS"

msgid "title"
msgstr "DNS"

msgid "modifyDNS"
msgstr "[[base-dns.title]] Settings"

msgid "dns_help"	
msgstr "Click here to change [[base-dns.modifyDNS]]."


# --- Common

msgid "basic"
msgstr "Basic"

msgid "advanced"	
msgstr "Advanced"

msgid "defaults"	
msgstr "Defaults"

msgid "basic_help"
msgstr "Click here to configure basic DNS server settings."

msgid "advanced_help"
msgstr "Click here to configure advanced DNS server settings, such as data formats, security restrictions and server defaults."

msgid "defaults_help"	
msgstr "Click here to configure default Start of Authority (SOA) values."

# --- Basic settings

msgid "enabled"
msgstr "Enable Server"

msgid "enabled_help"
msgstr "Turn Domain Name System (DNS) server functionality on or off.  Turning this feature on allows this server appliance to act as a local domain name server for itself and for its clients.  A domain name server translates textual host names and domain names into numerical IP addresses, and vice-versa."


# --- Advanced settings

msgid "caching"
msgstr "Cache Record Lookups"

msgid "caching_help"
msgstr "Enabling caching, also called recursion, allows resolution of domains and network zones that other name servers are authoritative for.  Disabling caching is useful when operating this server on a private network."

msgid "soa_defaults"
msgstr "Start of Authority (SOA) Default Values"

msgid "soa_defaults_help"
msgstr "These are the default values used when adding new domain name records."

msgid "admin_email"
msgstr "Default DNS Administrator Email Address"

msgid "admin_email_rule"
msgstr "Please enter a properly formatted email address. For example, user@example.com is a valid entry."

msgid "admin_email_help"
msgstr "Enter the default email address of the administrative contact for all newly added domains and networks.  [[base-dns.admin_email_rule]]"

msgid "admin_email_invalid"
msgstr "Sorry, [[VAR.invalidValue] is an invalid value for [[base-dns.admin_email]].  [[base-dns.admin_email_rule]]"

msgid "default_refresh"
msgstr "Default Refresh Interval (Seconds)"

msgid "default_refresh_rule"
msgstr "Please enter an integer between 1 and 4096000.  The default value is 10800."

msgid "default_refresh_help"	
msgstr "Enter the default refresh interval for all newly added domains and networks.   This value is the interval at which the secondary domain name server will try to synchronize its records with the primary domain name server.  [[base-dns.default_refresh_rule]]"

msgid "default_refresh_invalid"
msgstr "Sorry, [[VAR.invalidValue] is an invalid value for [[base-dns.default_refresh]].  [[base-dns.default_refresh_rule]]"

msgid "default_refresh_empty"	
msgstr "Sorry, you have not entered a value for [[base-dns.default_refresh]].  [[base-dns.default_refresh_rule]]"

msgid "default_retry"	
msgstr "Default Retry Interval (Seconds)"

msgid "default_retry_rule"
msgstr "Please enter an integer between 1 and 4096000.  The default value is 3600."

msgid "default_retry_help"
msgstr "Enter the default retry interval for all newly added domains and networks.  If for some reason the secondary domain name server is not able to contact the primary domain name server to synchronize its records, this value is the interval at which the secondary domain name server will try repeatedly to contact the primary domain name server.  [[base-dns.default_retry_rule]]"

msgid "default_retry_invalid"
msgstr "Sorry, [[VAR.invalidValue] is an invalid value for [[base-dns.default_retry]].  [[base-dns.default_retry_rule]]"

msgid "default_retry_empty"	
msgstr "Sorry, you have not entered a value for [[base-dns.default_retry]].  [[base-dns.default_retry_rule]]"

msgid "default_expire"	
msgstr "Default Expire Interval (Seconds)"

msgid "default_expire_rule"
msgstr "Please enter an integer between 1 and 4096000.  The default value is 604800."

msgid "default_expire_help"
msgstr "Enter the default expire interval for all newly added domains and networks.  If for some reason the secondary domain name server is repeatedly not able to contact the primary domain name server to synchronize its records, this value is the interval after which the secondary domain name server will no longer consider its domain information valid. It will then stop serving domain information until the primary domain name server can be contacted again.  [[base-dns.default_expire_rule]]"

msgid "default_expire_invalid"
msgstr "Sorry, [[VAR.invalidValue] is an invalid value for [[base-dns.default_expire]].  [[base-dns.default_expire_rule]]"

msgid "default_expire_empty"
msgstr "Sorry, you have not entered a value for [[base-dns.default_expire]].  [[base-dns.default_expire_rule]]"

msgid "default_ttl"	
msgstr "Default Time-To-Live Interval (Seconds)"

msgid "default_ttl_rule"
msgstr "Please enter an integer between 1 and 4096000.  The default value is 86400."

msgid "default_ttl_help"	
msgstr "Enter the default time-to-live interval for all newly added domains and networks.  This value is the length of time for which other domain name servers will cache the domain information retrieved from this domain name server and will assume it to be valid without checking with this domain name server again.  [[base-dns.default_ttl_rule]]"

msgid "default_ttl_invalid"
msgstr "Sorry, [[VAR.invalidValue] is an invalid value for [[base-dns.default_ttl]].  [[base-dns.default_ttl_rule]]"

msgid "default_ttl_empty"
msgstr "Sorry, you have not entered a value for [[base-dns.default_ttl]].  [[base-dns.default_ttl_rule]]"

msgid "global_settings"
msgstr "Server Settings"

msgid "global_settings_help"
msgstr "These are the default values for the domain name server."

msgid "forwarders"	
msgstr "Forwarding Servers"

msgid "forwarders_help"
msgstr "Enter the IP addresses of forwarding domain name servers.  Forwarding domain name servers are used when [[base-dns.caching]] is enabled and when root domain name servers are not directly accessible due to a limited or restricted Internet connection. [[base-dns.forwarders_rule]]"

msgid "forwarders_rule"
msgstr "Please enter a series of four numbers between 0 and 255 separated by periods.  For example, 192.168.1.1 is a valid entry."

msgid "forwarders_invalid"
msgstr "Sorry, [[VAR.invalidValue]] is an invalid value for [[base-dns.forwarders]].  [[base-dns.forwarders_rule]]"

msgid "zone_xfer_ipaddr"
msgstr "Zone Transfer Access by IP Address"

msgid "zone_xfer_ipaddr_help"
msgstr "Enter the IP addresses that are allowed to download all records maintained by this domain name server through zone transfers.  Zone transfers are used by secondary domain name servers to synchronize their records with primary domain name servers.  The default value is to leave this field empty to refuse zone transfer requests."

msgid "zone_xfer_ipaddr_invalid"
msgstr "Sorry, [[VAR.invalidValue]] is an invalid value for [[base-dns.zone_xfer_ipaddr]]."

msgid "zone_format_tab"
msgstr "Zone Format"

msgid "zone_format_tab_help"
msgstr "Click here to configure the [[base-dns.zone_format_tab]] for DNS records.  This should not be necessary unless your System Administrator or ISP has specifically given you a [[base-dns.zone_format_tab]] setting."

msgid "zone_format_settings_divider"
msgstr "[[base-dns.zone_format]] Settings"

msgid "zone_format_user_defined_divider"
msgstr "User Defined [[base-dns.zone_format]] Settings"

msgid "zone_format"	
msgstr "Zone File Format"

msgid "zone_format_help"	
msgstr "Choose a zone file format for subnetting on a non-octet boundary which is compatible with your local reverse delegation method.  RFC2317 is the standard format.  DION and OCN-JT are much less commonly used."

msgid "zone_format_required_warning"
msgstr "This field is required if the [[base-dns.zone_format]] you chose above is [[base-dns.USER]] but is ignored otherwise.  Your network administrator will provide you with the correct format if necessary."

msgid "zone_format_24"
msgstr "[[base-dns.zone_format]] for > 24-bit networks."

msgid "zone_format_24_help"
msgstr "Define the [[base-dns.zone_format]] to create for a non-octet boundary network with greater than 24 bits here.  [[base-dns.zone_format_required_warning]]"

msgid "zone_format_16"
msgstr "[[base-dns.zone_format]] for > 16-bit networks."

msgid "zone_format_16_help"
msgstr "Define the [[base-dns.zone_format]] to create for a non-octet boundary network with greater than 16 bits here.  [[base-dns.zone_format_required_warning]]"

msgid "zone_format_8"
msgstr "[[base-dns.zone_format]] for > 8-bit networks."

msgid "zone_format_8_help"
msgstr "Define the [[base-dns.zone_format]] to create for a non-octet boundary network with greater than 8 bits here.  [[base-dns.zone_format_required_warning]]"

msgid "zone_format_0"
msgstr "[[base-dns.zone_format]] for > 0-bit networks."

msgid "zone_format_0_help"
msgstr "Define the [[base-dns.zone_format]] to create for a non-octet boundary network with greater than 0 bits here.  [[base-dns.zone_format_required_warning]]"

msgid "RFC2317"
msgstr "RFC2317"

msgid "DION"
msgstr "DION"

msgid "OCN-JT"
msgstr "OCN-JT"

msgid "USER"
msgstr "User Defined"

# --- Record types (reused)

msgid "a_record"
msgstr "Forward Address (A) Record"

msgid "ptr_record"
msgstr "Reverse Address (PTR) Record"

msgid "cname_record"
msgstr "Alias (CNAME) Record"

msgid "mx_record"
msgstr "Mail Server (MX) Record"

msgid "records_title"
msgstr "Domain Settings for "

msgid "a_dir"
msgstr "Forward"

msgid "ptr_dir"
msgstr "Reverse"

msgid "cname_dir"
msgstr "Alias"

# --- Primary services

msgid "primary_service_button"
msgstr "Edit Primary Services"

msgid "primary_service_button_help"
msgstr "Manage DNS records for domains and networks that this server is registered to serve.  Primary DNS service is also called Master DNS service."

msgid "dnsSetting"	
msgstr "[[base-dns.title]] Primary Service List"

msgid "select_dom"
msgstr "Select Domain..."

msgid "select_net"	
msgstr "Select Network..."

	# drop down menu
msgid "add_record"
msgstr "Add Record..."

msgid "edit_soa"
msgstr "Modify SOA"

msgid "edit_soa_help"
msgstr "Modify the start of authority record for the selected domain or network authority."

msgid "confirm_delall"
msgstr "Are you sure you want to remove ALL of the DNS records for this domain or network?"

msgid "del_records"
msgstr "Remove Records"

msgid "del_records_help"
msgstr "Click to remove all DNS records for this domain or network.  This will remove ALL records in the currently selected zone and cannot be undone."

msgid "source"
msgstr "Query"

msgid "source_help"
msgstr "This is the query or question which will be asked directly to this domain name server."

msgid "direction"
msgstr "Type"

msgid "direction_help"
msgstr "This is the record type which relates the query to this server with the response from this server."

msgid "resolution"
msgstr "Response"

msgid "resolution_help"
msgstr "This is the response or answer which will be returned directly from this domain name server."

msgid "listAction"
msgstr "Action"

msgid "listAction_help"
msgstr "These are the buttons used to modify domain name records or remove domain name records."

msgid "confirm_removal"
msgstr "Are you sure you want to remove the record [[VAR.rec]]?"

	# general IP address rule
msgid "ipaddr_rule"
msgstr "An IP address is a series of four numbers between 0 and 255 separated by periods.  For example, 192.168.1.1 is a valid entry."





# --- A record

msgid "create_dns_recA"
msgstr "[[base-dns.title]] Add New [[base-dns.a_record]]"

msgid "modify_dns_recA"
msgstr "[[base-dns.title]] Modify [[base-dns.a_record]]"

msgid "a_record_explain"
msgstr "A [[base-dns.a_record]] provides the translation from a fully-qualified domain name to an IP address.  A fully-qualified domain name can be composed of both a host name and a domain name or only a domain name."

msgid "a_host_name"
msgstr "Host Name"

msgid "a_host_name_help"
msgstr "Enter the host name for this record. [[base-dns.a_record_explain]]"

msgid "a_host_name_invalid"
msgstr "The specified host name contains invalid characters."

msgid "a_domain_name"
msgstr "Domain Name"

msgid "a_domain_name_help"
msgstr "Enter the domain name for this record.[[base-dns.a_record_explain]]"

msgid "a_domain_name_invalid"
msgstr "The specified domain name contains invalid characters."

msgid "a_domain_name_empty"
msgstr "Please specify the domain for this record."

msgid "a_ip_address"
msgstr "IP Address"

msgid "a_ip_address_help"
msgstr "Enter the IP address for this record.[[base-dns.a_record_explain]]"

msgid "a_ip_address_invalid"
msgstr "The specified IP address is invalid. [[base-dns.ipaddr_rule]]"

msgid "a_ip_address_empty"
msgstr "Please specify the IP address to which the Host and Domain Name will resolve.  [[base-dns.ipaddr_rule]]"


# --- PTR  record

msgid "create_dns_recPTR"
msgstr "[[base-dns.title]] Add New [[base-dns.ptr_record]]"

msgid "modify_dns_recPTR"
msgstr "[[base-dns.title]] Modify [[base-dns.ptr_record]]"

msgid "ptr_explain"
msgstr "A [[base-dns.ptr_record]] provides the translation from an IP address to a fully-qualified domain name.  A fully-qualified domain name can be composed of both a host name and a domain name or only a domain name."

msgid "ptr_ip_address"
msgstr "IP Address"

msgid "ptr_ip_address_help"
msgstr "Enter the IP address for this record. [[base-dns.ptr_explain]]"

msgid "ptr_mask"
msgstr "Subnet Mask"

msgid "ptr_mask_help"
msgstr "Enter the network mask of the IP address for this record. [[base-dns.ptr_explain]]"

msgid "ptr_host_name"
msgstr "Host Name"

msgid "ptr_host_name_help"
msgstr "Enter the host name for this record. [[base-dns.ptr_explain]]"

msgid "ptr_domain_name"
msgstr "Domain Name"

msgid "ptr_domain_name_help"
msgstr "Enter the domain name for this record. [[base-dns.ptr_explain]]"

msgid "a_generate_ptr"
msgstr "Generate Reverse Address (PTR) Record"

msgid "ptr_generate_a"
msgstr "Generate Forward Address (A) Record"

msgid "ptr_generate_a_help"
msgstr "Automatically add a forward address record to resolve the specified host name and domain name from the specified IP address."

msgid "ptr_subnet_mask_invalid"
msgstr "The specified subnet mask is invalid.  The subnet mask must be entered in dot-quad notation, which is a series of four numbers between 0 and 255 separated by periods.  For example, 255.255.255.0 is a valid entry."

msgid "ptr_subnet_mask_empty"
msgstr "Please specify the subnet mask for this record."

msgid "ptr_ip_address_invalid"
msgstr "The specified IP address is invalid. [[base-dns.ipaddr_rule]]"

msgid "ptr_host_name_invalid"
msgstr "The specified host name contains invalid characters."

msgid "ptr_domain_name_invalid"
msgstr "The specified domain name contains invalid characters."

msgid "ptr_ip_address_empty"
msgstr "Please specify the IP address that will resolve to the Host and Domain Name. [[base-dns.ipaddr_rule]]"

msgid "ptr_domain_name_empty"
msgstr "Please specify the Domain Name that corresponds with the IP Address."


# --- MX record

msgid "create_dns_recMX"
msgstr "[[base-dns.title]] Add New [[base-dns.mx_record]]"

msgid "modify_dns_recMX"
msgstr "[[base-dns.title]] Modify [[base-dns.mx_record]]"

msgid "mx_host_name"
msgstr "Host Name"

msgid "mx_explain"
msgstr "A [[base-dns.mx_record]] identifies the mail server responsible for email destined to the specified host and domain name."

msgid "mx_host_name_help"
msgstr "Specify the host name that will handle all email sent to the mail server specified in the [[base-dns.mx_target_server]] field. [[base-dns.mx_explain]]"

msgid "mx_domain_name"
msgstr "Domain Name" 

msgid "mx_domain_name_empty"
msgstr "Please specify the domain name for this record."

msgid "mx_domain_name_help"
msgstr "Specify the domain name of the computer for which email should be directed to the mail server specified in the [[base-dns.mx_target_server]] field. [[base-dns.mx_explain]]"

msgid "mx_target_server"
msgstr "Mail Server Name" 

msgid "mx_target_server_help"
msgstr "Specify the fully-qualified domain name of the mail server that will accept mail for the specified Host and Domain Name. [[base-dns.mx_explain]]"

msgid "mx_priority"
msgstr "Delivery Priority" 

msgid "mx_priority_help"
msgstr "Select the priority of mail delivery to the mail server.  The delivery priority specifies the order in which a series of multiple mail server machines should try to be contacted for mail delivery.  The Delivery Priority setting is only useful if multiple MX records are specified for a domain or network."

msgid "very_high"
msgstr "Very High (20)"

msgid "high"	
msgstr "High (30)"

msgid "low"	
msgstr "Low (40)"

msgid "very_low"
msgstr "Very Low (50)"

msgid "mx_dir_very_high"
msgstr "Mail Highest"

msgid "mx_dir_high"	
msgstr "Mail High"

msgid "mx_dir_low"	
msgstr "Mail Low"

msgid "mx_dir_very_low"
msgstr "Mail Lowest"

msgid "mx_host_name_invalid"
msgstr "The specified host name contains invalid characters."

msgid "mx_domain_name_invalid"
msgstr "The specified domain name contains invalid characters."

msgid "mx_target_server_invalid"
msgstr "The specified fully-qualified domain name contains invalid characters."

msgid "mx_target_server_empty"
msgstr "Please specify the fully-qualified domain name of the mail server."


# --- CNAME record

msgid "create_dns_recCNAME"
msgstr "[[base-dns.title]] Add New [[base-dns.cname_record]]"

msgid "modify_dns_recCNAME"
msgstr "[[base-dns.title]] Modify [[base-dns.cname_record]]"

msgid "cname_explain"
msgstr "An alias record provides the translation from one fully-qualified domain name to another fully-qualified domain name."

msgid "cname_host_name"
msgstr "Alias Host Name"

msgid "cname_host_name_help"
msgstr "Enter the host name that will act as an alias for the real host and/or domain name. [[base-dns.cname_explain]]"

msgid "cname_domain_name"
msgstr "Alias Domain Name"

msgid "cname_domain_name_help"
msgstr "Enter the domain name that will act as an alias for the real host and/or domain name. [[base-dns.cname_explain]]"

msgid "cname_host_target"
msgstr "Real Host Name"

msgid "cname_host_target_help"
msgstr "Enter the real, or canonical, host name. [[base-dns.cname_explain]]"

msgid "cname_domain_target"
msgstr "Real Domain Name"

msgid "cname_domain_target_help"
msgstr "Enter the real, or canonical, domain name. [[base-dns.cname_explain]]"



# --- SOA

msgid "create_soa"
msgstr "Add Start of Authority (SOA) Record"

msgid "modify_soa"
msgstr "[[base-dns.title]] Modify Start of Authority (SOA) Record"

msgid "domain_soa"
msgstr "Domain Authority"

msgid "domain_soa_help"
msgstr "This is the domain authority to which this Start of Authority record applies."

msgid "network_soa"
msgstr "Network Authority"

msgid "network_soa_help"
msgstr "This is the network authority to which this Start of Authority record applies."

msgid "primary_dns"
msgstr "Primary Name Server (NS)"

msgid "primary_dns_help"
msgstr "Enter the fully-qualified domain name of the primary name server for the selected domain or network authority."

msgid "secondary_dns"
msgstr "Secondary Name Servers (NS)"

msgid "secondary_dns_help"
msgstr "Enter a space-separated list of fully-qualified domain names of the secondary name servers for the selected domain or network authority."

msgid "domain_admin"
msgstr "DNS Administrator Email Address"

msgid "domain_admin_rule"
msgstr "Please enter a properly formatted email address.  The default email address is set in the [[base-dns.soa_defaults]] section.  For example, user@example.com is a valid entry."

msgid "domain_admin_help"
msgstr "Enter the email address of the administrative contact for all newly added domains and networks.  [[base-dns.domain_admin_rule]]"

msgid "domain_admin_invalid"
msgstr "Sorry, [[VAR.invalidValue] is an invalid value for [[base-dns.domain_admin]].  [[base-dns.domain_admin_rule]]"

msgid "domain_admin_empty"
msgstr "Sorry, you have not entered a value for [[base-dns.domain_admin]].  [[base-dns.domain_admin_rule]]"

msgid "refresh"
msgstr "Refresh Interval (Seconds)"

msgid "refresh_rule"
msgstr "Please enter an integer between 1 and 4096000.  The default value is set in the [[base-dns.soa_defaults]] section."

msgid "refresh_help"
msgstr "Enter the default refresh interval for all newly added domains and networks.   This value is the interval at which the secondary domain name server will try to synchronize its records with the primary domain name server.  [[base-dns.refresh_rule]]"

msgid "refresh_invalid"
msgstr "Sorry, [[VAR.invalidValue] is an invalid value for [[base-dns.refresh]].  [[base-dns.refresh_rule]]"

msgid "refresh_empty"
msgstr "Sorry, you have not entered a value for [[base-dns.refresh]].  [[base-dns.refresh_rule]]"

msgid "retry"
msgstr "Retry Interval (Seconds)"

msgid "retry_rule"
msgstr "Please enter an integer between 1 and 4096000.  The default value is set in the [[base-dns.soa_defaults]] section."

msgid "retry_help"
msgstr "Enter the default retry interval for all newly added domains and networks.  If for some reason the secondary domain name server is not able to contact the primary domain name server to synchronize its records, this value is the interval at which the secondary domain name server will try repeatedly to contact the primary domain name server.  [[base-dns.retry_rule]]"

msgid "retry_invalid"
msgstr "Sorry, [[VAR.invalidValue] is an invalid value for [[base-dns.retry]].  [[base-dns.retry_rule]]"

msgid "retry_empty"
msgstr "Sorry, you have not entered a value for [[base-dns.retry]].  [[base-dns.retry_rule]]"


msgid "expire"
msgstr "Expire Interval (Seconds)"

msgid "expire_rule"
msgstr "Please enter an integer between 1 and 4096000.  The default value is set in the [[base-dns.soa_defaults]] section."

msgid "expire_help"
msgstr "Enter the default expire interval for all newly added domains and networks.  If for some reason the secondary domain name server is repeatedly not able to contact the primary domain name server to synchronize its records, this value is the interval after which the secondary domain name server will no longer consider its domain information valid. It will then stop serving domain information until the primary domain name server can be contacted again.  [[base-dns.expire_rule]]"

msgid "expire_invalid"
msgstr "Sorry, [[VAR.invalidValue] is an invalid value for [[base-dns.expire]].  [[base-dns.expire_rule]]"

msgid "expire_empty"
msgstr "Sorry, you have not entered a value for [[base-dns.expire]].  [[base-dns.expire_rule]]"


msgid "ttl"
msgstr "Time-To-Live Interval (Seconds)"

msgid "ttl_rule"
msgstr "Please enter an integer between 1 and 4096000.  The default value is set in the [[base-dns.soa_defaults]] section."

msgid "ttl_help"
msgstr "Enter the default time-to-live interval for all newly added domains and networks.  This value is the length of time for which other domain name servers will cache the domain information retrieved from this domain name server and assume it to be valid without checking with this domain name server again.  [[base-dns.ttl_rule]]"

msgid "ttl_invalid"
msgstr "Sorry, [[VAR.invalidValue] is an invalid value for [[base-dns.ttl]].  [[base-dns.ttl_rule]]"

msgid "ttl_empty"
msgstr "Sorry, you have not entered a value for [[base-dns.ttl]].  [[base-dns.ttl_rule]]"



# ---- Secondary Services

msgid "secondary_service_button"
msgstr "Edit Secondary Services"

msgid "secondary_service_button_help"
msgstr "Manage secondary DNS service for domains and networks. "

msgid "sec_list"
msgstr "[[base-dns.title]] Secondary Service List"

msgid "create_slave_rec"
msgstr "[[base-dns.title]] Add Secondary Service"

msgid "modify_slave_rec"
msgstr "[[base-dns.title]] Modify Secondary Service"

msgid "slave_domain_but"
msgstr "Secondary Domain Name Server for Domain"

msgid "slave_domain"
msgstr "Domain Name"

msgid "slave_domain_help"
msgstr "Enter the name of the domain for which this machine will be a secondary domain name server."

msgid "slave_dom_masters"
msgstr "Primary DNS Server IP Address"

msgid "slave_dom_masters_help"
msgstr "Enter the IP address of the primary domain name server for this domain."

msgid "slave_network_but"
msgstr "Secondary Domain Name Server for Network"

msgid "slave_ipaddr"
msgstr "Network"

msgid "slave_ipaddr_help"
msgstr "Enter the IP address of the network for which this machine will be a secondary domain name server."

msgid "slave_netmask"
msgstr "Network Subnet Mask"

msgid "slave_netmask_help"
msgstr "Enter the subnet mask of the network for which this machine will be a secondary domain name server."

msgid "slave_net_masters"
msgstr "Primary DNS Server IP Address"

msgid "slave_net_masters_help"
msgstr "Enter the IP address of the primary domain name server for this domain."

msgid "create_slave_rec"
msgstr "Add a Secondary Service"

msgid "sec_authority"
msgstr "Secondary Service"

msgid "sec_authority_help"
msgstr "This is the domain or network for which this machine will be a secondary domain name server."

msgid "sec_primaries"
msgstr "Primary DNS Server"

msgid "sec_primaries_help"
msgstr "This is the IP address of the primary domain name server for this domain or network."

msgid "recordlist_action"
msgstr "Action"

msgid "recordlist_action_help"
msgstr "These are the buttons used to modify secondary domain name service records or remove secondary domain name service records."

	# end of sentence is completed
msgid "confirm_removal_of_sec"
msgstr "Are you sure you want to delete the secondary domain name service record for [[VAR.rec]]?"

msgid "slave_ipaddr_invalid"
msgstr "The specified IP address is invalid."

msgid "slave_netmask_invalid"
msgstr "The specified netmask is invalid.  Netmasks must be entered in dot-quad notation."

msgid "slave_net_masters_invalid"
msgstr "The primary DNS server IP address is invalid."

msgid "slave_domain_invalid"
msgstr "The specified domain name is invalid."

msgid "slave_dom_masters_invalid"
msgstr "The primary DNS server IP address is invalid."



msgid "apply_changes"
msgstr "Apply Changes Now"

msgid "apply_changes_help"
msgstr "Click here to immediately activate any changes made to your domain name server records.  Any modifications made to your domain name records will not be active until they are explicitly applied to the domain name server by clicking this button."

msgid "apply_changes_disabledHelp"
msgstr "This button is disabled because you have not yet added or modified domain name server records. After adding or modifying domain name server records, click here to immediately activate any changes made to your domain name server records. "

# ---- Active monitor

msgid "amDNSNameTag"
msgstr "Domain Name Service (DNS) Server"

msgid "amDetailsTitle"
msgstr "Domain Name Service (DNS) Server Details"

msgid "amNotRunning"
msgstr "The domain name server is not running and could not be restarted. In the [[base-apache.amAdmservNameTag]], try turning the domain name server off then on again to see if this corrects the problem. If the domain name server is still unable to start, try rebooting the server itself by clicking the [[base-power.reboot]] button in the [[base-power.power]] menu under [[base-alpine.serverconfig]]. If the domain name server is still unable to start, please refer [[base-sauce-basic.techSupportURL]] for technical support."

msgid "amStatusOK"
msgstr "The domain name server is operating normally."




# --- Drop-down menu
msgid "select_a_domain"	
msgstr "Select a Domain..."

msgid "select_a_network"
msgstr "Select a Network..."

msgid "no_records"	
msgstr "No Domain or Network Authorities"

msgid "subdom_host_name"
msgstr "Subdomain Name" 

msgid "subdom_host_name_help"
msgstr "Specify the unqualified subdomain name.  For example, to delegate the subdomain remote.example.com, this server must be authoritative for the domain example.com.  Specify only the subdomain name, remote." 

msgid "subdom_domain_name"
msgstr "Parent Domain Name" 

msgid "subdom_domain_name_help"
msgstr "Select the parent domain name.  For example, to delegate the subdomain remote.example.com, select example.com" 

msgid "subdom_nameservers"
msgstr "Name Servers" 

msgid "subdom_nameservers_help"
msgstr "Specify a comma-separated list of fully-qualified host names that are authoritative for the specified subdomain.  At least one name server must be specified.  " 

msgid "subdom_nameservers_invalid"
msgstr "The [[base-dns.subdom_nameservers]] list contains invalid characters or host names."

msgid "subdom_nameservers_empty"
msgstr "Please specify at least one DNS server that is authoritative for this subdomain."

msgid "subnet_ip_address"
msgstr "Subnet IP Address" 

msgid "subnet_ip_address_help"
msgstr "Specify an IP address within the desired subnet that will be delegated to another DNS server."  

msgid "subnet_mask"
msgstr "Subnet Network Mask" 

msgid "subnet_mask_help"
msgstr "Specify the subnet network mask in dot-quad notation." 

msgid "subnet_nameservers"
msgstr "Name Servers" 

msgid "subnet_nameservers_help"
msgstr "Specify a comma-separated list of fully-qualified host names that are authoritative for the specified subnet.  At least one name server must be specified." 

msgid "subdnet_nameservers_invalid"
msgstr "The [[base-dns.subnet_nameservers]] list contains invalid characters or host names."

msgid "subnet_nameservers_empty"
msgstr "Please specify at least one DNS server that is authoritative for this subnet."

msgid "create_dns_rec"
msgstr "Add a DNS record" 

msgid "modify_dns_rec"	
msgstr "[[base-dns.title]] Modify a DNS record"

msgid "authority"
msgstr "Authority"

msgid "authority_help"
msgstr "DNS authorities are domains and networks. "

msgid "subnet_dir"
msgstr "Subnet"

msgid "subdom_dir"
msgstr "Subdomain"

msgid "subnet"
msgstr "Subnet Delegation"

msgid "subdom"
msgstr "Subdomain Delegation"

msgid "modify_dns_recSUBDOM"
msgstr "[[base-dns.title]] Modify a Subdomain Delegation."

msgid "create_dns_recSUBDOM"
msgstr "Add a Subdomain Delegation"

msgid "modify_dns_recSUBNET"
msgstr "[[base-dns.title]] Modify a Subnet Delegation"

msgid "create_dns_recSUBNET"
msgstr "Add a Subnet Delegation"



msgid "add_secondary"
msgstr "Add Secondary Service..."


msgid "add_secondary_forward"
msgstr "...for a Domain"

msgid "add_secondary_network"
msgstr "...for a Network"

# --- Lots of error messages

msgid "cname_domain_name_invalid"
msgstr "The specified domain name contains invalid characters."

msgid "cname_domain_target_invalid"
msgstr "The specified domain name contains invalid characters."

msgid "cname_host_target_invalid"
msgstr "The specified host name contains invalid characters."

msgid "cname_domain_target_invalid"
msgstr "The specified domain name contains invalid characters."

msgid "subdom_host_name_invalid"
msgstr "The specified host name contains invalid characters."

msgid "subdom_host_name_empty"
msgstr "Please specify the subdomain name to be delegated to remote DNS servers."

msgid "subdom_domain_name_invalid"
msgstr "The specified domain name contains invalid characters."

msgid "subdom_namerservers_invalid"
msgstr "The specified fully-qualified domain name for the primary DNS server is invalid."

msgid "subnet_subnet_mask_invalid"
msgstr "The specified subnet mask is invalid.  The subnet mask must be entered in dot-quad notation."

msgid "subnet_ip_address_invalid"
msgstr "The specified IP address is invalid. "

msgid "subnet_ip_address_empty"
msgstr "Please specify an IP address that is a member of the delegated subnet."

msgid "subnet_nameservers_invalid"
msgstr "The specified fully-qualified domain name for the primary DNS server is invalid."

msgid "subnet_nameservers_empty"
msgstr "The specified fully-qualified domain name for the primary DNS server is invalid."

msgid "primary_dns_invalid"
msgstr "The specified host name contains invalid characters."

msgid "secondary_dns_invalid"
msgstr "A secondary name server host name contains invalid characters."

msgid "domain_admin_invalid"
msgstr "The specified email address is not valid."

msgid "refresh_invalid"
msgstr "Sorry, [[VAR.invalidValue] is an invalid value for [[base-dns.default_refresh]].  [[base-dns.default_refresh_rule]]"

msgid "retry_invalid"
msgstr "Sorry, [[VAR.invalidValue] is an invalid value for [[base-dns.default_retry]].  [[base-dns.default_retry_rule]]"

msgid "expire_invalid"
msgstr "Sorry, [[VAR.invalidValue] is an invalid value for [[base-dns.default_expire]].  [[base-dns.default_expire_rule]]"

msgid "cname_domain_name_empty"
msgstr "Please enter the Alias Domain Name."

msgid "cname_domain_target_empty"
msgstr "Please specify a Real Domain Name that the Alias Host and Domain Name will resolve to."

msgid "slave_domain_empty"
msgstr "Please specify the domain name that this server will become a secondary DNS server for."

msgid "slave_dom_masters_empty"
msgstr "Please specify the IP address of the primary DNS server for the Domain Name."

msgid "slave_ipaddr_empty"
msgstr "Please specify an IP address that is a member of the network authority served by the Primary DNS Server."

msgid "slave_net_masters_empty"
msgstr "Please specify the IP address of the primary DNS server for the Network authority."

msgid "slave_netmask_empty"
msgstr "Please specify the netmask in dot-quad notation that, in addition to the specified Network IP address, defines the network that the Primary DNS Server is authoritative for."

msgid "cname_host_name_empty"
msgstr "Please specify the host name for this record."

msgid "cname_host_name_invalid"
msgstr "The specified host name contains invalid characters."

msgid "parent_network"
msgstr "Parent Network"

msgid "parent_network_help"
msgstr "This is the parent network for which this server is authoritative.  All IP addresses in the specified subnet must belong to this parent network."

msgid "invalidDuplicate"
msgstr "An identical domain name record already exists."

msgid "named-did-not-start"
msgstr "The Name Server (DNS) failed to restart correctly."

msgid "invalid-authority"
msgstr "The DNS record is missing critical information."

msgid "SOA-already-exists-for-zone"
msgstr "A start of authority (SOA) record already exists for this zone."

msgid "secondaryZoneOverlap"
msgstr "An existing secondary network service conflicts with this record."

msgid "secondaryZoneDuplicate"
msgstr "An existing secondary network service conflicts with this record."

msgid "primaryZoneDuplicate"
msgstr "An existing primary network service conflicts with this record."

msgid "primaryZoneOverlap"
msgstr "An existing primary network service conflicts with this record."

msgid ""
msgstr ""

msgid ""
msgstr ""

                                                                                                                locale/es/                                                                                          0042755 0000000 0000156 00000000000 07727667110 010555  5                                                                                                    ustar   root                                                                                                                                                                                                                                                   locale/es/dns.po                                                                                    0100644 0000000 0000156 00000073314 07372633002 011671  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   # --- Menu

msgid "dns"
msgstr 
"DNS"

msgid "modifyDNS"
msgstr 
"Configuraci�n del sistema de nombres de dominio (DNS)"

msgid "dns_help"	
msgstr 
"[[base-dns.modifyDNS]]."


# --- Common

msgid "basic"
msgstr 
"B�sica"

msgid "advanced"	
msgstr 
"Avanzada"

msgid "basic_help"
msgstr 
"Definir la configuraci�n b�sica del servidor DNS."

msgid "advanced_help"
msgstr 
"Modificar par�metros de la configuraci�n avanzada del servidor DNS, formatos de datos, restricciones de seguridad y valores predeterminados del servidor."


# --- Basic settings

msgid "enabled"
msgstr 
"Habilitar servidor"

msgid "enabled_help"
msgstr 
"Activar o desactivar la funci�n de servidor DNS, con la que funciona como servidor DNS local para s� mismo y para sus clientes. Dicho servidor traduce nombres de ordenador y nombres de dominio textuales a direcciones IP num�ricas, y viceversa."


# --- Advanced settings

msgid "soa_defaults"
msgstr 
"Valores predeterminados de inicio de autoridad (SOA)"

msgid "soa_defaults_help"
msgstr 
"Valores predeterminados al a�adir nuevos registros de nombres de dominio."

msgid "admin_email"
msgstr 
"Direcci�n de correo electr�nico predeterminada del administrador DNS"

msgid "admin_email_rule"
msgstr 
"La direcci�n de correo electr�nico debe tener el formato apropiado. Por ejemplo, usuario@cobalt.com."

msgid "admin_email_help"
msgstr 
"Valor predeterminado de la direcci�n de correo electr�nico del contacto administrativo para todos los dominios y redes reci�n a�adidos. [[base-dns.admin_email_rule]]"

msgid "admin_email_invalid"
msgstr 
"[[VAR.invalidValue]] no es un valor v�lido para [[base-dns.admin_email]]. [[base-dns.admin_email_rule]]"

msgid "default_refresh"
msgstr 
"Intervalo de actualizaci�n predeterminado (segundos)"

msgid "default_refresh_rule"
msgstr 
"N�mero entero entre 1 y 4096000. El valor predeterminado es 10800."

msgid "default_refresh_help"	
msgstr 
"Intervalo predeterminado para actualizaci�n de todos los dominios y redes reci�n a�adidos. Frecuencia con la que el servidor DNS secundario intentar� sincronizar sus registros con el principal. [[base-dns.default_refresh_rule]]"

msgid "default_refresh_invalid"
msgstr 
"[[VAR.invalidValue]] no es un valor v�lido para [[base-dns.default_refresh]]. [[base-dns.default_refresh_rule]]"

msgid "default_refresh_empty"	
msgstr 
"No se ha especificado un valor para [[base-dns.default_refresh]]. [[base-dns.default_refresh_rule]]"

msgid "default_retry"	
msgstr 
"Intervalo de reintento predeterminado (segundos)"

msgid "default_retry_rule"
msgstr 
"N�mero entero entre 1 y 4096000. El valor predeterminado es 3600."

msgid "default_retry_help"
msgstr 
"Valor predeterminado del intervalo de reintento para todos los dominios y redes reci�n a�adidos. Si el servidor DNS secundario no puede conectar con el servidor DNS principal para sincronizar registros, �ste ser� intervalo de reintento de conexi�n entre el servidor DNS secundario y el principal. [[base-dns.default_retry_rule]]"

msgid "default_retry_invalid"
msgstr 
"[[VAR.invalidValue]] no es un valor v�lido para [[base-dns.default_retry]]. [[base-dns.default_retry_rule]]"

msgid "default_retry_empty"	
msgstr 
"No se ha especificado un valor para [[base-dns.default_retry]]. [[base-dns.default_retry_rule]]"

msgid "default_expire"	
msgstr 
"Intervalo de caducidad predeterminado (segundos)"

msgid "default_expire_rule"
msgstr 
"N�mero entero entre 1 y 4096000. El valor predeterminado es 604800."

msgid "default_expire_help"
msgstr 
"Intervalo predeterminado de caducidad para todos los dominios y redes reci�n a�adidos. Si el servidor DNS secundario no puede conectar de forma reiterada con el principal para sincronizar registros, este valor ser� el intervalo despu�s del cual el servidor de nombres de dominio secundario considerar� inv�lida su informaci�n de dominio y dejar� de proporcionarla hasta que pueda reconectarse con el servidor DNS principal. [[base-dns.default_expire_rule]]"

msgid "default_expire_invalid"
msgstr 
"[[VAR.invalidValue]] no es un valor v�lido para [[base-dns.default_expire]]. [[base-dns.default_expire_rule]]"

msgid "default_expire_empty"
msgstr 
"No se ha especificado un valor para [[base-dns.default_expire]]. [[base-dns.default_expire_rule]]"

msgid "default_ttl"	
msgstr 
"Intervalo predeterminado de vida (segundos)"

msgid "default_ttl_rule"
msgstr 
"N�mero entero entre 1 y 4096000. El valor predeterminado es 86400."

msgid "default_ttl_help"	
msgstr 
"Intervalo predeterminado de vida para todos los dominios y redes reci�n a�adidos. Durante este per�odo otros servidores DNS colocar�n en cach� la informaci�n de dominio recuperada de este servidor DNS, que se supondr� v�lida sin comprobarla de nuevo con este servidor DNS. [[base-dns.default_ttl_rule]]"

msgid "default_ttl_invalid"
msgstr 
"[[VAR.invalidValue]] no es un valor v�lido para [[base-dns.default_ttl]]. [[base-dns.default_ttl_rule]]"

msgid "default_ttl_empty"
msgstr 
"No se ha especificado un valor para [[base-dns.default_ttl]]. [[base-dns.default_ttl_rule]]"

msgid "global_settings"
msgstr 
"Configuraci�n del servidor"

msgid "global_settings_help"
msgstr 
"Valores predeterminados para el servidor DNS."

msgid "forwarders"	
msgstr 
"Servidores de reenv�o"

msgid "forwarders_help"
msgstr 
"Direcciones IP de los servidores de nombres de dominio de reenv�o, que se utilizan cuando los servidores DNS ra�z no tienen acceso directo debido a una conexi�n de Internet limitada o restringida. [[base-dns.forwarders_rule]]"

msgid "forwarders_rule"
msgstr 
"Serie de cuatro n�meros entre 0 y 255 separados por puntos. Por ejemplo, 192.168.1.1."

msgid "forwarders_invalid"
msgstr 
"[[VAR.invalidValue]] no es un valor v�lido para [[base-dns.forwarders]]. [[base-dns.forwarders_rule]]"

msgid "zone_xfer_ipaddr"
msgstr "Acceso de transferencia de zona por dominio"

msgid "zone_xfer_ipaddr_help"
msgstr "Nombres de ordenador o de dominio con permiso para descargar todos los registros de este servidor DNS a trav�s de transferencias de zona. Los servidores DNS secundarios sincronizan sus registros con los principales con transferencias de zona. Se deja este campo vac�o para permitir transferencias de zona no restringidas."

msgid "zone_xfer_ipaddr_invalid"
msgstr "[[VAR.invalidValue]] no es un valor v�lido para [[base-dns.zone_xfer_domain]]."

msgid "zone_format"	
msgstr "Formato de archivo de zona"

msgid "zone_format_help"	
msgstr 
"El formato de archivo de zona debe permitir establecer subredes en un l�mite sin octetos compatible con su m�todo de delegaci�n inversa local. El formato est�ndar es RFC2317. Los formatos DION y OCN-JT son mucho menos frencuentes."

msgid "rfc2317"
msgstr 
"RFC2317"

msgid "dion"
msgstr 
"DION"

msgid "ocn-jt"
msgstr 
"OCN-JT"

# --- Record types (reused)

msgid "a_record"
msgstr "Registro de direcci�n de reenv�o (A)"

msgid "ptr_record"
msgstr "Registro de direcci�n inversa (PTR)"

msgid "cname_record"
msgstr "Registro de alias (CNAME)"

msgid "mx_record"
msgstr "Registro de servidor de correo (MX)"

msgid "records_title"
msgstr "Configuraci�n de dominio para "


# --- Primary services

msgid "primary_service_button"
msgstr 
"Editar servicios principales"

msgid "primary_service_button_help"
msgstr 
"Registros DNS para dominios y redes donde este servidor est� registrado para proporcionar servicios. El servicio DNS principal tambi�n se denomina maestro."

msgid "dnsSetting"	
msgstr 
"Lista de servicios principales"

msgid "select_dom"
msgstr 
"Seleccionar dominio..."

msgid "select_net"	
msgstr 
"Seleccionar red..."

	# drop down menu
msgid "add_record"
msgstr 
"A�adir registro..."

msgid "edit_soa"
msgstr 
"Modificar SOA"

msgid "edit_soa_help"
msgstr 
"Inicio del registro de autoridad para tal dominio o autoridad de red."

msgid "confirm_delall"
msgstr 
"�Est� seguro de que desea eliminar TODOS los registros DNS mostrados?"

msgid "del_records"
msgstr 
"Eliminar registros"

msgid "del_records_help"
msgstr 
"Eliminar todos los registros DNS mostrados en esta p�gina. Esta acci�n no puede deshacerse."

msgid "source"
msgstr 
"Consulta"

msgid "source_help"
msgstr 
"Consulta directa a este servidor de nombres de dominio."

msgid "direction"
msgstr 
"Tipo de registro"

msgid "direction_help"
msgstr 
"Tipo de registro que relaciona la consulta a este servidor con la respuesta de �ste."

msgid "resolution"
msgstr 
"Respuesta"

msgid "resolution_help"
msgstr 
"Respuesta directa desde este servidor de nombres de dominio."

msgid "listAction"
msgstr 
"Acci�n"

msgid "listAction_help"
msgstr 
"Botones utilizados para modificar o eliminar registros DNS."

msgid "confirm_removal"
msgstr 
"�Est� seguro de que desea eliminar el registro [[VAR.rec]]?"

	# general IP address rule
msgid "ipaddr_rule"
msgstr 
"Una direcci�n IP es una serie de cuatro n�meros entre 0 y 255 separados por puntos. Por ejemplo, 192.168.1.1."





# --- A record

msgid "create_dns_recA"
msgstr "A�adir nuevo [[base-dns.a_record]]"

msgid "modify_dns_recA"
msgstr "Modificar [[base-dns.a_record]]"

msgid "a_record_explain"
msgstr "Un [[base-dns.a_record]] traduce un nombre de dominio completo a una direcci�n IP. Dicho nombre puede incluir un nombre de ordenador y de dominio, o s�lo un nombre de dominio."

msgid "a_host_name"
msgstr "Nombre del operador"

msgid "a_host_name_help"
msgstr "Escriba el nombre del operador de este reg�stro. [[base-dns.a_record_explain]]"

msgid "a_host_name_invalid"
msgstr "El nombre del operador especificado contiene caracteres inv�lidos."

msgid "a_domain_name"
msgstr "Nombre de dominio"

msgid "a_domain_name_help"
msgstr "Nombre de dominio para este registro. [[base-dns.a_record_explain]]"

msgid "a_domain_name_invalid"
msgstr 
"El nombre de dominio especificado contiene caracteres inv�lidos."

msgid "a_domain_name_empty"
msgstr "Dominio para este registro."

msgid "a_ip_address"
msgstr "Direcci�n IP"

msgid "a_ip_address_help"
msgstr "Direcci�n IP para este registro. [[base-dns.a_record_explain]]"

msgid "a_ip_address_invalid"
msgstr "La direcci�n IP especificada no es v�lida. [[base-dns.ipaddr_rule]]"

msgid "a_ip_address_empty"
msgstr "Direcci�n IP para resolver nombres de ordenador y de dominio. [[base-dns.ipaddr_rule]]"


# --- PTR  record

msgid "create_dns_recPTR"
msgstr 
"A�adir nuevo [[base-dns.ptr_record]]"

msgid "modify_dns_recPTR"
msgstr "Modificar [[base-dns.ptr_record]]"

msgid "ptr_explain"
msgstr "Un [[base-dns.ptr_record]] traduce una direcci�n IP a un nombre de dominio completo. Dicho nombre puede incluir un nombre de ordenador y de dominio, o s�lo un nombre de dominio."

msgid "ptr_ip_address"

msgstr 
"Direcci�n IP"

msgid "ptr_ip_address_help"
msgstr 
"Direcci�n IP para este registro. [[base-dns.ptr_explain]]"

msgid "ptr_subnet_mask"
msgstr 
"M�scara de subred"

msgid "ptr_subnet_mask_help"
msgstr 
"M�scara de subred de la direcci�n IP para este registro. [[base-dns.ptr_explain]]"

msgid "ptr_host_name"
msgstr  "Nombre del operador"

msgid "ptr_host_name_help"
msgstr "Escriba el nombre del operdor para este registro [[base-dns.ptr_explain]]"

msgid "ptr_domain_name"
msgstr 
"Nombre de dominio"

msgid "ptr_domain_name_help"
msgstr 
"Nombre de dominio para este registro. [[base-dns.ptr_explain]]"

msgid "a_generate_ptr"
msgstr 
"Generar registro de direcci�n inversa (PTR)"

msgid "ptr_generate_a"
msgstr 
"Generar registro de direcci�n de reenv�o (A)"

msgid "ptr_generate_a_help"
msgstr 
"A�adir autom�ticamente un registro de direcci�n de reenv�o para resolver el nombre de ordenador y el de dominio especificados desde dicha direcci�n IP."

msgid "ptr_subnet_mask_invalid"
msgstr 
"La m�scara de subred especificada no es v�lida. La m�scara de subred debe tener cuatro n�meros entre 0 y 255 separados por puntos. Por ejemplo, 255.255.255.0."

msgid "ptr_ip_address_invalid"
msgstr 
"La direcci�n IP especificada no es v�lida. [[base-dns.ipaddr_rule]]"

msgid "ptr_host_name_invalid"
msgstr "El nombre del ordenador especificado contiene caracteres inv�lidos."

msgid "ptr_domain_name_invalid"
msgstr 
"El nombre de dominio especificado contiene caracteres inv�lidos."

msgid "ptr_ip_address_empty"
msgstr 
"Direcci�n IP para resolver los nombres de ordenador y de dominio. [[base-dns.ipaddr_rule]]"

msgid "ptr_domain_name_empty"
msgstr 
"Nombre de dominio que se corresponde con la direcci�n IP."


# --- MX record

msgid "create_dns_recMX"
msgstr 
"A�adir nuevo [[base-dns.mx_record]]"

msgid "modify_dns_recMX"
msgstr 
"Modificar [[base-dns.mx_record]]"

msgid "mx_host_name"
msgstr "Nombre del operador"

msgid "mx_explain"
msgstr "Un [[base-dns.mx_record]] identifica el servidor de correo responsable de todo correo electr�nico para el nombre de ordenador y de dominio especificados."

msgid "mx_host_name_help"
msgstr "Especifique el nombre del operador que se hara cargo de todo el correo del servidor especificado en el campo [[base-dns.mx_target_server]]. [[base-dns.mx_explain]]"

msgid "mx_domain_name"
msgstr "Nombre de dominio"

msgid "mx_domain_name_help"
msgstr 
"Nombre del ordenador destinatario del correo electr�nico enviado desde el servidor de correo especificado en el campo [[base-dns.mx_target_server]]. [[base-dns.mx_explain]]"

msgid "mx_domain_name_empty"
msgstr "Dominio para este registro."

msgid "mx_target_server"
msgstr 
"Nombre del servidor de correo" 

msgid "mx_target_server_help"
msgstr 
"Nombre de dominio completo del servidor de correo que aceptar� correo para el nombre de ordenador y de dominio especificados. [[base-dns.mx_explain]]"

msgid "mx_priority"
msgstr 
"Prioridad de entrega" 

msgid "mx_priority_help"
msgstr 
"Prioridad de entrega al servidor de correo. Es el orden de conexi�n con una serie de equipos de correo para su entrega. Este valor es solo es �til con varios registros MX para un dominio o red."

msgid "very_high"
msgstr 
"Muy alta (20)"

msgid "high"	
msgstr 
"Alta (30)"

msgid "low"	
msgstr 
"Baja (40)"

msgid "very_low"
msgstr 
"Muy baja (50)"

msgid "mx_host_name_invalid"
msgstr "El nombre de ordenador especificado contiene caracteres inv�lidos."

msgid "mx_domain_name_invalid"
msgstr "El nombre de dominio especificado contiene caracteres inv�lidos."

msgid "mx_target_server_invalid"
msgstr 
"El nombre de dominio completo especificado contiene caracteres inv�lidos."

msgid "mx_target_server_empty"
msgstr 
"Nombre de dominio completo del servidor de correo."


# --- CNAME record

msgid "create_dns_recCNAME"
msgstr "A�adir nuevo [[base-dns.cname_record]]"

msgid "modify_dns_recCNAME"
msgstr "Modificar [[base-dns.cname_record]]"


msgid "cname_explain"
msgstr "Un registro de alias traduce un nombre de dominio completo a otro nombre de dominio completo."

msgid "cname_host_name"
msgstr "Nombre alias del operador"

msgid "cname_host_name_help"
msgstr "Escriba el nombre del operador que actuar� como alias del operador real y/o del nombre de domino. [[base-dns.cname_explain]]"

msgid "cname_domain_name"
msgstr "Alias del nombre de dominio"

msgid "cname_domain_name_help"
msgstr "Nombre de dominio que ser� el alias del nombre de ordenador o de dominio real. [[base-dns.cname_explain]]"

msgid "cname_host_target"
msgstr "Nombre real del operador."

msgid "cname_host_target_help"
msgstr "Escriba el nombre de operador real o can�nico. [[base-dns.cname_explain]]"

msgid "cname_domain_target"
msgstr "Nombre de dominio real"

msgid "cname_domain_target_help"
msgstr "Nombre de dominio real o can�nico. [[base-dns.cname_explain]]"



# --- SOA

msgid "create_soa"
msgstr 
"A�adir registro de inicio de autoridad (SOA)"

msgid "modify_soa"
msgstr 
"Modificar registro de inicio de autoridad (SOA)"

msgid "domain_soa"
msgstr 
"Autoridad de dominio"

msgid "domain_soa_help"
msgstr 
"Autoridad de dominio a la que se aplica el registro de inicio de autoridad."

msgid "network_soa"
msgstr 
"Autoridad de red"

msgid "network_soa_help"
msgstr 
"Autoridad de red a la que se aplica el registro de inicio de autoridad."

msgid "primary_dns"
msgstr 
"Servidor de nombres (NS) principal"

msgid "primary_dns_help"
msgstr 
"Nombre de dominio completo del servidor DNS principal para el dominio o autoridad de red seleccionado."

msgid "secondary_dns"
msgstr 
"Servidores de nombres (NS) secundarios"

msgid "secondary_dns_help"
msgstr 
"Lista separada por espacios de nombres de dominio completos de los servidores DNS secundarios para el dominio o autoridad de red seleccionado."

msgid "domain_admin"
msgstr 
"Direcci�n de correo electr�nico del administrador DNS"

msgid "domain_admin_rule"
msgstr 
"La direcci�n de correo electr�nico debe tener el formato apropiado. En la secci�n [[base-dns.soa_defaults]] figura el valor predeterminado. Por ejemplo, usuario@cobalt.com."

msgid "domain_admin_help"
msgstr 
"Valor de la direcci�n de correo electr�nico del contacto administrativo para todos los dominios y redes reci�n a�adidos. [[base-dns.domain_admin_rule]]"

msgid "domain_admin_invalid"
msgstr 
"[[VAR.invalidValue]] no es un valor v�lido para [[base-dns.domain_admin]]. [[base-dns.domain_admin_rule]]"

msgid "domain_admin_empty"
msgstr 
"No se ha especificado un valor para [[base-dns.domain_admin]]. [[base-dns.domain_admin_rule]]"

msgid "refresh"
msgstr 
"Intervalo de actualizaci�n (segundos)"

msgid "refresh_rule"
msgstr 
"N�mero entero entre 1 y 4096000. En la secci�n [[base-dns.soa_defaults]] figura el valor predeterminado."

msgid "refresh_help"
msgstr 
"Valor predeterminado del intervalo de actualizaci�n para todos los dominios y redes reci�n a�adidos, el que denota la frecuencia de intento de sincronizaci�n de registros entre el servidor DNS secundario y el principal. [[base-dns.refresh_rule]]"

msgid "refresh_invalid"
msgstr 
"[[VAR.invalidValue]] no es un valor v�lido para [[base-dns.refresh]]. [[base-dns.refresh_rule]]"

msgid "refresh_empty"
msgstr 
"No se ha especificado un valor para [[base-dns.refresh]]. [[base-dns.refresh_rule]]"

msgid "retry"
msgstr 
"Intervalo de reintento (segundos)"

msgid "retry_rule"
msgstr 
"N�mero entero entre 1 y 4096000. En la secci�n [[base-dns.soa_defaults]] figura el valor predeterminado."

msgid "retry_help"
msgstr 
"Valor predeterminado del intervalo de reintento para todos los dominios y redes reci�n a�adidos. Si el servidor de nombres de dominio secundario no puede conectar con el principal para sincronizar sus registros, �ste es el intervalo de reintento de conexi�n entre el servidor DNS secundario y el principal. [[base-dns.retry_rule]]"

msgid "retry_invalid"
msgstr 
"[[VAR.invalidValue]] no es un valor v�lido para [[base-dns.retry]]. [[base-dns.retry_rule]]"

msgid "retry_empty"
msgstr 
"No se ha especificado un valor para [[base-dns.retry]]. [[base-dns.retry_rule]]"


msgid "expire"
msgstr 
"Intervalo de caducidad (segundos)"

msgid "expire_rule"
msgstr 
"N�mero entero entre 1 y 4096000.En la secci�n [[base-dns.soa_defaults]] figura el valor predeterminado."

msgid "expire_help"
msgstr 
"Intervalo de caducidad predeterminado para todos los dominios y redes reci�n a�adidos. Si el servidor DNS secundario no puede conectar con el principal para sincronizar registros, despu�s de este intervalo el servidor DNS secundario considerar� su informaci�n de dominio inv�lida y dejar� de proporcionarla hasta que pueda reconectarse con el servidor DNS principal. [[base-dns.expire_rule]]"

msgid "expire_invalid"
msgstr 
"[[VAR.invalidValue]] no es un valor v�lido para [[base-dns.expire]]. [[base-dns.expire_rule]]"

msgid "expire_empty"
msgstr 
"No se ha especificado un valor para [[base-dns.expire]]. [[base-dns.expire_rule]]"


msgid "ttl"
msgstr 
"Intervalo de tiempo de vida (segundos)"

msgid "ttl_rule"
msgstr 
"N�mero entero entre 1 y 4096000. El valor predeterminado se define en la secci�n [[base-dns.soa_defaults]]."

msgid "ttl_help"
msgstr 
"Intervalo predeterminado de vida para todos los dominios y redes reci�n a�adidos. En este per�odo otros servidores de nombres de dominio colocar�n en cach� la informaci�n de dominio recuperada de este servidor DNS, que se supondr� v�lida sin comprobarla de nuevo con este servidor DNS. [[base-dns.ttl_rule]]"

msgid "ttl_invalid"
msgstr 
"[[VAR.invalidValue]] no es un valor v�lido para [[base-dns.ttl]]. [[base-dns.ttl_rule]]"

msgid "ttl_empty"
msgstr 
"No se ha especificado un valor para [[base-dns.ttl]]. [[base-dns.ttl_rule]]"



# ---- Secondary Services

msgid "secondary_service_button"
msgstr 
"Editar servicios secundarios"

msgid "secondary_service_button_help"
msgstr 
"Administrar el servicio de DNS secundario para dominios y redes. "

msgid "sec_list"
msgstr 
"Lista de servicios secundarios"

msgid "create_slave_rec"
msgstr 
"A�adir servicio secundario"

msgid "modify_slave_rec"
msgstr 
"Modificar servicio secundario"

msgid "slave_domain_but"
msgstr 
"Servidor de nombres de dominio secundario para dominio"

msgid "slave_domain"
msgstr 
"Nombre de dominio"

msgid "slave_domain_help"
msgstr 
"Nombre del dominio donde este equipo ser� servidor DNS secundario."

msgid "slave_dom_masters"
msgstr 
"Direcci�n IP del servidor DNS principal"

msgid "slave_dom_masters_help"
msgstr 
"Direcci�n IP del servidor DNS principal para este dominio."

msgid "slave_network_but"
msgstr 
"Servidor DNS secundario para red"

msgid "slave_ipaddr"
msgstr 
"Red"

msgid "slave_ipaddr_help"
msgstr 
"Direcci�n IP de la red donde este equipo ser� un servidor DNS secundario."

msgid "slave_netmask"
msgstr 
"M�scara de subred de red"

msgid "slave_netmask_help"
msgstr 
"M�scara de subred de la red donde este equipo ser� un servidor DNS secundario."

msgid "slave_net_masters"
msgstr 
"Direcci�n IP del servidor DNS principal"

msgid "slave_net_masters_help"
msgstr 
"Direcci�n IP del servidor DNS principal para este dominio."

msgid "create_slave_rec"
msgstr 
"A�adir un servicio secundario"

msgid "sec_authority"
msgstr 
"Servicio secundario"

msgid "sec_authority_help"
msgstr 
"Dominio o red donde este equipo ser� servidor DNS secundario."

msgid "sec_primaries"
msgstr 
"Servidor DNS principal"

msgid "sec_primaries_help"
msgstr 
"Direcci�n IP del servidor DNS principal para este dominio o red."

msgid "recordlist_action"
msgstr 
"Acci�n"

msgid "recordlist_action_help"
msgstr 
"Botones para modificar o eliminar registros de DNS secundario."

	# end of sentence is completed
msgid "confirm_removal_of_sec"
msgstr 
"�Est� seguro de que desea eliminar el registro de servicio de nombres de dominio secundario para [[VAR.rec]]?"

msgid "slave_ipaddr_invalid"
msgstr 
"La direcci�n IP especificada no es v�lida."

msgid "slave_netmask_invalid"
msgstr 
"La m�scara de red especificada no es v�lida. Las m�scaras de red deben tener cuatro n�meros separados por puntos."

msgid "slave_net_masters_invalid"
msgstr 
"La direcci�n IP del servidor DNS principal no es v�lida."

msgid "slave_domain_invalid"
msgstr 
"El nombre de dominio especificado no es v�lido."

msgid "slave_dom_masters_invalid"
msgstr 
"La direcci�n IP del servidor DNS principal no es v�lida."



msgid "apply_changes"
msgstr 
"Aplicar cambios ahora"

msgid "apply_changes_help"
msgstr 
"Activar inmediatamente los cambios realizados en los registros de servidor DNS. Este bot�n activa dichos cambios, ya que se aplican al servidor DNS."

msgid "apply_changes_disabledHelp"
msgstr 
"Este bot�n est� deshabilitado porque no se han a�adido ni modificado registros de servidor DNS. Despu�s de hacerlo, presione aqu� para activar inmediatamente dichos cambios."

# ---- Active monitor

msgid "amDNSNameTag"
msgstr 
"Servidor de servicio de nombres de dominio (DNS)"

msgid "amDetailsTitle"
msgstr 
"Detalles del servidor de servicio de nombres de dominio (DNS)"

msgid "amNotRunning"
msgstr 
"El servidor de nombres de dominio no se est� ejecutando."

msgid "amStatusOK"
msgstr 
"El servidor de nombres de dominio funciona normalmente."




# --- Drop-down menu
msgid "select_a_domain"	
msgstr 
"Seleccionar un dominio..."

msgid "select_a_network"
msgstr 
"Seleccionar una red..."

msgid "no_records"	
msgstr 
"Sin autoridades de dominio o de red"

msgid "subdom_host_name"
msgstr "Nombre del Subdominio"

msgid "subdom_host_name_help"
msgstr "Especifique el nombre del subdominio incompleto. Por ejemplo, para delegar el subdominio remoto.nuestraempresa.com , este operador debe tener autoridad sobre el dominio nuestraempresa.com especif�que solamente el subdominio remoto."

msgid "subdom_domain_name"
msgstr "Nombre del dominio principal"

msgid "subdom_domain_name_help"
msgstr 
"Nombre del dominio principal. Por ejemplo, para delegar el subdominio remoto.nuestraempresa.com, seleccionar nuestraempresa.com" 

msgid "subdom_nameservers"
msgstr "Servidores de nombres"

msgid "subdom_nameservers_help"
msgstr "Lista separada por comas de direcciones IP de servidores de nombres con autoridad para el subdominio especificado. Debe haber al menos un servidor de nombres." 

msgid "subnet_ip_address"
msgstr 
"Direcci�n IP de subred"

msgid "subnet_ip_address_help"
msgstr 
"Direcci�n IP de la subred a delegarse a otro servidor DNS." 

msgid "subnet_subnet_mask"
msgstr 
"M�scara de red de subred"

msgid "subnet_subnet_mask_help"
msgstr 
"M�scara de red de subred en formato de cuatro n�meros separados por puntos." 

msgid "subnet_nameservers"
msgstr 
"Servidores de nombres"

msgid "subnet_nameservers_help"
msgstr 
"Lista separada por comas de direcciones IP de servidores de nombres con autoridad para la subred especificada. Especificar al menos un servidor de nombres." 

msgid "create_dns_rec"
msgstr 
"A�adir un registro DNS" 

msgid "modify_dns_rec"	
msgstr 
"Modificar un registro DNS" 

msgid "authority"
msgstr 
"Autoridad"

msgid "authority_help"
msgstr 
"Las autoridades DNS son dominios y redes."

msgid "subnet"
msgstr 
"Delegaci�n de subred"

msgid "subdom"
msgstr 
"Delegaci�n de subdominio"

msgid "modify_dns_recSUBDOM"
msgstr 
"Modificar una delegaci�n de subdominio"

msgid "create_dns_recSUBDOM"
msgstr 
"A�adir una delegaci�n de subdominio"

msgid "modify_dns_recSUBNET"
msgstr 
"Modificar una delegaci�n de subred"

msgid "create_dns_recSUBNET"
msgstr 
"A�adir una delegaci�n de subred"



msgid "add_secondary"
msgstr 
"A�adir servicio secundario..."


msgid "add_secondary_forward"
msgstr 
"Servicio secundario de dominio"

msgid "add_secondary_network"
msgstr 
"Servicio secundario de red"

# --- Lots of error messages

msgid "cname_domain_name_invalid"
msgstr "El nombre de dominio especificado contiene caracteres inv�lidos."

msgid "cname_domain_target_invalid"
msgstr "El nombre de dominio especificado contiene caracteres inv�lidos."

msgid "cname_host_target_invalid"
msgstr "El nombre de ordenador especificado contiene caracteres inv�lidos."

msgid "cname_domain_target_invalid"
msgstr "El nombre de dominio especificado contiene caracteres inv�lidos."


msgid "subdom_host_name_invalid"
msgstr "El nombre del ordenador especificado contiene caracteres inv�lidos."

msgid "subdom_domain_name_invalid"
msgstr "El nombre de dominio especificado contiene caracteres inv�lidos."

msgid "subdom_namerservers_invalid"
msgstr 
"El nombre de dominio completo especificado para el servidor DNS principal no es v�lido."

msgid "subnet_subnet_mask_invalid"
msgstr 
"La m�scara de subred especificada no es v�lida. La m�scara de subred debe escribirse en formato de cuatro n�meros separados por puntos."

msgid "subnet_ip_address_invalid"
msgstr 
"La direcci�n IP especificada no es v�lida."

msgid "subnet_nameservers_invalid"
msgstr 
"El nombre de dominio completo especificado para el servidor DNS principal no es v�lido."


msgid "primary_dns_invalid"
msgstr 
"El nombre de ordenador especificado contiene caracteres inv�lidos."

msgid "secondary_dns_invalid"
msgstr 
"Un nombre de ordenador de servidor de nombres secundario contiene caracteres inv�lidos."

msgid "domain_admin_invalid"
msgstr 
"La direcci�n de correo electr�nico especificada no es v�lida."

msgid "refresh_invalid"
msgstr 
"[[VAR.invalidValue]] no es un valor v�lido para [[base-dns.default_refresh]]. [[base-dns.default_refresh_rule]]"

msgid "retry_invalid"
msgstr 
"[[VAR.invalidValue]] no es un valor v�lido para [[base-dns.default_retry]]. [[base-dns.default_retry_rule]]"

msgid "expire_invalid"
msgstr 
"[[VAR.invalidValue]] no es un valor v�lido para [[base-dns.default_expire]]. [[base-dns.default_expire_rule]]"

msgid "cname_domain_name_empty"
msgstr 
"Nombre de dominio de alias."

msgid "cname_domain_target_empty"
msgstr 
"Nombre de dominio real para resolver el alias del nombre de ordenador y el nombre de dominio."

msgid "slave_domain_empty"
msgstr 
"Nombre de dominio para el que este servidor ser� un servidor DNS secundario."

msgid "slave_dom_masters_empty"
msgstr 
"Direcci�n IP del servidor DNS principal para el nombre de dominio."

msgid "slave_ipaddr_empty"
msgstr 
"Direcci�n IP miembro de la autoridad de red a la que proporciona servicios el servidor DNS principal."

msgid "slave_net_masters_empty"
msgstr 
"Direcci�n IP del servidor DNS principal para la autoridad de red."

msgid "slave_netmask_empty"
msgstr 
"La m�scara de red, en formato de cuatro n�meros separados por puntos, y la direcci�n IP de red especificada definen la red donde el servidor DNS principal tiene autoridad."

msgid "cname_host_name_empty"
msgstr "Por favor especifique el nombre del servidor de este registro."

msgid "cname_host_name_invalid"
msgstr "El nombre especificado, contiene caracteres inv�lidos."


                                                                                                                                                                                                                                                                                                                    locale/fr/                                                                                          0042755 0000000 0000156 00000000000 07727667110 010555  5                                                                                                    ustar   root                                                                                                                                                                                                                                                   locale/fr/dns.po                                                                                    0100644 0000000 0000156 00000075347 07262643644 011714  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   

# --- Menu

msgid "dns"
msgstr "DNS"

msgid "modifyDNS"
msgstr "Param�tres du serveur de noms de domaine (DNS)"

msgid "dns_help"	
msgstr "[[base-dns.modifyDNS]] peut �tre modifi� ici."


# --- Common

msgid "basic"
msgstr "De base"

msgid "advanced"	
msgstr "Avanc�"

msgid "basic_help"
msgstr "Les param�tres de base du serveur DNS peuvent �tre configur�s ici."

msgid "advanced_help"
msgstr "Les param�tres avanc�s du serveur DNS, tels que les formats de donn�es, les restrictions de s�curit� et les param�tres par d�faut du serveur, peuvent �tre configur�s ici."


# --- Basic settings

msgid "enabled"
msgstr "Activer le serveur"

msgid "enabled_help"
msgstr "Active ou d�sactive le serveur de noms de domaine (DNS). Une fois cette fonction activ�e, ce service fonctionne en tant que serveur de noms de domaine local pour lui-m�me et pour ses clients. Un serveur de noms de domaine convertit les noms de domaines et d'h�tes textuels en adresses IP num�riques, et r�ciproquement."


# --- Advanced settings

msgid "soa_defaults"
msgstr "Valeurs par d�faut SOA (Start of Authority)"

msgid "soa_defaults_help"
msgstr "Ces valeurs par d�faut sont utilis�es lorsque l'on ajoute de nouveaux enregistrements de nom de domaine."

msgid "admin_email"
msgstr "Adresse email par d�faut de l'administrateur DNS"

msgid "admin_email_rule"
msgstr "Entrez une adresse email correctement format�e. utilisateur@sun.fr est un exemple d'entr�e correct."

msgid "admin_email_help"
msgstr "Entrez l'adresse email par d�faut du contact administratif pour tous les nouveaux r�seaux et domaines ajout�s. [[base-dns.admin_email_rule]]"

msgid "admin_email_invalid"
msgstr "[[VAR.invalidValue]] n'est pas une valeur correcte pour l'[[base-dns.admin_email]]. [[base-dns.admin_email_rule]]"

msgid "default_refresh"
msgstr "Fr�quence d'actualisation par d�faut (secondes)"

msgid "default_refresh_rule"
msgstr "Entrez un nombre entier compris entre 1 et 4096000. La valeur par d�faut est 10800."

msgid "default_refresh_help"	
msgstr "Entrez la fr�quence d'actualisation par d�faut pour tous les nouveaux r�seaux et domaines ajout�s. Le serveur de noms de domaine secondaire essaie de synchroniser ses enregistrements avec le serveur de noms de domaine primaire selon l'intervalle d�fini par cette valeur. [[base-dns.default_refresh_rule]]"

msgid "default_refresh_invalid"
msgstr "[[VAR.invalidValue]] n'est pas une valeur correcte pour [[base-dns.default_refresh]]. [[base-dns.default_refresh_rule]]"

msgid "default_refresh_empty"	
msgstr "Vous n'avez pas entr� de valeur pour [[base-dns.default_refresh]]. [[base-dns.default_refresh_rule]]"

msgid "default_retry"	
msgstr "Intervalle par d�faut entre tentatives (secondes)"

msgid "default_retry_rule"
msgstr "Entrez un nombre entier compris entre 1 et 4096000. La valeur par d�faut est 3600."

msgid "default_retry_help"
msgstr "Entrez la valeur par d�faut de l'intervalle entre tentatives pour tous les nouveaux r�seaux et domaines ajout�s. Si le serveur de noms de domaine secondaire n'arrive pas � contacter le serveur de noms de domaine primaire pour synchroniser ses enregistrements, le serveur de noms de domaine secondaire tentera de contacter de fa�on r�p�t�e le serveur de noms de domaine primaire selon cette valeur d'intervalle. [[base-dns.default_retry_rule]]"

msgid "default_retry_invalid"
msgstr "[[VAR.invalidValue]] n'est pas une valeur correcte pour [[base-dns.default_retry]]. [[base-dns.default_retry_rule]]"

msgid "default_retry_empty"	
msgstr "Vous n'avez pas entr� de valeur pour [[base-dns.default_retry]]. [[base-dns.default_retry_rule]]"

msgid "default_expire"	
msgstr "Intervalle d'expiration par d�faut (secondes)"

msgid "default_expire_rule"
msgstr "Entrez un nombre entier compris entre 1 et 4096000. La valeur par d�faut est 604800."

msgid "default_expire_help"
msgstr "Entrez l'intervalle d'expiration par d�faut pour tous les nouveaux r�seaux et domaines ajout�s. Si le serveur de noms de domaine secondaire n'arrive pas � contacter de fa�on r�p�t�e le serveur de noms de domaine primaire pour synchroniser ses enregistrements, le serveur de noms de domaine secondaire consid�rera que son domaine n'est plus valide pass� l'intervalle ainsi d�fini, et arr�tera d'utiliser les informations de domaine tant que le serveur de noms de domaine primaire ne peut �tre contact�. [[base-dns.default_expire_rule]]"

msgid "default_expire_invalid"
msgstr "[[VAR.invalidValue]] n'est pas une valeur correcte pour [[base-dns.default_expire]]. [[base-dns.default_expire_rule]]"

msgid "default_expire_empty"
msgstr "Vous n'avez pas entr� de valeur pour [[base-dns.default_expire]]. [[base-dns.default_expire_rule]]"

msgid "default_ttl"	
msgstr "Intervalle de dur�e de vie par d�faut (secondes)"

msgid "default_ttl_rule"
msgstr "Entrez un nombre entier compris entre 1 et 4096000. La valeur par d�faut est 86400."

msgid "default_ttl_help"	
msgstr "Entrez la valeur de dur�e de vie par d�faut pour tous les nouveaux r�seaux et domaines ajout�s. Pendant la dur�e de cet intervalle, les autres serveurs de noms de domaine mettront les informations de domaine r�cup�r�es de ce serveur de noms de domaine temporairement dans un cache, et supposeront qu'elles sont valides sans v�rifier � nouveau aupr�s de ce serveur. [[base-dns.default_ttl_rule]]"

msgid "default_ttl_invalid"
msgstr "[[VAR.invalidValue]] n'est pas une valeur correcte pour [[base-dns.default_ttl]]. [[base-dns.default_ttl_rule]]"

msgid "default_ttl_empty"
msgstr "Vous n'avez pas entr� de valeur pour [[base-dns.default_ttl]]. [[base-dns.default_ttl_rule]]"

msgid "global_settings"
msgstr "Param�tres de serveur"

msgid "global_settings_help"
msgstr "Valeurs par d�faut pour le serveur de noms de domaine."

msgid "forwarders"
msgstr "Serveurs relais"

msgid "forwarders_help"
msgstr "Entrez les adresses IP des serveurs de noms de domaine de relais. Les serveurs de noms de domaine de relais sont utilis�s lorsque les serveurs de noms de domaine publiques ne sont pas directement accessibles en raison d'une connexion Internet restreinte ou limit�e. [[base-dns.forwarders_rule]]"

msgid "forwarders_rule"
msgstr "Entrez une s�rie de quatre nombres compris entre 0 et 255 s�par�s par des points. 192.168.1.1 est un exemple d'entr�e correcte."

msgid "forwarders_invalid"
msgstr "[[VAR.invalidValue]] n'est pas une valeur correcte pour [[base-dns.forwarders]]. [[base-dns.forwarders_rule]]"

msgid "zone_xfer_ipaddr"
msgstr "Transfert de zone par adresse IP"

msgid "zone_xfer_ipaddr_help"
msgstr "Entrez les adresses IP autoris�es � t�l�charger tous les enregistrements maintenus par ce serveur de noms de domaine par le biais des transferts de zone. Les transferts de zone sont utilis�s par les serveurs de noms de domaine secondaires pour synchroniser leurs enregistrements avec les serveurs de noms de domaine primaires. Le param�tre par d�faut consiste � ne rien inscrire dans ce champ pour permettre les transferts de zone sans restriction."

msgid "zone_xfer_ipaddr_invalid"
msgstr "[[VAR.invalidValue]] n'est pas une valeur correcte pour [[base-dns.zone_xfer_ipaddr]]."

msgid "zone_format"
msgstr "Format de fichier de zones"

msgid "zone_format_help"
msgstr "D�finissez un format de fichier de zones pour les sous-r�seaux dont la taille n'est pas sur un octet entier qui soit compatible avec votre m�thode de r�solution inverse. RFC2317 est le format standard. DION et OCN-JT sont beaucoup moins souvent utilis�s."

msgid "rfc2317"
msgstr "RFC2317"

msgid "dion"
msgstr "DION"

msgid "ocn-jt"
msgstr "OCN-JT"

# --- Record types (reused)

msgid "a_record"
msgstr "Enregistrement d'adresse (A)"

msgid "ptr_record"
msgstr "Enregistrement d'adresse inverse (PTR)"

msgid "cname_record"
msgstr "Enregistrement alias (CNAME)"

msgid "mx_record"
msgstr "Enregistrement de messagerie (MX)"

msgid "records_title"
msgstr "Param�tres de domaine pour "


# --- Primary services

msgid "primary_service_button"
msgstr "Modifier les services primaires"

msgid "primary_service_button_help"
msgstr "G�re les enregistrements DNS pour les domaines et les r�seaux que ce serveur est programm� pour servir. Le service DNS primaire s'appelle �galement Service DNS ma�tre."

msgid "dnsSetting"	
msgstr "Liste des services primaires"

msgid "select_dom"
msgstr "S�lectionner un domaine..."

msgid "select_net"
msgstr "S�lectionner un r�seau..."

	# drop down menu
msgid "add_record"
msgstr "Ajouter un enregistrement..."

msgid "edit_soa"
msgstr "Modifier SOA"

msgid "edit_soa_help"
msgstr "Modifie l'enregistrement SOA (Start of Authority) pour l'autorit� r�seau ou le domaine s�lectionn�."

msgid "confirm_delall"
msgstr "Voulez-vous vraiment supprimer TOUS les enregistrements DNS affich�s ?"

msgid "del_records"
msgstr "Supprimer les enregistrements"

msgid "del_records_help"
msgstr "Cliquez pour supprimer tous les enregistrements DNS enregistr�s. Cette op�ration supprimera tous les enregistrements affich�s sur cette page ; elle est irr�versible."

msgid "source"
msgstr "Requ�te"

msgid "source_help"
msgstr "Requ�te ou question qui sera pos�e directement � ce serveur de noms de domaine."

msgid "direction"
msgstr "Type d'enregistrement"

msgid "direction_help"
msgstr "Type d'enregistrement qui associe la requ�te re�ue � la r�ponse de ce serveur."

msgid "resolution"
msgstr "R�ponse"

msgid "resolution_help"
msgstr "R�ponse qui sera renvoy�e directement par ce serveur de noms de domaine."

msgid "listAction"
msgstr "Action"

msgid "listAction_help"
msgstr "Ces boutons permettent de modifier les enregistrements de noms de domaine ou de supprimer les enregistrements de noms de domaine."

msgid "confirm_removal"
msgstr "Voulez-vous vraiment supprimer l�enregistrement [[VAR.rec]]?"

	# general IP address rule
msgid "ipaddr_rule"
msgstr "Une adresse IP est une s�rie de quatre nombres entre 0 et 255 s�par�s par des points. 192.168.1.1 est un exemple d'entr�e correcte."





# --- A record

msgid "create_dns_recA"
msgstr "Ajouter un nouvel [[base-dns.a_record]]"

msgid "modify_dns_recA"
msgstr "Modifier un nouvel [[base-dns.a_record]]"

msgid "a_record_explain"
msgstr "Un [[base-dns.a_record]] assure la conversion d'un nom complet (FQDN) en adresse IP. Un nom complet peut �tre compos� d'un nom de domaine et d'un nom d'h�te ou d'un nom de domaine seul."

msgid "a_host_name"
msgstr "Nom d'h�te"

msgid "a_host_name_help"
msgstr "Entrez le nom d'h�te pour cet enregistrement. [[base-dns.a_record_explain]]"

msgid "a_host_name_invalid"
msgstr "Le nom d'h�te sp�cifi� contient des caract�res non valides."

msgid "a_domain_name"
msgstr "Nom de domaine"

msgid "a_domain_name_help"
msgstr "Entrez le nom de domaine pour cet enregistrement.[[base-dns.a_record_explain]]"

msgid "a_domain_name_invalid"
msgstr "Le nom de domaine sp�cifi� contient des caract�res non valides."

msgid "a_domain_name_empty"
msgstr "Sp�cifiez le domaine pour cet enregistrement."

msgid "a_ip_address"
msgstr "Adresse IP"

msgid "a_ip_address_help"
msgstr "Entrez l'adresse IP pour cet enregistrement.[[base-dns.a_record_explain]]"

msgid "a_ip_address_invalid"
msgstr "L'adresse IP sp�cifi�e n'est pas valide. [[base-dns.ipaddr_rule]]"

msgid "a_ip_address_empty"
msgstr "Sp�cifiez l'adresse IP pour la r�solution du nom de domaine et d'h�te. [[base-dns.ipaddr_rule]]"


# --- PTR record

msgid "create_dns_recPTR"
msgstr "Ajouter un nouvel [[base-dns.ptr_record]]"

msgid "modify_dns_recPTR"
msgstr "Modifier un nouvel [[base-dns.ptr_record]]"

msgid "ptr_explain"
msgstr "Un [[base-dns.ptr_record]] assure la conversion d'une adresse IP � partir d'un nom complet (FQDN). Un nom complet peut �tre compos� d'un nom de domaine et d'un nom d'h�te, ou d'un nom de domaine seul."

msgid "ptr_ip_address"
msgstr "Adresse IP"

msgid "ptr_ip_address_help"
msgstr "Entrez l'adresse IP pour cet enregistrement. [[base-dns.ptr_explain]]"

msgid "ptr_subnet_mask"
msgstr "Masque r�seau"

msgid "ptr_subnet_mask_help"
msgstr "Entrez le Masque r�seau de l'adresse IP pour cet enregistrement. [[base-dns.ptr_explain]]"

msgid "ptr_host_name"
msgstr "Nom d'h�te"

msgid "ptr_host_name_help"
msgstr "Entrez le nom d'h�te pour cet enregistrement. [[base-dns.ptr_explain]]"

msgid "ptr_domain_name"
msgstr "Nom de domaine"

msgid "ptr_domain_name_help"
msgstr "Entrez le nom de domaine pour cet enregistrement. [[base-dns.ptr_explain]]"

msgid "a_generate_ptr"
msgstr "Cr�er un enregistrement d'adresse inverse (PTR)"

msgid "ptr_generate_a"
msgstr "Cr�er un enregistrement d'adresse (A)"

msgid "ptr_generate_a_help"
msgstr "Ajoute automatiquement un enregistrement d'adresse pour r�soudre le nom de domaine et d'h�te � partir de l'adresse IP."

msgid "ptr_subnet_mask_invalid"
msgstr "Le masque de sous-r�seau sp�cifi� n'est pas valide. Le masque de sous-r�seau doit �tre saisi dans une notation � quatre points, c'est-�-dire une s�rie de quatre nombres compris entre 0 et 255 s�par�s par des points. 255.255.255.0 est un exemple d'entr�e correcte."

msgid "ptr_ip_address_invalid"
msgstr "L'adresse IP sp�cifi�e n'est pas valide. [[base-dns.ipaddr_rule]]"

msgid "ptr_host_name_invalid"
msgstr "Le nom d'h�te sp�cifi� contient des caract�res non valides."

msgid "ptr_domain_name_invalid"
msgstr "Le nom de domaine sp�cifi� contient des caract�res non valides."

msgid "ptr_ip_address_empty"
msgstr "Sp�cifiez l'adresse IP pour la r�solution du nom de domaine et d'h�te. [[base-dns.ipaddr_rule]]"

msgid "ptr_domain_name_empty"
msgstr "Sp�cifiez le nom de domaine qui correspond � l'adresse IP."


# --- MX record

msgid "create_dns_recMX"
msgstr "Ajouter un nouvel [[base-dns.mx_record]]"

msgid "modify_dns_recMX"
msgstr "Modifier [[base-dns.mx_record]]"

msgid "mx_host_name"
msgstr "Nom d'h�te"

msgid "mx_explain"
msgstr "Un [[base-dns.mx_record]] identifie le serveur de messagerie responsable du courrier destin� au nom de domaine et d'h�te sp�cifi�."

msgid "mx_host_name_help"
msgstr "Sp�cifiez le nom d'h�te qui traite les tous les email envoy�s au serveur email d�sign� dans le champ [[base-dns.mx_target_server]]. [[base-dns.mx_explain]]"

msgid "mx_domain_name"
msgstr "Nom de domaine" 

msgid "mx_domain_name_help"
msgstr "Sp�cifiez le nom de domaine de l'ordinateur dont le courrier doit �tre dirig� vers le serveur de messagerie d�sign� dans le champ [[base-dns.mx_target_server]]. [[base-dns.mx_explain]]"

msgid "mx_domain_name_empty"
msgstr "Sp�cifiez le domaine pour cet enregistrement."

msgid "mx_target_server"
msgstr "Nom du serveur de messagerie" 

msgid "mx_target_server_help"
msgstr "Sp�cifiez le nom complet (FQDN) du serveur de messagerie qui acceptera le courrier pour le nom de domaine et d'h�te d�sign�. [[base-dns.mx_explain]]"

msgid "mx_priority"
msgstr "Priorit� de livraison" 

msgid "mx_priority_help"
msgstr "S�lectionnez la priorit� de livraison du courrier au serveur de messagerie. La priorit� de la livraison d�signe l'ordre dans lequel la s�rie de serveurs de messagerie doit �tre contact�e pour accepter la livraison du courrier. Le param�tre Priorit� de livraison n'est utile que si plusieurs enregistrements MX sont d�sign�s pour un domaine ou un r�seau."

msgid "very_high"
msgstr "Tr�s �lev�e (20)"

msgid "high"	
msgstr "Elev�e (30)"

msgid "low"	
msgstr "Faible (40)"

msgid "very_low"
msgstr "Tr�s faible (50)"

msgid "mx_host_name_invalid"
msgstr "Le nom d'h�te sp�cifi� contient des caract�res non valides."

msgid "mx_domain_name_invalid"
msgstr "Le nom de domaine sp�cifi� contient des caract�res non valides."

msgid "mx_target_server_invalid"
msgstr "Le nom complet contient des caract�res non valides."

msgid "mx_target_server_empty"
msgstr "Sp�cifiez le nom complet (FQDN) du serveur de messagerie."


# --- CNAME record

msgid "create_dns_recCNAME"
msgstr "Ajouter un nouvel [[base-dns.cname_record]]"

msgid "modify_dns_recCNAME"
msgstr "Modifier un nouvel [[base-dns.a_record]]"

msgid "cname_explain"
msgstr "Un enregistrement d'alias assure la conversion d'un nom complet (FQDN) en un autre nom de domaine complet."

msgid "cname_host_name"
msgstr "Nom d'h�te alias"

msgid "cname_host_name_help"
msgstr "Entrez le nom d'h�te qui servira d'alias pour le nom de domaine et/ou d'h�te r�el. [[base-dns.cname_explain]]"

msgid "cname_domain_name"
msgstr "Nom de domaine alias"

msgid "cname_domain_name_help"
msgstr "Entrez le nom de domaine qui servira d'alias pour le nom de domaine et/ou d'h�te r�el. [[base-dns.cname_explain]]"

msgid "cname_host_target"
msgstr "Nom d'h�te r�el"

msgid "cname_host_target_help"
msgstr "Entrez le nom r�el ou d'alias de l'h�te. [[base-dns.cname_explain]]"

msgid "cname_domain_target"
msgstr "Nom de domaine r�el"

msgid "cname_domain_target_help"
msgstr "Entrez le nom r�el ou d'alias du domaine. [[base-dns.cname_explain]]"



# --- SOA

msgid "create_soa"
msgstr "Ajouter l'enregistrement SOA (Start of Authority)"

msgid "modify_soa"
msgstr "Modifier l'enregistrement SOA (Start of Authority)"

msgid "domain_soa"
msgstr "Autorit� du domaine"

msgid "domain_soa_help"
msgstr "Autorit� de domaine � laquelle cet enregistrement SOA s'applique."

msgid "network_soa"
msgstr "Autorit� de r�seau"

msgid "network_soa_help"
msgstr "Autorit� de r�seau � laquelle cet enregistrement SOA s'applique."

msgid "primary_dns"
msgstr "Serveur de noms primaire (NS)"

msgid "primary_dns_help"
msgstr "Entrez le nom complet (FQDN) du serveur de noms primaires pour l'autorit� de r�seau ou de domaine s�lectionn�e."

msgid "secondary_dns"
msgstr "Serveurs de noms secondaires (NS)"

msgid "secondary_dns_help"
msgstr "Entrez la liste des noms complets (FQDN) s�par�s par des espaces pour les serveurs de noms secondaires associ�s � l'autorit� de r�seau ou de domaine s�lectionn�e."

msgid "domain_admin"
msgstr "Adresse email de l'administrateur DNS"

msgid "domain_admin_rule"
msgstr "Entrez une adresse email correctement format�e. La valeur par d�faut est d�finie dans la section [[base-dns.soa_defaults]]. utilisateur@sun.fr est un exemple d'entr�e correcte."

msgid "domain_admin_help"
msgstr "Entrez l'adresse email du contact administratif pour tous les nouveaux r�seaux et domaines ajout�s. [[base-dns.domain_admin_rule]]"

msgid "domain_admin_invalid"
msgstr "[[VAR.invalidValue]] n'est pas une valeur correcte pour [[base-dns.domain_admin]]. [[base-dns.domain_admin_rule]]"

msgid "domain_admin_empty"
msgstr "Vous n'avez pas entr� de valeur pour [[base-dns.domain_admin]]. [[base-dns.domain_admin_rule]]"

msgid "refresh"
msgstr "Intervalle de rafra�chissement (secondes)"

msgid "refresh_rule"
msgstr "Entrez un nombre entier compris entre 1 et 4096000. La valeur par d�faut est d�finie dans la section [[base-dns.soa_defaults]]."

msgid "refresh_help"
msgstr "Entrez la valeur par d�faut de fr�quence d'actualisation pour tous les nouveaux r�seaux et domaines ajout�s. Le serveur de noms de domaine secondaire essaie de synchroniser ses enregistrements avec le serveur de noms de domaine primaire selon cette fr�quence. [[base-dns.refresh_rule]]"

msgid "refresh_invalid"
msgstr "[[VAR.invalidValue]] n'est pas une valeur correcte pour [[base-dns.refresh]]. [[base-dns.refresh_rule]]"

msgid "refresh_empty"
msgstr "Vous n'avez pas entr� de valeur pour [[base-dns.refresh]]. [[base-dns.refresh_rule]]"

msgid "retry"
msgstr "Intervalle entre tentatives (secondes)"

msgid "retry_rule"
msgstr "Entrez un nombre entier entre 1 et 4096000. La valeur par d�faut est d�finie dans la section [[base-dns.soa_defaults]]."

msgid "retry_help"
msgstr "Entrez la valeur par d�faut de l'intervalle entre tentatives pour tous les nouveaux r�seaux et domaines ajout�s. Si le serveur de noms de domaine secondaire n'arrive pas � contacter le serveur de noms de domaine primaire pour synchroniser ses enregistrements, le serveur de noms de domaine secondaire tentera de contacter de fa�on r�p�t�e le serveur de noms de domaine primaire selon cet intervalle. [[base-dns.retry_rule]]"

msgid "retry_invalid"
msgstr "[[VAR.invalidValue]] n'est pas une valeur correcte pour [[base-dns.retry]]. [[base-dns.retry_rule]]"

msgid "retry_empty"
msgstr "Vous n'avez pas entr� de valeur pour [[base-dns.retry]]. [[base-dns.retry_rule]]"


msgid "expire"
msgstr "Intervalle d'expiration (secondes)"

msgid "expire_rule"
msgstr "Entrez un nombre entier entre 1 et 4096000. La valeur par d�faut est d�finie dans la section [[base-dns.soa_defaults]]."

msgid "expire_help"
msgstr "Entrez l'intervalle d'expiration par d�faut pour tous les nouveaux r�seaux et domaines ajout�s. Si le serveur de noms de domaine secondaire n'arrive pas � contacter de fa�on r�p�t�e le serveur de noms de domaine primaire pour synchroniser ses enregistrements, le serveur de noms de domaine secondaire consid�re que son domaine n'est plus valide pass� l'intervalle ainsi d�fini, et arr�te de prendre en charge les informations de domaine tant que le serveur de noms de domaine primaire ne peut �tre contact�. [[base-dns.expire_rule]]"

msgid "expire_invalid"
msgstr "[[VAR.invalidValue]] n'est pas une valeur correcte pour [[base-dns.expire]]. [[base-dns.expire_rule]]"

msgid "expire_empty"
msgstr "Vous n'avez pas entr� de valeur pour [[base-dns.expire]]. [[base-dns.expire_rule]]"


msgid "ttl"
msgstr "Intervalle de dur�e de vie (secondes)"

msgid "ttl_rule"
msgstr "Entrez un nombre entier entre 1 et 4096000. La valeur par d�faut est d�finie dans la section [[base-dns.soa_defaults]]."

msgid "ttl_help"
msgstr "Entrez l'intervalle de dur�e de vie par d�faut pour tous les nouveaux r�seaux et domaines ajout�s. Pendant la dur�e de cet intervalle, les autres serveurs de noms de domaine mettent les informations de domaine r�cup�r�es de ce serveur de noms de domaine en ant�m�moire et supposent qu'elles sont valides sans v�rifier � nouveau aupr�s de ce serveur. [[base-dns.ttl_rule]]"

msgid "ttl_invalid"
msgstr "[[VAR.invalidValue]] n'est pas une valeur correcte pour [[base-dns.ttl]]. [[base-dns.ttl_rule]]"

msgid "ttl_empty"
msgstr "Vous n'avez pas entr� de valeur pour [[base-dns.ttl]]. [[base-dns.ttl_rule]]"



# ---- Secondary Services

msgid "secondary_service_button"
msgstr "Modifier les services secondaires"

msgid "secondary_service_button_help"
msgstr "G�re le service DNS secondaire pour les domaines et les r�seaux. "

msgid "sec_list"
msgstr "Liste des services secondaires"

msgid "create_slave_rec"
msgstr "Ajouter un service secondaire"

msgid "modify_slave_rec"
msgstr "Modifier un service secondaire"

msgid "slave_domain_but"
msgstr "Serveur de noms de domaine secondaire pour le domaine"

msgid "slave_domain"
msgstr "Nom de domaine"

msgid "slave_domain_help"
msgstr "Entrez le nom du domaine pour lequel cette machine servira de serveur de noms de domaine secondaire."

msgid "slave_dom_masters"
msgstr "Adresse IP du serveur DNS primaire"

msgid "slave_dom_masters_help"
msgstr "Entrez l'adresse IP du serveur de noms de domaine primaire pour ce domaine."

msgid "slave_network_but"
msgstr "Serveur de noms de domaine secondaire pour le r�seau"

msgid "slave_ipaddr"
msgstr "R�seau"

msgid "slave_ipaddr_help"
msgstr "Entrez l'adresse IP du r�seau pour lequel cette machine servira de serveur de noms de domaine secondaire."

msgid "slave_netmask"
msgstr "Masque r�seau"

msgid "slave_netmask_help"
msgstr "Entrez le masque de sous-r�seau du r�seau pour lequel cette machine servira de serveur de noms de domaine secondaire."

msgid "slave_net_masters"
msgstr "Adresse IP du serveur DNS primaire"

msgid "slave_net_masters_help"
msgstr "Entrez l'adresse IP du serveur de noms de domaine primaire pour ce domaine."

msgid "create_slave_rec"
msgstr "Ajouter un service secondaire"

msgid "sec_authority"
msgstr "Service secondaire"

msgid "sec_authority_help"
msgstr "Domaine ou r�seau pour lequel cette machine servira de serveur de noms de domaine secondaire."

msgid "sec_primaries"
msgstr "Serveur DNS primaire"

msgid "sec_primaries_help"
msgstr "Entrez l'adresse IP du serveur du nom de domaine primaire pour ce domaine ou r�seau."

msgid "recordlist_action"
msgstr "Action"

msgid "recordlist_action_help"
msgstr "Ces boutons permettent de modifier ou de supprimer les enregistrements du service de noms de domaine secondaire."

	# end of sentence is completed
msgid "confirm_removal_of_sec"
msgstr "Voulez-vous vraiment supprimer l�enregistrement du service de noms de domaine secondaire pour [[VAR.rec]]?"

msgid "slave_ipaddr_invalid"
msgstr "L'adresse IP sp�cifi�e n'est pas valide."

msgid "slave_netmask_invalid"
msgstr "Le masque r�seau sp�cifi� n'est pas valide. Les masques r�seau doivent �tre saisis en notation � quatre points."

msgid "slave_net_masters_invalid"
msgstr "L'adresse IP du serveur DNS primaire n'est pas valide."

msgid "slave_domain_invalid"
msgstr "Le nom de domaine sp�cifi� n'est pas valide."

msgid "slave_dom_masters_invalid"
msgstr "L'adresse IP du serveur DNS primaire n'est pas valide."

msgid "apply_changes"
msgstr "Appliquer les changements"

msgid "apply_changes_help"
msgstr "Cliquez ici pour activer imm�diatement les changements apport�s aux enregistrements de votre serveur de noms de domaine. Toutes les modifications apport�es � vos enregistrements de noms de domaine ne seront activ�es qu'apr�s avoir �t� explicitement appliqu�s au serveur de noms de domaine en cliquant sur ce bouton."

msgid "apply_changes_disabledHelp"
msgstr "Ce bouton est d�sactiv� car vous n'avez pas encore ajout� ou modifi� les enregistrements du serveur de noms de domaine. Apr�s avoir ajout� ou modifi� les enregistrements de votre serveur de noms de domaine, cliquez ici pour activer imm�diatement les changements apport�s. "

# ---- Active monitor

msgid "amDNSNameTag"
msgstr "Serveur de noms de domaine (DNS)"

msgid "amDetailsTitle"
msgstr "D�tails du serveur de noms de domaine (DNS)"

msgid "amNotRunning"
msgstr "Le serveur de noms de domaine ne fonctionne pas."

msgid "amStatusOK"
msgstr "Le serveur de noms de domaine fonctionne normalement."




# --- Drop-down menu
msgid "select_a_domain"	
msgstr "S�lectionner un domaine..."

msgid "select_a_network"
msgstr "S�lectionner un r�seau..."

msgid "no_records"	
msgstr "Pas d'autorit�s de r�seau ou de domaine"

msgid "subdom_host_name"
msgstr "Nom de sous-domaine" 

msgid "subdom_host_name_help"
msgstr "Sp�cifiez le nom du sous-domaine uniquement. Par exemple, pour d�l�guer le sous-domaine 'distant.monentrepreprise.fr', ce serveur doit avoir l'autorit� pour le domaine monentreprise.fr. Sp�cifiez ici uniquement le nom de sous-domaine, 'distant'."

msgid "subdom_domain_name"
msgstr "Nom de domaine parent" 

msgid "subdom_domain_name_help"
msgstr "S�lectionner le nom de domaine parent. Par exemple, pour d�l�guer le sous-domaine 'remote. monentreprise.fr', s�lectionnez 'monentreprise.fr'" 

msgid "subdom_nameservers"
msgstr "Serveurs de noms" 

msgid "subdom_nameservers_help"
msgstr "Sp�cifiez la liste des adresses IP, s�par�es par des virgules, des serveurs de noms qui auront l'autorit� pour le sous-domaine sp�cifi�. Au moins un serveur de noms doit �tre d�sign�." 

msgid "subnet_ip_address"
msgstr "Adresse IP de sous-r�seau" 

msgid "subnet_ip_address_help"
msgstr "Sp�cifiez une adresse IP dans le sous-r�seau souhait� qui sera d�l�gu�e � un autre serveur DNS." 

msgid "subnet_subnet_mask"
msgstr "Masque r�seau"

msgid "subnet_subnet_mask_help"
msgstr "Sp�cifiez le masque de sous-r�seau en notation � quatre points." 

msgid "subnet_nameservers"
msgstr "Serveurs de noms" 

msgid "subnet_nameservers_help"
msgstr "Sp�cifiez la liste des adresses IP, s�par�es par des virgules, des serveurs de noms qui auront l'autorit� pour le sous-r�seau sp�cifi�. Au moins un serveur de noms doit �tre d�sign�." 

msgid "create_dns_rec"
msgstr "Ajouter un enregistrement DNS" 

msgid "modify_dns_rec"	
msgstr "Modifier un enregistrement DNS"

msgid "authority"
msgstr "Autorit�"

msgid "authority_help"
msgstr "Les autorit�s DNS sont les domaines et les r�seaux. "

msgid "subnet"
msgstr "D�l�gation de sous-r�seau"

msgid "subdom"
msgstr "D�l�gation de sous-domaine"

msgid "modify_dns_recSUBDOM"
msgstr "Modifier une d�l�gation de sous-domaine."

msgid "create_dns_recSUBDOM"
msgstr "Ajouter une d�l�gation de sous-domaine."

msgid "modify_dns_recSUBNET"
msgstr "Modifier une d�l�gation de sous-r�seau."

msgid "create_dns_recSUBNET"
msgstr "Ajouter une d�l�gation de sous-r�seau."



msgid "add_secondary"
msgstr "Ajouter un service secondaire..."


msgid "add_secondary_forward"
msgstr "Service de domaine secondaire"

msgid "add_secondary_network"
msgstr "Service de r�seau secondaire"

# --- Lots of error messages

msgid "cname_domain_name_invalid"
msgstr "Le nom de domaine sp�cifi� contient des caract�res non valides."

msgid "cname_domain_target_invalid"
msgstr "Le nom de domaine sp�cifi� contient des caract�res non valides."

msgid "cname_host_target_invalid"
msgstr "Le nom d'h�te sp�cifi� contient des caract�res non valides."

msgid "cname_domain_target_invalid"
msgstr "Le nom de domaine sp�cifi� contient des caract�res non valides."


msgid "subdom_host_name_invalid"
msgstr "Le nom d'h�te sp�cifi� contient des caract�res non valides."

msgid "subdom_domain_name_invalid"
msgstr "Le nom de domaine sp�cifi� contient des caract�res non valides."

msgid "subdom_namerservers_invalid"
msgstr "Le nom complet pour le serveur DNS primaire n'est pas valide."

msgid "subnet_subnet_mask_invalid"
msgstr "Le masque de sous-r�seau sp�cifi� n'est pas valide. Le masque de sous-r�seau doit �tre saisi en notation � quatre points."

msgid "subnet_ip_address_invalid"
msgstr "L'adresse IP sp�cifi�e n'est pas valide. "

msgid "subnet_nameservers_invalid"
msgstr "Le nom complet pour le serveur DNS primaire n'est pas valide."


msgid "primary_dns_invalid"
msgstr "Le nom d'h�te sp�cifi� contient des caract�res non valides."

msgid "secondary_dns_invalid"
msgstr "Un nom d'h�te de serveur de noms secondaire contient des caract�res non valides."

msgid "domain_admin_invalid"
msgstr "L'adresse email sp�cifi�e n'est pas valide."

msgid "refresh_invalid"
msgstr "[[VAR.invalidValue]] n'est pas une valeur correcte pour [[base-dns.default_refresh]]. [[base-dns.default_refresh_rule]]"

msgid "retry_invalid"
msgstr "[[VAR.invalidValue]] n'est pas une valeur correcte pour [[base-dns.default_retry]]. [[base-dns.default_retry_rule]]"

msgid "expire_invalid"
msgstr "[[VAR.invalidValue]] n'est pas une valeur correcte pour [[base-dns.default_expire]]. [[base-dns.default_expire_rule]]"

msgid "cname_domain_name_empty"
msgstr "Entrez le Nom de domaine alias."

msgid "cname_domain_target_empty"
msgstr "Sp�cifiez un nom de domaine r�el pour la r�solution du nom de domaine et d'h�te alias."

msgid "slave_domain_empty"
msgstr "Sp�cifiez le nom de domaine pour lequel ce serveur servira de serveur DNS secondaire."

msgid "slave_dom_masters_empty"
msgstr "Sp�cifiez l'adresse IP du serveur DNS primaire pour le nom de domaine."

msgid "slave_ipaddr_empty"
msgstr "Sp�cifiez une adresse IP appartenant � l'autorit� de r�seau prise en charge par le serveur DNS primaire."

msgid "slave_net_masters_empty"
msgstr "Sp�cifiez l'adresse IP du serveur DNS primaire pour l'autorit� de r�seau."

msgid "slave_netmask_empty"
msgstr "Sp�cifiez le masque r�seau en notation � quatre points, en plus de l'adresse IP du r�seau, qui d�finit le r�seau pour lequel le serveur DNS primaire a autorit�."

msgid "cname_host_name_empty"
msgstr "Sp�cifiez le nom d'h�te pour cet enregistrement."

msgid "cname_host_name_invalid"
msgstr "Le nom d'h�te sp�cifi� contient des caracteres non valides."

                                                                                                                                                                                                                                                                                         locale/ja/                                                                                          0042755 0000000 0000156 00000000000 07727667110 010540  5                                                                                                    ustar   root                                                                                                                                                                                                                                                   locale/ja/dns.po                                                                                    0100644 0000000 0000156 00000103043 07452452104 011646  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   # --- Menu

msgid "dns"
msgstr "DNS"

msgid "title"
msgstr "DNS"

msgid "modifyDNS"
msgstr "DNS �̐ݒ�"

msgid "dns_help"
msgstr "DNS (Domain Name System) �̐ݒ��ύX�ł��܂��B"


# --- Common

msgid "basic"
msgstr "��{"

msgid "advanced"
msgstr "�ڍ�"

msgid "defaults"	
msgstr "�f�t�H���g"

msgid "basic_help"
msgstr "��{�I�� DNS �T�[�o�̐ݒ荀�ڂł��B"

msgid "advanced_help"
msgstr "�f�[�^�`���A�Z�L�����e�B�ی�A�f�t�H���g�l�ȂǁADNS �T�[�o�̏ڍׂ�ݒ�ł��܂��B"

msgid "defaults_help"	
msgstr "�f�t�H���g�� SOA (Start of Authority) �p�����[�^��ݒ�ł��܂��B"

# --- Basic settings

msgid "enabled"
msgstr "DNS �T�[�r�X��L���ɂ���"

msgid "enabled_help"
msgstr "���̃{�b�N�X���`�F�b�N����ƁADNS�i�h���C���l�[���V�X�e���j�T�[�r�X���L���ɂȂ�A���̃T�[�o�����̃T�[�o����у��[�J���l�b�g���[�N��̃N���C�A���g�ɑ΂���h���C���l�[���T�[�o�Ƃ��ċ@�\���܂��B�h���C���l�[���T�[�o�́A�e�L�X�g������ŕ\�L�����z�X�g���{�h���C���l�[���ƁA���l�ŕ\�L����� IP �A�h���X�Ƃ̑Ή� �i�������A�t����) ����񋟂��܂��B"


# --- Advanced settings

msgid "caching"
msgstr "�L���b�V�����R�[�h�̖₢���킹"

msgid "caching_help"
msgstr "�L���b�V���O�i�u�ċA�I�₢���킹�v�Ƃ��Ă΂��j��L���ɂ���ƁA���̃l�[���T�[�o�����Ђ����h���C����l�b�g���[�N�]�[���������ł���悤�ɂȂ�܂��B�v���C�x�[�g�ȃl�b�g���[�N��ł݂̂��̃T�[�o���g���ꍇ�ɂ́A�L���b�V���O�𖳌��ɂ��Ă��������B"

msgid "soa_defaults"
msgstr "SOA�iStart of Authority�j�̃f�t�H���g�ݒ�"

msgid "soa_defaults_help"
msgstr "�����ł́A�V�K�̃h���C���l�[�����R�[�h���쐬����Ƃ��Ƀf�t�H���g�Ƃ��Ďg����l��ݒ�ł��܂��B"

msgid "admin_email"
msgstr "DNS �Ǘ��҂̓d�q���[���A�h���X"

msgid "admin_email_rule"
msgstr "�i�w���F kazuo.otsuka@sun.com�j"

msgid "admin_email_help"
msgstr "�V�����h���C����l�b�g���[�N�� DNS ���R�[�h�ɒǉ�����ۂɃf�t�H���g�Ƃ��Ďg����Ǘ��҂̓d�q���[���A�h���X���A�������`���œ��͂��Ă��������B[[base-dns.admin_email_rule]]"

msgid "admin_email_invalid"
msgstr "[[VAR.invalidValue] �́A[[base-dns.admin_email]] �ɂ͎w��ł��܂���B�d�q���[���A�h���X�𐳂����`���œ��͂��Ă��������B[[base-dns.admin_email_rule]]"

msgid "default_refresh"
msgstr "���t���b�V���Ԋu�i�b�j"

msgid "default_refresh_rule"
msgstr "1 �` 4096000 �̐�������͂��Ă��������B�����l�� 10800 �ł��B"

msgid "default_refresh_help"
msgstr "�V�����h���C����l�b�g���[�N�� DNS ���R�[�h�ɒǉ�����ۂɃf�t�H���g�Ƃ��Ďg���郊�t���b�V���Ԋu���w�肵�Ă��������B���t���b�V���Ԋu�Ƃ́A�Z�J���_���h���C���l�[���T�[�o���v���C�}���h���C���l�[���T�[�o�ƃ��R�[�h�̓�����}�鎞�ԊԊu�ł��B[[base-dns.default_refresh_rule]]"

msgid "default_refresh_invalid"
msgstr "[[VAR.invalidValue]] �́A[[base-dns.default_refresh]] �ɂ͎w��ł��܂���B[[base-dns.default_refresh_rule]]"

msgid "default_refresh_empty"	
msgstr "[[base-dns.default_refresh]]�͕K�{�ł��B[[base-dns.default_refresh_rule]]"

msgid "default_retry"	
msgstr "���g���C�Ԋu�i�b�j"

msgid "default_retry_rule"
msgstr "1 �` 4096000 �̐�������͂��Ă��������B�����l�� 3600 �ł��B"

msgid "default_retry_help"
msgstr "�V�����h���C����l�b�g���[�N�� DNS ���R�[�h�ɒǉ�����ۂɃf�t�H���g�Ƃ��Ďg���郊�g���C�Ԋu���w�肵�Ă��������B���g���C�Ԋu�Ƃ́A���炩�̗��R�ŃZ�J���_���h���C���l�[���T�[�o���v���C�}���h���C���l�[���T�[�o�̃��R�[�h�Ɠ��������Ȃ��ꍇ�ɁA�J��Ԃ����R�[�h�̓��������s���鎞�ԊԊu�ł��B[[base-dns.default_retry_rule]]"

msgid "default_retry_invalid"
msgstr "[[VAR.invalidValue]] �́A[[base-dns.default_retry]] �ɂ͎w��ł��܂���B[[base-dns.default_retry_rule]]"

msgid "default_retry_empty"
msgstr "[[base-dns.default_retry]] �͕K�{�ł��B[[base-dns.default_retry_rule]]"

msgid "default_expire"
msgstr "�����Ԋu�i�b�j"

msgid "default_expire_rule"
msgstr "1 �` 4096000 �̐�������͂��Ă��������B�����l�� 604800 �ł��B"

msgid "default_expire_help"
msgstr "�V�����h���C����l�b�g���[�N�� DNS ���R�[�h�ɒǉ�����ۂɃf�t�H���g�Ƃ��Ďg���鎸���Ԋu���w�肵�Ă��������B���炩�̗��R�ŃZ�J���_���h���C���l�[���T�[�o���v���C�}���h���C���l�[���T�[�o�ƃ��R�[�h�𓯊��ł����A�J��Ԃ����������݂�ꍇ�A�����Ԋu�i�b�j���o�߂��Ă������ł��Ȃ��ƁA�Z�J���_���h���C���l�[���T�[�o�͎����̎��h���C�����͂����L���ł͂Ȃ��Ɣ��f���A�v���C�}���h���C���l�[���T�[�o�֍ēx�A���ł���܂Ńh���C�����̒񋟂��~���܂��B[[base-dns.default_expire_rule]]"

msgid "default_expire_invalid"
msgstr "[[VAR.invalidValue]] �́A[[base-dns.default_expire]]�ɂ͎w��ł��܂���B[[base-dns.default_expire_rule]]"

msgid "default_expire_empty"
msgstr "[[base-dns.default_expire]] �͕K�{�ł��B[[base-dns.default_expire_rule]]"

msgid "default_ttl"	
msgstr "TTL �Ԋu�i�b�j"

msgid "default_ttl_rule"
msgstr "1 �` 4096000 �̐�������͂��Ă��������B�����l�� 86400 �ł��B"

msgid "default_ttl_help"	
msgstr "�V�����h���C����l�b�g���[�N�� DNS ���R�[�h�ɒǉ�����ۂɃf�t�H���g�Ƃ��Ďg���� TTL �Ԋu���w�肵�Ă��������BTTL �Ԋu�Ƃ́A���̃h���C���l�[���T�[�o�����̃h���C���l�[���T�[�o����擾�����h���C�������L���b�V���ɕۊǂ��A���̃h���C���l�[���T�[�o�ɍĂјA�����Ȃ��܂܂��̏�񂪗L���ł���Ƒz�肷����Ԃł��B[[base-dns.default_ttl_rule]]"

msgid "default_ttl_invalid"
msgstr "[[VAR.invalidValue]] �́A[[base-dns.default_ttl]] �ɂ͎w��ł��܂���B[[base-dns.default_ttl_rule]]"

msgid "default_ttl_empty"
msgstr "[[base-dns.default_ttl]] �͕K�{�ł��B[[base-dns.default_ttl_rule]]"

msgid "global_settings"
msgstr "�T�[�o�̈�ʐݒ�"

msgid "global_settings_help"
msgstr "�h���C���l�[���T�[�o�̃f�t�H���g�l�ł��B"

msgid "forwarders"
msgstr "�]���T�[�o"

msgid "forwarders_help"
msgstr "�]���h���C���l�[���T�[�o�� IP �A�h���X����͂��Ă��������B�C���^�[�l�b�g�ڑ��ɉ��炩�̖�肪����A���[�g�h���C���l�[���T�[�o�ɒ��ڃA�N�Z�X�ł��Ȃ��ꍇ�ɁA�]���h���C���l�[���T�[�o���g���܂��B[[base-dns.forwarders_rule]]"

msgid "forwarders_rule"
msgstr "0 �` 255 �̐��l�S�g���A�s���I�h�ŋ�؂��ē��͂��Ă��������B�i�w���F 192.168.1.1�j"

msgid "forwarders_invalid"
msgstr "[[VAR.invalidValue]] �́A[[base-dns.forwarders]]�ɂ͎w��ł��܂���B[[base-dns.forwarders_rule]]"

msgid "zone_xfer_ipaddr"
msgstr "�]�[���]���������� IP �A�h���X"

msgid "zone_xfer_ipaddr_help"
msgstr "�]�[���]���Ƃ́A���̃h���C���l�[���T�[�o�ɕۊǂ���Ă���S���R�[�h�̃_�E�����[�h���Ӗ����܂��B���̃t�B�[���h�ɂ́A�]�[���]������������ IP �A�h���X���w�肵�Ă��������B�Z�J���_���h���C���l�[���T�[�o�́A�]�[���]���ɂ��v���C�}���h���C���l�[���T�[�o�ƃ��R�[�h�𓯊����܂��B���̃t�B�[���h���󔒂̂܂܎c���ƁA�]�[���]���͈�؋�����܂���B"

msgid "zone_xfer_ipaddr_invalid"
msgstr "[[VAR.invalidValue]] �́A[[base-dns.zone_xfer_ipaddr]] �Ƃ��Ďw��ł��܂���B"

msgid "zone_format_tab"
msgstr "�]�[���`��"

msgid "zone_format_tab_help"
msgstr "�������N���b�N����ƁADNS ���R�[�h��[[base-dns.zone_format_tab]]��ݒ�ł��܂��B�V�X�e���Ǘ��҂܂��� ISP ��������[[base-dns.zone_format_tab]]�̐ݒ���w������Ȃ�����ݒ�͕s�v�ł��B"

msgid "zone_format_settings_divider"
msgstr "�]�[���t�@�C���`���̐ݒ�"

msgid "zone_format_user_defined_divider"
msgstr "���[�U��`�̃]�[���t�@�C���`��"

msgid "zone_format"
msgstr "�]�[���t�@�C���̌`��"

msgid "zone_format_help"
msgstr "���[�J���̋t���������Ϗ����\�b�h�ɑΉ������I�N�e�b�g���E��̃T�u�l�b�g�p�]�[���t�@�C���`����I��ł��������B�W���`���� RFC2317 �ŁADION �� OCN-JT �͂��܂��ʓI�ł͂���܂���B"

msgid "zone_format_required_warning"
msgstr "���̃t�B�[���h�ւ̓��͂́A�w�肳��Ă���]�[���t�@�C���̌`�����u���[�U��`�v�̏ꍇ�ɂ̂ݕK�{�ŁA����ȊO�̃]�[���t�@�C���`���ł͖�������܂��B�w�肷�ׂ��l�̌`���ɂ��ẮA�l�b�g���[�N�Ǘ��҂܂ł��₢���킹���������B"

msgid "zone_format_24"
msgstr "24 �r�b�g�ȏ�̃l�b�g���[�N�p�]�[���t�@�C���`��"

msgid "zone_format_24_help"
msgstr "24 �r�b�g�𒴂����I�N�e�b�g���E��̃l�b�g���[�N�p�]�[���t�@�C���`�����w�肵�Ă��������B[[base-dns.zone_format_required_warning]]"

msgid "zone_format_16"
msgstr "16 �r�b�g�ȏ�̃l�b�g���[�N�p�]�[���t�@�C���`��"

msgid "zone_format_16_help"
msgstr "16 �r�b�g�𒴂����I�N�e�b�g���E��̃l�b�g���[�N�p�]�[���t�@�C���`�����w�肵�Ă��������B[[base-dns.zone_format_required_warning]]"

msgid "zone_format_8"
msgstr "8 �r�b�g�ȏ�̃l�b�g���[�N�p�]�[���t�@�C���`��"

msgid "zone_format_8_help"
msgstr "8 �r�b�g�𒴂����I�N�e�b�g���E��̃l�b�g���[�N�p�]�[���t�@�C���`�����w�肵�Ă��������B[[base-dns.zone_format_required_warning]]"

msgid "zone_format_0"
msgstr "0 �r�b�g�ȏ�̃l�b�g���[�N�p�]�[���t�@�C���`��"

msgid "zone_format_0_help"
msgstr "0 �r�b�g�𒴂����I�N�e�b�g���E��̃l�b�g���[�N�p�]�[���t�@�C���`�����w�肵�Ă��������B[[base-dns.zone_format_required_warning]]"

msgid "rfc2317"
msgstr "RFC2317"

msgid "dion"
msgstr "DION"

msgid "ocn-jt"
msgstr "OCN-JT"

msgid "USER"
msgstr "���[�U��`"

# --- Record types (reused)

msgid "a_record"
msgstr "�������A�h���X�iA�j���R�[�h"

msgid "ptr_record"
msgstr "�t�����A�h���X�iPTR�j���R�[�h"

msgid "cname_record"
msgstr "�G�C���A�X�iCNAME�j���R�[�h"

msgid "mx_record"
msgstr "���[���T�[�o�iMX�j���R�[�h"

msgid "records_title"
msgstr "�h���C���ݒ�F "

msgid "a_dir"
msgstr "������"

msgid "ptr_dir"
msgstr "�t����"

msgid "cname_dir"
msgstr "�G�C���A�X"

# --- Primary services

msgid "primary_service_button"
msgstr "�v���C�}���T�[�r�X��ݒ�"

msgid "primary_service_button_help"
msgstr "���̃T�[�o���񋟂��� DNS ���R�[�h���Ǘ��ł��܂��B�v���C�}�� DNS �T�[�r�X�́A�u�}�X�^�[ DNS �T�[�r�X�v�Ƃ��Ă΂�܂��B"

msgid "dnsSetting"
msgstr "[[base-dns.title]] - �v���C�}���T�[�r�X�̃��X�g"

msgid "select_dom"
msgstr "�h���C����I��..."

msgid "select_net"
msgstr "�l�b�g���[�N��I��..."

# drop down menu

msgid "add_record"
msgstr "���R�[�h��ǉ�..."

msgid "edit_soa"
msgstr "SOA ���C��"

msgid "edit_soa_help"
msgstr "����̃h���C���܂��̓l�b�g���[�N�ɓK�p����� SOA�iStart of Authority�j���C���ł��܂��B"

msgid "confirm_delall"
msgstr "�\������Ă��� DNS ���R�[�h�����ׂč폜���Ă�낵���ł����H"

msgid "del_records"
msgstr "�S���R�[�h���폜"

msgid "del_records_help"
msgstr "���̃{�^�����N���b�N����ƁA�\������Ă��� DNS ���R�[�h���S�č폜����܂��B �폜�͎������ł��܂���̂ł����ӂ��������B"

msgid "source"
msgstr "�₢���킹"

msgid "source_help"
msgstr "���̃l�[���T�[�o����M����₢���킹�ł��B"

msgid "direction"
msgstr "���R�[�h�̎��"

msgid "direction_help"
msgstr "���̃l�[���T�[�o����M����₢���킹�Ƒ��M����񓚂Ƃ��֘A�t���郌�R�[�h�̎�ނł��B"

msgid "resolution"
msgstr "��"

msgid "resolution_help"
msgstr "�₢���킹�ɑ΂��Ă��̃l�[���T�[�o���瑗�M�����񓚂ł��B"

msgid "listAction"
msgstr "�ڍ�"

msgid "listAction_help"
msgstr "���M�A�C�R�����N���b�N����ƁA���̃��R�[�h���C���ł��܂��B�S�~���A�C�R�����N���b�N����ƁA���̃��R�[�h���폜�ł��܂��B"

msgid "confirm_removal"
msgstr "[[VAR.rec]] �Ƃ������R�[�h���폜���Ă�낵���ł����H"


# general IP address rule
msgid "ipaddr_rule"
msgstr "IP �A�h���X�́A0 �` 255 �̐��l�S�g���s���I�h�ŋ�؂��ē��͂��Ă��������B�i�w���F 192.168.1.1�j"


# --- A record

msgid "create_dns_recA"
msgstr "[[base-dns.title]] - [[base-dns.a_record]]�̒ǉ�"

msgid "modify_dns_recA"
msgstr "[[base-dns.title]] - [[base-dns.a_record]]�̏C��"

msgid "a_record_explain"
msgstr "[[base-dns.a_record]]�́A�h���C���l�[������ IP �A�h���X�ւ̕ϊ��f�[�^��񋟂��܂��B���̏ꍇ�́u�h���C���l�[���v�́A�z�X�g���{�h���C���l�[���ł��A�h���C���l�[���݂̂ł��\���܂���B"

msgid "a_host_name"
msgstr "�z�X�g��"

msgid "a_host_name_help"
msgstr "���̃��R�[�h�̃z�X�g�����w�肵�Ă��������B[[base-dns.a_record_explain]]"

msgid "a_host_name_invalid"
msgstr "�w�肳�ꂽ�z�X�g���ɂ́A�s���ȕ������܂܂�Ă��܂��B"

msgid "a_domain_name"
msgstr "�h���C���l�[��"

msgid "a_domain_name_help"
msgstr "���̃��R�[�h�̃h���C���l�[�����w�肵�Ă��������B[[base-dns.a_record_explain]]"

msgid "a_domain_name_invalid"
msgstr "�w�肳�ꂽ�h���C���l�[���ɂ́A�s���ȕ������܂܂�Ă��܂��B"

msgid "a_domain_name_empty"
msgstr "���̃��R�[�h�̃h���C�����w�肵�Ă��������B"

msgid "a_ip_address"
msgstr "IP �A�h���X"

msgid "a_ip_address_help"
msgstr "���̃��R�[�h�� IP �A�h���X���w�肵�Ă��������B[[base-dns.a_record_explain]]"

msgid "a_ip_address_invalid"
msgstr "�w�肳�ꂽ IP �A�h���X�͕s���ł��B[[base-dns.ipaddr_rule]]"

msgid "a_ip_address_empty"
msgstr "�w�肳�ꂽ�z�X�g���ƃh���C���l�[���ɑΉ����� IP �A�h���X����͂��Ă��������B[[base-dns.ipaddr_rule]]"


# --- PTR  record

msgid "create_dns_recPTR"
msgstr "[[base-dns.title]] - [[base-dns.ptr_record]]�̒ǉ�"

msgid "modify_dns_recPTR"
msgstr "[[base-dns.title]] - [[base-dns.ptr_record]]�̏C��"

msgid "ptr_explain"
msgstr "[[base-dns.ptr_record]]�́AIP �A�h���X����h���C���l�[���ւ̕ϊ��f�[�^��񋟂��܂��B���̏ꍇ�́u�h���C���l�[���v�́A�z�X�g���{�h���C���l�[���ł��A�h���C���l�[���݂̂ł��\���܂���B"

msgid "ptr_ip_address"
msgstr "IP �A�h���X"

msgid "ptr_ip_address_help"
msgstr "���̃��R�[�h�� IP �A�h���X���w�肵�Ă��������B[[base-dns.ptr_explain]]"



msgid "ptr_mask"
msgstr "�T�u�l�b�g�}�X�N"

msgid "ptr_mask_help"
msgstr "���̃��R�[�h�� IP �A�h���X�̃l�b�g���[�N�}�X�N���w�肵�Ă��������B[[base-dns.ptr_explain]]"

msgid "ptr_host_name"
msgstr "�z�X�g��"

msgid "ptr_host_name_help"
msgstr "���̃��R�[�h�̃z�X�g�����w�肵�Ă��������B[[base-dns.ptr_explain]]"

msgid "ptr_domain_name"
msgstr "�h���C���l�[��"

msgid "ptr_domain_name_help"
msgstr "���̃��R�[�h�̃h���C���l�[�����w�肵�Ă��������B[[base-dns.ptr_explain]]"

msgid "a_generate_ptr"
msgstr "�t�����A�h���X�iPTR�j���R�[�h����������"

msgid "ptr_generate_a"
msgstr "�������A�h���X�iA�j���R�[�h����������"

msgid "ptr_generate_a_help"
msgstr "���̃{�b�N�X���`�F�b�N����ƁA�w�肳�ꂽ IP �A�h���X����w�肳�ꂽ�z�X�g���{�h���C���l�[���ւ̑Ή��������������A�h���X���R�[�h�������I�ɐ�������܂��B"

msgid "ptr_subnet_mask_invalid"
msgstr "�w�肳�ꂽ�T�u�l�b�g�}�X�N�͕s���ł��B�T�u�l�b�g�}�X�N�́A0 �` 255 �̐��l�S�g���s���I�h�ŋ�؂��Ďw�肵�Ă��������B�i�w���F255.255.255.0�j"

msgid "ptr_subnet_mask_empty"
msgstr "���̃��R�[�h�p�̃T�u�l�b�g�}�X�N���w�肵�Ă��������B"

msgid "ptr_ip_address_invalid"
msgstr "�w�肳�ꂽ IP �A�h���X�͕s���ł��B[[base-dns.ipaddr_rule]]"

msgid "ptr_host_name_invalid"
msgstr "�w�肳�ꂽ�z�X�g���ɂ́A�s���ȕ������܂܂�Ă��܂��B"

msgid "ptr_domain_name_invalid"
msgstr "�w�肳�ꂽ�h���C���l�[���ɂ́A�s���ȕ������܂܂�Ă��܂��B"

msgid "ptr_ip_address_empty"
msgstr "���w��̃z�X�g���ƃh���C���l�[���ɑΉ����� IP �A�h���X����͂��Ă��������B[[base-dns.ipaddr_rule]]"

msgid "ptr_domain_name_empty"
msgstr "���w���IP �A�h���X�ɑΉ�����h���C���l�[������͂��Ă��������B"


# --- MX record

msgid "create_dns_recMX"
msgstr "[[base-dns.title]] - [[base-dns.mx_record]]�̒ǉ�"

msgid "modify_dns_recMX"
msgstr "[[base-dns.title]] - [[base-dns.mx_record]]�̏C��"

msgid "mx_host_name"
msgstr "�z�X�g��"

msgid "mx_explain"
msgstr "[[base-dns.mx_record]] �́A����̃z�X�g�ƃh���C���l�[���֓d�q���[����z�M���郁�[���T�[�o���w�肵�܂��B"

msgid "mx_host_name_help"
msgstr "���̃t�B�[���h�Ɏw�肷��z�X�g���̓d�q���[���́A[[base-dns.mx_target_server]]�t�B�[���h�Ɏw�肷�郁�[���T�[�o�ɂ��z�M����܂��B [[base-dns.mx_explain]]"

msgid "mx_domain_name"
msgstr "�h���C���l�[��"

msgid "mx_domain_name_empty"
msgstr "�u�h���C���l�[���v�t�B�[���h�͏ȗ��ł��܂���B"

msgid "mx_domain_name_help"
msgstr "���̃t�B�[���h�Ɏw�肷��h���C���l�[�����̓d�q���[���́A[[base-dns.mx_target_server]]�t�B�[���h�Ɏw�肷�郁�[���T�[�o�ɂ��z�M����܂��B[[base-dns.mx_explain]]"

msgid "mx_target_server"
msgstr "���[���T�[�o��"

msgid "mx_target_server_help"
msgstr "��L�̃z�X�g���ƃh���C���l�[�����̃��[����z�M���郁�[���T�[�o�̃z�X�g���{�h���C���l�[�����w�肵�Ă��������B[[base-dns.mx_explain]]"

msgid "mx_priority"
msgstr "�z�M�̗D��x"

msgid "mx_priority_help"
msgstr "��L�̃��[���T�[�o�ɑ΂��郁�[���z�M�̗D��x���w�肵�Ă��������B�z�M�̗D��x�́A���[���z�M�̂��߂Ƀ��[���T�[�o�֘A�������݂鏇�����K�肵�A����̃h���C���܂��̓l�b�g���[�N�ɑ΂��ĕ����� MX ���R�[�h���w�肷��ꍇ�ɂ̂ݗL���ł��B"

msgid "very_high"
msgstr "�ŗD��i20�j"

msgid "high"
msgstr "�D��i30�j"

msgid "low"
msgstr "��D��i40�j"

msgid "very_low"
msgstr "�Œ�D��i50�j"

msgid "mx_dir_very_high"
msgstr "���[�� (�ŗD��)"

msgid "mx_dir_high"	
msgstr "���[�� (�D��)"

msgid "mx_dir_low"	
msgstr "���[�� (��D��)"

msgid "mx_dir_very_low"
msgstr "���[�� (�Œ�D��)"

msgid "mx_host_name_invalid"
msgstr "�w�肳�ꂽ�z�X�g���ɂ́A�s���ȕ������܂܂�Ă��܂��B"

msgid "mx_domain_name_invalid"
msgstr "�w�肳�ꂽ�h���C���l�[���ɂ́A�s���ȕ������܂܂�Ă��܂��B"

msgid "mx_target_server_invalid"
msgstr "�w�肳�ꂽ�����ȃh���C���l�[���ɂ́A�s���ȕ������܂܂�Ă��܂��B"

msgid "mx_target_server_empty"
msgstr "���[���T�[�o�̃z�X�g���{�h���C���l�[�����w�肵�Ă��������B"


# --- CNAME record

msgid "create_dns_recCNAME"
msgstr "[[base-dns.title]] - [[base-dns.cname_record]]�̒ǉ�"

msgid "modify_dns_recCNAME"
msgstr "[[base-dns.title]] - [[base-dns.cname_record]]�̏C��"

msgid "cname_explain"
msgstr "�G�C���A�X���R�[�h�́A��̃h���C���l�[������ʂ̃h���C���l�[���ւ̕ϊ��f�[�^��񋟂��܂��B"

msgid "cname_host_name"
msgstr "�G�C���A�X�z�X�g��"

msgid "cname_host_name_help"
msgstr "���z�X�g���܂��͎��h���C���l�[���ɑΉ�����G�C���A�X�̃z�X�g�����w�肵�Ă��������B[[base-dns.cname_explain]]"

msgid "cname_domain_name"
msgstr "�G�C���A�X�h���C���l�[��"

msgid "cname_domain_name_help"
msgstr "���z�X�g���܂��͎��h���C���l�[���ɑΉ�����G�C���A�X�̃h���C���l�[�����w�肵�Ă��������B[[base-dns.cname_explain]]"

msgid "cname_host_target"
msgstr "���z�X�g��"

msgid "cname_host_target_help"
msgstr "���� �i���K�j �̃z�X�g�����w�肵�Ă��������B[[base-dns.cname_explain]]"

msgid "cname_domain_target"
msgstr "���h���C���l�[��"

msgid "cname_domain_target_help"
msgstr "���� �i���K�j �̃h���C���l�[�����w�肵�Ă��������B[[base-dns.cname_explain]]"



# --- SOA

msgid "create_soa"
msgstr "SOA ���R�[�h�̒ǉ�"

msgid "modify_soa"
msgstr "[[base-dns.title]] - SOA ���R�[�h�̏C��"

msgid "domain_soa"
msgstr "�K�p�h���C��"

msgid "domain_soa_help"
msgstr "���� SOA �iStart of Authority�j���R�[�h���K�p�����h���C���ł��B"

msgid "network_soa"
msgstr "�K�p�l�b�g���[�N"

msgid "network_soa_help"
msgstr "���� SOA �iStart of Authority�j���R�[�h���K�p�����l�b�g���[�N�ł��B"

msgid "primary_dns"
msgstr "�v���C�}���l�[���T�[�o�iNS�j"

msgid "primary_dns_help"
msgstr "�K�p�h���C���i�܂��̓l�b�g���[�N�j�ɑΉ�����v���C�}���l�[���T�[�o�̃h���C���l�[������͂��Ă��������B"

msgid "secondary_dns"
msgstr "�Z�J���_���l�[���T�[�o�iNS�j"

msgid "secondary_dns_help"
msgstr "�K�p�h���C���i�܂��̓l�b�g���[�N�j�ɑΉ�����Z�J���_���l�[���T�[�o�̃h���C���l�[������͂��Ă��������B"

msgid "domain_admin"
msgstr "DNS �Ǘ��҂̓d�q���[���A�h���X"

msgid "domain_admin_rule"
msgstr "�d�q���[���A�h���X�𐳂����`���œ��͂��Ă��������B���̃t�B�[���h�ɕ\�������f�t�H���g�l�́A�uDNS�̐ݒ�v�e�[�u���́u�ڍׁv�Z�N�V�����Őݒ�ł��܂��B�i�w���F sugisaki@sun.co.jp�j"

msgid "domain_admin_help"
msgstr "�����Ɏw�肷��d�q���[���A�h���X�́A����ǉ������h���C������уl�b�g���[�N�̊Ǘ��҂̘A����Ƃ��Ďg���܂��B[[base-dns.domain_admin_rule]]"

msgid "domain_admin_invalid"
msgstr "[[VAR.invalidValue] �́A[[base-dns.domain_admin]]�̒l�Ƃ��Ă͕s���ł��B[[base-dns.domain_admin_rule]]"

msgid "domain_admin_empty"
msgstr "[[base-dns.domain_admin]] �͕K�{�ł��B[[base-dns.domain_admin_rule]]"

msgid "refresh"
msgstr "���t���b�V���Ԋu�i�b�j"

msgid "refresh_rule"
msgstr "1 �` 4096000 �̐�������͂��Ă��������B���̃t�B�[���h�ɕ\�������f�t�H���g�l�́A�uDNS�̐ݒ�v�e�[�u���́u�ڍׁv�Z�N�V�����Őݒ�ł��܂��B"

msgid "refresh_help"
msgstr "�����Ɏw�肷�郊�t���b�V���Ԋu�́A����ǉ������h���C������уl�b�g���[�N�Ŏg���܂��B���t���b�V���Ԋu�Ƃ́A�Z�J���_���h���C���l�[���T�[�o���v���C�}���h���C���l�[���T�[�o�ƃ��R�[�h�̓�����}�鎞�ԊԊu�ł��B[[base-dns.refresh_rule]]"

msgid "refresh_invalid"
msgstr "[[VAR.invalidValue] �́A[[base-dns.refresh]]�ɂ͎w��ł��܂���B  [[base-dns.refresh_rule]]"

msgid "refresh_empty"
msgstr "[[base-dns.refresh]] �͕K�{�ł��B[[base-dns.refresh_rule]]"

msgid "retry"
msgstr "���g���C�Ԋu�i�b�j"

msgid "retry_rule"
msgstr "1 �` 4096000 �̐�������͂��Ă��������B���̃t�B�[���h�ɕ\�������f�t�H���g�l�́A�uDNS�̐ݒ�v�e�[�u���́u�ڍׁv�Z�N�V�����Őݒ�ł��܂��B"

msgid "retry_help"
msgstr "�����Ɏw�肷�郊�g���C�Ԋu�́A����ǉ������h���C������уl�b�g���[�N�Ŏg���܂��B���g���C�Ԋu�Ƃ́A���炩�̗��R�ŃZ�J���_���h���C���l�[���T�[�o���v���C�}���h���C���l�[���T�[�o�̃��R�[�h�Ɠ��������Ȃ��ꍇ�ɁA�J��Ԃ����R�[�h�̓��������s���鎞�ԊԊu�ł��B[[base-dns.retry_rule]]"

msgid "retry_invalid"
msgstr "[[VAR.invalidValue] �́A[[base-dns.retry]]�ɂ͎w��ł��܂���B[[base-dns.retry_rule]]"

msgid "retry_empty"
msgstr "[[base-dns.retry]] �͕K�{�ł��B[[base-dns.retry_rule]]"

msgid "expire"
msgstr "�����Ԋu�i�b�j"

msgid "expire_rule"
msgstr "1 �` 4096000 �̊Ԃ̐�������͂��Ă��������B���̃t�B�[���h�ɕ\�������f�t�H���g�l�́A�uDNS�̐ݒ�v�e�[�u���́u�ڍׁv�Z�N�V�����Őݒ�ł��܂��B"

msgid "expire_help"
msgstr "�V�����h���C����l�b�g���[�N�� DNS ���R�[�h�ɒǉ�����ۂɃf�t�H���g�Ƃ��Ďg���鎸���Ԋu���w�肵�Ă��������B���炩�̗��R�ŃZ�J���_���h���C���l�[���T�[�o���v���C�}���h���C���l�[���T�[�o�ƃ��R�[�h�𓯊��ł����A�J��Ԃ����������݂�ꍇ�A�����Ԋu�i�b�j���o�߂��Ă������ł��Ȃ��ƁA�Z�J���_���h���C���l�[���T�[�o�͎����̎��h���C�����͂����L���ł͂Ȃ��Ɣ��f���A�v���C�}���h���C���l�[���T�[�o�֍ēx�A���ł���܂Ńh���C�����̒񋟂��~���܂��B[[base-dns.expire_rule]]"

msgid "expire_invalid"
msgstr "[[VAR.invalidValue] �́A[[base-dns.expire]] �ɂ͎w��ł��܂���B[[base-dns.expire_rule]]"

msgid "expire_empty"
msgstr "[[base-dns.expire]] ���w�肵�Ă��������B[[base-dns.expire_rule]]"


msgid "ttl"
msgstr "TTL �Ԋu�i�b�j"
msgid "ttl_rule"
msgstr "1 �` 4096000 �̐�������͂��Ă��������B���̃t�B�[���h�ɕ\�������f�t�H���g�l�́A�uDNS�̐ݒ�v�e�[�u���́u�ڍׁv�Z�N�V�����Őݒ�ł��܂��B"

msgid "ttl_help"
msgstr "�V�����h���C����l�b�g���[�N�� DNS ���R�[�h�ɒǉ�����ۂɃf�t�H���g�Ƃ��Ďg���� TTL �Ԋu���w�肵�Ă��������BTTL �Ԋu�Ƃ́A���̃h���C���l�[���T�[�o�����̃h���C���l�[���T�[�o����擾�����h���C�������L���b�V���ɕۊǂ��A���̃h���C���l�[���T�[�o�ɍĂјA�����Ȃ��܂܂��̏�񂪗L���ł���Ƒz�肷����Ԃł��B[[base-dns.ttl_rule]]"

msgid "ttl_invalid"
msgstr "[[VAR.invalidValue] �́A[[base-dns.ttl]]�ɂ͎w��ł��܂���B[[base-dns.ttl_rule]]"

msgid "ttl_empty"
msgstr "[[base-dns.ttl]]���w�肵�Ă��������B[[base-dns.ttl_rule]]"



# ---- Secondary Services

msgid "secondary_service_button"
msgstr "�Z�J���_���T�[�r�X��ݒ�"

msgid "secondary_service_button_help"
msgstr "�h���C����l�b�g���[�N�ɑ΂���Z�J���_�� DNS �T�[�r�X���Ǘ��ł��܂��B"

msgid "sec_list"
msgstr "[[base-dns.title]] - �Z�J���_���T�[�r�X�̃��X�g"

msgid "create_slave_rec"
msgstr "[[base-dns.title]] - �Z�J���_���T�[�r�X�̒ǉ�"

msgid "modify_slave_rec"
msgstr "[[base-dns.title]] - �Z�J���_���T�[�r�X�̏C��"

msgid "slave_domain_but"
msgstr "�h���C��"

msgid "slave_domain"
msgstr "�h���C���l�[��"

msgid "slave_domain_help"
msgstr "�Z�J���_���h���C���l�[���T�[�r�X�̒񋟐�h���C�����w�肵�Ă��������B"

msgid "slave_dom_masters"
msgstr "�v���C�}�� DNS �T�[�o�� IP �A�h���X"

msgid "slave_dom_masters_help"
msgstr "���̃h���C���̃v���C�}���h���C���l�[���T�[�o�� IP �A�h���X����͂��Ă��������B"

msgid "slave_network_but"
msgstr "�l�b�g���[�N"

msgid "slave_ipaddr"
msgstr "�l�b�g���[�N"

msgid "slave_ipaddr_help"
msgstr "�Z�J���_���h���C���l�[���T�[�r�X�̒񋟐�l�b�g���[�N�� IP �A�h���X����͂��Ă��������B"

msgid "slave_netmask"
msgstr "�l�b�g���[�N�̃T�u�l�b�g�}�X�N"

msgid "slave_netmask_help"
msgstr "�Z�J���_���h���C���l�[���T�[�r�X�̒񋟐�l�b�g���[�N�̃T�u�l�b�g�}�X�N����͂��Ă��������B"

msgid "slave_net_masters"
msgstr "�v���C�}�� DNS �T�[�o�� IP �A�h���X"

msgid "slave_net_masters_help"
msgstr "���̃h���C���̃v���C�}���h���C���l�[���T�[�o�� IP �A�h���X����͂��Ă��������B"

msgid "create_slave_rec"
msgstr "�Z�J���_���T�[�r�X�̒ǉ�"

msgid "sec_authority"
msgstr "�Z�J���_���T�[�r�X"

msgid "sec_authority_help"
msgstr "���̃T�[�o���Z�J���_���h���C���l�[���T�[�r�X��񋟂���h���C���i�܂��̓l�b�g���[�N�j�ł��B"

msgid "sec_primaries"
msgstr "�v���C�}�� DNS �T�[�o"

msgid "sec_primaries_help"
msgstr "���̃h���C���i�܂��̓l�b�g���[�N�j�̃v���C�}���h���C���l�[���T�[�o�� IP �A�h���X�ł��B"

msgid "recordlist_action"
msgstr "�ڍ�"

msgid "recordlist_action_help"
msgstr "���M�A�C�R�����N���b�N����ƁA���̃��R�[�h���C���ł��܂��B�S�~���A�C�R�����N���b�N����ƁA���̃��R�[�h���폜�ł��܂��B"

# end of sentence is completed

msgid "confirm_removal_of_sec"
msgstr "[[VAR.rec]] �Ƃ����Z�J���_���h���C���l�[���T�[�r�X���R�[�h���폜���Ă�낵���ł����H"

msgid "slave_ipaddr_invalid"
msgstr "�w�肳�ꂽ IP �A�h���X�͕s���ł��B"

msgid "slave_netmask_invalid"
msgstr "�w�肳�ꂽ�l�b�g�}�X�N�͕s���ł��B�l�b�g�}�X�N�́A255.255.255.0 �̌`���œ��͂��Ă��������B"

msgid "slave_net_masters_invalid"
msgstr "�w�肳�ꂽ�v���C�}�� DNS �T�[�o�� IP �A�h���X�͕s���ł��B"

msgid "slave_domain_invalid"
msgstr "�w�肳�ꂽ�h���C���l�[���͕s���ł��B"

msgid "slave_dom_masters_invalid"
msgstr "�w�肳�ꂽ�v���C�}�� DNS �T�[�o�� IP �A�h���X�͕s���ł��B"

msgid "apply_changes"
msgstr "�ύX��K�p"

msgid "apply_changes_help"
msgstr "���̃{�^�����N���b�N����ƁADNS ���R�[�h�ɉ������ύX���K�p����܂��BDNS ���R�[�h���C�����Ă��A���̃{�^�����N���b�N���Ȃ�����V�����ݒ�͗L���ɂȂ�܂���B"

msgid "apply_changes_disabledHelp"
msgstr "DNS ���R�[�h���ǉ��A�C������Ă��Ȃ����߁A���̃{�^���͌��ݖ����ł��BDNS ���R�[�h��ǉ��A�C�����Ă��炱�̃{�^�����N���b�N����ƁA�V�����ݒ肪�L���ɂȂ�܂��B "


# ---- Active monitor

msgid "amDNSNameTag"
msgstr "DNS �T�[�o"

msgid "amDetailsTitle"
msgstr "DNS �T�[�o�̏ڍ�"

msgid "amNotRunning"
msgstr "�h���C���l�[���T�[�o�͓��삵�Ă��炸�A�N�����邱�Ƃ��ł��܂���ł����B[[base-apache.amAdmservNameTag]] �ŁA�h���C���l�[���T�[�o����U�I�t�ɂ��āu�ۑ��v�{�^�����N���b�N���Ă���A������x�I���ɂ��āu�ۑ��v�{�^�����N���b�N���A��肪�������邩�ǂ������������������B�h���C���l�[���T�[�o���������N�����Ȃ��ꍇ�ɂ́A[[base-alpine.serverconfig]] �� [[base-power.power]] ���j���[�ɂ���u[[base-power.reboot]]�v�{�^�����N���b�N���āA�T�[�o�{�̂��ċN�����Ă��������B����ł��h���C���l�[���T�[�o���N�����Ȃ��ꍇ�ɂ́A[[base-sauce-basic.techSupportURL]] �ɂ���e�N�j�J���T�|�[�g�T�[�r�X�������p���������B"

msgid "amStatusOK"
msgstr "�h���C���l�[���T�[�o�͐���ɓ��삵�Ă��܂��B"


# --- Drop-down menu

msgid "select_a_domain"	
msgstr "�h���C����I��..."

msgid "select_a_network"
msgstr "�l�b�g���[�N��I��..."

msgid "no_records"	
msgstr "�h���C���܂��̓l�b�g���[�N����������܂���B"

msgid "subdom_host_name"
msgstr "�T�u�h���C���l�[��"

msgid "subdom_host_name_help"
msgstr "�T�u�h���C���l�[�����w�肵�Ă��������B�Ⴆ�΁Aremote.ourcompany.com �Ƃ����T�u�h���C���̌������Ϗ�����ɂ́A���̃T�[�o�� ourcompany.com �Ƃ����h���C���ɑ΂��錠���������Ă��Ȃ���΂Ȃ�܂���B���̃t�B�[���h�ɂ́A�T�u�h���C���l�[���ł��� remote �݂̂��w�肵�܂��B" 

msgid "subdom_domain_name"
msgstr "�e�h���C���l�[��"
msgid "subdom_domain_name_help"
msgstr "�e�h���C���l�[����I�����Ă��������B�Ⴆ�΁Aremote.ourcompany.com �Ƃ����T�u�h���C���̌������Ϗ�����ꍇ�ɂ́Aourcompany.com ��I�����܂��B"

msgid "subdom_nameservers"
msgstr "�l�[���T�[�o"

msgid "subdom_nameservers_help"
msgstr "�w�肳�ꂽ�T�u�h���C���ɑ΂��錠�������l�[���T�[�o�� IP �A�h���X���w�肵�Ă��������B�����w�肷��ꍇ�ɂ́A�R���}�ŋ�؂��Ă��������B���Ȃ��Ƃ��P�͎w�肷��K�v������܂��B" 

msgid "subdom_nameservers_invalid"
msgstr "[[base-dns.subdom_nameservers]]�̃��X�g�ɕs���ȕ����܂��̓z�X�g�����܂܂�Ă��܂��B"

msgid "subdom_nameservers_empty"
msgstr "���̃T�u�h���C���ɑ΂��錠�������� DNS �T�[�o�����Ȃ��Ƃ��P�͎w�肵�Ă��������B"

msgid "subnet_ip_address"
msgstr "�T�u�l�b�g�� IP �A�h���X"

msgid "subnet_ip_address_help"
msgstr "�ʂ� DNS �T�[�o�Ɍ������Ϗ��������T�u�l�b�g��� IP �A�h���X���w�肵�Ă��������B"  

msgid "subnet_mask"
msgstr "�T�u�l�b�g�̃l�b�g���[�N�}�X�N"

msgid "subnet_mask_help"
msgstr "�T�u�l�b�g�̃l�b�g���[�N�}�X�N���w�肵�Ă��������B" 

msgid "subnet_nameservers"
msgstr "�l�[���T�[�o"

msgid "subnet_nameservers_help"
msgstr "�w�肳�ꂽ�T�u�l�b�g�ɑ΂��錠�������l�[���T�[�o�� IP �A�h���X���w�肵�Ă��������B�����w�肷��ꍇ�ɂ́A�R���}�ŋ�؂��Ă��������B���Ȃ��Ƃ��P�͎w�肷��K�v������܂��B" 

msgid "subdnet_nameservers_invalid"
msgstr "[[base-dns.subnet_nameservers]] �̃��X�g�ɕs���ȕ����܂��̓z�X�g�����܂܂�Ă��܂��B"

msgid "subnet_nameservers_empty"
msgstr "���̃T�u�l�b�g�ɑ΂��錠�������� DNS �T�[�o�����Ȃ��Ƃ��P�͎w�肵�Ă��������B"

msgid "create_dns_rec"
msgstr "DNS ���R�[�h��ǉ�" 

msgid "modify_dns_rec"	
msgstr "[[base-dns.title]] - DNS ���R�[�h���C��" 

msgid "authority"
msgstr "����"

msgid "authority_help"
msgstr "DNS �����̓h���C���ƃl�b�g���[�N�ł��B"

msgid "subnet_dir"
msgstr "�T�u�l�b�g"

msgid "subdom_dir"
msgstr "�T�u�h���C��"

msgid "subnet"
msgstr "�T�u�l�b�g�̌����Ϗ�"

msgid "subdom"
msgstr "�T�u�h���C���̌����Ϗ�"

msgid "modify_dns_recSUBDOM"
msgstr "[[base-dns.title]] - �T�u�h���C���̌����Ϗ����C��"

msgid "create_dns_recSUBDOM"
msgstr "�T�u�h���C���̌����Ϗ���ǉ�"

msgid "modify_dns_recSUBNET"
msgstr "[[base-dns.title]] - �T�u�l�b�g�̌����Ϗ����C��"

msgid "create_dns_recSUBNET"
msgstr "�T�u�l�b�g�̌����Ϗ���ǉ�"

msgid "add_secondary"
msgstr "�Z�J���_���T�[�r�X��ǉ�..."

msgid "add_secondary_forward"
msgstr "�h���C��"

msgid "add_secondary_network"
msgstr "�l�b�g���[�N"


# --- Lots of error messages

msgid "cname_domain_name_invalid"
msgstr "�w�肳�ꂽ�h���C���l�[���ɂ́A�s���ȕ������܂܂�Ă��܂��B"

msgid "cname_domain_target_invalid"
msgstr "�w�肳�ꂽ�h���C���l�[���ɂ́A�s���ȕ������܂܂�Ă��܂��B"

msgid "cname_host_target_invalid"
msgstr "�w�肳�ꂽ�z�X�g���ɂ́A�s���ȕ������܂܂�Ă��܂��B"

msgid "cname_domain_target_invalid"
msgstr "�w�肳�ꂽ�h���C���l�[���ɂ́A�s���ȕ������܂܂�Ă��܂��B"

msgid "subdom_host_name_invalid"
msgstr "�w�肳�ꂽ�z�X�g���ɂ́A�s���ȕ������܂܂�Ă��܂��B"

msgid "subdom_host_name_empty"
msgstr "�����[�g�� DNS �T�[�o�Ɍ����Ϗ��������T�u�h���C�������w�肵�Ă��������B"

msgid "subdom_domain_name_invalid"
msgstr "�w�肳�ꂽ�h���C���l�[���ɂ́A�s���ȕ������܂܂�Ă��܂��B"

msgid "subdom_namerservers_invalid"
msgstr "�v���C�}�� DNS �T�[�o�̃h���C���l�[�����s���ł��B"

msgid "subnet_subnet_mask_invalid"
msgstr "�w�肳�ꂽ�T�u�l�b�g�}�X�N�͕s���ł��B�T�u�l�b�g�}�X�N�́A255.255.255.0�̌`���œ��͂��Ă��������B"

msgid "subnet_ip_address_invalid"
msgstr "�w�肳�ꂽ IP �A�h���X�͕s���ł��B "

msgid "subnet_ip_address_empty"
msgstr "�����Ϗ������T�u�l�b�g�̃����o�[�� IP �A�h���X���w�肵�Ă��������B"

msgid "subnet_nameservers_invalid"
msgstr "�v���C�}�� DNS �T�[�o�̃h���C���l�[�����s���ł��B"

msgid "subnet_nameservers_empty"
msgstr "�v���C�}�� DNS �T�[�o�̃h���C���l�[�����w�肵�Ă��������B"

msgid "primary_dns_invalid"
msgstr "�w�肳�ꂽ�z�X�g���ɂ́A�s���ȕ������܂܂�Ă��܂��B"

msgid "secondary_dns_invalid"
msgstr "�Z�J���_���l�[���T�[�o�̃z�X�g���ɁA�s���ȕ������܂܂�Ă��܂��B"

msgid "domain_admin_invalid"
msgstr "�w�肳�ꂽ�d�q���[���A�h���X�͕s���ł��B"

msgid "refresh_invalid"
msgstr "[[VAR.invalidValue]] �́A[[base-dns.default_refresh]]�ɂ͎w��ł��܂���B[[base-dns.default_refresh_rule]]"

msgid "retry_invalid"
msgstr "[[VAR.invalidValue]] �́A[[base-dns.default_retry]]�ɂ͎w��ł��܂���B  [[base-dns.default_retry_rule]]"

msgid "expire_invalid"
msgstr "[[VAR.invalidValue]] �́A[[base-dns.default_expire]]�ɂ͎w��ł��܂���B  [[base-dns.default_expire_rule]]"

msgid "cname_domain_name_empty"
msgstr "�G�C���A�X�h���C���l�[�����w�肵�Ă��������B"

msgid "cname_domain_target_empty"
msgstr "�G�C���A�X�z�X�g���ƃh���C���l�[���ɑΉ�������h���C���l�[�����w�肵�Ă��������B"

msgid "slave_domain_empty"
msgstr "���̃T�[�o���Z�J���_�� DNS �T�[�o�ƂȂ�h���C���l�[�����w�肵�Ă��������B"

msgid "slave_dom_masters_empty"
msgstr "�h���C���l�[���̃v���C�}�� DNS �T�[�o�� IP �A�h���X���w�肵�Ă��������B"

msgid "slave_ipaddr_empty"
msgstr "�v���C�}�� DNS �T�[�o�ɂ���Ē񋟂����l�b�g���[�N��� IP �A�h���X���w�肵�Ă��������B"

msgid "slave_net_masters_empty"
msgstr "�l�b�g���[�N�̃v���C�}�� DNS �T�[�o�� IP �A�h���X���w�肵�Ă��������B"

msgid "slave_netmask_empty"
msgstr "�w�肳�ꂽ�l�b�g���[�N IP �A�h���X�Ƌ��ɁA�v���C�}�� DNS �T�[�o�����������l�b�g���[�N�̃l�b�g���[�N�}�X�N���A255.255.255.0 �̌`���Ŏw�肵�Ă��������B"

msgid "cname_host_name_empty"
msgstr "���̃��R�[�h�̃z�X�g�����w�肵�Ă��������B"

msgid "cname_host_name_invalid"
msgstr "�w�肳�ꂽ�z�X�g���ɂ́A�s���ȕ������܂܂�Ă��܂��B"

msgid "parent_network"
msgstr "�e�l�b�g���[�N"

msgid "parent_network_help"
msgstr "���̃T�[�o�����������e�l�b�g���[�N�ŁA�w�肳�ꂽ�T�u�l�b�g��ɂ���S�Ă� IP �A�h���X�́A���̐e�l�b�g���[�N�ɑ�����K�v������܂��B"

msgid "invalidDuplicate"
msgstr "����̃h���C���l�[�����R�[�h�����ɑ��݂��܂��B"

msgid "named-did-not-start"
msgstr "�l�[���T�[�o (DNS) ���������ċN�����܂���ł����B"

msgid "invalid-authority"
msgstr "DNS ���R�[�h�ɕK�v�s���ȏ�񂪌��@���Ă��܂��B"

msgid "SOA-already-exists-for-zone"
msgstr "���̃]�[���p�� SOA (Start Of Authority) ���R�[�h�͊��ɑ��݂��܂��B"

msgid "secondaryZoneOverlap"
msgstr "���̃��R�[�h�́A�����̃Z�J���_���l�b�g���[�N�T�[�r�X�Ɩ������܂��B"

msgid "secondaryZoneDuplicate"
msgstr "���̃��R�[�h�́A�����̃Z�J���_���l�b�g���[�N�T�[�r�X�Ɩ������܂��B"

msgid "primaryZoneDuplicate"
msgstr "���̃��R�[�h�́A�����̃v���C�}���l�b�g���[�N�T�[�r�X�Ɩ������܂��B"

msgid "primaryZoneOverlap"
msgstr "���̃��R�[�h�́A�����̃v���C�}���l�b�g���[�N�T�[�r�X�Ɩ������܂��B"

msgid ""
msgstr ""

msgid ""
msgstr ""

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             locale/zh_CN/                                                                                       0042755 0000000 0000156 00000000000 07727667110 011147  5                                                                                                    ustar   root                                                                                                                                                                                                                                                   locale/zh_CN/dns.po                                                                                 0100644 0000000 0000156 00000052317 07372633002 012263  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   # --- Menu

msgid "dns"
msgstr "DNS"

msgid "modifyDNS"
msgstr "����ϵͳ (DNS) ����"

msgid "dns_help"	
msgstr "[[base-dns.modifyDNS]]���ڴ˴����ġ�"


# --- Common

msgid "basic"
msgstr "����"

msgid "advanced"	
msgstr "�߼�"

msgid "basic_help"
msgstr "���� DNS ���������ÿ��ڴ˴����á�"

msgid "advanced_help"
msgstr "���ݸ�ʽ����ȫ���ƺͷ�����ȱʡֵ֮��ĸ߼� DNS ���������ÿ��ڴ˴����á�"


# --- Basic settings

msgid "enabled"
msgstr "���÷�����"

msgid "enabled_help"
msgstr "�򿪻�ر�����ϵͳ (DNS) ���������ܡ��򿪴˹���ʹ�˷������豸�����Լ�����ͻ����ı����������������������������ı���������������ת��Ϊ����ʽ�� IP ��ַ��Ҳ�ɽ�����ʽ IP ��ַתΪΪ�ı�����������������"


# --- Advanced settings

msgid "soa_defaults"
msgstr "Ȩ������ (SOA) ȱʡֵ"

msgid "soa_defaults_help"
msgstr "��Щ��������������¼ʱʹ�õ�ȱʡֵ��"

msgid "admin_email"
msgstr "ȱʡ DNS ����Ա�����ʼ���ַ"

msgid "admin_email_rule"
msgstr "�������ʽ��ȷ�ĵ����ʼ���ַ�����磬user@cobalt.com ������Ч�����롣"

msgid "admin_email_help"
msgstr "���������������������Ĺ�����ϵ�˵����ʼ���ַ��ȱʡֵ�� [[base-dns.admin_email_rule]]"

msgid "admin_email_invalid"
msgstr "�Բ���[[VAR.invalidValue] ��[[base-dns.admin_email]]����Чֵ�� [[base-dns.admin_email_rule]]"

msgid "default_refresh"
msgstr "ȱʡˢ�¼�����룩"

msgid "default_refresh_rule"
msgstr "������ 1 �� 4096000 ֮���������ȱʡֵ�� 10800��"

msgid "default_refresh_help"	
msgstr "����������������������ˢ�¼��ȱʡֵ����ֵ�Ǹ�����������������ʹ���¼������������������ͬ����ʱ������[[base-dns.default_refresh_rule]]"

msgid "default_refresh_invalid"
msgstr "�Բ���[[VAR.invalidValue] ��[[base-dns.default_refresh]]����Чֵ�� [[base-dns.default_refresh_rule]]"

msgid "default_refresh_empty"	
msgstr "�Բ�����û��Ϊ[[base-dns.default_refresh]]����ֵ�� [[base-dns.default_refresh_rule]]"

msgid "default_retry"	
msgstr "ȱʡ���Լ�����룩"

msgid "default_retry_rule"
msgstr "������ 1 �� 4096000 ֮���������ȱʡֵ�� 3600��"

msgid "default_retry_help"
msgstr "�������������������������Լ��ȱʡֵ���������ĳ��ԭ�򣬸��������������޷�ͨ����������������ȡ����ϵʹ��¼ͬ������ֵ�Ǹ�����������������������ϵ��������������ʱ������[[base-dns.default_retry_rule]]"

msgid "default_retry_invalid"
msgstr "�Բ���[[VAR.invalidValue] ��[[base-dns.default_retry]]����Чֵ�� [[base-dns.default_retry_rule]]"

msgid "default_retry_empty"	
msgstr "�Բ�����û��Ϊ[[base-dns.default_retry]]����ֵ��[[base-dns.default_retry_rule]]"

msgid "default_expire"	
msgstr "ȱʡ���ڼ�����룩"

msgid "default_expire_rule"
msgstr "������ 1 �� 4096000 ֮���������ȱʡֵ�� 604800��"

msgid "default_expire_help"
msgstr "���������������������ĵ��ڼ��ȱʡֵ���������ĳ��ԭ�򣬸��������������޷�ͨ����������������ȡ����ϵ��ʹ��¼ͬ������ֵ�Ǹ�������������������Ϊ��������Ϣ��Ч��ֹͣ�ṩ����Ϣ�ļ����ֱ���������������ܹ��������ӡ� [[base-dns.default_expire_rule]]"

msgid "default_expire_invalid"
msgstr "�Բ���[[VAR.invalidValue] ��[[base-dns.default_expire]]����Чֵ�� [[base-dns.default_expire_rule]]"

msgid "default_expire_empty"
msgstr "�Բ�����û��Ϊ[[base-dns.default_expire]]����ֵ�� [[base-dns.default_expire_rule]]"

msgid "default_ttl"	
msgstr "ȱʡ����ʱ�������룩"

msgid "default_ttl_rule"
msgstr "������ 1 �� 4096000 ֮���������ȱʡֵ�� 86400��"

msgid "default_ttl_help"	
msgstr "��������������������������ʱ����ȱʡֵ����ֵ�Ǳ�ʾһ��ʱ�Σ��ڴ�ʱ���ڣ��������������������ٻ���Ӵ���������������������Ϣ�����Ҽٶ�����Ϣ��Ч����������������������˶ԡ�[[base-dns.default_ttl_rule]]"

msgid "default_ttl_invalid"
msgstr "�Բ���[[VAR.invalidValue] ��[[base-dns.default_ttl]]����Чֵ�� [[base-dns.default_ttl_rule]]"

msgid "default_ttl_empty"
msgstr "�Բ�����û��Ϊ[[base-dns.default_ttl]]����ֵ�� [[base-dns.default_ttl_rule]]"

msgid "global_settings"
msgstr "����������"

msgid "global_settings_help"
msgstr "��Щ��������������ȱʡֵ��"

msgid "forwarders"	
msgstr "ת��������"

msgid "forwarders_help"
msgstr "����ת�������������� IP ��ַ�����������������������ƶ��޷�ֱ�ӷ��ʸ�����������ʱ����ʹ��ת��������������[[base-dns.forwarders_rule]]"

msgid "forwarders_rule"
msgstr "������ 0 �� 255 ֮���ĸ��������֣��þ����������磬192.168.1.1 ������Ч�����롣"

msgid "forwarders_invalid"
msgstr "�Բ���[[VAR.invalidValue]]��[[base-dns.forwarders]]����Чֵ�� [[base-dns.forwarders_rule]]"

msgid "zone_xfer_ipaddr"
msgstr "�� IP ��ַ�������������"

msgid "zone_xfer_ipaddr_help"
msgstr "��������ͨ�����������ش�����������ά�������м�¼�� IP ��ַ����������������ʹ����������ʹ���ǵļ�¼����������������ͬ����ȱʡֵ�ǽ����ֶ����գ���ʵ�ֲ������Ƶ������䡣"

msgid "zone_xfer_ipaddr_invalid"
msgstr "�Բ���[[VAR.invalidValue]]��[[base-dns.zone_xfer_ipaddr]]����Чֵ��"

msgid "zone_format"	
msgstr "�����ļ���ʽ"

msgid "zone_format_help"	
msgstr "ѡ��һ�������ļ���ʽ�����ڰ��������ط�������������ݵķǰ�λ�ֽڱ߽������������� RFC2317 �Ǳ�׼��ʽ��DION �� OCN-JT �����á�"

msgid "rfc2317"
msgstr "RFC2317"

msgid "dion"
msgstr "DION"

msgid "ocn-jt"
msgstr "OCN-JT"

# --- Record types (reused)

msgid "a_record"
msgstr "�����ַ (A) ��¼"

msgid "ptr_record"
msgstr "�����ַ (PTR) ��¼"

msgid "cname_record"
msgstr "���� (CNAME) ��¼"

msgid "mx_record"
msgstr "�ʼ������� (MX) ��¼"

msgid "records_title"
msgstr "�����á� "


# --- Primary services

msgid "primary_service_button"
msgstr "�༭������"

msgid "primary_service_button_help"
msgstr "�����˷�������ע��ҪΪ���ṩ������������� DNS ��¼���� DNS ����Ҳ��Ϊ����Ҫ DNS������"

msgid "dnsSetting"	
msgstr "�������б�"

msgid "select_dom"
msgstr "ѡ����..."

msgid "select_net"	
msgstr "ѡ������..."

	# drop down menu
msgid "add_record"
msgstr "���Ӽ�¼..."

msgid "edit_soa"
msgstr "�޸� SOA"

msgid "edit_soa_help"
msgstr "�޸���ѡ�������Ȩ�޵�Ȩ�޼�¼��ʼ��"

msgid "confirm_delall"
msgstr "�Ƿ�ȷ��Ҫɾ����ʾ��ȫ�� DNS ��¼��"

msgid "del_records"
msgstr "ɾ����¼"

msgid "del_records_help"
msgstr "�������ɾ��������ʾ�� DNS ��¼���⽫ɾ����ҳ��ʾ�����м�¼�������޷�������"

msgid "source"
msgstr "��ѯ"

msgid "source_help"
msgstr "����ֱ�������������������Ĳ�ѯ�����⡣"

msgid "direction"
msgstr "��¼����"

msgid "direction_help"
msgstr "����ʹ�Դ˷������Ĳ�ѯ�����Դ˷���������Ӧ������ļ�¼���͡�"

msgid "resolution"
msgstr "��Ӧ"

msgid "resolution_help"
msgstr "����ֱ�ӴӴ��������������ص���Ӧ��Ӧ��"

msgid "listAction"
msgstr "����"

msgid "listAction_help"
msgstr "��Щ�������޸Ļ�ɾ��������¼�İ�ť��"

msgid "confirm_removal"
msgstr "�Ƿ�ȷ��Ҫɾ����¼[[VAR.rec]]��"

	# general IP address rule
msgid "ipaddr_rule"
msgstr "IP ��ַ�� 0 �� 255 ֮���þ��������ĸ�����ϵ�С����磬192.168.1.1 ������Ч�����롣"





# --- A record

msgid "create_dns_recA"
msgstr "�����µ�[[base-dns.a_record]]"

msgid "modify_dns_recA"
msgstr "�޸�[[base-dns.a_record]]"

msgid "a_record_explain"
msgstr "[[base-dns.a_record]]����ȫ�޶�������ת��Ϊ IP ��ַ����ȫ�޶��������ɰ���һ����������һ����������ֻ����һ��������"

msgid "a_host_name"
msgstr "������"

msgid "a_host_name_help"
msgstr "����˼�¼����������[[base-dns.a_record_explain]]"

msgid "a_host_name_invalid"
msgstr "ָ����������������Ч�ַ���"

msgid "a_domain_name"
msgstr "����"

msgid "a_domain_name_help"
msgstr "����˼�¼��������[[base-dns.a_record_explain]]"

msgid "a_domain_name_invalid"
msgstr "ָ��������������Ч�ַ���"

msgid "a_domain_name_empty"
msgstr "��ָ���˼�¼����"

msgid "a_ip_address"
msgstr "IP ��ַ"

msgid "a_ip_address_help"
msgstr "����˼�¼�� IP ��ַ��[[base-dns.a_record_explain]]"

msgid "a_ip_address_invalid"
msgstr "ָ���� IP ��ַ��Ч��[[base-dns.ipaddr_rule]]"

msgid "a_ip_address_empty"
msgstr "��ָ���������������������ɵ� IP ��ַ��[[base-dns.ipaddr_rule]]"


# --- PTR  record

msgid "create_dns_recPTR"
msgstr "�����µ�[[base-dns.ptr_record]]"

msgid "modify_dns_recPTR"
msgstr "�޸�[[base-dns.ptr_record]]"

msgid "ptr_explain"
msgstr "[[base-dns.ptr_record]]�� IP ��ַת��Ϊ��ȫ�޶�����������ȫ�޶��������ɰ���һ����������һ����������ֻ����һ��������"

msgid "ptr_ip_address"
msgstr "IP ��ַ"

msgid "ptr_ip_address_help"
msgstr "����˼�¼�� IP ��ַ��[[base-dns.ptr_explain]]"

msgid "ptr_subnet_mask"
msgstr "��������"

msgid "ptr_subnet_mask_help"
msgstr "����˼�¼�� IP ��ַ�������롣[[base-dns.ptr_explain]]"

msgid "ptr_host_name"
msgstr "������"

msgid "ptr_host_name_help"
msgstr "����˼�¼����������[[base-dns.ptr_explain]]"

msgid "ptr_domain_name"
msgstr "����"

msgid "ptr_domain_name_help"
msgstr "����˼�¼��������[[base-dns.ptr_explain]]"

msgid "a_generate_ptr"
msgstr "���ɷ����ַ (PTR) ��¼"

msgid "ptr_generate_a"
msgstr "���������ַ (A) ��¼"

msgid "ptr_generate_a_help"
msgstr "�Զ����������ַ��¼���Դ�ָ���� IP ��ַ����ָ������������������"

msgid "ptr_subnet_mask_invalid"
msgstr "ָ��������������Ч���������������������Ե�������ĸ�������ɣ������Ծ������ġ�0 �� 255 ֮����ĸ�����ɵ����С����磬255.255.255.0 ������Ч�����롣"

msgid "ptr_ip_address_invalid"
msgstr "ָ���� IP ��ַ��Ч��[[base-dns.ipaddr_rule]]"

msgid "ptr_host_name_invalid"
msgstr "ָ����������������Ч�ַ���"

msgid "ptr_domain_name_invalid"
msgstr "ָ��������������Ч�ַ���"

msgid "ptr_ip_address_empty"
msgstr "��ָ��������Ϊ�������������� IP ��ַ��[[base-dns.ipaddr_rule]]"

msgid "ptr_domain_name_empty"
msgstr "��ָ���� IP ��ַ��Ӧ��������"


# --- MX record

msgid "create_dns_recMX"
msgstr "�����µ�[[base-dns.mx_record]]"

msgid "modify_dns_recMX"
msgstr "�޸�[[base-dns.mx_record]]"

msgid "mx_host_name"
msgstr "������"

msgid "mx_explain"
msgstr "[[base-dns.mx_record]]��ʶ�ض����ʼ����������÷�����������Ŀ��Ϊָ�����������������ĵ����ʼ���"

msgid "mx_host_name_help"
msgstr "ָ����������������������������[[base-dns.mx_target_server]]�ֶ���ָ���ʼ��������������ʼ���[[base-dns.mx_explain]]"

msgid "mx_domain_name"
msgstr "����" 

msgid "mx_domain_name_empty"
msgstr "��ָ���˼�¼����"

msgid "mx_domain_name_help"
msgstr "ָ���������������������ʼ�Ӧת��[[base-dns.mx_target_server]]�ֶ���ָ�����ʼ���������[[base-dns.mx_explain]]"

msgid "mx_target_server"
msgstr "�ʼ�����������" 

msgid "mx_target_server_help"
msgstr "ָ���ʼ���������ȫ�޶������������ʼ�������������ָ�����������������ʼ���[[base-dns.mx_explain]]"

msgid "mx_priority"
msgstr "�������ȼ�" 

msgid "mx_priority_help"
msgstr "ѡ���ʼ��������ʼ������������ȼ����������ȼ�ֵָ���������Ӷ���ʼ��������Խ����ʼ����ݵ�˳�򡣴������ȼ����ý���Ϊһ���������ָ����� MX ��¼ʱ���á�  "

msgid "very_high"
msgstr "���� (20)"

msgid "high"	
msgstr "�� (30)"

msgid "low"	
msgstr "�� (40)"

msgid "very_low"
msgstr "���� (50)"

msgid "mx_host_name_invalid"
msgstr "ָ����������������Ч�ַ���"

msgid "mx_domain_name_invalid"
msgstr "ָ��������������Ч�ַ���"

msgid "mx_target_server_invalid"
msgstr "ָ������ȫ�޶�������������Ч�ַ���"

msgid "mx_target_server_empty"
msgstr "��ָ���ʼ���������ȫ�޶���������"


# --- CNAME record

msgid "create_dns_recCNAME"
msgstr "�����µ�[[base-dns.cname_record]]"

msgid "modify_dns_recCNAME"
msgstr "�޸�[[base-dns.cname_record]]"

msgid "cname_explain"
msgstr "������¼����ȫ�޶�������ת��Ϊ��һ����ȫ�޶���������"

msgid "cname_host_name"
msgstr "����������"

msgid "cname_host_name_help"
msgstr "���뽫��Ϊ������������/��������������������[[base-dns.cname_explain]]"

msgid "cname_domain_name"
msgstr "��������"

msgid "cname_domain_name_help"
msgstr "���뽫��Ϊ������������/������������������[[base-dns.cname_explain]]"

msgid "cname_host_target"
msgstr "����������"

msgid "cname_host_target_help"
msgstr "����������淶����������[[base-dns.cname_explain]]"

msgid "cname_domain_target"
msgstr "��������"

msgid "cname_domain_target_help"
msgstr "����������淶��������[[base-dns.cname_explain]]"



# --- SOA

msgid "create_soa"
msgstr "����Ȩ������ (SOA) ��¼"

msgid "modify_soa"
msgstr "�޸�Ȩ������ (SOA) ��¼"

msgid "domain_soa"
msgstr "��Ȩ��"

msgid "domain_soa_help"
msgstr "���Ǵˡ�Ȩ����������¼���õ���Ȩ�ޡ�"

msgid "network_soa"
msgstr "����Ȩ��"

msgid "network_soa_help"
msgstr "���Ǵˡ�Ȩ����������¼���õ�����Ȩ�ޡ�"

msgid "primary_dns"
msgstr "������������ (NS)"

msgid "primary_dns_help"
msgstr "������ѡ�������Ȩ������������������ȫ�޶�������"

msgid "secondary_dns"
msgstr "�������������� (NS)"

msgid "secondary_dns_help"
msgstr "������ѡ�������Ȩ�޸���������������ȫ�޶��������б����Կո������"

msgid "domain_admin"
msgstr "DNS ����Ա�����ʼ���ַ"

msgid "domain_admin_rule"
msgstr "�������ʽ��ȷ�ĵ����ʼ���ַ��ȱʡֵ��[[base-dns.soa_defaults]]�������á����磬user@cobalt.com ������Ч�����롣"

msgid "domain_admin_help"
msgstr "���������������������Ĺ�����ϵ�˵����ʼ���ַ��ֵ�� [[base-dns.domain_admin_rule]]"

msgid "domain_admin_invalid"
msgstr "�Բ���[[VAR.invalidValue] ��[[base-dns.domain_admin]]����Чֵ�� [[base-dns.domain_admin_rule]]"

msgid "domain_admin_empty"
msgstr "�Բ�����û��Ϊ[[base-dns.domain_admin]]����ֵ�� [[base-dns.domain_admin_rule]]"

msgid "refresh"
msgstr "ˢ�¼�����룩"

msgid "refresh_rule"
msgstr "������ 1 �� 4096000 ֮���������ȱʡֵ��[[base-dns.soa_defaults]]�������á�"

msgid "refresh_help"
msgstr "����������������������ˢ�¼��ȱʡֵ����ֵ�Ǹ�����������������ʹ���¼������������������ͬ����ʱ������ [[base-dns.refresh_rule]]"

msgid "refresh_invalid"
msgstr "�Բ���[[VAR.invalidValue] ��[[base-dns.refresh]]����Чֵ�� [[base-dns.refresh_rule]]"

msgid "refresh_empty"
msgstr "�Բ�����û��Ϊ[[base-dns.refresh]]����ֵ�� [[base-dns.refresh_rule]]"

msgid "retry"
msgstr "���Լ�����룩"

msgid "retry_rule"
msgstr "������ 1 �� 4096000 ֮���������ȱʡֵ��[[base-dns.soa_defaults]]�������á�"

msgid "retry_help"
msgstr "�������������������������Լ��ȱʡֵ���������ĳ��ԭ�򣬸��������������޷�ͨ����������������ȡ����ϵ��ʹ��¼ͬ������ֵ�Ǹ�����������������������ϵ��������������ʱ������[[base-dns.retry_rule]]"

msgid "retry_invalid"
msgstr "�Բ���[[VAR.invalidValue] ��[[base-dns.retry]]����Чֵ�� [[base-dns.retry_rule]]"

msgid "retry_empty"
msgstr "�Բ�����û��Ϊ[[base-dns.retry]]����ֵ�� [[base-dns.retry_rule]]"


msgid "expire"
msgstr "���ڼ�����룩"

msgid "expire_rule"
msgstr "������ 1 �� 4096000 ֮���������ȱʡֵ��[[base-dns.soa_defaults]]�������á�"

msgid "expire_help"
msgstr "����������������������ȱʡ���ڼ�����������ĳ��ԭ�򣬸��������������������Զ��޷�ͨ����������������ȡ����ϵ��ʹ��¼ͬ������ֵ�Ǹ�������������������Ϊ��������Ϣ��Ч��ֹͣ�ṩ����Ϣ�ļ����ֱ���������������ܹ��������ӡ�[[base-dns.expire_rule]]"

msgid "expire_invalid"
msgstr "�Բ���[[VAR.invalidValue] ��[[base-dns.expire]]����Чֵ�� [[base-dns.expire_rule]]"

msgid "expire_empty"
msgstr "�Բ�����û��Ϊ[[base-dns.expire]]����ֵ�� [[base-dns.expire_rule]]"


msgid "ttl"
msgstr "����ʱ�������룩"

msgid "ttl_rule"
msgstr "������ 1 �� 4096000 ֮���������ȱʡֵ��[[base-dns.soa_defaults]]�������á�"

msgid "ttl_help"
msgstr "����������������������ȱʡ����ʱ��������ֵ�Ǳ�ʾһ��ʱ�Σ��ڴ�ʱ���ڣ��������������������ٻ���Ӵ���������������������Ϣ�����Ҽٶ�����Ϣ��Ч����������������������˶ԡ� [[base-dns.ttl_rule]]"

msgid "ttl_invalid"
msgstr "�Բ���[[VAR.invalidValue] ��[[base-dns.ttl]]����Чֵ�� [[base-dns.ttl_rule]]"

msgid "ttl_empty"
msgstr "�Բ�����û��Ϊ[[base-dns.ttl]]����ֵ�� [[base-dns.ttl_rule]]"



# ---- Secondary Services

msgid "secondary_service_button"
msgstr "�༭��������"

msgid "secondary_service_button_help"
msgstr "Ϊ�������������� DNS ���� "

msgid "sec_list"
msgstr "���������б�"

msgid "create_slave_rec"
msgstr "���Ӹ�������"

msgid "modify_slave_rec"
msgstr "�޸ĸ�������"

msgid "slave_domain_but"
msgstr "��ĸ�������������"

msgid "slave_domain"
msgstr "����"

msgid "slave_domain_help"
msgstr "����˻�������Ϊ�丨��������������������"

msgid "slave_dom_masters"
msgstr "�� DNS ������ IP ��ַ"

msgid "slave_dom_masters_help"
msgstr "Ϊ���������������������� IP ��ַ��"

msgid "slave_network_but"
msgstr "����ĸ�������������"

msgid "slave_ipaddr"
msgstr "����"

msgid "slave_ipaddr_help"
msgstr "����˻�������Ϊ�丨������������������ IP ��ַ��"

msgid "slave_netmask"
msgstr "������������"

msgid "slave_netmask_help"
msgstr "����˻�������Ϊ�丨�������������������������롣"

msgid "slave_net_masters"
msgstr "�� DNS ������ IP ��ַ"

msgid "slave_net_masters_help"
msgstr "Ϊ���������������������� IP ��ַ��"

msgid "create_slave_rec"
msgstr "���Ӹ�������"

msgid "sec_authority"
msgstr "��������"

msgid "sec_authority_help"
msgstr "���Ǵ˻�������Ϊ�丨��������������������硣"

msgid "sec_primaries"
msgstr "�� DNS ������"

msgid "sec_primaries_help"
msgstr "���Ǵ���������������������� IP ��ַ."

msgid "recordlist_action"
msgstr "����"

msgid "recordlist_action_help"
msgstr "��Щ�������޸Ļ�ɾ���������������¼�İ�ť��"

	# end of sentence is completed
msgid "confirm_removal_of_sec"
msgstr "�Ƿ�ȷ��Ҫɾ��[[VAR.rec]]�ĸ������������¼��"

msgid "slave_ipaddr_invalid"
msgstr "ָ���� IP ��ַ��Ч�� "

msgid "slave_netmask_invalid"
msgstr "ָ��������������Ч�������������������Ե������"

msgid "slave_net_masters_invalid"
msgstr "�� DNS ������ IP ��ַ��Ч��"

msgid "slave_domain_invalid"
msgstr "ָ����������Ч��"

msgid "slave_dom_masters_invalid"
msgstr "�� DNS ������ IP ��ַ��Ч��"



msgid "apply_changes"
msgstr "����Ӧ�ø���"

msgid "apply_changes_help"
msgstr "�����˴��������������������������¼�����ĸ��ġ�������������¼�������κ��޸Ľ���ͨ�������˰�ťֱ����������������֮����Ч��"

msgid "apply_changes_disabledHelp"
msgstr "�˰�ť���ã���Ϊ����û�����ӻ��޸�������������¼�����ӻ��޸�������������¼�󣬵����˴��������������������������¼�����ĸ��ġ� "

# ---- Active monitor

msgid "amDNSNameTag"
msgstr "�������� (DNS) ������"

msgid "amDetailsTitle"
msgstr "�������� (DNS) ��������ϸ��Ϣ"

msgid "amNotRunning"
msgstr "����������û�����С�"

msgid "amStatusOK"
msgstr "��������������������"




# --- Drop-down menu
msgid "select_a_domain"	
msgstr "ѡ����..."

msgid "select_a_network"
msgstr "ѡ������..."

msgid "no_records"	
msgstr "���������Ȩ��"

msgid "subdom_host_name"
msgstr "������" 

msgid "subdom_host_name_help"
msgstr "ָ�����ϸ�������������磬Ҫ���� remote.ourcompany.com���˷����������� ourcompany.com ���Ȩ�ޡ�ָֻ�������� remote��" 

msgid "subdom_domain_name"
msgstr "ĸ����" 

msgid "subdom_domain_name_help"
msgstr "ѡ��ĸ���������磬Ҫ�������� remote.ourcompany.com��ѡ�� ourcompany.com" 

msgid "subdom_nameservers"
msgstr "���Ʒ�����" 

msgid "subdom_nameservers_help"
msgstr "ָ����ָ��������Ȩ�޵����Ʒ����� IP ��ַ�б����ö��Ÿ���������ָ������һ�����Ʒ�������" 

msgid "subnet_ip_address"
msgstr "���� IP ��ַ" 

msgid "subnet_ip_address_help"
msgstr "ָ��������������һ DNS �������������ڵ� IP ��ַ��"  

msgid "subnet_subnet_mask"
msgstr "������������" 

msgid "subnet_subnet_mask_help"
msgstr "ָ�����Ե�������ĸ�������ɵ������������롣" 

msgid "subnet_nameservers"
msgstr "���Ʒ�����" 

msgid "subnet_nameservers_help"
msgstr "ָ����ָ��������Ȩ�޵����Ʒ����� IP ��ַ�б����ö��Ÿ���������ָ������һ�����Ʒ�������" 

msgid "create_dns_rec"
msgstr "���� DNS ��¼" 

msgid "modify_dns_rec"	
msgstr "�޸� DNS ��¼"

msgid "authority"
msgstr "Ȩ��"

msgid "authority_help"
msgstr "DNS Ȩ����������硣 "

msgid "subnet"
msgstr "��������"

msgid "subdom"
msgstr "�������"

msgid "modify_dns_recSUBDOM"
msgstr "�޸����������"

msgid "create_dns_recSUBDOM"
msgstr "�����������"

msgid "modify_dns_recSUBNET"
msgstr "�޸���������"

msgid "create_dns_recSUBNET"
msgstr "������������"



msgid "add_secondary"
msgstr "���Ӹ�������..."


msgid "add_secondary_forward"
msgstr "��������"

msgid "add_secondary_network"
msgstr "���縨������"

# --- Lots of error messages

msgid "cname_domain_name_invalid"
msgstr "ָ��������������Ч�ַ���"

msgid "cname_domain_target_invalid"
msgstr "ָ��������������Ч�ַ���"

msgid "cname_host_target_invalid"
msgstr "ָ����������������Ч�ַ���"

msgid "cname_domain_target_invalid"
msgstr "ָ��������������Ч�ַ���"


msgid "subdom_host_name_invalid"
msgstr "ָ����������������Ч�ַ���"

msgid "subdom_domain_name_invalid"
msgstr "ָ��������������Ч�ַ���"

msgid "subdom_namerservers_invalid"
msgstr "ָ������ȫ�޶����� DNS ������������Ч��"

msgid "subnet_subnet_mask_invalid"
msgstr "ָ��������������Ч������������������Ե�������ĸ�������ɡ�"

msgid "subnet_ip_address_invalid"
msgstr "ָ���� IP ��ַ��Ч�� "

msgid "subnet_nameservers_invalid"
msgstr "ָ������ȫ�޶����� DNS ������������Ч��"


msgid "primary_dns_invalid"
msgstr "ָ����������������Ч�ַ���"

msgid "secondary_dns_invalid"
msgstr "��������������������������Ч�ַ���"

msgid "domain_admin_invalid"
msgstr "ָ���ĵ����ʼ���ַ��Ч��"

msgid "refresh_invalid"
msgstr "�Բ���[[VAR.invalidValue] ��[[base-dns.default_refresh]]����Чֵ�� [[base-dns.default_refresh_rule]]"

msgid "retry_invalid"
msgstr "�Բ���[[VAR.invalidValue] ��[[base-dns.default_retry]]����Чֵ�� [[base-dns.default_retry_rule]]"

msgid "expire_invalid"
msgstr "�Բ���[[VAR.invalidValue] ��[[base-dns.default_expire]]����Чֵ�� [[base-dns.default_expire_rule]]"

msgid "cname_domain_name_empty"
msgstr "���������������"

msgid "cname_domain_target_empty"
msgstr "��ָ����������������������Ϊ������������"

msgid "slave_domain_empty"
msgstr "��ָ���˷���������Ϊ�丨�� DNS ��������������"

msgid "slave_dom_masters_empty"
msgstr "��Ϊ����ָ���� DNS �������� IP ��ַ��"

msgid "slave_ipaddr_empty"
msgstr "��ָ����Ϊ�� DNS ���������������Ȩ�޳�Ա�� IP ��ַ��"

msgid "slave_net_masters_empty"
msgstr "��Ϊ����Ȩ��ָ���� DNS �������� IP ��ַ��"

msgid "slave_netmask_empty"
msgstr "��ָ�������� IP ��ַ�⣬��ָ�����Ե�������ĸ�������ɵ��������룬ȷ���� DNS ��������������硣"

msgid "cname_host_name_empty"
msgstr "��ָ���˼�¼����������"

msgid "cname_host_name_invalid"
msgstr "ָ����������������Ч�ַ���"

                                                                                                                                                                                                                                                                                                                 locale/zh_TW/                                                                                       0042755 0000000 0000156 00000000000 07727667110 011201  5                                                                                                    ustar   root                                                                                                                                                                                                                                                   locale/zh_TW/dns.po                                                                                 0100644 0000000 0000156 00000054406 07372633002 012316  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   # --- Menu

msgid "dns"
msgstr "DNS"

msgid "modifyDNS"
msgstr "����W�٨t�� (DNS) �]�w"

msgid "dns_help"	
msgstr "���B�i�ܧ�[[base-dns.modifyDNS]]�C"


# --- Common

msgid "basic"
msgstr "��"

msgid "advanced"	
msgstr "�i��"

msgid "basic_help"
msgstr "���B�i�t�m�� DNS ���A���]�w�ȡC"

msgid "advanced_help"
msgstr "���B�i�t�m�i�� DNS ���A���]�w�ȡA�Ҧp��Ʈ榡�B�w������M���A���w�]�ȡC"


# --- Basic settings

msgid "enabled"
msgstr "�ҥΦ��A��"

msgid "enabled_help"
msgstr "�}�ҩ������u����W�٨t�� (DNS)�v���A���\��C�}�Ҧ��\��N�i�������A���]�ƥR���䥻���αq�ݯ����ϰ����W�٦��A���C����W�٦��A���|�N��r�������D���W�٩M����W���ഫ���Ʀr�� IP ��}�A�Ϥ���M�C"


# --- Advanced settings

msgid "soa_defaults"
msgstr "���v�}�l (SOA) �w�]��"

msgid "soa_defaults_help"
msgstr "�o�ǭȬO�s�W����W�ٰO���ɨϥΪ��w�]�ȡC"

msgid "admin_email"
msgstr "�w�] DNS �t�κ޲z���q�l�l���}"

msgid "admin_email_rule"
msgstr "�п�J�@�Ӯ榡�ƪ��q�l�l���}�A�Ҧp�Auser@cobalt.com �N�O�@�Ӧ��Ī���}�C"

msgid "admin_email_help"
msgstr "�аw��Ҧ��s�W������M�����A��J�޲z�p���H���q�l�l���}���w�]�ȡC [[base-dns.admin_email_rule]]"

msgid "admin_email_invalid"
msgstr "�ܩ�p�A[[VAR.invalidValue] �O�L�Ī�[[base-dns.admin_email]]�ȡC [[base-dns.admin_email_rule]]"

msgid "default_refresh"
msgstr "�w�]��s���j�]���^"

msgid "default_refresh_rule"
msgstr "�п�J�@�Ӥ��� 1 �� 4096000 ��������ơC�w�]�Ȭ� 10800�C"

msgid "default_refresh_help"	
msgstr "�аw��Ҧ��s�W������M�����A��J��s���j���w�]�ȡC�o�ӭȬO���n����W�٦��A�����ջP�D�n����W�٦��A���P�B�ƨ�O�������j�C [[base-dns.default_refresh_rule]]"

msgid "default_refresh_invalid"
msgstr "�ܩ�p�A[[VAR.invalidValue] �O�L�Ī�[[base-dns.default_refresh]]�ȡC [[base-dns.default_refresh_rule]]"

msgid "default_refresh_empty"	
msgstr "�ܩ�p�A�z�å���J[[base-dns.default_refresh]]���ȡC [[base-dns.default_refresh_rule]]"

msgid "default_retry"	
msgstr "�w�]���ն��j�]���^"

msgid "default_retry_rule"
msgstr "�п�J�@�Ӥ��� 1 �� 4096000 ��������ơC�w�]�Ȭ� 3600�C"

msgid "default_retry_help"
msgstr "�аw��Ҧ��s�W������M�����A��J���ն��j���w�]�ȡC�p�G���n����W�٦��A���]�Y�ǭ�]�ӵL�k�sô�D�n����W�٦��A���A�H�P�B�ƨ�O���A�h�o�ӭȴN�O���n����W�٦��A���N���ƹ��ճsô�D�n����W�٦��A�������j�C [[base-dns.default_retry_rule]]"

msgid "default_retry_invalid"
msgstr "�ܩ�p�A[[VAR.invalidValue] �O�L�Ī�[[base-dns.default_retry]]�ȡC [[base-dns.default_retry_rule]]"

msgid "default_retry_empty"	
msgstr "�ܩ�p�A�z�å���J[[base-dns.default_retry]]���ȡC [[base-dns.default_retry_rule]]"

msgid "default_expire"	
msgstr "�w�]�O�����j�]���^"

msgid "default_expire_rule"
msgstr "�п�J�@�Ӥ��� 1 �� 4096000 ��������ơC�w�]�Ȭ� 604800�C"

msgid "default_expire_help"
msgstr "�аw��Ҧ��s�W������M�����A��J�O�����j���w�]�ȡC�p�G���n����W�٦��A���]�Y�ǭ�]�ӵL�k�sô�D�n����W�٦��A���A�B�L�k�P�B�ƨ�O���A�h�o�ӭȴN�O���n����W�٦��A��������A�����T�A���A��������T���ġA����i�A�׳sô�D�n����W�٦��A�����᪺���j�C [[base-dns.default_expire_rule]]"

msgid "default_expire_invalid"
msgstr "�ܩ�p�A[[VAR.invalidValue] �O�L�Ī�[[base-dns.default_expire]]�ȡC [[base-dns.default_expire_rule]]"

msgid "default_expire_empty"
msgstr "�ܩ�p�A�z�å���J[[base-dns.default_expire]]���ȡC [[base-dns.default_expire_rule]]"

msgid "default_ttl"	
msgstr "�w�]���Įɶ����j�]���^"

msgid "default_ttl_rule"
msgstr "�п�J�@�Ӥ��� 1 �� 4096000 ��������ơC�w�]�Ȭ� 86400�C"

msgid "default_ttl_help"	
msgstr "�аw��Ҧ��s�W������M�����A��J���Ķ��j���w�]�ȡC�o�Ӯɶ����ת��ȬO��L����W�٦��A���N�֨�������W�٦��A�������^���������T�B�B���A���s�ˬd������W�٦��A���B�ð��]�䬰���Ī��ɶ����סC [[base-dns.default_ttl_rule]]"

msgid "default_ttl_invalid"
msgstr "�ܩ�p�A[[VAR.invalidValue] �O�L�Ī�[[base-dns.default_ttl]]�ȡC [[base-dns.default_ttl_rule]]"

msgid "default_ttl_empty"
msgstr "�ܩ�p�A�z�å���J[[base-dns.default_ttl]]���ȡC [[base-dns.default_ttl_rule]]"

msgid "global_settings"
msgstr "���A���]�w"

msgid "global_settings_help"
msgstr "�o�ǬO����W�٦��A�����w�]�ȡC"

msgid "forwarders"	
msgstr "�౵���A��"

msgid "forwarders_help"
msgstr "�п�J�౵����W�٦��A���� IP ��}�C�Y�]�����έ�����ں����s���ӵL�k�����s�� Root ����W�٦��A���ɡA�|�ϥ��౵����W�٦��A���C[[base-dns.forwarders_rule]]"

msgid "forwarders_rule"
msgstr "�п�J�|�Ӥ��� 0 �� 255 �������Ʀr�ǦC�A�H�I���Ϲj�C�Ҧp�A192.168.1.1 �N�O���Ī��Ʀr�C"

msgid "forwarders_invalid"
msgstr "�ܩ�p�A[[VAR.invalidValue]]�O�L�Ī�[[base-dns.forwarders]]�ȡC [[base-dns.forwarders_rule]]"

msgid "zone_xfer_ipaddr"
msgstr "�� IP ��}�i�������e"

msgid "zone_xfer_ipaddr_help"
msgstr "�п�J�Q���\�z�L������e�U��������W�٦��A���Һ��@���Ҧ��O���� IP ��}�C���n����W�٦��A���ϥΤ�����e�A�P�D�n����W�٦��A���ӦP�B��O���C�w�]�Ȭ��O�d�����ťաA���\�L���������e�C"

msgid "zone_xfer_ipaddr_invalid"
msgstr "�ܩ�p�A[[VAR.invalidValue]]�O�L�Ī�[[base-dns.zone_xfer_ipaddr]]�ȡC"

msgid "zone_format"	
msgstr "�����ɮ׮榡"

msgid "zone_format_help"	
msgstr "�п�ܤ@�ػP�z���ϰ�ϦV���v��k�ۮe�������ɮ׮榡�A�Ω�i��D�K�i��ɭ�����@�~�CRFC2317 ���зǮ榡�CDION �M OCN-JT ���̤��`�Ϊ��榡�C"

msgid "rfc2317"
msgstr "RFC2317"

msgid "dion"
msgstr "DION"

msgid "ocn-jt"
msgstr "OCN-JT"

# --- Record types (reused)

msgid "a_record"
msgstr "���Ѧ�} (A) �O��"

msgid "ptr_record"
msgstr "�Ϭd��} (PTR) �O��"

msgid "cname_record"
msgstr "�O�W (CNAME) �O��"

msgid "mx_record"
msgstr "�l����A�� (MX) �O��"

msgid "records_title"
msgstr "����]�w�w�� "


# --- Primary services

msgid "primary_service_button"
msgstr "�s��D�n�A��"

msgid "primary_service_button_help"
msgstr "�޲z����M������ DNS �O���A�������O�������A���n���n���A�������C�u�D�n DNS (Primary DNS)�v�A�ȤS�٬��u�D�n DNS�v�A�ȡC"

msgid "dnsSetting"	
msgstr "�D�n�A�ȲM��"

msgid "select_dom"
msgstr "�������..."

msgid "select_net"	
msgstr "�������..."

	# drop down menu
msgid "add_record"
msgstr "�s�W�O��..."

msgid "edit_soa"
msgstr "�ק� SOA"

msgid "edit_soa_help"
msgstr "�ק��w������κ������v�����v�O�����_�l�B�C"

msgid "confirm_delall"
msgstr "�z�T�w�n�����Ҧ���ܪ� DNS �O���ܡH"

msgid "del_records"
msgstr "���h�O��"

msgid "del_records_help"
msgstr "���@�U�Ӳ����Ҧ���ܪ� DNS �O���C�o�N�|�����������W��ܪ��Ҧ��O���A�B�L�k�٭�C"

msgid "source"
msgstr "�d��"

msgid "source_help"
msgstr "�o�O�����V������W�٦��A���Ҵ��X���d�ߩΰ��D�C"

msgid "direction"
msgstr "�O������"

msgid "direction_help"
msgstr "�o�O�����惡���A�����d�߻P�Ӧۦ����A�����^�����p���O�������C"

msgid "resolution"
msgstr "�^��"

msgid "resolution_help"
msgstr "�o�O�����Ѧ�����W�٦��A���Ǧ^���^���Φ^���C"

msgid "listAction"
msgstr "�ʧ@"

msgid "listAction_help"
msgstr "�o�ǬO�Ψӭק�β�������W�ٰO�������s�C"

msgid "confirm_removal"
msgstr "�z�T�w�n�����O��[[VAR.rec]]�ܡH"

	# general IP address rule
msgid "ipaddr_rule"
msgstr "IP ��}�O�|�Ӥ��� 0 �� 255 �����B�H�I���Ϲj���Ʀr�ǦC�C�Ҧp�A192.168.1.1 �N�O���Ī���}�C"





# --- A record

msgid "create_dns_recA"
msgstr "�s�W[[base-dns.a_record]]"

msgid "modify_dns_recA"
msgstr "�ק�[[base-dns.a_record]]"

msgid "a_record_explain"
msgstr "[[base-dns.a_record]]�i�N���㪺����W���ഫ�� IP ��}�C���㪺����W�٥i�ѥD���W�٩M����W�ٲզ��ζȥѺ���W�٩Ҳզ��C"

msgid "a_host_name"
msgstr "�D���W��"

msgid "a_host_name_help"
msgstr "�п�J���O�����D���W�١C[[base-dns.a_record_explain]]"

msgid "a_host_name_invalid"
msgstr "���w���D���W�٧t���L�Ī��r���C"

msgid "a_domain_name"
msgstr "����W��"

msgid "a_domain_name_help"
msgstr "�п�J���O��������W�١C[[base-dns.a_record_explain]]"

msgid "a_domain_name_invalid"
msgstr "���w������W�٧t���L�Ī��r���C"

msgid "a_domain_name_empty"
msgstr "�Ы��w���O��������C"

msgid "a_ip_address"
msgstr "IP ��}"

msgid "a_ip_address_help"
msgstr "�п�J���O���� IP ��}�C[[base-dns.a_record_explain]]"

msgid "a_ip_address_invalid"
msgstr "���w�� IP ��}�L�ġC[[base-dns.ipaddr_rule]]"

msgid "a_ip_address_empty"
msgstr "�Ы��w IP ��}�A�� IP ��}�O�ѥD���W�٩M����W�٩ҸѪR�Ӧ��C[[base-dns.ipaddr_rule]]"


# --- PTR  record

msgid "create_dns_recPTR"
msgstr "�s�W[[base-dns.ptr_record]]"

msgid "modify_dns_recPTR"
msgstr "�ק�[[base-dns.ptr_record]]"

msgid "ptr_explain"
msgstr "[[base-dns.ptr_record]]�i�N IP ��}�ഫ�����㪺����W�١C���㪺����W�٥i�ѥD���W�٩M����W�ٲզ��ζȥѺ���W�٩Ҳզ��C"

msgid "ptr_ip_address"
msgstr "IP ��}"

msgid "ptr_ip_address_help"
msgstr "�п�J���O���� IP ��}�C[[base-dns.ptr_explain]]"

msgid "ptr_subnet_mask"
msgstr "�l�����B�n"

msgid "ptr_subnet_mask_help"
msgstr "�п�J���O���� IP ��}�������B�n�C[[base-dns.ptr_explain]]"

msgid "ptr_host_name"
msgstr "�D���W��"

msgid "ptr_host_name_help"
msgstr "�п�J���O�����D���W�١C[[base-dns.ptr_explain]]"

msgid "ptr_domain_name"
msgstr "����W��"

msgid "ptr_domain_name_help"
msgstr "�п�J���O��������W�١C[[base-dns.ptr_explain]]"

msgid "a_generate_ptr"
msgstr "���ͤϬd��} (PTR) �O��"

msgid "ptr_generate_a"
msgstr "���ͥ��Ѧ�} (A) �O��"

msgid "ptr_generate_a_help"
msgstr "�۰ʷs�W���Ѧ�}�O���A�H�q���w�� IP ��}�ѪR�����w���D���W�٩M����W�١C"

msgid "ptr_subnet_mask_invalid"
msgstr "���w���l�����B�n�L�ġC�l�����B�n�����H�I���Υ|�ӼƦr���ܪk��J�A�䬰�|�Ӥ��� 0 �� 255 �������Ʀr�ǦC�]�H�I���Ϲj�^�C�Ҧp�A255.255.255.0 �N�O���Ī��Ʀr�C"

msgid "ptr_ip_address_invalid"
msgstr "���w�� IP ��}�L�ġC[[base-dns.ipaddr_rule]]"

msgid "ptr_host_name_invalid"
msgstr "���w���D���W�٧t���L�Ī��r���C"

msgid "ptr_domain_name_invalid"
msgstr "���w������W�٧t���L�Ī��r���C"

msgid "ptr_ip_address_empty"
msgstr "�Ы��w IP ��}�A�� IP ��}�O�ѥD���W�٩M����W�٩ҸѪR�Ӧ����C[[base-dns.ipaddr_rule]]"

msgid "ptr_domain_name_empty"
msgstr "�Ы��w�P IP ��}����������W�١C"


# --- MX record

msgid "create_dns_recMX"
msgstr "�s�W[[base-dns.mx_record]]"

msgid "modify_dns_recMX"
msgstr "�ק�[[base-dns.mx_record]]"

msgid "mx_host_name"
msgstr "�D���W��"

msgid "mx_explain"
msgstr "[[base-dns.mx_record]]�ѧO�t�d�N�q�l�l��e�ܫ��w�D���M����W�٪��l����A���C"

msgid "mx_host_name_help"
msgstr "�Ы��w�D���W�١A�ӥD���N�t�d�B�z�Ҧ��ǰe��[[base-dns.mx_target_server]]��줤���w���l����A�����q�l�l��C[[base-dns.mx_explain]]"

msgid "mx_domain_name"
msgstr "����W��" 

msgid "mx_domain_name_empty"
msgstr "�Ы��w���O��������C"

msgid "mx_domain_name_help"
msgstr "�Ы��w�q��������W�١A�ӹq�����q�l�l�����ɦV��[[base-dns.mx_target_server]]��줤���w���l����A�����q�l�l��C[[base-dns.mx_explain]]"

msgid "mx_target_server"
msgstr "�l����A���W��" 

msgid "mx_target_server_help"
msgstr "�Ы��w�l����A�����������W�١A�Ӷl����A���N�������w���D���M����W�٪��l��C[[base-dns.mx_explain]]"

msgid "mx_priority"
msgstr "�l���u���v" 

msgid "mx_priority_help"
msgstr "�п���l��l���ܶl����A�����u���v�F�l���u���v���w�����pô�@�t�C�h�Ӷl����A�������H�i��l��l�����������ǡC�u���b�w�����κ������w�F�h�� MX �O���ɡA�u�l���u���v�v���w�~���ΡC"

msgid "very_high"
msgstr "���� (20)"

msgid "high"	
msgstr "�� (30)"

msgid "low"	
msgstr "�C (40)"

msgid "very_low"
msgstr "���C (50)"

msgid "mx_host_name_invalid"
msgstr "���w���D���W�٧t���L�Ī��r���C"

msgid "mx_domain_name_invalid"
msgstr "���w������W�٧t���L�Ī��r���C"

msgid "mx_target_server_invalid"
msgstr "���w���������W�٧t���L�Ī��r���C"

msgid "mx_target_server_empty"
msgstr "�Ы��w�l����A�����������W�١C"


# --- CNAME record

msgid "create_dns_recCNAME"
msgstr "�s�W[[base-dns.cname_record]]"

msgid "modify_dns_recCNAME"
msgstr "�ק�[[base-dns.cname_record]]"

msgid "cname_explain"
msgstr "�O�W�O���i�N�@�ӧ������W���ഫ���t�@�ӧ������W�١C"

msgid "cname_host_name"
msgstr "�O�W�D���W��"

msgid "cname_host_name_help"
msgstr "�п�J�N�R����ڥD���W�٤Ρ]�Ρ^����W�٤��O�W���D���W�١C[[base-dns.cname_explain]]"

msgid "cname_domain_name"
msgstr "�O�W����W��"

msgid "cname_domain_name_help"
msgstr "�п�J�N�R����ڥD���W�٤Ρ]�Ρ^����W�٤��O�W������W�١C[[base-dns.cname_explain]]"

msgid "cname_host_target"
msgstr "��ڥD���W��"

msgid "cname_host_target_help"
msgstr "�п�J�@�ӹ�ڪ��ΦX�G�зǪ��D���W�١C[[base-dns.cname_explain]]"

msgid "cname_domain_target"
msgstr "��ں���W��"

msgid "cname_domain_target_help"
msgstr "�п�J�@�ӹ�ڪ��ΦX�G�зǪ�����W�١C[[base-dns.cname_explain]]"



# --- SOA

msgid "create_soa"
msgstr "�s�W���v�}�l (SOA) �O��"

msgid "modify_soa"
msgstr "�ק���v�}�l (SOA) �O��"

msgid "domain_soa"
msgstr "�����v��"

msgid "domain_soa_help"
msgstr "�o�O�M�Φ��u���v�}�l (SOA)�v�O���������v���C"

msgid "network_soa"
msgstr "�����v��"

msgid "network_soa_help"
msgstr "�o�O�M�Φ��u���v�}�l (SOA)�v�O���������v���C"

msgid "primary_dns"
msgstr "�D�n�W�٦��A�� (NS)"

msgid "primary_dns_help"
msgstr "�п�J��w����κ����v�����D�n�W�٦��A�����������W�١C"

msgid "secondary_dns"
msgstr "���n�W�٦��A�� (NS)"

msgid "secondary_dns_help"
msgstr "�п�J��w����κ����v�������n�W�٦��A�����������W�١]�H�Ů�Ϲj�^�M��C"

msgid "domain_admin"
msgstr "DNS �t�κ޲z���q�l�l���}"

msgid "domain_admin_rule"
msgstr "�п�J�@�Ӯ榡�ƪ��q�l�l���}�C�w�]�ȳ]�w��[[base-dns.soa_defaults]]�Ϭq���C�Ҧp�Auser@cobalt.com �N�O�@�Ӧ��Ī���}�C"

msgid "domain_admin_help"
msgstr "�аw��Ҧ��s�W������M�����A��J�޲z�p���H���q�l�l���}�C [[base-dns.domain_admin_rule]]"

msgid "domain_admin_invalid"
msgstr "�ܩ�p�A[[VAR.invalidValue] �O�L�Ī�[[base-dns.domain_admin]]�ȡC [[base-dns.domain_admin_rule]]"

msgid "domain_admin_empty"
msgstr "�ܩ�p�A�z�å���J[[base-dns.domain_admin]]���ȡC [[base-dns.domain_admin_rule]]"

msgid "refresh"
msgstr "��s���j�]���^"

msgid "refresh_rule"
msgstr "�п�J�@�Ӥ��� 1 �� 4096000 ��������ơC�w�]�ȳ]�w��[[base-dns.soa_defaults]]�Ϭq���C"

msgid "refresh_help"
msgstr "�аw��Ҧ��s�W������M�����A��J��s���j���w�]�ȡC�o�ӭȬO���n����W�٦��A���N���ջP�D�n����W�٦��A���P�B�ƨ�O�������j�C [[base-dns.refresh_rule]]"

msgid "refresh_invalid"
msgstr "�ܩ�p�A[[VAR.invalidValue] �O�L�Ī�[[base-dns.refresh]]�ȡC [[base-dns.refresh_rule]]"

msgid "refresh_empty"
msgstr "�ܩ�p�A�z�å���J[[base-dns.refresh]]���ȡC [[base-dns.refresh_rule]]"

msgid "retry"
msgstr "���ն��j�]���^"

msgid "retry_rule"
msgstr "�п�J�@�Ӥ��� 1 �� 4096000 ��������ơC�w�]�ȳ]�w��[[base-dns.soa_defaults]]�Ϭq���C"

msgid "retry_help"
msgstr "�аw��Ҧ��s�W������M�����A��J���ն��j���w�]�ȡC�p�G���n����W�٦��A���]�Y�ǭ�]�ӵL�k�sô�D�n����W�٦��A���A�H�P�B�ƨ�O���A�h�o�ӭȬO���n����W�٦��A���N���ƹ��ճsô�D�n����W�٦��A�������j�C[[base-dns.retry_rule]]"

msgid "retry_invalid"
msgstr "�ܩ�p�A[[VAR.invalidValue] �O�L�Ī�[[base-dns.retry]]�ȡC [[base-dns.retry_rule]]"

msgid "retry_empty"
msgstr "�ܩ�p�A�z�å���J[[base-dns.retry]]���ȡC [[base-dns.retry_rule]]"


msgid "expire"
msgstr "�O�����j�]���^"

msgid "expire_rule"
msgstr "�п�J�@�Ӥ��� 1 �� 4096000 ��������ơC�w�]�ȳ]�w��[[base-dns.soa_defaults]]�Ϭq���C"

msgid "expire_help"
msgstr "�аw��Ҧ��s�W������M�����A��J�w�]�O�����j�C�p�G���n����W�٦��A���]�Y�ǭ�]�ӵL�k�sô�D�n����W�٦��A���A�H�P�B�ƨ�O���A�h�o�ӭȬO���n����W�٦��A���N���A���D�n����W�٦��A���������T�����ĸ�T�B�ñN������A�����T�A����i�A�׳sô�D�n����W�٦��A�����᪺���j�C [[base-dns.expire_rule]]"

msgid "expire_invalid"
msgstr "�ܩ�p�A[[VAR.invalidValue] �O�L�Ī�[[base-dns.expire]]�ȡC [[base-dns.expire_rule]]"

msgid "expire_empty"
msgstr "�ܩ�p�A�z�å���J[[base-dns.expire]]���ȡC [[base-dns.expire_rule]]"


msgid "ttl"
msgstr "���Įɶ����j�]���^"

msgid "ttl_rule"
msgstr "�п�J�@�Ӥ��� 1 �� 4096000 ��������ơC�w�]�ȳ]�w��[[base-dns.soa_defaults]]�Ϭq���C"

msgid "ttl_help"
msgstr "�аw��Ҧ��s�W������M�����A��J�O���ɶ��j���w�]�ȡC�o�Ӯɶ����ת��ȬO��L����W�٦��A���N�֨�������W�٦��A�������^���������T�B�B���A���s�ˬd������W�٦��A���B�ð��]�䬰���Ī��ɶ����סC [[base-dns.ttl_rule]]"

msgid "ttl_invalid"
msgstr "�ܩ�p�A[[VAR.invalidValue] �O�L�Ī�[[base-dns.ttl]]�ȡC [[base-dns.ttl_rule]]"

msgid "ttl_empty"
msgstr "�ܩ�p�A�z�å���J[[base-dns.ttl]]���ȡC [[base-dns.ttl_rule]]"



# ---- Secondary Services

msgid "secondary_service_button"
msgstr "�s�覸�n�A��"

msgid "secondary_service_button_help"
msgstr "�޲z����M���������n DNS �A�ȡC"

msgid "sec_list"
msgstr "���n�A�ȲM��"

msgid "create_slave_rec"
msgstr "�s�W���n�A��"

msgid "modify_slave_rec"
msgstr "�ק隸�n�A��"

msgid "slave_domain_but"
msgstr "���쪺���n����W�٦��A��"

msgid "slave_domain"
msgstr "����W��"

msgid "slave_domain_help"
msgstr "�п�J���������n����W�٦��A��������W�١C"

msgid "slave_dom_masters"
msgstr "�D�n DNS ���A�� IP ��}"

msgid "slave_dom_masters_help"
msgstr "�п�J�����줧�D�n����W�٦��A���� IP ��}�C"

msgid "slave_network_but"
msgstr "���A�������n����W�٦��A��"

msgid "slave_ipaddr"
msgstr "����"

msgid "slave_ipaddr_help"
msgstr "�п�J���������n����W�٦��A�������� IP ��}�C"

msgid "slave_netmask"
msgstr "�����l�����B�n"

msgid "slave_netmask_help"
msgstr "�o�O���������n����W�٦��A�����l�����B�n�C"

msgid "slave_net_masters"
msgstr "�D�n DNS ���A�� IP ��}"

msgid "slave_net_masters_help"
msgstr "�п�J�����줧�D�n����W�٦��A���� IP ��}�C"

msgid "create_slave_rec"
msgstr "�s�W���n�A��"

msgid "sec_authority"
msgstr "���n�A��"

msgid "sec_authority_help"
msgstr "�o�O���������n����W�٦��A��������κ����C"

msgid "sec_primaries"
msgstr "�D�n DNS ���A��"

msgid "sec_primaries_help"
msgstr "�o�O������κ������D�n����W�٦��A���� IP ��}�C"

msgid "recordlist_action"
msgstr "�ʧ@"

msgid "recordlist_action_help"
msgstr "�o�ǬO�Ψӭק�β������n����W�٪A�ȰO�������s�C"

	# end of sentence is completed
msgid "confirm_removal_of_sec"
msgstr "�z�T�w�n����[[VAR.rec]]�����n����W�٪A�ȰO���H"

msgid "slave_ipaddr_invalid"
msgstr "���w�� IP ��}�L�ġC "

msgid "slave_netmask_invalid"
msgstr "���w�������B�n�L�ġC�����B�n�����H�I���Υ|�ӼƦr���ܪk��J�C"

msgid "slave_net_masters_invalid"
msgstr "�D�n DNS ���A�� IP ��}�L�ġC"

msgid "slave_domain_invalid"
msgstr "���w������W�ٵL�ġC"

msgid "slave_dom_masters_invalid"
msgstr "�D�n DNS ���A�� IP ��}�L�ġC"



msgid "apply_changes"
msgstr "�ߧY�M���ܧ�"

msgid "apply_changes_help"
msgstr "���@�U���B�A�i�ߧY�Ұʱz������W�٦��A���O���ҧ@�������ܧ�C�b��z������W�٦��A���O���ҧ@���ܧ���T�a�M�Ρ]���k�������@���s�^�����W�٦��A����A���ܧ�~�|�ͮġC"

msgid "apply_changes_disabledHelp"
msgstr "�o�ӫ��s�w�����A�]���z�|���s�W�έק����W�٦��A���O���C�b�s�W�έק����W�٦��A���O����A���@�U���B�i�ߧY�Ұʹ����W�٦��A���O���ҧ@�������ܧ�C"

# ---- Active monitor

msgid "amDNSNameTag"
msgstr "����W�٪A�� (DNS) ���A��"

msgid "amDetailsTitle"
msgstr "����W�٪A�� (DNS) ���A������"

msgid "amNotRunning"
msgstr "������W�٦��A�����b���椤�C"

msgid "amStatusOK"
msgstr "������W�٦��A�����`�B�@���C"




# --- Drop-down menu
msgid "select_a_domain"	
msgstr "�������..."

msgid "select_a_network"
msgstr "�������..."

msgid "no_records"	
msgstr "�L����κ����v��"

msgid "subdom_host_name"
msgstr "������W��" 

msgid "subdom_host_name_help"
msgstr "�Ы��w�����㪺������W�١C�Ҧp�A�Y�n���v������ remote.ourcompany.com�A�����A���������v���� ourcompany.com�C�ȫ��w������W�� remote�C" 

msgid "subdom_domain_name"
msgstr "������W��" 

msgid "subdom_domain_name_help"
msgstr "�п��������W�١C�Ҧp�A�Y�n���v������ remote.ourcompany.com�A�п�� ourcompany.com" 

msgid "subdom_nameservers"
msgstr "�W�٦��A��" 

msgid "subdom_nameservers_help"
msgstr "�ХβM��]�H�r�I�Ϲj�^�C�X�N�����w�����쪺�W�٦��A���� IP ��}�C�ܤ֥������w�@�ӦW�٦��A���C" 

msgid "subnet_ip_address"
msgstr "�l���� IP ��}" 

msgid "subnet_ip_address_help"
msgstr "�Ы��w�Q���v���t�@�� DNS ���A�����l�������� IP ��}�C"  

msgid "subnet_subnet_mask"
msgstr "�l���������B�n" 

msgid "subnet_subnet_mask_help"
msgstr "�ХH�I���Υ|�ӼƦr���ܪk���w�l�����������B�n�C" 

msgid "subnet_nameservers"
msgstr "�W�٦��A��" 

msgid "subnet_nameservers_help"
msgstr "�ХβM��]�H�r�I�Ϲj�^�C�X�N�����w������W�٦��A���� IP ��}�C�ܤ֥������w�@�ӦW�٦��A���C " 

msgid "create_dns_rec"
msgstr "�s�W DNS �O��" 

msgid "modify_dns_rec"	
msgstr "�ק� DNS �O��"

msgid "authority"
msgstr "�v��"

msgid "authority_help"
msgstr "DNS �v��������M�����C"

msgid "subnet"
msgstr "�l�������v"

msgid "subdom"
msgstr "��������v"

msgid "modify_dns_recSUBDOM"
msgstr "�ק隸������v�C"

msgid "create_dns_recSUBDOM"
msgstr "�s�W��������v"

msgid "modify_dns_recSUBNET"
msgstr "�ק�l�������v"

msgid "create_dns_recSUBNET"
msgstr "�s�W�l�������v"



msgid "add_secondary"
msgstr "�s�W���n�A��..."


msgid "add_secondary_forward"
msgstr "���즸�n�A��"

msgid "add_secondary_network"
msgstr "�������n�A��"

# --- Lots of error messages

msgid "cname_domain_name_invalid"
msgstr "���w������W�٧t���L�Ī��r���C"

msgid "cname_domain_target_invalid"
msgstr "���w������W�٧t���L�Ī��r���C"

msgid "cname_host_target_invalid"
msgstr "���w���D���W�٧t���L�Ī��r���C"

msgid "cname_domain_target_invalid"
msgstr "���w������W�٧t���L�Ī��r���C"


msgid "subdom_host_name_invalid"
msgstr "���w���D���W�٧t���L�Ī��r���C"

msgid "subdom_domain_name_invalid"
msgstr "���w������W�٧t���L�Ī��r���C"

msgid "subdom_namerservers_invalid"
msgstr "��D�n DNS ���A���ҫ��w���������W�ٵL�ġC"

msgid "subnet_subnet_mask_invalid"
msgstr "���w���l�����B�n�L�ġC�l�����B�n�����H�I���Υ|�ӼƦr���ܪk��J�C"

msgid "subnet_ip_address_invalid"
msgstr "���w�� IP ��}�L�ġC "

msgid "subnet_nameservers_invalid"
msgstr "��D�n DNS ���A���ҫ��w���������W�ٵL�ġC"


msgid "primary_dns_invalid"
msgstr "���w���D���W�٧t���L�Ī��r���C"

msgid "secondary_dns_invalid"
msgstr "���n�W�٦��A���D���W�٧t���L�Ī��r���C"

msgid "domain_admin_invalid"
msgstr "���w���q�l�l���}�L�ġC"

msgid "refresh_invalid"
msgstr "�ܩ�p�A[[VAR.invalidValue] �O�L�Ī�[[base-dns.default_refresh]]�ȡC [[base-dns.default_refresh_rule]]"

msgid "retry_invalid"
msgstr "�ܩ�p�A[[VAR.invalidValue] �O�L�Ī�[[base-dns.default_retry]]�ȡC [[base-dns.default_retry_rule]]"

msgid "expire_invalid"
msgstr "�ܩ�p�A[[VAR.invalidValue] �O�L�Ī�[[base-dns.default_expire]]�ȡC [[base-dns.default_expire_rule]]"

msgid "cname_domain_name_empty"
msgstr "�п�J�u�O�W����W�١v�C"

msgid "cname_domain_target_empty"
msgstr "�Ы��w�ѡu�O�W�D���W�١v�M�u�O�W����W�١v�ѪR�����u��ں���W�١v�C"

msgid "slave_domain_empty"
msgstr "�Ы��w�����A�����n DNS ���A��������W�١C"

msgid "slave_dom_masters_empty"
msgstr "�й惡�u����W�١v���w�D�n DNS ���A���� IP ��}�C"

msgid "slave_ipaddr_empty"
msgstr "�Ы��w�@�� IP ��}�A�䬰�D�n DNS ���A���Ҧ��A�������v�����խ��C"

msgid "slave_net_masters_empty"
msgstr "�й惡�u�����v���v���w�D�n DNS ���A���� IP ��}�C"

msgid "slave_netmask_empty"
msgstr "���F���w������ IP ��}���~�A�ХH�I���Υ|�ӼƦr���ܪk���w�����B�n�A�Ӻ����B�n�w�q�D�n DNS ���A���N���������C"

msgid "cname_host_name_empty"
msgstr "�Ы��w���O�����D���W�١C"

msgid "cname_host_name_invalid"
msgstr "���w���D���W�٧t���L�Ī��r���C"

                                                                                                                                                                                                                                                          Makefile                                                                                            0100644 0000000 0000156 00000000767 07620550021 010334  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   # specify the following variables:
VENDOR=base

# if the VENDOR field is an alias, this should be the real name.
# otherwise, set it to VENDOR.
VENDORNAME=cobalt
SERVICE=dns

VERSION=1.1.0
RELEASE=93

# add a buildarch if desired
BUILDARCH=noarch

# locale exclude pattern
#XLOCALEPAT=

BUILDUI=yes
BUILDGLUE=yes
BUILDLOCALE=yes
BUILDSRC=yes

#########
# some useful defines
INSTALL=install
INSTALL_BIN=$(INSTALL) -m 755
INSTALL_OTH=$(INSTALL) -m 644
TMPDIR=/tmp

include /usr/sausalito/devel/module.mk
         packing_list                                                                                        0100644 0000000 0000156 00000000175 07370751573 011300  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   # [AUTORPMS] DO NOT REMOVE THIS LINE OR EDIT ANYTHING BELOW IT, BY ORDER OF THE BUILD PEOPLE
RPM: base-dns-am-1.0-2.i386.rpm
                                                                                                                                                                                                                                                                                                                                                                                                   perl/                                                                                               0042755 0000000 0000156 00000000000 07727667110 007651  5                                                                                                    ustar   root                                                                                                                                                                                                                                                   perl/Nettest.pm                                                                                     0100755 0000000 0000156 00000012557 07371576763 011655  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   #!/usr/bin/perl -I/usr/sausalito/perl
# Copyright 2001 Sun Microsystems, Inc.  All rights reserved.
# $Id: dns_add_records.pl 259 2004-01-03 06:28:40Z shibuya $
#
# Network tests for dns zone collision tests
#

package Base::Nettest;

use Exporter;
use vars qw(@ISA @EXPORT_OK);

@ISA    = qw(Exporter);

@EXPORT_OK = qw(
		net_convert_netmask
		test_network_in_network
		);

1;

sub net_convert_netmask
# Convert netmask from decimal notation to dotted quad (16 => 255.255.0.0) or vice versa
# Arguments: netmask in decimal, or netmask in dotted quad
# Return value; netmask in dotted quad if decimal argument given, or netmask in
#      decimal if dotted quad argument is given
# Example: $quadmask = Cobalt::Network::net_convert_netmask(26);
{
  my ($mask) = @_;
  # I should be able to do this in some cool mathematical way.
  # If only I knew how.
  my %netmasks = (
                  32 => "255.255.255.255", 31 => "255.255.255.254",
                  30 => "255.255.255.252", 29 => "255.255.255.248",
                  28 => "255.255.255.240", 27 => "255.255.255.224",
                  26 => "255.255.255.192", 25 => "255.255.255.128",
                  24 => "255.255.255.0",   23 => "255.255.254.0",
                  22 => "255.255.252.0",   21 => "255.255.248.0",
                  20 => "255.255.240.0",   19 => "255.255.224.0",
                  18 => "255.255.192.0",   17 => "255.255.128.0",
                  16 => "255.255.0.0",     15 => "255.254.0.0",
                  14 => "255.252.0.0",     13 => "255.248.0.0",
                  12 => "255,240.0.0",     11 => "255.224.0.0",
                  10 => "255.192.0.0",      9 => "255.128.0.0",
                   8 => "255.0.0.0",        7 => "254.0.0.0",
                   6 => "252.0.0.0",        5 => "248.0.0.0",
                   4 => "240.0.0.0",        3 => "224.0.0.0",
                   2 => "192.0.0.0",        1 => "128.0.0.0",
                   0 => "0.0.0.0",

                  "0.0.0.0" => 0,          "128.0.0.0" => 1,
                  "192.0.0.0" => 2,        "224.0.0.0" => 3,
                  "240.0.0.0" => 4,        "248.0.0.0" => 5,
                  "252.0.0.0" => 6,        "254.0.0.0" => 7,
                  "255.0.0.0" => 8,        "255.128.0.0" => 9,
                  "255.192.0.0" => 10,     "255.224.0.0" => 11,
                  "255,240.0.0" => 12,     "255.248.0.0" => 13,
                  "255.252.0.0" => 14,     "255.254.0.0" => 15,
                  "255.255.0.0" => 16,     "255.255.128.0" => 17,
                  "255.255.192.0" => 18,   "255.255.224.0" => 19,
                  "255.255.240.0" => 20,   "255.255.248.0" => 21,
                  "255.255.252.0" => 22,   "255.255.254.0" => 23,
                  "255.255.255.0" => 24,   "255.255.255.128" => 25,
                  "255.255.255.192" => 26, "255.255.255.224" => 27,
                  "255.255.255.240" => 28, "255.255.255.248" => 29,
                  "255.255.255.252" => 30, "255.255.255.254" => 31,
                  "255.255.255.255" => 32,
                 );

  return $netmasks{$mask};
}

sub test_network_in_network
# Test if one IP network is a subset of another network
#   This is not only for testing if an address is on a network--
#   it also tests wether a subnet is within a larger subnet
#   (e.g., 1.2.3.0/24 is a subnet of 1.2.0.0/16)
#   (generally: is the first network within the second?)
# argument 0 is the IP address of the first network
# argument 1 is the netmask of the first network
# argument 2 is the IP address of the second network
# argument 3 is the netmask of second network
# IP addresses do not have to have all 4 octets; any octets that are not
#   defined will be assumed to be 0 (e.g., "10.10.0.0" is equivalent
#   to "10.10".)
# The netmask can be given either in dotted quad (255.255.0.0) or in
#   decimal (16).  If in dotted quad, all four quads must be defined
#   (e.g., "255.255" is not acceptable--you must use "255.255.0.0")
# Return value: 1 if the first network is entirely within the second
#   network or if the two networks are the same; 0 otherwise.
#   Note that if the second network is entirely within the first,
#   we will return 0.
# Example: netutil_test_network_in_network("192.168.45.0",24,"192.168.0.0",16);
{
    my ($ip1, $netmask1, $ip2, $netmask2) = @_;

    # convert the IP addresses from dotted quad (e.g., 192.168.123.45)
    # to binary (e.g., 11000000101010000111101100101101)
    $ip1 = unpack('B32',pack('C4',split('\.',$ip1)));
    $ip2 = unpack('B32',pack('C4',split('\.',$ip2)));

    # If the netmask is given in dotted quad, convert to decimal
    $netmask1 = &net_convert_netmask($netmask1)
      if ($netmask1 =~ /\./o);
    $netmask2 = &net_convert_netmask($netmask2)
      if ($netmask2 =~ /\./o);

    # chop off the bits according to the netmask; if the netmask
    # is 32, then no chopping is done (it's exactly that IP)
    # (To return all but the last character, use substr($string, 0, -1))
    $ip1 = substr($ip1,0,$netmask1) if ($netmask1 != 32);
    $ip2 = substr($ip2,0,$netmask2) if ($netmask2 != 32);

    # Now do the comparisons...
    if ($netmask1 >= $netmask2) {
      # the second network is as large or larger than the first
      # (a smaller subnet mask means a larger network)
      return 1 if ($ip1 =~ /^$ip2/);
    } else {
      # The following tests if the second net is in the first
      # the first network is larger (smaller mask)
      return 2 if ($ip2 =~ /^$ip1/);
    }
    return 0;
}


                                                                                                                                                 src/                                                                                                0042755 0000000 0000156 00000000000 07727667110 007476  5                                                                                                    ustar   root                                                                                                                                                                                                                                                   src/base-dns-am/                                                                                    0042755 0000000 0000156 00000000000 07727667110 011565  5                                                                                                    ustar   root                                                                                                                                                                                                                                                   src/base-dns-am/Makefile                                                                            0100644 0000000 0000156 00000000574 07327123207 013214  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   # $Id: dns_add_records.pl 259 2004-01-03 06:28:40Z shibuya $
#
# Copyright 2001 Sun Microsystems, Inc.  All rights reserved.
#

#ifdef TOPDIR
#include $(TOPDIR)/devel/defines.mk
#else
include /usr/sausalito/devel/defines.mk
#endif

BINDIR = $(SWATCHBINDIR)
BINS = am_dns.sh

.PHONY: all
all: install

install: $(BINS)
	mkdir -p $(BINDIR)
	install -m 750 -o root -g root $(BINS) $(BINDIR)
                                                                                                                                    src/base-dns-am/am_dns.sh                                                                           0100755 0000000 0000156 00000001306 07327124422 013346  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   #!/bin/sh
# $Id: dns_add_records.pl 259 2004-01-03 06:28:40Z shibuya $
# Bind test

# Load return codes
. /usr/sausalito/swatch/statecodes

# Test whether we're intentionally disabled
# /sbin/chkconfig --list named | grep '3:on' > /dev/null
# if [ $? -gt 0 ]; then
# 	exit $AM_STATE_NOINFO
# fi

# Test localhost lookup
/usr/bin/host -W 2 127.0.0.1 127.0.0.1 | grep '1.0.0.127.in-addr.arpa.' >/dev/null

if [ $? -gt 0 ]; then

	# Merciful restart attempt
	/etc/rc.d/init.d/named restart > /dev/null 2>&1

	# Re-test
	/usr/bin/host -W 2 127.0.0.1 127.0.0.1 | grep '1.0.0.127.in-addr.arpa.' >/dev/null

	if [ $? -gt 0 ]; then
		echo -n "$redMsg"
		exit $AM_STATE_RED;
	fi
fi
	
echo -n "$greenMsg"
exit $AM_STATE_GREEN;
                                                                                                                                                                                                                                                                                                                          src/base-dns-am/base-dns-am.spec                                                                    0100644 0000000 0000156 00000001034 07337336725 014523  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   Summary: Active Monitor support for base-dns-am
Name: base-dns-am
Version: 1.0
Release: 2
Copyright: Cobalt Sun Microsystems 2001, All rights reserved.
Group: Utils
Source: base-dns-am.tar.gz
BuildRoot: /tmp/base-dns-am

%prep
%setup -n base-dns-am

%build
make all

%install
make PREFIX=$RPM_BUILD_ROOT install

%files
/usr/sausalito/swatch/bin/*

%description
This package contains binaries and scripts used by the Active Monitor 
subsystem for base-dns-am.  

%changelog
* Mon Jul 23 2001 Will DeHaan <null@sun.com>
- Initial spec file

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    src/Makefile                                                                                        0100644 0000000 0000156 00000000554 07327123207 011123  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   # Generic src makefile

DIRS=base-dns-am
TMPDIR=/tmp

all:
	for t in $(DIRS) ; do \
		make -C $$t all ; \
	done

install:
	for t in $(DIRS) ; do \
		make -C $$t install ; \
	done

rpm:
	for t in $(DIRS) ; do \
		tar -zcvf /tmp/$$t.tar.gz $$t --exclude '*CVS*' &> /dev/null &&\
		rpm -ta /tmp/$$t.tar.gz &> /tmp/rpm.log && \
		/bin/rm -f /tmp/$$t.tar.gz ; \
	done

                                                                                                                                                    templates/                                                                                          0042755 0000000 0000156 00000000000 07727667110 010705  5                                                                                                    ustar   root                                                                                                                                                                                                                                                   templates/rpmdefs.tmpl                                                                              0100644 0000000 0000156 00000002704 07443331354 013232  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   # configuration bits for mod_rpmize
# syntax:
# <begin [x]section>
# <end [x]section>
#
# x an be $ for a string or % for a hash.
# if a hash is being used, you can add sub-sections with
# <begin sub-section>
# <end sub-section>


<begin $DESCRIPTION>
%package [LABEL]
Group: CCE/[VENDOR]
Summary: [LABEL] for [VENDOR]-[SERVICE].
[AUTOFILL]
[BUILDARCH]

%description [LABEL]
The [VENDOR]-[SERVICE]-[LABEL] package contains the [LABEL]
information for [VENDOR]-[SERVICE].

<end $DESCRIPTION>

<begin %PREP>
<end %PREP>

<begin %SETUP>
<end %SETUP>

<begin %BUILD>
<end %BUILD>

<begin %INSTALL>
<end %INSTALL>

<begin %FILES>
<begin HEADER>
%files [LABEL]
%defattr(-,root,root)
<end HEADER>

<begin locale>
[AUTOFILL]

<end locale>

<begin glue>
/etc/cobaltdns.DION
/etc/cobaltdns.OCN-JT
/etc/cobaltdns.RFC2317
%attr(0700,root,root)%{RootDir}/sbin/named_enable.pl
[AUTOFILL]

<end glue>

<begin ui>
[AUTOFILL]

<end ui>

<begin capstone>
%{RootDir}/capstone/%{Vendor}-%{Service}.cap
[AUTOFILL]

<end capstone>
<end %FILES>

<begin %POST-INSTALL>
<begin HEADER>
%post [LABEL]
<end HEADER>

<begin glue>
# glue post-install

<end glue>
<begin ui>
# ui post-install

<end ui>
<begin locale>
# locale post-install

<end locale>
<end %POST-INSTALL>

<begin %POST-UNINSTALL>
<begin HEADER>
%postun [LABEL]
<end HEADER>

<begin glue>
# glue post-uninstall

<end glue>
<begin ui>
# ui post-uninstall

<end ui>
<begin locale>
# locale post-uninstall

<end locale>
<end %POST-UNINSTALL>
                                                            templates/spec.tmpl                                                                                 0100644 0000000 0000156 00000001563 07110360252 012514  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   # vendor and service name
%define Vendor [VENDOR]
%define Service [SERVICE]
%define RootDir [ROOTDIR]

Summary: skeleton spec template 
Name: %{Vendor}-%{Service}
Vendor: [VENDORNAME]
Version: [VERSION]
Release: [RELEASE]
Copyright: Cobalt Networks, Inc.
Group: CCE/%{Service}
Source: %{Vendor}-%{Service}-[VERSION].tar.gz
BuildRoot: /var/tmp/%{Vendor}-%{Service}

%description
This is a skeleton package. It builds the ui, locale, and glue rpms.

[DESCRIPTION_SECTION]

%prep
[PREP_SECTION]

%setup
[SETUP_SECTION]

%build
make
[BUILD_SECTION]

%install
rm -rf $RPM_BUILD_ROOT
PREFIX=$RPM_BUILD_ROOT make install
[INSTALL_SECTION]

[POST-INSTALL_SECTION]

[POST-UNINSTALL_SECTION]

[FILES_SECTION]

%changelog
* Tue Apr 18 2000 Adrian Sun <asun@cobalt.com>
- new, improved spec file template.

* Thu Mar 30 2000 Adrian Sun <asun@cobalt.com>
- sample spec file for skeleton package.
                                                                                                                                             TODO                                                                                                0100644 0000000 0000156 00000000206 07350446615 007365  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   - Add documentation to the doucmentation interface (arm/) ???
  symlink in bind docs in constructor
  ln -s /usr/doc/bind-9.1.1/ doc 
                                                                                                                                                                                                                                                                                                                                                                                          ui/                                                                                                 0042755 0000000 0000156 00000000000 07727667110 007324  5                                                                                                    ustar   root                                                                                                                                                                                                                                                   ui/menu/                                                                                            0042755 0000000 0000156 00000000000 07727667110 010270  5                                                                                                    ustar   root                                                                                                                                                                                                                                                   ui/menu/base-dns.xml                                                                                0100644 0000000 0000156 00000000503 07363333663 012476  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   <item
	id="base_dns"
	label="[[base-dns.title]]"
	description="[[base-dns.dns_help]]"
	url="/base/dns/dns.php"
>
	<parent id="base_networkServices" order="10">
        <access require="adminUser"/>
    </parent>
	<parent id="base_controlpanel" order="40">
        <access require="networkServices"/>
    </parent>
</item>

                                                                                                                                                                                             ui/web/                                                                                             0042755 0000000 0000156 00000000000 07770212423 010070  5                                                                                                    ustar   root                                                                                                                                                                                                                                                   ui/web/dns_add.php                                                                                  0100644 0000000 0000156 00000031417 07345743565 012214  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   <?php
// $Id: dns_add_records.pl 259 2004-01-03 06:28:40Z shibuya $
//
// ui for adding/modifying many DNS record types
$iam = '/base/dns/dns_add.php';
$parent = '/base/dns/records.php';

include("CobaltUI.php");
$Ui = new CobaltUI($sessionId, "base-dns"); 

// return the base ip address of a network
// as defined by dot-quad member ip and netmask
function get_network($ip = "127.0.0.1", $nm = "255.255.255.255") {
	$ip = split('[.]',$ip);
	$nm = split('[.]',$nm);
	for ($i=0; $i<4; $i++):
		$ip[$i] = (int) $ip[$i]; $nm[$i] = (int) $nm[$i];
		$nu[$i] .= $ip[$i] & $nm[$i];
	endfor;

	return join('.',$nu);
}

// mapping: lists a form field name to an object attribute.
//          note the many:1 mapping, this causes a case-map in update_cce()
$mapping = array (

	"type" => "type",
	"network" => "network",

	"a_host_name" => "hostname",
	"a_domain_name" => "domainname",
	"a_ip_address" => "ipaddr",

	"ptr_host_name" => "hostname",
	"ptr_domain_name" => "domainname",
	"ptr_ip_address" => "ipaddr",
	"ptr_mask" => "netmask",

	"cname_host_name" => "hostname",
	"cname_domain_name" => "domainname",
	"cname_host_target" => "alias_hostname",
	"cname_domain_target" => "alias_domainname",

	"mx_host_name" => "hostname",
	"mx_domain_name" => "domainname",
	"mx_target_server" => "mail_server_name",
	"mx_priority" => "mail_server_priority",

	"subdom_host_name" => "hostname",
	"subdom_domain_name" => "domainname",
	"subdom_nameservers" => "delegate_dns_servers",

	"subnet_parent_ip_address" => "ipaddr",
	"subnet_parent_mask" => "netmask",
	"subnet_nameservers" => "delegate_dns_servers",
	"subnet_nameservers" => "delegate_dns_servers",
	"subnet_network" => "network_delegate",

	"unused" => "delegate_sec_dns",
	"unused" => "delegate_sec_dns" );


$nm_to_dec = array(
	"0.0.0.0"   => "0",
	"128.0.0.0" => "1",	"255.128.0.0" => "9",	"255.255.128.0" => "17",	"255.255.255.128" => "25",
	"192.0.0.0" => "2", 	"255.192.0.0" => "10",	"255.255.192.0" => "18",	"255.255.255.192" => "26",
	"224.0.0.0" => "3",	"255.224.0.0" => "11",	"255.255.224.0" => "19",	"255.255.255.224" => "27",
	"240.0.0.0" => "4",	"255.240.0.0" => "12",	"255.255.240.0" => "20",	"255.255.255.240" => "28",
	"248.0.0.0" => "5",	"255.248.0.0" => "13",	"255.255.248.0" => "21",	"255.255.255.248" => "29",
	"252.0.0.0" => "6",	"255.252.0.0" => "14",	"255.255.252.0" => "22",	"255.255.255.252" => "30",
	"254.0.0.0" => "7",	"255.254.0.0" => "15",	"255.255.248.0" => "23",	"255.255.255.254" => "31",
	"255.0.0.0" => "8",	"255.255.0.0" => "16",	"255.255.255.0" => "24",	"255.255.255.255" => "32" );
$dec_to_nm = array_flip($nm_to_dec);

// handler:
if (!$_TARGET) { $_TARGET = 'A'; }
$done = handle($Ui, $_TARGET, $mapping, $HTTP_POST_VARS, $HTTP_GET_VARS, $nm_to_dec, $dec_to_nm);

# prevent PHP from sneakily adding new hidden fields:
if (is_array($HTTP_POST_VARS)) {
	$keys = array_keys($HTTP_POST_VARS);
	$index = array_keys($keys, "_LOAD"); array_splice($HTTP_POST_VARS, $index[0], 1);
	$index = array_keys($keys, "_save"); array_splice($HTTP_POST_VARS, $index[0], 1);
}

if ($HTTP_GET_VARS{'domauth'} != '') {
	$ret_url = $parent.'?domauth='.$HTTP_GET_VARS{'domauth'};
} elseif ($HTTP_GET_VARS{'netauth'} != '') {
	$ret_url = $parent.'?netauth='.urlencode($HTTP_GET_VARS{'netauth'});
} else {
	$ret_url = $parent;
}

$Ui->StartPage("AAS", $_TARGET ? $_TARGET : "DnsRecord", "");
$Ui->StartBlock((intval($_TARGET) > 0) ? "modify_dns_rec".$HTTP_GET_VARS{'TYPE'} : "create_dns_rec".$HTTP_GET_VARS{'TYPE'});

// Bail if we've saved successfully
if ($done) {
	$Ui->Redirect( $ret_url );
	exit();
}

// prep default values
if($HTTP_GET_VARS['netauth'] != '') {
	$net_defaults = split('/', urldecode($HTTP_GET_VARS['netauth']));
}
$dom_default = $HTTP_GET_VARS['domauth'];

// order is important here people...  PTR CNAME MX SUBDOM SUBNET else A

if ($HTTP_GET_VARS{'TYPE'} == 'PTR') {

	if ($Ui->Data['ptr_mask'] == '') { 
		$Ui->Data['ptr_mask'] = $dec_to_nm[$net_defaults[1]]; 
	}
	if ($Ui->Data['ptr_mask'] == '') { 
		$Ui->Data['ptr_mask'] = '255.255.255.0'; 
	}
	$Ui->IpAddress( "ptr_ip_address" );
	$Ui->IpAddress( "ptr_mask" );
	$Ui->DomainName( "ptr_host_name", array( "Optional" => 'loud' ) );
	$Ui->DomainName( "ptr_domain_name" );
	if ($Ui->Data['ptr_ip_address'] == '') { 
		$Ui->Boolean( "ptr_generate_a" ); 
	}

} elseif ($HTTP_GET_VARS{'TYPE'} == 'CNAME') {

	if ($Ui->Data['cname_domain_name'] == '') { 
		$Ui->Data['cname_domain_name'] = $dom_default;
	}
	if ($Ui->Data['cname_domain_target'] == '') { 
		$Ui->Data['cname_domain_target'] = $dom_default; 
	}
	$Ui->DomainName( "cname_host_name" );  // optional alias hostname
	$Ui->DomainName( "cname_domain_name" ); 
	// target hostname
	$Ui->DomainName( "cname_host_target", array( "Optional" => 'loud' ) );  
	$Ui->DomainName( "cname_domain_target" );  // target domain

} elseif ($HTTP_GET_VARS{'TYPE'} == 'MX') {

	if ($Ui->Data['mx_domain_name'] == '') { 
		$Ui->Data['mx_domain_name'] = $dom_default; 
	}
	$Ui->DomainName( "mx_host_name", array( "Optional" => 'loud' ) ); 
	$Ui->DomainName( "mx_domain_name" ); 
	$Ui->DomainName( "mx_target_server" );
	// $Ui->DomainName( "mx_target_server", array( "Optional" => "silent" ) );
	$Ui->Alters( "mx_priority", array('very_high', 'high', 'low', 'very_low') ); 
} elseif ($HTTP_GET_VARS{'TYPE'} == 'SUBDOM') {

	if ( ! $Ui->Data['subdom_domain_name'] ) { 
		$Ui->Data['subdom_domain_name'] = $dom_default; 
	}
	if ( $Ui->Data['subdom_domain_name'] ) { 
		$Ui->DomainName( "subdom_domain_name", array('Access' => 'r') );
	} else {
		$Ui->DomainName( "subdom_domain_name" );
	}
	$Ui->DomainName( "subdom_host_name" );
 
	$Ui->DomainNameList( "subdom_nameservers" );

} elseif ($HTTP_GET_VARS{'TYPE'} == 'SUBNET') {

	// Preserve authority ties
	$Ui->Data['subnet_parent_ip_address'] = $net_defaults[0];
	$Ui->Data['subnet_parent_mask'] = $dec_to_nm[$net_defaults[1]];
	$Ui->Hidden( 'subnet_parent_ip_address' );
	$Ui->Hidden( 'subnet_parent_mask' );

	$Ui->Data['parent_network'] = $net_defaults[0] .'/'.
		$dec_to_nm[$net_defaults[1]];
	$Ui->TextField( "parent_network", array('Access' => 'r') );

	if (!$Ui->Data['subnet_mask']) { 
		$Ui->Data['subnet_mask'] = $dec_to_nm[$net_defaults[1]+1]; 
	}
	if (!$Ui->Data['subnet_ip_address']) { 
		$Ui->Data['subnet_ip_address'] = $net_defaults[0]; 
	}

	$Ui->IpAddress( "subnet_ip_address" );
	$Ui->IpAddress( "subnet_mask" );
	$Ui->DomainNameList( "subnet_nameservers" );

} else { // ($HTTP_GET_VARS{'TYPE'} == 'A')

	if ($Ui->Data['a_domain_name'] == '') { 
		$Ui->Data['a_domain_name'] = $dom_default; 
	}
	$Ui->DomainName( "a_host_name", array( "Optional" => "loud" ) );
	$Ui->DomainName( "a_domain_name" );
	$Ui->IpAddress( "a_ip_address" );

}

$Ui->AddButtons($ret_url);

$Ui->EndBlock();
$Ui->EndPage();

function handle(&$Ui, $target, &$mapping, &$post_vars, &$get_vars, &$nm_to_dec, &$dec_to_nm)
{
	// echo "<b>handle $target</b><br>";
	
	// Set Defaults that can't be grabbed from CCE....
	$Ui->Data["moderator"]="admin";

	$http_vars = array();
	if (is_array($post_vars)) { 
		$http_vars = array_merge($http_vars, $post_vars); 
	}
	if (is_array($get_vars)) {
		$http_vars = array_merge($http_vars, $get_vars);
	}

	if ($http_vars["_LOAD"]) {
		if (intval($target) > 0) {
			handle_load($Ui, intval($target), $dec_to_nm); 
		}
	} else {
		handle_post($Ui, $target, $mapping, $http_vars);
	}

	
	if ($post_vars["_save"]==1) {
		return update_cce($Ui, $target, $mapping, $http_vars, $nm_to_dec);
	}

	return 0;
}
	
function handle_load(&$Ui, $oid, &$dec_to_nm)
{
	// load object attributes
	$rec = $Ui->Cce->get($oid);
 
	// override the http get type
	if($rec['type'] == 'A') {
		$Ui->Data['a_host_name'] = $rec['hostname'];
		$Ui->Data['a_domain_name'] = $rec['domainname'];
		$Ui->Data['a_ip_address'] = $rec['ipaddr'];
		$HTTP_GET_VARS{'TYPE'} = 'A';
		$HTTP_GET_VARS{'domauth'} = $rec['domainname']; 

	} elseif($rec['type'] == 'PTR') {
		$Ui->Data['ptr_host_name'] = $rec['hostname'];
		$Ui->Data['ptr_domain_name'] = $rec['domainname'];
		$Ui->Data['ptr_ip_address'] = $rec['ipaddr'];
		$Ui->Data['ptr_mask'] = $rec['netmask'];
		$HTTP_GET_VARS{'TYPE'} = 'PTR';
		$HTTP_GET_VARS{'netauth'} = $rec['network']; 

	} elseif($rec['type'] == 'CNAME') {
		$Ui->Data['cname_host_name'] = $rec['hostname'];
		$Ui->Data['cname_domain_name'] = $rec['domainname'];
		$Ui->Data['cname_host_target'] = $rec['alias_hostname'];
		$Ui->Data['cname_domain_target'] = $rec['alias_domainname'];
		$HTTP_GET_VARS{'TYPE'} = 'CNAME';
		$HTTP_GET_VARS{'domauth'} = $rec['domainname']; 

	} elseif($rec['type'] == 'MX') {
		$Ui->Data['mx_host_name'] = $rec['hostname'];
		$Ui->Data['mx_domain_name'] = $rec['domainname'];
		$Ui->Data['mx_target_server'] = $rec['mail_server_name'];
		$Ui->Data['mx_priority'] = $rec['mail_server_priority'];
		$HTTP_GET_VARS{'TYPE'} = 'MX';
		$HTTP_GET_VARS{'domauth'} = $rec['domainname']; 

	} elseif($rec['type'] == 'SN') {

		if ($rec['hostname']) {
			$HTTP_GET_VARS{'TYPE'} = 'SUBDOM';
			$HTTP_GET_VARS{'domauth'} = $rec['domainname']; 
			$Ui->Data['subdom_host_name'] = $rec['hostname'];
			$Ui->Data['subdom_domain_name'] = $rec['domainname'];
			$Ui->Data['subdom_nameservers'] = $rec['delegate_dns_servers'];
		} else { 

			$HTTP_GET_VARS{'TYPE'} = 'SUBNET';
			$HTTP_GET_VARS{'netauth'} = $rec['network']; 
			$Ui->Data['subnet_parent_ip_address'] = $rec['ipaddr'];
			$Ui->Data['subnet_parent_mask'] = $rec['netmask'];
			$smallnet = split('/', $rec['network_delegate']);
			$Ui->Data['subnet_ip_address']  = $smallnet[0];
			$Ui->Data['subnet_mask'] = $dec_to_nm[ $smallnet[1] ];
			$Ui->Data['subnet_nameservers'] = $rec['delegate_dns_servers'];
		}
	}
}

function handle_post(&$ui, $target, &$mapping, &$post_vars)
{
	while (list($key,$val) = each($mapping))
	{
		$ui->Data[$key] = $post_vars[$key];
	}
}

# translate post variables into an object hash based on $mapping.
# $mapping maps "Form Field Name" => "Object Attribute Name"
function map_vars($mapping, $post_vars)
{
	$obj = array();
	while (list($key,$val) = each($mapping))
	{
		if($post_vars[$key] != "") {
		 $obj[$val] = $post_vars[$key];
		} elseif ( $val == "hostname" && 
			! in_array ("hostname", array_keys ($obj))) {
		 $obj[$val] = "";
		}
	}
	return $obj;
}

function update_cce(&$Ui, $target, $mapping, $http_vars, $nm_to_dec)
{
	$oid = 0;
	// create record; first determine type
	if($http_vars['a_domain_name'] != '') {
		$http_vars['type'] = 'A';
	} elseif($http_vars['ptr_ip_address'] != '') {
		$http_vars['type'] = 'PTR';
		$http_vars['network'] = get_network($http_vars['ptr_ip_address'], 
			$http_vars['ptr_mask']).'/'.$nm_to_dec[ $http_vars['ptr_mask'] ];
	} elseif($http_vars['cname_domain_name'] != '') {
		$http_vars['type'] = 'CNAME';
	} elseif($http_vars['mx_domain_name'] != '') {
		$http_vars['type'] = 'MX';
	} elseif($http_vars['subdom_host_name'] != '') {
		$http_vars['type'] = 'SN';
	} elseif($http_vars['subnet_ip_address'] != '') {
		$http_vars['type'] = 'SN';
		$http_vars['network'] = 
			get_network($http_vars['subnet_parent_ip_address'], 
			$http_vars['subnet_mask']).'/'.
			$nm_to_dec[ $http_vars['subnet_parent_mask'] ];
		$http_vars['subnet_network'] = 
			get_network($http_vars['subnet_ip_address'],
			$http_vars['subnet_mask']).'/'.
			$nm_to_dec[ $http_vars['subnet_mask'] ];
	}
	
	if (intval($target) > 0) {
		// modify record, its type is fixed
		$oid = intval($target);
		$Ui->Cce->set ($oid, "", map_vars($mapping, $http_vars));
		// $Ui->Cce->set ($oid, "Archive", map_vars($mapping, $http_vars));

	} else {

		$class = $target;
		$oid = $Ui->Cce->create( 'DnsRecord', map_vars($mapping, $http_vars));
	
	}
	
	// blue light special, 2 records for the grief of 1
	// if($http_vars['ptr_generate_a'] != '') {
	if($http_vars['ptr_generate_a'] != '') {
		$http_vars['type'] = 'A';
		$oid = $Ui->Cce->create( 'DnsRecord', map_vars($mapping, $http_vars));
	}

	$flip_map = array_flip($mapping); // maps attributes -> form field names (1:many)

	// hack around 1:many reverse mapping
	if ($http_vars['type'] == 'PTR') {
		$flip_map['hostname'] = 'ptr_host_name';
		$flip_map['domainname'] = 'ptr_domain_name';
		$flip_map['ipaddr'] = 'ptr_ip_address';
		$flip_map['netmask'] = 'ptr_mask';
	} elseif ($http_vars['type'] == 'A') {
		$flip_map['hostname'] = 'a_host_name';
		$flip_map['domainname'] = 'a_domain_name';
		$flip_map['ipaddr'] = 'a_ip_address';
	} elseif ($http_vars['type'] == 'CNAME') {
		$flip_map['hostname'] = 'hostname';
		$flip_map['domainname'] = 'domainname';
	} elseif ($http_vars['type'] == 'MX') {
		$flip_map['hostname'] = 'mx_host_name';
		$flip_map['domainname'] = 'mx_domain_name';
	} elseif ($http_vars['type'] == 'SUBDOM') {
		$flip_map['hostname'] = 'subdom_host_name';
		$flip_map['domainname'] = 'subdom_domain_name';
		$flip_map['delegate_dns_servers'] = 'subdom_nameservers';
	} elseif ($http_vars['type'] == 'SUBNET') {
		$flip_map['netmask'] = 'subnet_parent_mask';
		$flip_map['ipaddr'] = 'subnet_parent_ip_address';
		$flip_map['delegate_dns_servers'] = 'subnet_nameservers';
	} 
	
	$Ui->report_errors($flip_map);

	return (count($errors) == 0);
}
	

?>
                                                                                                                                                                                                                                                 ui/web/dns.php                                                                                      0100644 0000000 0000156 00000005622 07437044607 011374  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   <?php
include("CobaltUI.php");

$Ui = new CobaltUI( $sessionId, "base-dns" );

$ConfDir = "/etc";
$ZonePrefix = $ConfDir."/cobaltdns";
$ZoneConf = $ZonePrefix.".conf";

$Ui->StartPage("SET","System","DNS");

$Ui->Handle( $HTTP_POST_VARS );
for ($i = 0; $i < count($Ui->Errors); $i++) {
	if (method_exists($Ui->Errors[$i], 'getKey') &&
	    ($key = $Ui->Errors[$i]->getKey())) {
		$fieldName = "[[base-dns.$key]]";
		$Ui->Errors[$i]->setVar("key", $fieldName);
	}
}

if ($HTTP_GET_VARS['commit']) {
	// Apply changes from records.php
	$Ui->Cce->setObject('System', 
		array("commit" => $HTTP_GET_VARS['commit']), 'DNS');
	$Ui->Cce->commit();
}

$Ui->StartBlock("modifyDNS");
$Ui->SetBlockView( "basic" );

$Ui->Data['commit'] = time();
$Ui->Hidden( "commit" );

$Ui->Boolean( "enabled" );
// $Ui->Boolean( "auto_config" );

$Ui->SetBlockView( "advanced" );


$Ui->Divider( "soa_defaults" );
$Ui->EmailAddress( "admin_email", array( "Optional" => 'loud' )  );
$Ui->Integer( "default_refresh", 1, 4096000);
$Ui->Integer( "default_retry", 1, 4096000);
$Ui->Integer( "default_expire", 1, 4096000);
$Ui->Integer( "default_ttl", 1, 4096000);

$Ui->Divider( "global_settings" );
$Ui->Boolean( "caching" );
$Ui->IpAddressList( "forwarders", array( "Optional" => 'loud' ) );
$Ui->IpAddressList( "zone_xfer_ipaddr", array( "Optional" => 'loud') );

// Zone File Format tab
$Ui->SetBlockView( "zone_format_tab" );
$Ui->Divider( "zone_format_settings_divider" );
$Ui->Alters( "zone_format", array('RFC2317','DION','OCN-JT','USER'));
$Ui->Divider( "zone_format_user_defined_divider" );
$Ui->TextField( "zone_format_24", array( "Optional" => 'loud' ) );
$Ui->TextField( "zone_format_16", array( "Optional" => 'loud' ) );
$Ui->TextField( "zone_format_8", array( "Optional" => 'loud' ) );
$Ui->TextField( "zone_format_0", array( "Optional" => 'loud' ) );

$Ui->AddSaveButton();

$Ui->EndBlock();


include_once("ServerScriptHelper.php");
$serverScriptHelper = new ServerScriptHelper();
$factory = $serverScriptHelper->getHtmlComponentFactory("base-dns");
$primaryButton = $factory->getButton('/base/dns/records.php', 'primary_service_button');
$secondaryButton = $factory->getButton('/base/dns/dns_sec_list.php', 'secondary_service_button');
$serverScriptHelper->destructor();

$Ui->AppendAfterHeaders("<TABLE><TR><TD>".$primaryButton->toHtml()."</TD><TD>".$secondaryButton->toHtml()."</TD></TR></TABLE><BR>");

$Ui->EndPage();

/*
function get_zonetypes() {
	$zones = array();
	$selfflags = array();
	//$oldcontents[] = file($ZoneConf);
	//$oldcontent = join ('', $oldcontents);
	$ConfDir = "/etc";
	if ( $handle = opendir($ConfDir)) {
		while( $file = readdir($handle)) {
			if( ! preg_match( "/^cobaltdns.(.*)$/", $file, $format))
				continue;
			if ( $format[1] == "conf")
				 continue;
			$zones[] = $format[1];
			//$content = join ('', file ($ConfDir."/".$File));
			//if ( $content == $oldcontents)
			//$selfflags[$format] = "selected";
		}
	}
	return $zones;
}
*/
?>
                                                                                                              ui/web/dns_amdetails.php                                                                            0100644 0000000 0000156 00000001035 07363454743 013415  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   <?
// Author: Tim Hockin
// Copyright 2000, Cobalt Networks.  All rights reserved.

include_once("ServerScriptHelper.php");
include("base/am/am_detail.inc");

$serverScriptHelper = new ServerScriptHelper();
$cce = $serverScriptHelper->getCceClient();
$factory = $serverScriptHelper->getHtmlComponentFactory("base-am");
$page = $factory->getPage();

print($page->toHeaderHtml());

am_detail_block($factory, $cce, "DNS", "[[base-dns.amDetailsTitle]]");
am_back($factory);

print($page->toFooterHtml());

$serverScriptHelper->destructor();

?>
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   ui/web/dns_sec.php                                                                                  0100644 0000000 0000156 00000012307 07155763125 012224  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   <?php
// $Id: dns_add_records.pl 259 2004-01-03 06:28:40Z shibuya $
//
// ui for adding/modifying many DNS record types
$iam = '/base/dns/dns_sec.php';
$parent = '/base/dns/dns_sec_list.php';

include("CobaltUI.php");
$Ui = new CobaltUI($sessionId, "base-dns"); 

// return the base ip address of a network
// as defined by dot-quad member ip and netmask
function get_network($ip = "127.0.0.1", $nm = "255.255.255.255") {
  $ip = split('[.]',$ip);
  $nm = split('[.]',$nm);
  for ($i=0; $i<4; $i++):
    $ip[$i] = (int) $ip[$i]; $nm[$i] = (int) $nm[$i];
    $nu[$i] .= $ip[$i] & $nm[$i];
  endfor;

  return join('.',$nu);
}

// mapping: lists a form field name to an object attribute.
$mapping = array (
  "slave_domain" => "domain",
  "slave_netmask" => "netmask",
  "slave_ipaddr" => "ipaddr",
  "slave_dom_masters" => "masters",
  "slave_net_masters" => "masters" );

$nm_to_dec = array(
  "0.0.0.0"   => "0",
  "128.0.0.0" => "1",	"255.128.0.0" => "9",	"255.255.128.0" => "17",	"255.255.255.128" => "25",
  "192.0.0.0" => "2", 	"255.192.0.0" => "10",	"255.255.192.0" => "18",	"255.255.255.192" => "26",
  "224.0.0.0" => "3",	"255.224.0.0" => "11",	"255.255.224.0" => "19",	"255.255.255.224" => "27",
  "240.0.0.0" => "4",	"255.240.0.0" => "12",	"255.255.240.0" => "20",	"255.255.255.240" => "28",
  "248.0.0.0" => "5",	"255.248.0.0" => "13",	"255.255.248.0" => "21",	"255.255.255.248" => "29",
  "252.0.0.0" => "6",	"255.252.0.0" => "14",	"255.255.252.0" => "22",	"255.255.255.252" => "30",
  "254.0.0.0" => "7",	"255.254.0.0" => "15",	"255.255.248.0" => "23",	"255.255.255.254" => "31",
  "255.0.0.0" => "8",	"255.255.0.0" => "16",	"255.255.255.0" => "24",	"255.255.255.255" => "32" );

// handler:
if (!$_TARGET) { $_TARGET = $HTTP_GET_VARS['_LOAD']; }
$done = handle($Ui, $_TARGET, $mapping, $HTTP_POST_VARS, $HTTP_GET_VARS, $nm_to_dec);

# prevent PHP from sneakily adding new hidden fields:
if (is_array($HTTP_POST_VARS)) {
  $keys = array_keys($HTTP_POST_VARS);
  $index = array_keys($keys, "_LOAD"); array_splice($HTTP_POST_VARS, $index[0], 1);
  $index = array_keys($keys, "_save"); array_splice($HTTP_POST_VARS, $index[0], 1);
}

$Ui->StartPage("AAS", $_TARGET ? $_TARGET : "DnsSlaveZone", "");
$Ui->StartBlock((intval($_TARGET) > 0) ? "modify_slave_rec" : "create_slave_rec");

// Bail if we've saved successfully
if ($done) {
  $Ui->Redirect( $parent );
  exit();
}

if ($HTTP_GET_VARS{'TYPE'} == 'NETWORK') {

  // secondary network auth
  if ($Ui->Data['slave_netmask'] == '') { $Ui->Data['slave_netmask'] = '255.255.255.0'; }
  $Ui->SetBlockView( "slave_network_but" );
  $Ui->IpAddress( "slave_ipaddr" );
  $Ui->IpAddress( "slave_netmask" );
  $Ui->IpAddress( "slave_net_masters" );

} else {

  // secondary domain auth
  $Ui->SetBlockView( "slave_domain_but" );
  $Ui->DomainName( "slave_domain" );
  $Ui->IpAddress( "slave_dom_masters" );

}

$Ui->AddButtons($parent);

$Ui->EndBlock();
$Ui->EndPage();



function handle(&$Ui, $target, &$mapping, &$post_vars, &$get_vars, &$nm_to_dec)
{
  // echo "<b>handle $target</b><br>";
  
  // Set Defaults that can't be grabbed from CCE....
  $Ui->Data["moderator"]="admin";

  $http_vars = array();
  if (is_array($post_vars)) { 
    $http_vars = array_merge($http_vars, $post_vars); 
  }
  if (is_array($get_vars)) {
    $http_vars = array_merge($http_vars, $get_vars);
  }

  if ($http_vars["_LOAD"]) {
    if (intval($target) > 0) {
      handle_load($Ui, intval($target)); 
    }
  } else {
    handle_post($Ui, $target, $mapping, $http_vars);
  }
  
  if ($post_vars["_save"]==1) {
    return update_cce($Ui, $target, $mapping, $http_vars, $nm_to_dec);
  }
  
  return 0;
}
  
function handle_load(&$Ui, $oid)
{
  // load object attributes
  $rec = $Ui->Cce->get($oid);
  
  $Ui->Data['slave_domain'] = $rec['domain'];
  $Ui->Data['slave_ipaddr'] = $rec['ipaddr'];
  $Ui->Data['slave_netmask'] = $rec['netmask'];

  if($rec['ipaddr'] == '') {
    $Ui->Data['slave_dom_masters'] = $rec['masters'];
  } else {
    $Ui->Data['slave_net_masters'] = $rec['masters'];
  }
}

function handle_post(&$ui, $target, &$mapping, &$post_vars)
{
  while (list($key,$val) = each($mapping))
  {
    $ui->Data[$key] = $post_vars[$key];
  }
}

# translate post variables into an object hash based on $mapping.
# $mapping maps "Form Field Name" => "Object Attribute Name"
function map_vars($mapping, $post_vars)
{
  $obj = array();
  while (list($key,$val) = each($mapping))
  {
    if($post_vars[$key] != "") {
      $obj[$val] = $post_vars[$key];
    }
  }
  return $obj;
}

function update_cce(&$Ui, $target, $mapping, $http_vars, $nm_to_dec)
{
  $oid = 0;

  if (intval($target) > 0) {

    // modify record, its type is fixed
    $oid = intval($target);
    $Ui->Cce->set ($oid, "", map_vars($mapping, $http_vars));
    // $Ui->Cce->set ($oid, "Archive", map_vars($mapping, $http_vars));

  } else {

    $class = $target;
    $oid = $Ui->Cce->create( 'DnsSlaveZone', map_vars($mapping, $http_vars));
  
  }

  $flip_map = array_flip($mapping); // maps attributes -> form field names (1:many)

  // hack around 1:many reverse mapping
  if ($http_vars['slave_dom_masters'] != '') {
    $flip_map['masters'] = 'slave_dom_masters';
  } else {
    $flip_map['masters'] = 'slave_net_masters';
  }

  $Ui->report_errors($flip_map);

  return (count($errors) == 0);
}
  

?>
                                                                                                                                                                                                                                                                                                                         ui/web/dns_sec_list.php                                                                             0100644 0000000 0000156 00000006260 07363454743 013264  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   <?php
// List secondary dns authorities
// TODO: promote secondary to primaries
// Copyright 2000, Cobalt Networks.  All rights reserved.
// $Id: dns_add_records.pl 259 2004-01-03 06:28:40Z shibuya $
$iam = '/base/dns/dns_sec_list.php';
$edit = '/base/dns/dns_sec.php';
$parent = '/base/dns/dns.php';

include_once("ServerScriptHelper.php");

$serverScriptHelper = new ServerScriptHelper() or die ("no SSH");
$cceClient = $serverScriptHelper->getCceClient() or die ("no CCE");
$factory = $serverScriptHelper->getHtmlComponentFactory(
	"base-dns", $iam);
$i18n = $serverScriptHelper->getI18n("base-dns") or die ("no i18n");

$page = $factory->getPage();

// deal with remove actions
if ($_REMOVE) {
  $cceClient->destroy($_REMOVE);
}

// Grab system-DNS data
$sys_oid = $cceClient->find('System');
$sys_dns = $cceClient->get($sys_oid, 'DNS');

// pull-down add secondary service
$addList = array(	"add_secondary_forward" => "$edit?TYPE=FORWARD",
			"add_secondary_network" => "$edit?TYPE=NETWORK");
$addButton = $factory->getMultiButton("add_secondary", array_values($addList), array_keys($addList));

// build scroll list of mailing lists
$scrollList = $factory->getScrollList("sec_list", array("sec_authority", "sec_primaries", 'listAction'), array(0, 1));
$scrollList->setAlignments(array("left", "left", "center"));
$scrollList->setColumnWidths(array("", "", "1%"));

// $scrollList->addButton($factory->getAddButton($edit));

// populate elements in the scroll list
$oids = $cceClient->find("DnsSlaveZone");

for ($i = 0; $i < count($oids); $i++) {
  if ($oids[$i] != '') {
    $oid = $oids[$i];
    $rec = $cceClient->get($oid, "");

    if($rec['ipaddr'] != '') {
      $label = $rec['ipaddr'].'/'.$rec['netmask'];
      $type = 'NETWORK';
    } else {
      // domain auth
      $label = $rec['domain'];
      $type = 'DOMAIN';
    }

    $msg = $i18n->get("confirm_removal_of_sec");  // .$label.'?';

    $scrollList->addEntry( array(
      $factory->getTextField("", $label, "r"),
      $factory->getTextField("", $rec['masters'], "r"),
      $factory->getCompositeFormField(array(
        $factory->getModifyButton(
          "$edit?_TARGET=$oid&_LOAD=1&TYPE=$type" ),
        $factory->getRemoveButton(
          "javascript: confirmRemove('$msg', '$oid', '$label')")
      ))
    ));
  }
}

print $page->toHeaderHtml();

?>

<SCRIPT LANGUAGE="javascript">
function confirmRemove(msg, oid, label) {
	msg = top.code.string_substitute(msg, "[[VAR.rec]]", label);
  if(confirm(msg))
    location = "<?php print $iam; ?>?_REMOVE=" + oid;
}
</SCRIPT>

<?php

print $addButton->toHtml();
print '<BR><BR>';

print $scrollList->toHtml();
print '<P>';

// Add commit and back buttons -- hack around uifc single-button formatting limitations
$commit_time = time();
$commitButton = $factory->getButton("/base/dns/dns.php?commit=$commit_time", "apply_changes");
if($sys_dns['dirty'] == 0) {
  $commitButton->setDisabled(true);
}

$backButton = $factory->getBackButton($parent);
?>

<P>

<CENTER>
<TABLE BORDER=0 CELLSPACING=2 CELLPADDING=2>
<TR>
    <TD NOWRAP>
    <?php print($commitButton->toHtml()); ?>
    </TD>
    <TD NOWRAP>
    <?php print($backButton->toHtml()); ?>
    </TD>
</TR>
</TABLE>


<?php print $page->toFooterHtml(); ?>



                                                                                                                                                                                                                                                                                                                                                ui/web/dns_soa.php                                                                                  0100644 0000000 0000156 00000011510 07332045501 012213  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   <?php
// $Id: dns_add_records.pl 259 2004-01-03 06:28:40Z shibuya $
//
// ui for adding/modifying many DNS record types
$iam = '/base/dns/dns_add.php';
$parent = '/base/dns/records.php';

// preserve the selected authority in the records list
if ($HTTP_GET_VARS{'domauth'} != '') {
  $ret_url = $parent.'?domauth='.$HTTP_GET_VARS{'domauth'};
} elseif ($HTTP_GET_VARS{'netauth'} != '') {
  $ret_url = $parent.'?netauth='.urlencode($HTTP_GET_VARS{'netauth'});
} else {
  $ret_url = $parent;
}

include("CobaltUI.php");
$Ui = new CobaltUI($sessionId, "base-dns"); 

// mapping: lists a form field name to an object attribute.
$mapping = array (
  "primary_dns" => "primary_dns",
  "secondary_dns" => "secondary_dns",
  "domain_admin" => "domain_admin",
  "refresh" => "refresh",
  "retry" => "retry",
  "expire" => "expire",
  "ttl" => "ttl" );

// handler:
if (!$_TARGET) { $_TARGET = $HTTP_GET_VARS['_LOAD']; }
$done = handle($Ui, $_TARGET, $mapping, $HTTP_POST_VARS, $HTTP_GET_VARS);

# prevent PHP from sneakily adding new hidden fields:
if (is_array($HTTP_POST_VARS)) {
  $keys = array_keys($HTTP_POST_VARS);
  $index = array_keys($keys, "_LOAD"); array_splice($HTTP_POST_VARS, $index[0], 1);
  $index = array_keys($keys, "_save"); array_splice($HTTP_POST_VARS, $index[0], 1);
}

// render table title
// $table_title = $18n->get( (intval($_TARGET) > 0) ? "modify_soa" : "create_soa" );
// if($Ui->Data['domainname']) {
//   $table_title .= '   -   '.$Ui->Data['domainname'];
// } else {
//   $table_title .= '   -   '.$Ui->Data['ipaddr'].' / '.$Ui->Data['netmask'];
// }

error_log("Starting page...");
error_log("Target $_TARGET");
$Ui->StartPage("SET", $_TARGET ? $_TARGET : "DnsSOA", "");

error_log("Starting block...");
error_log(intval($_TARGET));
$Ui->StartBlock((intval($_TARGET) > 0) ? "modify_soa" : "create_soa");

// Return to the records list on successful save
if ($done) {
  $Ui->Redirect( $ret_url );
  exit();
}

//  $Ui->Data['ipaddr'] = $rec['ipaddr'];
//  $Ui->Data['netmask'] = $rec['netmask'];

error_log("Filling in fields...");
if($Ui->Data['domainname'] != '') {
  $Ui->Data['domain_soa'] = $Ui->Data['domainname'];
  $Ui->TextField( 'domain_soa', array( 'access' => 'r' ) );
} else {
  $Ui->Data['network_soa'] = $Ui->Data['ipaddr'].'/'.$Ui->Data['netmask'];
  $Ui->TextField( 'network_soa', array( 'access' => 'r' ) );
}

$Ui->DomainName( "primary_dns", array( "Optional" => "loud" ) );
$Ui->DomainNameList( "secondary_dns", array( "Optional" => "loud" ) );
$Ui->EmailAddress( "domain_admin", array( "Optional" => "silent" ) );
$Ui->Integer( "refresh", 1, 4096000);
$Ui->Integer( "retry", 1, 4096000);
$Ui->Integer( "expire", 1, 4096000);
$Ui->Integer( "ttl", 1, 4096000);

$Ui->AddButtons($ret_url);

$Ui->EndBlock();
$Ui->EndPage();

function handle(&$Ui, $target, $mapping, &$post_vars, &$get_vars)
{
  // echo "<b>handle $target</b><br>";

  // Set Defaults that can't be grabbed from CCE....
  $Ui->Data["moderator"]="admin";

  $http_vars = array();
  if (is_array($post_vars)) {
    $http_vars = array_merge($http_vars, $post_vars);
  }
  if (is_array($get_vars)) {
    $http_vars = array_merge($http_vars, $get_vars);
  }

  if ($http_vars["_LOAD"]) {
    if (intval($target) > 0) {
      handle_load($Ui, $target);
    }
  } else {
    handle_post($Ui, $target, $mapping, $http_vars);
  }

  if ($post_vars["_save"]==1) {
    return update_cce($Ui, $target, $mapping, $http_vars);
  }

  return 0;
}

function handle_load(&$Ui, $oid)
{
  // load object attributes
  $rec = $Ui->Cce->get($oid);
  $Ui->Data['primary_dns'] = $rec['primary_dns'];
  $Ui->Data['secondary_dns'] = $rec['secondary_dns'];
  $Ui->Data['domain_admin'] = $rec['domain_admin'];
  $Ui->Data['refresh'] = $rec['refresh'];
  $Ui->Data['retry'] = $rec['retry'];
  $Ui->Data['expire'] = $rec['expire'];
  $Ui->Data['ttl'] = $rec['ttl'];
  $Ui->Data['domainname'] = $rec['domainname'];
  $Ui->Data['ipaddr'] = $rec['ipaddr'];
  $Ui->Data['netmask'] = $rec['netmask'];
}

function handle_post(&$ui, $target, &$mapping, &$post_vars)
{
  while (list($key,$val) = each($mapping))
  {
    $ui->Data[$key] = $post_vars[$key];
  }
}

# translate post variables into an object hash based on $mapping.
# $mapping maps "Form Field Name" => "Object Attribute Name"
function map_vars($mapping, $post_vars)
{
  $obj = array();
  while (list($key,$val) = each($mapping))
  {
    if($post_vars[$key] != "") {
      $obj[$val] = $post_vars[$key];
    } elseif (preg_match ("(primary_dns|secondary_dns|domain_admin)", $val)) {
      $obj[$val] = "";
    }
  }
  return $obj;
}

function update_cce(&$Ui, $target, $mapping, $http_vars)
{
  $oid = 0;
  if (intval($target) > 0) {

    $oid = intval($target);
    $Ui->Cce->set ($oid, "", map_vars($mapping, $http_vars));

  } else {

    $class = $target;
    $oid = $Ui->Cce->create( 'DnsSOA', map_vars($mapping, $http_vars));

  }
  $Ui->report_errors($mapping);
  return (count($errors) == 0);
}


?>
                                                                                                                                                                                        ui/web/records.php                                                                                  0100644 0000000 0000156 00000027073 07446245767 012267  0                                                                                                    ustar   root                                                                                                                                                                                                                                                   <?php
/*
 * Copyright 2000-2002 Sun Microsystems, Inc.  All rights reserved.
 * $Id: dns_add_records.pl 259 2004-01-03 06:28:40Z shibuya $
 */
include_once("ServerScriptHelper.php");

$iam = '/base/dns/records.php';
$addmod = '/base/dns/dns_add.php';
$soamod = '/base/dns/dns_soa.php';

$serverScriptHelper = new ServerScriptHelper() or die ("no server-script-helper");
$i18n = $serverScriptHelper->getI18n("base-dns");
$confirm_removal = $i18n->get('confirm_removal');
$confirm_delall = $i18n->get('confirm_delall');
$cceClient = $serverScriptHelper->getCceClient() or die ("no CCE");
$factory = $serverScriptHelper->getHtmlComponentFactory("base-dns", $iam);
$records_title_separator = '   -   ';

$nm_to_dec = array(
	"0.0.0.0"   => "0",
	"128.0.0.0" => "1", "255.128.0.0" => "9",  "255.255.128.0" => "17", "255.255.255.128" => "25",
	"192.0.0.0" => "2", "255.192.0.0" => "10", "255.255.192.0" => "18", "255.255.255.192" => "26",
	"224.0.0.0" => "3", "255.224.0.0" => "11", "255.255.224.0" => "19", "255.255.255.224" => "27",
	"240.0.0.0" => "4", "255.240.0.0" => "12", "255.255.240.0" => "20", "255.255.255.240" => "28",
	"248.0.0.0" => "5", "255.248.0.0" => "13", "255.255.248.0" => "21", "255.255.255.248" => "29",
	"252.0.0.0" => "6", "255.252.0.0" => "14", "255.255.252.0" => "22", "255.255.255.252" => "30",
	"254.0.0.0" => "7", "255.254.0.0" => "15", "255.255.248.0" => "23", "255.255.255.254" => "31",
	"255.0.0.0" => "8", "255.255.0.0" => "16", "255.255.255.0" => "24", "255.255.255.255" => "32" );
$dec_to_nm = array_flip($nm_to_dec);

// start our scrolling list
$page = $factory->getPage();

// deal with remove actions
$errors = array();
if ($_REMOVE) {
	$cceClient->destroy($_REMOVE);
	$errors = $cceClient->errors();
}
if ($_DELMANY) {
	$death_row = split('x', $_DELMANY);

	rsort($death_row);
	for ($i = 0; $i < $death_row[0]; $i++) {
		if($death_row[$i] != '') {
			$cceClient->destroy($death_row[$i]);
		}
	}
	$errors = $cceClient->errors();
}

// Grab system-DNS data
$sys_oid = $cceClient->find('System');
$sys_dns = $cceClient->get($sys_oid, 'DNS');

// Abstract our authorities list
// build a pull-down menu, select a default authority
$oids = $cceClient->find("DnsSOA");
$rec_oids = array();
$smallnet = array();
$auth_dom_oids = array();
$auth_net_oids = array();

rsort($oids);
if(count($oids)) { // Any current records?
	for ($i = 0; $i <= $oids[0]; $i++) {
		if($oids[$i] != '') {
			$rec = $cceClient->get($oids[$i], "");

			if ($rec["domainname"] != "") {
				$authorities_dom[$rec["domainname"]] = "$iam?domauth=".urlencode($rec["domainname"]);
				$authorities_dom_label[$rec["domainname"]] = "$iam?domauth=".urlencode($rec["domainname"]);
				$auth_oids[$rec['domainname']] = $oids[$i];
				array_push($auth_dom_oids, $oids[$i]);
				if($default_domauth == '') { $default_domauth = $rec['domainname']; }
			}

			if ($rec["ipaddr"] != "") {
				$network_label = $rec["ipaddr"].'/'.$rec["netmask"];
				$network = $rec["ipaddr"].'/'.$nm_to_dec[$rec["netmask"]];
				$authorities_net[$network] = "$iam?netauth=".urlencode($network);
				$authorities_net_label[$network_label] = "$iam?netauth=".urlencode($network);
				$auth_oids[$network] = $oids[$i];
				array_push($auth_net_oids, $oids[$i]);
				if($default_netauth == '') { $default_netauth = urlencode($network); }
			}

		}
	}
}

// Actually default
$title_authority = $domauth;
if ($title_authority == '') {
	$title_authority = urldecode($netauth);
}
if (($domauth == '') && ($netauth == '')) { 
	$domauth = $default_domauth;
	if ($title_authority == '') {
		$title_authority = $default_domauth;
	}
	$netauth = $default_netauth; 
	if ($title_authority == '') {
		$title_authority = urldecode($default_netauth);
	}
}
if ($title_authority != '') { 
	$title_members = split('/', $title_authority);
	$title_authority = $records_title_separator . $title_members[0];
	if ($title_members[1] != '') {
		$title_authority .= '/' . $dec_to_nm[$title_members[1]];
	}
}

// start the table
$block = $factory->getScrollList($i18n->get('dnsSetting') . $title_authority,
				 array("source", "direction", "resolution",
				       "listAction"),
				 array(1,0,2));
$block->setAlignments(array("left", "center", "left", "center"));
$block->setColumnWidths(array("", "", "", "1%"));
$block->setLength(999999);

/*
 * Preserve the selected authority between menus by appending the 
 * $auth_link to hyperlinks
 */
if($domauth != '') {
	$domauth = urldecode($domauth);
	$rec_oids = $cceClient->find("DnsRecord",
				      array('domainname' => $domauth));
	$auth_link = '&domauth=' . $domauth;
	$block->addButton($factory->getButton("$soamod?_LOAD=" . $auth_oids[$domauth] . $auth_link,"edit_soa"));
	$many_oids = join('x', $rec_oids);
	$block->addButton($factory->getButton("javascript: confirmDelAll(strConfirmDelAll, '_DELMANY=$many_oids');", 'del_records'));

} else if ($netauth != '') {

	$netauth = urldecode($netauth);
	$rec_oids = $cceClient->find("DnsRecord", array('network' => $netauth));
	$auth_link = '&netauth=' . urlencode($netauth);
	$block->addButton($factory->getButton("$soamod?_LOAD=" . $auth_oids[$netauth] . $auth_link,"edit_soa"));
	$many_oids = join('x', $rec_oids);
	$block->addButton($factory->getButton("javascript: confirmDelAll(strConfirmDelAll, '_DELMANY=$many_oids');", 'del_records'));

}

if (count($rec_oids) == 0) {
	$rec_oids = $cceClient->find("DnsRecord");
}


//  Array of labels => actions for "add a record" menu
$addRecordsList = array("a_record" => "dns_add.php?TYPE=A" . $auth_link,
			"ptr_record" => "dns_add.php?TYPE=PTR" . $auth_link,
			"mx_record" => "dns_add.php?TYPE=MX" . $auth_link,
			"cname_record" => "dns_add.php?TYPE=CNAME" . $auth_link);

				
if ($domauth != '') {
	$addRecordsList['subdom'] = "dns_add.php?TYPE=SUBDOM" . $auth_link;
} else if ($netauth != '') {
	$addRecordsList['subnet'] = "dns_add.php?TYPE=SUBNET" . $auth_link;
}

$addButton = $factory->getMultiButton("add_record",
				      array_values($addRecordsList),
				      array_keys($addRecordsList));

// display records
rsort($rec_oids);
if(count($rec_oids)) { 
	for ($i = 0; $i < $rec_oids[0]; $i++) {
		if($rec_oids[$i] != '') {
			$oid = $rec_oids[$i];
			$rec = $cceClient->get($oid, "");

			/*
			 * we could add a recordtype if structure to build the 
			 * scrollist entries aesthetically
			 * all records define 
			 * { $source, $direction, $resolution, $label }
			 */
			$direction = $rec['type'];
			$resolution = '';
			$source = '';
		
			if ($rec['type'] == 'A') {
				if($rec['hostname']) { 
					$source = $rec['hostname'] . ' . '; 
				}
				$source .= $rec['domainname'];
				$direction = $i18n->get('a_dir');
				$resolution = $rec['ipaddr'];
				$label = $rec['hostname'] . '.' .
					$rec['domainname'];

			} else if($rec['type'] == 'PTR') {
				$source = $rec['ipaddr'];
				if ($domauth) {
					$source .= '/' . $rec['netmask'];
				}
				if ($rec['hostname'] != '') { 
					$resolution = $rec['hostname'] . ' . '; 
				}
				$direction = $i18n->get('ptr_dir');
				$resolution .= $rec['domainname'];
				$label = $rec['ipaddr'] . '/' . $rec['netmask'];

			} else if ($rec['type'] == 'CNAME') {
				if($rec['hostname'] != '') { 
					$source = $rec['hostname'].' . '; 
				} 
				$source .= $rec['domainname'];
				$direction = $i18n->get('cname_dir');
				if ($rec['alias_hostname'] != '') {
					$resolution = $rec['alias_hostname'] .
						' . ';
				}
				$resolution .= $rec['alias_domainname'];
				$label = $rec['alias_hostname'] . '.' .
					$rec['domainname'];

			} else if ($rec['type'] == 'MX') {
				if($rec['hostname']) { 
					$source = $rec['hostname'] . ' . '; 
				}
				$source .= $rec['domainname'];
				$resolution = $rec['mail_server_name'];
				$direction = $i18n->get('mx_dir_' . 
					$rec['mail_server_priority']);
				$label = $rec['hostname'] . '.' .
					$rec['domainname'];

			} else if ($rec['type'] == 'SN') {
				if($rec['ipaddr']) { 
					$rec['type'] = 'SUBNET';
					$direction = $i18n->get('subnet_dir');

					$smallnet = split('/', $rec['network_delegate']);
					$source = $smallnet[0] . '/' .
						$dec_to_nm[$smallnet[1]];
					$resolution = $rec['delegate_dns_servers'];
					$label = $rec['ipaddr'] . '/' .
						$rec["netmask"];
				} else {
					$rec['type'] = 'SUBDOM';
					$direction = $i18n->get('subdom_dir');

					$source = $rec['hostname'].' . '.$rec['domainname'];
					$resolution = $rec['delegate_dns_servers'];
					$label = $rec['hostname'].'.'.$rec['domainname'];
				}
				$resolution = ereg_replace('^&', '', $resolution);
				$resolution = ereg_replace('&$', '', $resolution);
				$resolution = ereg_replace('&', ' ', $resolution);
			} else {
				next;
				echo "unkown type: ".$rec['type']."\n";
			}
	
			$block->addEntry(array(
				$factory->getTextField("", $source, "r"),
				$factory->getTextField("", $direction, "r"),
				$factory->getTextField("", $resolution, "r"),
				$factory->getCompositeFormField(array(
					$factory->getModifyButton( "$addmod?_PagedBlock_selectedId_blockid0=_".$rec['type']."&_TARGET=$oid&_LOAD=1&TYPE=".$rec['type'].$auth_link ),
					$factory->getRemoveButton( "javascript: confirmRemove(strConfirmRemoval, '$oid', '$label', '$domauth', '$netauth')" )
	
				))
			));
		}
	}
}

$domauthRemember = $factory->getTextField('domauth', $domauth, '');
$domauthRemember->setPreserveData(false);
$netauthRemember = $factory->getTextField('netauth', $netauth, '');
$netauthRemember->setPreserveData(false);

$serverScriptHelper->destructor();

print($page->toHeaderHtml());
?>
<SCRIPT LANGUAGE="javascript">
// these need to be defined seperately or Japanese gets corrupted
var strConfirmRemoval = '<?php print $confirm_removal; ?>';
var strConfirmDelAll = '<?php print $confirm_delall; ?>';
</SCRIPT>
<?
print $domauthRemember->toHtml();
print $netauthRemember->toHtml();

if(count($authorities_dom_label) > 0) {
	// select-an-authority button
	ksort($authorities_dom_label);
	$authorityDomButton = $factory->getMultiButton("select_dom", array_values($authorities_dom_label), array_keys($authorities_dom_label));
	print($authorityDomButton->toHtml());
	print("&nbsp;");
}
if(count($authorities_net_label) > 0) {
	// select-an-authority button
	ksort($authorities_net_label);
	$authorityNetButton = $factory->getMultiButton("select_net", array_values($authorities_net_label), array_keys($authorities_net_label));
	print($authorityNetButton->toHtml());
	// print("&nbsp;");
	print("&nbsp;");
}

print($addButton->toHtml());
print("<P>");


print($block->toHtml()); 

// Add commit and back buttons -- hack around uifc single-button formatting limitations
// Gray-out the commit button if there are no uncommitted changes
// print "Sys oid: $sys_oid, sys_dirty: ".$sys_dns['dirty'];
$commit_time = time();
$commitButton = $factory->getButton("/base/dns/dns.php?commit=$commit_time", "apply_changes");
if($sys_dns['dirty'] == 0) {
	$commitButton->setDisabled(true);
}

$backButton = $factory->getBackButton("/base/dns/dns.php");
?>

<SCRIPT LANGUAGE="javascript">
function confirmRemove(msg, oid, label, domauth, netauth) {
	// var msg = "<?php print($i18n->get("removeUserConfirm"))?>";
	msg = top.code.string_substitute(msg, "[[VAR.rec]]", label);
	 
	if(confirm(msg))
		location = "/base/dns/records.php?_REMOVE=" + oid +
			"&domauth=" + domauth + "&netauth=" + netauth;
}

function confirmDelAll(msg, url) {
	if(confirm(msg))
		location = "/base/dns/records.php?" + url;
}
</SCRIPT>

<BR>

<TABLE BORDER=0 CELLSPACING=2 CELLPADDING=2>
<TR>
		<TD NOWRAP>
		<?php print($commitButton->toHtml()); ?>
		</TD>
		<TD NOWRAP>
		<?php print($backButton->toHtml()); ?>
		</TD>
</TR>
</TABLE>
	
<?php
// output any error messages
if (count($errors) > 0) {
	print "<SCRIPT LANGUAGE=\"javascript\">\n";
	print $serverScriptHelper->toErrorJavascript($errors);
	print "</SCRIPT>\n";
}
	
print($page->toFooterHtml());
?>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     # Copyright (c) 2003 Sun Microsystems, Inc. All  Rights Reserved.
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
