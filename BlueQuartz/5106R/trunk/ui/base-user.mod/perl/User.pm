#!/usr/bin/perl -I/usr/sausalito/perl
# Copyright 2001 Sun Microsystems, Inc.  All rights reserved.
# $Id: User.pm,v 1.16.2.2 2002/06/18 21:54:06 naroori Exp $
#
# commonly used functions such as useradd, usermod, userdel
# TODO: get input on the API, documentation
#

package Base::User;

=pod

=head1 NAME

Base::User - methods to add, modify, and delete system users

=head1 SYNOPSIS

 use Base::User;
 use Base::User qw(useradd usermod userdel user_kill_processes);

 Base::User::useradd($user);
 Base::User::system_useradd(\@users);
 Base::User::usermod(\@users);
 Base::User::userdel(1, 'user1', 'user2', ...);

 Base::User::user_kill_processes('user1');

=head1 DESCRIPTION

Base::User is a collection of methods to add, modify, and remove system users.
The functionality is roughtly similar to that of the useradd, usermod, and
userdel programs that ship with RedHat Linux.  The difference is that the
included methods know about the preferred user information storage method for
Sun Microsystems Linux.

This module should always be used when doing anything with users in CCE
handlers, although this module does not interact with CCE in anyway nor does
it make changes to the CCE database.  The normal RedHat programs will still
work, and this module will see changes made by those programs.  However, all
changes made by this module may not be visible to the RedHat programs.  This
should be considered the authoritative means of dealing with making changes
to the system user information "databases".  All other means are considered
deprecated for use in Sun Microsystems Linux.

=head1 EXPORTS

All the methods in Base::User can be exported into the the caller's namespace
using the standard C<use Module qw(function1 function2 ...);> pragma.  All
variables in Base::User are considered private.  Changing any of their values
will break things.

=cut

use Exporter;
use vars qw(@ISA @EXPORT_OK);

@ISA = qw(Exporter);

@EXPORT_OK = qw(
                user_kill_processes
                useradd usermod userdel
                system_useradd
                );

use PWDB;
use DB_File;
use Fcntl qw(:flock);
use FileHandle;
use File::Path;
use Sauce::Config;
use Sauce::Util;
use Base::HomeDir qw(homedir_get_user_dir);

use vars qw($DEBUG $UIDS_LOCKFILE $UIDS_CACHE $MIN_UID $MAX_UID);
$DEBUG = 0;
$UIDS_CACHE = '/var/db/freeuids.db';
$MIN_UID = 500;  # the minimum uid to assign to users created with useradd
$MAX_UID = 2 ** 16;  # the max uid to assign to users created with useradd

# private vars to minimize open and close system calls
my $db_handle = undef;
my %uids;
my $lock_handle = undef;

if ($DEBUG)
{
    use Data::Dumper;
}

=pod

=head1 USER 'OBJECT'

Base::User does not use PERL objects (yet.  This may change, but hopefully
backward compatibility will remain).  The user "object" the user* methods
expect is really just a reference to a PERL hash.  The user hash has the
following structure.

$user = {
 'name' => 'username',
 'oldname' => 'oldusername',
 'uid' => 501,
 'group' => 'users',
 'password' => 'crypted_password',
 'comment' => 'User Name',
 'homedir' => '/home/users/username',
 'dont_create_home' => 0,
 'shell' => '/bin/bash',
 'skel' => '/etc/skel/user/en'

};

The members of the hash are:

=over 4

=item name

The user name (login) of the user to add or modify.

=item oldname

This is optional unless the login name of the user is being changed through
the usermod method.  If specified, I<oldname> should contain the current login
name of the user, and I<name> should contain the new login name.

=item uid

This is optional unless the user should be given a specific user id number.  If
not specified for user addition, the user will be assigned the next available
user id number.  Specifying a value for uid is not recommended, but it can be
useful in conjuction with the I<system_useradd> function to add multiple
login names which share the same user id number.

=item group

This is the name of the user's initial group.  This is optional for user
modification unless the user's initial group should be changed.

=item password

This is the md5 crypted password for the user.  This is optional for user
modification unless the user's password should be changed.

=item comment

This corresponds to the comment entry in the user's passwd entry.  This is
commonly used to hold the user's full name.

=item homedir

This is the user's home directory.  By default, during user addition the user's
home directory is created and the ownership of the directory is set to the
user id assigned to the user and the group id of the group in the I<group>
member of the user "object".  See I<dont_create_home>.

