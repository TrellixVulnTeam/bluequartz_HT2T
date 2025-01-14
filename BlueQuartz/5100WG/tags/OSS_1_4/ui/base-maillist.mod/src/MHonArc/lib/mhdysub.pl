##---------------------------------------------------------------------------##
##  File:
##	@(#) mhdysub.pl 2.4 99/07/25 02:02:34
##  Author:
##      Earl Hood       mhonarc@pobox.com
##  Description:
##      Definition of create_routines() that creates routines are
##	runtime.
##---------------------------------------------------------------------------##
##    MHonArc -- Internet mail-to-HTML converter
##    Copyright (C) 1996-1999	Earl Hood, mhonarc@pobox.com
##
##    This program is free software; you can redistribute it and/or modify
##    it under the terms of the GNU General Public License as published by
##    the Free Software Foundation; either version 2 of the License, or
##    (at your option) any later version.
##
##    This program is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY; without even the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##    GNU General Public License for more details.
##
##    You should have received a copy of the GNU General Public License
##    along with this program; if not, write to the Free Software
##    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
##---------------------------------------------------------------------------##

package mhonarc;

my $_sub_eval_cnt = 0;

##---------------------------------------------------------------------------
##	create_routines is used to dynamically create routines that
##	would benefit from being create at run-time.  Routines
##	that have to check against several regular expressions
##	are candidates.
##
sub create_routines {
    my($sub) = '';

    ##-----------------------------------------------------------------------
    ## exclude_field: Used to determine if field should be excluded from
    ## message header
    ##
    $sub  =<<'EndOfRoutine';
    sub exclude_field {
	my($f) = shift;
	my $ret = 0;
	EXC_FIELD_SW: {
EndOfRoutine

    # Create switch block for checking field against regular
    # expressions (a large || statement could also work).
    my $pat;
    foreach $pat (keys %HFieldsExc) {
	$sub .= join('',
		     'if ($f =~ /^',
		     $pat,
		     '/i) { $ret = 1;  last EXC_FIELD_SW; }',
		     "\n");
    }

    $sub .=<<'EndOfRoutine';
	}
	$ret;
    }
EndOfRoutine

    $sub .= "# $_sub_eval_cnt\n";  ++$_sub_eval_cnt;
    eval $sub;
    die("ERROR: Unable to create exclude_field routine:\n$@\n") if $@;

    ##-----------------------------------------------------------------------
    ## subject_strip: Used to apply user-defined s/// operations on
    ## message subjects as they are read;
    ##
    $sub  =<<EndOfRoutine;
    sub subject_strip {
	local(\$_) = shift;
	$SubStripCode;
	\$_;
    }
EndOfRoutine

    $sub .= "# $_sub_eval_cnt\n";  ++$_sub_eval_cnt;
    eval $sub;
    die("ERROR: Unable to create subject_strip routine:\n$@\n") if $@;

    ##-----------------------------------------------------------------------
    ##	Routine to determine last message number in use.
    ##
    $sub =<<'EndOfRoutine';
    sub get_last_msg_num {
	opendir(DIR, $OUTDIR) || die("ERROR: Unable to open $OUTDIR\n");
	my($max) = -1;
	my $msgrex = '^'.
		     "\Q$MsgPrefix".
		     '(\d+)\.'.
		     "\Q$HtmlExt".
		     '$';
	chop $msgrex  if ($HtmlExt =~ /html$/i);

	foreach (readdir(DIR)) {
	    if (/$msgrex/io) { $max = int($1)  if $1 > $max; }
	}
	close(DIR);
	$max;
    }
EndOfRoutine

    $sub .= "# $_sub_eval_cnt\n";  ++$_sub_eval_cnt;
    eval $sub;
    die("ERROR: Unable to create get_last_msg_num routine:\n$@\n") if $@;

    ##-----------------------------------------------------------------------
    ##	Routine to get base subject text from index
    ##
    $sub =<<'EndOfRoutine';
    sub get_base_subject {
	my($ret) = ($Subject{$_[0]});
	1 while $ret =~ s/$SubReplyRxp//io;
	$ret;
    }
EndOfRoutine

    $sub .= "# $_sub_eval_cnt\n";  ++$_sub_eval_cnt;
    eval $sub;
    die("ERROR: Unable to create get_base_subject routine:\n$@\n") if $@;

    ##-----------------------------------------------------------------------
    ##	Routine to rewrite mail addresses in message header
    ##
    $sub =<<EndOfRoutine;
    sub rewrite_address {
	local \$_ = shift;
	$AddressModify;
	\$_;
    }
EndOfRoutine

    $sub .= "# $_sub_eval_cnt\n";  ++$_sub_eval_cnt;
    eval $sub;
    die("ERROR: Unable to create rewrite_address routine:\n$@\n") if $@;

    ##-----------------------------------------------------------------------
    ## message_exclude: User-defined code to check if a message should
    ## be added or not.
    ##
    $sub  =<<EndOfRoutine;
    sub message_exclude {
	package mhonarc::Pkg_message_exclude;
	local(\$_) = shift;
	$MsgExcFilter;
    }
EndOfRoutine

    $sub .= "# $_sub_eval_cnt\n";  ++$_sub_eval_cnt;
    eval $sub;
    die("ERROR: Unable to create subject_strip routine:\n$@\n") if $@;

}

##---------------------------------------------------------------------------##
1;
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
