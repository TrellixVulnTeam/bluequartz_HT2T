# MailList.pm
# $Id: MailList.pm 576 2005-09-05 10:26:24Z shibuya $
#
# common functions shared between MailList handlers.  Fun fun fun.
#
# FIXME: Replace Majordomo with something that isn't such a hack.

package MailList;

use lib qw( /usr/sausalito/perl );
use Sauce::Util;
use CCE;

# configuration stuff:
my $Majordomo_dir = '/usr/local/majordomo';
my $Lists_dir = $Majordomo_dir . '/lists';
my $Majordomo_user = 'mail';
my $Majordomo_group = 'daemon';
my $Majordomo_uid = scalar (getpwnam($Majordomo_user));
my $Majordomo_gid = scalar (getgrnam($Majordomo_group));

sub get_listfile {
  my $obj = shift;

  my $listfile = ${Lists_dir} . '/' . $obj->{name};

  $listfile = $Majordomo_dir.'/sites/'.$obj->{site}.'/lists/'.$obj->{name} 
	if ($obj->{site});   

  return $listfile;
}

# my ($ok) = rewrite_members($obj)
# create subscriber list from the MailList object
sub rewrite_members
{
  my $obj = shift;

  # extract information about the list...
  my $list = $obj->{name};

  # sorry about the ugly perl code here, it's efficient:
  my @local_recips = CCE->scalar_to_array($obj->{local_recips});
  my @remote_recips = CCE->scalar_to_array($obj->{remote_recips});
  my $listfile = &get_listfile($obj);

  # lock the members list:
  Sauce::Util::lockfile($listfile);

  # rewrite the members list:
  Sauce::Util::modifyfile("$listfile");
  unlink($listfile);
  system('rm', '-rf', $listfile) if (-e $listfile);
  open(LIST, ">$listfile");

  my %members = map { $_ => 1 } (
	@local_recips, 
	@remote_recips,
  );
  my @members = sort keys %members;
  if ($obj->{group}) {
	push (@members, $obj->{group} . "_alias");
  }
  if ($#members >= 0) {
	print LIST join("\n",@members),"\n";
  } else {
	print LIST "nobody\n"; # every club needs a member even nobody
  }
  close(LIST);

  Sauce::Util::chmodfile(0640, $listfile);
  Sauce::Util::chownfile($Majordomo_uid, $Majordomo_gid, $listfile);

  # unlock the members list:
  Sauce::Util::unlockfile($listfile);
}

