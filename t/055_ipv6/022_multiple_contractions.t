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


my @chunks = qw [2001 1d0 ffff 1 aa 98ba abcd e9f];

#
# No multiple contractions
#
my %seen;
for (my $i = 0; $i <= 6; $i ++) {
    my $i_chunks = join ":" => @chunks [0 .. $i - 1];
    for (my $m1 = 1; $i + $m1 <= 7; $m1 ++) {
        for (my $j = 0; $i + $m1 + $j <= 7; $j ++) {
            my $j_chunks = join ":" => @chunks [$i + $m1 .. $i + $m1 + $j - 1];
            for (my $m2 = 1; $i + $m1 + $j + $m2 <= 8; $m2 ++) {
                for (my $k = 0; $i + $m1 + $j + $m2 + $k <= 6; $k ++) {
                    my $k_chunks = join ":" =>
                                        @chunks [$i + $m1 + $j + $m2 ..
                                                 $i + $m1 + $j + $m2 + $k - 1];
                    my $address = "${i_chunks}::${j_chunks}::${k_chunks}";
                    next if $seen {$address} ++;
                    foreach my $test ($test_default, $test_no_max_con, 
                                      $test_single_con, $test_leading_zeros) {
                        $test -> no_match (
                            $address,
                            reason => "Multiple contractions"
                        )
                    }
                }
            }
        }
    }
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
