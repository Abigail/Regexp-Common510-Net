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

my @tests = ($test_default, $test_space, $test_1035, $test_space_1035);

my $max  = "bcd" . ("0123456789" x 6);   # Max label length is 63.
my $long = "a$max";

my @pass = ($max, "host.$max", "$max.tld", "host.$max.tld", "$max.$max.$max");
my @fail = ($long, "host.$long", "$long.tld", "host.$long.tld");


foreach my $address (@pass) {
    foreach my $test (@tests) {
        $test -> match ($address, test => "Max length of label",
                        captures => [[domain => $address]]);
    }
}

foreach my $address (@fail) {
    foreach my $test (@tests) {
        $test -> no_match ($address, reason => "Label too long");
    }
}



Test::NoWarnings::had_no_warnings () if $r;

done_testing;