# my ($ok) = rewrite_config($cce, $obj)
# create subscriber list from the MailList object
sub rewrite_config
{
  my ($cce, $obj) = @_;
  my $ret = 1;
  my $fqdn = '';

  if ($obj->{site}) {
    my ($vs_oid) = $cce->find('Vsite', { 'name' => $obj->{site} });
    my ($ok, $vsite) = $cce->get($vs_oid);
    if (!$ok) {
      $cce->bye('FAIL', '[[base-maillist.systemError]]');
      exit(1);
    }
    $fqdn = $vsite->{fqdn};
  }

  my $starttag = "#AUTOSTART";
  my $stoptag = "#AUTOSTOP";
  my $data;
  
  # configure the list password:
  $password = $obj->{apassword};
  if (!$password) {
  	my @l = ('a' .. 'z', 'A' .. 'Z', '1' .. '9');
    my $l = sub { return int(rand($#l+1)); };
  	$password = join("",@l[(&$l(), &$l(), &$l(), &$l(), &$l(), &$l(), &$l(), &$l())]);
  }
  push (@data, "admin_passwd = $password");
  push (@data, "approve_passwd = $password");
  
  # configure some standard stuff
  push (@data,
    "administrivia = no",  # all majordomo commands must be sent to majordomo
    "advertise << END\n/.*/\nEND", # always advertise
    "noadvertise << END\nEND", # never don't advertise
    "who_access = list", # only list members may run 'who'
    "subject_prefix = [\$LIST] ", # prefix listname to subject
    "message_headers << END\nX-Majordomo-Version: \$VERSION\nEND",
  );
  
  # configure subscription policy
  {
    my $policy = "auto+confirm"; # default
    if ($obj->{subPolicy} =~ m/closed/) {
  	  $policy = 'closed';
    }
    if ($obj->{subPolicy} =~ m/open/) {
  	  $policy = 'open';
    }
    if ($obj->{subPolicy} =~ m/confirm/) {
  	  $policy = 'auto+confirm';
    }
    push (@data, "subscribe_policy = $policy");
  }
  
  # configure unsubscription policy
  push (@data, "unsubscribe_policy = open");

  # configure posting policy
  $_ = $obj->{postPolicy};
  if (m/moderated/) {
    my $mod = $obj->{moderator} || 'admin';
    push (@data,
      "moderate = yes",
      "moderator = $mod",
      );
  }
  elsif (m/any/) {
  	# do nothing
	push (@data, "restrict_post = "); # majordomo needs this. :-b
  }  
  else {
  	# policy = members
	my $str = "restrict_post = $obj->{name}:$obj->{name}.administrator";
	if ($obj->{group}) {
	  $str .= ':/etc/group.d/' . $obj->{group};
	}
    	push (@data, $str);
  }

  # disable mungedomain this may break the qube, but the qube suffers
  # from the same spoofing vulnerability--pbaltz
  # push(@data, "mungedomain = yes");

  # maxlength
  if ($obj->{maxlength}) {
	push (@data, "maxlength = ".$obj->{maxlength});
  }

  if ($obj->{replyToList}) {
	push (@data, "reply_to = $obj->{name}\@$fqdn");
  } else {
	push (@data, "reply_to = \$SENDER");
  }

  # fix the stupid majordome dir permissions cause the rpm doesn't
  Sauce::Util::chownfile($Majordomo_uid, $Majordomo_gid, "/usr/local/majordomo");
  Sauce::Util::chmodfile(0700, "/usr/local/majordomo"); # else majordomo no workee.
  
  # edit the file:
  my $name = $obj->{name};
  Sauce::Util::makedirectory("/usr/local/majordomo/lists",0700);
  Sauce::Util::chmodfile(0700, "/usr/local/majordomo/lists");


  my $listfile = &get_listfile($obj);

  # this is a cheap trick, but it works and keeps the evil warnings away
  Sauce::Util::modifyfile($listfile.".config");
  system ("/bin/touch", $listfile.".config");
  Sauce::Util::chownfile($Majordomo_uid, $Majordomo_gid, $listfile.".config");
  Sauce::Util::chmodfile(0640, $listfile.".config");
  $ret = Sauce::Util::replaceblock(
	$listfile.".config",
  	$starttag, join("\n",@data), $stoptag);

  # update the admin file
  {
  	my $fn = $listfile.".administrator";
	my $mod = $obj->{moderator} || "";
	Sauce::Util::editfile( $fn, 
		sub { 
			my ($fin, $fout) = (shift, shift);
			print $fout $mod,"\n"; 
		} );
	Sauce::Util::chownfile($Majordomo_uid, $Majordomo_gid, $fn);
	Sauce::Util::chmodfile(0640, $fn);
  };

  return $ret;
}

# munge the local_recips and moderator properties to make sure they
# are in the form user@fqdn
sub munge_members
{
	my ($cce, $mail_list) = @_;

	my $fqdn = '';
	if ($mail_list->{site})
	{
		my ($vs_oid) = $cce->find('Vsite', { 'name' => $mail_list->{site} });
		my ($ok, $vsite) = $cce->get($vs_oid);
		if (!$ok)
		{
			$cce->bye('FAIL', '[[base-maillist.systemError]]');
			exit(1);
		}
		$fqdn = $vsite->{fqdn};
	}
	else
	{
		my ($sys_oid) = $cce->find('System');
		my ($ok, $sys) = $cce->get($sys_oid);
		if (!$ok)
		{
			$cce->bye('FAIL', '[[base-maillist.systemError]]');
			exit(1);
		}
	
		$fqdn = $sys->{hostname} . '.' . $sys->{domainname};
	}
	
	my @locals = $cce->scalar_to_array($mail_list->{local_recips});
	# munge the moderator too
	push @locals, $mail_list->{moderator};

	for (my $i = 0; $i < scalar(@locals); $i++)
	{
		# skip blank entries
		if ($locals[$i] =~ /^\s*$/) { next; }
	
		# check to see if it is already correct
		if ($locals[$i] =~ /\@/) { next; }
	
		$locals[$i] .= "\@$fqdn";
	}
	
	$mail_list->{moderator} = pop(@locals);
	$mail_list->{local_recips} = $cce->array_to_scalar(@locals);
}

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
