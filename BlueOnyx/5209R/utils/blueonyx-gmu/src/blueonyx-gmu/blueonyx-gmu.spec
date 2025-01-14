#
# Spec file for blueonyx-gmu
#

%define pkgname blueonyx-gmu
%define instdir .blueonyx-gmu

Name:           %{pkgname}
Version:        0.9.0
Release:        11
Packager:       Michael Stauber <mstauber@blueonyx.it>
Vendor:         BLUEONYX.IT
URL:            http://www.blueonyx.it
License:        Sun Modified BSD
Group:			System
BuildRoot: 		%{_tmppath}/%{name}-%{version}-root
Requires:		perl
Requires:		perl-XML-Simple
Requires:		pv
Requires:		perl-Apache-ConfigFile
Requires:		perl-List-Flatten
Requires:		perl-Mail-Sendmail
Requires:		procmail
BuildArch:      noarch
Distribution:   BlueOnyx 5209R
Source:         %{name}.tar.gz
Summary:        BlueOnyx Generic Migration Utility
AutoReq         : no
AutoProv        : no

%description
The BlueOnyx Generic Migration Utility can import Resellers,
Vsites and Users that were exported on other platforms than 
BlueOnyx. For this it reads an XML dump generated by an 
export script customized to the export platform. According
to the data in the XML it will then create Resellers, Vsites
and users accordingly. It also handles Maildir to Mbox 
conversions, import of mailspools, import of Vsite and
User tarballs, automatically raising quotas of over quora
Vsites and Users and other tasks.

%prep
%setup -n %{name}

%build
echo "Working on $RPM_BUILD_ROOT"

%install

%{__rm} -rf %{buildroot}
mkdir %{buildroot}/
mv * %{buildroot}/

mkdir -p $RPM_BUILD_ROOT/home/solarspeed/%{instdir}
mkdir -p $RPM_BUILD_ROOT/usr/sausalito/sbin/
mv $RPM_BUILD_ROOT/blueonyx-gmu $RPM_BUILD_ROOT/home/.blueonyx-gmu
mv $RPM_BUILD_ROOT/home/%{instdir}/blueonyx-import.pl $RPM_BUILD_ROOT/usr/sausalito/sbin/blueonyx-import.pl
mv $RPM_BUILD_ROOT/home/%{instdir}/lib/dw-maildirtombox.pl $RPM_BUILD_ROOT/usr/sausalito/sbin/dw-maildirtombox.pl
rm -f $RPM_BUILD_ROOT/blueonyx-gmu.spec

%pre

%post

%preun

%postun

