<?php
// Author: Patrick Bose
// Copyright 2001, Cobalt Networks.  All rights reserved.
// $Id: raidDone.php 201 2003-07-18 19:11:07Z will $

include("ServerScriptHelper.php");

$serverScriptHelper = new ServerScriptHelper();

$factory = $serverScriptHelper->getHtmlComponentFactory("base-wizard", "/base/wizard/raidHandler.php");
$i18n = $serverScriptHelper->getI18n("base-raid");
$page = $factory->getPage();

if ( $error ) {
	$cceClient = $serverScriptHelper->getCceClient();
	$cceClient->setObject("System", array("level" => "-1"), "RAID", array());

	print($page->toHeaderHtml());
	print($i18n->getHtml($error)); 
	print($page->toFooterHtml());
	$serverScriptHelper->destructor();
	return;
}

print($serverScriptHelper->toHandlerHtml("", array()));

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

