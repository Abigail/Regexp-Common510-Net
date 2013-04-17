#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2013041201;
use Regexp::Common510 'Net';

our $r = eval "require Test::NoWarnings; 1";

my $test_default = Test::Regexp:: -> new -> init (
    pattern      => RE (Net => 'IPv6', -Keep => 0),
    keep_pattern => RE (Net => 'IPv6', -Keep => 1),
    full_text    => 1,
    name         => "Net IPv6",
);
my $test_HEX     = Test::Regexp:: -> new -> init (
    pattern      => RE (Net => 'IPv6', -Keep => 0, -base => 'HEX'),
    keep_pattern => RE (Net => 'IPv6', -Keep => 1, -base => 'HEX'),
    full_text    => 1,
    name         => "Net IPv6, -base => 'HEX'",
);
my $test_HeX     = Test::Regexp:: -> new -> init (
    pattern      => RE (Net => 'IPv6', -Keep => 0, -base => 'HeX'),
    keep_pattern => RE (Net => 'IPv6', -Keep => 1, -base => 'HeX'),
    full_text    => 1,
    name         => "Net IPv6, -base => 'HeX'",
);
my $test_lz      = Test::Regexp:: -> new -> init (
    pattern      => RE (Net => 'IPv6', -Keep => 0, -leading_zeros => 1),
    keep_pattern => RE (Net => 'IPv6', -Keep => 1, -leading_zeros => 1),
    full_text    => 1,
    name         => "Net IPv6, -leading_zeros => 1",
);
my $test_lz_HEX  = Test::Regexp:: -> new -> init (
    pattern      => RE (Net => 'IPv6', -Keep => 0, -leading_zeros => 1,
                                                   -base          => 'HEX'),
    keep_pattern => RE (Net => 'IPv6', -Keep => 1, -leading_zeros => 1,
                                                   -base          => 'HEX'),
    full_text    => 1,
    name         => "Net IPv6, -leading_zeros => 1, -base => 'HEX'",
);
my $test_lz_HeX  = Test::Regexp:: -> new -> init (
    pattern      => RE (Net => 'IPv6', -Keep => 0, -leading_zeros => 1,
                                                   -base          => 'HeX'),
    keep_pattern => RE (Net => 'IPv6', -Keep => 1, -leading_zeros => 1,
                                                   -base          => 'HeX'),
    full_text    => 1,
    name         => "Net IPv6, -leading_zeros => 1, -base => 'HeX'",
);


my @chunks = qw [2001 0 ffff 1 aa abcd e9f];
my @lz     = qw [0fff 0ed 0b 00a9 008 00 0007 000 0000];

foreach my $c (1 .. 20) {
    my @lc_units    = @chunks [map {$c  * $_ % @chunks}
                                    1, 2, 3, 5, 7, 11, 13, 17];
    my @uc_units    = map {uc} @lc_units;
    my $lc_address  = sprintf "%s:%s:%s:%s:%s:%s:%s:%s" => @lc_units;
    my $uc_address  = sprintf "%s:%s:%s:%s:%s:%s:%s:%s" => @uc_units;
    my @lc_captures = ([IPv6 => $lc_address], map {[unit => $_]} @lc_units);
    my @uc_captures = ([IPv6 => $uc_address], map {[unit => $_]} @uc_units);


    if ($lc_address eq $uc_address) {
        foreach my $test ($test_default, $test_HeX, $test_lz, $test_lz_HeX,
                          $test_HEX, $test_lz_HEX) {
            $test -> match ($lc_address,
                            test     => "Basic IPv6",
                            captures => \@lc_captures,);
        }
    }
    else {
        foreach my $test ($test_default, $test_HeX, $test_lz, $test_lz_HeX) {
            $test -> match ($lc_address,
                            test     => "Basic IPv6",
                            captures => \@lc_captures,);
        }
        foreach my $test ($test_HEX, $test_lz_HEX) {
            $test -> no_match ($lc_address,
                                reason  => "Lower case a-f",);
        }

        foreach my $test ($test_HEX, $test_lz_HEX, $test_HeX, $test_lz_HeX) {
            $test -> match ($uc_address,
                            test     => "Basic IPv6, upper cased",
                            captures => \@uc_captures,);
        }
        foreach my $test ($test_default, $test_lz) {
            $test -> no_match ($uc_address,
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

    if ($lc_address eq $uc_address) {
        foreach my $test ($test_lz, $test_lz_HeX, $test_lz_HEX) {
            $test -> match ($lc_address,
                            test     => "Basic IPv6, with leading zeros",
                            captures => \@lc_captures,);
        }
        foreach my $test ($test_default, $test_HeX, $test_HEX) {
            $test -> no_match ($lc_address,
                                reason  => "Leading zeros")
        }
    }
    else {
        foreach my $test ($test_lz, $test_lz_HeX) {
            $test -> match ($lc_address,
                            test     => "Basic IPv6, with leading zeros",
                            captures => \@lc_captures,);
        }
        foreach my $test ($test_lz_HEX) {
            $test -> no_match ($lc_address,
                                reason => "Lower case a-f")
        }
        foreach my $test ($test_default, $test_HeX) {
            $test -> no_match ($lc_address,
                                reason => "Leading zeros")
        }
        foreach my $test ($test_HEX) {
            $test -> no_match ($lc_address,
                                reason => "Leading zeros & lower case a-f")
        }

        foreach my $test ($test_lz_HEX, $test_lz_HeX) {
            $test -> match ($uc_address,
                            test     => "Basic IPv6, with leading zeros, " .
                                        "upper case A-F",
                            captures => \@uc_captures,);
        }
        foreach my $test ($test_lz) {
            $test -> no_match ($uc_address,
                                reason => "Upper case A-F")
        }
        foreach my $test ($test_HEX, $test_HeX) {
            $test -> no_match ($uc_address,
                                reason => "Leading zeros")
        }
        foreach my $test ($test_default) {
            $test -> no_match ($uc_address,
                                reason => "Leading zeros & upper case A-F")
        }
    }
}
                          


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
