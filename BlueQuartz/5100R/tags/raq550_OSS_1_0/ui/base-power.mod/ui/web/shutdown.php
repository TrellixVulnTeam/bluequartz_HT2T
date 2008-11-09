<?php
// Copyright 2000, Cobalt Networks.  All rights reserved.
// $Id: shutdown.php 259 2004-01-03 06:28:40Z shibuya $

include("ServerScriptHelper.php");
include_once("Product.php");

$serverScriptHelper = new ServerScriptHelper();
$factory = $serverScriptHelper->getHtmlComponentFactory("base-power", "/base/power/shutdown.php");
$i18n = $serverScriptHelper->getI18n("base-power");
$product = new Product($serverScriptHelper->getCceClient());

if ($product->isRaq()) {
  $instr = "shutdownInstructions_softpower";
} else {
  $instr = "shutdownInstructions";
}

$stylist = $serverScriptHelper->getStylist();
$style = $stylist->getStyle("Page");
$fontTag = "<FONT STYLE=\"" . $style->toTextStyle() . "\">%s</FONT>";

$page = $factory->getPage();

$shutdownMessage = $i18n->getJs("shutdownMessage");

print($page->toHeaderHtml());
?>
<BR>

<BLOCKQUOTE>
	<?php print($i18n->get("shutdownMessage")); ?>
</BLOCKQUOTE>
<P>
<TABLE WIDTH="50%">
	<TR>
		<TD>
<?php printf($fontTag, $i18n->get($instr)); ?>
		</TD>
	</TR>
</TABLE>

<?php print($page->toFooterHtml());
/*
Copyright (c) 2003 Sun Microsystems, Inc. All  Rights Reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

-Redistribution of source code must retain the above copyright notice, this  list of conditions and the following disclaimer.

-Redistribution in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation and/or 
other materials provided with the distribution.

Neither the name of Sun Microsystems, Inc. or the names of contributors may 
be used to endorse or promote products derived from this software without 
specific prior written permission.

This software is provided "AS IS," without a warranty of any kind. ALL EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES, INCLUDING ANY IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR NON-INFRINGEMENT, ARE HEREBY EXCLUDED. SUN MICROSYSTEMS, INC. ("SUN") AND ITS LICENSORS SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES. IN NO EVENT WILL SUN OR ITS LICENSORS BE LIABLE FOR ANY LOST REVENUE, PROFIT OR DATA, OR FOR DIRECT, INDIRECT, SPECIAL, CONSEQUENTIAL, INCIDENTAL OR PUNITIVE DAMAGES, HOWEVER CAUSED AND REGARDLESS OF THE THEORY OF LIABILITY, ARISING OUT OF THE USE OF OR INABILITY TO USE THIS SOFTWARE, EVEN IF SUN HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

You acknowledge that  this software is not designed or intended for use in the design, construction, operation or maintenance of any nuclear facility.
*/
?>
