# $Id: sausalito-cce.spec.in 991 2007-05-05 05:40:00Z shibuya $
# Copyright 2001 Sun Microsystems, Inc.  All rights reserved.

%define extension_dir %(php-config --extension-dir)

Summary: Cobalt CCE Server and Clients
Name: sausalito-cce
Version: 0.80.2
Release: 1BQ37%{?dist}
Vendor: %{vendor}
License: Sun modified BSD
Group: System Environment/BlueQuartz
Source: sausalito-cce.tar.gz
Prefix: /usr/sausalito
BuildRoot: /var/tmp/cce-root
BuildRequires: glib-devel, pam-devel
BuildRequires: flex, bison
%if "%tlas" != "2"
BuildRequires: glib-ghash
%endif

%if "%sles" == "9"
BuildRequires: php4-devel
%endif
%if "%tlas" == "2"
BuildRequires: php4
%endif
%if 0%{?fedora}%{?centos}
BuildRequires: php-devel
%endif

# Maximum RPM: "There are times when RPM's automatic dependency
# processing may not be desirable."  Yeah, like when it crashes.
# AutoReqProv: no

%description
sausalito-cce has both the server and client parts of cce.

%package server
Group: System Environment/BlueQuartz
Summary: The CCE server daemon
Requires: glib, glib-ghash, pam
%if "%centos" == "4"
Requires: audit-libs
%endif

%description server
The cce-server package contains the server-side parts of the Cobalt 
Configuration Engine.

%package client
Group: System Environment/BlueQuartz
Summary: The CCE client libraries
Requires: glib, glib-ghash, pam, httpd

%description client
The cce-client package contains the client-side parts of the Cobalt 
Configuration Engine.

%prep
%setup -n cce

%build
make all \
%if "%tlas" != "2"
	GLIB_GHASH=true \
%endif
	CCETOPDIR=/usr/sausalito

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/usr/sausalito/
mkdir -p $RPM_BUILD_ROOT/usr/sausalito/sbin
mkdir -p $RPM_BUILD_ROOT/usr/sausalito/bin
mkdir -p $RPM_BUILD_ROOT/usr/sausalito/codb
mkdir -p $RPM_BUILD_ROOT/usr/sausalito/codb/txn
mkdir -p $RPM_BUILD_ROOT/usr/sausalito/conf
mkdir -p $RPM_BUILD_ROOT/usr/sausalito/schemas
mkdir -p $RPM_BUILD_ROOT/usr/sausalito/sessions
mkdir -p $RPM_BUILD_ROOT/usr/sausalito/handlers
mkdir -p $RPM_BUILD_ROOT/usr/sausalito/constructor
mkdir -p $RPM_BUILD_ROOT/usr/sausalito/destructor
mkdir -p $RPM_BUILD_ROOT/usr/sausalito/capstone
mkdir -p $RPM_BUILD_ROOT/usr/sausalito/devel
mkdir -p $RPM_BUILD_ROOT/usr/sausalito/lib
mkdir -p $RPM_BUILD_ROOT/usr/sausalito/include
mkdir -p $RPM_BUILD_ROOT/usr/sausalito/perl
mkdir -p $RPM_BUILD_ROOT/etc/rc.d/init.d
mkdir -p $RPM_BUILD_ROOT/etc/pam.d
mkdir -p $RPM_BUILD_ROOT/lib/security
mkdir -p $RPM_BUILD_ROOT/etc/php.d
make install PREFIX=$RPM_BUILD_ROOT CCETOPDIR=/usr/sausalito

