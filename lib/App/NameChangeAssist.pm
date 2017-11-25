#!/usr/bin/perl

#
# Copyright (C) 2017 Joelle Maslak
# All Rights Reserved - See License
#

package App::NameChangeAssist v0.01.00;

use strict;

use File::FindStrings::Boilerplate 'class';

use App::NameChangeAssist::DirectoryCheck;
use App::NameChangeAssist::GitCheck;
use App::NameChangeAssist::LoginCheck;
use App::NameChangeAssist::SourceCheck;
use Config::Any;
use Perl6::Slurp;

# ABSTRACT: Assists with changing huamn's name (such as after marriage) in Linux

=head1 SYNOPSIS

  Nothing here yet

=head1 DESCRIPTION

Nothing Here Yet

=attr config_base

The base configuration filename, defaults to C<.namechangeassistrc> in the
home directory.

=cut

has config_base => (
    is      => 'ro',
    isa     => 'Str',
    builder => '_config_base_builder',
);

sub _config_base_builder($self) {
    if (defined($ENV{HOME}) && ($ENV{HOME} ne '')) {
        return $ENV{HOME} . "/.namechangeassistrc";
    } else {
        return ".namechangeassistrc";
    }
}

=attr config

Config data, defaults to the parsed contents of the config file.

=cut

has config => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    builder => '_config_builder',
);

sub _config_builder($self) {
    my $cfg = Config::Any->load_stems( { stems => [ $self->config_base ], use_ext => 1 } );
    if ( !scalar @$cfg )    { die("Must provide a config file"); }
    if ( scalar @$cfg > 1 ) { die("Must only provide one config file type"); }

    my $k = ( keys $cfg->[0]->%* )[0];
    return $cfg->[0]{$k};
}

=attr bad_names

This contains bad names we don't want to see.  By default, this reads from
the config file.

=cut

has bad_names => (
    is      => 'rw',
    isa     => 'ArrayRef[Str]',
    lazy    => 1,
    builder => '_bad_names_builder',
);

sub _bad_names_builder($self) {
    return $self->config->{bad_names};
}

=attr bad_usernames

This contains bad usernames we don't want to see.  By default, this reads from
the config file.

=cut

has bad_usernames => (
    is      => 'rw',
    isa     => 'ArrayRef[Str]',
    lazy    => 1,
    builder => '_bad_usernames_builder',
);

sub _bad_usernames_builder($self) {
    return $self->config->{bad_usernames};
}

=attr bad_emails

This contains bad email addresses we don't want to see.  By default, this
reads from the config file.

=cut

has bad_emails => (
    is      => 'rw',
    isa     => 'ArrayRef[Str]',
    lazy    => 1,
    builder => '_bad_emails_builder',
);

sub _bad_emails_builder($self) {
    return $self->config->{bad_emails};
}

=method new()

Instantiates the application, currently takes no parameters.

=method run()

Executes the application.

=cut

sub run($self) {
    $self->logstartup();

    my $ret = 0;

    $ret += App::NameChangeAssist::DirectoryCheck::run($self);
    $ret += App::NameChangeAssist::LoginCheck::run($self);
    $ret += App::NameChangeAssist::GitCheck::run($self);
    $ret += App::NameChangeAssist::SourceCheck::run($self);

    $self->info("Finished name change checking");

    return $ret;
}

sub logstartup($self) {
    $self->info("Started name change checking");
    return;
}

sub info ( $self, @log ) {
    logit( $self, "I", @log );
    return;
}

sub isok ( $self, @log ) {
    logit( $self, "D", @log, "...passed" );
    return;
}

sub skip ( $self, @log ) {
    logit( $self, "D", @log, "...skipped" );
    return;
}

sub notok ( $self, @log ) {
    logit( $self, "W", @log, "...NOT OK" );
    return;
}

sub warning ( $self, @log ) {
    logit( $self, "W", @log );
    return;
}

sub err ( $self, @log ) {
    logit( $self, "E", @log );
    return;
}

sub logit ( $self, $type, @log ) {
    if ( $type eq 'D' ) {
        say "debug ", @log;
    } elsif ( $type eq 'I' ) {
        say "info: ", @log;
    } elsif ( $type eq 'W' ) {
        say STDERR "WARN: ", @log;
    } elsif ( $type eq 'E' ) {
        say STDERR "*ERR: ", @log;
    } else {
        say STDERR "*ERR: UNKNOWN LOG TYPE: $type";
        say STDERR "#ERR: ", @log;
    }

    return;
}

1;

