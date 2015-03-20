#!/usr/bin/perl -I/usr/sausalito/perl
# $Id: import_php_ini_settings.pl
#
# This script parses php.ini and brings CODB up to date on how PHP is configured.
# This also handles third party extra-PHP installs.
#
# Additionally it updates the PHP-FPM master pool file if needed.

# Debugging switch:
$DEBUG = "0";
if ($DEBUG)
{
        use Sys::Syslog qw( :DEFAULT setlogsock);
}

# Uncomment correct type:
$whatami = "constructor";

# Location of php.ini:
$php_ini = "/etc/php.ini";

# Location of the config file for Apache PHP DSO:
$php_dso_conf = '/etc/httpd/conf.modules.d/10-php.conf';

$php_dso_location = '/usr/lib64/httpd/modules/libphp5.so';

#
#### No configureable options below!
#

$extra_PHP_basepath = '/home/solarspeed/';

use CCE;
use Data::Dumper;
use Sauce::Config;
use FileHandle;
use File::Copy;

my $cce = new CCE;
my $conf = '/var/lib/cobalt';

if ($whatami eq "handler") {
    $cce->connectfd();
}
else {
    $cce->connectuds();
}

#
## Check for presence of third party extra PHP versions:
#

# Known PHP versions:
%known_php_versions = (
						'PHP53' => '5.3',
						'PHP54' => '5.4',
						'PHP55' => '5.5',
						'PHP56' => '5.6'
						);

# Check if known extra PHP versions are present. If so, update CODB accordingly:
@PHPObject = $cce->find('PHP');

# Get 'System' Object:
@system_oid = $cce->find('System');
($ok, $System) = $cce->get($system_oid[0]);

# Create 'PHP' Object if it's not there yet:
if (!defined($PHPObject[0])) {
	&debug_msg("No 'PHP' Object present yet! Creating it!\n");
	($ok) = $cce->create('PHP');
	@PHPObject = $cce->find('PHP');
}

if (defined($PHPObject[0])) {
	($ok, $PHP) = $cce->get($PHPObject[0]);
	for $phpVer (keys %known_php_versions) {
		$phpFpmPath = $extra_PHP_basepath . "php-" . $known_php_versions{$phpVer} . "/sbin/php-fpm";
		$phpBinaryPath = $extra_PHP_basepath . "php-" . $known_php_versions{$phpVer} . "/bin/php";
		if ( -f $phpBinaryPath) {
			$reportedVersion = `$phpBinaryPath -v|grep "(cli)"|awk {'print \$2'}`;
			chomp($reportedVersion);
			$known_php_versions_reverse{$reportedVersion} = $phpVer;
		}
		if (( -f $phpFpmPath) && ( -f $phpBinaryPath)) {
			($ok) = $cce->set($PHPObject[0], "$phpVer", { 'present' => '1', 'version' => $reportedVersion });
		}
		else {
			($ok) = $cce->set($PHPObject[0], "$phpVer", { 'present' => '0', 'enabled' => '0', 'version' => "" });
		}
	}
}
else {
	&debug_msg("No 'PHP' Object present! \n");
	$cce->bye('FAIL');
	exit(1);
}

# Find out which version of PHP the OS is running and store it in CCE:
$PHP_version = `/usr/bin/php -v|/bin/grep ^PHP | /bin/awk '\{print \$2\}'`;
chomp($PHP_version);
($ok) = $cce->set($PHPObject[0], '', { 'PHP_version_os' => $PHP_version });

# Check if the OS supplied PHP is any different than the PHP that Apache DSO is currently using:
if ($PHP_version ne $PHP->{PHP_version}) {
	$thirdPartyCGI = $extra_PHP_basepath . "php-" . $known_php_versions{$known_php_versions_reverse{$PHP->{PHP_version}}} . "/bin/php-cgi";
	$new_php_dso_location = $extra_PHP_basepath . "php-" . $known_php_versions{$known_php_versions_reverse{$PHP->{PHP_version}}} . "/lib/httpd/libphp5.so";
}
else {
	$thirdPartyCGI = "/usr/bin/php-cgi";
	$new_php_dso_location = $php_dso_location;
}

# Update default php-cgi location in /etc/suphp.conf: (Actually we don't do this anymore.)
if ((-f "$thirdPartyCGI") && (-f "/etc/suphp.conf")) {
	umask(0077);
	my $stage = "/etc/suphp.conf~";
	open(HTTPD, "/etc/suphp.conf");
	unlink($stage);
	sysopen(STAGE, $stage, 1|O_CREAT|O_EXCL, 0600) || die;
	while(<HTTPD>) {
		#s/^x-httpd-suphp="(.*)"/x-httpd-suphp="php:$thirdPartyCGI"/g;
		s/^x-httpd-suphp="(.*)"/x-httpd-suphp="php:\/usr\/bin\/php-cgi"/g;
		print STAGE;
	}
	close(STAGE);
	close(HTTPD);
	chmod(0644, $stage);
	if(-s $stage) {
		move($stage,"/etc/suphp.conf");
		chmod(0644, "/etc/suphp.conf"); # paranoia
	}
}

