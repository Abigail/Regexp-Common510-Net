#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2013041201;
use t::Patterns;

our $r = eval "require Test::NoWarnings; 1";

my @chunks = qw [2001 0 ffff 1 aa abcd e9f 72b1 d13a];

#
# Too many units, no contractions
#
{
    my $address = join ":" => @chunks;
    foreach my $test (@IPv6) {
        $test -> no_match (
            $address,
            reason => "Too many units"
        )
    }
}

#
# Not enough units, no contractions.
#
{
    for (my $i = 0; $i <= 6; $i ++) {
        my $address = join ":" => @chunks [0 .. $i];
        foreach my $test (@IPv6) {
            $test -> no_match (
                $address,
                reason => "Not enough units"
            );
        }
    }
}

#
# No units at all
#
{
    my $address = ":";
    foreach my $test (@IPv6) {
        $test -> no_match (
            $address,
            reason => "No units"
        );
    }
}


#
# 8 units, with contraction
#
for (my $i = 0; $i <= 8; $i ++) {
    my @left    = @chunks [ 0 .. $i - 1];
    my @right   = @chunks [$i ..  7];
    my $address = join (":" => @left) . '::' . join (":" => @right);
    foreach my $test (@IPv6) {
        $test -> no_match (
            $address,
            reason => "Contraction, and still 8 units"
        )
    }
}
                          


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
