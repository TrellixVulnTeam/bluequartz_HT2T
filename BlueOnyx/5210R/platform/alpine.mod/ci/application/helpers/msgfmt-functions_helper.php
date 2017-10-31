<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');


/**
 * php-msgfmt
 *
 * php-msgfmt is dual-licensed under
 *   the GNU Lesser General Public License, version 2.1, and
 *   the Apache License, version 2.0.
 * 
 * For the terms of the licenses, see the LICENSE-LGPL.txt and LICENSE-AL2.txt
 * files, respectively.
 *
 *
 * Copyright (C) 2007 Matthias Bauer
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License, version 2.1, as published by the Free Software Foundation.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 *
 * Copyright 2007 Matthias Bauer
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * @package php-msgfmt
 * @version $Id$
 * @copyright 2007 Matthias Bauer
 * @source http://wordpress-soc-2007.googlecode.com/svn/trunk/moeffju/php-msgfmt/
 * @author Matthias Bauer
 * @license http://opensource.org/licenses/lgpl-license.php GNU Lesser General Public License 2.1
 * @license http://opensource.org/licenses/apache2.0.php Apache License 2.0
 */

function _po_clean_helper($x) {
	if (is_array($x)) {
		foreach ($x as $k => $v) {
			$x[$k]= _po_clean_helper($v);
		}
	} else {
		if ($x[0] == '"')
			$x= substr($x, 1, -1);
		$x= str_replace("\"\n\"", '', $x);
		$x= str_replace('$', '\\$', $x);
		$x= @ eval ("return \"$x\";");
	}
	return $x;
}

/* Parse gettext .po files. */
/* @link http://www.gnu.org/software/gettext/manual/gettext.html#PO-Files */
function parse_po_file($in) {
	// read .po file
	$fc= file_get_contents($in);
	// normalize newlines
	$fc= str_replace(array (
		"\r\n",
		"\r"
	), array (
		"\n",
		"\n"
	), $fc);

	// results array
	$hash= array ();
	// temporary array
	$temp= array ();
	// state
	$state= null;
	$fuzzy= FALSE;

	// iterate over lines
	foreach (explode("\n", $fc) as $line) {
		$line= trim($line);
		if ($line === '') {
			continue;
		}
		$ptrn = '/#/';
		if (!preg_match($ptrn, $line)) {

			list ($key, $data)= explode(' ', $line, 2);

			switch ($key) {

				case '#,' : // flag...
					$fuzzy= in_array('fuzzy', preg_split('/,\s*/', $data));
				case '#' : // translator-comments
				case '#.' : // extracted-comments
				case '#:' : // reference...
				case '#|' : // msgid previous-untranslated-string
					// start a new entry
					if (sizeof($temp) && array_key_exists('msgid', $temp) && array_key_exists('msgstr', $temp)) {
						if (!$fuzzy)
							$hash[]= $temp;
						$temp= array ();
						$state= null;
						$fuzzy= false;
					}
					//break;
				case 'msgctxt' :
					// context
				case 'msgid' :
					$state= $key;
					$temp[$data]= "";
					$msgid = $data;
					// untranslated-string
				case 'msgid_plural' :
					// untranslated-string-plural
					break;
				case 'msgstr' :
					// translated-string
					$state= 'msgstr';
					$temp[$msgid]= $data;
					break;
			}
		}
	}
	return $temp;
}

/* Write a GNU gettext style machine object. */
/* @link http://www.gnu.org/software/gettext/manual/gettext.html#MO-Files */
function write_mo_file($hash, $out) {
	// sort by msgid
	ksort($hash, SORT_STRING);
	// our mo file data
	$mo= '';
	// header data
	$offsets= array ();
	$ids= '';
	$strings= '';

	foreach ($hash as $entry) {
		$id= $entry['msgid'];
		if (isset ($entry['msgid_plural']))
			$id .= "\x00" . $entry['msgid_plural'];
		// context is merged into id, separated by EOT (\x04)
		if (array_key_exists('msgctxt', $entry))
			$id= $entry['msgctxt'] . "\x04" . $id;
		// plural msgstrs are NUL-separated
		$str= implode("\x00", $entry['msgstr']);
		// keep track of offsets
		$offsets[]= array (
			strlen($ids
		), strlen($id), strlen($strings), strlen($str));
		// plural msgids are not stored (?)
		$ids .= $id . "\x00";
		$strings .= $str . "\x00";
	}

	// keys start after the header (7 words) + index tables ($#hash * 4 words)
	$key_start= 7 * 4 + sizeof($hash) * 4 * 4;
	// values start right after the keys
	$value_start= $key_start +strlen($ids);
	// first all key offsets, then all value offsets
	$key_offsets= array ();
	$value_offsets= array ();
	// calculate
	foreach ($offsets as $v) {
		list ($o1, $l1, $o2, $l2)= $v;
		$key_offsets[]= $l1;
		$key_offsets[]= $o1 + $key_start;
		$value_offsets[]= $l2;
		$value_offsets[]= $o2 + $value_start;
	}
	$offsets= array_merge($key_offsets, $value_offsets);

	// write header
	$mo .= pack('Iiiiiii', 0x950412de, // magic number
	0, // version
	sizeof($hash), // number of entries in the catalog
	7 * 4, // key index offset
	7 * 4 + sizeof($hash) * 8, // value index offset,
	0, // hashtable size (unused, thus 0)
	$key_start // hashtable offset
	);
	// offsets
	foreach ($offsets as $offset)
		$mo .= pack('i', $offset);
	// ids
	$mo .= $ids;
	// strings
	$mo .= $strings;

	file_put_contents($out, $mo);
}

?>
