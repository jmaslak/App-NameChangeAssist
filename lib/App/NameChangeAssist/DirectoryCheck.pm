#!/usr/bin/perl

#
# Copyright (C) 2017 Joelle Maslak
# All Rights Reserved - See License
#

package App::NameChangeAssist::DirectoryCheck;

use strict;

use App::NameChangeAssist::Boilerplate 'script';

use Cwd;

our $NAME = 'DirectoryCheck';

sub run($app) {
    my $result = 0;

    foreach my $login ($app->bad_usernames->@*) {
        $result += check_one($app, $login);
    }

    if (! $result) {
        $app->isok("$NAME: directory names");
    }

    return $result;
}

sub check_one($app, $login) {
    state $current = getcwd;
    state $home    = $ENV{HOME} // $current;

    my $ret = 0;

    if ($current =~ m/\b$login\b/gis) {
        $ret++;
        $app->notok("$NAME: current directory name contains $login");
    }

    if ( ($current ne $home) && ($home =~ m/\b$login\b/gis)) {
        $ret++;
        $app->notok("$NAME: home directory name contains $login");
    }

    return $ret;
}

1;



