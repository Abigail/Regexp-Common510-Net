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

my @tests = ($test_default, $test_1035, $test_space, $test_space_1035);

#
# Curiously enough, the longest possible label is 63 characters long,
# and there are 63 valid characters allowed in a label...
#
my $longest = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" .
              "abcdefghijklmnopqrstuvwxyz" .
              "-0123456789";
#
# Make it so that the GCD of the sizes of each pair of sets is 1.
#
my @tlds    = (qw [com net nl biz xxx A], $longest);                       # 7
my @hosts   = (qw [www host X HoSt12345], $longest);                       # 5
my @domains = (qw [domain EXAMPLE PeRl mine123 Q a1b2c Y0 FfF], $longest); # 9

foreach my $label (@tlds [0 .. @tlds - 2], @hosts [0 .. @hosts - 2], @domains) {
    foreach my $test (@tests) {
        $test -> match ($label,
                         test      => "Single label",
                         captures  => [[domain => $label]]);
    }
}

my $c = 0;
foreach (1 .. 43) {
    foreach my $test (@tests) {
        my $name = $domains [$c % @domains] . '.' . $tlds [$c % @tlds];
        $test -> match ($name,
                         test     => "Two level domain",
                         captures => [[domain => $name]]);
        $c ++;
    }
}

foreach (1 .. 71) {
    foreach my $test (@tests) {
        my $name = $hosts   [$c % @hosts]   . '.' .
                   $domains [$c % @domains] . '.' . $tlds [$c % @tlds];
        $test -> match ($name,
                         test     => "Three level host/domain",
                         captures => [[domain => $name]]);
        $c ++;
    }
}



Test::NoWarnings::had_no_warnings () if $r;

done_testing;
