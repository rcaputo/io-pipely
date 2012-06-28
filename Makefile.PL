#!/usr/bin/perl
# rocco // vim: ts=2 sw=2 expandtab

use strict;
use ExtUtils::MakeMaker;

### Touch files that will be generated at "make dist" time.
### ExtUtils::MakeMaker will complain about them if
### they aren't present now.

open(TOUCH, ">>CHANGES") and close TOUCH;
open(TOUCH, ">>README") and close TOUCH;

# check for optional IPv6 stuff
{
  # under perl-5.6.2 the warning "leaks" from the eval, while newer versions don't...
  # it's due to Exporter.pm behaving differently, so we have to shut it up
  no warnings 'redefine';
  require Carp;
  local *Carp::carp = sub { die @_ };

  # On perl-5.14.0 Socket.pm provides getaddrinfo
  # otherwise we need to use Socket::GetAddrInfo
  eval { require Socket; Socket->import("getaddrinfo") };
  if ($@) {
    check_for_modules( "optional",
      "Socket::GetAddrInfo" => "0.20",
    );
  }

  # On perl-5.14.0 Socket.pm provides the needed IPv6 constants
  # otherwise we need to use Socket6
  eval { Socket->import( qw(AF_INET6 PF_INET6) ) };
  if ($@) {
    check_for_modules( "optional",
      "Socket6" => "0.23",
    );
  }
}

### Generate Makefile.PL.

WriteMakefile(
  NAME               => 'IO::Pipely',
  AUTHOR             => 'Rocco Caputo <rcaputo@cpan.org>',
  ABSTRACT           => 'Create pipe()-like file handles portably for any platform.',
  LICENSE            => 'perl',

  VERSION_FROM       => 'lib/IO/Pipely.pm',
  dist               => {
    COMPRESS => 'gzip -9f',
    SUFFIX   => 'gz',
    PREOP    => (
      'git-log.pl | ' .
      '/usr/bin/tee ./$(DISTNAME)-$(VERSION)/CHANGES > ./CHANGES; '
    ),
  },

  clean => {
    FILES => join ' ', qw(
      */*/*/*/*~
      */*/*/*~
      */*/*/*~
      */*/*~
      */*~
      *~
      META.yml
      Makefile.old
      coverage.report
    ),
  },

  test => { TESTS => 't/*.t t/*/*.t' },

  PREREQ_PM => {
    "Errno"      => 1.09,
    "Fcntl"      => 0,
    "IO::Socket" => 0,
    "Symbol"     => 0,
    "Test::More" => 0,
  },

  META_MERGE => {
    resources => {
      homepage   => 'http://github.com/rcaputo/io-pipely',
      license    => 'http://dev.perl.org/licenses/',
      repository => 'http://github.com/rcaputo/io-pipely',  # TODO - anon git
    },
  },

  # TODO - ExtUtils::MakeMaker doesn't generate 'provides'.
  # Module::Build did, but we're not using it anymore.
);

1;
