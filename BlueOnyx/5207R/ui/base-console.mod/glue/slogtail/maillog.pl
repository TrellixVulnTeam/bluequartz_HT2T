#!/usr/bin/suidperl

$ENV{'PATH'} = '/usr/bin';

system("/usr/bin/tail -200 /var/log/maillog");

