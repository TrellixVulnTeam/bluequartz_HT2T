# Makefile.in generated by automake 1.13.4 from Makefile.am.
# src/Makefile.  Generated from Makefile.in by configure.

# Copyright (C) 1994-2013 Free Software Foundation, Inc.

# This Makefile.in is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY, to the extent permitted by law; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.





am__is_gnu_make = test -n '$(MAKEFILE_LIST)' && test -n '$(MAKELEVEL)'
am__make_running_with_option = \
  case $${target_option-} in \
      ?) ;; \
      *) echo "am__make_running_with_option: internal error: invalid" \
              "target option '$${target_option-}' specified" >&2; \
         exit 1;; \
  esac; \
  has_opt=no; \
  sane_makeflags=$$MAKEFLAGS; \
  if $(am__is_gnu_make); then \
    sane_makeflags=$$MFLAGS; \
  else \
    case $$MAKEFLAGS in \
      *\\[\ \	]*) \
        bs=\\; \
        sane_makeflags=`printf '%s\n' "$$MAKEFLAGS" \
          | sed "s/$$bs$$bs[$$bs $$bs	]*//g"`;; \
    esac; \
  fi; \
  skip_next=no; \
  strip_trailopt () \
  { \
    flg=`printf '%s\n' "$$flg" | sed "s/$$1.*$$//"`; \
  }; \
  for flg in $$sane_makeflags; do \
    test $$skip_next = yes && { skip_next=no; continue; }; \
    case $$flg in \
      *=*|--*) continue;; \
        -*I) strip_trailopt 'I'; skip_next=yes;; \
      -*I?*) strip_trailopt 'I';; \
        -*O) strip_trailopt 'O'; skip_next=yes;; \
      -*O?*) strip_trailopt 'O';; \
        -*l) strip_trailopt 'l'; skip_next=yes;; \
      -*l?*) strip_trailopt 'l';; \
      -[dEDm]) skip_next=yes;; \
      -[JT]) skip_next=yes;; \
    esac; \
    case $$flg in \
      *$$target_option*) has_opt=yes; break;; \
    esac; \
  done; \
  test $$has_opt = yes
am__make_dryrun = (target_option=n; $(am__make_running_with_option))
am__make_keepgoing = (target_option=k; $(am__make_running_with_option))
pkgdatadir = $(datadir)/netdata
pkgincludedir = $(includedir)/netdata
pkglibdir = $(libdir)/netdata
pkglibexecdir = $(libexecdir)/netdata
am__cd = CDPATH="$${ZSH_VERSION+.}$(PATH_SEPARATOR)" && cd
install_sh_DATA = $(install_sh) -c -m 644
install_sh_PROGRAM = $(install_sh) -c
install_sh_SCRIPT = $(install_sh) -c
INSTALL_HEADER = $(INSTALL_DATA)
transform = $(program_transform_name)
NORMAL_INSTALL = :
PRE_INSTALL = :
POST_INSTALL = :
NORMAL_UNINSTALL = :
PRE_UNINSTALL = :
POST_UNINSTALL = :
build_triplet = x86_64-unknown-linux-gnu
host_triplet = x86_64-unknown-linux-gnu
sbin_PROGRAMS = netdata$(EXEEXT)
plugins_PROGRAMS = apps.plugin$(EXEEXT)
#am__append_1 = \
#	plugin_freebsd.c plugin_freebsd.h \
#	freebsd_sysctl.c \
#	$(NULL)

am__append_2 = \
	plugin_proc.c plugin_proc.h \
	proc_diskstats.c \
	proc_interrupts.c \
	proc_softirqs.c \
	proc_loadavg.c \
	proc_meminfo.c \
	proc_net_dev.c \
	proc_net_ip_vs_stats.c \
	proc_net_netstat.c \
	proc_net_rpc_nfs.c \
	proc_net_rpc_nfsd.c \
	proc_net_snmp.c \
	proc_net_snmp6.c \
	proc_net_softnet_stat.c \
	proc_net_stat_conntrack.c \
	proc_net_stat_synproxy.c \
	proc_stat.c \
	proc_sys_kernel_random_entropy_avail.c \
	proc_vmstat.c \
	ipc.c ipc.h \
	sys_kernel_mm_ksm.c \
	$(NULL)

subdir = src
DIST_COMMON = $(srcdir)/Makefile.in $(srcdir)/Makefile.am \
	$(top_srcdir)/depcomp $(dist_cache_DATA) $(dist_log_DATA) \
	$(dist_registry_DATA) $(dist_varlib_DATA)
ACLOCAL_M4 = $(top_srcdir)/aclocal.m4
am__aclocal_m4_deps = $(top_srcdir)/m4/ax_c___atomic.m4 \
	$(top_srcdir)/m4/ax_c__generic.m4 \
	$(top_srcdir)/m4/ax_c_mallinfo.m4 \
	$(top_srcdir)/m4/ax_c_mallopt.m4 \
	$(top_srcdir)/m4/ax_check_compile_flag.m4 \
	$(top_srcdir)/m4/ax_pthread.m4 $(top_srcdir)/m4/jemalloc.m4 \
	$(top_srcdir)/m4/tcmalloc.m4 $(top_srcdir)/configure.ac
am__configure_deps = $(am__aclocal_m4_deps) $(CONFIGURE_DEPENDENCIES) \
	$(ACLOCAL_M4)
mkinstalldirs = $(install_sh) -d
CONFIG_HEADER = $(top_builddir)/config.h
CONFIG_CLEAN_FILES =
CONFIG_CLEAN_VPATH_FILES =
am__installdirs = "$(DESTDIR)$(pluginsdir)" "$(DESTDIR)$(sbindir)" \
	"$(DESTDIR)$(cachedir)" "$(DESTDIR)$(logdir)" \
	"$(DESTDIR)$(registrydir)" "$(DESTDIR)$(varlibdir)"
PROGRAMS = $(plugins_PROGRAMS) $(sbin_PROGRAMS)
am_apps_plugin_OBJECTS = apps_plugin.$(OBJEXT) avl.$(OBJEXT) \
	clocks.$(OBJEXT) common.$(OBJEXT) log.$(OBJEXT) \
	procfile.$(OBJEXT) web_buffer.$(OBJEXT)
