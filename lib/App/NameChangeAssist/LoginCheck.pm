#!/usr/bin/perl

#
# Copyright (C) 2017 Joelle Maslak
# All Rights Reserved - See License
#

package App::NameChangeAssist::LoginCheck;

use App::NameChangeAssist::Boilerplate 'script';

sub run($app) {
    my $result = 0;

    foreach my $login ($app->bad_usernames->@*) {
        $result += check_one($app, $login);
    }

    if (! $result) {
        $app->isok("LoginCheck: login name");
    }

    return $result;
}

sub check_one($app, $login) {
    state $current = getlogin // getpwuid($<);
    state $checked = 0;

    if (!defined($current)) {
        if ($checked++) { return 1; }

        $app->warn("LoginCheck: Could not check login name");
        return 1;
    }

    if (fc($current) eq fc($login)) {
        $app->notok("LoginCheck: login name contains $login");
        return 1;
    }

    return 0;
}

1;


