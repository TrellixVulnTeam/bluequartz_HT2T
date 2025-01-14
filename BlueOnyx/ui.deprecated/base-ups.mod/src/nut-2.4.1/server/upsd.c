/* upsd.c - watches ups state files and answers queries 

   Copyright (C)
	1999	Russell Kroll <rkroll@exploits.org>
	2008	Arjen de Korte <adkorte-guest@alioth.debian.org>

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

#include "upsd.h"
#include "upstype.h"
#include "conf.h"

#include "netcmds.h"
#include "upsconf.h"

#include <sys/un.h>
#include <sys/socket.h>
#include <netdb.h>
#include <poll.h>

#include "user.h"
#include "ctype.h"
#include "stype.h"
#include "ssl.h"
#include "sstate.h"
#include "desc.h"
#include "neterr.h"

#ifdef HAVE_WRAP
#include <tcpd.h>
int	allow_severity = LOG_INFO;
int	deny_severity = LOG_WARNING;
#endif	/* HAVE_WRAP */

	/* externally-visible settings and pointers */

	upstype_t	*firstups = NULL;

	/* default 15 seconds before data is marked stale */
	int	maxage = 15;

	/* default FD_SETSIZE connections allowed */
	int	maxconn = FD_SETSIZE;

	/* preloaded to STATEPATH in main, can be overridden via upsd.conf */
	char	*statepath = NULL;

	/* preloaded to DATADIR in main, can be overridden via upsd.conf */
	char	*datapath = NULL;

	/* everything else */
	const char	*progname;

static ctype_t	*firstclient = NULL;
/* static ctype_t	*lastclient = NULL; */

	/* default is to listen on all local interfaces */
static stype_t	*firstaddr = NULL;

#ifdef	HAVE_IPV6
static int 	opt_af = AF_UNSPEC;
#endif

typedef enum {
	DRIVER = 1,
	CLIENT,
	SERVER
} handler_type_t;

typedef struct {
	handler_type_t	type;
	void		*data;
} handler_t;

	/* pollfd  */
static struct pollfd	*fds = NULL;
static handler_t	*handler = NULL;

	/* pid file */
static char	pidfn[SMALLBUF];

	/* set by signal handlers */
static int	reload_flag = 0, exit_flag = 0;

#ifdef	HAVE_IPV6
static const char *inet_ntopW (struct sockaddr_storage *s)
{
	static char str[40];

	switch (s->ss_family)
	{
	case AF_INET:
		return inet_ntop (AF_INET, &(((struct sockaddr_in *)s)->sin_addr), str, 16);
	case AF_INET6:
		return inet_ntop (AF_INET6, &(((struct sockaddr_in6 *)s)->sin6_addr), str, 40);
	default:
		errno = EAFNOSUPPORT;
		return NULL;
	}
}
#endif

/* return a pointer to the named ups if possible */
upstype_t *get_ups_ptr(const char *name)
{
	upstype_t	*tmp;

	if (!name) {
		return NULL;
	}

	for (tmp = firstups; tmp; tmp = tmp->next) {
		if (!strcasecmp(tmp->name, name)) {
			return tmp;
		}
	}

	return NULL;
}

/* mark the data stale if this is new, otherwise cleanup any remaining junk */
static void ups_data_stale(upstype_t *ups)
{
	/* don't complain again if it's already known to be stale */
	if (ups->stale == 1) {
		return;
	}

	ups->stale = 1;

	upslogx(LOG_NOTICE, "Data for UPS [%s] is stale - check driver", ups->name);
}

/* mark the data ok if this is new, otherwise do nothing */
static void ups_data_ok(upstype_t *ups)
{
	if (ups->stale == 0) {
		return;
	}

	ups->stale = 0;

	upslogx(LOG_NOTICE, "UPS [%s] data is no longer stale", ups->name);
}