# Update the path to the Apache PHP DSO in the Apache module config:
if ((-f "$php_dso_conf") && ( -f "$new_php_dso_location")) {
	umask(0077);
	my $stage = "$php_dso_conf~";
	open(HTTPD, "$php_dso_conf");
	unlink($stage);
	sysopen(STAGE, $stage, 1|O_CREAT|O_EXCL, 0600) || die;
	while(<HTTPD>) {
		s/LoadModule php5_module (.*)/LoadModule php5_module $new_php_dso_location/g;
		print STAGE;
	}
	close(STAGE);
	close(HTTPD);
	chmod(0644, $stage);
	if(-s $stage) {
		move($stage,"$php_dso_conf");
		chmod(0644, "$php_dso_conf"); # paranoia
	}
}

# Config file present?
#
# PLEASE NOTE:
#
# /etc/php.ini is the main PHP ini. All changes and settings go into it. ALWAYS!
# 
# BUT: As we might have several extra PHP versions installed (and one of them might even
#      be the new default one!) we need to walk through all extra PHP php.ini files to
#	   update them with our key/value pairs for all items of interest.
#

if (-f $php_ini) {

	# Array of PHP config switches that we want to update in CCE:
	&items_of_interest;

	# Read, parse and hash /etc/php.ini:
	&ini_read;

	# Verify input and set defaults if needed:
	&verify;

	# Shove ouput into CCE:
	&feedthemonster;

	# Update PHP-FPM master file if needed:
	&fpm_init;
}
else {
	# Ok, we have a problem: No php.ini found.
	# So we just weep silently and exit. 
	$cce->bye('FAIL', "$php_ini not found!");
	exit(1);
}

$cce->bye('SUCCESS');
exit(0);

# Read and parse php.ini:
sub ini_read {
	open (F, $php_ini) || die "Could not open $php_ini: $!";

	while ($line = <F>) {
		chomp($line);
		next if $line =~ /^\s*$/;               	# skip blank lines
		next if $line =~ /^\;*$/;               	# skip comment lines
		next if $line =~ /^url_rewriter(.*)$/;    	# skip line starting with url_rewriter.tags
		if ($line =~ /^([A-Za-z_\.]\w*)/) {		
			$line =~s/\s//g; 				# Remove spaces
			$line =~s/;(.*)$//g; 			# Remove trailing comments in lines
			$line =~s/\"//g; 				# Remove double quotation marks
			@row = split (/=/, $line);			# Split row at the equal sign
			$CONFIG{$row[0]} = $row[1];			# Hash the splitted row elements
		}
	}
	close(F);

	# At this point we have all switches from php.ini cleanly in a hash, split in key / value pairs.
	# To read how "memory_limit" is set we query $CONFIG{'memory_limit'} for example. 

	# For debugging only:
	if ($DEBUG > "1") {
		while (my($k,$v) = each %CONFIG) {
			&debug_msg("$k => $v\n");
		}
	}

	# For debugging only:
	if ($DEBUG == "1") {
		&debug_msg("memory_limit: " . $CONFIG{'memory_limit'} . "\n");
	}

}

