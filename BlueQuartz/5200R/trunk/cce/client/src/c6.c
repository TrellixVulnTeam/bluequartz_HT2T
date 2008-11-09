/* $Id: c6.c 259 2004-01-03 06:28:40Z shibuya $ */
/* Copyright 2001 Sun Microsystems, Inc.  All rights reserved. */

#include <cce_common.h>
#include <stdlib.h>
#include <string.h>
/* So we can set the socket to non-blocking */
#include <fcntl.h>

#include <sys/poll.h>
#include <glib.h>

#include <cce_scalar.h>
/* We get the global cscp_cmd_table var from here.. */
#include <cscp_cmd_table.h>
/* Our ud_connect calls from here.. */
#include <ud_socket.h>
/* Our definition for commands come from here */
#include <cscp.h>
/* Our string representation of the defines come from here */
#include <cscp_cmd_table.h>

#include <c6.h>

/**
 * CCE Connection
 *
 * This object is created to hold the connection, handle tear up and tear
 * down, authentication is included in the tear up state.
 *
 * All operations to do with actual communication with CCE will go through
 * here.
 */
struct cscp_conn_struct
{
    int version[2];		/* Major and minor protocol version numbers */
    int in_fd;
    int out_fd;
    cscp_resp_t *resp;		/* The last acheived response */
    int txn;			/* Current transaction number */
    char *buf;			/* Fractional data of a line from the last 
      	      	      	      	   poll yet to be parsed */
    /* To cache things like find and list results we use these lists */
};

/**
 * CSCP Command
 *
 * This is a struct form of a CSCP command. Bassically just the command
 * type and a list of args.
 *
 */

struct cscp_cmnd_struct
{
    int cmnd;
    GString *args;
};

/**
 *
 * CSCP Line
 *
 * This is just a single line returned by the CCE. A numerical code
 * and a linked list of following data.
 *
 * Args is a linked list of strings generated by splitting on spaces all the
 * argument to this line.
 *
 */
struct cscp_line_struct
{
    int code;
    GSList *args;
};

/**
 *
 * CCE Response
 *
 * A final boolean result for convenience.
 * A linked list of all messages
 *
 *
 */
struct cscp_resp_struct
{
    int result;			/* True for success, false for failure */
    GSList *messages;		/* Linked list of all messages */
    GSList *curr;		/* Pointer for nextline functions */
    cscp_line_t *final;		/* Final success or failure line ((2|4)???) */
};

/* Private function declerations */
#ifdef DEBUG
static char *printAllLines (GSList * list);
#endif

static void free_whole_g_slist (GSList * list);
static void free_whole_g_slist_lines (GSList * list);
static char *cscp_cmnd2str (int cmnd);

static GSList *cscp_string_to_glist_scalars (char *in_line);

/*
 * Connection Functions
 */

cscp_conn_t *
cscp_conn_new ()
{
    cscp_conn_t *conn;
    conn = (cscp_conn_t *) malloc (sizeof (cscp_conn_t));

    if (!conn) {
	return NULL;
    }

    /* Holder for the last received response */
    conn->resp = NULL;
    /* Buffer for unprocessed data */
    conn->buf = NULL;

    /* invalid file descriptors */
    conn->in_fd = -1;
    conn->out_fd = -1;

    return conn;
}

int
cscp_conn_connect (cscp_conn_t * conn, char *path)
{
    if (!conn)
	return 0;
    conn->in_fd = conn->out_fd = ud_connect (path);
    if (conn->in_fd < 0) {
	return 0;
    } else {
	return 1;
    }
}

int
cscp_conn_connect_stdin (cscp_conn_t * conn)
{
    conn->in_fd = STDIN_FILENO;
    conn->out_fd = STDOUT_FILENO;
    return 1;
}

void
cscp_conn_destroy (cscp_conn_t * conn)
{
    if (conn->resp) {
	cscp_resp_destroy (conn->resp);
    }
    free (conn->buf);

    if (conn->in_fd >= 0)
	close (conn->in_fd);
    if (conn->out_fd >= 0)
	close (conn->out_fd);
    free (conn);
}

