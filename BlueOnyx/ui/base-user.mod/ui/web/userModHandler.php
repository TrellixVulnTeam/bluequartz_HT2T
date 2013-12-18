<?php
/*
 * Copyright 2000-2002 Sun Microsystems, Inc.  All rights reserved.
 * $Id: userModHandler.php
 */

include_once("ArrayPacker.php");
include_once("ServerScriptHelper.php");
include_once("AutoFeatures.php");

$serverScriptHelper = new ServerScriptHelper();

// Only adminUser and siteAdmin should be here
if (!$serverScriptHelper->getAllowed('adminUser') &&
    !($serverScriptHelper->getAllowed('siteAdmin') &&
      $group == $serverScriptHelper->loginUser['site'])) {
  header("location: /error/forbidden.html");
  return;
}

// Start sane:
$errors = array();

$autoFeatures = new AutoFeatures($serverScriptHelper);
$cceClient = $serverScriptHelper->getCceClient();

$oids = $cceClient->find("User", array("name" => $userNameField));
$iam = $serverScriptHelper->getLoginName();

// modify user
$attributes = array("fullName" => $fullNameField);
if($sortNameField)
  $attributes["sortName"]=$sortNameField;
if($passwordField)
  $attributes["password"] = $passwordField;
$obj = $cceClient->get($oids[0], "");
if (!$obj["desc_readonly"]) {
  $attributes["description"] = $userDescField;	
}

# don't set this attribute now if a siteadmin is trying to demote himself
if (isset($siteAdministrator) && ($siteAdministrator || (!$siteAdministrator && ($iam != $userNameField))))
  $attributes["capLevels"] = ($siteAdministrator ? '&siteAdmin&' : '');

if (isset($dnsAdministrator) && ($dnsAdministrator || (!$dnsAdministrator && ($iam != $userNameField))))
  $attributes["capLevels"] .= ($dnsAdministrator ? '&siteDNS&' : '');

// dirty trick
$attributes["capLevels"] = str_replace("&&", "&", $attributes["capLevels"]);

if (isset($suspendUser))
  $attributes['ui_enabled'] = ($suspendUser) ? '0' : '1';

// Handle FTP access clauses:
if ($ftpForNonSiteAdmins == "0") {
    $hasNoFTPaccess = "1";
}
else {
    $hasNoFTPaccess = "0";
}

if ($siteAdministrator == "1") {
    $hasNoFTPaccess = "0";
}

// Username = Password? Baaaad idea!
if (strcasecmp($userNameField, $passwordField) == 0) {
        $attributes["password"] = "1";
        $error_msg = "[[base-user.error-password-equals-username]] [[base-user.error-invalid-password]]";
        $errors[] = new Error($error_msg);
}

// Only run cracklib checks if something was entered into the password field:
if ($passwordField) {

    // Open CrackLib Dictionary for usage:
    $dictionary = crack_opendict('/usr/share/dict/pw_dict') or die('Unable to open CrackLib dictionary');

    // Perform password check with cracklib:
    $check = crack_check($dictionary, $passwordField);

    // Retrieve messages from cracklib:
    $diag = crack_getlastmessage();

    if ($diag == 'strong password') {
        // Nothing to do. Cracklib thinks it's a good password.
    }
    else {
        $attributes["password"] = "1";
        $errors[] = new Error("[[base-user.error-password-invalid]]" . $diag . ". " . "[[base-user.error-invalid-password]]");
    }

    // Close cracklib dictionary:
    crack_closedict($dictionary);
}

$attributes['emailDisabled'] = $emailDisabled;

$attributes['ftpDisabled'] = $hasNoFTPaccess;

$cceClient->set($oids[0], "", $attributes);
//$errors = $cceClient->errors();

for ($i = 0; $i < count($errors); $i++) {
	if ( ($errors[$i]->code == 2) && ($errors[$i]->key === "password"))
	{
		$errors[$i]->message = "[[base-user.error-invalid-password]]";
	}
}

// set quota
if(!$maxDiskSpaceField)
	$maxDiskSpaceField = -1;

$cceClient->set($oids[0], "Disk", array("quota" => $maxDiskSpaceField));
$errors = array_merge($errors, $cceClient->errors());

if ( isset( $group ) && $group != "" )
  $site = $group;

