# $Id: TreeXml.pm 922 2003-07-17 15:22:40Z will $
# Cobalt Networks, Inc http://www.cobalt.com
# Copyright 2002 Sun Microsystems, Inc.  All rights reserved.

package TreeXml;
use strict;

require Exporter;

use vars qw(@ISA @EXPORT @EXPORT_OK $VERSION);
@ISA    = qw( Exporter );       
@EXPORT = qw(
		&find 
		&addNode 
		&deleteNode 
		&writeXml 
		&readXml 
		&readXmlStream
		&remapItem
		&removeItem
		&countAttr
		$VERSION
		$XMLPROLOG
		$XMLHEADER
);      
$VERSION = 2.43;

use vars qw($XMLPROLOG $XMLHEADER $KEYATTR);
$XMLPROLOG = '<?xml version="1.0" encoding="iso-8859-1"?>';
$XMLHEADER = "<!-- generated by Sun Cobalt Migration Utility version $VERSION -->";
$KEYATTR = {
    group  => 'id',
    vsite  => 'id',
    user   => 'id',
    list   => 'id',
};

#######################################
# find ($hashref, $type, $name, $where)
# find searches the given $hashref for $type which must be supplied. Optional
# arguments are $name and $where. $name can be used to find a particular 
# structure of the given $type. $where can be used to find a set of structures
# of the given $type. 
#
# find is generalized and quite simple. calling find without $where simply 
# returns values one or two levels into the $hashref. we can use consecutaive
# calls to find to traverse deeper by returning the result of find into the
# $hashref of the next find call. For data structures of which we know the
# basic layout this is useful. 
#
# if $where is specified find simply searches by walking the $hashref in O(n)
# time 

sub find {
    my $hashref = shift;
    my $type = shift;
    my $name = shift;
    my $where = shift;

    if ($name eq '' and $where eq '') {
	return ($hashref->{$type});
    }
    elsif ($where eq '') {
	return ($hashref->{$type}->{$name});
    }
    elsif ($name eq '') {
	my @ret;
	foreach my $entry (keys %{ $hashref->{$type} }) {
	    if ($hashref->{$type}->{$entry}->{$where->[0]}->{value} eq $where->[1]) {
		push @ret, $hashref->{$type}->{$entry};
	    }
	}
	return @ret;
    }
 
}
    
sub addNode {
    my $key = shift;
    my $newNode = shift;
    my $hashref = shift;

	$hashref->{$key} = $newNode;
}

sub deleteNode {
    my $key = shift;
    my $hashref = shift;
    delete $hashref->{$key};
}

sub renameNode {
    my ($oldName, $newName, $tree) = @_;
    my $temp = $tree->{$oldName};
    deleteNode($oldName, $tree);
    addNode($newName, $temp, $tree);
	if(exists $tree->{$newName}->{id}) {
		$tree->{$newName}->{id} = $newName;
	}
}

sub remapItem
{
	my $old = shift;
	my $new = shift;
	my $data = shift || return;

	my @keys = keys %{ $data };
	foreach my $key (@keys) {
		if(ref($data->{$key}) eq "ARRAY") {
			foreach my $item (@{ $data->{$key} }) { 
				$item =~ s/$old$/$new/; 
			}
		} elsif ($data->{$key}) { $data->{$key} =~ s/$old$/$new/; }
	}
	return($data);
}

sub removeItem
# This expects the hash above the item you are removing
{
	my $name = shift;
	my $data = shift;
	
	my $ret = 0;
	my @keys = keys %{ $data };
	foreach my $key (@keys) {
		if(ref($data->{$key}) eq "ARRAY") {
			my @arr = @{ $data->{$key} };
			for(my $i = 0; $i < @arr; $i++) {
				next unless($data->{$key}->[$i] eq $name);
				splice(@{ $data->{$key} }, $i, 1);
				$ret = 1;
				last;
			}
			if(scalar(@{ $data->{$key} }) eq 0) { delete $data->{$key}; }
		} elsif ($data->{$key} eq $name) { 
			delete $data->{$key};
			$ret = 1;
		}
	}
	return($ret);
}

sub writeXml {
    my $ref = shift;
    my $filename = shift;

    # Wrap top level arrayref in a hash
    if (ref($ref) eq 'ARRAY') {
	$ref = { anon => $ref };
    }

    my $tree = TreeXml::asXml($ref);
    my $xml = $XMLPROLOG . "\n" . $XMLHEADER . "\n\n" . join('', @$tree);

    return $xml unless defined $filename;

    open(XMLOUT, ">$filename") || die "writeXml: Could not open file: $!";
    print XMLOUT $xml;
    close(XMLOUT);
}

sub printXml {
    my $ref = shift;

	# Wrap top level arrayref in a hash
    if (ref($ref) eq 'ARRAY') {
	$ref = { anon => $ref };
    }

    my $tree = TreeXml::asXml($ref);
    my $xml = $XMLPROLOG . "\n" . $XMLHEADER . "\n\n" . join('', @$tree);
	print $xml;

}

