<?php
// $Id: dns_add.php 3 2003-07-17 15:19:15Z will $
//
// ui for adding/modifying many DNS record types
$iam = '/base/dns/dns_add.php';
$parent = '/base/dns/records.php';

include("CobaltUI.php");
$Ui = new CobaltUI($sessionId, "base-dns"); 

// return the base ip address of a network
// as defined by dot-quad member ip and netmask
function get_network($ip = "127.0.0.1", $nm = "255.255.255.255") {
  $ip = split('[.]',$ip);
  $nm = split('[.]',$nm);
  for ($i=0; $i<4; $i++):
    $ip[$i] = (int) $ip[$i]; $nm[$i] = (int) $nm[$i];
    $nu[$i] .= $ip[$i] & $nm[$i];
  endfor;

  return join('.',$nu);
}

// mapping: lists a form field name to an object attribute.
//          note the many:1 mapping, this causes a case-map in update_cce()
$mapping = array (
  "type" => "type",
  "network" => "network",
  "a_host_name" => "hostname",
  "ptr_host_name" => "hostname",
  "cname_host_name" => "hostname",
  "mx_host_name" => "hostname",
  "subdom_host_name" => "hostname",
  "a_domain_name" => "domainname",
  "ptr_domain_name" => "domainname",
  "cname_domain_name" => "domainname",
  "mx_domain_name" => "domainname",
  "subdom_domain_name" => "domainname",
  "a_ip_address" => "ipaddr",
  "ptr_ip_address" => "ipaddr",
  "subnet_ip_address" => "ipaddr",
  "ptr_subnet_mask" => "netmask",
  "subnet_netmask" => "netmask",
  "mx_target_server" => "mail_server_name",
  "mx_priority" => "mail_server_priority",
  "cname_host_target" => "alias_hostname",
  "cname_domain_target" => "alias_domainname",
  "subdom_nameservers" => "delegate_pri_dns",
  "subnet_nameservers" => "delegate_pri_dns",
  "unused" => "delegate_sec_dns",
  "unused_prime" => "delegate_sec_dns" );

$nm_to_dec = array(
  "0.0.0.0"   => "0",
  "128.0.0.0" => "1",	"255.128.0.0" => "9",	"255.255.128.0" => "17",	"255.255.255.128" => "25",
  "192.0.0.0" => "2", 	"255.192.0.0" => "10",	"255.255.192.0" => "18",	"255.255.255.192" => "26",
  "224.0.0.0" => "3",	"255.224.0.0" => "11",	"255.255.224.0" => "19",	"255.255.255.224" => "27",
  "240.0.0.0" => "4",	"255.240.0.0" => "12",	"255.255.240.0" => "20",	"255.255.255.240" => "28",
  "248.0.0.0" => "5",	"255.248.0.0" => "13",	"255.255.248.0" => "21",	"255.255.255.248" => "29",
  "252.0.0.0" => "6",	"255.252.0.0" => "14",	"255.255.252.0" => "22",	"255.255.255.252" => "30",
  "254.0.0.0" => "7",	"255.254.0.0" => "15",	"255.255.254.0" => "23",	"255.255.255.254" => "31",
  "255.0.0.0" => "8",	"255.255.0.0" => "16",	"255.255.255.0" => "24",	"255.255.255.255" => "32" );
$dec_to_nm = array_flip($nm_to_dec);

// handler:
if (!$_TARGET) { $_TARGET = 'A'; }
$done = handle($Ui, $_TARGET, $mapping, $HTTP_POST_VARS, $HTTP_GET_VARS, $nm_to_dec);

# prevent PHP from sneakily adding new hidden fields:
if (is_array($HTTP_POST_VARS)) {
  $keys = array_keys($HTTP_POST_VARS);
  $index = array_keys($keys, "_LOAD"); array_splice($HTTP_POST_VARS, $index[0], 1);
  $index = array_keys($keys, "_save"); array_splice($HTTP_POST_VARS, $index[0], 1);
}

if ($HTTP_GET_VARS{'domauth'} != '') {
  $ret_url = $parent.'?domauth='.$HTTP_GET_VARS{'domauth'};
} elseif ($HTTP_GET_VARS{'netauth'} != '') {
  $ret_url = $parent.'?netauth='.urlencode($HTTP_GET_VARS{'netauth'});
} else {
  $ret_url = $parent;
}

$Ui->StartPage("AAS", $_TARGET ? $_TARGET : "DnsRecord", "");
$Ui->StartBlock((intval($_TARGET) > 0) ? "modify_dns_rec".$HTTP_GET_VARS{'TYPE'} : "create_dns_rec".$HTTP_GET_VARS{'TYPE'});

