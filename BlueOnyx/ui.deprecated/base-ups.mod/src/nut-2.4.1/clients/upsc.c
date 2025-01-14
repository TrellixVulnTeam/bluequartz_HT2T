/* upsc - simple "client" to test communications 

   Copyright (C) 1999  Russell Kroll <rkroll@exploits.org>

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/

#include "common.h"

#include <netdb.h>
#include <netinet/in.h>
#include <sys/socket.h>

#include "upsclient.h"

static char		*upsname = NULL, *hostname = NULL;
static UPSCONN_t	*ups = NULL;

static void usage(const char *prog)
{
	printf("Network UPS Tools upsc %s\n\n", UPS_VERSION);

	printf("usage: %s -l | -L [<hostname>[:port]]\n", prog);
	printf("       %s <ups> [<variable>]\n", prog);

	printf("\nDemo program to display UPS variables.\n\n");

	printf("First form (lists UPSes):\n");
	printf("  -l         - lists each UPS on <hostname>, one per line.\n");
	printf("  -L         - lists each UPS followed by its description (from ups.conf).\n");
	printf("               Default hostname: localhost\n");

	printf("\nSecond form (lists variables and values):\n");
	printf("  <ups>      - upsd server, <upsname>[@<hostname>[:<port>]] form\n");
	printf("  <variable> - optional, display this variable only.\n");
	printf("               Default: list all variables for <host>\n");
}

static void printvar(const char *var)
{
	int		ret;
	unsigned int	numq, numa;
	const char	*query[4];
	char		**answer;

	/* old-style variable name? */
	if (!strchr(var, '.')) {
		fatalx(EXIT_FAILURE, "Error: old-style variable names are not supported");
	}

	query[0] = "VAR";
	query[1] = upsname;
	query[2] = var;

	numq = 3;

	ret = upscli_get(ups, numq, query, &numa, &answer);

	if (ret < 0) {

		/* new var and old upsd?  try to explain the situation */
		if (upscli_upserror(ups) == UPSCLI_ERR_UNKCOMMAND) {
			fatalx(EXIT_FAILURE, "Error: variable unknown (old upsd detected)");
		}

		fatalx(EXIT_FAILURE, "Error: %s", upscli_strerror(ups));
	}

	if (numa < numq) {
		fatalx(EXIT_FAILURE, "Error: insufficient data (got %d args, need at least %d)", numa, numq);
	}

	printf("%s\n", answer[3]);
}

static void list_vars(void)
{
	int		ret;
	unsigned int	numq, numa;
	const char	*query[4];
	char		**answer;

	query[0] = "VAR";
	query[1] = upsname;
	numq = 2;

	ret = upscli_list_start(ups, numq, query);

	if (ret < 0) {

		/* check for an old upsd */
		if (upscli_upserror(ups) == UPSCLI_ERR_UNKCOMMAND) {
			fatalx(EXIT_FAILURE, "Error: upsd is too old to support this query");
		}

		fatalx(EXIT_FAILURE, "Error: %s", upscli_strerror(ups));
	}

	while (upscli_list_next(ups, numq, query, &numa, &answer) == 1) {

		/* VAR <upsname> <varname> <val> */
		if (numa < 4) {
			fatalx(EXIT_FAILURE, "Error: insufficient data (got %d args, need at least 4)", numa);
		}

		printf("%s: %s\n", answer[2], answer[3]);
	}
}

static void list_upses(int verbose)
{
	int		ret;
	unsigned int	numq, numa;
	const char	*query[4];
	char		**answer;

	query[0] = "UPS";
	numq = 1;

	ret = upscli_list_start(ups, numq, query);
	
	if (ret < 0) {
		/* check for an old upsd */
		if (upscli_upserror(ups) == UPSCLI_ERR_UNKCOMMAND) {
			fatalx(EXIT_FAILURE, "Error: upsd is too old to support this query");
		}

		fatalx(EXIT_FAILURE, "Error: %s", upscli_strerror(ups));
	}

	while (upscli_list_next(ups, numq, query, &numa, &answer) == 1) {

		/* UPS <upsname> <description> */
		if (numa < 3) {
			fatalx(EXIT_FAILURE, "Error: insufficient data (got %d args, need at least 3)", numa);
		}

		if(verbose) {
			printf("%s: %s\n", answer[1], answer[2]);
		} else {
			printf("%s\n", answer[1]);
		}
	}
}

static void clean_exit(void)
{
	if (ups) {
		upscli_disconnect(ups);
	}

	free(upsname);
	free(hostname);
	free(ups);
}

int main(int argc, char **argv)
{
	int	i, port;
	int	varlist = 0, verbose = 0;
	const char	*prog = xbasename(argv[0]);

	while ((i = getopt(argc, argv, "+hlLV")) != -1) {

		switch (i)
		{
		case 'L':
			verbose = 1;
		case 'l':
			varlist = 1;
			break;

		case 'V':
			fatalx(EXIT_SUCCESS, "Network UPS Tools upscmd %s", UPS_VERSION);

		case 'h':
		default:
			usage(prog);
			exit(EXIT_SUCCESS);
		}
	}

	argc -= optind;
	argv += optind;

	/* be a good little client that cleans up after itself */
	atexit(clean_exit);

	if (varlist) {
		if (upscli_splitaddr(argv[0] ? argv[0] : "localhost", &hostname, &port) != 0) {
			fatalx(EXIT_FAILURE, "Error: invalid hostname.\nRequired format: [hostname[:port]]");
		}
	} else {
		if (upscli_splitname(argv[0], &upsname, &hostname, &port) != 0) {
			fatalx(EXIT_FAILURE, "Error: invalid UPS definition.\nRequired format: upsname[@hostname[:port]]");
		}
	}

	ups = xmalloc(sizeof(*ups));

	if (upscli_connect(ups, hostname, port, UPSCLI_CONN_TRYSSL) < 0) {
		fatalx(EXIT_FAILURE, "Error: %s", upscli_strerror(ups));
	}

	if (varlist) {
		list_upses(verbose);
		exit(EXIT_SUCCESS);
	}

	if (argc > 1) {
		printvar(argv[1]);
	} else {
		list_vars();
	}

	exit(EXIT_SUCCESS);
}
