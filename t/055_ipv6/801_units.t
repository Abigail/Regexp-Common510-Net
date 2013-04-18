#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2013041801;
use t::Patterns;

our $r = eval "require Test::NoWarnings; 1";

my @chunks = qw [2001 0 ffff 1 aa abcd e9f 72b1];
my @big    = qw [12345 abcde 1234567890abcdef];
my @big_lz = qw [00000 000000 01234 00abc];

#
# Units exceed 16-bits
#
{
    for (my $i = 0; $i < @chunks; $i ++) {
        my @copy      = @chunks;
           $copy [$i] = $big [$i % @big];

        my $address = join ":" => @copy;
        foreach my $test (@IPv6) {
            $test -> no_match (
                $test -> name =~ /HEX/ ? uc $address : $address,
                reason => "Unit too large"
            )
        }

        @copy      = @chunks;
        $copy [$i] = $big_lz [$i % @big_lz];
        $address   = join ":" => @copy;
        foreach my $test ($IPv6_lz, $IPv6_lz_HeX, $IPv6_rfc2373) {
            $test -> no_match (
                $address,
                reason => "Too many leading zeros"
            )
        }
    }
}

for (my $i = 0; $i <= 6; $i ++) {
    for (my $j = 0; $i + $j <= 6; $j ++) {
        next unless $i || $j;
        my @left  = @chunks [0 .. $i - 1];
        my @right = @chunks [8 - $j .. 7];
        my @addresses;
        for (my $n = 0; $n < @left; $n ++) {
            local $left [$n] = $big [$n % @big];
            push @addresses => join (":" => @left) . "::" .
                               join (":" => @right);
        }
        for (my $n = 0; $n < @right; $n ++) {
            local $right [$n] = $big [$n % @big];
            push @addresses => join (":" => @left) . "::" .
                               join (":" => @right);
        }
        foreach my $address (@addresses) {
            foreach my $test (@IPv6) {
                $test -> no_match (
                    $test -> name =~ /HEX/ ? uc $address : $address,
                    reason => "Unit too large"
                )
            }
        }
    }
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