// Bail if we've saved successfully
if ($done) {
  $Ui->Redirect( $ret_url );
  exit();
}

// prep default values
if($HTTP_GET_VARS['netauth'] != '') {
  $net_defaults = split('/', urldecode($HTTP_GET_VARS['netauth']));
}
$dom_default = $HTTP_GET_VARS['domauth'];

// order is important here people...  PTR CNAME MX SUBDOM SUBNET else A

if ($HTTP_GET_VARS{'TYPE'} == 'PTR') {
  if ($Ui->Data['ptr_subnet_mask'] == '') { $Ui->Data['ptr_subnet_mask'] = $dec_to_nm[$net_defaults[1]]; }
  if ($Ui->Data['ptr_subnet_mask'] == '') { $Ui->Data['ptr_subnet_mask'] = '255.255.255.0'; }
  $Ui->IpAddress( "ptr_ip_address" );
  $Ui->IpAddress( "ptr_subnet_mask" );
  $Ui->DomainName( "ptr_host_name", array( "Optional" => 'loud' ) );
  $Ui->DomainName( "ptr_domain_name" );
  if ($Ui->Data['ptr_ip_address'] == '') { $Ui->Boolean( "ptr_generate_a" ); }
} elseif ($HTTP_GET_VARS{'TYPE'} == 'CNAME') {
  if ($Ui->Data['cname_domain_name'] == '') { $Ui->Data['cname_domain_name'] = $dom_default; }
  if ($Ui->Data['cname_domain_target'] == '') { $Ui->Data['cname_domain_target'] = $dom_default; }
  $Ui->DomainName( "cname_host_name" );  // optional alias hostname
  $Ui->DomainName( "cname_domain_name" ); 
  $Ui->DomainName( "cname_host_target", array( "Optional" => 'loud' ) );  // target hostname
  $Ui->DomainName( "cname_domain_target" );  // target domain
} elseif ($HTTP_GET_VARS{'TYPE'} == 'MX') {
  if ($Ui->Data['mx_domain_name'] == '') { $Ui->Data['mx_domain_name'] = $dom_default; }
  $Ui->DomainName( "mx_host_name", array( "Optional" => 'loud' ) ); 
  $Ui->DomainName( "mx_domain_name" ); 
  $Ui->DomainName( "mx_target_server" );
  // $Ui->DomainName( "mx_target_server", array( "Optional" => "silent" ) );
  $Ui->Alters( "mx_priority", array('very_high', 'high', 'low', 'very_low') ); 
} elseif ($HTTP_GET_VARS{'TYPE'} == 'SUBDOM') {
  if ($Ui->Data[''] == 'subdom_domain_name') { $Ui->Data['subdom_domain_name'] = $dom_default; }
  $Ui->DomainName( "subdom_host_name" ); 
  $Ui->DomainName( "subdom_domain_name" ); // should be read-only 
  $Ui->DomainName( "subdom_nameservers" );
} elseif ($HTTP_GET_VARS{'TYPE'} == 'SUBNET') {
  if ($Ui->Data['subnet_subnet_mask'] == '') { $Ui->Data['subnet_subnet_mask'] = $dec_to_nm[$net_defaults[1]]; }
  $Ui->IpAddress( "subnet_ip_address" );
  $Ui->IpAddress( "subnet_subnet_mask" );
  $Ui->DomainName( "subnet_nameservers" );
} else {
  if ($Ui->Data['a_domain_name'] == '') { $Ui->Data['a_domain_name'] = $dom_default; }
  $Ui->TextField( "a_host_name", array( "Optional" => "loud" ) );
  $Ui->DomainName( "a_domain_name" );
  $Ui->IpAddress( "a_ip_address" );
}

$Ui->AddButtons($ret_url);

$Ui->EndBlock();
$Ui->EndPage();

function handle(&$Ui, $target, &$mapping, &$post_vars, &$get_vars, &$nm_to_dec)
{
  // echo "<b>handle $target</b><br>";
  
  // Set Defaults that can't be grabbed from CCE....
  $Ui->Data["moderator"]="admin";

  $http_vars = array();
  if (is_array($post_vars)) { 
    $http_vars = array_merge($http_vars, $post_vars); 
  }
  if (is_array($get_vars)) {
    $http_vars = array_merge($http_vars, $get_vars);
  }

  if ($http_vars["_LOAD"]) {
    if (intval($target) > 0) {
      handle_load($Ui, intval($target)); 
    }
  } else {
    handle_post($Ui, $target, $mapping, $http_vars);
  }
  
  if ($post_vars["_save"]==1) {
    return update_cce($Ui, $target, $mapping, $http_vars, $nm_to_dec);
  }
  
  return 0;
}
  