=item dont_create_home

This can be used during user addition to specify that the user's home directory
should not be created by setting it's value to boolean true, or 1.  If true,
the home directory will not be created, any skeleton specified via the I<skel>
member will not be copied, and the ownership of the directory specified by
I<homedir> will not be changed.

=item shell

Specifies the user's login shell.

=item skel

This is optional and is only used for user addition.  The value of I<skel>
should be a directory that contains the skeleton directory for a new user.  The
specified directories contents will be copied into the directory specified in
the I<homedir> member of the user "object".

=back

=head1 METHODS

=over 4

=item useradd($user or \@users)

This method takes either a user "object" or a reference to a list of user 
"objects" for bulk user adds.  The user information is added to the system
passwd "database", and if I<dont_create_home> is not set in the user "object",
the user's home directory is created.  In addition, if the I<skel> property
is set, the skeleton diretory contents are copied into the user's home
directory.  Finally, if the user's home directory is created by I<useradd>, the
home directory's file ownerships are set to the user id of the new user and the
group id of the I<group> property of the user.

The method returns a list with the first element being the success code 
(1 for success, 0 for failure for any users) and the second element being a 
list reference to a list containing names of users that useradd was unable
to create.  If the method fails before attempting to add the user(s), the list
reference returned will be undefined.

=cut

sub useradd
{
    return _internal_useradd([PWDB_UNIX, PWDB_SHADOW], @_);
}

=pod

=item system_useradd($user or \@users)

This is an exact duplicate of the I<useradd> method.  However, while I<useradd>
uses the preferred database to store user information, users added with
I<system_useradd> are guaranteed to be added to /etc/passwd, so that they will
be able to login if the preferred database becomes unusable for some reason.
This should only be used for system administrator accounts that must always be
able to login to the machine.  The method's behaviour and return value are
exactly the same as I<useradd> with the exception that users are always added
to /etc/passwd.

=cut

# system_useradd is exactly the same as useradd except it adds users
# to /etc/passwd and shadow instead of the db.  It should only be used
# for crucial users who should be able to login if the database gets corrupted
# for some reason
sub system_useradd
{
    return _internal_useradd([PWDB_UNIX, PWDB_SHADOW], @_);
}

=pod

=item usermod($user or \@users)

The I<usermod> method takes either a single user "object" or a reference to a
list of user "objects" the same as I<useradd>.  The only required property the
the user "object" passed to I<usermod> is the I<name>.  The only other 
properties that must be set are those that should be changed.  To change the 
login name of a user, the I<name> property should be set to the new login name,
and the I<oldname> property should be set to the current login name.  Unlike 
I<useradd>, this method will not create the new directory or change the
ownership of any files or directories if the user's home directory, user id, or
initial group are changed.

The return value is the same as the I<useradd> method.  The list reference
contains the current login names of users I<usermod> was unable to update.

=cut

