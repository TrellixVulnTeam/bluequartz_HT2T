<?php
// Author: Kevin K.M. Chiu
// Copyright 2000, Cobalt Networks.  All rights reserved.
// $Id: userAdd.php 259 2004-01-03 06:28:40Z shibuya $

include_once("ArrayPacker.php");
include_once("ServerScriptHelper.php");
include_once("AutoFeatures.php");

$serverScriptHelper = new ServerScriptHelper();
$cceClient = $serverScriptHelper->getCceClient();
$factory = $serverScriptHelper->getHtmlComponentFactory("base-user", "/base/user/userAddHandler.php");
$i18n = $factory->i18n;

// slight efficiency gain
$errors = $serverScriptHelper->getErrors();
if (count($errors) == 0)
{
    // defaults
    if ($group)
    { 
        $defaults = $cceClient->getObject("Vsite", array("name" => $group), "UserDefaults");
    }
    else  
    {
        $defaults = $cceClient->getObject("System", array(), "UserDefaults");
    }
}

$page = $factory->getPage();
$form = $page->getForm();
$formId = $form->getId();

$block = $factory->getPagedBlock("addNewUser");
if ($group) {
  list($vsite) = $cceClient->find("Vsite", array("name" => $group));
  $vsiteObj = $cceClient->get($vsite);
  $block->setLabel($factory->getLabel('addNewUserTitle', false, array('fqdn' => $vsiteObj['fqdn'])));
}

if(count($errors) > 0)
{
    $block->processErrors($errors, array('fullName' => 'fullNameField', 'name' => 'userNameField', 'password' => 'passwordField', 'description' => 'userDescField', 'quota' => 'maxDiskSpaceField', 'capLevels' => 'siteAdministrator', 'aliases' => 'emailAliasesField'));
}

$block->addFormField($factory->getTextField("group", $group, ""));

$block->addFormField(
    $factory->getFullName("fullNameField", $fullNameField),
    $factory->getLabel("fullNameField")
);

$prop=$i18n->getProperty("needSortName");
if($prop=="yes"){
	    $sortName=$factory->getFullName("sortNameField", $sortNameField);
	    $sortName->setOptional('silent');
	    $block->addFormField(
	            $sortName,
                $factory->getLabel("sortNameField")
	);
}

$block->addFormField(
    $factory->getUserName("userNameField", $userNameField),
    $factory->getLabel("userNameField")
);

$block->addFormField(
    $factory->getPassword("passwordField", $passwordField),
    $factory->getLabel("passwordField")
);

// Load site quota
if ($group)
{
    list($vsite_oid) = $cceClient->find('Vsite', array("name" => $group));
    $disk = $cceClient->get($vsite_oid, 'Disk');
    $max_quota = $disk['quota'];
}

$site_quota = ($max_quota == -1 ? 499999999 : $max_quota);

$quota = $factory->getInteger(
			"maxDiskSpaceField", 
			($defaults['quota'] != -1 ? $defaults['quota'] : ""), 
			1, $site_quota);
// quota is not optional for site members on raqs
if (!isset($group)) {
	$quota->setOptional('silent');
}

if($max_quota && $max_quota != -1)
    $quota->showBounds(1);

$block->addFormField(
    $quota,
    $factory->getLabel("maxDiskSpaceField")
);


// add other features
$autoFeatures = new AutoFeatures($serverScriptHelper);

if (isset($group) && $group != "") 
{
    list($userServices) = $cceClient->find("UserServices", array("site" => $group));
    list($vsite) = $cceClient->find("Vsite", array("name" => $group));
    $autoFeatures->display($block, "create.User", array("CCE_SERVICES_OID" => $userServices, "VSITE_OID" => $vsite));

    $block->addFormField(
        $factory->getBoolean("siteAdministrator", ""),
        $factory->getLabel("siteAdministratorField")
    );
 
}
else 
{
    list($userServices) = $cceClient->find("UserServices");
    $autoFeatures->display($block, "create.User", array("CCE_SERVICES_OID" => $userServices));
}

// make group list if Workgroup exists
$cceClient->names("Workgroup");
if (count($cceClient->errors()) == 0)
{
    $groups = $cceClient->getObjects("Workgroup");
  	$groupNames = array();
  	for($i = 0; $i < count($groups); $i++) 
    {
        $group = $groups[$i];
        $groupNames[] = $group["name"];
  	}
  	$groupNamesString = arrayToString($groupNames);
  
  	$groupSelector = $factory->getSetSelector("memberGroupsField", "", $groupNamesString, "memberGroups", "allGroups");
  	$groupSelector->setOptional(true);
  	$block->addFormField(
                $groupSelector,
                $factory->getLabel("memberGroupsField")
        );
}
	
$emailAliases = $factory->getEmailAliasList("emailAliasesField");
$emailAliases->setOptional(true);
$block->addFormField(
    $emailAliases,
    $factory->getLabel("emailAliasesField")
);

$textblock = $factory->getTextBlock("userDescField", 
	                $i18n->interpolate($default["description"]));
$textblock->setWidth(2*$textblock->getWidth());
$textblock->setOptional(true);
$block->addFormField(
    $textblock,
    $factory->getLabel("userDescField")
);

$block->addButton($factory->getSaveButton($page->getSubmitAction()));
$block->addButton($factory->getCancelButton("/base/user/userList.php?group=$group"));

$serverScriptHelper->destructor();
?>
<?php print($page->toHeaderHtml()); ?>

<SCRIPT LANGUAGE="javascript" SRC="userNameGenerator.JS"></SCRIPT>
<SCRIPT LANGUAGE="javascript" SRC="emailAliasGenerator.JS"></SCRIPT>

<?php 
print($block->toHtml());
if ( $group ) {
	$vsite = $factory->getTextField("group", $group, "");
	print($vsite->toHtml());
}
?>

<SCRIPT LANGUAGE="javascript">
var oldChangeHandler = document.<?php print($formId)?>.fullNameField.onchange;

function fullNameChangeHandler() {
  if(oldChangeHandler != null) {
    var ret = oldChangeHandler();
    if(!ret)
      return ret;
  }

  var form = document.<?php print($formId)?>;

  // generate user name
  if(form.userNameField.value == "")
    form.userNameField.value = userNameGenerator_generate(form.fullNameField.value, "<?php print($defaults["userNameGenMode"]) ?>");

  // generate email alias
  if(form.emailAliasesField.textArea.value == "") {
    var alias = emailAliasGenerator_generate(form.fullNameField.value);
    if(alias != form.userNameField.value)
      form.emailAliasesField.textArea.value = alias;
  }
}
<?php
if($i18n->getProperty("genUsername")=="yes"){
	print("document.$formId.fullNameField.onchange = fullNameChangeHandler;\n");
}
?>
</SCRIPT>

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