function handle_load(&$Ui, $oid)
{
  // load object attributes
  $rec = $Ui->Cce->get($oid);
 
  // override the http get type
  if($rec['type'] == 'A') {
    $Ui->Data['a_host_name'] = $rec['hostname'];
    $Ui->Data['a_domain_name'] = $rec['domainname'];
    $Ui->Data['a_ip_address'] = $rec['ipaddr'];
    $HTTP_GET_VARS{'TYPE'} = 'A';
    $HTTP_GET_VARS{'domauth'} = $rec['domainname']; 

  } elseif($rec['type'] == 'PTR') {
    $Ui->Data['ptr_host_name'] = $rec['hostname'];
    $Ui->Data['ptr_domain_name'] = $rec['domainname'];
    $Ui->Data['ptr_ip_address'] = $rec['ipaddr'];
    $Ui->Data['ptr_subnet_mask'] = $rec['netmask'];
    $HTTP_GET_VARS{'TYPE'} = 'PTR';
    $HTTP_GET_VARS{'netauth'} = $rec['network']; 

  } elseif($rec['type'] == 'CNAME') {
    $Ui->Data['cname_host_name'] = $rec['hostname'];
    $Ui->Data['cname_domain_name'] = $rec['domainname'];
    $Ui->Data['cname_host_target'] = $rec['alias_hostname'];
    $Ui->Data['cname_domain_target'] = $rec['alias_domainname'];
    $HTTP_GET_VARS{'TYPE'} = 'CNAME';
    $HTTP_GET_VARS{'domauth'} = $rec['domainname']; 

  } elseif($rec['type'] == 'MX') {
    $Ui->Data['mx_host_name'] = $rec['hostname'];
    $Ui->Data['mx_domain_name'] = $rec['domainname'];
    $Ui->Data['mx_target_server'] = $rec['mail_server_name'];
    $Ui->Data['mx_priority'] = $rec['mail_server_priority'];
    $HTTP_GET_VARS{'TYPE'} = 'MX';
    $HTTP_GET_VARS{'domauth'} = $rec['domainname']; 

  } elseif($rec['type'] == 'NS') {
    // covers both subdomain and subnet delegations
    $Ui->Data['subdom_host_name'] = $rec['hostname'];
    $Ui->Data['subdom_domain_name'] = $rec['domainname'];
    $Ui->Data['subnet_ip_address'] = $rec['ipaddr'];
    $Ui->Data['subnet_netmask'] = $rec['netmask'];
    $Ui->Data['subnet_nameservers'] = $rec['delegate_pri_dns'];
    $HTTP_GET_VARS{'TYPE'} = 'SUBNET';
    $HTTP_GET_VARS{'netauth'} = $rec['network']; 
    if ($Data['subdom_domain_name'] != '') {
      $HTTP_GET_VARS{'TYPE'} = 'SUBDOM';
      $HTTP_GET_VARS{'domauth'} = $rec['domainname']; 
    }
  }
}

function handle_post(&$ui, $target, &$mapping, &$post_vars)
{
  while (list($key,$val) = each($mapping))
  {
    $ui->Data[$key] = $post_vars[$key];
  }
}

# translate post variables into an object hash based on $mapping.
# $mapping maps "Form Field Name" => "Object Attribute Name"
function map_vars($mapping, $post_vars)
{
  $obj = array();
  while (list($key,$val) = each($mapping))
  {
    if($post_vars[$key] != "") {
      $obj[$val] = $post_vars[$key];
    } elseif ( $val == "hostname" && 
               ! in_array ("hostname", array_keys ($obj))) {
      $obj[$val] = "";
    }

    // catchall lookup support
    if($val == "hostname" && ereg("\*", $post_vars[$key])) {
      $obj[$val] = "*";
    }
  }
  return $obj;
}