/* FIXME: This function should be taken out and shot. */
int
cscp_conn_poll (cscp_conn_t * conn)
{
    cscp_line_t *line;

    GString *line_buf;
    char buf[17];

    int end_i;
    int cread;
    int new_data = 0;

    struct pollfd ufds;

    /* Wait for data to come in over the line */
    ufds.fd = conn->in_fd;
    ufds.events = POLLIN | POLLERR | POLLHUP | POLLNVAL;
    if (poll (&ufds, 1, 1000) < 1) {
	return 0;
    }

    if (!conn->resp) {
	conn->resp = cscp_resp_new ();
    }

    /* Set it up for non-bocking IO so we don't hang here */
    fcntl (conn->in_fd, F_SETFL, O_NONBLOCK);

    /* Start off the buffer with anything we have left over form last
     * time */
    if (conn->buf) {
	line_buf = g_string_new (conn->buf);
	free (conn->buf);
    } else {
	line_buf = g_string_new ("");
    }
    while ((cread = read (conn->in_fd, buf, 16)) > 0) {
	buf[cread] = '\0';
	g_string_append (line_buf, buf);
    }
    
    /* While there are newlines in the input */
    while (strchr (line_buf->str, '\n')) {
	char *line_str;

	/* Get the index of the next newline */
	end_i = line_buf->len - strlen (strchr (line_buf->str, '\n'));
	line_str = (char *) malloc (end_i + 1);

	/* Should copy everything up to but not including the newline */
	strncpy (line_str, line_buf->str, end_i);
	/* NULL terminate it as it will never be */
	line_str[end_i] = '\0';

	/* Now update the line_buf to just past the end of line */
	g_string_erase (line_buf, 0, end_i + 1);

	line = cscp_line_from_string (line_str);
	if (line) {
	    cscp_resp_add_line (conn->resp, line);
	    new_data = 1;
	    if (cscp_conn_is_finished (conn)) {
		free (line_str);
		break;
	    }
	} else {
	    CCE_SYSLOG("Error: Invalid line fed to poller %s", line_str);
	    free (line_str);
	    line = cscp_line_from_string ("401 FAIL\n");
	    cscp_resp_add_line (conn->resp, line);
	    new_data = 1;
	    break;
	}
	free (line_str);
    }

    /* Fill our buffer if there were any partial commands in there */
    if (line_buf->len) {
	conn->buf = strdup (line_buf->str);
    } else {
	conn->buf = NULL;
    }
    g_string_free (line_buf, 1);

    // handle the closing of the socket by appending termination to
    // the response:
    if (cread == 0) {
	// something bad happened.  let's try to be graceful.
	line = cscp_line_from_string("401 FAIL");
	cscp_resp_add_line(conn->resp, line);
    } 

    return new_data;
}

int
cscp_conn_is_finished (cscp_conn_t * conn)
{
    /* Jeez, absolutely nothing yet.. */
    if (!conn->resp) {
	return 0;
    } else {
	return cscp_resp_is_finished (conn->resp);
    }
}

int
cscp_conn_do_nowait (cscp_conn_t * conn, cscp_cmnd_t * cmnd)
{
    char *cmnd_string;
    int length;
    int ret;
    cmnd_string = cscp_cmnd_serialise (cmnd);
    length = strlen (cmnd_string);
    ret = write (conn->out_fd, cmnd_string, length);
    free (cmnd_string);
    return (ret == length);
}

int
cscp_conn_do (cscp_conn_t * conn, cscp_cmnd_t * cmnd)
{
    if (conn->resp) {
	cscp_conn_clear (conn);
    }

    /* We need a new response object for this */
    conn->resp = cscp_resp_new ();

    if (!cscp_conn_do_nowait (conn, cmnd)) {
	return 0;
    }

    /* FIXME: Need some kind of timeout here.. */
    while (!cscp_conn_is_finished (conn)) {
	cscp_conn_poll (conn);
    }

    return 1;
}