apps_plugin_OBJECTS = $(am_apps_plugin_OBJECTS)
apps_plugin_LDADD = $(LDADD)
am__netdata_SOURCES_DIST = appconfig.c appconfig.h avl.c avl.h \
	backends.c backends.h clocks.c clocks.h common.c common.h \
	daemon.c daemon.h dictionary.c dictionary.h eval.c eval.h \
	global_statistics.c global_statistics.h health.c health.h \
	log.c log.h main.c main.h plugin_checks.c plugin_checks.h \
	plugin_idlejitter.c plugin_idlejitter.h plugin_nfacct.c \
	plugin_nfacct.h plugin_tc.c plugin_tc.h plugins_d.c \
	plugins_d.h popen.c popen.h sys_fs_cgroup.c procfile.c \
	procfile.h proc_self_mountinfo.c proc_self_mountinfo.h \
	registry.c registry.h rrd.c rrd.h rrd2json.c rrd2json.h \
	storage_number.c storage_number.h unit_test.c unit_test.h \
	url.c url.h web_buffer.c web_buffer.h web_buffer_svg.c \
	web_buffer_svg.h web_client.c web_client.h web_server.c \
	web_server.h plugin_freebsd.c plugin_freebsd.h \
	freebsd_sysctl.c plugin_proc.c plugin_proc.h proc_diskstats.c \
	proc_interrupts.c proc_softirqs.c proc_loadavg.c \
	proc_meminfo.c proc_net_dev.c proc_net_ip_vs_stats.c \
	proc_net_netstat.c proc_net_rpc_nfs.c proc_net_rpc_nfsd.c \
	proc_net_snmp.c proc_net_snmp6.c proc_net_softnet_stat.c \
	proc_net_stat_conntrack.c proc_net_stat_synproxy.c proc_stat.c \
	proc_sys_kernel_random_entropy_avail.c proc_vmstat.c ipc.c \
	ipc.h sys_kernel_mm_ksm.c
#am__objects_1 = plugin_freebsd.$(OBJEXT) \
#	freebsd_sysctl.$(OBJEXT)
am__objects_2 = plugin_proc.$(OBJEXT) \
	proc_diskstats.$(OBJEXT) \
	proc_interrupts.$(OBJEXT) \
	proc_softirqs.$(OBJEXT) proc_loadavg.$(OBJEXT) \
	proc_meminfo.$(OBJEXT) proc_net_dev.$(OBJEXT) \
	proc_net_ip_vs_stats.$(OBJEXT) \
	proc_net_netstat.$(OBJEXT) \
	proc_net_rpc_nfs.$(OBJEXT) \
	proc_net_rpc_nfsd.$(OBJEXT) \
	proc_net_snmp.$(OBJEXT) \
	proc_net_snmp6.$(OBJEXT) \
	proc_net_softnet_stat.$(OBJEXT) \
	proc_net_stat_conntrack.$(OBJEXT) \
	proc_net_stat_synproxy.$(OBJEXT) \
	proc_stat.$(OBJEXT) \
	proc_sys_kernel_random_entropy_avail.$(OBJEXT) \
	proc_vmstat.$(OBJEXT) ipc.$(OBJEXT) \
	sys_kernel_mm_ksm.$(OBJEXT)
am_netdata_OBJECTS = appconfig.$(OBJEXT) avl.$(OBJEXT) \
	backends.$(OBJEXT) clocks.$(OBJEXT) common.$(OBJEXT) \
	daemon.$(OBJEXT) dictionary.$(OBJEXT) eval.$(OBJEXT) \
	global_statistics.$(OBJEXT) health.$(OBJEXT) log.$(OBJEXT) \
	main.$(OBJEXT) plugin_checks.$(OBJEXT) \
	plugin_idlejitter.$(OBJEXT) plugin_nfacct.$(OBJEXT) \
	plugin_tc.$(OBJEXT) plugins_d.$(OBJEXT) popen.$(OBJEXT) \
	sys_fs_cgroup.$(OBJEXT) procfile.$(OBJEXT) \
	proc_self_mountinfo.$(OBJEXT) registry.$(OBJEXT) rrd.$(OBJEXT) \
	rrd2json.$(OBJEXT) storage_number.$(OBJEXT) \
	unit_test.$(OBJEXT) url.$(OBJEXT) web_buffer.$(OBJEXT) \
	web_buffer_svg.$(OBJEXT) web_client.$(OBJEXT) \
	web_server.$(OBJEXT) $(am__objects_1) $(am__objects_2)
netdata_OBJECTS = $(am_netdata_OBJECTS)
am__DEPENDENCIES_1 =
netdata_DEPENDENCIES = $(am__DEPENDENCIES_1) $(am__DEPENDENCIES_1) \
	$(am__DEPENDENCIES_1) $(am__DEPENDENCIES_1)
AM_V_P = $(am__v_P_$(V))
am__v_P_ = $(am__v_P_$(AM_DEFAULT_VERBOSITY))
am__v_P_0 = false
am__v_P_1 = :
AM_V_GEN = $(am__v_GEN_$(V))
am__v_GEN_ = $(am__v_GEN_$(AM_DEFAULT_VERBOSITY))
am__v_GEN_0 = @echo "  GEN     " $@;
am__v_GEN_1 = 
AM_V_at = $(am__v_at_$(V))
am__v_at_ = $(am__v_at_$(AM_DEFAULT_VERBOSITY))
am__v_at_0 = @
am__v_at_1 = 
DEFAULT_INCLUDES = -I. -I$(top_builddir)
depcomp = $(SHELL) $(top_srcdir)/depcomp
am__depfiles_maybe = depfiles
am__mv = mv -f
COMPILE = $(CC) $(DEFS) $(DEFAULT_INCLUDES) $(INCLUDES) $(AM_CPPFLAGS) \
	$(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS)
AM_V_CC = $(am__v_CC_$(V))
am__v_CC_ = $(am__v_CC_$(AM_DEFAULT_VERBOSITY))
am__v_CC_0 = @echo "  CC      " $@;
am__v_CC_1 = 
CCLD = $(CC)
LINK = $(CCLD) $(AM_CFLAGS) $(CFLAGS) $(AM_LDFLAGS) $(LDFLAGS) -o $@
AM_V_CCLD = $(am__v_CCLD_$(V))
am__v_CCLD_ = $(am__v_CCLD_$(AM_DEFAULT_VERBOSITY))
am__v_CCLD_0 = @echo "  CCLD    " $@;
am__v_CCLD_1 = 
SOURCES = $(apps_plugin_SOURCES) $(netdata_SOURCES)
DIST_SOURCES = $(apps_plugin_SOURCES) $(am__netdata_SOURCES_DIST)
am__can_run_installinfo = \
  case $$AM_UPDATE_INFO_DIR in \
    n|no|NO) false;; \
    *) (install-info --version) >/dev/null 2>&1;; \
  esac
