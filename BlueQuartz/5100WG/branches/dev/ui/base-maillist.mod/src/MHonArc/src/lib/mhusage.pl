##---------------------------------------------------------------------------##
##  File:
##      @(#) mhusage.pl 2.13 00/02/13 03:28:52
##  Author:
##      Earl Hood       mhonarc@pobox.com
##  Description:
##      Usage output.  Just require the file to have usage info
##	printed to STDOUT.
##---------------------------------------------------------------------------##
##    MHonArc -- Internet mail-to-HTML converter
##    Copyright (C) 1995-1999   Earl Hood, mhonarc@pobox.com
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

sub mhusage {
    my($usefh, $close);
    local(*PAGER);
    PAGERCHECK: {
	if ($UNIX &&
	    (($ENV{'PAGER'} && open(PAGER, "| $ENV{'PAGER'}")) ||
	     (open(PAGER, "| more")))) {
	    $usefh = \*PAGER;
	    $close = 1;
	    last PAGERCHECK;
	}
	$usefh = \*STDOUT;
	$close = 0;
    }
    my($curfh) = select($usefh);

    print <<EndOfUsage;
Usage:  $PROG [<options>] <mailfolder> ...
        $PROG -rmm [<options>] <msg> ...
        $PROG -annotate [-notetext <text>] <msg> ...

Description:
  MHonArc is a highly customizable Perl program for converting mail,
  encoded with MIME, into HTML archives.  MHonArc supports the conversion
  of UUCP-style mailbox files and MH style mail folders.  The -single
  option can be used to convert a single mail message to standard output.

  Read the full documentation included with the distribution for more
  complete usage information.

Options:
  -add                     : Add message(s) to archive
  -afs                     : Skip archive directory permission check
  -addressmodifycode <exp> : Perl expressions for modifying addresses
  -annotate                : Add an annotation to message(s)
  -archive                 : Generate archive related files (the default)
  -authsort                : Sort messages by author
  -checknoarchive          : Check for "no archive" flags in messages
  -conlen                  : Honor Content-Length fields
  -datefields <list>       : Fields to determine the date of a message
  -decodeheads             : Decode decode-only charset data when reading mail
  -definevar <varlist>     : Define custom resource variables
  -dbfile <name>           : Name of MHonArc database file
                             (def: ".mhonarc.db")
  -doc                     : Print link to doc at end of index page
  -docurl <url>            : URL to MHonArc documentation
                             (def: "http://www.oac.uci.edu/indiv/ehood/
                                    mhonarc.html")
  -editidx                 : Edit/change index page(s) and messages, only
  -expiredate <date>       : Message cut-off date
  -expireage <secs>        : Time from current when messages expire
  -folrefs                 : Print links to follow-ups/references
  -force                   : Perform archive operations even if unable to lock
  -footer <file>           : Include File for bottom of index page
  -fromfields <list>       : Fields to detemine whom the message is from
  -genidx                  : Output index to stdout based upon archive contents
  -gmtdatefmt <fmt>        : Format for GMT date
  -gzipexe <file>          : Pathname of Gzip executable
                             (def: "gzip")
  -gzipfiles               : Gzip files
  -gziplinks               : Add ".gz" to filenames in links
  -header <file>           : User text to include at top of index page
  -help                    : This message
  -htmlext <ext>           : Filename extension for generated HTML files
                             (def: "html")
  -idxfname <name>         : Name of index page
                             (def: "maillist.html")
  -idxprefix <string>      : Filename prefix for multi-page main index
                             (def: "mail")
  -idxsize <#>             : Maximum number of messages shown in indexes
  -localdatefmt <fmt>      : Format for local date
  -lock                    : Do archive locking (default)
  -lockdelay <#>           : Time delay, in seconds, between lock tries
                             (def: "3")
  -locktries <#>           : Maximum number of tries in locking an archive
                             (def: "10")
  -mailtourl <url>         : URL to use for e-mail address hyperlinks
                             (def: "mailto:\$TO\$")
  -main                    : Create a main index
  -maxsize <#>             : Maximum number of messages allowed in archive
  -mhpattern <exp>         : Perl expression for message files in a directory
                             (def: "^\\d+\$")
  -modtime                 : Set modification time on files to message date
  -months <list>           : Month names
  -monthsabr <list>        : Abbreviated month names
  -msgpgs                  : Create message pages (the default)
  -msgprefix <prefix>      : Filename prefix for message HTML files
                             (def: "msg")
  -msgexcfilter <exp>      : Perl expression(s) for selective message exclusion
  -msgsep <exp>            : Message separator (Perl) regex for mbox files
                             (def: "^From ")
  -multipg                 : Generate multi-page indexes
  -news                    : Add links to newsgroups (the default)
  -noarchive               : Do not generate archive related files
  -noauthsort              : Do not sort messages by author
  -nochecknoarchive        : Ignore "no archive" flags in messages
  -noconlen                : Ignore Content-Length fields (the default)
  -nodecodeheads           : Leave message headers "as is" when read
  -nodoc                   : Do not print link to doc at end of index page
  -nofolrefs               : Do not print links to follow-ups/references
  -nogzipfiles             : Do not Gzip files (the default)
  -nosaveresources         : Do not save resource values in DB
  -nogziplinks             : Do not add ".gz" to filenames in links
  -nolock                  : Do not lock archive
  -nomailto                : Do not add in mailto links for e-mail addresses
  -nomain                  : Do not create a main index
  -nomodtime               : Do not set mod time on files to message date
  -nomsgpgs                : Do not create message pages
  -nomultipg               : Do not generate multi-page indexes
  -nonews                  : Do not add links to newsgroups
  -noposixstrftime         : Do not use POSIX::strftime() to process time
                             format (the default)
  -noreverse               : List messages in normal order (the default)
  -nosort                  : Do not sort messages
  -nospammode              : Do not obfuscate addresses
  -nosubjectthreads        : Do not check subjects for threads
  -nosubsort               : Do not sort messages by subject
  -notetext <text>         : Text data of annotation if -annotation specified
  -nothread                : Do not create threaded index
  -notreverse              : List threads in order (the default)
  -notsort                 : List threads by ordered processed
  -notsubsort              : Do not list threads by subject
  -nourl                   : Do not make URL hyperlinks
  -otherindex <files>      : Other rcfile for extra index
  -outdir <path>           : Destination/location of HTML mail archive
                             (def: ".")
  -pagenum <page>          : Output specified page if -genidx and -multipg
  -perlinc <list>          : List of paths to search for MIME filters
  -posixstrftime           : Use POSIX::strftime() to process time formats
  -quiet                   : Suppress status messages during execution
  -rcfile <file>           : Resource file for MHonArc
  -reverse                 : List messages in reverse order
  -rmm                     : Remove messages from archive
  -savemem                 : Write message data while processing
  -saveresources           : Save resource values in DB (the default)
  -scan                    : List out archive contents to stdout
  -single                  : Convert a single message to HTML (no archive ops)
  -sort                    : Sort messages by date (the default)
  -spammode                : Obfuscate addresses
  -stderr <file>           : File to send stderr messages to
  -stdin <file>            : File to treat as standard input
  -stdout <file>           : File to send stdout messages to
  -subjectarticlerxp <rxp> : Regex for leading articles in subjects
  -subjectreplyrxp <rxp>   : Regex for leading reply string in subjects
  -subjectstripcode <exp>  : Perl expressions for modifying subjects
  -subjectthreads          : Check subjects for threads
  -subsort                 : Sort message by subject
  -thread                  : Create threaded index (the default)
  -tidxfname <name>        : Filename of threaded index page
                             (def: "threads.html")
  -tidxprefix <string>     : Filename prefix for multi-page thread index
                             (def: "thrd")
  -time                    : Print to stderr CPU time used to process mail
  -title <string>          : Title of main index page
                             (def: "Mail Index")
  -tlevels <#>             : Maximum # of nested lists in threaded index
                             (def: "3")
  -treverse                : List threads in reverse order
  -tslice <#:#>            : Set size of thread slice listing
  -tsort                   : List threads by date (the default)
  -tsubsort                : List threads by subject
  -ttitle <string>         : Title of thread index page
                             (def: "Mail Thread Index")
  -umask <umask>           : Umask of MHonArc process (Unix only)
  -url                     : Make URL hyperlinks (the default)
  -v                       : Print version information
  -varregex <regex>        : Perl regex matching resource variables
  -weekdays <list>         : Weekday names
  -weekdaysabr <list>      : Abbreviated weekday names

  The following options can be specified multiple times: -definevar,
  -notetext, -otherindex, -perlinc, -rcfile.

Version:
$VINFO
EndOfUsage

    close($usefh)  if $close;
    select($curfh);
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
