<?php
// Author: Tim Hockin
// Copyright 2000, Cobalt Networks.  All rights reserved.
// $Id: ImageButton.php 201 2003-07-18 19:11:07Z will $

global $isImageButtonDefined;
if($isImageButtonDefined)
  return;
$isImageButtonDefined = true;

include("uifc/Button.php");
include("uifc/ImageLabel.php");

class ImageButton extends Button {
  //
  // public methods
  //

  function getDefaultStyle($stylist) {
    return $stylist->getStyle("ImageButton");
  }

  // description: constructor
  // param: page: the Page object this object lives in
  // param: action: the string used within HREF attribute of the A tag
  function ImageButton($page, $action, $image, $lbl, $desc) {
    $i18n = $page->getI18n();
    $stylist = $page->getStylist();

    $label = $i18n->get($lbl);
    $description = $i18n->get($desc);

    $this->Button($page, $action, 
	new ImageLabel($page, $image, $label, $description), 
	new ImageLabel($page, $image, $label, $description)
    );
  }
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

