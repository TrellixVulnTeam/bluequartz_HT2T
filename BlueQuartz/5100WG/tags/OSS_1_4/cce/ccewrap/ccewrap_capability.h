#ifndef CCEWRAP_CAPABILITY_H
#define CCEWRAP_CAPABILITY_H 1

#include "../include/xml_parse.h"

typedef struct ccewrapconf_capability_t* ccewrapconf_capability;

#include "ccewrap_conf.h"

ccewrapconf_capability ccewrapconf_capability_new (void);
void ccewrapconf_capability_free (ccewrapconf_capability);
ccewrapconf_capability mk_capability (struct xml_element *e);

void ccewrapconf_capability_setrequires (ccewrapconf_capability capability, char *requires);
char *ccewrapconf_capability_getrequires (ccewrapconf_capability capability);
void ccewrapconf_capability_setuser (ccewrapconf_capability capability, char *user);
char *ccewrapconf_capability_getuser (ccewrapconf_capability capability);
char *ccewrapconf_capability_getuser (ccewrapconf_capability capability);
int ccewrapconf_capability_allowed(ccewrapconf_capability capability, ccewrapconf conf, GList **validUsers);

#endif /* CCEWRAP_CAPABILITY_H */
/* Copyright (c) 2003 Sun Microsystems, Inc. All  Rights Reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met: 
 * 
 * -Redistribution of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 * 
 * -Redistribution in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution. 
 *
 * Neither the name of Sun Microsystems, Inc. or the names of contributors may
 * be used to endorse or promote products derived from this software without 
 * specific prior written permission.

 * This software is provided "AS IS," without a warranty of any kind. ALL EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES, INCLUDING ANY IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR NON-INFRINGEMENT, ARE HEREBY EXCLUDED. SUN MICROSYSTEMS, INC. ("SUN") AND ITS LICENSORS SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES. IN NO EVENT WILL SUN OR ITS LICENSORS BE LIABLE FOR ANY LOST REVENUE, PROFIT OR DATA, OR FOR DIRECT, INDIRECT, SPECIAL, CONSEQUENTIAL, INCIDENTAL OR PUNITIVE DAMAGES, HOWEVER CAUSED AND REGARDLESS OF THE THEORY OF LIABILITY, ARISING OUT OF THE USE OF OR INABILITY TO USE THIS SOFTWARE, EVEN IF SUN HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
 * 
 * You acknowledge that  this software is not designed or intended for use in the design, construction, operation or maintenance of any nuclear facility.
 */
