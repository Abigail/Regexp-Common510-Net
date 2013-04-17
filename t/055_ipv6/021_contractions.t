#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2013041201;
use Regexp::Common510 'Net';

our $r = eval "require Test::NoWarnings; 1";

my $test_default    = Test::Regexp:: -> new -> init (
    pattern         => RE (Net => 'IPv6', -Keep => 0),
    keep_pattern    => RE (Net => 'IPv6', -Keep => 1),
    full_text       => 1,
    name            => "Net IPv6",
);
my $test_no_max_con = Test::Regexp:: -> new -> init (
    pattern         => RE (Net => 'IPv6', -Keep => 0, -max_contraction => 0),
    keep_pattern    => RE (Net => 'IPv6', -Keep => 1, -max_contraction => 0),
    full_text       => 1,
    name            => "Net IPv6 -max_contraction => 0",
);
my $test_single_con = Test::Regexp:: -> new -> init (
    pattern         => RE (Net => 'IPv6', -Keep => 0, -single_contraction => 1),
    keep_pattern    => RE (Net => 'IPv6', -Keep => 1, -single_contraction => 1),
    full_text       => 1,
    name            => "Net IPv6 -single_contraction => 1",
);
my $test_leading_zeros = Test::Regexp:: -> new -> init (
    pattern         => RE (Net => 'IPv6', -Keep => 0, -leading_zeros => 1),
    keep_pattern    => RE (Net => 'IPv6', -Keep => 1, -leading_zeros => 1),
    full_text       => 1,
    name            => "Net IPv6 -leading_zeros => 1",
);
my $test_rfc2373 = Test::Regexp:: -> new -> init (
    pattern      => RE (Net => 'IPv6', -Keep => 0, -rfc2373 => 1),
    keep_pattern => RE (Net => 'IPv6', -Keep => 1, -rfc2373 => 1),
    full_text    => 1,
    name         => "Net IPv6, -rfc2373 => 1",
);


my @chunks = qw [2001 1d0 ffff 1 aa 98ba abcd e9f];

#
# Tests that something really is contracted
#
for (my $i = 1; $i < 8; $i ++) {
    my @copy = @chunks;
    splice @copy, $i, 0, "";
    my $address = join ":" => @copy;
    foreach my $test ($test_default, $test_no_max_con, 
                      $test_single_con, $test_leading_zeros,
                      $test_rfc2373) {
        $test -> no_match (
            $address,
            reason => "Contracting 0 units"
        )
    }
}
{
    my $address = join ":" => @chunks;
    foreach my $test ($test_default, $test_no_max_con, 
                      $test_single_con, $test_leading_zeros,
                      $test_rfc2373) {
        foreach my $address ("::$address", "${address}::") {
            $test -> no_match (
                $address,
                reason => "Contracting 0 units"
            )
        }
    }
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