# take the same type of argument as useradd
# returns the same info as useradd
sub usermod
{
    my $users = shift;

    # what did we get
    my $internal_list = [];
    if (ref($users) eq 'HASH')
    {
        push @$internal_list, $users;
    }
    elsif (ref($users) eq 'ARRAY')
    {
        $internal_list = $users;
    }
    else
    {
        # what are they doing to me?
        $DEBUG && warn('invalid argument passed for users');
        return (0, undef);
    }
    
    # succeed by default
    my $success = 1;
    my $bad_users = [];

    # save umask and set to a known value while editing files
    my $old_umask = umask(022);

    $DEBUG && warn('pwdb_start');
    PWDB::pwdb_start();
    
    for my $user (@$internal_list)
    {
        my $old_uid;
        my $username = $user->{oldname} ? $user->{oldname} : $user->{name};

        # don't specify a src to search since useradd only adds to one
        # db anyways
        my $pwdb = PWDB::pwdb_locate('user', [],
                                    $username, PWDB_ID_UNKNOWN);

        if (!$pwdb)
        { # not found?
            $DEBUG && warn("$user->{name} not found skipping");
            $success = 0;
            push @$bad_users, $username;
            next;
        }
       
        # save old settings for rollback
        my $old_user = _get_current_settings($pwdb);

        # parse new user settings
        $old_uid = $pwdb->get_entry('uid');
        if (exists($user->{uid}))
        {
            # make sure the specified uid isn't being used
            my @foo = getpwuid($user->{uid});
            if (@foo && $foo[0] ne $username)
            {
                $DEBUG && warn("uid, $user->{uid}, already in use");
                $success = 0;
                push @$bad_users, $username;
                next;
            }

            $pwdb->set_entry('uid', $user->{uid} + 0);
        }

        if (exists($user->{homedir}))
        {
            $pwdb->set_entry('dir', $user->{homedir});
        }
        
        if (exists($user->{comment}))
        {
            $pwdb->set_entry('gecos', $user->{comment});
        }
        if (exists($user->{shell}))
        {
            $pwdb->set_entry('shell', $user->{shell});
        }
        if (exists($user->{group}))
        {
            $pwdb->set_entry('gid', scalar(getgrnam($user->{group})));
        }
        if ($user->{oldname})
        {
            $pwdb->set_entry('user', $user->{name});
        }

        if (defined($user->{password}))
        {
            $pwdb->set_entry('defer_pass', 'x');
            $pwdb->set_entry('passwd', $user->{password});
        }

        # make sure directories above the user's directory exist
        # FIXME:  this shouldn't be here, but I don't want to pull
	# 	  it at this point for fear of breaking anything
	mkpath($pwdb->get_entry('dir'));

        $DEBUG && warn("replacing $username with $user->{name}");
        if (!PWDB::pwdb_replace($pwdb, $username, $old_uid))
        {
            $success = 0;
            push @$bad_users, $username;
        }
        else
        {
#ROLLBACK USERMOD
            # handle name changes
            my $oldname_info = '';
            if ($user->{oldname})
            {
                $oldname_info = "'oldname' => '$user->{name}', ";
            }
            
            my $rollback_cmd = "/usr/bin/perl "
                    . "-I/usr/sausalito/perl -e \"use Base::User qw(usermod); "
                    . "print STDERR \\\"ROLLBACK USERMOD\\n\\\"; "
                    . "usermod({ "
                            . "'name' => '$old_user->{name}', "
                            . ${oldname_info}
                            . "'uid' => '$old_user->{uid}', "
                            . "'group' => '$old_user->{group}', "
                            . "'password' => '$old_user->{password}', "
                            . "'comment' => '$old_user->{comment}', "
                            . "'homedir' => '$old_user->{homedir}', "
                            . "'shell' => '$old_user->{shell}' "
                            . "});\"";

            Sauce::Util::addrollbackcommand($rollback_cmd);
        }
    }

    PWDB::pwdb_end();

    # restore umask
    umask($old_umask);

    return ($success, $bad_users);
}

=pod

=item userdel($remove_home_dir, @user_names)

I<userdel> will remove users home directories, if desired, and will remove the
user's information from the passwd database.  The return value is the same
as that for I<useradd> and I<usermod>.  The returned list reference in the
second item in the returned list contains the login names of users that 
I<userdel> was unable to remove.

=over 4

=item *

I<$remove_home_dir> is a boolean value indicating whether the home direcotries
of the users being removed should be destroyed.  If I<$remove_home_dir> is set
to boolean true (or 1), the users' home directories are removed in addition to
the users' login information.  If set to boolean false, users' home directories
will not be touched.

=item *

I<@user_names> is the list of login names for which to remove login information.

=back

=cut

