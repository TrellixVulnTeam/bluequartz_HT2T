#!/usr/bin/perl -w -I/usr/sausalito/perl -I.
# $Id: set_httpd_alias_perms.pl So 08 Sep 2013 02:11:49 CEST mstauber $
#
# This constructor sets the GID and permissions on the databases in /etc/httpd/alias/
# to the new requested standards as required by the mod_nss introduced by CentOS-5.6:

# Fix GID and permissions one /etc/httpd/alias/ for new mod_nss:
if (-e "/etc/httpd/alias/cert8.db") {
        system('find /etc/httpd/alias -user root -name "*.db" -exec /bin/chgrp apache {} \;');
        system('find /etc/httpd/alias -user root -name "*.db" -exec /bin/chmod g+r {} \;');   
}

# While we are at it, delete the default CentOS welcome page:
if (-e "/etc/httpd/conf.d/welcome.conf") {
	system('/bin/rm -f /etc/httpd/conf.d/welcome.conf');
}

# Also delete /etc/httpd/conf.d/manual.conf:
if (-e "/etc/httpd/conf.d/manual.conf") {
	system('/bin/rm -f /etc/httpd/conf.d/manual.conf');
}

# Also remove server.conf
if (-e "/etc/httpd/conf.d/server.conf") {
	system('/bin/rm -f /etc/httpd/conf.d/server.conf');
}

# A lot of BX servers have ImageMagick installed, which in turn installs and activates the avahi-daemon.
# This daemon is not really needed and certainly should not be running. Hence we stop it and turn it off:
if (-e "/etc/init.d/avahi-daemon") {
	system('/etc/init.d/avahi-daemon stop >/dev/null 2>&1');
	system('/sbin/chkconfig --level 2345 avahi-daemon off');
}

exit(0);

