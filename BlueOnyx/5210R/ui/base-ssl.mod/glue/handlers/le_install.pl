#!/usr/bin/perl -I/usr/sausalito/perl
# $Id: le_install.pl
#

# Debugging switch (0|1):
# 0 = off
# 1 = log to syslog
$DEBUG = "0";
if ($DEBUG) {
    use Sys::Syslog qw( :DEFAULT setlogsock);
    use Data::Dumper;
}

use CCE;
use lib qw(/usr/sausalito/perl /usr/sausalito/handlers/base/ssl);
use Sauce::Service;
use Base::Vsite qw(vsite_update_site_admin_caps);
use Base::HomeDir qw(homedir_get_group_dir);
use SSL qw(ssl_get_cert_info ssl_create_directory);
use JSON;

my $cce = new CCE('Domain' => 'base-ssl');
$cce->connectfd();

# Get Vsite and ssl information for the Vsite:
$vsite = $cce->event_object();
$oid = $cce->event_oid();
($ok, $ssl_info) = $cce->get($oid, 'SSL');
$ssl = $cce->event_object();
$ssl_old = $cce->event_old();
$ssl_new = $cce->event_new();

if ($ssl_info->{'performLEinstall'} eq "") {
    &debug_msg("Not using LE for this SSL certificiate install.\n");
    $cce->bye('SUCCESS');
    exit(0);
}

if ($vsite->{'name'}) {
    $siteName = $vsite->{'name'};
}
else {
    $siteName = '';
}

&debug_msg("Performing LE SSL install for $vsite->{'CLASS'} $siteName\n");

