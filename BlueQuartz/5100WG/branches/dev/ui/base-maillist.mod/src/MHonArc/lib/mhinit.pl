##---------------------------------------------------------------------------##
##  File:
##	@(#) mhinit.pl 2.20 00/02/13 03:28:47
##  Author:
##      Earl Hood       mhonarc@pobox.com
##  Description:
##      Initialization stuff for MHonArc.
##---------------------------------------------------------------------------##
##    MHonArc -- Internet mail-to-HTML converter
##    Copyright (C) 1995-1999	Earl Hood, mhonarc@pobox.com
##
##    This program is free software; you can redistribute it and/or modify
##    it under the terms of the GNU General Public License as published by
##    the Free Software Foundation; either version 2 of the License, or
##    (at your option) any later version.
##
##    This program is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY; without even the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##    GNU General Public License for more details.
##
##    You should have received a copy of the GNU General Public License
##    along with this program; if not, write to the Free Software
##    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
##    02111-1307, USA
##---------------------------------------------------------------------------##

package mhonarc;

##---------------------------------------------------------------------------##

sub mhinit_vars {

##	The %Zone array should be augmented to contain all timezone
##	specifications with the positive/negative hour offset from UTC
##	(GMT).  The zone value is *added* to the time containing the
##	zone to determine GMT time.  Hence, the values will be the
##	negative inverse used in actual time specifications in messages.
##	(There has got to be a better way to handle timezones)
##	Array can be augmented/overridden via the resource file.
%Zone = (
    'ACDT', '-1030',	# Australian Central Daylight
    'ACST', '-0930',	# Australian Central Standard
    'ADT',   '0300',	# (US) Atlantic Daylight
    'AEDT', '-1100',	# Australian East Daylight
    'AEST', '-1000',	# Australian East Standard
    'AHDT',  '0900',
    'AHST',  '1000',	
    'AST',   '0400',	# (US) Atlantic Standard
    'AT',    '0200',	# Azores
    'AWDT', '-0900',	# Australian West Daylight
    'AWST', '-0800',	# Australian West Standard
    'BAT',  '-0300',	# Baghdad
    'BDST', '-0200',	# British Double Summer
    'BET',   '1100',	# Bering Standard
    'BST',  '-0100',	# British Summer
#   'BST',   '0300',	# Brazil Standard
    'BT',   '-0300',	# Baghdad
    'BZT2',  '0300',	# Brazil Zone 2
    'CADT', '-1030',	# Central Australian Daylight
    'CAST', '-0930',	# Central Australian Standard
    'CAT',   '1000',	# Central Alaska
    'CCT',  '-0800',	# China Coast
    'CDT',   '0500',	# (US) Central Daylight
    'CED',  '-0200',	# Central European Daylight
    'CET',  '-0100',	# Central European
    'CST',   '0600',	# (US) Central Standard
    'EAST', '-1000',	# Eastern Australian Standard
    'EDT',   '0400',	# (US) Eastern Daylight
    'EED',  '-0300',	# Eastern European Daylight
    'EET',  '-0200',	# Eastern Europe
    'EEST', '-0300',	# Eastern Europe Summer
    'EST',   '0500',	# (US) Eastern Standard
    'FST',  '-0200',	# French Summer
    'FWT',  '-0100',	# French Winter
    'GMT',   '0000',	# Greenwich Mean
    'GST',  '-1000',	# Guam Standard
#   'GST',   '0300',	# Greenland Standard
    'HDT',   '0900',	# Hawaii Daylight
    'HST',   '1000',	# Hawaii Standard
    'IDLE', '-1200',	# Internation Date Line East
    'IDLW',  '1200',	# Internation Date Line West
    'IST',  '-0530',	# Indian Standard
    'IT',   '-0330',	# Iran
    'JST',  '-0900',	# Japan Standard
    'JT',   '-0700',	# Java
    'KST',  '-0900',	# Korean Standard
    'MDT',   '0600',	# (US) Mountain Daylight
    'MED',  '-0200',	# Middle European Daylight
    'MET',  '-0100',	# Middle European
    'MEST', '-0200',	# Middle European Summer
    'MEWT', '-0100',	# Middle European Winter
    'MST',   '0700',	# (US) Mountain Standard
    'MT',   '-0800',	# Moluccas
    'NDT',   '0230',	# Newfoundland Daylight
    'NFT',   '0330',	# Newfoundland
    'NT',    '1100',	# Nome
    'NST',  '-0630',	# North Sumatra
#   'NST',   '0330',	# Newfoundland Standard
    'NZ',   '-1100',	# New Zealand
    'NZST', '-1200',	# New Zealand Standard
    'NZDT', '-1300',	# New Zealand Daylight
    'NZT',  '-1200',	# New Zealand
    'PDT',   '0700',	# (US) Pacific Daylight
    'PST',   '0800',	# (US) Pacific Standard
    'ROK',  '-0900',	# Republic of Korea
    'SAD',  '-1000',	# South Australia Daylight
    'SAST', '-0900',	# South Australia Standard
    'SAT',  '-0900',	# South Australia
    'SDT',  '-1000',	# South Australia Daylight
    'SST',  '-0200',	# Swedish Summer
    'SWT',  '-0100',	# Swedish Winter
    'USZ3', '-0400',	# USSR Zone 3
    'USZ4', '-0500',	# USSR Zone 4
    'USZ5', '-0600',	# USSR Zone 5
    'USZ6', '-0700',	# USSR Zone 6
    'UT',    '0000',	# Universal Coordinated
    'UTC',   '0000',	# Universal Coordinated
    'UZ10', '-1100',	# USSR Zone 10
    'WAT',   '0100',	# West Africa
    'WET',   '0000',	# West European
    'WST',  '-0800',	# West Australian Standard
    'YDT',   '0800',	# Yukon Daylight
    'YST',   '0900',	# Yukon Standard
    'ZP4',  '-0400',	# USSR Zone 3
    'ZP5',  '-0500',	# USSR Zone 4
    'ZP6',  '-0600',	# USSR Zone 5
);
%ZoneUD = ();

##	Assoc array listing mail header fields to exclude in output.
##	Each key is treated as a regular expression with '^' prepended
##	to it.

%HFieldsExc = (
    'content-', 1,		# Mime headers
    'errors-to', 1,
    'forward', 1,		# Forward lines (MH may add these)
    'lines', 1,
    'message-id', 1,
    'mime-', 1, 		# Mime headers
    'nntp-', 1,
    'originator', 1,
    'path', 1,
    'precedence', 1,
    'received', 1,		# MTA added headers
    'replied', 1,		# Replied lines (MH may add these)
    'return-path', 1,   	# MH/MTA header
    'status', 1,
    'via', 1,
    'x-', 1,    		# Non-standard headers
);

##	Asocc arrays defining HTML formats to apply to header fields

%HeadFields = (
    "-default-", "",		# Nothing
);
%HeadHeads = (
    "-default-", "em",		# Empasize field labels
);
@FieldOrder = (			# Order fields are listed
    'to',
    'subject',
    'from',
    'date',
    '-extra-',
);
%FieldODefs = (			# Fields not to slurp up in "-extra-"
    'to', 1,
    'subject', 1,
    'from', 1,
    'date', 1,
);

##	Message information variables

$NumOfMsgs	=  0;	# Total number of messages
$LastMsgNum	= -1;	# Message number of last message
%Message  	= ();	# Message indexes to bodies
%MsgHead  	= ();	# Message indexes to heads
%MsgHtml  	= ();	# Flag if message is html
%Subject  	= ();	# Message indexes to subjects
%From   	= ();	# Message indexes to froms
%Date   	= ();	# Message indexes to dates
%MsgId  	= ();	# Message ids to indexes
%NewMsgId  	= ();	# New message ids to indexes
%IndexNum 	= ();	# Index key to message number
%Derived  	= ();	# Index key to derived files for message
%Refs   	= ();	# Index key to message references
%Follow  	= ();	# Index key to follow-ups
%FolCnt   	= ();	# Index key to number of follow-ups
%ContentType	= ();	# Index key to base content-type of message
%Icons    	= ();	# Index key to icon URL for content-type
%AddIndex 	= ();	# Flags for messages that must be written

@MListOrder	= ();	# List of indexes in order printed on main index
%Index2Mloc	= ();	# Map index to position in main index
@TListOrder	= ();	# List of indexes in order printed on thread index
%Index2Tloc	= ();	# Map index to position in thread index
%ThreadLevel	= ();	# Map index to thread level

%UDerivedFile	= ();	# Key = filename template.  Value = content template

##	Following variables used in thread computation

@ThreadList	= ();	# List of messages visible in thread index
@NotIdxThreadList
		= ();	# List of messages not visible in index
%HasRef		= ();	# Flags if message has references (Keys = indexes)
			# 	(Values = reference message indexes)
%HasRefDepth	= ();	# Depth of reference from HasRef value
%Replies	= ();	# Msg-ids of explicit replies (Keys = indexes)
%SReplies	= ();	# Msg-ids of subject-based replies (Keys = indexes)
%TVisible	= ();	# Message visible in thread index (Keys = indexes)
$DoMissingMsgs	=  0;	# Flag is missing messages should be noted in index

##	Some miscellaneous variables

%IsDefault	= ();	# Flags if certain resources are the default

$bs 		= "\b";	# Used as a separator
$Url 		= '(http://|https://|ftp://|afs://|wais://|telnet://|' .
		   'gopher://|news:|nntp:|mid:|cid:|mailto:|prospero:)';

$MLCP		= 0;	# Main index contains included files flag
$SLOW		= 0;	# Save memory flag
$NumOfPages	= 0;	# Number of index pages
$IdxMinPg	= -1;	# Starting page of index for updating
$TIdxMinPg	= -1;	# Starting page of thread index for updating
$IdxPageNum	= 0;	# Page to output if genidx
$DBPathName	= '';	# Full pathname of database file

##----------------------------------------------------------------------
##	BEGIN readmail.pl variable settings
##----------------------------------------------------------------------
##	Default filters
##
%readmail::MIMEFilters = (
    # Content-type			Filter
    #-------------------------------------------------------------------
    "application/octet-stream",		"m2h_external::filter",
    "application/x-patch",		"m2h_text_plain::filter",
    "message/delivery-status",  	"m2h_text_plain::filter",
    "message/external-body",   		"m2h_msg_extbody::filter",
    "message/partial",   		"m2h_text_plain::filter",
    "text/enriched",    		"m2h_text_enriched::filter",
    "text/html",			"m2h_text_html::filter",
    "text/plain",			"m2h_text_plain::filter",
    "text/richtext",    		"m2h_text_enriched::filter",
    "text/setext",			"m2h_text_setext::filter",
    "text/tab-separated-values",	"m2h_text_tsv::filter",
    "text/x-html",			"m2h_text_html::filter",
    "text/x-setext",    		"m2h_text_setext::filter",

    "application/*",		 	"m2h_external::filter",
    "audio/*",				"m2h_external::filter",
    "chemical/*",  			"m2h_external::filter",
    "image/*",  			"m2h_external::filter",
    "model/*",  			"m2h_external::filter",
    "text/*",   			"m2h_text_plain::filter",
    "video/*",  			"m2h_external::filter",

    "x-sun-attachment",			"m2h_text_plain::filter",
);
%readmail::MIMEFiltersSrc = (
    # Content-type			Filter
    #-------------------------------------------------------------------
    "application/octet-stream",		"mhexternal.pl",
    "application/x-patch",		"mhtxtplain.pl",
    "message/delivery-status",  	"mhtxtplain.pl",
    "message/external-body",   		"mhmsgextbody.pl",
    "message/partial",   		"mhtxtplain.pl",
    "text/enriched",    		"mhtxtenrich.pl",
    "text/html",			"mhtxthtml.pl",
    "text/plain",			"mhtxtplain.pl",
    "text/richtext",    		"mhtxtenrich.pl",
    "text/setext",			"mhtxtsetext.pl",
    "text/tab-separated-values",	"mhtxttsv.pl",
    "text/x-html",			"mhtxthtml.pl",
    "text/x-setext",    		"mhtxtsetext.pl",

    "application/*",		 	"mhexternal.pl",
    "audio/*",				"mhexternal.pl",
    "chemical/*",  			"mhexternal.pl",
    "image/*",  			"mhexternal.pl",
    "model/*",  			"mhexternal.pl",
    "text/*",   			"mhtxtplain.pl",
    "video/*",  			"mhexternal.pl",

    "x-sun-attachment",			"mhtxtplain.pl",
);

##  Default filter arguments
##
%readmail::MIMEFiltersArgs = (
    # Content-type			Arguments
    #-------------------------------------------------------------------
    "image/gif",			"inline",
    "image/jpeg",			"inline",
    "image/x-xbitmap", 	 		"inline",
    "image/x-xbm",			"inline",
);

##  Charset filters
##
%readmail::MIMECharSetConverters = (
    # Character set			Converter Function
    #-------------------------------------------------------------------
    "plain",     			"mhonarc::htmlize",
    "us-ascii",   			"mhonarc::htmlize",
    "iso-8859-1",   			"mhonarc::htmlize",
    "iso-8859-2",   			"iso_8859::str2sgml",
    "iso-8859-3",   			"iso_8859::str2sgml",
    "iso-8859-4",   			"iso_8859::str2sgml",
    "iso-8859-5",   			"iso_8859::str2sgml",
    "iso-8859-6",   			"iso_8859::str2sgml",
    "iso-8859-7",   			"iso_8859::str2sgml",
    "iso-8859-8",   			"iso_8859::str2sgml",
    "iso-8859-9",   			"iso_8859::str2sgml",
    "iso-8859-10",   			"iso_8859::str2sgml",
    "iso-2022-jp",   			"iso_2022_jp::str2html",
    "latin1",   			"mhonarc::htmlize",
    "latin2",   			"iso_8859::str2sgml",
    "latin3",   			"iso_8859::str2sgml",
    "latin4",   			"iso_8859::str2sgml",
    "latin5",   			"iso_8859::str2sgml",
    "latin6",   			"iso_8859::str2sgml",
    "default",     			"-ignore-",
);
%readmail::MIMECharSetConvertersSrc = (
    # Character set			Converter Function
    #-------------------------------------------------------------------
    "plain",     			undef,
    "us-ascii",   			undef,
    "iso-8859-1",   			undef,
    "iso-8859-2",   			"iso8859.pl",
    "iso-8859-3",   			"iso8859.pl",
    "iso-8859-4",   			"iso8859.pl",
    "iso-8859-5",   			"iso8859.pl",
    "iso-8859-6",   			"iso8859.pl",
    "iso-8859-7",   			"iso8859.pl",
    "iso-8859-8",   			"iso8859.pl",
    "iso-8859-9",   			"iso8859.pl",
    "iso-8859-10",   			"iso8859.pl",
    "iso-2022-jp",   			"iso2022jp.pl",
    "latin1",   			undef,
    "latin2",   			"iso_8859.pl",
    "latin3",   			"iso_8859.pl",
    "latin4",   			"iso_8859.pl",
    "latin5",   			"iso_8859.pl",
    "latin6",   			"iso_8859.pl",
    "default",     			undef,
);

##------------------------------------------------------------------------
##	END readmail.pl variable settings
##------------------------------------------------------------------------

##  Variable to hold function for converting message header text.
$MHeadCnvFunc	= "mhonarc::htmlize";

##  Regexp for variable detection
$VarExp    = $ENV{'M2H_VARREGEX'}   || '\$([^\$]*)\$';

##  Regexp for address/msg-id detection (looks like cussing in cartoons)
$AddrExp = q%[^()<>@,;:\/\s"'&|]+@[^()<>@,;:\/\s"'&|]+%;

##	Grab environment variable settings
##
$AFS	   = $ENV{'M2H_AFS'}        || 0;
$ANNOTATE  = $ENV{'M2H_ANNOTATE'}   || 0;
$DBFILE    = $ENV{'M2H_DBFILE'}     || 
	     (($MSDOS || $VMS) ? "mhonarc.db": ".mhonarc.db");
$DOCURL    = $ENV{'M2H_DOCURL'}     ||
	     'http://www.oac.uci.edu/indiv/ehood/mhonarc.html';
$FOOTER    = $ENV{'M2H_FOOTER'}     || "";
$HEADER    = $ENV{'M2H_HEADER'}     || "";
$IDXNAME   = "";	# Set in get_resources()
$IDXPREFIX = $ENV{'M2H_IDXPREFIX'}  || "mail";
$TIDXPREFIX= $ENV{'M2H_TIDXPREFIX'} || "thrd";
$IDXSIZE   = $ENV{'M2H_IDXSIZE'}    || 0;
$TIDXNAME  = "";	# Set in get_resources()
$OUTDIR    = $ENV{'M2H_OUTDIR'}     || $CURDIR;
$FMTFILE   = $ENV{'M2H_RCFILE'}     || "";
$TTITLE    = $ENV{'M2H_TTITLE'}     || "Mail Thread Index";
$TITLE     = $ENV{'M2H_TITLE'}      || "Mail Index";
$MAILTOURL = $ENV{'M2H_MAILTOURL'}  || "";
$FROM      = $ENV{'M2H_MSGSEP'}     || '^From ';
$LOCKFILE  = $ENV{'M2H_LOCKFILE'}   ||
	     ($MSDOS ? "mhonarc.lck" :
		$VMS ? "mhonarc_lck" : ".mhonarc.lck");
$LOCKTRIES = $ENV{'M2H_LOCKTRIES'}  || 10;
$LOCKDELAY = $ENV{'M2H_LOCKDELAY'}  || 3;
$MAXSIZE   = $ENV{'M2H_MAXSIZE'}    || 0;
$TLEVELS   = $ENV{'M2H_TLEVELS'}    || 3;
$MHPATTERN = $ENV{'M2H_MHPATTERN'}  || '^\d+$';
$DefRcFile = $ENV{'M2H_DEFRCFILE'}  || '';
$HtmlExt   = $ENV{'M2H_HTMLEXT'}    || "html";
$MsgPrefix = $ENV{'M2H_MSGPREFIX'}  || "msg";
$DefRcName = $ENV{'M2H_DEFRCNAME'}  ||
	     (($MSDOS || $VMS) ? "mhonarc.rc": ".mhonarc.rc");
$GzipExe   = $ENV{'M2H_GZIPEXE'}    || 'gzip';
$SpamMode  = $ENV{'M2H_SPAMMODE'}   || 0;

$GMTDateFmt	= $ENV{'M2H_GMTDATEFMT'}   	|| '';
$LocalDateFmt	= $ENV{'M2H_LOCALDATEFMT'} 	|| '';
$ExpireDate	= $ENV{'M2H_EXPIREDATE'}   	|| '';
$ExpireDateTime = 0;
$ExpireTime	= $ENV{'M2H_EXPIREAGE'}    	|| 0;

$MsgGMTDateFmt	= $ENV{'M2H_MSGGMTDATEFMT'}   	|| '';
$MsgLocalDateFmt= $ENV{'M2H_MSGLOCALDATEFMT'}	|| '';

$NoteDir	= $ENV{'M2H_NOTEDIR'} 		|| 'notes';

$LockMethod 	= $ENV{'M2H_LOCKMETHOD'}	|| 'directory';
$LockMethod	= set_lock_mode($LockMethod);

$CONLEN      = defined($ENV{'M2H_CONLEN'})    ?  $ENV{'M2H_CONLEN'}	: 0;
$MAIN        = defined($ENV{'M2H_MAIN'})      ?  $ENV{'M2H_MAIN'}	: 1;
$MULTIIDX    = defined($ENV{'M2H_MULTIPG'})   ?  $ENV{'M2H_MULTIPG'}	: 0;
$MODTIME     = defined($ENV{'M2H_MODTIME'})   ?  $ENV{'M2H_MODTIME'}	: 0;
$NODOC       = defined($ENV{'M2H_DOC'})       ? !$ENV{'M2H_DOC'}	: 0;
$NOMAILTO    = defined($ENV{'M2H_MAILTO'})    ? !$ENV{'M2H_MAILTO'}	: 0;
$NoMsgPgs    = defined($ENV{'M2H_MSGPGS'})    ? !$ENV{'M2H_MSGPGS'}	: 0;
$NONEWS      = defined($ENV{'M2H_NEWS'})      ? !$ENV{'M2H_NEWS'}	: 0;
$NOSORT      = defined($ENV{'M2H_SORT'})      ? !$ENV{'M2H_SORT'}	: 0;
$NOURL       = defined($ENV{'M2H_URL'})       ? !$ENV{'M2H_URL'}	: 0;
$REVSORT     = defined($ENV{'M2H_REVSORT'})   ?  $ENV{'M2H_REVSORT'}	: 0;
$SUBSORT     = defined($ENV{'M2H_SUBSORT'})   ?  $ENV{'M2H_SUBSORT'}	: 0;
$AUTHSORT    = defined($ENV{'M2H_AUTHSORT'})  ?  $ENV{'M2H_AUTHSORT'}	: 0;
$THREAD      = defined($ENV{'M2H_THREAD'})    ?  $ENV{'M2H_THREAD'}	: 1;
$TNOSORT     = defined($ENV{'M2H_TSORT'})     ? !$ENV{'M2H_TSORT'}	: 0;
$TREVERSE    = defined($ENV{'M2H_TREVERSE'})  ?  $ENV{'M2H_TREVERSE'}	: 0;
$TSUBSORT    = defined($ENV{'M2H_TSUBSORT'})  ?  $ENV{'M2H_TSUBSORT'}	: 0;
$GzipFiles   = defined($ENV{'M2H_GZIPFILES'}) ?  $ENV{'M2H_GZIPFILES'}	: 0;
$GzipLinks   = defined($ENV{'M2H_GZIPLINKS'}) ?  $ENV{'M2H_GZIPLINKS'}	: 0;
$UseLocalTime= defined($ENV{'M2H_USELOCALTIME'}) ? 
		       $ENV{'M2H_USELOCALTIME'} : 0;
$NoSubjectThreads = defined($ENV{'M2H_SUBJECTTHREADS'}) ?
			   !$ENV{'M2H_SUBJECTTHREADS'} : 0;
$SaveRsrcs   = defined($ENV{'M2H_SAVERESOURCES'}) ?
		       $ENV{'M2H_SAVERESOURCES'} : 1;
$POSIXstrftime = defined($ENV{'M2H_POSIXSTRFTIME'}) ?
			 $ENV{'M2H_POSIXSTRFTIME'} : 0;

if ($UNIX) {
    eval {
	$UMASK = defined($ENV{'M2H_UMASK'}) ?
		    $ENV{'M2H_UMASK'} : sprintf("%o",umask);
    };
}

$CheckNoArchive = defined($ENV{'M2H_CHECKNOARCHIVE'}) ?
			  $ENV{'M2H_CHECKNOARCHIVE'} : 0;
$DecodeHeads = defined($ENV{'M2H_DECODEHEADS'}) ? $ENV{'M2H_DECODEHEADS'} : 0;
$DoArchive   = defined($ENV{'M2H_ARCHIVE'})     ? $ENV{'M2H_ARCHIVE'}     : 1;
$DoFolRefs   = defined($ENV{'M2H_FOLREFS'})     ? $ENV{'M2H_FOLREFS'}     : 1;
$UsingLASTPG = defined($ENV{'M2H_USINGLASTPG'}) ? $ENV{'M2H_USINGLASTPG'} : 1;

@OtherIdxs   = defined($ENV{'M2H_OTHERINDEXES'}) ?
		    split(/:/, $ENV{'M2H_OTHERINDEXES'}) : ();
@PerlINC     = defined($ENV{'M2H_PERLINC'}) ?
		    split(/:/, $ENV{'M2H_PERLINC'}) : ();
@DateFields  = defined($ENV{'M2H_DATEFIELDS'}) ?
		    split(/:/, $ENV{'M2H_DATEFIELDS'}) : ();
@FromFields  = defined($ENV{'M2H_FROMFIELDS'}) ?
		    split(/:/, $ENV{'M2H_FROMFIELDS'}) : ();

($TSliceNBefore, $TSliceNAfter) = defined($ENV{'M2H_TSLICE'}) ?
		    split(/:/, $ENV{'M2H_TSLICE'}) : (0, 0);

##	Code for modify addresses in headers
$AddressModify = $ENV{'M2H_ADDRESSMODIFYCODE'} || "";

##	Regex representing "article" words for stripping out when doing
##	subject sorting.
$SubArtRxp   = $ENV{'M2H_SUBJECTARTICLERXP'} ||
	       q/^(the|a|an)\s+/;

##	Regex representing reply/forward prefixes to subject.
$SubReplyRxp = $ENV{'M2H_SUBJECTREPLYRXP'} ||
	       q/^\s*(re|sv|fwd|fw)[\[\]\d]*[:>-]+\s*/;

##	Code for stripping subjects
$SubStripCode = $ENV{'M2H_SUBJECTSTRIPCODE'} || "";

$MsgExcFilter = $ENV{'M2H_MSGEXCFILTER'} || "";

##	Arrays for months and weekdays.  If empty, the default settings
##	in mhtime.pl are used.

@Months   = $ENV{'M2H_MONTHS'}      ? split(/:/, $ENV{'M2H_MONTHS'})      : ();
@months   = $ENV{'M2H_MONTHSABR'}   ? split(/:/, $ENV{'M2H_MONTHSABR'})   : ();
@Weekdays = $ENV{'M2H_WEEKDAYS'}    ? split(/:/, $ENV{'M2H_WEEKDAYS'})    : ();
@weekdays = $ENV{'M2H_WEEKDAYSABR'} ? split(/:/, $ENV{'M2H_WEEKDAYSABR'}) : ();

##	Many of the following are set during runtime after the
##	database and resources have been read.  The variables are
##	listed here as a quick reference.

$ADDSINGLE	= 0;	# Flag if adding a single message
$IDXONLY	= 0;	# Flag if generating index to stdout
$RMM		= 0;	# Flag if removing messages
$SCAN		= 0;	# Flag if doing an archive scan

$SSMARKUP	= '';	# Initial markup of all pages

$IDXLABEL	= '';	# Label for main index
$LIBEG  	= '';	# List open template for main index
$LIEND  	= '';	# List close template for main index
$LITMPL 	= '';	# List item template
$AUTHBEG	= '';	# Begin of author group
$AUTHEND	= '';	# End of author group
$DAYBEG   	= '';	# Begin of a day group
$DAYEND   	= '';	# End of a day group
$SUBJECTBEG	= '';	# Begin of subject group
$SUBJECTEND	= '';	# End of subject group

$TIDXLABEL	= '';	# Label for thread index
$THEAD  	= '';	# Thread index header (and list start)
$TFOOT  	= '';	# Thread index footer (and list end)
$TSINGLETXT	= '';	# Single/lone thread entry template
$TTOPBEG	= '';	# Top of a thread begin template
$TTOPEND	= '';	# Top of a thread end template
$TSUBLISTBEG	= '';	# Sub-thread list open
$TSUBLISTEND	= '';	# Sub-thread list close
$TLITXT 	= '';	# Thread list item text
$TLIEND 	= '';	# Thread list item end
$TLINONE	= '';	# List item for missing message in thread
$TLINONEEND	= '';	# List item end for missing message in thread
$TSUBJECTBEG	= '';	# Pre-text for subject-based items
$TSUBJECTEND	= '';	# Post-text for subject-based items
$TINDENTBEG	= '';	# Thread indent open
$TINDENTEND	= '';	# Thread indent close
$TCONTBEG	= '';	# Thread continue open
$TCONTEND	= '';	# Thread continue close

$TSLICEBEG	= '';	# Start of thread slice
$TSLICEEND	= '';	# End of thread slice

$MSGFOOT	= '';	# Message footer
$MSGHEAD	= '';	# Message header
$TOPLINKS	= '';	# Message links at top of message
$BOTLINKS	= '';	# Message links at bottom of message
$SUBJECTHEADER	= '';	# Markup for message main subject line
$HEADBODYSEP 	= '';	# Markup between mail header and body
$MSGBODYEND 	= '';	# Markup at end of message data

$FIELDSBEG	= '';	# Beginning markup for mail header
$FIELDSEND	= '';	# End markup for mail header
$FLDBEG 	= '';	# Beginning markup for field text
$FLDEND 	= '';	# End markup for field text
$LABELBEG	= '';	# Beginning markup for field label
$LABELEND	= '';	# End markup for field label

$NEXTBUTTON	= '';  	# Next button template
$NEXTBUTTONIA	= '';  	# Next inactive button template
$PREVBUTTON	= '';  	# Previous button template
$PREVBUTTONIA	= '';  	# Previous inactive button template
$NEXTLINK	= '';  	# Next link template
$NEXTLINKIA	= '';  	# Next inactive link template
$PREVLINK	= '';  	# Previous link template
$PREVLINKIA	= '';  	# Previous inactive link template

$TNEXTBUTTON	= '';  	# Thread Next button template
$TNEXTBUTTONIA	= '';  	# Thread Next inactive button template
$TPREVBUTTON	= '';  	# Thread Previous button template
$TPREVBUTTONIA	= '';  	# Thread Previous inactive button template
$TNEXTLINK	= '';  	# Thread Next link template
$TNEXTLINKIA	= '';  	# Thread Next inactive link template
$TPREVLINK	= '';  	# Thread Previous link template
$TPREVLINKIA	= '';  	# Thread Previous inactive link template

$IDXPGBEG	= '';	# Beginning of main index page
$IDXPGEND	= '';	# Ending of main index page
$TIDXPGBEG	= '';	# Beginning of thread index page
$TIDXPGEND	= '';	# Ending of thread index page

$MSGPGBEG	= '';	# Beginning of message page
$MSGPGEND	= '';	# Ending of message page

$NEXTPGLINK 	= '';  	# Next page link template
$NEXTPGLINKIA	= '';  	# Next page inactive link template
$PREVPGLINK 	= '';  	# Previous page link template
$PREVPGLINKIA	= '';  	# Previous page inactive link template

$TNEXTPGLINK	= '';  	# Thread next page link template
$TNEXTPGLINKIA	= '';  	# Thread next page inactive link template
$TPREVPGLINK	= '';  	# Thread previous page link template
$TPREVPGLINKIA	= '';  	# Thread previous page inactive link template

$FOLUPBEGIN	= '';	# Start of follow-ups for message page
$FOLUPLITXT	= '';	# Markup for follow-up list entry
$FOLUPEND	= '';	# End of follow-ups for message page
$REFSBEGIN	= '';	# Start of refs for message page
$REFSLITXT	= '';	# Markup for ref list entry
$REFSEND	= '';	# End of refs for message page

$MSGIDLINK 	= '';	# Markup for linking message-ids

$NOTE		= '';	# Markup template when annotation available
$NOTEIA		= '';	# Markup template when annotation not available
$NOTEICON	= '';	# Markup template for note icon if annotation
$NOTEICONIA	= '';	# Markup template for note icon if no annotation

##	The following associative array if for defining custom
##	resource variables
%CustomRcVars	= ();

$X = "\034";	# Value separator (should equal $;)
		# NOTE: Older versions used this variable for
		#	the multiple field separator in parsed
		#	message headers.  $readmail::FieldSep should
		#	now be used (readmail.pl).

}

##---------------------------------------------------------------------------##

1;
# Copyright (c) 2003 Sun Microsystems, Inc. All  Rights Reserved.
# 
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
# 
# -Redistribution of source code must retain the above copyright notice, 
# this list of conditions and the following disclaimer.
# 
# -Redistribution in binary form must reproduce the above copyright notice, 
# this list of conditions and the following disclaimer in the documentation  
# and/or other materials provided with the distribution.
# 
# Neither the name of Sun Microsystems, Inc. or the names of contributors may 
# be used to endorse or promote products derived from this software without 
# specific prior written permission.
# 
# This software is provided "AS IS," without a warranty of any kind. ALL EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES, INCLUDING ANY IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR NON-INFRINGEMENT, ARE HEREBY EXCLUDED. SUN MICROSYSTEMS, INC. ("SUN") AND ITS LICENSORS SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES. IN NO EVENT WILL SUN OR ITS LICENSORS BE LIABLE FOR ANY LOST REVENUE, PROFIT OR DATA, OR FOR DIRECT, INDIRECT, SPECIAL, CONSEQUENTIAL, INCIDENTAL OR PUNITIVE DAMAGES, HOWEVER CAUSED AND REGARDLESS OF THE THEORY OF LIABILITY, ARISING OUT OF THE USE OF OR INABILITY TO USE THIS SOFTWARE, EVEN IF SUN HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
# 
# You acknowledge that  this software is not designed or intended for use in the design, construction, operation or maintenance of any nuclear facility.
