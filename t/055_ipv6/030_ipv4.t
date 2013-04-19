#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2013041801;
use t::Patterns;

our $r = eval "require Test::NoWarnings; 1";

my @ipv6 = qw [2001 0 ffff 1 aa e9f a1b2 192];
my @ipv4 = qw [127.0.0.1 192.168.0.1 10.11.12.13 0.0.0.0 255.255.255.255];

foreach my $c (1 .. 20) {
    my @units     =  @ipv6 [map {$c  * $_ % @ipv6} 1, 2, 3, 5, 7, 11];
    my $ipv4      =  $ipv4 [$c % @ipv4];
    my @octets    =   split /\./ => $ipv4;
    my $address   =   sprintf "%s:%s:%s:%s:%s:%s.%s" => @units, $ipv4;
    my @captures  =  ([IPv6 => $address],
                      (map {[unit => $_]} @units, ("") x 2),
                      [IPv4 => $ipv4],
                      (map {[octet => $_]} @octets));

    foreach my $test ($IPv6_ipv4, $IPv6_rfc2373) {
        $test -> match (
            $address,
             test     => "IPv6 with trailing IPv4",
             captures => \@captures,
        );
    }

    foreach my $test ($IPv6_default) {
        $test -> no_match (
            $address,
             reason => "Trailing IPv4 not allowed",
        )
    }
}
                          


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
