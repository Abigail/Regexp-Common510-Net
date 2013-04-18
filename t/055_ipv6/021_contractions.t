#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2013041801;
use t::Patterns;

our $r = eval "require Test::NoWarnings; 1";


my @chunks = qw [2001 1d0 ffff 1 aa 98ba abcd e9f];

#
# Tests that something really is contracted
#
for (my $i = 1; $i < 8; $i ++) {
    my @copy = @chunks;
    splice @copy, $i, 0, "";
    my $address = join ":" => @copy;
    foreach my $test ($IPv6_default, $IPv6_no_max_con, 
                      $IPv6_single_con, $IPv6_lz,
                      $IPv6_rfc2373) {
        $test -> no_match (
            $address,
            reason => "Contracting 0 units"
        )
    }
}
{
    my $address = join ":" => @chunks;
    foreach my $test ($IPv6_default, $IPv6_no_max_con, 
                      $IPv6_single_con, $IPv6_lz,
                      $IPv6_rfc2373) {
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
