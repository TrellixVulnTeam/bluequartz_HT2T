Summary: Scripts and misc utils used by base-scandetection
Name: base-scandetection-misc
Version: 1.0
Release: 30
Copyright: Sun Microsystems 2001
Group: Utils
Source: base-scandetection-misc.tar.gz
BuildRoot: /tmp/%{name}
BuildArchitectures: noarch

%description
This package contains miscelanous tools and scripts for the Cobalt scandetection package

%prep
%setup

%build

%install
mkdir -p ${RPM_BUILD_ROOT}/etc/
cp -r lcd.d ${RPM_BUILD_ROOT}/etc/
mkdir -p ${RPM_BUILD_ROOT}/etc/rc.d/
cp -r init.d ${RPM_BUILD_ROOT}/etc/rc.d/
mkdir -p ${RPM_BUILD_ROOT}/usr/sausalito/swatch/bin
cp -r swatch ${RPM_BUILD_ROOT}/usr/sausalito/
cp -r scandetection ${RPM_BUILD_ROOT}/etc/
mkdir -p ${RPM_BUILD_ROOT}/usr/sbin/
cp paflogd ${RPM_BUILD_ROOT}/usr/sbin/
cp pafalertd ${RPM_BUILD_ROOT}/usr/sbin/


%post 
/sbin/chkconfig --level 345 scandetection on

%preun
/sbin/chkconfig --level 345 scandetection off

%clean
rm -rf ${RPM_BUILD_ROOT}



%files
/usr/sbin/paflogd
/usr/sbin/pafalertd
%dir /etc/lcd.d
%dir /etc/lcd.d/10main.m
%dir /etc/lcd.d/10main.m/70CLEAR_SCANDETECTION.s
/etc/lcd.d/10main.m/70CLEAR_SCANDETECTION.s/10clear_portscan
%attr(0700,-,-) /etc/lcd.d/10main.m/70CLEAR_SCANDETECTION.s/string
%dir /etc/rc.d
%dir /etc/rc.d/init.d
/etc/rc.d/init.d/scandetection
/usr/sausalito/swatch/bin/am_scandetection.sh
%dir /etc/scandetection
/etc/scandetection/scandetection.fwall
/etc/scandetection/scandetection.conf
