ifndef CCETOPDIR
CCETOPDIR = /usr/sausalito
endif

# include defines.mk here before checking to see which target make is doing
include $(CCETOPDIR)/devel/defines.mk

# check PREFIX, because if it is defined we are 'make rpm' and CCETOPDIR
# needs to be redefined appropriately
ifdef PREFIX
CCETOPDIR = $(PREFIX)/usr/sausalito
endif

PROFILEDIR = $(PREFIX)/etc/profile.d
PROFILES=java.sh

MODJKDIR = $(PREFIX)/etc/httpd/conf.d
MODJK=mod_jk.conf

WORKERSDIR = $(PREFIX)/etc/tomcat/jk
WORKERS=workers.properties

USERSDIR = $(PREFIX)/etc/tomcat
USERS=tomcat-users.xml.dist tomcat.logrotate.dist

# Specify the right lib dir for 32-bit and 64-bit:
MODULESLIBDIR=$(shell if [ `uname -m` = "x86_64" ]; then  echo -n "lib64"; else  echo -n "lib"; fi)
MODULES = $(PREFIX)/usr/$(MODULESLIBDIR)/httpd/modules

# Use the right mod_jk.so based on the architecture:
MODULEJK=$(shell if [ `uname -m` = "x86_64" ]; then  echo -n "mod_jk.so"; else  echo -n "mod_jk.so"; fi)
#MODULEJK=mod_jk.so

SCRIPTS=java_load_war.pl

all:

install:
	echo "making dir:"
	echo $(CCESBINDIR)
	mkdir -p $(CCESBINDIR)
	mkdir -p $(PROFILEDIR)
	mkdir -p $(MODJKDIR)
	mkdir -p $(WORKERSDIR)
	mkdir -p $(USERSDIR)
	mkdir -p $(MODULES)
	(cd sbin; $(INSTALL) $(INSTALL_BINFLAGS) $(SCRIPTS) $(CCESBINDIR); )
	(cd etc/profile.d; $(INSTALL) $(PROFILES) $(PROFILEDIR); )
	(cd etc/httpd/conf.d; $(INSTALL) $(MODJK) $(MODJKDIR); )
	(cd etc/tomcat/jk; $(INSTALL) $(WORKERS) $(WORKERSDIR); )
	(cd etc/tomcat; $(INSTALL) $(USERS) $(USERSDIR); )
	(cd modules; $(INSTALL) $(INSTALL_BINFLAGS) $(MODULEJK) $(MODULES); )

rpm:

