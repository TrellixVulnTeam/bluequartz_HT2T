##---------------------------------------------------------------------------##
##  File:
##      @(#) mhrmm.pl 1.4 00/04/24 00:03:36
##  Author:
##      Earl Hood       mhonarc@pobox.com
##  Description:
##      Rmm routine for MHonArc.
##---------------------------------------------------------------------------##
##    MHonArc -- Internet mail-to-HTML converter
##    Copyright (C) 1995-1999   Earl Hood, mhonarc@pobox.com
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
##	Function for removing messages.
##
sub rmm {
    local(@numbers) = ();
    local($key, %Num2Index, $num, $i, $pg);
    local($_);

    ## Create list of messages to remove
    foreach (@_) {
	# range
	if (/^(\d+)-(\d+)$/) {
	    push(@numbers, int($1) .. int($2));
	    next;
	}
	# single number
	if (/^\d+$/) {
	    push(@numbers, int($_));
	    next;
	}
	# probably message-id
	push(@numbers, $_);
    }

    if ($#numbers < 0) {
	warn("Warning: No messages specified\n");
	return 0;
    }

    ## Make hash to perform deletions
    foreach $key (keys %IndexNum) {
	$Num2Index{$IndexNum{$key}} = $key;
    }

    ## Set @MListOrder to flag next/prev messages to be updated.
    ## @TListOrder is already set since it is saved in db.
    @MListOrder = &sort_messages();
    $i=0; foreach $key (@MListOrder) {
	$Index2MLoc{$key} = $i++;
    }

    ## Remove messages
    foreach $num (@numbers) {
	if (($key = $Num2Index{$num}) || ($key = $MsgId{$num})) {
	    &delmsg($key);

	    # Need to flag messages that link to deleted message so
	    # they will be updated.
	    foreach (split(/$bs/o, $FollowOld{$index})) {
		$Update{$IndexNum{$_}} = 1;
	    }
	    $Update{$IndexNum{$TListOrder[$Index2TLoc{$key}-1]}} = 1;
	    $Update{$IndexNum{$TListOrder[$Index2TLoc{$key}+1]}} = 1;
	    $Update{$IndexNum{$MListOrder[$Index2MLoc{$key}-1]}} = 1;
	    $Update{$IndexNum{$MListOrder[$Index2MLoc{$key}+1]}} = 1;

	    # Mark where index page updates start
	    if ($MULTIIDX) {
		$pg = int($Index2MLoc{$key}/$IDXSIZE)+1;
		$IdxMinPg = $pg
		    if ($pg < $IdxMinPg || $IdxMinPg < 0);
		$pg = int($Index2TLoc{$key}/$IDXSIZE)+1;
		$TIdxMinPg = $pg
		    if ($pg < $TIdxMinPg || $TIdxMinPg < 0);
	    }

	    next;
	}

	# message not in archive
	warn qq/Warning: Message "$num" not in archive\n/;
    }

    ## Clear loc data; it will get recomputed
    @MListOrder = ();
    %Index2MLoc = ();

    &write_pages();
    1;
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
