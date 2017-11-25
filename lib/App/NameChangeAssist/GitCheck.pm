#!/usr/bin/perl

#
# Copyright (C) 2017 Joelle Maslak
# All Rights Reserved - See License
#

package App::NameChangeAssist::GitCheck;

use strict;

use App::NameChangeAssist::Boilerplate 'script';

use Cwd;
use File::FindStrings qw(find_words_in_file);
use List::Util qw(uniqstr);

our $NAME = 'GitCheck';

sub run($app) {
    state $current = getcwd;
    state $home = $ENV{HOME} // $current;

    my $result = 0;

    $result += check_config( $app, '.git/config' );
    if ( $home ne $current ) {
        $result += check_config( $app, "$home/.gitconfig" );
    }
    $app->isok("$NAME: git config contents");

    return $result;
}

sub check_config ( $app, $configfile ) {
    if ( !-f $configfile ) {
        $app->skip("$NAME: $configfile not found");
        return 0;
    }

    my (@bads) = uniqstr
      map { fc } $app->config->{bad_names}->@*,
      $app->config->{bad_usernames}->@*,
      $app->config->{bad_emails}->@*;

    my (@results) = find_words_in_file( $configfile, @bads );

    if (! scalar(@results)) {
        return 0;
    }

    my (@matches) = uniqstr map { $_->{word} } @results;
    foreach my $match (@matches) {
        $app->notok("$NAME: checking $configfile for \"$match\"");
    }

    return scalar(@matches);
}

1;