# userdel
# arguments: boolean flag indicating whether user's directory should
# also be removed (true to remove directory, false otherwise) list of usernames
# returns same as useradd and usermod
sub userdel
{
    my $remove = shift;
    my @users = @_;

    $DEBUG && warn('Base::User::userdel called');
    
    # succeed by default
    my $success = 1;
    my $bad_users = [];

    # save umask and set to a known value
    my $old_umask = umask(022);

    $DEBUG && warn('calling PWDB::pwdb_start');
    my $ret = PWDB::pwdb_start();
    $DEBUG && warn(PWDB::pwdb_strerror($ret));

    for my $user (@users)
    {
        $DEBUG && warn("deleting $user");
        # get information for rollback
        my @user_info = getpwnam($user);
        if (!scalar(@user_info))
        {
            # not failure if the user doesn't exist
            $DEBUG && warn("Base::User::userdel not deleting non-existant user $user");
            next;
        }

        my $old_user = {
                        'name' => $user,
                        'uid' => $user_info[2],
                        'group' => scalar(getgrgid($user_info[3])),
                        'password' => $user_info[1], 
                        'homedir' => $user_info[7],
                        'shell' => $user_info[8], 
                        'comment' => $user_info[6]
                    };
        
        $DEBUG && warn('about to do PWDB::pwdb_remove');
        $ret = PWDB::pwdb_remove('user', [], $user, $user_info[2]);
        $DEBUG && warn(PWDB::pwdb_strerror($ret));
        if ($ret != PWDB::PWDB_SUCCESS)
        {
            $DEBUG && warn("Base::User::userdel deleting $user failed.");
            $DEBUG && warn(PWDB::pwdb_strerror($ret) . "\n");
            $success = 0;
            push @$bad_users, $user;
        }
        else
        {
            # free the uid for this user
            put_free_uid($user_info[2]);

            # be sure the homedir isn't /
            if ($remove && $user_info[7] =~ /^\/.+/)
            {
                # FIXME this could take a while
                system('/bin/rm', '-rf', $user_info[7]);
            }

#ROLLBACK USERDEL

            # don't have rollback recreate and chown the home directory
            # unless userdel was told to remove the dir
            # this handles the special case of the admin-fqdn users
            # whose home directories are the site directories
            my $dir_flag = 1;
            if ($remove)
            {
                $dir_flag = 0;
            }

            my $rollback_cmd = "/usr/bin/perl "
                    . "-I/usr/sausalito/perl -e \"use Base::User qw(useradd); "
                    . "print STDERR \\\"ROLLBACK USERDEL\\n\\\"; "
                    . "useradd({ "
                            . "'name' => '$old_user->{name}', "
                            . "'uid' => '$old_user->{uid}', "
				            . "'group' => '$old_user->{group}', "
				            . "'password' => '$old_user->{password}', "
				            . "'comment' => '$old_user->{comment}', "
				            . "'homedir' => '$old_user->{homedir}', "
				            . "'dont_create_home' => $dir_flag, "
				            . "'shell' => '$old_user->{shell}' "
				          . "});\"";

            Sauce::Util::addrollbackcommand($rollback_cmd);
        }
    } # done deleting users

    $ret = PWDB::pwdb_end();
    $DEBUG && warn(PWDB::pwdb_strerror($ret));

    # restore umask
    umask($old_umask);

    return ($success, $bad_users);
}

=pod

=item user_kill_processes($login_name)

This method will kill all running processes for a specific user.  In other
words, if a user is being deleted and is logged in, this will effectively log
them out.  The calling process must be owned by the superuser for this method
to work.

=over 4

=item *

I<$login_name> is simply the login name of the user whose processes should be
killed.

=back

=back

=cut

sub user_kill_processes
{
    my $user = shift;

    # kill all of this user's currently running processes:
    # copied from del_user.pl in sauce-basic.mod
    my @pids;
    chomp (@pids = `/bin/ps --user $user -ho pid`);
    if (@pids) 
    {
        kill 1, @pids;
        sleep(1);
        my $cnt = 0;
        while (chomp(@pids = `/bin/ps --user $user -ho pid`)) 
        {
            $cnt++;
            if ($cnt > 5) 
            {
                $DEBUG && print STDERR "$0: Couldn't kill processes of $user: @pids\n";
                last;
            }
            kill 9, @pids;
            sleep(1);
        }
    }
}

=pod

=head1 NOTES

This module relies on PWDB for seamless access to the system user information
"databases".  See the PWDB documentation for more information.

=head1 BUGS

I<usermod> will actually try to create the new home directory if a user's home
directory is changed.  It uses I<File::mkpath>, so it does nothing if the
specified directory already exists.  This should not happen, but at this point
removing it could break something.

=head1 SEE ALSO

perl(1), useradd(8), usermod(8), userdel(9), PWDB, File::Path

=cut

# private functions
sub _get_current_settings
{
    my $pwdb = shift;

    return {
            'name' => $pwdb->get_entry('user'),
            'uid' => $pwdb->get_entry('uid'),
            'group' => scalar(getgrgid($pwdb->get_entry('gid'))),
            'password' => $pwdb->get_entry('passwd'),
            'comment' => $pwdb->get_entry('gecos'),
            'homedir' => $pwdb->get_entry('dir'),
            'shell' => $pwdb->get_entry('shell')
            };
}

