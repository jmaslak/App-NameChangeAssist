#!/usr/bin/perl

#
# Copyright (C) 2017 Joelle Maslak
# All Rights Reserved - See License
#

use App::NameChangeAssist::Boilerplate 'script';

use Test2::Bundle::Extended 0.000058;

MAIN: {
    require App::NameChangeAssist;
    ok(1);
    done_testing;
}

1;


