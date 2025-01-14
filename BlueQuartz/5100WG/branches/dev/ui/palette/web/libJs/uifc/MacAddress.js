// Author: Kevin K.M. Chiu
// Copyright 2000, Cobalt Networks.  All rights reserved.
// $Id: MacAddress.js 201 2003-07-18 19:11:07Z will $

function MacAddress_changeHandler(element) {
  if(!MacAddress_isMacAddressValid(element.value)) {
    top.code.error_invalidElement(element, top.code.string_substitute(element.invalidMessage, "[[VAR.invalidValue]]", element.value));
    return false;
  }

  return true;
}

function MacAddress_isMacAddressValid(macAddr) {
  if(macAddr.length == 0)
    return true;

  var chucks = macAddr.split(":");

  // must have 6 chucks
  if(chucks.length != 6)
    return false;

  for(var i = 0; i < chucks.length; i++) {
    var chuck = chucks[i];

    // each chuck must have 2 characters
    if(chuck.length != 2)
      return false;

    for(var j = 0; j < chuck.length; j++) {
      var ch = chuck.charAt(j);

      // each character must be alphanumeric
      if(!top.code.string_isAlpha(ch) && !top.code.string_isNumeric(ch))
	return false;
    }
  }

  return true;
}