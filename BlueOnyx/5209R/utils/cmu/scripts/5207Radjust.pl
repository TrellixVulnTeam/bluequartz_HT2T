#!/usr/bin/perl
# $Id: 5207Radjust.pl
use strict;

# If you are not toor, go away :)
die "You must run this script as root\n" if ($< != 0);

use lib "/usr/cmu/perl";
require CmuCfg;

my $cfg = CmuCfg->new(type => 'adjust');
$cfg->parseOpts();

require TreeXml;

my ($cmuXml, $outFile);
if($cfg->isSess) {
        $cmuXml = $cfg->cmuXml;
        $outFile = $cfg->sessXml;
        if(-f $outFile) { $cmuXml = $outFile; }
} else { die "ERROR: no session id given, cannot adjust files\n" }

my $tree = TreeXml::readXml($cmuXml, 0);

$tree->{adjustPlatform} = "5207R";

require Jcode; 
require MIME::Base64; 
import MIME::Base64 qw(decode_base64 encode_base64); 
 
if (defined $tree->{user}) {
	my($uTree, $fqdn, @arr); 
	my ($j, $name); 
	my @keys = keys %{ $tree->{user}}; 

    my @adminCaps = ('serverHttpd', 'serverFTP', 'serverEmail', 'serverDNS', 
                    'serverSNMP', 'serverShell', 'serveriStat', 'serverSSL', 
                    'serverSystemFirewall', 'serverNetwork', 
                    'serverVsite', 'serverTime', 'serverInformation', 
                    'serverServerDesktop', 'serverStatsServerNetwork', 
                    'serverStatsServerWebalizer', 'serverStatsServerWeb', 
                    'serverStatsServerFTP', 'serverStatsServerEmail', 
                    'serverStatsServerDisk', 'serverShowActiveMonitor', 
                    'serverActiveMonitor', 'manageSite','menuServerServerStats', 
                    'managePackage', 'siteAdmin', 'siteSSL', 'siteAnonFTP', 'siteShell', 'siteDNS'); 
 
	foreach my $user (@keys) { 
        my $admin; 
        $uTree = $tree->{user}->{$user}; 
 
        # Check suspend user 
        if (!defined($uTree->{enabled})) { 
                $uTree->{enabled} = 0; 
        } 
        if (!defined($uTree->{ui_enabled})) { 
                $uTree->{ui_enabled} = 0; 
        } 
 
        # Convert encoding to UTF-8 
        if (defined($uTree->{fullName})) { 
                $name = decode_base64($uTree->{fullName}); 
                if(Jcode::getcode($name) ne 'utf8') { 
                        $j = Jcode->new($name); 
                        $uTree->{fullName} = encode_base64($j->utf8, ''); 
                } 
        } 
        if (defined($uTree->{sortName})) { 
                $name = decode_base64($uTree->{sortName}); 
                if(Jcode::getcode($name) ne 'utf8') { 
                        $j = Jcode->new($name); 
                        $uTree->{sortName} = encode_base64($j->utf8, ''); 
                } 
        } 
        if (defined($uTree->{description})) { 
                $name = decode_base64($uTree->{description}); 
                if(Jcode::getcode($name) ne 'utf8') { 
                        $j = Jcode->new($name); 
                        $uTree->{description} = encode_base64($j->utf8, ''); 
                } 
        } 
 
        if (defined($uTree->{Email}->{vacationMsg})) { 
                $name = decode_base64($uTree->{Email}->{vacationMsg}); 
                if(Jcode::getcode($name) ne 'utf8') { 
                        $j = Jcode->new($name); 
                        $uTree->{Email}->{vacationMsg} = encode_base64($j->utf8, ''); 
                } 
        } 
 
        # Convert capabilities 
        next unless(defined $uTree->{capLevels}->{cap}); 
        @arr = @{ $uTree->{capLevels}->{cap} }; 
 
        for(my $i = 0; $i < @arr; $i++) { 
            if($uTree->{capLevels}->{cap}->[$i] eq 'ipPooling') { 
                    $uTree->{capLevels}->{cap}->[$i] = 'serverIpPooling'; 
            } elsif ($uTree->{capLevels}->{cap}->[$i] eq 'controlPower') { 
                    $uTree->{capLevels}->{cap}->[$i] = 'serverPower'; 
            } elsif ($uTree->{capLevels}->{cap}->[$i] eq 'adminUser') { 
                    $admin = 1; 
            } elsif ($uTree->{capLevels}->{cap}->[$i] eq 'siteFrontpage') { 
                    # remove siteFrontpage capability 
                    delete $uTree->{capLevels}->{cap}->[$i]; 
            } 

            # Add forwardEmail capability to site admin 
            if ($uTree->{capLevels}->{cap}->[$i] eq 'siteAdmin') { 
                    push(@{ $uTree->{capLevels}->{cap} }, 'forwardEmail'); 
            } 

            # For RaQ550/5100R 
            if ($tree->{exportPlatform} eq 'RaQ550' || 
                $tree->{exportPlatform} eq '5100R' ||
                $tree->{exportPlatform} eq '5106R' ||
                $tree->{exportPlatform} eq '5107R' ||
                $tree->{exportPlatform} eq '5107R') { 
                if ($admin) { 
                        push(@{ $uTree->{capLevels}->{cap} }, @adminCaps); 
                } 
            } 
        } 
	} 
} 
 
if(defined $tree->{list}) { 
	my($lTree, $fqdn, @arr); 
	my ($j, $name); 
	my @keys = keys %{ $tree->{list} }; 
	foreach my $list (@keys) { 
        $lTree = $tree->{list}->{$list}; 
 
        # Check reply policy 
        if (!defined($lTree->{replyToList})) { 
                $lTree->{replyToList} = 0; 
        } 
 
        # Convert encoding to UTF-8 
        if (defined($lTree->{description})) { 
                $name = decode_base64($lTree->{description}); 
                if(Jcode::getcode($name) ne 'utf8') { 
                        $j = Jcode->new($name); 
                        $lTree->{description} = encode_base64($j->utf8, ''); 
                } 
        } 
 	} 
} 
 
 
if(defined $tree->{vsite}) { 
	my $vTree; 
	my @keys = keys %{ $tree->{vsite} }; 
	foreach my $vsite (@keys) { 
        $vTree = $tree->{vsite}->{$vsite}; 
        if(defined $vTree->{SSL}->{importCert}) { 
                delete $vTree->{SSL}->{importCert}; 
        } 
	} 
} 

my $migrate = {};
TreeXml::addNode('migrate', $tree, $migrate);
TreeXml::writeXml($migrate, $outFile);
exit 0;

