/* netcmds.h - upsd support structure details

   Copyright (C) 2001  Russell Kroll <rkroll@exploits.org>

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

#include "ctype.h"

#include "ssl.h"
#include "netget.h"
#include "netset.h"
#include "netlist.h"
#include "netmisc.h"
#include "netuser.h"
#include "netinstcmd.h"

#define FLAG_USER	0x0001		/* username and password must be set */

struct netcmds_t {
	const	char	*name;
	void	(*func)(ctype_t *client, int numargs, const char **arg);
	int	flags;
};

struct netcmds_t netcmds[] =
{
	{ "VER",	net_ver,	0		},
	{ "HELP",	net_help,	0		},
	{ "STARTTLS",	net_starttls,	0		},

	{ "GET",	net_get,	0		},
	{ "LIST",	net_list,	0		},

	{ "USERNAME",	net_username,	0		},
	{ "PASSWORD",	net_password,	0		},

	{ "LOGIN",	net_login,	FLAG_USER	},
	{ "LOGOUT", 	net_logout,	0		},
	{ "MASTER",	net_master,	FLAG_USER	},

	{ "FSD",	net_fsd,	FLAG_USER	},

	{ "SET",	net_set,	FLAG_USER	},
	{ "INSTCMD",	net_instcmd,	FLAG_USER	},

	{ NULL,		(void(*)())(NULL), 0		}
};
