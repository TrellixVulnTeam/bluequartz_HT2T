##---------------------------------------------------------------------------##
##  File:
##	@(#) mhindex.pl 1.6 99/10/01 02:03:44
##  Author:
##      Earl Hood       mhonarc@pobox.com
##  Description:
##	Main index routines for mhonarc
##---------------------------------------------------------------------------##
##    MHonArc -- Internet mail-to-HTML converter
##    Copyright (C) 1995-1999	Earl Hood, mhonarc@pobox.com
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
##    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
##    02111-1307, USA
##---------------------------------------------------------------------------##

package mhonarc;

##---------------------------------------------------------------------------
##	write_main_index outputs main index of archive
##
sub write_main_index {
    local($onlypg) = @_;
    local($MLCP);
    local($outhandle, $i, $i_p0, $filename, $tmpl, $isfirst, $tmp,
	  $mlfh, $mlinfh, $tmpfile, $offstart, $offend);
    local(*a);
    local($PageNum, $PageSize, $totalpgs);

    &compute_page_total();
    $PageNum    = $onlypg || 1;
    $totalpgs   = $onlypg || $NumOfPages;
    if (!scalar(@MListOrder)) {
	@MListOrder = &sort_messages();
	%Index2MLoc = ();
	@Index2MLoc{@MListOrder} = (0 .. $#MListOrder);
    }

    for ( ; $PageNum <= $totalpgs; ++$PageNum) {
	next  if $PageNum < $IdxMinPg;

	$isfirst = 1;
	$MLCP = 0;

        if ($MULTIIDX) {
            $offstart = ($PageNum-1) * $IDXSIZE;
            $offend   = $offstart + $IDXSIZE-1;
            $offend   = $#MListOrder  if $#MListOrder < $offend;
            @a        = @MListOrder[$offstart..$offend];

	    if ($PageNum > 1) {
		$IDXPATHNAME = join("", $OUTDIR, $DIRSEP,
				    $IDXPREFIX, $PageNum, ".", $HtmlExt);
	    } else {
		$IDXPATHNAME = join($DIRSEP, $OUTDIR, $IDXNAME);
	    }

	} else {
	    if ($IDXSIZE && (($i = ($#MListOrder+1) - $IDXSIZE) > 0)) {
		if ($REVSORT) {
		    @a = @MListOrder[0..($IDXSIZE-1)];
		} else {
		    @a = @MListOrder[$i..$#MListOrder];
		}
	    } else {
		*a = *MListOrder;
	    }
	    $IDXPATHNAME = join($DIRSEP, $OUTDIR, $IDXNAME);
	}
	$PageSize = scalar(@a);
	    
	## Open/create index file
	if ($IDXONLY) {
	   $outhandle = 'STDOUT';

	} else {
	    if ($ADD && &file_exists($IDXPATHNAME)) {
		$tmpfile = join($DIRSEP, $OUTDIR, "tmp.$$");
		&file_rename($IDXPATHNAME, $tmpfile);
		($mlinfh = &file_open($tmpfile))
		    || die("ERROR: Unable to open $tmpfile\n");
		$MLCP = 1;
	    }
	    ($outhandle = &file_create($IDXPATHNAME, $GzipFiles)) ||
		die("ERROR: Unable to create $IDXPATHNAME\n");
	}
	print STDOUT "Writing $IDXPATHNAME ...\n"  unless $QUIET;

	## Print top part of index
	&output_maillist_head($outhandle, $mlinfh);

	## Output links to messages

	if ($NOSORT) {
	    foreach $index (@a) {
		($tmpl = $LITMPL) =~ s/$VarExp/&replace_li_var($1,$index)/geo;
		print $outhandle $tmpl, "ufo1\n";
	    }

	} elsif ($SUBSORT) {
	    local($prevsub) = '';
	    foreach $index (@a) {
		if (($tmp = &get_base_subject($index)) ne $prevsub) {
		    $prevsub = $tmp;
		    if (!$isfirst) {
			($tmpl = $SUBJECTEND) =~
				s/$VarExp/&replace_li_var($1,$index)/geo;
			print $outhandle $tmpl,"ufo2\n";
		    } else {
			$isfirst = 0;
		    }
		    ($tmpl = $SUBJECTBEG) =~
			s/$VarExp/&replace_li_var($1,$index)/geo;
		    print $outhandle $tmpl,"ufo3\n";
		}
		($tmpl = $LITMPL) =~ s/$VarExp/&replace_li_var($1,$index)/geo;
		print $outhandle $tmpl,"ufo4\n";
	    }
	    ($tmpl = $SUBJECTEND) =~ s/$VarExp/&replace_li_var($1,$index)/geo;
	    print $outhandle $tmpl,"ufo5\n";

	} elsif ($AUTHSORT) {
	    local($prevauth) = '';
	    foreach $index (@a) {
		if (($tmp = &get_base_author($index)) ne $prevauth) {
		    $prevauth = $tmp;
		    if (!$isfirst) {
			($tmpl = $AUTHEND) =~
			    s/$VarExp/&replace_li_var($1,$index)/geo;
			print $outhandle $tmpl,"ufo6\n";
		    } else {
			$isfirst = 0;
		    }
		    ($tmpl = $AUTHBEG) =~
			s/$VarExp/&replace_li_var($1,$index)/geo;
		    print $outhandle $tmpl,"ufo7\n";
		}
		($tmpl = $LITMPL) =~ s/$VarExp/&replace_li_var($1,$index)/geo;
		print $outhandle $tmpl,"ufo8\n";
	    }
	    ($tmpl = $AUTHEND) =~ s/$VarExp/&replace_li_var($1,$index)/geo;
	    print $outhandle $tmpl,"ufo9\n";

	} else {
	    local($prevdate) = '';
	    local($time);
	    foreach $index (@a) {
		$time = &get_time_from_index($index);
		$tmp = join("", $UseLocalTime ? (localtime($time))[3,4,5] :
						(gmtime($time))[3,4,5]);
		if ($tmp ne $prevdate) {
		    $prevdate = $tmp;
		    if (!$isfirst) {
			($tmpl = $DAYEND) =~
			    s/$VarExp/&replace_li_var($1,$index)/geo;
#start of child
	#		print $outhandle $tmpl;
#start of child end
		    } else {
			$isfirst = 0;
		    }
		    ($tmpl = $DAYBEG) =~
			s/$VarExp/&replace_li_var($1,$index)/geo;
#start of index (<ul>)
	#	    print $outhandle $tmpl;
#start of index (<ul>) end
		}
		($tmpl = $LITMPL) =~ s/$VarExp/&replace_li_var($1,$index)/geo;
#start of record (<liTemplate>)
		print $outhandle $tmpl;
#start of record (<liTemplate>) end
	    }
	    ($tmpl = $DAYEND) =~ s/$VarExp/&replace_li_var($1,$index)/geo;
#start of child closing
	#    print $outhandle $tmpl;
#start of child closing end
	}

	## Print bottom part of index
	&output_maillist_foot($outhandle, $mlinfh);
	close($outhandle)  unless $IDXONLY;
	if ($MLCP) {
	    close($mlinfh);
	    &file_remove($tmpfile);
	}
    }
}

##---------------------------------------------------------------------------
##	output_maillist_head() outputs the beginning of the index page.
##
sub output_maillist_head {
    local($handle, $cphandle) = @_;
    local($tmp, $index, $headfh);
    $index = "";

    print $handle "<?php\n";
    ($tmp = $SSMARKUP) =~ s/$VarExp/&replace_li_var($1,'')/geo;
    print $handle $tmp;

    print $handle "/* ", &commentize("MHonArc v$VERSION"), " */\n";

    ## Output title
    ($tmp = $IDXPGBEG) =~ s/$VarExp/&replace_li_var($1,'')/geo;
    print $handle $tmp;
    print $handle "/*X-ML-Title-H1-End*/\n";

    if ($MLCP) {
	while (<$cphandle>) { last  if /\/\*X-ML-Title-H1-End/; }
    }

    ## Output header file
    if ($HEADER) {				# Read external header
	print $handle "/*X-ML-Header*/\n";
	if ($headfh = &file_open($HEADER)) {
	    while (<$headfh>) { print $handle $_; }
	    close($headfh);
	} else {
	    warn "Warning: Unable to open header: $HEADER\n";
	}
	if ($MLCP) {
	    while (<$cphandle>) { last  if /\/\*X-ML-Header-End/; }
	}
	print $handle "/*X-ML-Header-End*/\n";
    } elsif ($MLCP) {				# Preserve maillist header
	while (<$cphandle>) {
	    print $handle $_;
	    last  if /\/\*X-ML-Header-End/;
	}
    } else {					# No header
	print $handle "/*X-ML-Header*/\n",
		      "/*X-ML-Header-End*/\n";
    }

    print $handle "/*X-ML-Index*/\n";
    ($tmp = $LIBEG) =~ s/$VarExp/&replace_li_var($1,'')/geo;
    print $handle $tmp;
}

##---------------------------------------------------------------------------
##	output_maillist_foot() outputs the end of the index page.
##
sub output_maillist_foot {
    local($handle, $cphandle) = @_;
    local($tmp, $index, $footfh);
    $index = "";

    ($tmp = $LIEND) =~ s/$VarExp/&replace_li_var($1,'')/geo;
    print $handle $tmp;
    print $handle "/*X-ML-Index-End*/\n";

    ## Skip past index in old maillist file
    if ($MLCP) {
	while (<$cphandle>) { last  if /\/\*X-ML-Index-End/; }
    }

    ## Output footer file
    if ($FOOTER) {				# Read external footer
	print $handle "/*X-ML-Footer*/\n";
	if ($footfh = &file_open($FOOTER)) {
	    while (<$footfh>) { print $handle $_; }
	    close($footfh);
	} else {
	    warn "Warning: Unable to open footer: $FOOTER\n";
	}
	if ($MLCP) {
	    while (<$cphandle>) { last  if /\/\*X-ML-Footer-End/; }
	}
	print $handle "/*X-ML-Footer-End*/\n";
    } elsif ($MLCP) {				# Preserve maillist footer
	while (<$cphandle>) {
	    print $handle $_;
	    last  if /\/\*X-ML-Footer-End/;
	}
    } else {					# No footer
	print $handle "/*X-ML-Footer*/\n",
		      "/*X-ML-Footer-End*/\n";
    }

    #&output_doclink($handle);

    ## Close document
    ($tmp = $IDXPGEND) =~ s/$VarExp/&replace_li_var($1,'')/geo;
    print $handle $tmp;

    #print $handle "/* ", &commentize("MHonArc v$VERSION"), " */\n";
}

##---------------------------------------------------------------------------
##	Output link to documentation, if specified
##
sub output_doclink {
    local($handle) = ($_[0]);
    if (!$NODOC && $DOCURL) {
	print $handle "<HR>\n";
	print $handle
		"<ADDRESS>\n",
		"Mail converted by ",
		qq|<A HREF="$DOCURL"><CODE>MHonArc</CODE></A> $VERSION\n|,
		"</ADDRESS>\n";
    }
}

##---------------------------------------------------------------------------
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