sub verify {

	# Find out if we have ever run before:
	$first_run = "0";
	if ($System->{'isLicenseAccepted'} eq "0") {
		$first_run = "1";
	}

	# Go through list of config switches we're interested in:
	foreach $entry (@whatweneed) {
		if (!$CONFIG{"$entry"}) {
			# Found key without value - setting defaults for those that need it:
			if ($entry eq "allow_url_include") {
				$CONFIG{"$entry"} = "Off";
			}
			if ($entry eq "safe_mode_include_dir") {
				$CONFIG{"$entry"} = "/usr/sausalito/configs/php/";
			}
			if (($entry eq "disable_functions") && ($first_run eq "1")) {
				#$CONFIG{"$entry"} = "exec,system,passthru,shell_exec,popen,escapeshellcmd,proc_open,proc_nice,ini_restore";
				$CONFIG{"$entry"} = "exec,system,passthru,shell_exec,proc_open,proc_nice,ini_restore";
			}
			if (($entry eq "open_basedir") && ($first_run eq "1")) {
				$CONFIG{"$entry"} = "/tmp/:/var/lib/php/session/:/usr/sausalito/configs/php/";
			}
			if (($entry eq "safe_mode_allowed_env_vars") && ($first_run eq "1")) {
				$CONFIG{"$entry"} = "PHP_,_HTTP_HOST,_SCRIPT_NAME,_SCRIPT_FILENAME,_DOCUMENT_ROOT,_REMOTE_ADDR,_SOWNER";
			}
			if (($entry eq "post_max_size") && ($CONFIG{"$entry"} eq "")) {
				$CONFIG{"$entry"} = "2M";
			}
			if (($entry eq "upload_max_filesize") && ($CONFIG{"$entry"} eq "")) {
				$CONFIG{"$entry"} = "8M";
			}
			if ($DEBUG == "1") {
				print $entry . " has no value!\n";
			}
		}
		if (($first_run eq "1") || ($System->{'productBuild'} ne "5106R")) {
			# If we're indeed running for the first time, make sure safe defaults
			# are set for all our remaining switches of most importance:
			$CONFIG{"safe_mode"} = "Off";
			$CONFIG{"register_globals"} = "Off";
			$CONFIG{"allow_url_fopen"} = "Off";
		}
		# For debugging only:
		if ($DEBUG == "1") {
			&debug_msg($entry . " = " . $CONFIG{"$entry"} . "\n");
		}
    }

	# If we have base-squirrelmail.mod installed, we make sure that 'popen' and 'escapeshellcmd' are not present in 'disable_functions':
	if (-f "/etc/httpd/conf.d/squirrelmail.conf") {
		@old_disable_functions = split(/,/, $CONFIG{"disable_functions"});
		foreach $value (@old_disable_functions) {
			# Transform to lower case:
			$value =~ tr/A-Z/a-z/;
			# Weed out undersired options:
			unless (($value eq "popen") || ($value eq "escapeshellcmd") || ($value eq "")) {
			# Push the rest to new array:
			push(@new_disable_functions, $value);
			}
		}
		# Turn the cleaned array back to a string:
		$CONFIG{"disable_functions"} = join(",", @new_disable_functions);
	}
}

