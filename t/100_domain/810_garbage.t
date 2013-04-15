#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2013041201;
use Regexp::Common510 'Net';

our $r = eval "require Test::NoWarnings; 1";

my $test_default    =   Test::Regexp:: -> new -> init (
    pattern         =>  RE (Net => 'domain'),
    keep_pattern    =>  RE (Net => 'domain', -Keep => 1),
    full_text       =>  1,
    name            => "Net domain",
);
my $test_1035       =   Test::Regexp:: -> new -> init (
    pattern         =>  RE (Net => 'domain', -rfc1035 => 1),
    keep_pattern    =>  RE (Net => 'domain', -rfc1035 => 1, -Keep => 1),
    full_text       =>  1,
    name            => "Net domain -rfc1035 => 1",
);
my $test_space      =   Test::Regexp:: -> new -> init (
    pattern         =>  RE (Net => 'domain', -allow_space => 1),
    keep_pattern    =>  RE (Net => 'domain', -allow_space => 1, -Keep => 1),
    full_text       =>  1,
    name            => "Net domain -allow_space => 1",
);
my $test_space_1035 =   Test::Regexp:: -> new -> init (
    pattern         =>  RE (Net => 'domain', -allow_space => 1, -rfc1035 => 1),
    keep_pattern    =>  RE (Net => 'domain', -allow_space => 1, -rfc1035 => 1,
                                             -Keep => 1),
    full_text       =>  1,
    name            => "Net domain -allow_space => 1",
);

my @tests     = ($test_default, $test_space, $test_1035, $test_space_1035);

my @f_hosts   = (" host", "host ", "ho!st");
my @f_domains = ("?domain", "domain\x{1DD}", "\x{23B}");
my @f_tlds    = ("\btld", "tld\n", "t\x{00}ld");


foreach my $test (@tests) {
    foreach my $tld (@f_tlds) {
        $test -> no_match ( $tld,
                             reason => "Illegal character in tld");
        $test -> no_match ( "host.$tld",
                             reason => "Illegal character in tld");
        $test -> no_match ( "host.domain.$tld",
                             reason => "Illegal character in tld");
    }
    foreach my $host (@f_hosts) {
        $test -> no_match ( $host,
                             reason => "Illegal character in host");
        $test -> no_match ("$host.tld",
                             reason => "Illegal character in host");
        $test -> no_match ("$host.domain.tld",
                             reason => "Illegal character in host");
    }
    foreach my $domain (@f_domains) {
        $test -> no_match ("$domain.tld",
                             reason => "Illegal character in domain");
        $test -> no_match ( "host.$domain.tld",
                             reason => "Illegal character in domain");
        $test -> no_match ( "host.domain.$domain.tld",
                             reason => "Illegal character in domain");
        $test -> no_match ( "host.$domain.domain.tld",
                             reason => "Illegal character in domain");
    }
}

my @names = qw [host ho-st host.tld host.t-d host.domain.tld host.do-main.tld];

foreach my $test (@tests) {
    foreach my $name (@names) {
        $test -> no_match (" $name", reason => "Leading garbage");
        $test -> no_match ("$name\n", reason => "Trailing garbage");
    }
    $test -> no_match ("", reason => "Empty string");
    $test -> no_match ("ajq9(*&)NI;'.---+==]", reason => "Garbage");
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
