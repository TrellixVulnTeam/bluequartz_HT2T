/* $Id: main.c 229 2003-07-18 20:22:20Z will $ */
const char *sun_copyright = 
    "Copyright 2002 Sun Microsystems, Inc.  All rights reserved.";

/*
 * main.c
 * this is the main routine for cced
 */

#include "cce_common.h"
#include "cced.h"
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "ud_socket.h"
#include "sessionmgr.h"

#define IDSTR 	"Cobalt Configuration Engine (CCE) version " CCE_VERSION
#define CREDITS 	"   by: \n" \
			"     Tim Hockin \n" \
			"     Chris Johnson \n" \
			"     Jonathan Mayer \n" \
			"     Michael Pashniak \n"\
			"     Adrian Sun \n"\
			"     Harris Vaegan-Lloyd\n"

/* functions used internally */
static void sighandle(int s);
static void exithandle(int n);
static int daemonize(void);
static void handle_cmdline(int argc, char *argv[]);
static void usage(void);
static void version(int flag);

/* globals declared extern in cced.h are instantiated here */
char *progname = NULL;
char **progargv = NULL;
char *progdir = NULL;

/* cmdline params */
int ndflag = 0;
int nfflag = 0;
int nhflag = 0;
int roflag = 0;
char cced_dir[128] = CCEDIR;

struct cmdline_opt {
	char *opt;		/* flag as passed on cmdline */
	enum { 		/* how to interpret */
		OPT_BOOL, 
		OPT_STR, 
		OPT_ULONG, 
		OPT_LONG 
	} type;
	void *flag;		/* address to store flag result */
	char *help;		/* for usage() */
};
static struct cmdline_opt opts[] = {
	{ "-c         ", OPT_STR,  cced_dir, "set global cce dir" },
	{ "-d <num>   ", OPT_ULONG, &cce_debug_mask,  "set debugging mask" },
	{ "-nd        ", OPT_BOOL, &ndflag, "do not daemonize" },
	{ "-nf        ", OPT_BOOL, &nfflag, "do not fork (allow one client)" },
	{ "-nh        ", OPT_BOOL, &nhflag, "do not use handlers" },
	{ "-ro        ", OPT_BOOL, &roflag, "run read-only (implies -nh)" },
	{ "-st <secs> ", OPT_LONG, &session_timeout,  "set session timeout" },
	{ "-V         ", OPT_BOOL, &vflag, "verbose (errors to stderr)" },
	{ "-nl        ", OPT_BOOL, &nologflag, "no logging to syslog" },
	{ "-nt        ", OPT_BOOL, &txnstopflag, "stop txn library support" },
	{ "-tf        ", OPT_BOOL, &txnfailflag, "make all txns fail" },
	{ NULL, OPT_BOOL, NULL, NULL }
};


int
main(int argc, char *argv[])
{
	handle_cmdline(argc, argv);

	if (nologflag) {
		fprintf(stderr, "Not sending anything to syslog.\n");
		vflag = 1;
	}

	/* only leave stderr open if debugging or verbose */
	if (!vflag && !cce_debug_mask) {
		int nfd;
		nfd = open("/dev/null", O_RDWR);
		if (nfd < 0) {
			CCE_SYSLOG("open(\"/dev/null\" %s", strerror(errno));
			exit(1);
		}
		if (dup2(nfd, STDERR_FILENO) != STDERR_FILENO) {
 			CCE_SYSLOG("dup2() %s", strerror(errno));
			exit(1);
		}
	} else {
		/* any kind of output to stderr means DON'T DAEMONIZE */
		ndflag = 1;
	}

	/* prep syslog for the daemon */
	OPENLOG("cced");

	/* cwd should be consistent, so that relative paths are right */
	{ 
		char buf[256];  
		getcwd(buf, sizeof(buf));
		progdir = strdup(buf);
	}
	chdir(cced_dir);
	
        /* see if we are already running */
        if (ud_connect(CCESOCKET) >= 0) {
                CCE_SYSLOG("socket %s is busy", CCESOCKET);
                exit(42);
        }

	/* daemonize this process */
	if (!ndflag && daemonize()) {
		CCE_SYSLOG("main: daemonize() failed");
		exit(-1);
	}

	if (vflag) { 
		fprintf(stderr,"Verbose mode enabled.\n"); 
	}
	if (cce_debug_mask) {
		fprintf(stderr,"Debugging mask=0x%0lx.\n", cce_debug_mask);
	}

	DPRINTF(DBG_CCED, "main: starting up (pid %d)\n", getpid());

	CCE_SYSLOG(IDSTR);
	CCE_SYSLOG(sun_copyright);
	CCE_SYSLOG("starting up (pid %d)", getpid());
	
	/* handle signals - stubs for now */
	signal(SIGHUP, sighandle);
	signal(SIGINT, sighandle);
	signal(SIGTERM, sighandle);
	signal(SIGQUIT, sighandle);
	signal(SIGCHLD, SIG_DFL); /* POSIX says SIG_IGN + SIGCHLD == bad */

	start_smd_thread();
}

static int
daemonize(void)
{
	int pid;
	int nfd;

	/* fork and keep child */
	pid = fork();
	switch(pid) {
		case -1:
			/* damn */
			CCE_SYSLOG("daemonize: fork() %s", strerror(errno));
			return -1;
			break;
		case 0:
			/* child will continue below */
			break;
		default:
			/* parent should die */
			exit(0);
	}

	/* open /dev/null for stdin/stdout */
	nfd = open("/dev/null", O_RDWR);
	if (nfd < 0) {
		CCE_SYSLOG("daemonize: open(\"/dev/null\" %s", strerror(errno));
		exit(1);
	}
	if ((dup2(nfd, STDIN_FILENO) != STDIN_FILENO) 
	 || (dup2(nfd, STDOUT_FILENO) != STDOUT_FILENO)) {
 		CCE_SYSLOG("daemonize: dup2() %s", strerror(errno));
		exit(1);
	}
	
	/* become session leader */
	setsid();

	umask(027);

	return 0;
}


static void
sighandle(int s)
{
	CCE_SYSLOG("caught signal %d", s);

	/* do we know about this signal? */
	if (s == SIGHUP || s == SIGINT || s == SIGTERM || s == SIGQUIT) {
		/* exit cleanly */
		exithandle(0);
	} else {
		CCE_SYSLOG("sighandle: signal %d caught, but unknown", s);
	}
}

static void
exithandle(int n)
{
	CCE_SYSLOG("exiting main");

	DPRINTF(DBG_CCED, "exithandle: the end is here\n");

#ifdef CCE_ENABLE_MEMDEBUG
	memdebug_dump();
#endif
	exit(n);
}

static void
handle_cmdline(int argc, char *argv[])
{
	int i;
	int err = 0;

	/* save progname and argv globally */
	progname = argv[0];
	progargv = argv;
	argc--; argv++;

	/* handle cmdline */
	while (argc) {
		i = 0;

		if (!strcmp(argv[0], "-v")) {
			version(0);
			exit(0);
		} else if (!strcmp(argv[0], "-vv")) {
			version(1);
			exit(0);
		}

		while (opts[i].opt) {
		  if (!strncmp(argv[0], opts[i].opt, strlen(argv[0]))) {
			if (opts[i].type == OPT_BOOL) {
		  		/* boolean */
  		      	*(int *)(opts[i].flag) = 1;
		      	break;
		    	} else if (opts[i].type == OPT_STR) {
		  		/* string */
		      	argc--;argv++;
				if (argc < 1) {
					err = 1;
					break;
				}
		      	strncpy((char *)(opts[i].flag), argv[0], 127);
		      	break;
		    	} else if (opts[i].type == OPT_ULONG) {
		  		/* unsigned integer */
		      	argc--;argv++;
				if (argc < 1) {
					err = 1;
					break;
				}
				*(ulong *)opts[i].flag = strtoul(argv[0], NULL, 0);
		      	break;
		    	} else if (opts[i].type == OPT_LONG) {
		  		/* integer */
				argc--; argv++;
				if (argc < 1) {
					err = 1;
					break;
				}
				*(long *)opts[i].flag = strtol(argv[0], NULL, 0);
		      	break;
		    	} else {
				err = 1;
				break;
			}
		  }
		  i++;
		}

		if (!opts[i].opt || err) {
			/* option not known */
			usage();
			exit(-1);
		}

		/* next item */
		argc--; argv++;
	}
}

static void 
usage(void)
{
	int i = 0;

	version(0);
	
	fprintf(stderr, "usage: %s [options]\n", progname);
	fprintf(stderr, "  options:\n");
	fprintf(stderr, "    -v     \tdisplay version info and exit\n");
	
	while (opts[i].opt) {
		fprintf(stderr, "    %s\t%s\n", opts[i].opt, opts[i].help);
		i++;
	}
	
	fprintf(stderr, "\n");
}

static void
version(int flag)
{
	fprintf(stderr, IDSTR);
	fprintf(stderr, sun_copyright);
	if (flag) {
		fprintf(stderr, CREDITS);
	}
}

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