sub feedthemonster {

	# Making sure 'open_basedir' has the bare minimum defaults:
	@php_settings_temporary = split(":", $CONFIG{"open_basedir"});
	@my_baremetal_minimums = ('/usr/sausalito/configs/php/', '/tmp/', '/var/lib/php/session/');
	@php_settings_temp_joined = (@php_settings_temporary, @my_baremetal_minimums);

	# Remove duplicates:
	foreach my $var ( @php_settings_temp_joined ){
			if ( ! grep( /$var/, @open_basedir ) ){   
			push(@open_basedir, $var );
		}
	}
	$CONFIG{"open_basedir"} = join(":", @open_basedir);

	# Just to be really sure:
	unless (($CONFIG{"open_basedir"} =~ m#/usr/sausalito/configs/php/#) && ($CONFIG{"open_basedir"} =~ m#/tmp/#) && ($CONFIG{"open_basedir"} =~ m#/var/lib/php/session/#)) {
		&debug_msg("Fixing 'open_basedir': It is missing our 'must have' entries. Restoring it to the defaults. \n");
		$CONFIG{"open_basedir"} = "/tmp/:/var/lib/php/session/:/usr/sausalito/configs/php/";
	}

	# Making sure 'safe_mode_allowed_env_vars' has the bare minimum defaults:
	@smaev_temporary = split(":", $CONFIG{"safe_mode_allowed_env_vars"});
	@smi_baremetal_minimums = ('PHP_','_HTTP_HOST','_SCRIPT_NAME','_SCRIPT_FILENAME','_DOCUMENT_ROOT','_REMOTE_ADDR','_SOWNER');
	@smaev_temp_joined = (@smaev_temporary, @smi_baremetal_minimums);

	# Remove duplicates:
	foreach my $var ( @smaev_temp_joined ){
		if ( ! grep( /$var/, @safe_mode_allowed_env_vars ) ){
			push(@safe_mode_allowed_env_vars, $var );
		}
	}
	$CONFIG{"safe_mode_allowed_env_vars"} = join(",", @safe_mode_allowed_env_vars);

	@oids = $cce->find('PHP');
	if ($#oids < 0) {
		# Object not yet in CCE. Creating new one and forcing re-write of php.ini by setting "force_update":
		&debug_msg("CLASS 'PHP' not found! Creating it!!! \n");
		($ok) = $cce->create('PHP', {
			'applicable' => 'server',
			'PHP_version' => $PHP_version,
			'PHP_version_os' => $PHP_version,
			'safe_mode' => $CONFIG{"safe_mode"},  
			'safe_mode_allowed_env_vars' => $CONFIG{"safe_mode_allowed_env_vars"},   
			'safe_mode_exec_dir' => $CONFIG{"safe_mode_exec_dir"},   
			'safe_mode_gid' => $CONFIG{"safe_mode_gid"},   
			'safe_mode_include_dir' => $CONFIG{"safe_mode_include_dir"},  
			'safe_mode_protected_env_vars' => $CONFIG{"safe_mode_protected_env_vars"},  
			'register_globals' => $CONFIG{"register_globals"},  
			'allow_url_fopen' => $CONFIG{"allow_url_fopen"},   
			'allow_url_include' => $CONFIG{"allow_url_include"},  
			'disable_classes' => $CONFIG{"disable_classes"},   
			'disable_functions' => $CONFIG{"disable_functions"},  
			'open_basedir' => $CONFIG{"open_basedir"},   
			'post_max_size' => $CONFIG{"post_max_size"},   
			'upload_max_filesize'  => $CONFIG{"upload_max_filesize"},  
			'max_execution_time' => $CONFIG{"max_execution_time"},   
			'max_input_time' => $CONFIG{"max_input_time"},   
			'memory_limit' => $CONFIG{"memory_limit"},   
			'php_ini_location' => $php_ini,  
			'force_update' => time()  
		});
	}
	else {
		# Object already present in CCE. Updating it, NOT forcing a rewrite of php.ini.
		($sys_oid) = $cce->find('PHP');
		($ok, $sys) = $cce->get($sys_oid);
		&debug_msg("CLASS 'PHP' was found! (Object $system_oid) Using it!!! \n");
		if ($sys->{'PHP_version'} eq "") {
			($ok) = $cce->set($sys_oid, '',{ 'PHP_version' => $PHP_version });
		}
		($ok) = $cce->set($sys_oid, '',{
			'PHP_version_os' => $PHP_version,  
			'safe_mode' => $CONFIG{"safe_mode"},  
			'safe_mode_allowed_env_vars' => $CONFIG{"safe_mode_allowed_env_vars"},   
			'safe_mode_exec_dir' => $CONFIG{"safe_mode_exec_dir"},   
			'safe_mode_gid' => $CONFIG{"safe_mode_gid"},   
			'safe_mode_include_dir' => $CONFIG{"safe_mode_include_dir"},  
			'safe_mode_protected_env_vars' => $CONFIG{"safe_mode_protected_env_vars"},  
			'register_globals' => $CONFIG{"register_globals"},  
			'allow_url_fopen' => $CONFIG{"allow_url_fopen"},   
			'allow_url_include' => $CONFIG{"allow_url_include"},  
			'disable_classes' => $CONFIG{"disable_classes"},   
			'disable_functions' => $CONFIG{"disable_functions"},  
			'open_basedir' => $CONFIG{"open_basedir"},   
			'post_max_size' => $CONFIG{"post_max_size"},   
			'upload_max_filesize' => $CONFIG{"upload_max_filesize"},  
			'max_execution_time' => $CONFIG{"max_execution_time"},   
			'max_input_time' => $CONFIG{"max_input_time"},   
			'memory_limit' => $CONFIG{"memory_limit"},   
			'php_ini_location' => $php_ini  
		});
	}
}

sub items_of_interest {
	# List of config switches that we're interested in:
	@whatweneed = ( 
		'safe_mode', 
		'safe_mode_allowed_env_vars', 
		'safe_mode_exec_dir', 
		'safe_mode_gid', 
		'safe_mode_include_dir', 
		'safe_mode_protected_env_vars',	
		'register_globals', 
		'allow_url_fopen', 
		'allow_url_include', 
		'disable_classes', 
		'disable_functions', 
		'open_basedir', 
		'post_max_size', 
		'upload_max_filesize',
		'max_execution_time',
		'max_input_time',
		'memory_limit'
	);
}

sub fpm_init {
	if (-f "/etc/php-fpm.d/www.conf") {
		$fpm_check = `cat /etc/php-fpm.d/www.conf |grep "pm = dynamic"|wc -l`;
		chomp($fpm_check);
		if ($fpm_check eq "1") {
			# Need to convert it. So we set the trigger to do it:
			($sys_oid) = $cce->find('PHP', {'applicable' => 'server'});
			($ok) = $cce->set($sys_oid, '',{ 'force_update' => time() });
		}
	}
}

sub debug_msg {
    if ($DEBUG) {
        my $msg = shift;
        $user = $ENV{'USER'};
        setlogsock('unix');
        openlog($0,'','user');
        syslog('info', "$ARGV[0]: $msg");
        closelog;
    }
}

$cce->bye('SUCCESS');
exit(0);

# 
# Copyright (c) 2015 Michael Stauber, SOLARSPEED.NET
# Copyright (c) 2015 Team BlueOnyx, BLUEONYX.IT
# All Rights Reserved.
# 
# 1. Redistributions of source code must retain the above copyright 
#	 notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright 
#	 notice, this list of conditions and the following disclaimer in 
#	 the documentation and/or other materials provided with the 
#	 distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its 
#	 contributors may be used to endorse or promote products derived 
#	 from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
# COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
# 
# You acknowledge that this software is not designed or intended for 
# use in the design, construction, operation or maintenance of any 
# nuclear facility.
# 
