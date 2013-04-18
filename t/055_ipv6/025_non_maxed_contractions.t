#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2013041201;
use t::Patterns;

$| = 1;

our $r = eval "require Test::NoWarnings; 1";

my @chunks = qw [2001 1d0 ffff 1 aa 98ba abcd e9f];

for (my $l = 0; $l <= 6; $l ++) {
    for (my $m = 2; $m <= 4 && $l + $m <= 8; $m ++) {
        my $r     = 8 - $l - $m;
        my @left  = @chunks [0 .. $l - 1];
        my @right = @chunks [@chunks - $r .. @chunks - 1];

        #
        # Make zero unit sequences of length > $m on the left hand
        # side of the contraction.
        #
        for (my $i = 0; $i + $m < @left; $i ++) {
            for (my $n = $i + $m + 1; $n < @left; $n ++) {
                my @copy     = @left;
                $copy [$_]   = 0 for $i .. $n - 1;
                my $address  = join ":" => @copy, (""), @right;
                   $address .= ":" unless @right;
                   $address  = ":$address" unless @left;
                my @captures = ([IPv6 => $address],
                                map {[unit => $_]} @copy, ("") x $m, @right);

                foreach my $test ($IPv6_default, $IPv6_HeX, $IPv6_lz) {
                    $test -> no_match (
                        $address,
                        reason => "Contraction is not maximal",
                    );
                }
                foreach my $test ($IPv6_no_max_con, $IPv6_rfc2373) {
                    $test -> match (
                        $address,
                        test     => "Contractions do not have to be maximal",
                        captures => \@captures,
                    )
                }
            }
        }


        #
        # Make zero unit sequences of length > $m on the right hand
        # side of the contraction.
        #
        for (my $j = 1; $j + $m <= @right; $j ++) {
            for (my $n = $j + $m + 1; $n < @right; $n ++) {
                my @copy     = @right;
                $copy [$_]   = 0 for $j .. $n - 1;
                my $address  = join ":" => @left, (""), @copy;
                   $address .= ":" unless @right;
                   $address  = ":$address" unless @left;
                my @captures = ([IPv6 => $address],
                                map {[unit => $_]} @left, ("") x $m, @copy);

                foreach my $test ($IPv6_default, $IPv6_HeX, $IPv6_lz) {
                    $test -> no_match (
                        $address,
                        reason => "Contraction is not maximal",
                    );
                }
                foreach my $test ($IPv6_no_max_con, $IPv6_rfc2373) {
                    $test -> match (
                        $address,
                        test     => "Contractions do not have to be maximal",
                        captures => \@captures,
                    )
                }
            }
        }
    }
}



Test::NoWarnings::had_no_warnings () if $r;

done_testing;
