<?php
// Author: Kevin K.M. Chiu
// Copyright 2000, Cobalt Networks.  All rights reserved.
// $Id: lanHandler.php 1003 2007-06-25 15:19:33Z shibuya $

include_once("ServerScriptHelper.php");

$serverScriptHelper = new ServerScriptHelper();
$cceClient = $serverScriptHelper->getCceClient();

$oids = $cceClient->find("System");

$cceClient->set($oids[0], "", array("gateway" => $gatewayField));
$errors = $cceClient->errors();

// find out IP forwarding and NAT inputs
$forward = ($forwardField != "forwardOff");
$nat = ($forwardField == "forwardNat");
$cceClient->set($oids[0], "Network", array("internetMode" => "lan", "ipForwarding" => $forward, "nat" => $nat));
$errors = array_merge($errors, $cceClient->errors());

if (empty($ipAddressField2) && empty($netMaskField2)) {	
	// if empty, turn eth1 off
	$cceClient->setObject(
			"Network",
			array("enabled" => "0"),
			"",
			array("device" => "eth1")
		);

} elseif ($ipAddressField2 && ($ipAddressField2 != $ipAddressOrig2 || $netMaskField2 != $netMaskOrig2)){
	// setup eth1 if they have entered anything new for ip or netmask
	$cceClient->setObject(
			"Network", 
			array(
				"ipaddr" => $ipAddressField2, 
				"netmask" => $netMaskField2, 
				"enabled" => "1", 
				"bootproto" => "none"
			), 
			"", 
			array("device" => "eth1")
		);
}

$eth1errors = $cceClient->errors();

// turn off PPPoE
$cceClient->set($oids[0], "Pppoe", array("connMode" => "off"));
$errors = array_merge($errors, $cceClient->errors());

// turn off modem
$cceClient->set($oids[0], "Modem", array("connMode" => "off"));
$errors = array_merge($errors, $cceClient->errors());

if( count($eth1errors) == 0 && $SERVER_ADDR == $ipAddressOrig2 and $ipAddressOrig2 != $ipAddressField2 ){	//If IP is different and admin used this IP, redirect to new one
	?>
	<SCRIPT LANGUAGE="Javascript">
	<!--
		setTimeout("parent.location = 'http://<? echo $ipAddressField2; ?>/login'", 200);
	//-->
	</SCRIPT>
	<?
} else {
	print($serverScriptHelper->toHandlerHtml("/base/network/wan.php", array_merge($eth1errors, $errors)));
}




$serverScriptHelper->destructor();
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
