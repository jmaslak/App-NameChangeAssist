#!/usr/bin/perl

#
# Copyright (C) 2017 Joelle Maslak
# All Rights Reserved - See License
#

package App::NameChangeAssist::SourceCheck;

use strict;

use App::NameChangeAssist::Boilerplate 'script';

use Cwd;
use File::Find qw(find);
use File::FindStrings qw(find_words_in_file);
use List::Util qw(uniqstr);

our $NAME = 'SourceCheck';

sub run($app) {
    state $current = getcwd;
    state $home = $ENV{HOME} // $current;

    my $result = 0;

    if ( ! -d '.git' ) {
        $app->skip("$NAME: current directory is not a repo");
        return 0;
    }

    find(
        sub {
            my $base = $_;
            my $name = $File::Find::name;

            # Needs to be readable
            if ( ! -f $base ) { return; }
            if ( ! -r $base ) { return; }

            # Skip GIT & build files
            if ( $name =~ m{/\.(?:build|git)/}gis) { return; }

            # Skip things that aren't source code
            if ( $base !~ m/\.(?:c|cpp|pl|pm|pl6|sh)$/gis) { return; }

            $result += check_file($app, $name, $base);
        },
        '.'
    );

    if ($result == 0) {
        $app->isok("$NAME: code files");
    }

    return $result;
}

sub check_file ( $app, $file, $base ) {
    if ( ! -r $base ) { return 0; }

    my (@bads) = uniqstr
      map { fc } $app->config->{bad_names}->@*,
      $app->config->{bad_usernames}->@*,
      $app->config->{bad_emails}->@*;

    my (@results) = find_words_in_file( $base, @bads );

    if (! scalar(@results)) {
        return 0;
    }

    my (@matches) = uniqstr map { $_->{word} } @results;
    foreach my $match (@matches) {
        $app->notok("$NAME: checking $file for \"$match\"");
    }

    return scalar(@matches);
}

1;

