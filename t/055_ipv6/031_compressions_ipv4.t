#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2013041801;
use t::Patterns;

our $r = eval "require Test::NoWarnings; 1";

my @ipv6 = qw [2001 ffff 1 aa e9f a1b2 192];
my @ipv4 = qw [127.0.0.1 192.168.0.1 10.11.12.13 0.0.0.0 255.255.255.255];

for (my $l = 0; $l <= 4; $l ++) {
    state $c = 0;
    my @left = @ipv6 [0 .. $l - 1];
    my $left = join ":" => @left;
    for (my $m = 2; $l + $m <= 6; $m ++) {
        my $r        = 6 - $l - $m;
        my @right    = @ipv6 [@ipv6 - $r .. @ipv6 - 1];
        my $right    = join ":" => @right;

        my $ipv4     = $ipv4 [$c ++ % @ipv4];

        my $address  = "${left}::${right}.$ipv4";
        my @captures = ([IPv6 => $address],
                       (map {[unit => $_]} @left, ("") x $m, @right, ("") x 2),
                        [IPv4 => $ipv4],
                        map {[octet => $_]} split /\./ => $ipv4);

         foreach my $test ($IPv6_ipv4, $IPv6_rfc2373) {
             $test -> match (
                 $address,
                  test     => "Compression and trailing IPv4",
                  captures => \@captures,
             );
         }

         foreach my $test ($IPv6_default) {
             $test -> no_match (
                 $address,
                  reason => "Trailing IPv4 part not allowed",
             );
         }
    }
}
                          


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
