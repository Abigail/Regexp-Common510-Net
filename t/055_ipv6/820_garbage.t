#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2013041801;
use t::Patterns;

our $r = eval "require Test::NoWarnings; 1";

my @ipv6 = qw [2001:0:ab23:9d4:1:ffff:e8:2a0
               2001:0:ab23::e8:2a0
               ::9d4:1:ffff:e8:2a0
               2001:0:ab23:9d4:1::
               a::b
               ::];
my @junk = (' ', ':foo', 'foo:', 'asdfkjqwe', "\x{60c}");

#
# Leading/trailing junk
#
foreach my $ipv6 (@ipv6) {
    foreach my $junk (@junk) {
        my @addresses = ("${ipv6}${junk}", "${junk}${ipv6}");
        foreach my $address (@addresses) {
            foreach my $test (@IPv6) {
                $test -> no_match (
                    $address,
                    reason => "Leading/trailing junk"
                );
            }
        }
    }
}

#
# Garbage
#
foreach my $junk (@junk) {
    foreach my $test (@IPv6) {
        $test -> no_match (
            $junk,
            reason => "Garbage"
        )
    }
}

#
# Make sure the empty string does not match
#
foreach my $test (@IPv6) {
    $test -> no_match (
        "",
        reason => "Empty string",
    )
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