sub readXml {
    my $filename = shift || return;
    my $keepRoot = shift;

    unless(-f $filename) {
		warn "ERROR Cannot find filename: $filename\n";
		return;
    }

    require XML::Parser;

    my $xp = new XML::Parser(Style => 'Tree');
    my $tree = $xp->parsefile($filename);
    $xp = undef;

    my $ref = TreeXml::reduceXml(@{ $tree->[1] });
    return $ref unless ($keepRoot == 1);

    my $rootRef = {};
    $rootRef->{ $tree->[0] } = $ref;

    return $rootRef;
}

sub readXmlStream {
    my $data = shift || return;
    my $keepRoot = shift;

    require XML::Parser;

    my $xp = new XML::Parser(Style => 'Tree');
    my $tree = $xp->parse($data);
    $xp = undef;

    my $ref = TreeXml::reduceXml(@{ $tree->[1] });
    return $ref unless ($keepRoot == 1);

    my $rootRef = {};
    $rootRef->{ $tree->[0] } = $ref;
    return $rootRef;
}

sub getStats
# used for getting a list of stat for import or export
# arguments: data structure
# retrun: String of output
{
    my $data = shift;
    my @attrs = [];

    if ($data->{exportPlatform} =~ /RaQ/) {
	@attrs = qw(vsite user list);
    }
    elsif ($data->{exportPlatform} =~ /Qube/) {
	@attrs = qw(group user list);
    } else { return "Unknown exportPlatform\n" }

    my $str = '';
    foreach my $attr (@attrs) {
	$str .= " ".countAttr($data, $attr)." ".$attr."s,";
    }
    chop $str;

    return $str."\n";
}

sub countAttr
# used for counting types of attributes in data stucture
# arguments: data structure, type (users, etc)
# returns the number of items, zero if none
{
    my $data = shift;
    my $type = shift;

    foreach my $item (keys %{ $data }) {
		next unless $item eq $type;
		if(ref($data->{$item}) eq 'ARRAY') {
			return scalar(@{ $data->{$item} });
    	} elsif(ref($data->{$item}) eq 'HASH') {
			return scalar(keys %{ $data->{$item} });
		}
	}
    return 0;
}


##############################################################################
#
#    TreeXml::reduceXml()
#
#    reduce the XML::Parser generated tree by removing nested
#    arrays, whitespace-only text sections, and other crud.
#
sub reduceXml {
    my $attr = shift;
    my ($key, $val);

    while (@_) {
	$key = shift;
	$val = shift;

	if (ref($val)) {
	    $val = TreeXml::reduceXml(@$val); # recurse to handle children
	}
	elsif ($key eq '0') {
	    next if ($val =~ /^\s*$/s);       # skip all whitespace content
	    return $val if (!%$attr and !@_); # return text in tag with no attr
	}
            
	# Combine duplicate attributes into arrayref
	if (exists($attr->{$key})) {
	    if (ref($attr->{$key}) eq 'ARRAY') {
		push @{ $attr->{$key} }, TreeXml::stripType($val);
	    }
	    else {
		$attr->{$key} = [ $attr->{$key}, TreeXml::stripType($val) ];
	    }
	}
	elsif (ref($val) eq 'ARRAY') {
	    # Handle anonymous arrays
	    $attr->{$key} = [ $val ];
	}
	elsif (ref($val) eq 'HASH') {
	    # Don't convert one member arrays to hashes
	    $attr->{$key} = TreeXml::stripType($val);
	}
	else {
	    $attr->{$key} = [ $val ];
	}
    }
  
    # convert arrayref to hashref and wrap hashref using KEYATTR
    while (($key,$val) = each %$attr) {
	next unless ref($val) eq 'ARRAY' or ref($val) eq 'HASH';
	$attr->{$key} = TreeXml::array2hash($key, $val);
    }

    # fold hashes containing a single anonymous array into just array
    return $attr->{anon} if (scalar(keys %$attr) == 1) and
	                    (ref($attr->{anon}) eq 'ARRAY');

    return $attr;
}


