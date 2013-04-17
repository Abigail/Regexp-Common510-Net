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
my $test_leading_zeros = Test::Regexp:: -> new -> init (
    pattern      => RE (Net => 'IPv6', -Keep => 0, -leading_zeros => 1),
    keep_pattern => RE (Net => 'IPv6', -Keep => 1, -leading_zeros => 1),
    full_text    => 1,
    name         => "Net IPv6, -leading_zeros => 1",
);

my @tests = ($test_default, $test_leading_zeros);

my @chunks = qw [2001 0 ffff 1 aa abcd e9f];
my @lz     = qw [0fff 0ed 0b 00a9 008 00 0007 000 0000];

foreach my $c (1 .. 20) {
    my @units   = @chunks [map {$c  * $_ % @chunks} 1, 2, 3, 5, 7, 11, 13, 17];
    my $address = sprintf "%s:%s:%s:%s:%s:%s:%s:%s" => @units;

    foreach my $test (@tests) {
        $test -> match ($address,
                        test     => "Basic IPv6",
                        captures => [[IPv6 => $address],
                                     map {[unit => $_]} @units]);
    }

    $units [$c % @units] = $lz [$c % @lz];
    $address = sprintf "%s:%s:%s:%s:%s:%s:%s:%s" => @units;

    foreach my $test ($test_leading_zeros) {
        $test -> match ($address,
                        test     => "Basic IPv6, with leading zeros",
                        captures => [[IPv6 => $address],
                                     map {[unit => $_]} @units]);
    }
    foreach my $test ($test_default) {
        $test -> no_match ($address,
                            reason  => "Leading zeros")
    }
}
                          


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