%files server
%defattr(-,root,root)
%doc LICENSE.txt
%dir /usr/sausalito/
%dir /usr/sausalito/sbin
/usr/sausalito/sbin/*
%dir /usr/sausalito/bin
/usr/sausalito/bin/pperl
/usr/sausalito/bin/pperld
%dir /usr/sausalito/codb
%dir /usr/sausalito/codb/txn
%dir /usr/sausalito/conf
%dir /usr/sausalito/schemas
/usr/sausalito/schemas/*
%dir /usr/sausalito/sessions
%dir /usr/sausalito/handlers
%dir /usr/sausalito/constructor
%dir /usr/sausalito/destructor
%dir /usr/sausalito/capstone
%dir /usr/sausalito/devel
%dir /usr/sausalito/lib
%dir /usr/sausalito/include
%dir /usr/sausalito/perl
/etc/rc.d/init.d/*
/etc/pam.d/*
/lib/security/*

%files client
%attr(-,root,apache)/usr/sausalito/bin/ccewrap
%config %attr(-,root,root)/etc/ccewrap.conf
%defattr(-,root,root)
%doc LICENSE.txt
%dir /etc/ccewrap.d
/usr/sausalito/bin/cce_construct  
/usr/sausalito/bin/cceclient
/usr/sausalito/lib/*.so*
/usr/sausalito/include/*
/usr/sausalito/ui/libPhp/*
/usr/sausalito/perl/*
%{extension_dir}/*
/usr/share/locale/*
%config(noreplace) /etc/httpd/conf.d/bluequartz.conf

%post server
# only run on install, not upgrade 
if [ "$1" = "1" ]; then
	/sbin/chkconfig --add cced.init
fi

%postun server
# only run if this is the last instance to be removed
if [ "$1" = "0" ]; then
	/sbin/chkconfig --del cced.init
fi

# restart cced.init on upgrade
if [ "$1" -ge "1" ]; then
	service cced.init restart >/dev/null 2>&1
fi

%post client
# only run on install, not upgrade
if [ "$1" = "1" ]; then
	LIB=/usr/sausalito/lib
	cp /etc/ld.so.conf /etc/ld.so.conf.bak
	egrep "^$LIB[ 	]*$" /etc/ld.so.conf >/dev/null \
		|| echo $LIB >> /etc/ld.so.conf
	/sbin/ldconfig
fi

# resetup the owner of ccewrap
if [ $1 = 2 ]; then
 	/bin/chgrp apache /usr/sausalito/bin/ccewrap
	/bin/chmod u+s /usr/sausalito/bin/ccewrap
fi

%postun client
# reload httpd
if [ "$1" -ge "1" ]; then
	service httpd restart >/dev/null 2>&1
	service admserv restart >/dev/null 2>&1
fi

%changelog

%changelog 
* Wed Jun 04 2008 Michael Stauber <mstauber@solarspeed.net> 0.80.2-1BQ37
- Fixed /etc/pam/cced and added /etc/pam/system-auth-cce as we cannot use the regular /etc/pam/system-auth

* Mon Jun 02 2008 Michael Stauber <mstauber@solarspeed.net> 0.80.2-1BQ36
- Fixed function array_to_scalar in CceClient.php to add a check if the argument IS an array to begin with.

* Sun Jun 01 2008 Michael Stauber <mstauber@solarspeed.net> 0.80.2-1BQ35 
- For 5106R: Merged Brians mods from 5200R svn tree and mods from 5100R to 5106R

* Sun May 11 2008 Michael Stauber <mstauber@solarspeed.net> 0.80.2-1BQ34 
- Modified basetypes.schema to change minimum/maximum password length to more secure defaults (min:6, max: 24). 
- Modified rules.mk to comment out 'ifdefined' for GLIB_GHASH to eleminate build errors on CentOS-4 
- Added README to build tree to remind people which BuildRequires this package has. 

* Sun Jan 27 2008 Hisao SHIBUYA <shibuya@bluequartz.org> 0.80.2-1BQ33 
- add sign package. 

* Sat May 05 2007 Hisao SHIBUYA <shibuya@bluequartz.org> 0.80.2-1BQ33
- use include_once instead of include for php file.

* Fri May 04 2007 Hisao SHIBUYA <shibuya@bluequartz.org> 0.80.2-1BQ32
- modify pam config file for cced to remove pwdb feature.

* Sun Apr 29 2007 Hisao SHIBUYA <shibuya@bluequartz.org> 0.80.2-1BQ31
- remove .svn directory.
- replace corrupted db.1.85.tar.gz.

* Mon Jun 19 2006 Hisao SHIBUYA <shibuya@alpha.or.jp> 0.80.2-1BQ30
- change group and mod to ccewrap.

* Sun Jun 18 2006 Hisao SHIBUYA <shibuya@alpha.or.jp> 0.80.2-1BQ29
- add requires httpd for client package.

* Thu May 05 2006 Hisao SHIBUYA <shibuya@alpha.or.jp> 0.80.2-1BQ28
- modified initscript to add static route at starting.

* Mon Jan 16 2006 Hisao SHIBUYA <shibuya@alpha.or.jp> 0.80.2-1BQ27
- remove cce.ini for php.

* Sun Dec 25 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 0.80.2-1BQ26.1
- modified cscp/src/cscp_fsm.c to support alpha.

* Wed Nov 02 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 0.80.2-1BQ26
- add BuildRequires: flex, bison.

* Mon Oct 31 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 0.80.2-1BQ25
- added Requires for CentOS4.
- modified spec file to add Requires to server and client packages.

* Mon Oct 31 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 0.80.2-1BQ24
- modified bluequartz.conf for httpd.

* Mon Oct 31 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 0.80.2-1BQ23
- use %02d for debug output time.

* Fri Oct 21 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 0.80.2-1BQ22
- use php-config to get extension directory.

* Thu Oct 20 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 0.80.2-1BQ21
- add specific code to spec file for tlas

* Thu Oct 20 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 0.80.2-1BQ20
- use vendor macro for vendor tag.

* Tue Oct 19 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 0.80.2-1BQ19
- rebuild with devel-tools 0.5.1

* Mon Aug 15 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 0.80.2-1BQ18
- clean up spec file.

* Thu Jun 23 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 0.80.2-1BQ17
- modified debug code displayed microtime.

* Sun Jun 12 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 0.80.2-1BQ16
- added Indexed taf for the sake of backward compatibility in bluequartz.conf.

* Sat Jun 11 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 0.80.2-1BQ15
- modified cced.pam to support i386 and x86_64.

* Sat Jun 11 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 0.80.2-1BQ14
- modified cced.pam for x86_64.

* Thu May 26 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 0.80.2-1BQ13
- build for x86_64.

* Wed Mar 09 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 0.80.2-1BQ12
- add distribution dependency code.

* Mon Dec 27 2004 Hisao SHIBUYA <shibuya@alpha.or.jp> 0.80.2-1BQ11
- added restart script on %postun section

* Wed Nov 24 2004 Hisao SHIBUYA <shibuya@alpha.or.jp> 0.80.2-1BQ7
- modified bluequartz.conf for apache to modified AllowOverride.

* Thu Jul 29 2004 Hisao SHIBUYA <shibuya@alpha.or.jp> 0.80.2-1BQ6
- usr libghash.so instead of patched libglib.so to support GHashIter function.

* Fri May 28 2004 Hisao SHIBUYA <shibuya@alphr.or.jp> 0.80.2-1BQ5
- fix wrong integer type gave warning in cce.c

* Thu Mar 25 2004 Hisao SHIBUYA <shibuya@alpha.or.jp> 0.80.2-1BQ4
- change cced.init for Blue Quartz 5100R

* Tue Jan 08 2004 Hisao SHIBUYA <shibuya@alpha.or.jp> 0.80.2-1BQ1
- build for Blue Quartz

* Wed Feb 27 2002 CCE Team <cce@sun.com>
-- This is a short summary of some major changes from version 0.76 to 0.80.1
- "rollback" handlers run on failure of a transaction
- Extensible security rules can be specified in schemas
- Create and destroy acls can be specified on namespaces
- ACLs accept boolean logic rules
- More builtin security rules
- "begin"/"commit" creates a single transaction from multiple commands
- ccewrap now looks in /etc/ccewrap.d/ directory for new XML format files
- CCE can be put in a read-only mode using the "admin suspend" command
- "find" enhanced with a regular expression search capability
- "find" enhanced with more builtin sort types
- Indexes can be defined to speed up searching
- Logging of all CSCP commands has a consistant format
- Handlers can be specified as relative paths
- Handlers run chdir'd to their location, not /tmp
- Connections from uid 0 which auth/authkey, correctly lose admin privledges
- "baddata"/"warn" messages are escaped
- Handlers default to fail, not success
