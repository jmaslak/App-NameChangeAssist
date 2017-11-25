#!/usr/bin/perl

#
# Copyright (C) 2017 Joelle Maslak
# All Rights Reserved - See License
#

use App::NameChangeAssist::Boilerplate 'script';

use App::NameChangeAssist;

MAIN: {
    my $app = App::NameChangeAssist->new();
    exit $app->run();
}