/* add another listening address */
void listen_add(const char *addr, const char *port)
{
	stype_t	*server;

	/* don't change listening addresses on reload */
	if (reload_flag) {
		return;
	}

	/* grab some memory and add the info */
	server = xcalloc(1, sizeof(*server));
	server->addr = xstrdup(addr);
	server->port = xstrdup(port);
	server->sock_fd = -1;
	server->next = firstaddr;

	firstaddr = server;

	upsdebugx(3, "listen_add: added %s:%s", server->addr, server->port);
}

/* create a listening socket for tcp connections */
static void setuptcp(stype_t *server)
{
#ifndef	HAVE_IPV6
	struct hostent		*host;
	struct sockaddr_in	sockin;
	int	res, one = 1;

	host = gethostbyname(server->addr);

	if (!host) {
		struct  in_addr	listenaddr;

		if (!inet_aton(server->addr, &listenaddr)) {
			fatal_with_errno(EXIT_FAILURE, "inet_aton");
		}

		host = gethostbyaddr(&listenaddr, sizeof(listenaddr), AF_INET);

		if (!host) {
			fatal_with_errno(EXIT_FAILURE, "gethostbyaddr");
		}
	}

	if ((server->sock_fd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
		fatal_with_errno(EXIT_FAILURE, "socket");
	}

	res = setsockopt(server->sock_fd, SOL_SOCKET, SO_REUSEADDR, (void *) &one, sizeof(one));

	if (res != 0) {
		fatal_with_errno(EXIT_FAILURE, "setsockopt(SO_REUSEADDR)");
	}

	memset(&sockin, '\0', sizeof(sockin));
	sockin.sin_family = AF_INET;
	sockin.sin_port = htons(atoi(server->port));

	memcpy(&sockin.sin_addr, host->h_addr, host->h_length);

	if (bind(server->sock_fd, (struct sockaddr *) &sockin, sizeof(sockin)) == -1) {
		fatal_with_errno(EXIT_FAILURE, "Can't bind TCP port %s", server->port);
	}

	if ((res = fcntl(server->sock_fd, F_GETFL, 0)) == -1) {
		fatal_with_errno(EXIT_FAILURE, "fcntl(get)");
	}

	if (fcntl(server->sock_fd, F_SETFL, res | O_NDELAY) == -1) {
		fatal_with_errno(EXIT_FAILURE, "fcntl(set)");
	}

	if (listen(server->sock_fd, 16)) {
		fatal_with_errno(EXIT_FAILURE, "listen");
	}
#else
	struct addrinfo		hints, *res, *ai;
	int	v = 0, one = 1;

	upsdebugx(3, "setuptcp: try to bind to %s port %s", server->addr, server->port);

	memset(&hints, 0, sizeof(hints));
	hints.ai_flags		= AI_PASSIVE;
	hints.ai_family		= opt_af;
	hints.ai_socktype	= SOCK_STREAM;
	hints.ai_protocol	= IPPROTO_TCP;

	if ((v = getaddrinfo(server->addr, server->port, &hints, &res)) != 0) {
		if (v == EAI_SYSTEM) {
			fatal_with_errno(EXIT_FAILURE, "getaddrinfo");
		}

		fatalx(EXIT_FAILURE, "getaddrinfo: %s", gai_strerror(v));
	}

	for (ai = res; ai; ai = ai->ai_next) {
		int sock_fd;

		if ((sock_fd = socket(ai->ai_family, ai->ai_socktype, ai->ai_protocol)) < 0) {
			upsdebug_with_errno(3, "setuptcp: socket");
			continue;
		}
		
		if (setsockopt(sock_fd, SOL_SOCKET, SO_REUSEADDR, (void *)&one, sizeof(one)) != 0) {
			fatal_with_errno(EXIT_FAILURE, "setuptcp: setsockopt");
		}

		if (bind(sock_fd, ai->ai_addr, ai->ai_addrlen) < 0) {
			upsdebug_with_errno(3, "setuptcp: bind");
			close(sock_fd);
			continue;
		}

		if ((v = fcntl(sock_fd, F_GETFL, 0)) == -1) {
			fatal_with_errno(EXIT_FAILURE, "setuptcp: fcntl(get)");
		}

		if (fcntl(sock_fd, F_SETFL, v | O_NDELAY) == -1) {
			fatal_with_errno(EXIT_FAILURE, "setuptcp: fcntl(set)");
		}

		if (listen(sock_fd, 16) < 0) {
			upsdebug_with_errno(3, "setuptcp: listen");
			close(sock_fd);
			continue;
		}

		server->sock_fd = sock_fd;
		break;
	}

	freeaddrinfo(res);
#endif

	/* don't fail silently */
	if (server->sock_fd < 0) {
		fatalx(EXIT_FAILURE, "not listening on %s port %s", server->addr, server->port);
	} else {
		upslogx(LOG_INFO, "listening on %s port %s", server->addr, server->port);
	}

	return;
}

/* decrement the login counter for this ups */
static void declogins(const char *upsname)
{
	upstype_t	*ups;

	ups = get_ups_ptr(upsname);

	if (!ups) {
		upslogx(LOG_INFO, "Tried to decrement invalid ups name (%s)", upsname);
		return;
	}

	ups->numlogins--;

	if (ups->numlogins < 0) {
		upslogx(LOG_ERR, "Programming error: UPS [%s] has numlogins=%d", ups->name, ups->numlogins);
	}
}

/* disconnect a client connection and free all related memory */
static void client_disconnect(ctype_t *client)
{
	if (!client) {
		return;
	}

	upsdebugx(2, "Disconnect from %s", client->addr);

	shutdown(client->sock_fd, 2);
	close(client->sock_fd);

	if (client->loginups) {
		declogins(client->loginups);
	}

	ssl_finish(client);

	pconf_finish(&client->ctx);

	if (client->prev) {
		client->prev->next = client->next;
	} else {
		/* deleting first entry */
		firstclient = client->next;
	}

	if (client->next) {
		client->next->prev = client->prev;
	} else {
		/* deleting last entry */
		/* lastclient = client->prev; */
	}

	free(client->addr);
	free(client->loginups);
	free(client->password);
	free(client->username);
	free(client);

	return;
}

/* send the buffer <sendbuf> of length <sendlen> to host <dest> */
int sendback(ctype_t *client, const char *fmt, ...)
{
	int	res, len;
	char ans[NUT_NET_ANSWER_MAX+1];
	va_list ap;

	if (!client) {
		return 0;
	}

	va_start(ap, fmt);
	vsnprintf(ans, sizeof(ans), fmt, ap);
	va_end(ap);

	len = strlen(ans);

	if (client->ssl) {
		res = ssl_write(client, ans, len);
	} else {
		res = write(client->sock_fd, ans, len);
	}

	upsdebugx(2, "write: [destfd=%d] [len=%d] [%s]", client->sock_fd, len, rtrim(ans, '\n'));

	if (len != res) {
		upslog_with_errno(LOG_NOTICE, "write() failed for %s", client->addr);
		client->last_heard = 0;
		return 0;	/* failed */
	}

	return 1;	/* OK */
}

/* just a simple wrapper for now */
int send_err(ctype_t *client, const char *errtype)
{
	if (!client) {
		return -1;
	}

	upsdebugx(4, "Sending error [%s] to client %s", errtype, client->addr);

	return sendback(client, "ERR %s\n", errtype);
}

/* disconnect anyone logged into this UPS */
void kick_login_clients(const char *upsname)
{
	ctype_t	*client, *cnext;

	for (client = firstclient; client; client = cnext) {

		cnext = client->next;

		/* if it's not logged in, don't check it */
		if (!client->loginups) {
			continue;
		}

		if (!strcmp(client->loginups, upsname)) {
			upslogx(LOG_INFO, "Kicking client %s (was on UPS [%s])\n", client->addr, upsname);
			client_disconnect(client);
		}
	}
}

/* make sure a UPS is sane - connected, with fresh data */
int ups_available(const upstype_t *ups, ctype_t *client)
{
	if (ups->sock_fd < 0) {
		send_err(client, NUT_ERR_DRIVER_NOT_CONNECTED);
		return 0;
	}

	if (ups->stale) {
		send_err(client, NUT_ERR_DATA_STALE);
		return 0;
	}

	/* must be OK */
	return 1;
}

/* check flags and access for an incoming command from the network */
static void check_command(int cmdnum, ctype_t *client, int numarg, 
	const char **arg)
{
	if (netcmds[cmdnum].flags & FLAG_USER) {
#ifdef HAVE_WRAP
		struct request_info	req;
#endif	/* HAVE_WRAP */

		if (!client->username) {
			send_err(client, NUT_ERR_USERNAME_REQUIRED);
			return;
		}

		if (!client->password) {
			send_err(client, NUT_ERR_PASSWORD_REQUIRED);
			return;
		}

#ifdef HAVE_WRAP
		request_init(&req, RQ_DAEMON, progname, RQ_CLIENT_ADDR, client->addr, RQ_USER, client->username, 0);

		if (!hosts_access(&req)) {
			/* tcp-wrappers says access should be denied */
			send_err(client, NUT_ERR_ACCESS_DENIED);
			return;
		}
#endif	/* HAVE_WRAP */
	}

	/* looks good - call the command */
	netcmds[cmdnum].func(client, numarg - 1, &arg[1]);
}

/* parse requests from the network */
static void parse_net(ctype_t *client)
{
	int	i;

	/* shouldn't happen */
	if (client->ctx.numargs < 1) {
		send_err(client, NUT_ERR_UNKNOWN_COMMAND);
		return;
	}

	for (i = 0; netcmds[i].name; i++) {
		if (!strcasecmp(netcmds[i].name, client->ctx.arglist[0])) {
			check_command(i, client, client->ctx.numargs, (const char **) client->ctx.arglist);
			return;
		}
	}

	/* fallthrough = not matched by any entry in netcmds */

	send_err(client, NUT_ERR_UNKNOWN_COMMAND);
}

/* answer incoming tcp connections */
static void client_connect(stype_t *server)
{
#ifndef	HAVE_IPV6
	struct	sockaddr_in csock;
#else
	struct	sockaddr_storage csock;
#endif
	socklen_t	clen;
	int		fd;
	ctype_t		*client;

	clen = sizeof(csock);
	fd = accept(server->sock_fd, (struct sockaddr *) &csock, &clen);

	if (fd < 0) {
		return;
	}

	client = xcalloc(1, sizeof(*client));

	client->sock_fd = fd;

	time(&client->last_heard);

#ifndef	HAVE_IPV6
	client->addr = xstrdup(inet_ntoa(csock.sin_addr));
#else
	client->addr = xstrdup(inet_ntopW(&csock));
#endif

	pconf_init(&client->ctx, NULL);

	if (firstclient) {
		firstclient->prev = client;
		client->next = firstclient;
	}

	firstclient = client;

/*
	if (lastclient) {
		client->prev = lastclient;
		lastclient->next = client;
	}

	lastclient = client;
 */
	upsdebugx(2, "Connect from %s", client->addr);
}

/* read tcp messages and handle them */
static void client_readline(ctype_t *client)
{
	char	buf[SMALLBUF];
	int	i, ret;

	if (client->ssl) {
		ret = ssl_read(client, buf, sizeof(buf));
	} else {
		ret = read(client->sock_fd, buf, sizeof(buf));
	}

	if (ret < 0) {
		upsdebug_with_errno(2, "Disconnect %s (read failure)", client->addr);
		client_disconnect(client);
		return;
	}

	if (ret == 0) {
		upsdebugx(2, "Disconnect %s (no data available)", client->addr);
		client_disconnect(client);
		return;
	}

	/* fragment handling code */
	for (i = 0; i < ret; i++) {

		/* add to the receive queue one by one */
		switch (pconf_char(&client->ctx, buf[i]))
		{
		case 1:
			time(&client->last_heard);	/* command received */
			parse_net(client);
			continue;

		case 0:
			continue;	/* haven't gotten a line yet */

		default:
			/* parse error */
			upslogx(LOG_NOTICE, "Parse error on sock: %s", client->ctx.errmsg);
			return;
		}
	}

	return;
}

void server_load(void)
{
	stype_t	*server;

	/* default behaviour if no LISTEN addres has been specified */
	if (!firstaddr) {
#ifdef	HAVE_IPV6
		if (opt_af != AF_INET) {
			listen_add("::1", string_const(PORT));
		}

		if (opt_af != AF_INET6) {
			listen_add("127.0.0.1", string_const(PORT));
		}
#else
		listen_add("127.0.0.1", string_const(PORT));
#endif
	}

	for (server = firstaddr; server; server = server->next) {
		setuptcp(server);
	}
}

void server_free(void)
{
	stype_t	*server, *snext;

	/* cleanup server fds */
	for (server = firstaddr; server; server = snext) {
		snext = server->next;

		if (server->sock_fd != -1) {
			close(server->sock_fd);
		}

		free(server->addr);
		free(server->port);
		free(server);
	}

	firstaddr = NULL;
}

static void client_free(void)
{
	ctype_t		*client, *cnext;

	/* cleanup client fds */
	for (client = firstclient; client; client = cnext) {
		cnext = client->next;
		client_disconnect(client);
	}
}

void driver_free(void)
{
	upstype_t	*ups, *unext;

	for (ups = firstups; ups; ups = unext) {
		unext = ups->next;

		if (ups->sock_fd != -1) {
			close(ups->sock_fd);
		}

		sstate_infofree(ups);
		sstate_cmdfree(ups);

		pconf_finish(&ups->sock_ctx);

		free(ups->fn);
		free(ups->name);
		free(ups->desc);
		free(ups);
	}
}

static void upsd_cleanup(void)
{
	if (strlen(pidfn) > 0) {
		unlink(pidfn);
	}

	/* dump everything */

	user_flush();
	desc_free();
	
	server_free();
	client_free();
	driver_free();

	free(statepath);
	free(datapath);
	free(certfile);

	free(fds);
	free(handler);
}

void poll_reload(void)
{
	int	ret;

	ret = sysconf(_SC_OPEN_MAX);

	if (ret < maxconn) {
		fatalx(EXIT_FAILURE, "Maximum number of connections limited to %d [requested %d]", ret, maxconn);
	}

	fds = xrealloc(fds, maxconn * sizeof(*fds));
	handler = xrealloc(handler, maxconn * sizeof(*handler));
}

/* service requests and check on new data */
static void mainloop(void)
{
	int	i, ret, nfds = 0;

	upstype_t	*ups;
	ctype_t		*client, *cnext;
	stype_t		*server;
	time_t	now;

	time(&now);

	if (reload_flag) {
		conf_reload();
		poll_reload();
		reload_flag = 0;
	}

	/* scan through driver sockets */
	for (ups = firstups; ups && (nfds < maxconn); ups = ups->next) {

		/* see if we need to (re)connect to the socket */
		if (ups->sock_fd < 0) {
			ups->sock_fd = sstate_connect(ups);
			continue;
		}

		/* throw some warnings if it's not feeding us data any more */
		if (sstate_dead(ups, maxage)) {
			ups_data_stale(ups);
		} else {
			ups_data_ok(ups);
		}

		fds[nfds].fd = ups->sock_fd;
		fds[nfds].events = POLLIN;

		handler[nfds].type = DRIVER;
		handler[nfds].data = ups;

		nfds++;
	}

	/* scan through client sockets */
	for (client = firstclient; client; client = cnext) {

		cnext = client->next;

		if (difftime(now, client->last_heard) > 60) {
			/* shed clients after 1 minute of inactivity */
			client_disconnect(client);
			continue;
		}

		if (nfds >= maxconn) {
			/* ignore clients that we are unable to handle */
			continue;
		}

		fds[nfds].fd = client->sock_fd;
		fds[nfds].events = POLLIN;

		handler[nfds].type = CLIENT;
		handler[nfds].data = client;

		nfds++;
	}

	/* scan through server sockets */
	for (server = firstaddr; server && (nfds < maxconn); server = server->next) {

		if (server->sock_fd < 0) {
			continue;
		}

		fds[nfds].fd = server->sock_fd;
		fds[nfds].events = POLLIN;

		handler[nfds].type = SERVER;
		handler[nfds].data = server;

		nfds++;
	}

	upsdebugx(2, "%s: polling %d filedescriptors", __func__, nfds);

	ret = poll(fds, nfds, 2000);

	if (ret == 0) {
		upsdebugx(2, "%s: no data available", __func__);
		return;
	}

	if (ret < 0) {
		upslog_with_errno(LOG_ERR, "%s", __func__);
		return;
	}

	for (i = 0; i < nfds; i++) {

		if (fds[i].revents & (POLLHUP|POLLERR|POLLNVAL)) {

			switch(handler[i].type)
			{
			case DRIVER:
				sstate_disconnect((upstype_t *)handler[i].data);
				break;
			case CLIENT:
				client_disconnect((ctype_t *)handler[i].data);
				break;
			case SERVER:
				upsdebugx(2, "%s: server disconnected", __func__);
				break;
			default:
				upsdebugx(2, "%s: <unknown> disconnected", __func__);
				break;
			}

			continue;
		}

		if (fds[i].revents & POLLIN) {

			switch(handler[i].type)
			{
			case DRIVER:
				sstate_readline((upstype_t *)handler[i].data);
				break;
			case CLIENT:
				client_readline((ctype_t *)handler[i].data);
				break;
			case SERVER:
				client_connect((stype_t *)handler[i].data);
				break;
			default:
				upsdebugx(2, "%s: <unknown> has data available", __func__);
				break;
			}

			continue;
		}
	}
}

static void help(const char *progname) 
{
	printf("Network server for UPS data.\n\n");
	printf("usage: %s [OPTIONS]\n", progname);

	printf("\n");
	printf("  -c <command>	send <command> via signal to background process\n");
	printf("		commands:\n");
	printf("		 - reload: reread configuration files\n");
	printf("		 - stop: stop process and exit\n");
	printf("  -D		raise debugging level\n");
	printf("  -h		display this help\n");
	printf("  -r <dir>	chroots to <dir>\n");
	printf("  -u <user>	switch to <user> (if started as root)\n");
	printf("  -V		display the version of this software\n");
#ifdef	HAVE_IPV6
	printf("  -4		IPv4 only\n");
	printf("  -6		IPv6 only\n");
#endif

	exit(EXIT_SUCCESS);
}

static void set_reload_flag(int sig)
{
	reload_flag = 1;
}

static void set_exit_flag(int sig)
{
	exit_flag = sig;
}

static void setup_signals(void)
{
	struct sigaction	sa;

	sigemptyset(&sa.sa_mask);
	sigaddset(&sa.sa_mask, SIGHUP);
	sa.sa_flags = 0;

	/* basic signal setup to ignore SIGPIPE */
	sa.sa_handler = SIG_IGN;
	sigaction(SIGPIPE, &sa, NULL);

	/* handle shutdown signals */
	sa.sa_handler = set_exit_flag;
	sigaction(SIGINT, &sa, NULL);
	sigaction(SIGQUIT, &sa, NULL);
	sigaction(SIGTERM, &sa, NULL);

	/* handle reloading */
	sa.sa_handler = set_reload_flag;
	sigaction(SIGHUP, &sa, NULL);
}

void check_perms(const char *fn)
{
	int	ret;
	struct stat	st;

	ret = stat(fn, &st);

	if (ret != 0) {
		fatal_with_errno(EXIT_FAILURE, "stat %s", fn);
	}

	/* include the x bit here in case we check a directory */
	if (st.st_mode & (S_IROTH | S_IXOTH)) {
		upslogx(LOG_WARNING, "%s is world readable", fn);
	}
}

int main(int argc, char **argv)
{
	int	i, cmd = 0;
	char	*chroot_path = NULL;
	const char	*user = NULL;
	struct passwd	*new_uid = NULL;

	progname = xbasename(argv[0]);

	/* pick up a default from configure --with-user */
	user = RUN_AS_USER;

	/* yes, xstrdup - the conf handlers call free on this later */
	statepath = xstrdup(dflt_statepath());
	datapath = xstrdup(DATADIR);

	/* set up some things for later */
	snprintf(pidfn, sizeof(pidfn), "%s/upsd.pid", altpidpath());

	printf("Network UPS Tools upsd %s\n", UPS_VERSION);

	while ((i = getopt(argc, argv, "+h46p:r:i:fu:Vc:D")) != -1) {
		switch (i) {
			case 'h':
				help(progname);
				break;
			case 'p':
			case 'i':
				fatalx(EXIT_FAILURE, "Specifying a listening addresses with '-i <address>' and '-p <port>'\n"
					"is deprecated. Use 'LISTEN <address> [<port>]' in 'upsd.conf' instead.\n"
					"See 'man 8 upsd.conf' for more information.");
			case 'r':
				chroot_path = optarg;
				break;
			case 'u':
				user = optarg;
				break;
			case 'V':

				/* do nothing - we already printed the banner */
				exit(EXIT_SUCCESS);

			case 'c':
				if (!strncmp(optarg, "reload", strlen(optarg)))
					cmd = SIGCMD_RELOAD;
				if (!strncmp(optarg, "stop", strlen(optarg)))
					cmd = SIGCMD_STOP;

				/* bad command given */
				if (cmd == 0)
					help(progname);
				break;

			case 'D':
				nut_debug_level++;
				break;

#ifdef	HAVE_IPV6
		  case '4':
				opt_af = AF_INET;
				break;

		  case '6':
				opt_af = AF_INET6;
				break;
#endif

			default:
				help(progname);
				break;
		}
	}

	if (cmd) {
		sendsignalfn(pidfn, cmd);
		exit(EXIT_SUCCESS);
	}

	argc -= optind;
	argv += optind;

	if (argc != 0) {
		help(progname);
	}

	atexit(upsd_cleanup);

	setup_signals();

	open_syslog("upsd");

	/* send logging to the syslog pre-background for later use */
	syslogbit_set();

	/* do this here, since getpwnam() might not work in the chroot */
	new_uid = get_user_pwent(user);

	if (chroot_path) {
		chroot_start(chroot_path);
	}

	/* handle upsd.conf */
	load_upsdconf(0);	/* 0 = initial */

	/* start server */
	server_load();

	become_user(new_uid);

	if (chdir(statepath)) {
		fatal_with_errno(EXIT_FAILURE, "Can't chdir to %s", statepath);
	}

	/* check statepath perms */
	check_perms(statepath);

	/* handle ups.conf */
	read_upsconf();
	upsconf_add(0);		/* 0 = initial */
	poll_reload();

	if (num_ups == 0) {
		fatalx(EXIT_FAILURE, "Fatal error: at least one UPS must be defined in ups.conf");
	}

	ssl_init();

	/* try to bring in the var/cmd descriptions */
	desc_load();

	/* handle upsd.users */
	user_load();

	if (!nut_debug_level) {
		background();
		writepid(pidfn);
	} else {
		memset(pidfn, 0, sizeof(pidfn));
	}

	while (!exit_flag) {
		mainloop();
	}

	upslogx(LOG_INFO, "Signal %d: exiting", exit_flag);
	return EXIT_SUCCESS;
}