##############################################################################
#
#    TreeXml::asXml()
# 
#    $ref:     data structure reference to work with
#    $name:    name to use for this node
#    $indent:  string with whitespace for indent at this level
#
#    traverse through a data structure and build XML tree to represent it
#
sub asXml {
    my ($ref, $name, $indent) = @_;
    my $named = (defined($name) and $name ne '' ? 1 : 0);
    my ($key, $val);
    my @result = ();

    # short circuit recursion early if there are no children
    if (!ref($ref)) {
	if ($named) {
	    push @result, $indent, qq( <$name>), escText($ref), qq(</$name>\n);
	}
	else {
	    push @result, qq($ref\n);
	}
	return \@result;
    }

    # Convert hash-o-hashes to array-o-hashes, IFF:
    if (ref($ref) eq 'HASH'  # $ref is a hashref,
	and %$ref            # with entries,
	and $named           # the node (or parent) is named,
	and $indent) {       # and this is not the root
	$ref = TreeXml::hash2array($name, $ref);
    }

    #
    # handle `hashrefs'
    #
    if (ref($ref) eq 'HASH') {
	my @nested = ();

	# named node is standalone OR parent with special attribute
	if ($named) {
	    if (exists($KEYATTR->{$name})) {
		my $id = escText($ref->{ $KEYATTR->{$name} });
		push @result, $indent, qq( <$name $KEYATTR->{$name} = "$id">\n);
		delete $ref->{ $KEYATTR->{$name} };
	    }
	    elsif (%$ref) {
		push @result, $indent, qq( <$name>\n);
	    }
	    else {
		return \@result;
	    }
	}

	# now traverse the elements of this node.
	# traverse any nested trees but save the result till later
	if (%$ref) {
	    while (($key,$val) = each(%$ref)) {
		$val = {} unless defined $val;  # undefined vars are ok
		if (ref($val)) {
		    push @nested, @{ TreeXml::asXml($val, $key, "$indent  ") };
		}
		elsif ($val) {
		    $val = escText($val);
		    push @result, $indent, qq(   <$key value = "$val"/>\n);
		}
	    }
	}

	# now add the nested trees, if any
	if (@nested) {
	    push @result, @nested;
	    push @result, $indent, qq( </$name>\n) if ($named);
	}
	else {
	    push @result, $indent, qq( </$name>\n);
	}
    }

    # handle array elements
    elsif (ref($ref) eq 'ARRAY') {
	foreach $val (@$ref) {

	    if (!ref($val)) {
		push @result, qq($indent <$name>), escText($val), qq(</$name>\n);
	    }
	    elsif (ref($val) eq 'HASH') {
		push @result, @{ TreeXml::asXml($val, $name, $indent) };
	    }
	    else {
		push @result, $indent, qq( <$name>\n);
		push @result, @{ TreeXml::asXml($val, 'anon', "$indent  ") };
		push @result, $indent, qq( </$name>\n);
	    }
	}
    }

    # log a warning about other datatypes but return current result anyway
    else {
		warn "ERROR Error encoding '$name' type ", ref($ref), "\n";
    }

    return \@result;
}

##############################################################################
#
#    TreeXml::escText()
#
#    $data:  scalar data value
#
#    replace XML delimiter characters with predefined entities
#
sub escText {
    my $data = shift;
	return $data unless($data =~ /(&|>|<|\"|\')/);
    my $code = '
$data =~ s/&/&amp;/sg;
$data =~ s/</&lt;/sg;
$data =~ s/>/&gt;/sg;
$data =~ s/\"/&quot;/sg;
$data =~ s/\'/&apos;/sg;
';
    eval $code;
    return $data;
}

##############################################################################
#
#    TreeXml::stripType()
#
#    $val:  hash containing data type reference
#
sub stripType {
    my $val = shift;

	if(!ref $val) { return $val }
    elsif(exists $val->{'value'}) { return $val->{'value'} }
    return $val;
}

##############################################################################
#
#    TreeXml::array2hash()
#
#    $name     : element name
#    $arrayref : array of hashes to convert
#
#    Transforms an `array of hashes' into a `hash of hashes'.
#    Used by TreeXml::reduceXml() to simplify the XML tree.
#    The global variable $KEYATTR is used to find entity keys.
#
sub array2hash {
    my $name = shift;
    my $arrayref = shift;
    my $hashref = {};

    return $arrayref unless exists $KEYATTR->{$name};
    my $key = $KEYATTR->{$name};

    # single element arrays reduce to hashes, so wrap in array
    $arrayref = [ $arrayref ] if ref($arrayref) eq 'HASH';

    foreach my $node (@$arrayref) {
	return $arrayref unless ref($node) eq 'HASH';
	return $arrayref unless exists $node->{$key};
	$hashref->{ $node->{$key} } = { %$node };
	delete $hashref->{ $node->{$key} }->{$key};
    }

    return $hashref;
}

##############################################################################
#
#    TreeXml::hash2array()
#
#    $name    : element name
#    $hashref : hash of hashes to convert
#
#    Transforms an `hash of hashes' into an `array of hashes'.
#    Used by TreeXml::asXml() to produce suitable XML output.
#    The global variable $KEYATTR is used to find entity keys.
#
sub hash2array {
    my $name = shift;
    my $hashref = shift;
    my $arrayref = [];

    return $hashref unless exists $KEYATTR->{$name};

    while (my($key,$val) = each %$hashref) {
        if (ref($val) ne 'HASH') {
	    scalar(keys %$hashref);  # reset `each' iterator
	    return $hashref;
	}
        push @$arrayref, { $KEYATTR->{$name} => $key, %$val };
    }

    return $arrayref;
}

1;

__END__
# Copyright (c) 2003 Sun Microsystems, Inc. All  Rights Reserved.
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
