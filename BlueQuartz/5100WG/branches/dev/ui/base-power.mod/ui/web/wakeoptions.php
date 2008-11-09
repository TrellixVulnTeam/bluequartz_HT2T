<?php
// Copyright 2000, Cobalt Networks.  All rights reserved.
// $Id: wakeoptions.php 201 2003-07-18 19:11:07Z will $

include("ServerScriptHelper.php");
include("uifc/Label.php");
include("uifc/Option.php");
include("uifc/TextList.php");

$serverScriptHelper = new ServerScriptHelper();
$cceClient = $serverScriptHelper->getCceClient();

if (!$action) {
  $action = "display";
}

// if $useExistingData is true, the page will display the data
// that exists in global variables, rather than looking up the data
// in CCE. That enables us to return errors without blowing away
// all user data.
$useExistingData = ($action == "commit") ? true : false;

// HANDLE PAGE
if ($action == "commit") {
  $errors = handlePage($wakemode);

  genPage($useExistingData, $errors);

} else if ($action == "display") {

// DISPLAY PAGE
  genPage($useExistingData);
}

$serverScriptHelper->destructor();
exit;


function genPage($useExistingData, $errors = array()) {
  global $cceClient;
  global $serverScriptHelper;
  global $wakemode;

  $factory = $serverScriptHelper->getHtmlComponentFactory("base-power", "/base/power/wakeoptions.php?action=commit");

  if (!$useExistingData) {
    list($sysoid) = $cceClient->find("System");
    $cceWakeOpts = $cceClient->get($sysoid, "Power");
    $wakemode = $cceWakeOpts["wakemode"];
  }

  $page = $factory->getPage();
  
  $modeBlock = $factory->getPagedBlock("wakeMode_block");
  
  //using a multichoice dropdown
   
  $wakeModeField = $factory->getMultiChoice("wakemode");
  
  $noneOption = $factory->getOption("none", $wakemode == "none");
  $wakeModeField->addOption($noneOption);
  
  $magicOption = $factory->getOption("magic", $wakemode == "magic");
  $wakeModeField->addOption($magicOption);
  
  $modeBlock->addFormField($wakeModeField, $factory->getLabel("wakemode"));
  
  $modeBlock->addButton($factory->getSaveButton($page->getSubmitAction()));
  
  //Add error handling to page
  $modeBlock->process_errors($errors, array("wakemode" => "wakemode"));

  print($page->toHeaderHtml());
  print($modeBlock->toHtml()); 
  print($page->toFooterHtml()); 
}


function handlePage($wakemode) {
  global $cceClient;

  $cceClient->setObject("System", array("wakemode" => $wakemode), "Power");
  
  return $cceClient->errors();
}



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

