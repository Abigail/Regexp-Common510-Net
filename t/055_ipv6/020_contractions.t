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
    name            => "Net IPv6 -single_contraction => 1",
);


my @chunks = qw [2001 1d0 ffff 1 aa 98ba abcd e9f];

for (my $i = 0; $i <= 7; $i ++) {
    my @left   = @chunks [0 .. $i - 1];
    my $left   =  join ":" => @left;
    my @left_z = @left; $left_z [-1] = 0 if @left_z;
    my $left_z =  join ":" => @left_z;
    my $l      = @left;
    for (my $j = $i + 1; $j <= 8; $j ++) {
        my @right       = @chunks [$j .. 7];
        my $right       =  join ":" => @right;
        my @right_z     = @right; $right_z [0] = 0 if @right_z;
        my $right_z     =  join ":" => @right_z;

        my $address     = "${left}::${right}";
        my $address_lz  = "${left_z}::${right}";
        my $address_rz  = "${left}::${right_z}";
        my $r           = @right;

        my $m           = 8 - $l - $r;

        my @captures    = ([IPv6 => $address],
                            map {[unit => $_]} @left,   ("") x $m, @right);
        my @captures_lz = ([IPv6 => $address_lz],
                            map {[unit => $_]} @left_z, ("") x $m, @right);
        my @captures_rz = ([IPv6 => $address_rz],
                            map {[unit => $_]} @left,   ("") x $m, @right_z);

        if ($m == 1) {
            foreach my $test ($test_default, $test_no_max_con,
                              $test_leading_zeros) {
                $test -> no_match (
                    $address,
                    reason   => "Contraction of 1 unit"
                )
            }
            foreach my $test ($test_single_con) {
                $test -> match (
                    $address,
                    test     => "Contraction of 1 unit",
                    captures => \@captures,
                )
            }
        }
        else {
            foreach my $test ($test_default, $test_no_max_con,
                              $test_single_con, $test_leading_zeros) {
                $test -> match (
                    $address,
                    test     => "Contraction ${l}::${r}",
                    captures => \@captures,
                );
            }

            if ($l) {
                foreach my $test ($test_default, $test_single_con,
                                  $test_leading_zeros) {
                    $test -> no_match (
                        $address_lz,
                         reason => "0 unit before contraction",
                    );
                }
                foreach my $test ($test_no_max_con) {
                    $test -> match (
                        $address_lz,
                        test     => "0 unit before contraction",
                        captures => \@captures_lz,
                    );
                }
            }

            if ($r) {
                foreach my $test ($test_default, $test_single_con,
                                  $test_leading_zeros) {
                    $test -> no_match (
                        $address_rz,
                         reason => "0 unit after contraction",
                    );
                }
                foreach my $test ($test_no_max_con) {
                    $test -> match (
                        $address_rz,
                        test     => "0 unit after contraction",
                        captures => \@captures_rz,
                    );
                }
            }
        }
    }
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
