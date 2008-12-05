#!/usr/bin/perl
#
# modify_mysql_data.pl - Solarspeed.net's mysql GUI
# By: Michael Stauber <mstauber@solarspeed.net>
# Copyright 2006-2008 Solarspeed Ltd. All rights reserved.

# Global Paths & Config
$namespace = 'MYSQL_Vsite';
$global_namespace = 'MYSQL_DBs';

# Perl libraries, all Sausalito
use lib qw(/usr/sausalito/perl);
use DBI;
use CCE;
use Sauce::Util;
#use File::Copy;
#use Base::Vsite qw(vsite_update_site_admin_caps);
#umask(002); # group write

# Debug, Will-style
$DEBUG = 0;
$DEBUG && open(STDERR, ">>/tmp/mod_mysql-vsite");
$DEBUG && warn $0.' '.`date`;

$cce = new CCE;
$cce->connectfd();
#$cce->connectuds(); # Only for debugging

$object = $cce->event_object();
$new = $cce->event_new();
$old = $cce->event_old();

$vsite_name = $old->{fqdn};
$DEBUG && warn "Vsite Name: $vsite_name  \n";

#$cce->bye('SUCCESS');
#exit(0);

# Get 'System' details:
@system_main = $cce->find('System');
if (!defined($system_main[0])) {
    print STDERR "Sorry, no 'System' object found in CCE!\n";
    $cce->bye('FAIL', "Unable to find 'System' Object in CCE.");
    exit(1);
}
else {
    # Build FQDN:
    ($ok, $my_system_main) = $cce->get($system_main[0]);
    $my_host = $my_system_main->{'hostname'};
    $my_domain = $my_system_main->{'domainname'};
    $my_fqdn = $my_host . "." . $my_domain; 
}

# Get Vsite's MySQL data out of 'MYSQL_DBs':
@mysql_vsite_extra = $cce->find('MYSQL_DBs', { 'fqdn' => $vsite_name} );
if (!defined($mysql_vsite_extra[0])) {
        print STDERR "Sorry, this Vsite has no 'MYSQL_DBs' object in CCE!\n";
	# We exit cleanly nonetheless, as this site might never have had a MySQL database.
	$cce->bye('SUCCESS');
	exit(0);
}
else {
	($ok, $site_mysql_extra) = $cce->get($mysql_vsite_extra[0]);
	$site_mysql_user = $site_mysql_extra->{username};
	$db = $site_mysql_extra->{DB};
	if ($site_mysql_extra->{enabled} == "1") {
	    $mysqlsite = "1";
	}
	else {
	    $mysqlsite = "0";
	}
	$DEBUG && warn "User: $site_mysql_user - DB: $db \n";
}

$fqdn = $vsite->{fqdn};
$fqdn = $new->{fqdn} if ($new->{fqdn});

# Get main MySQL access settings out of 'Solarspeed_MySQL':
@mysql_main = $cce->find('Solarspeed_MySQL');
if (!defined($mysql_main[0])) {
        print STDERR "Sorry, no 'Solarspeed_MySQL' object found in CCE!\n";
        print STDERR "Unable to fetch MySQL 'root' access details for MySQL.\n";
	$cce->bye('FAIL', "Unable to fetch MySQL 'root' access details for MySQL from CCE. Please configure them under 'Solarspeed GUI', 'MySQL Settings'.");
        exit(1);
}
else {
	($ok, $mysql_main) = $cce->get($mysql_main[0]);
	$sql_root = $mysql_main->{'sql_root'};
	$root_pass = $mysql_main->{'sql_rootpassword'};
	$sql_host = $mysql_main->{'sql_host'};
	$sql_port = $mysql_main->{'sql_port'};
}

# Make sure we have all MySQL access details that we need:
unless (($sql_root ne "") && ($root_pass ne "") && ($sql_host ne "") && ($sql_port ne "")) {
        print STDERR "Unable to fetch MySQL 'root' access details for MySQL from CCE.\n";
	$cce->bye('FAIL', "Unable to fetch MySQL 'root' access details for MySQL from CCE. Please configure them under 'Solarspeed GUI', 'MySQL Settings'.");
        exit(1);
}
else {
	$new_sql_host=$sql_host . ":" . $sql_port;
}

