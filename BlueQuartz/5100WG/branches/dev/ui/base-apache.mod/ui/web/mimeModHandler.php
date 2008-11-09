<?
include_once("ServerScriptHelper.php");
$serverScriptHelper = new ServerScriptHelper();
$cce = $serverScriptHelper->getCceClient();

$data = array(
	'extension' => $extension,
	'application' => $application,
);

if ($oid) {
  // I'm modifying!
  $cce->set($oid, "", $data);
} else {
  // I'm creating!
  $cce->create("MimeType", $data);
}

$errors=$cce->errors();

$goto="/base/apache/mimeList.php";
if(!empty($errors)){
	$goto="/base/apache/mimeMod.php";
}

for($i=0;$i<count($errors);$i++){
	if($errors[$i]->{"key"}=="application"){
		$errors[$i]->{"message"}="[[base-apache.application_invalid]]";
		$errors[$i]->{"key"}="";
	}

	if($errors[$i]->{"key"}=="extension"){
                $errors[$i]->{"message"}="[[base-apache.extension_invalid]]";
		$errors[$i]->{"key"}="";
        }
}


print $serverScriptHelper->toHandlerHtml($goto, $errors);
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

