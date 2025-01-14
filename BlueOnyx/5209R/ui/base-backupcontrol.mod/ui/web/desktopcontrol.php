<?php
/*
 * $Id: desktopcontrol.php
 *
 */
include_once("ServerScriptHelper.php");

$helper = new ServerScriptHelper();

// Only 'serverServerDesktop' should be here
if (!$helper->getAllowed('serverServerDesktop')) {
  header("location: /error/forbidden.html");
  return;
}

$cce = $helper->getCceClient();
$factory = $helper->getHtmlComponentFactory('base-backupcontrol',
    '/base/backupcontrol/desktopcontrolHandler.php');

// get settings
$systemObj = $cce->getObject('System', array(), 'DesktopControl');

$page = $factory->getPage();
$block = $factory->getPagedBlock('desktop_control');
$block->processErrors($helper->getErrors());

$access = 'rw';

$block->addFormField($factory->getBoolean('lock_desktop', $systemObj['lock'], $access),
	$factory->getLabel('lock_desktop')
);

// Don't ask why, but somehow with PHP5 we need to add a blank FormField or nothing shows on this page:
$hidden_block = $factory->getTextBlock("Nothing", "");
$hidden_block->setOptional(true);
$block->addFormField(
    $hidden_block,
    $factory->getLabel("Nothing"),
    "Hidden"
    );

// Allow the administrator to change the setting
$block->addButton($factory->getSaveButton($page->getSubmitAction()));

$helper->destructor();
?>
<?php print($page->toHeaderHtml()); ?>

<?php print($block->toHtml()); ?>

<?php print($page->toFooterHtml());

/*
Copyright (c) 2013 Michael Stauber, SOLARSPEED.NET
Copyright (c) 2013 Team BlueOnyx, BLUEONYX.IT
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