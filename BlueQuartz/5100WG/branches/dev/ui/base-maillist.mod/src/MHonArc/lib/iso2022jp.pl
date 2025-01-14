##---------------------------------------------------------------------------##
##  File:
##	@(#) iso2022jp.pl 1.2 00/01/15 17:54:50
##  Author(s):
##      Earl Hood       mhonarc@pobox.com
##      NIIBE Yutaka	gniibe@mri.co.jp
##  Description:
##	Library defines routine to process iso-2022-jp data.
##---------------------------------------------------------------------------##
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

package iso_2022_jp;

$Url    	= '(http://|https://|ftp://|afs://|wais://|telnet://|ldap://' .
		   '|gopher://|news:|nntp:|mid:|cid:|mailto:|prospero:)';
$UrlExp 	= $Url . q%[^\s\(\)\|<>"']*[^\.?!;,"'\|\[\]\(\)\s<>]%;
$HUrlExp	= $Url . q%[^\s\(\)\|<>"'\&]*[^\.?!;,"'\|\[\]\(\)\s<>\&]%;

use Jcode;  #COBALT CHANGE

##---------------------------------------------------------------------------##
##	str2html(): Convert an iso-2022-jp string into HTML.  Function
##	interface similiar as iso8859.pl function.
##
sub str2html { jp2022_to_html($_[0], 0); }

##---------------------------------------------------------------------------##
##	Function to convert ISO-2022-JP data into HTML.  Function is based
##	on the following RFCs:
##
##	RFC-1468 I
##		J. Murai, M. Crispin, E. van der Poel, "Japanese Character
##		Encoding for Internet Messages", 06/04/1993. (Pages=6)
##
##	RFC-1554  I
##		M. Ohta, K. Handa, "ISO-2022-JP-2: Multilingual Extension of  
##		ISO-2022-JP", 12/23/1993. (Pages=6)
##
##  Author of function:
##      NIIBE Yutaka	gniibe@mri.co.jp
##	(adapted for mhtxtplain.pl by Earl Hood <mhonarc@pobox.com>)
##	(some changes made to remove use of $& and few other optimizations)
##	(extracted as separate, general, function from mhtxtplain.pl)
##
sub jp2022_to_html {
    my($body) = shift;
    my($nourl) = shift;
    my(@lines) = split(/\r?\n/,$body);
    my($ret, $ascii_text);
    local($_);

    $ret = "";
    foreach (@lines) {
	# Process preceding ASCII text
	while(1) {
	    if (s/^([^\033]+)//) {	# ASCII plain text
		$ascii_text = $1;

		# Replace meta characters in ASCII plain text
		$ascii_text =~ s%\&%\&amp;%g;
		$ascii_text =~ s%<%\&lt;%g;
		$ascii_text =~ s%>%\&gt;%g;
		## Convert URLs to hyperlinks
		$ascii_text =~ s%($HUrlExp)%<A HREF="$1">$1</A>%gio
		    unless $nourl;

		$ret .= $ascii_text;
	    } elsif (s/(\033\.[A-F])//) { # G2 Designate Sequence
		$ret .= $1;
	    } elsif (s/(\033N[ -])//) { # Single Shift Sequence
		$ret .= $1;
	    } else {
		last;
	    }
	}

	# Process Each Segment
	while(1) {
	    if (s/^(\033\([BJ])//) { # Single Byte Segment
		$ret .= $1;
		while(1) {
		    if (s/^([^\033]+)//) {	# ASCII plain text
			$ascii_text = $1;

			# Replace meta characters in ASCII plain text
			$ascii_text =~ s%\&%\&amp;%g;
			$ascii_text =~ s%<%\&lt;%g;
			$ascii_text =~ s%>%\&gt;%g;
			## Convert URLs to hyperlinks
			$ascii_text =~ s%($HUrlExp)%<A HREF="$1">$1</A>%gio
			    unless $nourl;

			$ret .= $ascii_text;
		    } elsif (s/(\033\.[A-F])//) { # G2 Designate Sequence
			$ret .= $1;
		    } elsif (s/(\033N[ -])//) { # Single Shift Sequence
			$ret .= $1;
		    } else {
			last;
		    }
		}
	    } elsif (s/^(\033\$[\@AB]|\033\$\([CD])//) { # Double Byte Segment
		$ret .= $1;
		while (1) {
		    if (s/^([!-~][!-~]+)//) { # Double Char plain text
			$ret .= $1;
		    } elsif (s/(\033\.[A-F])//) { # G2 Designate Sequence
			$ret .= $1;
		    } elsif (s/(\033N[ -])//) { # Single Shift Sequence
			$ret .= $1;
		    } else {
			last;
		    }
		}
	    } else {
		# Something wrong in text
		$ret .= $_;
		last;
	    }
	}

	$ret .= "\n";
    }

    Jcode->new($ret)->sjis();    #COBALT CHANGE
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
