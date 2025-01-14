#!/usr/bin/perl
# $Id: 5106Radjust.pl 1161 2008-06-21 10:31:02Z shibuya $
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

$tree->{adjustPlatform} = "5106R";

my $migrate = {};
TreeXml::addNode('migrate', $tree, $migrate);
TreeXml::writeXml($migrate, $outFile);
exit 0;

