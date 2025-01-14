#!/bin/bash

# Make sure 'ifup-routes' and 'ifup' have our handler provisions:
/usr/sausalito/constructor/base/network/10_fix_ifup.pl

# Make sure our IPs are all bound and our routes are all OK:
#/usr/sausalito/handlers/base/network/change_route.pl -c 2 >/dev/null 2>&1 || :

# Fix PHP Session dir GID if needed:
if [ -d "/var/lib/php/session" ];then
    SESSPERMS=`ls -la /var/lib/php|grep session|awk '{print $1}'`
    if [ $SESSPERMS != "drwxrwxrwx" ];then
        chmod 777 /var/lib/php/session
    fi
fi

# Remove the OS supplied YUM autoupdater (if present), as we bring our own:
if [ -f /etc/cron.daily/yum-autoupdate ] ; then
    rm -f /etc/cron.daily/yum-autoupdate
fi

# The CD-Installer of BlueOnyx brings /usr/bin/fix-httpd-log-dir aboard, but
# it might not be executable:
if [ -f /usr/bin/fix-httpd-log-dir ]; then
    chmod 755 /usr/bin/fix-httpd-log-dir
fi

# While we are at it, delete the default CentOS welcome page:
if [ -f /etc/httpd/conf.d/welcome.conf ]; then
        /bin/rm -f /etc/httpd/conf.d/welcome.conf
fi

# Also delete /etc/httpd/conf.d/manual.conf:
if [ -f /etc/httpd/conf.d/manual.conf ]; then
        /bin/rm -f /etc/httpd/conf.d/manual.conf
fi

# Also remove server.conf
if [ -f /etc/httpd/conf.d/server.conf ]; then
        /bin/rm -f /etc/httpd/conf.d/server.conf
fi

# Fix nss.conf if present:
if [ -f /etc/httpd/conf.d/nss.conf ]; then
NUMNSS=`/bin/cat /etc/httpd/conf.d/nss.conf | /bin/grep NSSEnforceValidCerts | /usr/bin/wc -l`
    if [ $NUMNSS = "0" ]; then
        sed -i "s/^NSSSession3CacheTimeout 86400/NSSSession3CacheTimeout 86400\\nNSSEnforceValidCerts off/g" /etc/httpd/conf.d/nss.conf
    fi
fi

# Run Passive Monitor Support Account watcher (if present):
if [ -f /usr/sausalito/swatch/bin/am_support.pl ]; then
        /usr/sausalito/swatch/bin/am_support.pl
fi

# Fix DBUS issue if /var/run/dbus/system_bus_socket no longer is a Symlink:
#if [ -f /usr/bin/systemctl ];then
#    if [ ! -L /var/run/dbus/system_bus_socket ];then
#        systemctl stop dbus
#        rm /var/run/dbus/system_bus_socket
#        ln -s /run/dbus/system_bus_socket /var/run/dbus/system_bus_socket
#        systemctl start dbus
#    fi
#fi

# Fix Imagetragick issue:
if [ -f /etc/ImageMagick/policy.xml ];then
    ITRAGIC=`cat /etc/ImageMagick/policy.xml |grep TEXT|wc -l`
    # We need to apply the fix:
    if [ $ITRAGIC -eq 0 ]; then
        # Do we have a good copy? We should!
        if [ -f /etc/ImageMagick/policy.xml.fixed ];then
            cp /etc/ImageMagick/policy.xml.fixed /etc/ImageMagick/policy.xml
        fi
    fi
fi

# CentOS 7 Snafu-fix:
if [ -f /usr/lib/systemd/system/auditd.service ];then
    AUDITD=`ls -la /usr/lib/systemd/system/auditd.service|grep "^-rw-r-----"|wc -l`
    if [ $AUDITD -eq 1 ]; then
        chmod 644 /usr/lib/systemd/system/auditd.service
    fi
fi

# Create Dovecot SSL parameters (DH-stuff) if it's missing:
if [ ! -f /var/lib/dovecot/ssl-parameters.dat ]; then
    /usr/libexec/dovecot/ssl-params &>/dev/null
fi

# End:
exit