%clean
rm -R -f $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%attr(0755,root,root) /usr/sausalito/sbin/blueonyx-import.pl
%attr(0755,root,root) /usr/sausalito/sbin/dw-maildirtombox.pl
%attr(0755,root,root) /home/.blueonyx-gmu/lib/Unix/AutomountFile.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/Unix/PasswdFile.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/Unix/AliasFile.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/Unix/ConfigFile.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/Unix/GroupFile.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/List/Util.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/List/Flatten.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/List/MoreUtils.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/List/Util/XS.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/Simple/FAQ.pod
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/NamespaceSupport.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/SAX.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/Simple.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/SAX/DocumentLocator.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/SAX/Exception.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/SAX/Intro.pod
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/SAX/ParserDetails.ini
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/SAX/PurePerl/EncodingDetect.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/SAX/PurePerl/DTDDecls.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/SAX/PurePerl/NoUnicodeExt.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/SAX/PurePerl/Exception.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/SAX/PurePerl/DebugHandler.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/SAX/PurePerl/DocType.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/SAX/PurePerl/XMLDecl.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/SAX/PurePerl/Reader/
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/SAX/PurePerl/Reader/String.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/SAX/PurePerl/Reader/URI.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/SAX/PurePerl/Reader/NoUnicodeExt.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/SAX/PurePerl/Reader/Stream.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/SAX/PurePerl/Reader/UnicodeExt.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/SAX/PurePerl/Reader.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/SAX/PurePerl/UnicodeExt.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/SAX/PurePerl/Productions.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/SAX/Base.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/SAX/PurePerl.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/XML/SAX/ParserFactory.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/pv_bsd
%attr(0755,root,root) /home/.blueonyx-gmu/lib/Apache/ConfigFile.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/perl5/site_perl/5.8.9/Unix/AutomountFile.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/perl5/site_perl/5.8.9/Unix/PasswdFile.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/perl5/site_perl/5.8.9/Unix/AliasFile.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/perl5/site_perl/5.8.9/Unix/ConfigFile.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/perl5/site_perl/5.8.9/Unix/GroupFile.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/perl5/site_perl/5.8.9/mach/auto/Unix/ConfigFile/.packlist
%attr(0755,root,root) /home/.blueonyx-gmu/lib/perl5/5.8.9/man/man3/Unix::AliasFile.3
%attr(0755,root,root) /home/.blueonyx-gmu/lib/perl5/5.8.9/man/man3/Unix::PasswdFile.3
%attr(0755,root,root) /home/.blueonyx-gmu/lib/perl5/5.8.9/man/man3/Unix::AutomountFile.3
%attr(0755,root,root) /home/.blueonyx-gmu/lib/perl5/5.8.9/man/man3/Unix::GroupFile.3
%attr(0755,root,root) /home/.blueonyx-gmu/lib/perl5/5.8.9/man/man3/Unix::ConfigFile.3
%attr(0755,root,root) /home/.blueonyx-gmu/lib/perl5/5.8.9/mach/perllocal.pod
%attr(0755,root,root) /home/.blueonyx-gmu/lib/Mail/Sendmail.pm
%attr(0755,root,root) /home/.blueonyx-gmu/lib/pv
%attr(0755,root,root) /home/.blueonyx-gmu/lib/pv64
%attr(0755,root,root) /home/.blueonyx-gmu/lib/Tie/DxHash.pm
%attr(0755,root,root) /home/.blueonyx-gmu/verio-to-blueonyx-exporter.pl


%changelog

* Wed Dec 30 2015 Michael Stauber <mstauber@blueonyx.it>
- [0.9.0-11] Small fix in exporter.

* Mon Dec 07 2015 Michael Stauber <mstauber@blueonyx.it>
- [0.9.0-10] Switched exporter from NameVirtualHost to VirtualHost parsing.

* Tue Dec 01 2015 Michael Stauber <mstauber@blueonyx.it>
- [0.9.0-9] Added more prohibited aliases to exporter.

* Mon Nov 30 2015 Michael Stauber <mstauber@blueonyx.it>
- [0.9.0-8] Added '-p' switch to importer to apply PHP settings to Vsites.

* Mon Nov 30 2015 Michael Stauber <mstauber@blueonyx.it>
- [0.9.0-7] Several fixes and tweaks in exporter.

* Fri Nov 27 2015 Michael Stauber <mstauber@blueonyx.it>
- [0.9.0-6] Reseller import fix.

* Fri Nov 27 2015 Michael Stauber <mstauber@blueonyx.it>
- [0.9.0-5] Small fixes in importer for password hashes.

* Fri Nov 27 2015 Michael Stauber <mstauber@blueonyx.it>
- [0.9.0-4] Small fixes in exporter to prohibit username 'admin'.

* Fri Nov 27 2015 Michael Stauber <mstauber@blueonyx.it>
- [0.9.0-3] Small fixes to importer in line 246.

* Fri Nov 27 2015 Michael Stauber <mstauber@blueonyx.it>
- [0.9.0-2] Small fixes to importer for cgi-bin location.

* Fri Nov 27 2015 Michael Stauber <mstauber@blueonyx.it>
- [0.9.0-1] Initial release.