// handle autofeatures
list($userservices) = $cceClient->find("UserServices", array("site" => $site));
$af_errors = $autoFeatures->handle("modify.User", array("CCE_SERVICES_OID" =>
$userservices, "CCE_OID" => $oids[0]));
$errors = array_merge($errors, $af_errors);

$userNames = $cceClient->names("User");

// set group membership
$memberGroups = stringToArray($memberGroupsField);
$goids = $cceClient->find("Workgroup");
for($i = 0; $i < count($goids); $i++) {
  $group = $cceClient->get($goids[$i]);
  $members = stringToArray($group["members"]);

  if(in_array($group["name"], $memberGroups)) {
    // add user to group
    $found = false;
    for($j = 0; $j < count($members); $j++)
	if($members[$j] == $userNameField) {
	  $found = true;
	  break;
	}
    if(!$found)
	$members[] = $userNameField;
  }
  else {
    // remove user from group
    for($j = 0; $j < count($members); $j++)
	if($members[$j] == $userNameField) {
	  array_splice($members, $j, 1);
	  break;
	}
  }

  // update CCE
  $cceClient->set($goids[$i], "", array("members" => arrayToString($members)));
  $errors = array_merge($errors, $cceClient->errors());
}

// set email forwarding info
$cceClient->set($oids[0], "Email", array(
	"forwardEnable" => ($forwardEnableField ? 1 : 0), 
	"forwardEmail" => $forwardEmailField, 
	"forwardSave" => $forwardSaveField));
$errors = array_merge($errors, $cceClient->errors());

// set email aliases info

//Prune the duplicate email aliases
$emailAliasesFieldArray = $cceClient->scalar_to_array($emailAliasesField);
$emailAliasesFieldArray = array_unique($emailAliasesFieldArray);
$emailAliasesField = $cceClient->array_to_scalar($emailAliasesFieldArray);

// replace && with &, to avoid always getting a blank alias in the field
// in cce, this also skirts around dealing with browser issues
$emailAliasesField = str_replace("&&", "&", $emailAliasesField);
if ($emailAliasesField == '&') {
	$emailAliasesField = '';
}

$attributes = array("aliases" => $emailAliasesField);
#if ( isset($apop) ) 
#  $attributes["apop"] = $apop;

$cceClient->set($oids[0], "Email", $attributes);
$errors = array_merge($errors, $cceClient->errors());

// set vacation info
if ($_autoRespondStartDate_amPm == "PM") { 
  $_autoRespondStartDate_hour = $_autoRespondStartDate_hour + 12; 
 } 

if ($_autoRespondStopDate_amPm == "PM") { 
  $_autoRespondStopDate_hour = $_autoRespondStopDate_hour + 12; 
 } 

$vacationMsgStart = mktime($_autoRespondStartDate_hour, $_autoRespondStartDate_minute, 
			   $_autoRespondStartDate_second, $_autoRespondStartDate_month, 
			   $_autoRespondStartDate_day, $_autoRespondStartDate_year); 
$vacationMsgStop = mktime($_autoRespondStopDate_hour, $_autoRespondStopDate_minute, 
			  $_autoRespondStopDate_second, $_autoRespondStopDate_month, 
			  $_autoRespondStopDate_day, $_autoRespondStopDate_year); 

if (($vacationMsgStop - $vacationMsgStart) < 0) { 
  $vacationMsgStop = $oldStop; 
  
  $error_msg = "[[base-user.invalidVacationDate]]"; 
  $errors[] = new Error($error_msg); 
 } 

$cceClient->set($oids[0], "Email", array( 
	"vacationOn" => ($autoResponderField ? 1 : 0), 
        "vacationMsg" => $autoResponderMessageField, 
	"vacationMsgStart" => $vacationMsgStart, 
	"vacationMsgStop" =>$vacationMsgStop)); 
$errors = array_merge($errors, $cceClient->errors());

# log the user out if they are trying to demote themself
if (isset($siteAdministrator) && !$siteAdministrator && ($iam == $userNameField)) {
  $cceClient->set($oids[0], "", array('capLevels' => ''));
  print($serverScriptHelper->toHandlerHtml("/logoutHandler.php"));
  $serverScriptHelper->destructor();
  exit(0);
}

print($serverScriptHelper->toHandlerHtml("/base/user/userList.php?group=" . $obj["site"], $errors, false));

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