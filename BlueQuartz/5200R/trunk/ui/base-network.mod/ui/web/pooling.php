<?php
// Copyright Sun Microsystems, Inc. 2001
// $Id: pooling.php 533 2005-08-12 09:40:56Z shibuya $

include_once("ServerScriptHelper.php");
include_once("uifc/Label.php");
include_once("uifc/TextList.php");
include_once("uifc/Button.php");
include_once("uifc/FormFieldBuilder.php");

$serverScriptHelper = new ServerScriptHelper();
$cceClient = $serverScriptHelper->getCceClient();

// Only adminUser should be here
if (!$serverScriptHelper->getAllowed('adminUser')) {
  header("location: /error/forbidden.html");
  return;
}

if (!isset($action)) {
  $action = "display";
}

//HANDLE PAGE
if ($action != "display") {
  $errors = handlePage();
} 

// SET UP DATA
// First, get data from CCE
list($sysoid) = $cceClient->find("System");
$network = $cceClient->get($sysoid, 'Network');
$enabled = $network['pooling'];

$oids = $cceClient->findx('IPPoolingRange', array(), array(), 'old_numeric', 'creation_time');
$ranges = array();

foreach ($oids as $oid) {
  $ranges[$oid] = $cceClient->get($oid);
}

// $act_on == 'new' if we're in the process of handling a new range
// during 'add' and 'edit' states, show an empty editable row
// during the 'save' state with errors, we show an editable row
// else, we don't add a row, just use the CCE data
$need_editable_row = ($action == 'add' || $action == 'edit' || ($action == 'save' && $errors));

if ($act_on == 'new' && $need_editable_row) {
  $ranges['new'] = array( 'min' => '', 'max' => '');
}


// Make modifications depending on error condition
// and what action we're handling
if ($action == "delete" && $errors) {
  // If errors when deleting, just use the original CCE data
} else if ($action == "save" && $errors) {
  // If errors when saving, restore the data in the edited row
  $min_string = "range_min$act_on";
  $max_string = "range_max$act_on";
  $ranges[$act_on]['min'] = $HTTP_POST_VARS[$min_string];
  $ranges[$act_on]['max'] = $HTTP_POST_VARS[$max_string];
  
} else {
  // The above are the only cases which throw errors.
  // If we get to here, there are no errors.
  // Just use the CCE data
} 


// ------------------------------------------------------------------------------------
// When I get to here, all the data should be in an array called $ranges
// $num_edit_rows is the number of rows that have an "edit" field with
// $ranges[$oid] = array( 'min' => $min, 'max' => $max);
// A "new" entry will be in $ranges["new"];
// ------------------------------------------------------------------------------------

$factory = $serverScriptHelper->getHtmlComponentFactory("base-network", "/base/network/pooling.php");

$page = $factory->getPage();

$rangeList = $factory->getScrollList("rangeList", 
				array("min", "max", ""));

