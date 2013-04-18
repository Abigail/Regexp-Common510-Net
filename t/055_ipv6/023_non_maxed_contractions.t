#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2013041201;
use t::Patterns;

our $r = eval "require Test::NoWarnings; 1";

my @chunks = qw [2001 1d0 ffff 1 aa 98ba abcd e9f];

#
# Create addresses with 8 units, and 2 or more zero units in a row
#
for (my $i = 0; $i < @chunks - 1; $i ++) {
    for (my $j = $i + 1; $j < @chunks; $j ++) {
        my @copy     = @chunks;
        $copy [$_]   = 0 for $i .. $j;
        my $address  = join ":" => @copy;
        my @captures = ([IPv6 => $address],
                        map {[unit => $_]} @copy);

        foreach my $test ($IPv6_default, $IPv6_HeX, $IPv6_lz) {
            $test -> no_match (
                $address,
                reason => "Address can be contracted"
            )
        }
        foreach my $test ($IPv6_no_max_con, $IPv6_rfc2373) {
            $test -> match (
                $address,
                test => "Contractable sequences are allowed",
                captures => \@captures
            )
        }
    }
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
