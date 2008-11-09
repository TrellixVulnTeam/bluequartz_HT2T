<?php
// Author: jmayer@cobalt.com
// Copyright 2000, Cobalt Networks.  All rights reserved.
// $Id: IntRange.php 259 2004-01-03 06:28:40Z shibuya $

global $isIntRangeDefined;
if($isIntRangeDefined)
  return;
$isIntRangeDefined = true;

include("uifc/FormField.php");
include("uifc/FormFieldBuilder.php");

class IntRange extends FormField {
  //
  // private variables
  //

  //
  // public methods
  //

  // description: constructor
  // param: page: the Page object this form field lives in
  // param: id: the identifier of this object
  // param: value: the default value
  // param: invalidMessage: message to be shown upon invalid input. Optional
  // param: emptyMessage: message to be shown upon empty input
  //     if the field is not optional. This message is optional
  function IntRange(&$page, $id, $value, $invalidMessage, $emptyMessage = "") {
    // superclass constructor
    $this->FormField($page, $id, $value, $invalidMessage, $emptyMessage);

    $this->isConfirm = true;
  }

  function isConfirm() {
    return $this->isConfirm;
  }

  // description: set the config flag
  // param: isConfirm: if true, a confirm field is shown
  function setConfirm($isConfirm) {
    $this->isConfirm = $isConfirm;
  }

  function toHtml($style = "") {
    $id = $this->getId();
    $access = $this->getAccess();
    $value = $this->getValue();
    
    $regs = array();
    if (ereg("^([^:]+):(.+)", $value, $regs)) {
      $low = $regs[1]; $high = $regs[2];
    } else {
      $low = $value; $high = $value;
    }
    
    $onchange = "if (document.form.high_$id.value - 0 < document.form.low_$id.value - 0) { "
      . " document.form.high_$id.value = document.form.low_$id.value; "
      . " };"
      . "document.form.$id.value = document.form.low_$id.value + ':' + document.form.high_$id.value; "
      . "if (!document.form.low_$id.value) { document.form.$id.value = ''; }; "
	. "return true;";

    $formField = "
<TABLE BORDER=\"0\" CELLPADDING=\"0\" CELLSPACING=\"0\">
  <TR>
    <TD>
      <input type=\"hidden\" name=\"$id\" value=\"$value\">
      <input type=\"text\" name=\"low_$id\" value=\"$low\" 
      	size=\"5\"
	onChange=\"$onchange\">
    </td>
    <td>&nbsp;-&nbsp;</td>
    <td>
      <input type=\"text\" name=\"high_$id\" value=\"$high\"
      	size=\"5\"
	onChange=\"$onchange\">
    </td>
  </tr>
</table>
";
  
    return $formField;
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
