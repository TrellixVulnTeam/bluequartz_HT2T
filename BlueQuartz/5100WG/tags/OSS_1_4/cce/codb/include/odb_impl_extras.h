/* 
 * these are bits that are part of the impl-odb interface, but are impl
 * specific
 */

#ifndef _CCE_ODB_IMPL_EXTRAS_H_
#define _CCE_ODB_IMPL_EXTRAS_H_ 1

#define MAX_PATHLEN           512
#define ODB_DIR			CCEDBDIR
#define PATHVAR(x)		char x[MAX_PATHLEN]

#include <odb_types.h>

#include <stdio.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
 
/* 
 * FIXME: these should all take an impl_handle *, and use h->db_path, not
 * ODB_DIR
 */
static inline char *
objpathof_ul(unsigned long oid, char *result)
{
	snprintf(result, MAX_PATHLEN-1, "%s/objects/%lu", ODB_DIR, oid);
	
	return result;
}	
static inline char *
objpathof(odb_oid *oid, char *result)
{
	return objpathof_ul(oid->oid, result);
}

static inline char *
proppathof(char *path, char *prop, char *result)
{
	snprintf(result, MAX_PATHLEN-1, "%s/%s", path, prop);
	
	return result;
}

static inline int 
isdir(char *path)
{
	struct stat s;

	if ((!stat(path, &s)) && (S_ISDIR(s.st_mode))) {
		return 1;
	}

	return 0;
}

#endif
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
