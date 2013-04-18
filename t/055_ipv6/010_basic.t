#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

$| = 1;

use Test::More 0.88;
use Test::Regexp 2013041801;
use t::Patterns;

our $r = eval "require Test::NoWarnings; 1";


my @chunks = qw [2001 0 ffff 1 aa abcd e9f];
my @lz     = qw [0fff 0ed 0b 00a9 008 00 0007 000 0000];

foreach my $c (1 .. 20) {
    my @lc_units         = @chunks [map {$c  * $_ % @chunks}
                                         1, 2, 3, 5, 7, 11, 13, 17];
    my @uc_units         = map {uc} @lc_units;
    my $lc_address       = sprintf "%s:%s:%s:%s:%s:%s:%s:%s" => @lc_units;
    my $uc_address       = sprintf "%s:%s:%s:%s:%s:%s:%s:%s" => @uc_units;
    my @lc_captures      = ([IPv6 => $lc_address],
                                      map {[unit => $_]} @lc_units);
    my @uc_captures      = ([IPv6 => $uc_address],
                                      map {[unit => $_]} @uc_units);

    my @ipv4_lc_captures = (@lc_captures, [IPv4  => undef],
                                         ([octet => undef]) x 4);
    my @ipv4_uc_captures = (@uc_captures, [IPv4  => undef],
                                         ([octet => undef]) x 4);

    if ($lc_address eq $uc_address) {
        foreach my $test ($IPv6_default, $IPv6_HeX, $IPv6_lz, $IPv6_lz_HeX,
                          $IPv6_HEX, $IPv6_lz_HEX, $IPv6_ipv4, $IPv6_rfc2373) {
            $test -> match (
                $lc_address,
                 test     => "Basic IPv6",
                 captures => $test -> tag (-ipv4) ? \@ipv4_lc_captures
                                                  : \     @lc_captures
            );
        }
    }
    else {
        foreach my $test ($IPv6_default, $IPv6_HeX, $IPv6_lz, $IPv6_lz_HeX,
                          $IPv6_ipv4, $IPv6_rfc2373,) {
            $test -> match (
                $lc_address,
                 test     => "Basic IPv6",
                 captures => $test -> tag (-ipv4) ? \@ipv4_lc_captures
                                                  : \     @lc_captures
            );
        }
        foreach my $test ($IPv6_HEX, $IPv6_lz_HEX) {
            $test -> no_match (
                $lc_address,
                 reason  => "Lower case a-f",
            );
        }

        foreach my $test ($IPv6_HEX, $IPv6_lz_HEX, $IPv6_HeX, $IPv6_lz_HeX,
                          $IPv6_rfc2373,) {
            $test -> match (
                $uc_address,
                 test     => "Basic IPv6, upper cased",
                 captures => $test -> tag (-ipv4) ? \@ipv4_uc_captures
                                                  : \     @uc_captures,
            );
        }
        foreach my $test ($IPv6_default, $IPv6_lz, $IPv6_ipv4) {
            $test -> no_match (
                $uc_address,
                 reason  => "Upper case A-F",);
        }
    }

    #
    # Replace one of the units with a unit with a leading zero.
    #
    $lc_units [$c % @lc_units] = $lz [$c % @lz];
    $lc_address  = sprintf "%s:%s:%s:%s:%s:%s:%s:%s" => @lc_units;
    @lc_captures = ([IPv6 => $lc_address], map {[unit => $_]} @lc_units);
    $uc_units [$c % @uc_units] = uc $lz [$c % @lz];
    $uc_address  = sprintf "%s:%s:%s:%s:%s:%s:%s:%s" => @uc_units;
    @uc_captures = ([IPv6 => $uc_address], map {[unit => $_]} @uc_units);

    @ipv4_lc_captures = (@lc_captures, [IPv4 => undef], ([octet => undef]) x 4);
    @ipv4_uc_captures = (@uc_captures, [IPv4 => undef], ([octet => undef]) x 4);

    if ($lc_address eq $uc_address) {
        foreach my $test ($IPv6_lz, $IPv6_lz_HeX, $IPv6_lz_HEX,
                          $IPv6_rfc2373,) {
            $test -> match (
                $lc_address,
                 test     => "Basic IPv6, with leading zeros",
                 captures => $test -> tag (-ipv4) ? \@ipv4_lc_captures
                                                  : \     @lc_captures,
            );
        }
        foreach my $test ($IPv6_default, $IPv6_HeX, $IPv6_HEX, $IPv6_ipv4) {
            $test -> no_match (
                $lc_address,
                 reason  => "Leading zeros",
            );
        }
    }
    else {
        foreach my $test ($IPv6_lz, $IPv6_lz_HeX, $IPv6_rfc2373) {
            $test -> match (
                $lc_address,
                 test     => "Basic IPv6, with leading zeros",
                 captures => $test -> tag (-ipv4) ? \@ipv4_lc_captures
                                                  : \     @lc_captures,
            );
        }
        foreach my $test ($IPv6_lz_HEX) {
            $test -> no_match (
                $lc_address,
                 reason => "Lower case a-f",
            );
        }
        foreach my $test ($IPv6_default, $IPv6_HeX, $IPv6_ipv4) {
            $test -> no_match (
                $lc_address,
                 reason => "Leading zeros",
            );
        }
        foreach my $test ($IPv6_HEX) {
            $test -> no_match (
                $lc_address,
                 reason => "Leading zeros & lower case a-f",
            );
        }

        foreach my $test ($IPv6_lz_HEX, $IPv6_lz_HeX, $IPv6_rfc2373) {
            $test -> match (
                $uc_address,
                 test     => "Basic IPv6, with leading zeros, upper case A-F",
                 captures => $test -> tag (-ipv4) ? \@ipv4_uc_captures
                                                  : \     @uc_captures,
            );
        }
        foreach my $test ($IPv6_lz) {
            $test -> no_match (
                $uc_address,
                 reason => "Upper case A-F",
            );
        }
        foreach my $test ($IPv6_HEX, $IPv6_HeX) {
            $test -> no_match (
                $uc_address,
                 reason => "Leading zeros",
            );
        }
        foreach my $test ($IPv6_default, $IPv6_ipv4) {
            $test -> no_match (
                $uc_address,
                 reason => "Leading zeros & upper case A-F",
            );
        }
    }
}
                          


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