void
cscp_conn_clear (cscp_conn_t * conn)
{
    cscp_resp_destroy (conn->resp);
    conn->resp = NULL;
}

cscp_resp_t *
cscp_conn_last_resp (cscp_conn_t * conn)
{
    return conn->resp;
}

/*
 * Line methods
 */

cscp_line_t *
cscp_line_new ()
{
    cscp_line_t *line;
    line = (cscp_line_t *) malloc (sizeof (cscp_line_t));
    line->args = NULL;
    return line;
}

void
cscp_line_destroy (cscp_line_t * line)
{
    free_whole_g_slist (line->args);
    free (line);
}

cscp_line_t *
cscp_line_from_string (char *in_line)
{
    cscp_line_t *line;

    line = cscp_line_new ();

    line->code = atoi (in_line);
    if (line->code < 1 || line->code > 499) {
	CCE_SYSLOG("Invalid code %d while parsing line %s", line->code,
		 in_line);
	cscp_line_destroy (line);
	return 0;
    }

    if (strlen (in_line) < C6_CODE_LENGTH) {
	/* A line without any content ? */
	return line;
    }
    line->args = cscp_string_to_glist_scalars (in_line + C6_CODE_LENGTH + 1);
    if (!line->args->data) {
	cscp_line_destroy (line);
	return NULL;
    }

    return line;
}

GSList *
cscp_string_to_glist_scalars (char *in_line)
{
    char **args;
    char *arg;
    cce_scalar *scalar;
    char *scalar_quoted;
    GSList *list = NULL;
    GString *fullstr;
    int i;

    args = g_strsplit (in_line, " ", 0);

    for (i = 0; args[i] != NULL; i++) {
	arg = args[i];
	if (arg[0] == '"') {
	    fullstr = g_string_new (arg);
	    /* If we start with a quote then this is a wuoted string
	     * thus if we do not end with another quote that is not preceeded
	     * by a slash, dump the next argument on */
	    arg = args[i + 1];
	    while (arg) {
		int length;
		/* If the final charachter of the string is a quote and is not
		 * imemeditaly prefaced by an escaper, break out of the while
		 */
		length = strlen (arg);
		if (arg[length] == '"' && length >= 2 && arg[length] != '\\') {
		    break;
		}
		/* We now know that we're going to use the next argument no
		 * matter what so increment the counter.. */
		i += 1;
		/* The space will have been dumped by the split */
		g_string_append_c (fullstr, ' ');
		g_string_append (fullstr, arg);
		arg = args[i + 1];
	    }
	    scalar = cce_scalar_new_from_qstr (fullstr->str);
	    g_string_free (fullstr, 1);
	    scalar_quoted = strdup (scalar->data);
	    list = g_slist_append (list, scalar_quoted);
	    cce_scalar_destroy (scalar);
	} else if (arg[0] == '\0') {
	    /* Just skip spaces */
	    continue;
	} else {
	    list = g_slist_append (list, strdup (arg));
	}
    }

    g_strfreev (args);

    return list;
}

int
cscp_line_getcode (cscp_line_t * line)
{
    return line->code;
}

int
cscp_line_code_status (cscp_line_t * line)
{
    return line->code / 100;
}

int
cscp_line_code_type (cscp_line_t * line)
{
    return line->code % 100;
}

char *
cscp_line_getparam (cscp_line_t * line, int pos)
{
    GSList *arg;
    if (line->args == NULL) {
	return NULL;
    }
    if ((arg = g_slist_nth (line->args, pos)) == NULL) {
	return NULL;
    } else {
	return arg->data;
    }
}

char *
copy_message (cscp_line_t * line)
{
    char *strdata;
    GString *str;
    GSList *arglist;
    if (line->args == NULL) {
	return NULL;
    }

    str = g_string_new ("");
    arglist = g_slist_nth (line->args, 1);

    while (arglist) {
	g_string_append (str, (char *) (arglist->data));
	g_string_append_c (str, ' ');
	arglist = g_slist_next (arglist);
    }

    strdata = str->str;
    g_string_free (str, 0);	// dont free str->str

    return strdata;
}