am__vpath_adj_setup = srcdirstrip=`echo "$(srcdir)" | sed 's|.|.|g'`;
am__vpath_adj = case $$p in \
    $(srcdir)/*) f=`echo "$$p" | sed "s|^$$srcdirstrip/||"`;; \
    *) f=$$p;; \
  esac;
am__strip_dir = f=`echo $$p | sed -e 's|^.*/||'`;
am__install_max = 40
am__nobase_strip_setup = \
  srcdirstrip=`echo "$(srcdir)" | sed 's/[].[^$$\\*|]/\\\\&/g'`
am__nobase_strip = \
  for p in $$list; do echo "$$p"; done | sed -e "s|$$srcdirstrip/||"
am__nobase_list = $(am__nobase_strip_setup); \
  for p in $$list; do echo "$$p $$p"; done | \
  sed "s| $$srcdirstrip/| |;"' / .*\//!s/ .*/ ./; s,\( .*\)/[^/]*$$,\1,' | \
  $(AWK) 'BEGIN { files["."] = "" } { files[$$2] = files[$$2] " " $$1; \
    if (++n[$$2] == $(am__install_max)) \
      { print $$2, files[$$2]; n[$$2] = 0; files[$$2] = "" } } \
    END { for (dir in files) print dir, files[dir] }'
am__base_list = \
  sed '$$!N;$$!N;$$!N;$$!N;$$!N;$$!N;$$!N;s/\n/ /g' | \
  sed '$$!N;$$!N;$$!N;$$!N;s/\n/ /g'
am__uninstall_files_from_dir = { \
  test -z "$$files" \
    || { test ! -d "$$dir" && test ! -f "$$dir" && test ! -r "$$dir"; } \
    || { echo " ( cd '$$dir' && rm -f" $$files ")"; \
         $(am__cd) "$$dir" && rm -f $$files; }; \
  }
DATA = $(dist_cache_DATA) $(dist_log_DATA) $(dist_registry_DATA) \
	$(dist_varlib_DATA)
am__tagged_files = $(HEADERS) $(SOURCES) $(TAGS_FILES) $(LISP)
# Read a list of newline-separated strings from the standard input,
# and print each of them once, without duplicates.  Input order is
# *not* preserved.
am__uniquify_input = $(AWK) '\
  BEGIN { nonempty = 0; } \
  { items[$$0] = 1; nonempty = 1; } \
  END { if (nonempty) { for (i in items) print i; }; } \
'
# Make sure the list of sources is unique.  This is necessary because,
# e.g., the same source file might be shared among _SOURCES variables
# for different programs/libraries.
am__define_uniq_tagged_files = \
  list='$(am__tagged_files)'; \
  unique=`for i in $$list; do \
    if test -f "$$i"; then echo $$i; else echo $(srcdir)/$$i; fi; \
  done | $(am__uniquify_input)`
ETAGS = etags
CTAGS = ctags
DISTFILES = $(DIST_COMMON) $(DIST_SOURCES) $(TEXINFOS) $(EXTRA_DIST)
ACLOCAL = ${SHELL} /home/install/netdata/netdata/missing aclocal-1.13
AMTAR = $${TAR-tar}
AM_DEFAULT_VERBOSITY = 1
AUTOCONF = ${SHELL} /home/install/netdata/netdata/missing autoconf
AUTOHEADER = ${SHELL} /home/install/netdata/netdata/missing autoheader
AUTOMAKE = ${SHELL} /home/install/netdata/netdata/missing automake-1.13
AWK = gawk
CC = gcc
CCDEPMODE = depmode=gcc3
CFLAGS = -O3 -pthread
CPP = gcc -E
CPPFLAGS = 
CYGPATH_W = echo
DEFS = -DHAVE_CONFIG_H
DEPDIR = .deps
ECHO_C = 
ECHO_N = -n
ECHO_T = 
EGREP = /usr/bin/grep -E
EXEEXT = 
GREP = /usr/bin/grep
INSTALL = /usr/bin/install -c
INSTALL_DATA = ${INSTALL} -m 644
INSTALL_PROGRAM = ${INSTALL}
INSTALL_SCRIPT = ${INSTALL}
INSTALL_STRIP_PROGRAM = $(install_sh) -c -s
LDFLAGS = 
LIBMNL_CFLAGS = 
LIBMNL_LIBS = 
LIBOBJS = 
LIBS =  
LTLIBOBJS = 
MAINT = #
MAKEINFO = ${SHELL} /home/install/netdata/netdata/missing makeinfo
MATH_CFLAGS = 
MATH_LIBS = -lm
MKDIR_P = /usr/bin/mkdir -p
NFACCT_CFLAGS = 
NFACCT_LIBS = 
OBJEXT = o
OPTIONAL_MATH_CLFAGS = 
OPTIONAL_MATH_LIBS = -lm
OPTIONAL_NFACCT_CLFAGS = 
OPTIONAL_NFACCT_LIBS = 
OPTIONAL_UUID_CLFAGS = -I/usr/include/uuid  
OPTIONAL_UUID_LIBS = -luuid  
OPTIONAL_ZLIB_CLFAGS =  
OPTIONAL_ZLIB_LIBS = -lz  
PACKAGE = netdata
PACKAGE_BUGREPORT = 
PACKAGE_NAME = netdata
PACKAGE_RPM_RELEASE = 
PACKAGE_RPM_VERSION = 1.4.1
PACKAGE_STRING = netdata 1.4.1_master
PACKAGE_TARNAME = netdata
PACKAGE_URL = 
PACKAGE_VERSION = 1.4.1_master
PATH_SEPARATOR = :
PKG_CONFIG = /usr/bin/pkg-config
PKG_CONFIG_LIBDIR = 
PKG_CONFIG_PATH = 
PTHREAD_CC = gcc
PTHREAD_CFLAGS = -pthread
PTHREAD_LIBS = 
SET_MAKE = 
SHELL = /bin/sh
SSE_CANDIDATE = 
STRIP = 
UUID_CFLAGS = -I/usr/include/uuid  
UUID_LIBS = -luuid  
VERSION = 1.4.1_master
ZLIB_CFLAGS =  
ZLIB_LIBS = -lz  
abs_builddir = /home/install/netdata/netdata/src
abs_srcdir = /home/install/netdata/netdata/src
abs_top_builddir = /home/install/netdata/netdata
abs_top_srcdir = /home/install/netdata/netdata
ac_ct_CC = gcc
am__include = include
am__leading_dot = .
am__quote = 
am__tar = $${TAR-tar} chof - "$$tardir"
am__untar = $${TAR-tar} xf -
ax_pthread_config = 
bindir = ${exec_prefix}/bin
build = x86_64-unknown-linux-gnu
build_alias = 
build_cpu = x86_64
build_os = linux-gnu
build_vendor = unknown
builddir = .
cachedir = $(localstatedir)/cache/netdata
chartsdir = $(libexecdir)/netdata/charts.d
configdir = $(sysconfdir)/netdata
datadir = ${datarootdir}
datarootdir = ${prefix}/share
docdir = ${datarootdir}/doc/${PACKAGE_TARNAME}
dvidir = ${docdir}
exec_prefix = ${prefix}
has_jemalloc = 0
has_tcmalloc = 0
host = x86_64-unknown-linux-gnu
host_alias = 
host_cpu = x86_64
host_os = linux-gnu
host_vendor = unknown
htmldir = ${docdir}
includedir = ${prefix}/include
infodir = ${datarootdir}/info
install_sh = ${SHELL} /home/install/netdata/netdata/install-sh
libdir = ${exec_prefix}/lib
libexecdir = ${exec_prefix}/libexec
localedir = ${datarootdir}/locale
localstatedir = /var
logdir = $(localstatedir)/log/netdata
mandir = ${datarootdir}/man
mkdir_p = $(MKDIR_P)
nodedir = $(libexecdir)/netdata/node.d
oldincludedir = /usr/include
pdfdir = ${docdir}
pluginsdir = $(libexecdir)/netdata/plugins.d
prefix = /usr
program_transform_name = s,x,x,
psdir = ${docdir}
pythondir = $(libexecdir)/netdata/python.d
registrydir = $(localstatedir)/lib/netdata/registry
sbindir = ${exec_prefix}/sbin
sharedstatedir = ${prefix}/com
srcdir = .
sysconfdir = /etc
target_alias = 
top_build_prefix = ../
top_builddir = ..
top_srcdir = ..
varlibdir = $(localstatedir)/lib/netdata
webdir = $(pkgdatadir)/web

