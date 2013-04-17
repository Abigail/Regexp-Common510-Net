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

my @tests = ($test_default, $test_no_max_con);

my @chunks = qw [2001 1d0 ffff 1 aa 98ba abcd e9f];

for (my $i = 0; $i <= 6; $i ++) {
    my @left   = @chunks [0 .. $i - 1];
    my $left   =  join ":" => @left;
    my @left_z = @left; $left_z [-1] = 0 if @left_z;
    my $left_z =  join ":" => @left_z;
    my $l      = @left;
    for (my $j = $i + 2; $j <= 8; $j ++) {
        my @right   = @chunks [$j .. 7];
        my $right   =  join ":" => @right;
        my @right_z = @right; $right_z [0] = 0 if @right_z;
        my $right_z =  join ":" => @right_z;

        my $address = "${left}::${right}";
        my $r       = @right;

        foreach my $test (@tests) {
            $test -> match ($address,
                             test     => "Contraction ${l}::${r}",
                             captures => [[IPv6 => $address],
                                          map {[unit => $_]} @left,
                                                           ("") x (8 - $l - $r),
                                                            @right]
            );
        }

        if ($l) {
            my $address = "${left_z}::${right}";
            $test_default -> no_match (
                $address,
                reason => "0 unit before contraction",
            );
            $test_no_max_con -> match (
                $address,
                test     => "0 unit before contraction",
                captures => [[IPv6 => $address],
                             map {[unit => $_]} @left_z,
                                               ("") x (8 - $l - $r),
                                                @right]
            );
        }

        if ($r) {
            my $address = "${left}::${right_z}";
            $test_default -> no_match ($address,
                                       reason => "0 unit after contraction",
            );
            $test_no_max_con -> match (
                $address,
                test     => "0 unit after contraction",
                captures => [[IPv6 => $address],
                             map {[unit => $_]} @left,
                                               ("") x (8 - $l - $r),
                                                @right_z]
            );
        }
    }
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