/*
 * Response functions
 */

cscp_resp_t *
cscp_resp_new ()
{
    /* warn, info, all, final, success */
    cscp_resp_t *resp;
    resp = (cscp_resp_t *) malloc (sizeof (cscp_resp_t));
    resp->messages = NULL;
    resp->curr = NULL;
    resp->final = NULL;
    return resp;
}

void
cscp_resp_destroy (cscp_resp_t * resp)
{
    free_whole_g_slist_lines (resp->messages);
    /* FIXME: Why do I segfault ? */
    free (resp);
}

int
cscp_resp_add_line (cscp_resp_t * resp, cscp_line_t * line)
{
    /* code is in the range 0 -> 4 */
    int code;
    if (!line) {
	return 0;
    }
    code = cscp_line_code_status (line);

    resp->messages = g_slist_append (resp->messages, line);
    if (code == 2 || code == 4) {
	resp->final = line;
	/* That's the final line. Return true */
	return 1;
    }
    /* Not the final response, return false */
    return 0;
}

int
cscp_resp_is_success (cscp_resp_t * resp)
{
    if (!resp->final) {
	return 0;
    } else if (cscp_line_code_status (resp->final) == 2) {
	return 1;
    }
    return 0;
}

int
cscp_resp_is_finished (cscp_resp_t * resp)
{
    if (resp->final) {
	return 1;
    } else {
	return 0;
    }
}

cscp_line_t *
cscp_resp_nextline (cscp_resp_t * resp)
{
    if (!resp->curr) {
	/* Haven't been here before or we rewinded, set up the curr pointer */
	resp->curr = resp->messages;
	if (!resp->curr) {
	    return NULL;
	}
	return resp->curr->data;
    } else {
	resp->curr = g_slist_next (resp->curr);
	if (resp->curr) {
	    return resp->curr->data;
	} else {
	    return NULL;
	}
    }
}

/* Wow, this is easy enough.. */
void
cscp_resp_rewind (cscp_resp_t * resp)
{
    /* We actually just set it to null, so that the next call to nextline
     * will do the *actual* rewinding for us */
    resp->curr = NULL;
}

cscp_line_t *
cscp_resp_lastline (cscp_resp_t * resp)
{
    return resp->final;
}

/*
 * Command Functions
 */

cscp_cmnd_t *
cscp_cmnd_new ()
{
    cscp_cmnd_t *cmnd;
    cmnd = (cscp_cmnd_t *) malloc (sizeof (cscp_cmnd_t));
    cmnd->cmnd = 0;
    cmnd->args = g_string_new ("");
    return cmnd;
}

void
cscp_cmnd_destroy (cscp_cmnd_t * cmnd)
{
    g_string_free (cmnd->args, 1);
    free (cmnd);
}

void
cscp_cmnd_addstr (cscp_cmnd_t * cmnd, char *arg)
{
    cce_scalar *scalar;
    char *str;

    scalar = cce_scalar_new_from_str (arg);
    str = cce_scalar_to_str (scalar);
    cce_scalar_destroy (scalar);

    /* don't know for sure how glib will handle null as string, so 
     * just don't try */
    if (!str)
	return;

    g_string_append_c (cmnd->args, ' ');

    g_string_append (cmnd->args, str);

    free (str);
    return;
}

/* Can also add an OID namespace */
void
cscp_cmnd_addoid (cscp_cmnd_t * cmnd, cscp_oid_t oid, char *namespace)
{
    if (namespace && strcmp (namespace, "")) {
	g_string_sprintfa (cmnd->args, " %lu.%s", oid, namespace);
    } else {
	g_string_sprintfa (cmnd->args, " %lu", oid);
    }
}

