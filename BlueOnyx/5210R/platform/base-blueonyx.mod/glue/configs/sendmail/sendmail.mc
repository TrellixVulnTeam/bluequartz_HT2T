divert(-1)dnl
dnl #
dnl # This is the sendmail macro config file for m4. If you make changes to
dnl # /etc/mail/sendmail.mc, you will need to regenerate the
dnl # /etc/mail/sendmail.cf file by confirming that the sendmail-cf package is
dnl # installed and then performing a
dnl #
dnl #     make -C /etc/mail
dnl #
include(`/usr/share/sendmail-cf/m4/cf.m4')dnl
VERSIONID(`setup for BlueOnyx w/o lists')dnl
OSTYPE(`linux')dnl
dnl #
dnl # Uncomment and edit the following line if your outgoing mail needs to
dnl # be sent out through an external mail server:
dnl #
dnl define(`SMART_HOST',`smtp.your.provider')
dnl #
define(`confDEF_USER_ID',``8:12'')dnl
define(`confTRUSTED_USER', `smmsp')dnl
dnl define(`confAUTO_REBUILD')dnl
define(`confTO_CONNECT', `1m')dnl
define(`confTRY_NULL_MX_LIST',true)dnl
define(`confDONT_PROBE_INTERFACES',true)dnl
define(`PROCMAIL_MAILER_PATH',`/usr/bin/procmail')dnl
dnl # removed /etc/mail/aliases.majordomo
define(`ALIAS_FILE', `/etc/mail/aliases')dnl
define(`STATUS_FILE', `/var/log/mail/statistics')dnl
define(`UUCP_MAILER_MAX', `2000000')dnl
define(`confUSERDB_SPEC', `/etc/mail/userdb.db')dnl
define(`confPRIVACY_FLAGS', `authwarnings,novrfy,noexpn,restrictqrun')dnl
define(`confAUTH_OPTIONS', `A')dnl
dnl #
dnl # The following allows relaying if the user authenticates, and disallows
dnl # plaintext authentication (PLAIN/LOGIN) on non-TLS links
dnl #
dnl define(`confAUTH_OPTIONS', `A p')dnl
dnl # 
dnl # PLAIN is the preferred plaintext authentication method and used by
dnl # Mozilla Mail and Evolution, though Outlook Express and other MUAs do
dnl # use LOGIN. Other mechanisms should be used if the connection is not
dnl # guaranteed secure.
dnl #
TRUST_AUTH_MECH(`EXTERNAL DIGEST-MD5 CRAM-MD5 LOGIN PLAIN')dnl
define(`confAUTH_MECHANISMS', `EXTERNAL GSSAPI DIGEST-MD5 CRAM-MD5 LOGIN PLAIN')dnl
dnl #
dnl # Rudimentary information on creating certificates for sendmail TLS:
dnl #     make -C /usr/share/ssl/certs usage
dnl #
define(`confCACERT_PATH',`/usr/share/ssl/certs')
define(`confCACERT',`/usr/share/ssl/certs/ca-bundle.crt')
define(`confSERVER_CERT',`/usr/share/ssl/certs/sendmail.pem')
define(`confSERVER_KEY',`/usr/share/ssl/certs/sendmail.pem')
dnl #
dnl # This allows sendmail to use a keyfile that is shared with OpenLDAP's
dnl # slapd, which requires the file to be readble by group ldap
dnl #
dnl define(`confDONT_BLAME_SENDMAIL',`groupreadablekeyfile')dnl
dnl #
dnl define(`confTO_QUEUEWARN', `4h')dnl
dnl define(`confTO_QUEUERETURN', `5d')dnl
dnl define(`confQUEUE_LA', `12')dnl
dnl define(`confREFUSE_LA', `18')dnl
define(`confTO_IDENT', `0')dnl
dnl FEATURE(delay_checks)dnl
FEATURE(`no_default_msa',`dnl')dnl
FEATURE(`smrsh',`/usr/sbin/smrsh')dnl
FEATURE(`mailertable',`hash -o /etc/mail/mailertable.db')dnl
FEATURE(`virtusertable',`hash -o /etc/mail/virtusertable.db')dnl
FEATURE(redirect)dnl
FEATURE(always_add_domain)dnl
FEATURE(use_cw_file)dnl
FEATURE(use_ct_file)dnl
dnl #
dnl # The -t option will retry delivery if e.g. the user runs over his quota.
dnl #
FEATURE(local_procmail,`',`procmail -Y -a $h -d $u')dnl
FEATURE(`access_db',`hash -T<TMPF> -o /etc/mail/access.db')dnl
FEATURE(`blacklist_recipients')dnl
EXPOSED_USER(`root')dnl
VIRTUSER_DOMAIN_FILE(`/etc/mail/virthosts')dnl
dnl #
dnl # The following causes sendmail to only listen on the IPv4 loopback address
dnl # 127.0.0.1 and not on any other network devices. Remove the loopback
dnl # address restriction to accept email from the internet or intranet.
dnl #
DAEMON_OPTIONS(`Port=smtp, Name=MTA')dnl
dnl #
dnl # The following causes sendmail to additionally listen to port 587 for
dnl # mail from MUAs that authenticate. Roaming users who can't reach their
dnl # preferred sendmail daemon due to port 25 being blocked or redirected find
dnl # this useful.
dnl #
DAEMON_OPTIONS(`Port=submission, Name=MSA, M=Ea')dnl
dnl #
dnl # The following causes sendmail to additionally listen to port 465, but
dnl # starting immediately in TLS mode upon connecting. Port 25 or 587 followed
dnl # by STARTTLS is preferred, but roaming clients using Outlook Express can't
dnl # do STARTTLS on ports other than 25. Mozilla Mail can ONLY use STARTTLS
dnl # and doesn't support the deprecated smtps; Evolution <1.1.1 uses smtps
dnl # when SSL is enabled-- STARTTLS support is available in version 1.1.1.
dnl #
dnl # For this to work your OpenSSL certificates must be configured.
dnl #
DAEMON_OPTIONS(`Port=smtps, Name=TLSMTA, M=s')dnl
dnl #
dnl # The following causes sendmail to additionally listen on the IPv6 loopback
dnl # device. Remove the loopback address restriction listen to the network.
dnl #
dnl # NOTE: binding both IPv4 and IPv6 daemon to the same port requires
dnl #       a kernel patch
dnl #
dnl DAEMON_OPTIONS(`port=smtp,Addr=::1, Name=MTA-v6, Family=inet6')dnl
dnl #
dnl # We strongly recommend not accepting unresolvable domains if you want to
dnl # protect yourself from spam. However, the laptop and users on computers
dnl # that do not have 24x7 DNS do need this.
dnl #
dnl FEATURE(`accept_unresolvable_domains')dnl
dnl #
dnl FEATURE(`relay_based_on_MX')dnl
dnl # 
dnl # Also accept email sent to "localhost.localdomain" as local email.
dnl # 
LOCAL_DOMAIN(`localhost.localdomain')dnl
dnl #
dnl # The following example makes mail from this host and any additional
dnl # specified domains appear to be sent from mydomain.com
dnl #
MASQUERADE_AS()dnl
dnl #
dnl # masquerade not just the headers, but the envelope as well
dnl #
dnl FEATURE(masquerade_envelope)dnl
dnl #
dnl # masquerade not just @mydomainalias.com, but @*.mydomainalias.com as well
dnl #
dnl FEATURE(masquerade_entire_domain)dnl
dnl #
dnl define(`confPRIVACY_FLAGS', `noexpn noreceipts authwarnings noetrn')
dnl some mail servers don't give expn or helo dnl
dnl define(`confPRIVACY_FLAGS', `needmailhelo needexpnhelo noexpn needvrfyhelo noreceipts authwarnings noetrn noverb')
dnl 1.6 meg limit on message size
dnl define(`confMAX_MESSAGE_SIZE',20000000)dnl
define(`confMAX_RCPTS_PER_MESSAGE',`25')dnl
dnl timeout on the initial outgoing connect
dnl define(`TimoutIconnect=30s')dnl
dnl define(`confLOG_LEVEL',`9')dnl
dnl I can do a dns lookup on hte mailer, EVERY MAILER should be be able to do this.
define(`_DNSVALID_',1)dnl 
dnl here is the default header in sendmail:$j Sendmail $v/$Z; $b
dnl I change it to remove version information.
define(`confSMTP_LOGIN_MSG',$j Sendmail; $b)dnl
dnl this will wait 2 minutes for a command from the other mailer.
dnl this will timeout on mailers that are parasiting on my mailer.
dnl this has never caused problems on mail delivery, it just removes troublesome
dnl mailers (spammers that won't resolve ip or similar.)
dnl define(`confTO_COMMAND',120s)dnl
dnl timeout on the initial outgoing connect
dnl define(`ConnectionCacheTimeout=30')dnl
dnl To enable black whole lists, remove the 'dnl' before the work FEATURE.
dnl - save the file
dnl - type: make 
dnl - hit enter; and then do
dnl - service sendmail restart
dnl FEATURE(enhdnsbl,`bl.spamcop.net',`',`t',`Spam blocked see: http://spamcop.net/bl.shtml?$&{client_addr}')dnl
dnl FEATURE(enhdnsbl,`sbl-xbl.spamhaus.org',`',`t',`Spam blocked - see http://ordb.org/')dnl
dnl FEATURE(enhdnsbl,`relays.ordb.org',`',`t',`Spam blocked - see http://ordb.org')dnl
dnl FEATURE(enhdnsbl,`blackholes.mail-abuse.org', `t',`Spam blocked see: http://www.mail-abuse.org/rbl')dnl
dnl FEATURE(enhdnsbl,`relays.mail-abuse.org', `t',`Spam blocked see: http://www.mail-abuse.org/rss')dnl
dnl FEATURE(enhdnsbl,`rbl-plus.mail-abuse.org', `t',`Spam blocked see: http://www.mail-abuse.org')dnl
dnl FEATURE(enhdnsbl,`dsn.rfc-ignorant.org', `t',`Spam blocked see: http://www.rfc-ignorant.org')dnl
dnl FEATURE(enhdnsbl,`postmaster.rfc-ignorant.org', `t',`Spam blocked see: http://www.rfc-ignorant.org')dnl
dnl FEATURE(enhdnsbl,`abuse.rfc-ignorant.org', `t',`Spam blocked see: http://www.rfc-ignorant.org')dnl
dnl FEATURE(enhdnsbl,`in.dnsbl.org', `t',`Spam blocked see: http://www.dnsbl.org')dnl
dnl MASQUERADE_DOMAIN(localhost)dnl
dnl MASQUERADE_DOMAIN(localhost.localdomain)dnl
dnl MASQUERADE_DOMAIN(mydomainalias.com)dnl
dnl MASQUERADE_DOMAIN(mydomain.lan)dnl
MAILER(smtp)dnl
MAILER(procmail)dnl
dnl #
dnl # additinal configuration for Blue Quartz
dnl #
define(`confDONT_BLAME_SENDMAIL', `forwardfileingroupwritabledirpath, ForwardFileInUnsafeDirPath, ForwardFileInUnsafeDirPathSafe')dnl
HACK(popauth)dnl

dnl here is the default header in sendmail:$j Sendmail $v/$Z; $b
dnl I change it to remove version information.
dnl #les# define(`confSMTP_LOGIN_MSG',$j Sendmail; $b)dnl
define(`confSMTP_LOGIN_MSG',$?{if_name}${if_name}$|$j$. Sendmail Ready; $b)dnl
