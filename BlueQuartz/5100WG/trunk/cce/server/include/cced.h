/*
 * $Id: cced.h 3 2003-07-17 15:19:15Z will $
 *
 * This is the header for the CCE daemon
 * copyright (c) 2000 Cobalt Networks, Inc.
 */

#ifndef __CCED_H__
#define __CCED_H__

#include <cce_common.h>

#ifdef DEBUG_CCED
#	define CCE_ENABLE_DEBUG
#else
#	undef CCE_ENABLE_DEBUG
#endif /* ifdef DEBUG */
#include <cce_debug.h>

/***** globals ******/
extern char *progname;
extern char **progargv;
extern char *progdir;

extern int ndflag;	/* don't daemonize */
extern int nfflag;	/* don't fork */
extern int nhflag;	/* don't use handlers */
extern int roflag;	/* read-only */
extern int vflag;		/* be verbose */
extern char cced_conf_dir[];

#define OPENLOG(id)	\
	do { \
		openlog(id, LOG_PID, LOG_DAEMON); \
	} while (0)

#define DEF_DIR				CCEDIR
#define DEF_CONF_DIR			CCECONFDIR
#define MAINTENANCE_LOCK		CCEDIR "cced.lock"

/* Session Manager */
#define SMD_UDS_NAME			CCESOCKET
#define SMD_MAX_CONNECTIONS		1024
void start_smd_thread(void) __attribute__ ((noreturn));

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