#
# Copyright (C) 2015 Alon Bar-Lev <alon.barlev@gmail.com>
#
MAINTAINERCLEANFILES = $(srcdir)/Makefile.in
AM_CPPFLAGS = \
	-DVARLIB_DIR="\"$(varlibdir)\"" \
	-DCACHE_DIR="\"$(cachedir)\"" \
	-DCONFIG_DIR="\"$(configdir)\"" \
	-DLOG_DIR="\"$(logdir)\"" \
	-DPLUGINS_DIR="\"$(pluginsdir)\"" \
	-DRUN_DIR="\"$(localstatedir)/run/netdata\"" \
	-DWEB_DIR="\"$(webdir)\"" \
	$(NULL)

AM_CFLAGS = \
	$(OPTIONAL_MATH_CFLAGS) \
	$(OPTIONAL_NFACCT_CLFAGS) \
	$(OPTIONAL_ZLIB_CFLAGS) \
	$(OPTIONAL_UUID_CFLAGS) \
	$(NULL)

dist_cache_DATA = .keep
dist_varlib_DATA = .keep
dist_registry_DATA = .keep
dist_log_DATA = .keep
netdata_SOURCES = appconfig.c appconfig.h avl.c avl.h backends.c \
	backends.h clocks.c clocks.h common.c common.h daemon.c \
	daemon.h dictionary.c dictionary.h eval.c eval.h \
	global_statistics.c global_statistics.h health.c health.h \
	log.c log.h main.c main.h plugin_checks.c plugin_checks.h \
	plugin_idlejitter.c plugin_idlejitter.h plugin_nfacct.c \
	plugin_nfacct.h plugin_tc.c plugin_tc.h plugins_d.c \
	plugins_d.h popen.c popen.h sys_fs_cgroup.c procfile.c \
	procfile.h proc_self_mountinfo.c proc_self_mountinfo.h \
	registry.c registry.h rrd.c rrd.h rrd2json.c rrd2json.h \
	storage_number.c storage_number.h unit_test.c unit_test.h \
	url.c url.h web_buffer.c web_buffer.h web_buffer_svg.c \
	web_buffer_svg.h web_client.c web_client.h web_server.c \
	web_server.h $(NULL) $(am__append_1) $(am__append_2)
netdata_LDADD = \
	$(OPTIONAL_MATH_LIBS) \
	$(OPTIONAL_NFACCT_LIBS) \
	$(OPTIONAL_ZLIB_LIBS) \
	$(OPTIONAL_UUID_LIBS) \
	$(NULL)

apps_plugin_SOURCES = \
	apps_plugin.c \
	avl.c avl.h \
	clocks.c clocks.h \
	common.c common.h \
	log.c log.h \
	procfile.c procfile.h \
	web_buffer.c web_buffer.h \
	$(NULL)

all: all-am

.SUFFIXES:
.SUFFIXES: .c .o .obj
$(srcdir)/Makefile.in: # $(srcdir)/Makefile.am  $(am__configure_deps)
	@for dep in $?; do \
	  case '$(am__configure_deps)' in \
	    *$$dep*) \
	      ( cd $(top_builddir) && $(MAKE) $(AM_MAKEFLAGS) am--refresh ) \
	        && { if test -f $@; then exit 0; else break; fi; }; \
	      exit 1;; \
	  esac; \
	done; \
	echo ' cd $(top_srcdir) && $(AUTOMAKE) --gnu src/Makefile'; \
	$(am__cd) $(top_srcdir) && \
	  $(AUTOMAKE) --gnu src/Makefile
.PRECIOUS: Makefile
Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
	@case '$?' in \
	  *config.status*) \
	    cd $(top_builddir) && $(MAKE) $(AM_MAKEFLAGS) am--refresh;; \
	  *) \
	    echo ' cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@ $(am__depfiles_maybe)'; \
	    cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@ $(am__depfiles_maybe);; \
	esac;

$(top_builddir)/config.status: $(top_srcdir)/configure $(CONFIG_STATUS_DEPENDENCIES)
	cd $(top_builddir) && $(MAKE) $(AM_MAKEFLAGS) am--refresh