void
cscp_cmnd_addliteral (cscp_cmnd_t * cmnd, char *literal)
{
    g_string_append (cmnd->args, literal);
    return;
}


char *
cscp_cmnd_serialise (cscp_cmnd_t * cmnd)
{
    GString *result;
    char *ret;

    result = g_string_new (cscp_cmnd2str (cmnd->cmnd));

    g_string_append (result, cmnd->args->str);
    g_string_append_c (result, '\n');

    ret = strdup (result->str);
    g_string_free (result, 1);
    return ret;
}

void
cscp_cmnd_setcmnd (cscp_cmnd_t * cmnd, int cmd_num)
{
    cmnd->cmnd = cmd_num;
}

int
cscp_cmnd_getcmnd (cscp_cmnd_t * cmnd)
{
    return cmnd->cmnd;
}

/*
 * Utility functions
 */

static void
free_whole_g_slist (GSList * list)
{
    GSList *curr;

    curr = list;
    while (curr) {
	free (curr->data);
	curr = g_slist_next (curr);
    }
    g_slist_free (list);
}

static void
free_whole_g_slist_lines (GSList * list)
{
    GSList *curr;

    curr = list;
    while (curr) {
	cscp_line_destroy ((curr->data));
	curr = g_slist_next (curr);
    }
    g_slist_free (list);
}

/* FIXME: This segfaults on invalid commands, I intend to stop invalid commands
 * at other points, but this should still not fail */
char *
cscp_cmnd2str (int cmnd)
{
    return cscp_cmd_table[cmnd].cmd;
}

/*
 * Oid Manipulation commands
 */

cscp_oid_t
cscp_oid_from_string (char *number)
{
    if (number == NULL) {
	return 0;
    }
    return strtoul (number, NULL, 10);
}

char *
cscp_oid_to_string (cscp_oid_t oid)
{
    char buf[32];

    snprintf (buf, sizeof (buf), "%lu", oid);

    return strdup (buf);
}


#ifdef DEBUG
/* We occasionally decide not to use * functions in this area because we
 * intend to find memory leaks here, not fix them */

char *
cscp_line_serialise (cscp_line_t * line)
{
    GString *result;
    char *ret;
    char *code;
    GSList *args;

    result = g_string_new ("");
    args = line->args;

    code = malloc (C6_CODE_LENGTH + 1);
    snprintf (code, C6_CODE_LENGTH + 1, "%d", line->code);

    g_string_append (result, code);

    free (code);

    while (args) {
	g_string_append_c (result, ' ');
	g_string_append (result, (char *) args->data);
	args = g_slist_next (args);
	/* Not free as cce_scalar uses just plain malloc */
    }

    ret = strdup (result->str);
    g_string_free (result, 1);
    return ret;
}

char *
cscp_resp_serialise (cscp_resp_t * resp)
{
    GString *result;
    char *ret;

    result = g_string_new ("");
    g_string_sprintfa (result, "\tResult: %d\n", cscp_resp_is_success (resp));

    g_string_append (result, "\tMessages\n");
    ret = printAllLines (resp->messages);
    g_string_append (result, ret);
    free (ret);

    g_string_append (result, "\tFinal Message\n");
    if (resp->final) {
	ret = cscp_line_serialise (resp->final);
	g_string_append (result, "\t\t");
	g_string_append (result, ret);
	g_string_append_c (result, '\n');
	free (ret);
    } else {
	g_string_append (result, "\t\tHas not yet been generated\n");
    }

    ret = strdup (result->str);
    g_string_free (result, 1);
    return ret;
}

char *
printAllLines (GSList * list)
{
    char *ret;
    GString *result;
    result = g_string_new ("");
    while (list) {
	ret = cscp_line_serialise (list->data);
	g_string_append (result, "\t\t");
	g_string_append (result, ret);
	g_string_append_c (result, '\n');
	free (ret);
	list = g_slist_next (list);
    }
    ret = strdup (result->str);
    g_string_free (result, 1);
    return ret;
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