sub sel
{
  return $_[int(rand(1+$#_))];
}

sub cryptpw
{
    my $pw = shift;
    my @saltchars = ('a'..'z','A'..'Z',0..9);
    srand();
    my $salt = sel(@saltchars) . sel(@saltchars);
    my $crypt_pw = crypt($pw, $salt);
    $salt = '$1$';
    for (my $i = 0; $i < 8; $i++) { $salt .= sel(@saltchars); }
    $salt .= '$';
    my $md5_pw = crypt($pw, $salt);
    return ($crypt_pw, $md5_pw);
}

# always make sure lockfile exists
BEGIN
{
    # need to set this here or the BEGIN method can't see it
    $UIDS_LOCKFILE = '/var/db/freeuids.lock';
    if (!-f $UIDS_LOCKFILE)
    {
        open(LOCK, ">$UIDS_LOCKFILE") or die "$!\n";
        close(LOCK);
    }
}

END
{
    # always try to close the database, so that things aren't stale
    undef($db_handle);
    untie(%uids);

    if (defined($lock_handle))
    {
        unlock($lock_handle);
        $lock_handle->close();
    }
}

sub get_free_uid
{
    my ($key, $value, $status);

    # lock down
    if (!$lock_handle)
    {
        $lock_handle = new FileHandle("<$UIDS_LOCKFILE");
        if (!defined($lock_handle))
        {
            die "can't open $UIDS_LOCKFILE: $!\n";
        }
    }

    if (!lock($lock_handle))
    {
        $DEBUG && warn("error: couldn't lock $UIDS_LOCKFILE");
        exit(1);
    }
   
    # only open the db once
    if (!$db_handle)
    {
        $db_handle = tie %uids, 'DB_File', $UIDS_CACHE, O_RDWR, 0600, $DB_BTREE;
    }

    # set key to nothing
    $key = -1;
    
    # fallback to linear search if the db is missing or something
    if ($db_handle)
    {
        $DEBUG && warn('getting uid from DB');

        # to be safe loop and check if the specified uid is being used
        # before returning
        while(1)
        {
            # get first/next entry
            $status = $db_handle->seq($key, $value, R_NEXT);
            $DEBUG && warn("got $key from DB");
            
            # check for errors and act accordingly
            if ($status != 0)
            {
                $DEBUG && warn("failure, status = $status");
                $key = -1;
                last;
            }
            else
            {
                # delete the entry and check if it is in use already
                delete($uids{$key});
                if (!scalar(getpwuid($key)))
                {
                    # make sure perl knows $key should be a number
                    $key = $key + 0;
                    last;
                }
                else
                {
                    $DEBUG && warn("uid $key is already in use");
                }
            }
        }

        $DEBUG && warn("done searching DB, got uid = $key");
    }

    # unlock
    unlock($lock_handle);

    # fallback to linear search (How can we make this not suck?)
    if ($key == -1)
    {
        $DEBUG && warn('getting uid via linear search');
        for (my $i = $MIN_UID; $i < $MAX_UID; $i++)
        {
            # FIXME: methinks this is a really nasty race condition
            if (not scalar(getpwuid($i)))
            {
                $key = $i;
                last;
            }
        }
    }

    return $key;
}

# put_free_uid must be called AFTER a uid is no longer in use 
# due to user deletion
sub put_free_uid
{
    my $uid = shift;

    # try to protect the cache from invalid data
    # users with uids < $MIN_UID should always specify the 
    # uid when creating the user
    # also don't allow uids that are in use to be placed in the cache
    if ($uid < $MIN_UID || $uid > $MAX_UID || scalar(getpwuid($uid)))
    {
        return;
    }

    # lock down
    if (!$lock_handle)
    {
        $lock_handle = new FileHandle("<$UIDS_LOCKFILE");
        if (!defined($lock_handle))
        {
            die "can't open $UIDS_LOCKFILE: $!\n";
        }
    }
    if (!lock($lock_handle))
    {
        $DEBUG && warn("error: couldn't lock $UIDS_LOCKFILE");
        exit(1);
    }
   
    # only open the db once
    if (!$db_handle)
    {
        $db_handle = tie %uids, 'DB_File', $UIDS_CACHE, 
                        O_CREAT|O_RDWR, 0600, $DB_BTREE;
    }

    if ($db_handle)
    {
        $uids{$uid} = 1;
    }

    unlock($lock_handle);
}

sub lock
{
    my $fh = shift;

    my $ret = 0;
    
    # try 10 times to get the lock or fail
    for (my $i = 0; $i < 10; $i++)
    {
        if (flock($fh, LOCK_EX|LOCK_NB))
        {
            $ret = 1;
            last;
        }
        
        sleep(1);
    }
    
    return $ret;
}

sub unlock
{
    my $fh = shift;

    flock($fh, LOCK_UN);
}

sub _internal_useradd
{
    my ($src, $users) = @_;

    $DEBUG && warn('Base::User::useradd called.');

    # what did we get
    my $internal_list = [];
    if (ref($users) eq 'HASH')
    {
        push @$internal_list, $users;
    }
    elsif (ref($users) eq 'ARRAY')
    {
        $internal_list = $users;
    }
    else
    {
        # what are they doing to me?
        $DEBUG && warn('Base::User::useradd unknown reference passed as argument');
        return (0, undef);
    }
    
    # succeed by default
    my $success = 1;
    my $bad_users = [];

    # set the umask to a known value so files get created correctly
    my $old_umask = umask(022);

    PWDB::pwdb_start();
    
    for my $user (@$internal_list)
    {
        # make sure user doesn't exist already
        if (getpwnam($user->{name}))
        {
            $success = 0;
            push @$bad_users, $user->{name};
            next;
        }

        my $pwdb = PWDB::pwdb_new('user', $src, 1000);

        if (!$pwdb)
        {
            # fatal error
            print STDERR "useradd failed due to problems with pwdb_new!\n";
            PWDB::pwdb_end();
            exit(1);
        }

        if (not exists($user->{uid}))
        {
            # get the next available uid
            $user->{uid} = get_free_uid();
            $DEBUG && print STDERR "uid is $user->{uid}", "\n";
        }
       
        # because the password is crypted elsewhere, don't do it
        # here to be consistent
        # crypt the password
        # my $crypt_pw = (cryptpw($user->{password}))[1];
        # $DEBUG && print STDERR "crypt password $crypt_pw\n";

        $pwdb->set_entry('create_user', 1);
        $pwdb->set_entry('user', $user->{name});
        $pwdb->set_entry('defer_pass', 'x');  # force passwd into shadow
       if (defined($user->{password})) {
               $pwdb->set_entry('passwd', $user->{password});
       }
        $pwdb->set_entry('uid', $user->{uid} + 0);
        $pwdb->set_entry('gid', scalar(getgrnam($user->{group})));
        $pwdb->set_entry('gecos', $user->{comment});
        $pwdb->set_entry('dir', $user->{homedir});
        $pwdb->set_entry('shell', $user->{shell});

        if (!PWDB::pwdb_add($pwdb, $user->{name}, $user->{uid}))
        {
            $success = 0;
            push @$bad_users, $user->{name};
        }
        else
        {
            if (!$user->{dont_create_home})
            {
                $DEBUG && warn("creating user's home directory");
                # since were hashing need to create directories first
                mkpath($user->{homedir});
                if (exists($user->{skel}) && $user->{skel})
                {
                    # copy user skel to correct location
                    # no need for this to be rollback safe since the
                    # rollback command will call userdel with the flag
                    # to rm the user's directory
                    system("/bin/cp -r $user->{skel}/* $user->{homedir}");
                    system("/bin/cp /etc/skel/.bash* $user->{homedir}");
                }
    
                Sauce::Util::chmodfile(Sauce::Config::perm_UserDir, $user->{homedir});
                my $uid = getpwnam($user->{name});
                my $gid = getgrnam($user->{group});
                
                $DEBUG && print STDERR Dumper $user;
                $DEBUG && print STDERR "$uid:$gid", "\n";

                # this doesn't need to be rollback safe either since the
                # whole directory just gets blown away on rollback
                system('/bin/chown', '-R', "$uid:$gid", $user->{homedir});
            } # end if !$user->{dont_create_home}

# ROLLBACK USERADD
            # set flag for whether the user's directory should be
            # removed on rollback.  This is a special case for admin-fqdn
            # users
            my $dir_flag = 1;
            if ($user->{dont_create_home})
            {
                $dir_flag = 0;
            }

            my $rollback_cmd = "/usr/bin/perl "
                    . "-I /usr/sausalito/perl -e \"use Base::User qw(userdel); "
                    . "print STDERR \\\"ROLLBACK USERADD\\n\\\"; "
                    . "userdel($dir_flag, '$user->{name}');\"";

            Sauce::Util::addrollbackcommand($rollback_cmd);
        }
    } # done adding current user

    PWDB::pwdb_end();

    # restore umask
    umask($old_umask);

    return ($success, $bad_users);
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
