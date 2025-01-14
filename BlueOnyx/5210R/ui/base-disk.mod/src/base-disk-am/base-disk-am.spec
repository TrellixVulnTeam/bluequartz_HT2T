Summary: Binaries and scripts used by Active Monitor for base-disk
Name: base-disk-am
Version: 1.2.0
Release: 0BX03%{?dist}
Vendor: %{vendor}
License: Sun modified BSD
Group: System Environment/BlueOnyx
Source: base-disk-am.tar.gz
BuildRoot: /tmp/%{name}
Requires: perl-Unix-ConfigFile >= 0.06-SOL1
Requires: perl-MIME-Lite >= 3.023-2
Requires: perl-Email-Date-Format >= 1.002-1

%prep
%setup -n %{name}

%build
make all

%install
make PREFIX=$RPM_BUILD_ROOT install

%files
/usr/sausalito/swatch/bin/*
/usr/sausalito/sbin/*

%description
This package contains a number of binaries and scripts used by the Active
Monitor subsystem to monitor services provided by the base-disk module.  

%changelog

* Fri Sep 15 2017 Michael Stauber <mstauber@solarspeed.net> 1.2.0-0BX03
- Modified src/base-disk-am/get_quotas.pl to only look under /home/.sites/ for
  the Vsites, as this is the only place where we really support them to be at
  this time. This is faster and more reliable.

* Mon Oct 13 2014 Michael Stauber <mstauber@solarspeed.net> 1.2.0-0BX02
- Modified src/base-disk-am/get_quotas.pl to add debugging. Also added a check that if
  there is only one disk (think OpenVZ, Cloud or similar) which is mounted, is 'internal'
  and has the flag 'isHomePartition', then we use it, but check for the sites on /home
  instead. This eleminates the last vestiges of BlueOnyx really needing a /home
  partition. This is the one work around that eleminates the need for all the other
  duct-tape measures in this regards. Still works if the other usual band-aids are
  already applied on a box.

* Thu Dec 05 2013 Michael Stauber <mstauber@solarspeed.net> 1.2.0-0BX01
- Modified am_disk.pl to allow mailing in 'ja_JP' again. Now that our Japanese locales are
  in UTF-8 it might finally work.

* Thu Apr 05 2012 Michael Stauber <mstauber@solarspeed.net> 1.1.0-15BX25
- Modified am_disk.pl to set correct locale for Emails that it generates. Required changes
  after massive UTF-8 update, as it was still sending in 'ISO-8859-1' format.

* Tue Oct 04 2011 Michael Stauber <mstauber@solarspeed.net> 1.1.0-15BX24
- Updated am_disk.pl again to make output generation of user-over-quota-mails more readable.

* Fri Sep 28 2011 Michael Stauber <mstauber@solarspeed.net> 1.1.0-15BX23
- Updated am_disk.pl again to hard code Japanese emails to 'en' or 'en_US' but with
  some more respect to the platform specific locales.
- Added am_disk.pl-japanese-test outside the source tree. Contains a not yet working
  test-version which uses perl-MIME-Lite-TT-Japanese instead of MIME:Lite.

* Fri Sep 28 2011 Michael Stauber <mstauber@solarspeed.net> 1.1.0-15BX22
- Updated am_disk.pl to use MIME::Lite for mailings to admin and users.
- Updated am_disk.pl to prepend hostname if it emails admin on over-quota users. 
  It also adds the FQDN of the user to the mail, so that it is easier to see which 
  site the user belongs to. Because without that the info is often useless.
- Updated requirements to add perl-MIME-Lite and perl-Email-Date-Format

* Mon Nov 15 2010 Michael Stauber <mstauber@solarspeed.net> 1.1.0-15BX21
- Updated am_disk.pl to check if /home/.sites/ exists before it tries to open it blindly.
- Otherwise Swatch throws errors on fresh installed systems until the 1st site gets added.

* Mon Nov 15 2010 Taco Scargo <taco@scargo.nl> 1.1.0-15BX20
- Fixed am_disk.pl as users did not receive quota warning e-mails

* Sun Jun 06 2010 Michael Stauber <mstauber@solarspeed.net> 1.1.0-15BX19
- On CentOS6 user 'nfsnobody' has UID > 500, so we need to ignore him as well.

* Wed Dec 03 2008 Michael Stauber <mstauber@solarspeed.net> 1.1.0-15BQ18
- Rebuilt for BlueOnyx.

* Mon Dec 01 2008 Michael Stauber <mstauber@solarspeed.net> 1.1.0-15BQ17
- Another small fix in get_quota.pl: SITExx-logs users are no longer reported.

* Mon Dec 01 2008 Michael Stauber <mstauber@solarspeed.net> 1.1.0-15BQ16
- Small fix in get_quota.pl. Replaced 'lt' with '<'. One day I'll learn to avoid this kind of mistake.

* Thu Nov 27 2008 Michael Stauber <mstauber@solarspeed.net> 1.1.0-15BQ15
- Since all users are no longer in the 'users' group, quota info couldn't be obtained for sites AND users.
- Updated get_quota.pl to now use UnixConfigFile Perl Module to determine group on demand.
- Streamlined user and group parsing routines in get_quota using Unix::PasswdFile.
- Added requirement for perl-Unix-ConfigFile >= 0.06-SOL1 to specfile.
- Major version bump to 1.1.0 to make clear that this is a radical modify, although 100% compatible to the outside.

* Tue Mar 04 2008 Michael Stauber <mstauber@solarspeed.net> 1.0.1-15BQ14
- Fixed am_disk.pl again. Set safe defaul for $dev if its undefined.

* Sat Mar 01 2008 Michael Stauber <mstauber@solarspeed.net> 1.0.1-15BQ13
- Updated am_disk.pl to address cases where $dev is undefined.

* Sun Feb 03 2008 Hisao SHIBUYA <shibuya@bluequartz.org> 1.0.1-15BQ12
- add sign to the package.

* Thu Apr 13 2006 Hisao SHIBUYA <shibuya@alpha.or.jp> 1.0.1-15BQ11
- modify am_disk.pl to fix the issue when gid is NULL by Brian.

* Thu Mar 30 2006 Hisao SHIBUYA <shibuya@alpha.or.jp> 1.0.1-15BQ10
- The am_disk.pl supports LVM partition.

* Mon Oct 31 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 1.0.1-15BQ9
- add dist macro for release.

* Fri Oct 21 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 1.0.1-15BQ8
- use vendor macro for Vendor tag.

* Fri Oct 21 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 1.0.1-15BQ7
- remove Serial tag.

* Fri Aug 12 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 1.0.1-15BQ6
- add serial number.

* Thu Aug 11 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 1.0.1-15BQ5
- clean up spec file.

* Tue May 17 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 1.0.1-15BQ4
- modified am_disk.pl. 

* Tue Apr 26 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 1.0.1-15BQ3
- The am_disk.pl supports LVM partition.

* Sat Dec 25 2004 Hisao SHIBUYA <shibuya@alpha.or.jp> 1.0.1-15BQ2
- modified get_quotas.pl to exclude 'games' user.

* Wed Mar 10 2004 Hisao SHIBUYA <shibuya@alpha.or.jp> 1.0.1-15BQ1
- build for Blue Quartz
- fix disk active monitor alert

* Tue Jun 20 2000 Tim Hockin <thockin@cobalt.com>
- initial spec file

