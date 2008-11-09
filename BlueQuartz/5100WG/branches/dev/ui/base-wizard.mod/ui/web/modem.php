<?php
// Author: Kevin K.M. Chiu
// Copyright 2000, Cobalt Networks.  All rights reserved.
// $Id: modem.php 201 2003-07-18 19:11:07Z will $

include("ServerScriptHelper.php");

$serverScriptHelper = new ServerScriptHelper();
$cceClient = $serverScriptHelper->getCceClient();
$factory = $serverScriptHelper->getHtmlComponentFactory("base-wizard", "/base/wizard/modemHandler.php");
$i18n = $serverScriptHelper->getI18n("base-wizard");

// get settings
$modemObj = $cceClient->getObject("System", array(), "Modem");

$page = $factory->getPage();

$block = $factory->getPagedBlock("modemSettings");

$block->addFormField(
  $factory->getMultiChoice("connModeField", array("demand", "on", "off"), array($modemObj["connMode"])),
  $factory->getLabel("connModeField")
);

$block->addFormField(
  $factory->getTextField("modemPhoneField", $modemObj["phone"]),
  $factory->getLabel("modemPhoneField")
);

$block->addFormField(
  $factory->getTextField("userNameField", $modemObj["userName"]),
  $factory->getLabel("userNameField")
);

$block->addFormField(
  $factory->getPassword("modemPasswordField"),
  $factory->getLabel("modemPasswordField")
);

$block->addFormField(
  $factory->getTextField("initStringField", $modemObj["initStr"]),
  $factory->getLabel("initStringField")
);

$localIp = $modemObj["localIp"];
if($localIp == "0.0.0.0")
  $localIp = "";
$ip = $factory->getIpAddress("localIpField", $localIp);
$ip->setOptional(true);
$block->addFormField(
  $ip,
  $factory->getLabel("localIpField")
);

$block->addFormField(
  $factory->getBoolean("pulseField", $modemObj["pulse"]),
  $factory->getLabel("pulseField")
);
?>
<?php print($page->toHeaderHtml()); ?>

<?php print($i18n->getHtml("modemMessage")); ?>
<BR><BR>

<?php print($block->toHtml()); ?>

<?php print($page->toFooterHtml()); /*
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

