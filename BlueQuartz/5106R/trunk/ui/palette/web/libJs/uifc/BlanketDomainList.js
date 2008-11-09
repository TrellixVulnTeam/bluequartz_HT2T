// Author: Kevin K.M. Chiu
// Copyright 2000, Cobalt Networks.  All rights reserved.
// $Id: BlanketDomainList.js 259 2004-01-03 06:28:40Z shibuya $

//
// public functions
//

function DomainNameList_changeHandler(element) {
  var textArea = element.textArea;

  var entries = top.code.textArea_getEntries(textArea);
  for(var i = 0; i < entries.length; i++)
    if(!top.code.DomainName_isBlanketDomainValid(entries[i])) {
      top.code.error_invalidElement(textArea, top.code.string_substitute(element.invalidMessage, "[[VAR.invalidValue]]", entries[i]));
      return false;
    }

  return true;
}