$(top_srcdir)/configure: # $(am__configure_deps)
	cd $(top_builddir) && $(MAKE) $(AM_MAKEFLAGS) am--refresh
$(ACLOCAL_M4): # $(am__aclocal_m4_deps)
	cd $(top_builddir) && $(MAKE) $(AM_MAKEFLAGS) am--refresh
$(am__aclocal_m4_deps):
install-pluginsPROGRAMS: $(plugins_PROGRAMS)
	@$(NORMAL_INSTALL)
	@list='$(plugins_PROGRAMS)'; test -n "$(pluginsdir)" || list=; \
	if test -n "$$list"; then \
	  echo " $(MKDIR_P) '$(DESTDIR)$(pluginsdir)'"; \
	  $(MKDIR_P) "$(DESTDIR)$(pluginsdir)" || exit 1; \
	fi; \
	for p in $$list; do echo "$$p $$p"; done | \
	sed 's/$(EXEEXT)$$//' | \
	while read p p1; do if test -f $$p \
	  ; then echo "$$p"; echo "$$p"; else :; fi; \
	done | \
	sed -e 'p;s,.*/,,;n;h' \
	    -e 's|.*|.|' \
	    -e 'p;x;s,.*/,,;s/$(EXEEXT)$$//;$(transform);s/$$/$(EXEEXT)/' | \
	sed 'N;N;N;s,\n, ,g' | \
	$(AWK) 'BEGIN { files["."] = ""; dirs["."] = 1 } \
	  { d=$$3; if (dirs[d] != 1) { print "d", d; dirs[d] = 1 } \
	    if ($$2 == $$4) files[d] = files[d] " " $$1; \
	    else { print "f", $$3 "/" $$4, $$1; } } \
	  END { for (d in files) print "f", d, files[d] }' | \
	while read type dir files; do \
	    if test "$$dir" = .; then dir=; else dir=/$$dir; fi; \
	    test -z "$$files" || { \
	      echo " $(INSTALL_PROGRAM_ENV) $(INSTALL_PROGRAM) $$files '$(DESTDIR)$(pluginsdir)$$dir'"; \
	      $(INSTALL_PROGRAM_ENV) $(INSTALL_PROGRAM) $$files "$(DESTDIR)$(pluginsdir)$$dir" || exit $$?; \
	    } \
	; done

uninstall-pluginsPROGRAMS:
	@$(NORMAL_UNINSTALL)
	@list='$(plugins_PROGRAMS)'; test -n "$(pluginsdir)" || list=; \
	files=`for p in $$list; do echo "$$p"; done | \
	  sed -e 'h;s,^.*/,,;s/$(EXEEXT)$$//;$(transform)' \
	      -e 's/$$/$(EXEEXT)/' \
	`; \
	test -n "$$list" || exit 0; \
	echo " ( cd '$(DESTDIR)$(pluginsdir)' && rm -f" $$files ")"; \
	cd "$(DESTDIR)$(pluginsdir)" && rm -f $$files

clean-pluginsPROGRAMS:
	-test -z "$(plugins_PROGRAMS)" || rm -f $(plugins_PROGRAMS)
install-sbinPROGRAMS: $(sbin_PROGRAMS)
	@$(NORMAL_INSTALL)
	@list='$(sbin_PROGRAMS)'; test -n "$(sbindir)" || list=; \
	if test -n "$$list"; then \
	  echo " $(MKDIR_P) '$(DESTDIR)$(sbindir)'"; \
	  $(MKDIR_P) "$(DESTDIR)$(sbindir)" || exit 1; \
	fi; \
	for p in $$list; do echo "$$p $$p"; done | \
	sed 's/$(EXEEXT)$$//' | \
	while read p p1; do if test -f $$p \
	  ; then echo "$$p"; echo "$$p"; else :; fi; \
	done | \
	sed -e 'p;s,.*/,,;n;h' \
	    -e 's|.*|.|' \
	    -e 'p;x;s,.*/,,;s/$(EXEEXT)$$//;$(transform);s/$$/$(EXEEXT)/' | \
	sed 'N;N;N;s,\n, ,g' | \
	$(AWK) 'BEGIN { files["."] = ""; dirs["."] = 1 } \
	  { d=$$3; if (dirs[d] != 1) { print "d", d; dirs[d] = 1 } \
	    if ($$2 == $$4) files[d] = files[d] " " $$1; \
	    else { print "f", $$3 "/" $$4, $$1; } } \
	  END { for (d in files) print "f", d, files[d] }' | \
	while read type dir files; do \
	    if test "$$dir" = .; then dir=; else dir=/$$dir; fi; \
	    test -z "$$files" || { \
	      echo " $(INSTALL_PROGRAM_ENV) $(INSTALL_PROGRAM) $$files '$(DESTDIR)$(sbindir)$$dir'"; \
	      $(INSTALL_PROGRAM_ENV) $(INSTALL_PROGRAM) $$files "$(DESTDIR)$(sbindir)$$dir" || exit $$?; \
	    } \
	; done

uninstall-sbinPROGRAMS:
	@$(NORMAL_UNINSTALL)
	@list='$(sbin_PROGRAMS)'; test -n "$(sbindir)" || list=; \
	files=`for p in $$list; do echo "$$p"; done | \
	  sed -e 'h;s,^.*/,,;s/$(EXEEXT)$$//;$(transform)' \
	      -e 's/$$/$(EXEEXT)/' \
	`; \
	test -n "$$list" || exit 0; \
	echo " ( cd '$(DESTDIR)$(sbindir)' && rm -f" $$files ")"; \
	cd "$(DESTDIR)$(sbindir)" && rm -f $$files

clean-sbinPROGRAMS:
	-test -z "$(sbin_PROGRAMS)" || rm -f $(sbin_PROGRAMS)

apps.plugin$(EXEEXT): $(apps_plugin_OBJECTS) $(apps_plugin_DEPENDENCIES) $(EXTRA_apps_plugin_DEPENDENCIES) 
	@rm -f apps.plugin$(EXEEXT)
	$(AM_V_CCLD)$(LINK) $(apps_plugin_OBJECTS) $(apps_plugin_LDADD) $(LIBS)

netdata$(EXEEXT): $(netdata_OBJECTS) $(netdata_DEPENDENCIES) $(EXTRA_netdata_DEPENDENCIES) 
	@rm -f netdata$(EXEEXT)
	$(AM_V_CCLD)$(LINK) $(netdata_OBJECTS) $(netdata_LDADD) $(LIBS)