if($cce->event_is_destroy() && $old->{fqdn}) {
	# Site deletion, not to be confused with MySQL disable
	&checkalldetails;
	&remove_db_and_user;
	&remove_extra;
}
elsif ($mysqlsite == "1") {
    # Enable MySQL for the site

}

elsif ($mysqlsite == "0") {
    # disable for a site, not to be confused with site deletion
}

$cce->bye('SUCCESS');
exit 0;

### Subs

sub remove_db_and_user {

	#
	## Now we reset $sql_host with $my_fqdn on an as needed basis:
	#
	
	if ($sql_host ne 'localhost') {
	    $sql_host = $my_fqdn;
	}

	#
	## Delete the sites MySQL database: 
	#
	$dbh = DBI->connect("DBI:mysql:$db;host=$new_sql_host", $sql_root, $root_pass) || die "Database connection not possible: $DBI::errstr";
	eval { $dbh->do("DROP DATABASE IF EXISTS $db") };
	print STDERR "Dropping $db failed: $@\n" if $@;
	$dbh->disconnect();

	#
        ## Revoke privileges (Step #1):
        #
        $dbh = DBI->connect("DBI:mysql:mysql;host=$new_sql_host", $sql_root, $root_pass) || die "Database connection not possible: $DBI::errstr";
	$userstring = "REVOKE ALL PRIVILEGES ON * . * FROM '$site_mysql_user'\@'$sql_host';\n";
        print STDERR "Userstring: " . $userstring . "\n";
        eval { $dbh->do($userstring) };
        print STDERR "Revoking privileges failed at step 1 for user $site_mysql_user at $sql_host $@\n" if $@;
        $dbh->disconnect();

	#
        ## Revoke privileges (Step #2):
        #
        $dbh = DBI->connect("DBI:mysql:mysql;host=$new_sql_host", $sql_root, $root_pass) || die "Database connection not possible: $DBI::errstr";
	$userstring = "REVOKE ALL PRIVILEGES ON `" . $db . "` . * FROM '$site_mysql_user'\@'$sql_host';\n";
        print STDERR "Userstring: " . $userstring . "\n";
        eval { $dbh->do($userstring) };
        print STDERR "Revoking privileges failed at step 2 for user $site_mysql_user at $sql_host $@\n" if $@;
        $dbh->disconnect();

	#
        ## Revoke privileges (Step #3):
        #
        $dbh = DBI->connect("DBI:mysql:mysql;host=$new_sql_host", $sql_root, $root_pass) || die "Database connection not possible: $DBI::errstr";
	$userstring = "REVOKE GRANT OPTION ON * . * FROM '$site_mysql_user'\@'$sql_host';\n";
        print STDERR "Userstring: " . $userstring . "\n";
        eval { $dbh->do($userstring) };
        print STDERR "Revoking privileges failed at step 3 for user $site_mysql_user at $sql_host $@\n" if $@;
        $dbh->disconnect();

	#
	## Delete the sites MySQL user: 
	#
	$dbh = DBI->connect("DBI:mysql:mysql;host=$new_sql_host", $sql_root, $root_pass) || die "Database connection not possible: $DBI::errstr";
	print STDERR "Trying to drop MySQL user $site_mysql_user at $sql_host \n";
	$userstring = "DROP USER '$site_mysql_user'\@'$sql_host';\n";
	print STDERR "Userstring: " . $userstring . "\n";
	eval { $dbh->do($userstring) };
	print STDERR "MySQL user removal failed for user $site_mysql_user at $sql_host $@\n" if $@;
	$dbh->disconnect();

	#
	## Flush privileges:
	#
	$dbh = DBI->connect("DBI:mysql:mysql;host=$new_sql_host", $sql_root, $root_pass) || die "Database connection not possible: $DBI::errstr";
	$userstring = "FLUSH PRIVILEGES;";
	eval { $dbh->do($userstring) };
	print STDERR "Flushing privileges failed: $@\n" if $@;
	$dbh->disconnect();

}

sub checkalldetails {
# Make sure we know what user and DB to delete:
    if (($site_mysql_user eq "") || ($db eq "")) {
	$DEBUG && warn "Could not determine the name of the MySQL user and MySQL database for this Vsite. $dudu \n";
	$cce->bye('FAIL', "Could not determine the MySQL username and database name for this virtual site.");
        exit(1);
    }
}

sub remove_extra {
    ($ok) = $cce->destroy($mysql_vsite_extra[0]);
}
