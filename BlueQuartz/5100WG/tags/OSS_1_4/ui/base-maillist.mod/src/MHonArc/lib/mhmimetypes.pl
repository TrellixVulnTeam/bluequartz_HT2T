##---------------------------------------------------------------------------##
##  File:
##	@(#) mhmimetypes.pl 1.4 00/01/15 17:54:32
##  Author:
##      Earl Hood       mhonarc@pobox.com
##  Description:
##	MIME type mappings.
##---------------------------------------------------------------------------##
##    MHonArc -- Internet mail-to-HTML converter
##    Copyright (C) 1998,1999	Earl Hood, mhonarc@pobox.com
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

$UnknownExt     = 'bin';

%CTExt = (
##-----------------------------------------------------------------------
##  Content-Type			Extension:Description
##-----------------------------------------------------------------------

    'application/astound',		'asd:Astound presentation',
    'application/envoy',		'evy:Envoy file',
    'application/fastman',		'lcc:fastman file',
    'application/fractals',		'fif:Fractal Image Format',
    'application/iges',			'iges:IGES file',
    'application/mac-binhex40', 	'hqx:Mac BinHex archive',
    'application/mathematica', 		'ma:Mathematica Notebook document',
    'application/mbedlet',		'mbd:mbedlet file',
    'application/msword',		'doc:MS-Word document',
    'application/octet-stream', 	'bin:Binary data',
    'application/oda', 			'oda:ODA file',
    'application/pdf', 			'pdf:Adobe PDF document',
    'application/pgp',  		'pgp:PGP message',
    'application/pgp-signature',	'pgp:PGP signature',
    'application/postscript', 		'ps,eps,ai:PostScript document',
    'application/rtf', 			'rtf:RTF file',
    'application/sgml',			'sgml:SGML document',
    'application/studiom',		'smp:Studio M file',
    'application/timbuktu',		'tbt:timbuktu file',
    'application/vis5d',		'v5d:Vis5D dataset',
    'application/vnd.framemaker',	'fm:FrameMaker document',
    'application/vnd.hp-hpgl',          'hpg,hpgl:HPGL file',
    'application/vnd.lotus-1-2-3',      '123,wk4,wk3,wk1:Lotus 1-2-3',
    'application/vnd.lotus-approach',   'apr,vew:Lotus Approach',
    'application/vnd.lotus-freelance',  'prz,pre:Lotus Freelance',
    'application/vnd.lotus-organizer',  'org,or3,or2:Lotus Organizer',
    'application/vnd.lotus-screencam',  'scm:Lotus Screencam',
    'application/vnd.lotus-wordpro',    'lwp,sam:Lotus WordPro',
    'application/vnd.mif', 		'mif:Frame MIF document',
    'application/vnd.ms-excel',         'xls:MS-Excel spreadsheet',
    'application/vnd.ms-powerpoint',    'ppt:MS-Powerpoint presentation',
    'application/vnd.ms-project',	'mpp:MS-Project file',
    'application/winhlp',		'hlp:WinHelp document',
    'application/wordperfect5.1',	'wp:WordPerfect 5.1 document',
    'application/x-asap',		'asp:asap file',
    'application/x-bcpio', 		'bcpio:BCPIO file',
    'application/x-bzip2', 		'bz2:BZip2 compressed data',
    'application/x-compress', 		'Z:Unix compressed data',
    'application/x-cpio', 		'cpio:CPIO file',
    'application/x-csh', 		'csh:C-Shell script',
    'application/x-dot',		'dot:dot file',
    'application/x-dvi', 		'dvi:TeX dvi file',
    'application/x-earthtime',		'etc:Earthtime file',
    'application/x-envoy',		'evy:Envoy file',
    'application/x-excel',		'xls:MS-Excel spreadsheet',
    'application/x-gtar', 		'gtar:GNU Unix tar archive',
    'application/x-gzip', 		'gz:GNU Zip compressed data',
    'application/x-hdf', 		'hdf:HDF file',
    'application/x-javascript',		'js:JavaScript source',
    'application/x-ksh',		'ksh:Korn Shell script',
    'application/x-latex', 		'latex:LaTeX document',
    'application/x-maker',		'fm:FrameMaker document',
    'application/x-mif', 		'mif:Frame MIF document',
    'application/x-mocha',		'moc:mocha file',
    'application/x-msaccess',		'mdb:MS-Access database',
    'application/x-mscardfile',		'crd:MS-CardFile',
    'application/x-msclip',		'clp:MS-Clip file',
    'application/x-msmediaview',	'm14:MS-Media View file',
    'application/x-msmetafile',		'wmf:MS-Metafile',
    'application/x-msmoney',		'mny:MS-Money file',
    'application/x-mspublisher',	'pub:MS-Publisher document',
    'application/x-msschedule',		'scd:MS-Schedule file',
    'application/x-msterminal',		'trm:MS-Terminal',
    'application/x-mswrite',		'wri:MS-Write document',
    'application/x-net-install',	'ins:Net Install file',
    'application/x-netcdf', 		'cdf:Cdf file',
    'application/x-ns-proxy-autoconfig','proxy:Netscape Proxy Auto Config',
    'application/x-patch',		'patch:Source code patch',
    'application/x-perl',		'pl:Perl program',
    'application/x-pointplus',		'css:pointplus file',
    'application/x-salsa',		'slc:salsa file',
    'application/x-script',		'script:A script file',
    'application/x-sh', 		'sh:Bourne shell script',
    'application/x-shar', 		'shar:Unix shell archive',
    'application/x-sprite',		'spr:sprite file',
    'application/x-stuffit',		'sit:Macintosh archive',
    'application/x-sv4cpio', 		'sv4cpio:SV4Cpio file',
    'application/x-sv4crc', 		'sv4crc:SV4Crc file',
    'application/x-tar', 		'tar:Unix tar archive',
    'application/x-tcl', 		'tcl:Tcl script',
    'application/x-tex', 		'tex:TeX document',
    'application/x-texinfo', 		'texinfo:TeXInfo document',
    'application/x-timbuktu',		'tbp:timbuktu file',
    'application/x-tkined',		'tki:tkined file',
    'application/x-troff', 		'roff:Troff document',
    'application/x-troff-man', 		'man:Unix manual page',
    'application/x-troff-me', 		'me:Troff ME-macros document',
    'application/x-troff-ms', 		'ms:Troff MS-macros document',
    'application/x-ustar', 		'ustar:UStar file',
    'application/x-wais-source', 	'src:WAIS Source',
    'application/x-zip-compressed',	'zip:Zip compressed data',
    'application/zip', 			'zip:Zip archive',

    'audio/basic', 			'snd:Basic audio',
    'audio/echospeech',			'es:Echospeech audio',
    'audio/microsoft-wav', 		'wav:Wave audio',
    'audio/midi',			'midi:MIDI audio',
    'audio/wav', 			'wav:Wave audio',
    'audio/x-aiff', 			'aif,aiff,aifc:AIF audio',
    'audio/x-epac',			'pae:epac audio',
    'audio/x-midi',			'midi:MIDI audio',
    'audio/x-mpeg',			'mp2:MPEG audio',
    'audio/x-pac',			'pac:pac audio',
    'audio/x-pn-realaudio',		'ra,ram:PN Realaudio',
    'audio/x-wav', 			'wav:Wave audio',

    'chemical/chem3d',			'c3d:Chem3d chemical test',
    'chemical/chemdraw',		'chm:Chemdraw chemical test',
    'chemical/cif',			'cif:CIF chemical test',
    'chemical/cml',			'cml:CML chemical test',
    'chemical/cmsl',			'cml:Chemical Structure Markup',
    'chemical/cxf',			'cxf:Chemical Exhange Format file',
    'chemical/daylight-smiles',		'smi:SMILES format file',
    'chemical/embl-dl-nucleotide',	'emb,embl:EMBL nucleotide format file',
    'chemical/gaussian',		'gau:Gaussian data',
    'chemical/gaussian-input',		'gau:Gaussian input data',
    'chemical/gaussian-log',		'gal:Gaussian log',
    'chemical/gcg8-sequence',		'gcg:GCG format file',
    'chemical/genbank',			'gen:GENbank data',
    'chemical/jcamp-dx',		'jdx:Jcamp chemical spectra test',
    'chemical/kinemage',		'kin:Kinemage',
    'chemical/macromodel-input',	'mmd,mmod:Macromodel chemical test',
    'chemical/mopac-input',		'gau:Mopac chemical test',
    'chemical/mdl-molfile',		'mol:MOL mdl chemical test',
    'chemical/mdl-rdf',			'rdf:RDF chemical test',
    'chemical/mdl-rxn',			'rxn:RXN chemical test',
    'chemical/mdl-sdf',			'sdf:SDF chemical test',
    'chemical/mdl-tgf',			'tgf:TGF chemical test',
    'chemical/mif',			'mif:MIF chemical test',
    'chemical/mmd',			'mmd:Macromodel data',
    'chemical/mopac-input',		'mop:MOPAC data ',
    'chemical/ncbi-asn1',		'asn:NCBI data',
    'chemical/pdb',			'pdb:Protein Databank data',
    'chemical/rosdal',			'ros:Rosdal data',
    'chemical/xyz',			'xyz:Xmol XYZ data',

    'image/bmp',			'bmp:Windows bitmap',
    'image/cgm',			'cgm:Computer Graphics Metafile',
    'image/fif',			'fif:Fractal Image Format image',
    'image/g3fax',			'g3f:Group III FAX image',
    'image/gif',			'gif:GIF image',
    'image/ief',			'ief:IEF image',
    'image/ifs',			'ifs:IFS image',
    'image/jpeg',			'jpg,jpeg,jpe:JPEG image',
    'image/png',			'png:PNG image',
    'image/tiff',			'tif,tiff:TIFF image',
    'image/vnd',			'dwg:VND image',
    'image/wavelet',			'wi:Wavelet image',
    'image/x-cmu-raster',		'ras:CMU raster',
    'image/x-pbm',			'pbm:Portable bitmap',
    'image/x-pcx',			'pcx:PCX image',
    'image/x-pgm',			'pgm:Portable graymap',
    'image/x-pict',			'pict:Mac PICT image',
    'image/x-pnm',			'pnm:Portable anymap',
    'image/x-portable-anymap',		'pnm:Portable anymap',
    'image/x-portable-bitmap',		'pbm:Portable bitmap',
    'image/x-portable-graymap',		'pgm:Portable graymap',
    'image/x-portable-pixmap',		'ppm:Portable pixmap',
    'image/x-ppm',			'ppm:Portable pixmap',
    'image/x-rgb',			'rgb:RGB image',
    'image/x-xbitmap',			'xbm:X bitmap',
    'image/x-xbm',			'xbm:X bitmap',
    'image/x-xpixmap',			'xpm:X pixmap',
    'image/x-xpm',			'xpm:X pixmap',
    'image/x-xwd',			'xwd:X window dump',
    'image/x-xwindowdump',		'xwd:X window dump',

    'model/iges',			'iges:IGES model',
    'model/vrml',			'wrl:VRML model',
    'model/mesh',			'mesh:Mesh model',

    'text/enriched',			'rtx:Text-enriched document',
    'text/html',			'html:HTML document',
    'text/plain',			'txt:Text document',
    'text/richtext',			'rtx:Richtext document',
    'text/setext',			'stx:Setext document',
    'text/sgml',			'sgml:SGML document',
    'text/tab-separated-values',	'tsv:Tab separated values',
    'text/x-speech',			'talk:Speech document',

    'video/isivideo',			'fvi:isi video',
    'video/mpeg',			'mpg,mpeg,mpe:MPEG movie',
    'video/msvideo',			'avi:MS Video',
    'video/quicktime',			'mov,qt:QuickTime movie',
    'video/vivo',			'viv:vivo video',
    'video/wavelet',			'wv:Wavelet video',
    'video/x-sgi-movie',		'movie:SGI movie',

);