mostlyclean-compile:
	-rm -f *.$(OBJEXT)

distclean-compile:
	-rm -f *.tab.c

include ./$(DEPDIR)/appconfig.Po
include ./$(DEPDIR)/apps_plugin.Po
include ./$(DEPDIR)/avl.Po
include ./$(DEPDIR)/backends.Po
include ./$(DEPDIR)/clocks.Po
include ./$(DEPDIR)/common.Po
include ./$(DEPDIR)/daemon.Po
include ./$(DEPDIR)/dictionary.Po
include ./$(DEPDIR)/eval.Po
include ./$(DEPDIR)/freebsd_sysctl.Po
include ./$(DEPDIR)/global_statistics.Po
include ./$(DEPDIR)/health.Po
include ./$(DEPDIR)/ipc.Po
include ./$(DEPDIR)/log.Po
include ./$(DEPDIR)/main.Po
include ./$(DEPDIR)/plugin_checks.Po
include ./$(DEPDIR)/plugin_freebsd.Po
include ./$(DEPDIR)/plugin_idlejitter.Po
include ./$(DEPDIR)/plugin_nfacct.Po
include ./$(DEPDIR)/plugin_proc.Po
include ./$(DEPDIR)/plugin_tc.Po
include ./$(DEPDIR)/plugins_d.Po
include ./$(DEPDIR)/popen.Po
include ./$(DEPDIR)/proc_diskstats.Po
include ./$(DEPDIR)/proc_interrupts.Po
include ./$(DEPDIR)/proc_loadavg.Po
include ./$(DEPDIR)/proc_meminfo.Po
include ./$(DEPDIR)/proc_net_dev.Po
include ./$(DEPDIR)/proc_net_ip_vs_stats.Po
include ./$(DEPDIR)/proc_net_netstat.Po
include ./$(DEPDIR)/proc_net_rpc_nfs.Po
include ./$(DEPDIR)/proc_net_rpc_nfsd.Po
include ./$(DEPDIR)/proc_net_snmp.Po
include ./$(DEPDIR)/proc_net_snmp6.Po
include ./$(DEPDIR)/proc_net_softnet_stat.Po
include ./$(DEPDIR)/proc_net_stat_conntrack.Po
include ./$(DEPDIR)/proc_net_stat_synproxy.Po
include ./$(DEPDIR)/proc_self_mountinfo.Po
include ./$(DEPDIR)/proc_softirqs.Po
include ./$(DEPDIR)/proc_stat.Po
include ./$(DEPDIR)/proc_sys_kernel_random_entropy_avail.Po
include ./$(DEPDIR)/proc_vmstat.Po
include ./$(DEPDIR)/procfile.Po
include ./$(DEPDIR)/registry.Po
include ./$(DEPDIR)/rrd.Po
include ./$(DEPDIR)/rrd2json.Po
include ./$(DEPDIR)/storage_number.Po
include ./$(DEPDIR)/sys_fs_cgroup.Po
include ./$(DEPDIR)/sys_kernel_mm_ksm.Po
include ./$(DEPDIR)/unit_test.Po
include ./$(DEPDIR)/url.Po
include ./$(DEPDIR)/web_buffer.Po
include ./$(DEPDIR)/web_buffer_svg.Po
include ./$(DEPDIR)/web_client.Po
include ./$(DEPDIR)/web_server.Po

.c.o:
	$(AM_V_CC)$(COMPILE) -MT $@ -MD -MP -MF $(DEPDIR)/$*.Tpo -c -o $@ $<
	$(AM_V_at)$(am__mv) $(DEPDIR)/$*.Tpo $(DEPDIR)/$*.Po
#	$(AM_V_CC)source='$<' object='$@' libtool=no \
#	DEPDIR=$(DEPDIR) $(CCDEPMODE) $(depcomp) \
#	$(AM_V_CC_no)$(COMPILE) -c $<

.c.obj:
	$(AM_V_CC)$(COMPILE) -MT $@ -MD -MP -MF $(DEPDIR)/$*.Tpo -c -o $@ `$(CYGPATH_W) '$<'`
	$(AM_V_at)$(am__mv) $(DEPDIR)/$*.Tpo $(DEPDIR)/$*.Po
#	$(AM_V_CC)source='$<' object='$@' libtool=no \
#	DEPDIR=$(DEPDIR) $(CCDEPMODE) $(depcomp) \
#	$(AM_V_CC_no)$(COMPILE) -c `$(CYGPATH_W) '$<'`
install-dist_cacheDATA: $(dist_cache_DATA)
	@$(NORMAL_INSTALL)
	@list='$(dist_cache_DATA)'; test -n "$(cachedir)" || list=; \
	if test -n "$$list"; then \
	  echo " $(MKDIR_P) '$(DESTDIR)$(cachedir)'"; \
	  $(MKDIR_P) "$(DESTDIR)$(cachedir)" || exit 1; \
	fi; \
	for p in $$list; do \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  echo "$$d$$p"; \
	done | $(am__base_list) | \
	while read files; do \
	  echo " $(INSTALL_DATA) $$files '$(DESTDIR)$(cachedir)'"; \
	  $(INSTALL_DATA) $$files "$(DESTDIR)$(cachedir)" || exit $$?; \
	done

uninstall-dist_cacheDATA:
	@$(NORMAL_UNINSTALL)
	@list='$(dist_cache_DATA)'; test -n "$(cachedir)" || list=; \
	files=`for p in $$list; do echo $$p; done | sed -e 's|^.*/||'`; \
	dir='$(DESTDIR)$(cachedir)'; $(am__uninstall_files_from_dir)
install-dist_logDATA: $(dist_log_DATA)
	@$(NORMAL_INSTALL)
	@list='$(dist_log_DATA)'; test -n "$(logdir)" || list=; \
	if test -n "$$list"; then \
	  echo " $(MKDIR_P) '$(DESTDIR)$(logdir)'"; \
	  $(MKDIR_P) "$(DESTDIR)$(logdir)" || exit 1; \
	fi; \
	for p in $$list; do \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  echo "$$d$$p"; \
	done | $(am__base_list) | \
	while read files; do \
	  echo " $(INSTALL_DATA) $$files '$(DESTDIR)$(logdir)'"; \
	  $(INSTALL_DATA) $$files "$(DESTDIR)$(logdir)" || exit $$?; \
	done

