#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2013041801;
use t::Patterns;

$| = 1;

our $r = eval "require Test::NoWarnings; 1";

my @chunks        = qw [2001 1d0 ffff 1 aa 98ba abcd e9f];
my @ipv4_captures = ([IPv4 => undef], ([octet => undef]) x 4);

for (my $l = 0; $l <= 6; $l ++) {
    for (my $m = 2; $m <= 4 && $l + $m <= 8; $m ++) {
        my $r     = 8 - $l - $m;
        my @left  = @chunks [0 .. $l - 1];
        my @right = @chunks [@chunks - $r .. @chunks - 1];

        #
        # Make zero sequences of length $m on the left hand
        # side of the contraction.
        #
        for (my $i = 0; $i + $m < @left; $i ++) {
            my @copy     = @left;
            $copy [$_]   = 0 for $i .. $i + $m - 1;
            my $address  = join ":" => @copy, (""), @right;
               $address .= ":" unless @right;
               $address  = ":$address" unless @left;
            my @captures = ([IPv6 => $address],
                            map {[unit => $_]} @copy, ("") x $m, @right);

            foreach my $test ($IPv6_default, $IPv6_HeX, $IPv6_lz, $IPv6_ipv4) {
                $test -> no_match (
                    $address,
                    reason => "Contraction is not left most",
                )
            }
            foreach my $test ($IPv6_no_max_com, $IPv6_rfc2373, $IPv6_lax) {
                $test -> match (
                    $address,
                    test     => "Contractions do not have to be left most",
                    captures => [@captures,
                                 $test -> tag (-ipv4) ? @ipv4_captures : ()],
                )
            }
        }

        #
        # Make zero sequences of length $m on the right hand
        # side of the contraction. That is always ok.
        #
        for (my $j = 1; $j + $m <= @right; $j ++) {
            my @copy     = @right;
            $copy [$_]   = 0 for $j .. $j + $m - 1;
            my $address  = join ":" => @left, (""), @copy;
               $address .= ":" unless @right;
               $address  = ":$address" unless @left;
            my @captures = ([IPv6 => $address],
                            map {[unit => $_]} @left, ("") x $m, @copy);

            foreach my $test ($IPv6_default, $IPv6_HeX, $IPv6_lz,
                              $IPv6_no_max_com, $IPv6_ipv4, $IPv6_rfc2373,
                              $IPv6_lax) {
                $test -> match (
                    $address,
                    test     => "Squence of zeros of equal length " .
                                "as contraction",
                    captures => [@captures,
                                 $test -> tag (-ipv4) ? @ipv4_captures : ()],
                )
            }
        }
    }
}



Test::NoWarnings::had_no_warnings () if $r;

done_testing;