##---------------------------------------------------------------------------
##	get_mime_ext(): Get the prefered filename extension and a
##	a brief description of a given mime type.
##
sub get_mime_ext {
    my $ctype = lc shift;
    my($ext, $desc) = (undef, undef);

    if (defined($CTExt{$ctype})) {
	($ext, $desc) = split(/:/, $CTExt{$ctype}, 2);
    } elsif (($ctype =~ s|/x-|/|) && defined($CTExt{$ctype})) {
	($ext, $desc) = split(/:/, $CTExt{$ctype}, 2);
    }
    if (defined($ext)) {
	$ext = (split(/,/, $ext))[0];
    } else {
	$ext = $UnknownExt;
	$desc = $ctype;
    }
    ($ext, $desc);
}

##---------------------------------------------------------------------------
##	write_attachment(): Write data to a file with a given content-type.
##	Function can be used by content-type filters for writing data
##	to a file.
##
sub write_attachment {
    my $ctype	= lc shift;
    my $sref	= shift;
    my $path	= shift;
    my $fname	= shift;
    my $inext	= shift;
    my($cnt, $pre, $ext, $pathname);

    local(*OUTFILE);

    $pathname = $OUTDIR;
    if ($path) {
	$pathname .= $DIRSEP . $path;
	mkdir($pathname, 0777);
    }

    ## If no filename specified, generate it
    if (!$fname) {
	($cnt, $pre, $ext) = get_cnt($ctype, $pathname, $inext);
	$fname = $pre . $cnt . '.' . $ext;

    ## Else, filename given
    } else {
	$fname =~ tr/ \t\n\r/_/;	# Convert spaces to underscore
    }

    ## Set pathname for file
    $pathname .= $DIRSEP . $fname;

    if (open(OUTFILE, "> $pathname")) {
	binmode(OUTFILE);		# For MS-DOS
	print OUTFILE $$sref;
	close(OUTFILE);
    } else {
	warn qq/Warning: Unable to create "$pathname": $!\n/;
    }

    join("",
	 ($mhonarc::SINGLE ? $mhonarc::OUTDIR.$mhonarc::DIRSEP : ""),
	 ($path ? join($mhonarc::DIRSEP,$path,$fname) : $fname));
}