function update_cce(&$Ui, $target, $mapping, $http_vars, $nm_to_dec)
{
  $oid = 0;

  // create record; first determine type
  if($http_vars['a_domain_name'] != '') {
    $http_vars['type'] = 'A';
  } elseif($http_vars['ptr_ip_address'] != '') {
    $http_vars['type'] = 'PTR';
    $http_vars['network'] = get_network($http_vars['ptr_ip_address'], 
      $http_vars['ptr_subnet_mask']).'/'.$nm_to_dec[ $http_vars['ptr_subnet_mask'] ];
  } elseif($http_vars['cname_domain_name'] != '') {
    $http_vars['type'] = 'CNAME';
  } elseif($http_vars['mx_domain_name'] != '') {
    $http_vars['type'] = 'MX';
  } elseif($http_vars['subdom_host_name'] != '') {
    $http_vars['type'] = 'NS';
  } elseif($http_vars['subnet_ip_address'] != '') {
    $http_vars['type'] = 'NS';
    $http_vars['network'] = get_network($http_vars['subnet_ip_address'], 
      $http_vars['subnet_subnet_mask']).'/'.$nm_to_dec[ $http_vars['subnet_subnet_mask'] ];
  }
  
  if (intval($target) > 0) {
    // modify record, its type is fixed
    $oid = intval($target);
    $Ui->Cce->set ($oid, "", map_vars($mapping, $http_vars));
    // $Ui->Cce->set ($oid, "Archive", map_vars($mapping, $http_vars));

  } else {

    $class = $target;
    $oid = $Ui->Cce->create( 'DnsRecord', map_vars($mapping, $http_vars));
  
  }
  
  // blue light special, 2 records for the grief of 1
  // if($http_vars['ptr_generate_a'] != '') {
  if($http_vars['ptr_generate_a'] != '') {
    $http_vars['type'] = 'A';
    $oid = $Ui->Cce->create( 'DnsRecord', map_vars($mapping, $http_vars));
  }

  $flip_map = array_flip($mapping); // maps attributes -> form field names (1:many)

  // hack around 1:many reverse mapping
  if ($http_vars['type'] == 'PTR') {
    $flip_map['hostname'] = 'ptr_host_name';
    $flip_map['domainname'] = 'ptr_domain_name';
    $flip_map['ipaddr'] = 'ptr_ip_address';
    $flip_map['netmask'] = 'ptr_subnet_mask';
  } elseif ($http_vars['type'] == 'A') {
    $flip_map['hostname'] = 'a_host_name';
    $flip_map['domainname'] = 'a_domain_name';
    $flip_map['ipaddr'] = 'a_ip_address';
  } elseif ($http_vars['type'] == 'CNAME') {
    $flip_map['hostname'] = 'cname_host_name';
    $flip_map['domainname'] = 'cname_domain_name';
  } elseif ($http_vars['type'] == 'MX') {
    $flip_map['hostname'] = 'mx_host_name';
    $flip_map['domainname'] = 'mx_domain_name';
  } elseif ($http_vars['type'] == 'SUBDOM') {
    $flip_map['hostname'] = 'subdom_host_name';
    $flip_map['domainname'] = 'subdom_domain_name';
    $flip_map['delegate_pri_dns'] = 'subdom_nameservers';
  } elseif ($http_vars['type'] == 'SUBNET') {
    $flip_map['hostname'] = '';
    $flip_map['netmask'] = 'subnet_netmask';
    $flip_map['ipaddr'] = 'subnet_ip_address';
    $flip_map['delegate_pri_dns'] = 'subnet_nameservers';
  } 
  
  $Ui->report_errors($flip_map);

  return (count($errors) == 0);
}
  


/*
Copyright (c) 2003 Sun Microsystems, Inc. All  Rights Reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

-Redistribution of source code must retain the above copyright notice, this  list of conditions and the following disclaimer.

-Redistribution in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation and/or 
other materials provided with the distribution.

Neither the name of Sun Microsystems, Inc. or the names of contributors may 
be used to endorse or promote products derived from this software without 
specific prior written permission.

This software is provided "AS IS," without a warranty of any kind. ALL EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES, INCLUDING ANY IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR NON-INFRINGEMENT, ARE HEREBY EXCLUDED. SUN MICROSYSTEMS, INC. ("SUN") AND ITS LICENSORS SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES. IN NO EVENT WILL SUN OR ITS LICENSORS BE LIABLE FOR ANY LOST REVENUE, PROFIT OR DATA, OR FOR DIRECT, INDIRECT, SPECIAL, CONSEQUENTIAL, INCIDENTAL OR PUNITIVE DAMAGES, HOWEVER CAUSED AND REGARDLESS OF THE THEORY OF LIABILITY, ARISING OUT OF THE USE OF OR INABILITY TO USE THIS SOFTWARE, EVEN IF SUN HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

You acknowledge that  this software is not designed or intended for use in the design, construction, operation or maintenance of any nuclear facility.
*/
?>