uninstall-dist_logDATA:
	@$(NORMAL_UNINSTALL)
	@list='$(dist_log_DATA)'; test -n "$(logdir)" || list=; \
	files=`for p in $$list; do echo $$p; done | sed -e 's|^.*/||'`; \
	dir='$(DESTDIR)$(logdir)'; $(am__uninstall_files_from_dir)
install-dist_registryDATA: $(dist_registry_DATA)
	@$(NORMAL_INSTALL)
	@list='$(dist_registry_DATA)'; test -n "$(registrydir)" || list=; \
	if test -n "$$list"; then \
	  echo " $(MKDIR_P) '$(DESTDIR)$(registrydir)'"; \
	  $(MKDIR_P) "$(DESTDIR)$(registrydir)" || exit 1; \
	fi; \
	for p in $$list; do \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  echo "$$d$$p"; \
	done | $(am__base_list) | \
	while read files; do \
	  echo " $(INSTALL_DATA) $$files '$(DESTDIR)$(registrydir)'"; \
	  $(INSTALL_DATA) $$files "$(DESTDIR)$(registrydir)" || exit $$?; \
	done

uninstall-dist_registryDATA:
	@$(NORMAL_UNINSTALL)
	@list='$(dist_registry_DATA)'; test -n "$(registrydir)" || list=; \
	files=`for p in $$list; do echo $$p; done | sed -e 's|^.*/||'`; \
	dir='$(DESTDIR)$(registrydir)'; $(am__uninstall_files_from_dir)
install-dist_varlibDATA: $(dist_varlib_DATA)
	@$(NORMAL_INSTALL)
	@list='$(dist_varlib_DATA)'; test -n "$(varlibdir)" || list=; \
	if test -n "$$list"; then \
	  echo " $(MKDIR_P) '$(DESTDIR)$(varlibdir)'"; \
	  $(MKDIR_P) "$(DESTDIR)$(varlibdir)" || exit 1; \
	fi; \
	for p in $$list; do \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  echo "$$d$$p"; \
	done | $(am__base_list) | \
	while read files; do \
	  echo " $(INSTALL_DATA) $$files '$(DESTDIR)$(varlibdir)'"; \
	  $(INSTALL_DATA) $$files "$(DESTDIR)$(varlibdir)" || exit $$?; \
	done

uninstall-dist_varlibDATA:
	@$(NORMAL_UNINSTALL)
	@list='$(dist_varlib_DATA)'; test -n "$(varlibdir)" || list=; \
	files=`for p in $$list; do echo $$p; done | sed -e 's|^.*/||'`; \
	dir='$(DESTDIR)$(varlibdir)'; $(am__uninstall_files_from_dir)

ID: $(am__tagged_files)
	$(am__define_uniq_tagged_files); mkid -fID $$unique
tags: tags-am
TAGS: tags

tags-am: $(TAGS_DEPENDENCIES) $(am__tagged_files)
	set x; \
	here=`pwd`; \
	$(am__define_uniq_tagged_files); \
	shift; \
	if test -z "$(ETAGS_ARGS)$$*$$unique"; then :; else \
	  test -n "$$unique" || unique=$$empty_fix; \
	  if test $$# -gt 0; then \
	    $(ETAGS) $(ETAGSFLAGS) $(AM_ETAGSFLAGS) $(ETAGS_ARGS) \
	      "$$@" $$unique; \
	  else \
	    $(ETAGS) $(ETAGSFLAGS) $(AM_ETAGSFLAGS) $(ETAGS_ARGS) \
	      $$unique; \
	  fi; \
	fi
ctags: ctags-am

CTAGS: ctags
ctags-am: $(TAGS_DEPENDENCIES) $(am__tagged_files)
	$(am__define_uniq_tagged_files); \
	test -z "$(CTAGS_ARGS)$$unique" \
	  || $(CTAGS) $(CTAGSFLAGS) $(AM_CTAGSFLAGS) $(CTAGS_ARGS) \
	     $$unique

GTAGS:
	here=`$(am__cd) $(top_builddir) && pwd` \
	  && $(am__cd) $(top_srcdir) \
	  && gtags -i $(GTAGS_ARGS) "$$here"
cscopelist: cscopelist-am

cscopelist-am: $(am__tagged_files)
	list='$(am__tagged_files)'; \
	case "$(srcdir)" in \
	  [\\/]* | ?:[\\/]*) sdir="$(srcdir)" ;; \
	  *) sdir=$(subdir)/$(srcdir) ;; \
	esac; \
	for i in $$list; do \
	  if test -f "$$i"; then \
	    echo "$(subdir)/$$i"; \
	  else \
	    echo "$$sdir/$$i"; \
	  fi; \
	done >> $(top_builddir)/cscope.files

distclean-tags:
	-rm -f TAGS ID GTAGS GRTAGS GSYMS GPATH tags