##---------------------------------------------------------------------------
##	get_cnt(): Function that returns a list which can be used to
##	generate a unique filename for a given content-type.
##
sub get_cnt {
    my $ctype 	= shift;		# content-type
    my $dir 	= shift || $CURDIR;	# directory
    my $inext 	= shift;		# passed in extension (optional)

    my(@files)  = ();
    my $ext 	= $inext || (get_mime_ext($ctype))[0];
    my $pre 	= $ext;
    my $cnt	= -1;
    local(*DIR);

    substr($pre, 3) = "" if length($pre) > 3;

    if (!opendir(DIR, $dir)) {
	warn qq/Warning: Unable to open "$dir": $!\n/;
    } else {
	@files = sort file_numeric grep(/^$pre\d+\.$ext$/i, readdir(DIR));
	closedir(DIR);
	if (@files) {
	    ($cnt) = $files[$#files] =~ /(\d+)/;
	}
    }
    ++$cnt;
    (sprintf("%05d", $cnt), $pre, $ext);
}

##---------------------------------------------------------------------------

sub file_numeric {
    ($A) = $a =~ /(\d+)/;
    ($B) = $b =~ /(\d+)/;
    $A <=> $B;
}

##---------------------------------------------------------------------------

sub dump_ctext_hash {
    local($_);
    foreach (sort keys %CTExt) {
	print STDERR $_,":",$CTExt{$_},"\n";
    }
}

##---------------------------------------------------------------------------
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
