Summary: Binaries and scripts used by Active Monitor for base-network
Name: base-network-am
Version: 1.0.1
Release: 3BQ2%{?dist}
Vendor: %{vendor}
License: Sun modified BSD
Group: System Environment/BlueQuartz
Source: base-network-am.tar.gz
BuildRoot: /tmp/%{name}

%prep
%setup -n %{name}

%build
make all

%install
make PREFIX=$RPM_BUILD_ROOT install

%files
/usr/sausalito/swatch/bin/*

%description
This package contains a number of binaries and scripts used by the Active
Monitor subsystem to monitor services provided by the base-network module.  

%changelog
* Sun Jul 09 2006 Hisao SHIBUYA <shibuya@alpha.or.jp> 1.0.1-3BQ2
- add dist tag for release.

* Sun Jul 09 2006 Hisao SHIBUYA <shibuya@alpha.or.jp> 1.0.1-3BQ1
- build for BlueQuartz 5100WG.

* Wed Aug 30 2000 Tim Hockin <thockin@cobalt.com>
- initial spec file

