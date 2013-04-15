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
my @names = qw [host host.tld host.domain.tld host.first.second.tld];

foreach my $name (@names) {
    foreach my $test (@tests) {
        $test -> no_match ("$name.", reason => "Trailing separator");
        $test -> no_match (".$name", reason => "Leading separator");
        next unless $name =~ /\./;
        my $nnn = $name;
        $nnn  =~ s/\./../;
        $test -> no_match ($nnn, reason => "Doubled separator");
        $nnn  =  $name;
        $nnn  =~ s/\./../g;
        $test -> no_match ($nnn, reason => "Too many separators");
    }
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
