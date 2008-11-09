#!/usr/bin/perl -I /usr/sausalito/perl

use Sauce::Util::SecurityLevels;

my $sec = new SecurityLevels();

$sec->updateSecurityLevels(
	'adminUser',
	'[[base-sauce-basic.capgroup_adminUser]]',
	'[[base-sauce-basic.capgroup_adminUser_help]]',
	'createUser',
	'destroyUser',
	'modifyUser',
	'modifyUserDefaults'
);

$sec->updateSecurityLevels(
	'adminWorkgroup',
	'[[base-workgroup.capgroup_adminWorkgroup]]',
	'[[base-workgroup.capgroup_adminWorkgroup_help]]',
	'createWorkgroup',
	'modifyWorkgroup',
	'destroyWorkgroup',
	'modifyWorkgroupDefaults'
);

$sec->updateSecurityLevels(
	'adminUserGroupMailingList',
	'[[base-sauce-basic.capgroup_adminUserGroupMailingList]]',
	'[[base-sauce-basic.capgroup_adminUserGroupMailingList_help]]',
	'adminUser',
	'adminWorkgroup', 
	'createMaillist',
	'destroyMaillist',
	'modifyMaillist',
	'modifySystemLdapImport'
);
$sec->setSortOrder(20);

# power
$sec->updateSecurityLevels(
	'adminPower',
	'[[base-power.capgroup_adminPower]]',
	'[[base-power.capgroup_adminPower_help]]',
	'modifySystemPower'
);
$sec->setSortOrder(170);

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
