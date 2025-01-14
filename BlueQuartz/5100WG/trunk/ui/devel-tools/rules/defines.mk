CCEBASE=/usr/sausalito
CCEDIR=$(PREFIX)$(CCEBASE)
CCEWEB=$(CCEBASE)/ui/web

CCELIBDIR=$(CCEDIR)/lib
CCEINCDIR=$(CCEDIR)/include
CCEBINDIR=$(CCEDIR)/bin
CCESBINDIR=$(CCEDIR)/sbin
CCEPERLDIR=$(CCEDIR)/perl
CCEPHPLIBDIR=$(PREFIX)/usr/lib/php4
CCEPHPCLASSDIR=$(CCEDIR)/ui/libPhp
CCETMPDIR=$(PREFIX)/tmp
CCECONFDIR=$(CCEDIR)/conf
CCESCHEMASDIR=$(CCEDIR)/schemas
CCESESSIONSDIR=$(CCEDIR)/sessions
CCEHANDLERDIR=$(CCEDIR)/handlers
CCEWRAPD=$(PREFIX)/etc/ccewrap.d

CCELOCALEDIR=$(PREFIX)/usr/share/locale/

CCECDEFS=-I$(CCEINCDIR) -D_REENTRANT
CCESHAREDCDEFS=$(CCECDEFS) -fPIC
CCELIBDEFS=-L$(CCELIBDIR)
CCESHAREDLDDEFS=-shared -rdynamic

SWATCHDIR=$(PREFIX)/usr/sausalito/swatch
SWATCHCONFDIR=$(SWATCHDIR)/conf
SWATCHBINDIR=$(SWATCHDIR)/bin

# lcd installation
LCDINSTALLDIR=$(PREFIX)/etc/lcd.d/10main.m
LCDDIR=/etc/lcd.d/10main.m

# default permissions
INSTALL_DEFAULT=-o root -g root
INSTALL_HEADERFLAGS=$(INSTALL_DEFAULT) -m 644
INSTALL_BINFLAGS=$(INSTALL_DEFAULT) -m 755
INSTALL_SBINFLAGS=$(INSTALL_DEFAULT) -m 700
INSTALL_SCRIPTFLAGS=$(INSTALL_DEFAULT) -m 755
INSTALL_LIBFLAGS=$(INSTALL_DEFAULT) -m 644
INSTALL_SHLIBFLAGS=$(INSTALL_DEFAULT) -m 755

# non-cce stuff
RANLIB=ranlib
AR=ar
CC=gcc
INSTALL=install
RPM_DIR=/fargo/rpms/i386
SRPM_DIR=/fargo/srpms
REDHAT_DIR=/usr/src/redhat

XLOCALEPAT=zh_CN zh_TW
