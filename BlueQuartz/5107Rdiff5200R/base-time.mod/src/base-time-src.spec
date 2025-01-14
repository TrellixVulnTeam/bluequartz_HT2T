Summary: Miscellaneous parts of base-time.mod.
Name: base-time-src
Version: 1.0.1
Release: 3BQ9%{?dist}
Vendor: %{vendor}
License: Sun modified BSD
Group: System Environment/BlueQuartz
Source: base-time-src.tar.gz
BuildRoot: /var/tmp/base-time-src

%description
This builds the src directory for base-time.

%prep
%setup -n src

%build
make

%install
rm -rf $RPM_BUILD_ROOT
PREFIX=$RPM_BUILD_ROOT make install

%files
%defattr(-,root,root)
%attr(0700,root,root)/usr/sausalito/sbin/setTime
%attr(0700,root,root)/usr/sausalito/sbin/epochdate

%changelog
* Wed Mar 10 2010 Hisao SHIBUYA <shibuya@bluequartz.org> 1.0.1-3BQ9
- remove .svn directory from rpm package.

* Sun Feb 03 2008 Hisao SHIBUYA <shibuya@bluequartz.org> 1.0.1-3BQ8
- add sign to the package.

* Mon Nov 14 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 1.0.1-3BQ7
- use PACKAGE_DIR instead of /usr/src/redhat.

* Mon Oct 31 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 1.0.1-3BQ6
- add dist macro for release.

* Fri Oct 21 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 1.0.1-3BQ5
- use vendor macro for Vendor tag.

* Fri Oct 21 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 1.0.1-3BQ4
- remove Serial tag.

* Mon Aug 15 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 1.0.1-3BQ3
- clean up spec file.

* Sun Jul 03 2005 Hisao SHIBUYA <shibuya@alpha.or.jp> 1.0.1-3BQ2
- remove BuildArchitectures tag

* Wed Jan 14 2004 Hisao SHIBUYA <shibuya@alpha.or.jp> 1.0.1-3BQ1
- build for Blue Quartz

* Mon Nov 05 2001 Will DeHaan <will@cobalt.com>
- Added deferred time sets

* Sun Sep 10 2000 Patrick Baltz <pbaltz@cobalt.com>
- spec file for src part of base-time