if (($vsite->{'CLASS'} eq "Vsite") || ($vsite->{'CLASS'} eq "System")) {

    if ($vsite->{'CLASS'} eq "Vsite") {
        $fqdn = $vsite->{'fqdn'};
    }
    elsif ($vsite->{'CLASS'} eq "System") {
        $fqdn = $vsite->{'hostname'} . '.' . $vsite->{'domainname'};
    }
    else {
        &debug_msg("WARNING: Unable to detect fqdn!\n");
        $cce->bye('FAIL', "[[base-ssl.LE_CA_Request_FQDN_Error]]"); 
        exit(1); 
    }

    &debug_msg("FQDN: $fqdn\n");

    # Get WebAliases:
    $alias_line = '';
    if ($vsite->{'CLASS'} eq "Vsite") {
        @webAliases = $cce->scalar_to_array($ssl_info->{LEwantedAliases});
        $numAliases = '0';
        foreach $alias (@webAliases) {
            if ($alias ne "") {
                $alias_line .= '-d ' . $alias . ' ';
                $numAliases++;
            }
        }
        chop($alias_line);

        # Special Case: If 'Web Alias Redirects' is ticked and we request cert validity for more
        # than the primary FQDN, then the validation will fail due to the redirects. Hence:
        # If someone requests validity for more than just FQDN, then we turn 'Web Alias Redirects'
        # off:
        if ($numAliases gt '0') {
            $cce->set($vsite->{'OID'}, '', { 'webAliasRedirects' => '0', 'force_update' => time() });
            &debug_msg("Web-Aliases: Multiple aliases requested. Turning 'webAliasRedirects' off.\n");
        }
    }
    &debug_msg("Web-Aliases: $alias_line\n");

    # Get webroot:
    if ($vsite->{'CLASS'} eq "Vsite") {
        $webroot = $vsite->{'basedir'} . "/web";

        # Find and get System Object:
        ($sysoid) = $cce->find('System');
        ($ok, $System_web) = $cce->get($sysoid, 'Web');
    }
    else {
        $webroot = '/var/www/html';
    }

    # Auto-Renew:
    $autoRenew = '0';
    if ($ssl_info->{'autoRenew'} eq "1") {
        $autoRenew = '1';
    }

    # After how many days do we renew?
    $autoRenewDays = $ssl_info->{'autoRenewDays'};

    # Email:
    $email = '';
    if ($ssl_info->{'LEemail'} ne "") {
        $email = ' --accountemail ' . $ssl_info->{'LEemail'};
    }

    # Old location of the ./well-known directory (we now use '/home/.acme/' instead:)
    $well_known_location = $webroot . '/.well-known';

    # Get certificate directory:
    if ($vsite->{'CLASS'} eq "Vsite") {
        if ($vsite->{basedir}) {
            $cert_dir = "$vsite->{basedir}/$SSL::CERT_DIR";
            &debug_msg("Cert-Directory: $vsite->{basedir}/$SSL::CERT_DIR \n");
        }
        else {
            $cert_dir = homedir_get_group_dir($vsite->{name}, $vsite->{volume}) . '/' . $SSL::CERT_DIR;
        }
    }
    else {
        $cert_dir = '/etc/admserv/certs';
        &debug_msg("Cert-Directory: $cert_dir \n");
    }
    if ($vsite->{'CLASS'} eq "Vsite") {
        if (!-d $cert_dir) {
            if (!ssl_create_directory(02770, scalar(getgrnam($vsite->{name})), $cert_dir)) {
                &debug_msg("Couldn't create $cert_dir!\n");
                $cce->bye('FAIL', "[[base-ssl.CouldnotCreateCertDir]]");
                exit(1);
            }
        }
    }

    if (-f "/usr/sausalito/acme/acme_wrapper.sh") {
        $acme_bin = "/usr/sausalito/acme/acme_wrapper.sh"
    }
    else {
        $acme_bin = "/usr/sausalito/acme/acme.sh"
    }

    # Obtain SSL cert:
    $dry_run = '';
    #$dry_run = "--staging";
    &debug_msg("Running: $acme_bin $dry_run --apache --issue -d $fqdn $alias_line -w /home/.acme/ --keylength 4096 --days $autoRenewDays --cert-file $cert_dir/certificate --key-file $cert_dir/key --fullchain-file $cert_dir/nginx_cert_ca_combined --ca-file $cert_dir/ca-certs --auto-upgrade 1 $email --force --debug --log /var/log/letsencrypt/letsencrypt.log\n");
    $result = `$acme_bin $dry_run --apache --issue -d $fqdn $alias_line -w /home/.acme/ --keylength 4096 --days $autoRenewDays --cert-file $cert_dir/certificate --key-file $cert_dir/key --fullchain-file $cert_dir/nginx_cert_ca_combined --ca-file $cert_dir/ca-certs --auto-upgrade $autoRenew $email --force --debug --log /var/log/letsencrypt/letsencrypt.log 2>&1`;

    $CertFail = '0';

    if ($result =~ /NXDOMAIN/) {
        &clean_well_known;
        &deal_with_services;
        &debug_msg("WARNING: Error during SSL cert request!\n");
        $CertFail = '1';
        $FailMsg = "[[base-ssl.LE_CA_Request_Error]]";
    }

    if ($result =~ /Cert success./) {
        &debug_msg("Certificate request successful!\n");
    }
    else {
        &clean_well_known;
        &deal_with_services;
        &debug_msg("WARNING: Error during SSL cert request!\n");
        $CertFail = '1';
        $FailMsg = "[[base-ssl.LE_CA_Request_Error]]";
    }

    &debug_msg("Checking cert dir: $cert_dir\n");
    if ((-d $cert_dir) && ($cert_dir ne "")) {
        # Check if we have a good cert:
        ($subject, $issuer, $expires) = ssl_get_cert_info($cert_dir);

        &debug_msg("Cert info (subject): "  . Dumper($subject) . "\n");
        &debug_msg("Cert info (Issuer): " . Dumper($issuer) . "\n");
        &debug_msg("Cert info (expires): $expires\n");

        # Make sure this is really a Let's Encrypt cert:
        $uses_letsencrypt = '0';
        if (($issuer->{'O'} eq 'Let\'s Encrypt') || ($issuer->{'CN'} eq 'Fake LE Intermediate X1')) {
            &debug_msg("SSL issuer: Let's Encrypt\n");
            $uses_letsencrypt = '1';
        }

        if (($expires ne "") && ($uses_letsencrypt eq "1")) {
            # Munge date because they changed the strtotime function in php:
            $expires =~ s/(\d{1,2}:\d{2}:\d{2})(\s+)(\d{4,})/$3$2$1/;
            &debug_msg("expires: $expires\n");

            # Update CODB to activate the whole shebang:
            $cce->set($vsite->{'OID'}, 'SSL', { 'uses_letsencrypt' => $uses_letsencrypt, 'country' => 'US', 'state' => 'Other', 'expires' => $expires, 'enabled' => '1', 'email' => $ssl_info->{'LEemail'}, 'orgName' => "Let's Encrypt", 'ACME' => '1', 'LEcreationDate' => time() });
        }
        else {
            # Turn off the 'uses_letsencrypt' flag and fail:
            $cce->set($vsite->{'OID'}, 'SSL', { 'uses_letsencrypt' => $uses_letsencrypt });
            &clean_well_known;
            &deal_with_services;
            &debug_msg("Did not get a valid certificate back!\n");
            $CertFail = '1';
            $FailMsg = "[[base-ssl.doNotHaveValidLECert]]";
        }
    }

    ### Start: To CCE ####
    $Z = '0';
    $cleanedResult = '';
    @ResArray = split("\n",$result);
    foreach my $x (@ResArray) {
        if (($x =~ /^(.*)_(.*)$/) || ($x =~ /(.*)estore(.*)$/) || ($x =~ /^(.*)\] httpd(.*)$/) || ($x =~ /(.*)httpd\.conf(.*)$/)) {
            next;
        }
        if (($Z eq '0') && ($x =~ /^\[(.*)\](.*)$/)) {
            $cleanedResult .= $x . "\n";
        }
        if ($x =~ /(.*)Please check log file for more details(.*)$/) {
            $Z = '1';
        }
    }
    %TheResult = ('Status' => $CertFail, 'Error' => $FailMsg, 'ErrMsg' => $cleanedResult);
    $json_result = encode_json(\%TheResult);

    $cce->set($vsite->{'OID'}, 'SSL', { 'LEclientRet' => $json_result }); 

    ### End: To CCE ####
}

# Cleanup:
&deal_with_services;
&clean_well_known;

$cce->bye('SUCCESS');
exit(0);

#
### Subroutines:
#

sub debug_msg {
    if ($DEBUG eq "1") {
        $msg = shift;
        $user = $ENV{'USER'};
        setlogsock('unix');
        openlog($0,'','user');
        syslog('info', "$ARGV[0]: $msg");
        closelog;
    }
}

sub deal_with_services {
    if ($vsite->{'CLASS'} eq "System") {
        # Reload admserv:
        &debug_msg("Reloading Admserv\n");
        service_run_init('admserv', 'reload');
    }
}

sub clean_well_known {
    &debug_msg("Request logged to delete $well_known_location\n");
    if (-d "$well_known_location") {
        if (($well_known_location ne '') || ($well_known_location ne '/')) {
            &debug_msg("Deleting $well_known_location\n");
            system("rm -Rf $well_known_location");
        }
        else {
            &debug_msg("Not deleting $well_known_location!\n");
        }
    }
    else {
        &debug_msg("Directory $well_known_location no present. Good.\n");
    }
}

# 
# Copyright (c) 2017-2019 Michael Stauber, SOLARSPEED.NET
# Copyright (c) 2017-2019 Team BlueOnyx, BLUEONYX.IT
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
