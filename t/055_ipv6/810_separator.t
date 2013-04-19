#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2013041801;
use t::Patterns;

our $r = eval "require Test::NoWarnings; 1";

my @chunks = qw [2001 0 ffff 1 aa e9f 72b1 d13a];
my @ipv4   = qw [127.0.0.1 0.0.0.0 255.255.255.255 192.168.0.1];

foreach my $sep ('.', '-', ' ') {
    my @addresses = (
        join ($sep => @chunks),
        $chunks [0] . $sep . join (':' => @chunks [1 .. @chunks - 1]),
        join (':' => @chunks [0 .. 6]) . $sep . $chunks [7],
    );
    foreach my $address (@addresses) {
        foreach my $test (@IPv6) {
            $test -> no_match (
                $address,
                reason => "Incorrect separator '$sep'"
            );
        }
    }
}
foreach my $ipv4 (@ipv4) {
    my $address = join (':', @chunks [0 .. 5]) . ':' . $ipv4;
    foreach my $test ($IPv6_rfc2373, $IPv6_ipv4) {
        $test -> no_match (
            $address,
            reason => "IPv6 units and IPv4 address separated by a ':'"
        );
    }
    $ipv4 =~ s/\./:/g;
    $address = join (':', @chunks [0 .. 5]) . '.' . $ipv4;
    foreach my $test ($IPv6_rfc2373, $IPv6_ipv4) {
        $test -> no_match (
            $address,
            reason => "IPv4 octets separated by a ':'"
        );
    }
}
    
                          


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