distdir: $(DISTFILES)
	@srcdirstrip=`echo "$(srcdir)" | sed 's/[].[^$$\\*]/\\\\&/g'`; \
	topsrcdirstrip=`echo "$(top_srcdir)" | sed 's/[].[^$$\\*]/\\\\&/g'`; \
	list='$(DISTFILES)'; \
	  dist_files=`for file in $$list; do echo $$file; done | \
	  sed -e "s|^$$srcdirstrip/||;t" \
	      -e "s|^$$topsrcdirstrip/|$(top_builddir)/|;t"`; \
	case $$dist_files in \
	  */*) $(MKDIR_P) `echo "$$dist_files" | \
			   sed '/\//!d;s|^|$(distdir)/|;s,/[^/]*$$,,' | \
			   sort -u` ;; \
	esac; \
	for file in $$dist_files; do \
	  if test -f $$file || test -d $$file; then d=.; else d=$(srcdir); fi; \
	  if test -d $$d/$$file; then \
	    dir=`echo "/$$file" | sed -e 's,/[^/]*$$,,'`; \
	    if test -d "$(distdir)/$$file"; then \
	      find "$(distdir)/$$file" -type d ! -perm -700 -exec chmod u+rwx {} \;; \
	    fi; \
	    if test -d $(srcdir)/$$file && test $$d != $(srcdir); then \
	      cp -fpR $(srcdir)/$$file "$(distdir)$$dir" || exit 1; \
	      find "$(distdir)/$$file" -type d ! -perm -700 -exec chmod u+rwx {} \;; \
	    fi; \
	    cp -fpR $$d/$$file "$(distdir)$$dir" || exit 1; \
	  else \
	    test -f "$(distdir)/$$file" \
	    || cp -p $$d/$$file "$(distdir)/$$file" \
	    || exit 1; \
	  fi; \
	done
check-am: all-am
check: check-am
all-am: Makefile $(PROGRAMS) $(DATA)
installdirs:
	for dir in "$(DESTDIR)$(pluginsdir)" "$(DESTDIR)$(sbindir)" "$(DESTDIR)$(cachedir)" "$(DESTDIR)$(logdir)" "$(DESTDIR)$(registrydir)" "$(DESTDIR)$(varlibdir)"; do \
	  test -z "$$dir" || $(MKDIR_P) "$$dir"; \
	done
install: install-am
install-exec: install-exec-am
install-data: install-data-am
uninstall: uninstall-am

install-am: all-am
	@$(MAKE) $(AM_MAKEFLAGS) install-exec-am install-data-am

installcheck: installcheck-am
install-strip:
	if test -z '$(STRIP)'; then \
	  $(MAKE) $(AM_MAKEFLAGS) INSTALL_PROGRAM="$(INSTALL_STRIP_PROGRAM)" \
	    install_sh_PROGRAM="$(INSTALL_STRIP_PROGRAM)" INSTALL_STRIP_FLAG=-s \
	      install; \
	else \
	  $(MAKE) $(AM_MAKEFLAGS) INSTALL_PROGRAM="$(INSTALL_STRIP_PROGRAM)" \
	    install_sh_PROGRAM="$(INSTALL_STRIP_PROGRAM)" INSTALL_STRIP_FLAG=-s \
	    "INSTALL_PROGRAM_ENV=STRIPPROG='$(STRIP)'" install; \
	fi
mostlyclean-generic:

clean-generic:

distclean-generic:
	-test -z "$(CONFIG_CLEAN_FILES)" || rm -f $(CONFIG_CLEAN_FILES)
	-test . = "$(srcdir)" || test -z "$(CONFIG_CLEAN_VPATH_FILES)" || rm -f $(CONFIG_CLEAN_VPATH_FILES)

maintainer-clean-generic:
	@echo "This command is intended for maintainers to use"
	@echo "it deletes files that may require special tools to rebuild."
	-test -z "$(MAINTAINERCLEANFILES)" || rm -f $(MAINTAINERCLEANFILES)
clean: clean-am

clean-am: clean-generic clean-pluginsPROGRAMS clean-sbinPROGRAMS \
	mostlyclean-am

distclean: distclean-am
	-rm -rf ./$(DEPDIR)
	-rm -f Makefile
distclean-am: clean-am distclean-compile distclean-generic \
	distclean-tags

dvi: dvi-am

dvi-am:

html: html-am

html-am:

info: info-am

info-am:

install-data-am: install-dist_cacheDATA install-dist_logDATA \
	install-dist_registryDATA install-dist_varlibDATA \
	install-pluginsPROGRAMS
	@$(NORMAL_INSTALL)
	$(MAKE) $(AM_MAKEFLAGS) install-data-hook
install-dvi: install-dvi-am

install-dvi-am:

install-exec-am: install-sbinPROGRAMS

install-html: install-html-am

install-html-am:

install-info: install-info-am

install-info-am:

install-man:

install-pdf: install-pdf-am

install-pdf-am:

install-ps: install-ps-am

install-ps-am:

installcheck-am:

maintainer-clean: maintainer-clean-am
	-rm -rf ./$(DEPDIR)
	-rm -f Makefile
maintainer-clean-am: distclean-am maintainer-clean-generic

mostlyclean: mostlyclean-am

mostlyclean-am: mostlyclean-compile mostlyclean-generic

pdf: pdf-am

pdf-am:

ps: ps-am

ps-am:

uninstall-am: uninstall-dist_cacheDATA uninstall-dist_logDATA \
	uninstall-dist_registryDATA uninstall-dist_varlibDATA \
	uninstall-pluginsPROGRAMS uninstall-sbinPROGRAMS

.MAKE: install-am install-data-am install-strip

.PHONY: CTAGS GTAGS TAGS all all-am check check-am clean clean-generic \
	clean-pluginsPROGRAMS clean-sbinPROGRAMS cscopelist-am ctags \
	ctags-am distclean distclean-compile distclean-generic \
	distclean-tags distdir dvi dvi-am html html-am info info-am \
	install install-am install-data install-data-am \
	install-data-hook install-dist_cacheDATA install-dist_logDATA \
	install-dist_registryDATA install-dist_varlibDATA install-dvi \
	install-dvi-am install-exec install-exec-am install-html \
	install-html-am install-info install-info-am install-man \
	install-pdf install-pdf-am install-pluginsPROGRAMS install-ps \
	install-ps-am install-sbinPROGRAMS install-strip installcheck \
	installcheck-am installdirs maintainer-clean \
	maintainer-clean-generic mostlyclean mostlyclean-compile \
	mostlyclean-generic pdf pdf-am ps ps-am tags tags-am uninstall \
	uninstall-am uninstall-dist_cacheDATA uninstall-dist_logDATA \
	uninstall-dist_registryDATA uninstall-dist_varlibDATA \
	uninstall-pluginsPROGRAMS uninstall-sbinPROGRAMS


install-data-hook:
	if [ `id -u` == 0 ]; then \
		chown root '$(DESTDIR)$(pluginsdir)/apps.plugin' && \
		chmod 0755 '$(DESTDIR)$(pluginsdir)/apps.plugin' && \
		( setcap cap_dac_read_search,cap_sys_ptrace+ep '$(DESTDIR)$(pluginsdir)/apps.plugin' || \
		  chmod 4755 '$(DESTDIR)$(pluginsdir)/apps.plugin' ); \
	else \
		echo; \
		echo "ATTENTION"; \
		echo; \
		echo "$(pluginsdir)/apps.plugin requires escalated capabilities:"; \
		echo "sudo chown root '$(DESTDIR)$(pluginsdir)/apps.plugin'"; \
		echo "sudo chmod 0755 '$(DESTDIR)$(pluginsdir)/apps.plugin'"; \
		echo "sudo setcap cap_dac_read_search,cap_sys_ptrace+ep '$(DESTDIR)$(pluginsdir)/apps.plugin'"; \
		echo; \
	fi

# Tell versions [3.59,3.63) of GNU make to not export all variables.
# Otherwise a system limit (for SysV at least) may be exceeded.
.NOEXPORT:
