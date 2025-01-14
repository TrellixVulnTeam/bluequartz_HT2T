#include <alloca.h>
#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

/* this will be running setuid root, so be careful! */

void usage(void) {
    fprintf(stderr, "usage: usernetctl <interface-config> <up|down|report>\n");
    exit(1);
}

static char * safeEnviron[] = {
	"PATH=/bin:/sbin:/usr/bin:/usr/sbin",
	"HOME=/root",
	NULL
};

#define FOUND_FALSE -1
#define NOT_FOUND 0
#define FOUND_TRUE 1


int testSafe(char * ifaceConfig) {
    struct stat sb;

    /* these shouldn't be symbolic links -- anal, but that's fine w/ me */
    if (lstat(ifaceConfig, &sb)) {
	fprintf(stderr, "failed to stat %s: %s\n", ifaceConfig, 
		strerror(errno));
	exit(1);
    }

    /* safety checks */
    if (!S_ISREG(sb.st_mode)) {
	fprintf(stderr, "%s is not a normal file\n", ifaceConfig);
	exit(1);
    }

    if (sb.st_uid) {
	fprintf(stderr, "%s should be owned by root\n", ifaceConfig);
	exit(1);
    }
    
    if (sb.st_mode & S_IWOTH) {
	fprintf(stderr, "%s should not be world writeable\n", ifaceConfig);
	exit(1);
    }

    return sb.st_size;
}


int userCtl(char * file) {
    char * contents;
    char * chptr;
    char * end;
    int fd;
    int size;

    size = testSafe(file);

    contents = alloca(size + 2);

    if ((fd = open(file, O_RDONLY)) < 0) {
	fprintf(stderr, "failed to open %s: %s\n", file, strerror(errno));
	exit(1);
    }

    if (read(fd, contents, size) != size) {
	perror("error reading device configuration");
	exit(1);
    }
    close(fd);

    contents[size] = '\n';
    contents[size + 1] = '\0';

    /* each pass parses a single line (until an answer is found), contents
       itself points to the beginning of the current line */
    while (*contents) {
	chptr = contents;
	while (*chptr != '\n') chptr++;
	end = chptr + 1;
	while (chptr > contents && isspace(*chptr)) chptr--;
	*(++chptr) = '\0';

	if (!strncmp(contents, "USERCTL=", 8)) {
	    if (!strcmp(contents+8, "yes")) return FOUND_TRUE;
	    else return FOUND_FALSE;
	}

	contents = end;
    }

    return NOT_FOUND;
}


int main(int argc, char ** argv) {
    char * ifaceConfig;
    char * chptr;
    char * cmd;
    int report = 0;

    if (argc != 3) usage();

    if (!strcmp(argv[2], "up")) {
	cmd = "./ifup";
    } else if (!strcmp(argv[2], "down")) {
	cmd = "./ifdown";
    } else if (!strcmp(argv[2], "report")) {
	report = 1;
    } else {
	usage();
    }

    if (chdir("/etc/sysconfig/network-scripts")) {
	fprintf(stderr, "error switching to /etc/sysconfig/network-scripts: "
		"%s\n", strerror(errno));
	exit(1);
    }

    /* force the interface configuration to be in the current directory */
    chptr = ifaceConfig = argv[1];
    while (*chptr) {
	if (*chptr == '/')
	    ifaceConfig = chptr + 1;
	chptr++;
    }

    /* automatically prepend "ifcfg-" if it is not specified */
    if (strncmp(ifaceConfig, "ifcfg-", 6)) {
	char *temp;

	temp = (char *) alloca(strlen(ifaceConfig) + 7);
	strcpy(temp, "ifcfg-");
	/* strcat is safe because we got the length from strlen */
	strcat(temp, ifaceConfig);
	ifaceConfig = temp;
    }
    

    switch (userCtl(ifaceConfig)) {
	char *dash;

	case NOT_FOUND:
	    /* a `-' will be found at least in "ifcfg-" */
	    dash = strrchr(ifaceConfig, '-');
	    if (*(dash-1) != 'g') {
		/* This was a clone configuration; ask the parent config */
		*dash = '\0';
		if (userCtl(ifaceConfig) == FOUND_TRUE)
		    /* exit the switch; users are allowed to control */
		    break;
	    }
	    /* else fall through */
	case FOUND_FALSE:
	    if (! report)
	        fprintf(stderr,
			"Users are not allowed to control this interface.\n");
	    exit(1);
	    break;
    }

    /* looks good to me -- let's go for it if we are changing the interface,
     * report good status to the user otherwise */

    if (report)
	exit(0);

    /* pppd wants the real uid to be the same as the effective (god only
       knows why when it works fine setuid out of the box) */
    setuid(geteuid());

    execle(cmd, cmd, ifaceConfig, NULL, safeEnviron);
    fprintf(stderr, "exec of %s failed: %s\n", cmd, strerror(errno));
    
    exit(1);
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