reset($ranges);
while (list($oid, $range) = each($ranges)) {

  // Loop through data and add the entries to scroll list
  // If we need to edit, make the $act_on field read/write, with save buttons
  // Else, just display the data in $range_mins, $range_maxes
  $min_string = "range_min$oid";
  $max_string = "range_max$oid";
  // We need to edit if:
  // 1. We are in "edit" mode
  // 2. We are in "save" mode, but couldn't save for some reason.
  $need_editable_row = ($action == 'add' || $action == 'edit' || ($action == 'save' && $errors));
  
  $act_on_this = ($act_on == $oid);

  if ($act_on_this && $need_editable_row) {
    $minField = $factory->getTextField($min_string, $range['min'], "rw");
    $maxField = $factory->getTextField($max_string, $range['max'], "rw");
  } else {
    $minField = $factory->getTextField($min_string, $range['min'], "r");
    $maxField = $factory->getTextField($max_string, $range['max'], "r");
  }
  $minField->setOptional("silent");
  $maxField->setOptional("silent");
  $minField->setPreserveData(false);
  $maxField->setPreserveData(false);

  // Create the buttons
  $actions = $factory->getCompositeFormField();

  // If in edit mode, we need save and delete buttons for the one we're editing
  // If in save mode and we have an error when saving, we need to edit the field, so have save and delete buttons.

  // if we're editing an actual existing row, delete will delete it. cancel will abort the operation.
  if ( $act_on_this && $oid != 'new' && $need_editable_row) {
    $saveButton = $factory->getButton("javascript: document.form.onsubmit(); document.form.action.value='save'; document.form.act_on.value = '$oid'; document.form.submit()", "save");
    $actions->addFormField($saveButton);
    
    $deleteButton = $factory->getRemoveButton("javascript: document.form.onsubmit(); document.form.action.value='delete';  document.form.act_on.value = '$oid'; document.form.submit()");
    $actions->addFormField($deleteButton);
    $cancelButton = $factory->getButton("javascript: document.form.onsubmit(); document.form.action.value='display'; document.form.submit()", "cancel");
    $actions->addFormField($cancelButton);
  } else if ($act_on_this && $oid == 'new' && $need_editable_row) {
    // if we're adding a new row, then delete and cancel will abort the operation by simply putting the page into 'display' mode
    $saveButton = $factory->getButton("javascript: document.form.onsubmit(); document.form.action.value='save'; document.form.act_on.value = 'new'; document.form.submit()", "save");
    $actions->addFormField($saveButton);
    
    $deleteButton = $factory->getRemoveButton("javascript: document.form.onsubmit(); document.form.action.value='display'; document.form.submit()");
    $actions->addFormField($deleteButton);
    $cancelButton = $factory->getButton("javascript: document.form.onsubmit(); document.form.action.value='display'; document.form.submit()", "cancel");
    $actions->addFormField($cancelButton);
  } else {
    // Otherwise, have edit and delete buttons
    $modifyButton = $factory->getModifyButton("javascript: document.form.onsubmit(); document.form.action.value='edit'; document.form.act_on.value = '$oid'; document.form.submit()");
    $actions->addFormField($modifyButton);
    $deleteButton = $factory->getRemoveButton("javascript: document.form.onsubmit(); document.form.action.value='delete';  document.form.act_on.value = '$oid'; document.form.submit()");
    $actions->addFormField($deleteButton);
  }

  // Finally, add the entry to the list
  $rangeList->addEntry(array($minField, $maxField, $actions));
}

if (!$need_editable_row) {
  $addButton = $factory->getButton("javascript: document.form.onsubmit(); document.form.action.value='add'; document.form.act_on.value = 'new'; document.form.submit();", "add");
  $rangeList->addButton($addButton);
} 

// Now we create the "enable" part of the page
$enableBlock = $factory->getPagedBlock("pooling_block");
$enabledField = $factory->getBoolean("enabled", $enabled);
$enabledField->setPreserveData(false);
$enableBlock->addFormField($enabledField, $factory->getLabel("enabledField"));
$enableButton = $factory->getButton("javascript: document.form.onsubmit(); document.form.action.value='enable'; document.form.submit();", "saveEnabled");
$enableBlock->addButton($enableButton);


// Hidden fields for $action and $act_on
$builder = new FormFieldBuilder();
$hiddenAction = $builder->makeHiddenField("action", "");
$actionNumber = $builder->makeHiddenField("act_on", "");


print ($page->toHeaderHtml());
print ($hiddenAction);
print ($actionNumber);
print ($enableBlock->toHtml());
print ("<BR>");
print ($rangeList->toHtml());
if ($errors) {
  print "<SCRIPT LANGUAGE=\"JAVASCRIPT\">\n";
  print $serverScriptHelper->toErrorJavascript($errors);
  print "</SCRIPT>\n";
}
print ($page->toFooterHtml());
  
$serverScriptHelper->destructor();
exit;

function handlePage() {
  global $cceClient;
  global $act_on;
  global $action;
  global $HTTP_POST_VARS;

  // if add, the create new from HTTP_POST_VARS
  // if delete, then delete
  // if save, then set
  // if enable, then enable
  switch ($action) {
    case 'delete':
      $ok = $cceClient->destroy($act_on);
      if (!$ok) {
	return $cceClient->errors();
      }
      break;
    case 'save':
      $values = array();
      if ($HTTP_POST_VARS["range_min$act_on"]) {
	$values['min'] = $HTTP_POST_VARS["range_min$act_on"];
      }
      if ($HTTP_POST_VARS["range_max$act_on"]) {
	$values['max'] = $HTTP_POST_VARS["range_max$act_on"];
      }
      if ($act_on == 'new') {
	$ok = $cceClient->create('IPPoolingRange', $values);
      } else {
	$ok = $cceClient->set($act_on, '', $values);
      }
      if (!$ok) {
	return $cceClient->errors();
      }
      break;
    case 'enable':
      list($sysoid) = $cceClient->findx('System');
      $ok = $cceClient->set($sysoid, 'Network', array('pooling' => $HTTP_POST_VARS['enabled']));
      if (!$ok) {
	return $cceClient->errors();
      }
      break;
    case 'add':
    case 'edit':
    case 'display':
    default :
      break;
  }
  
  return;
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
