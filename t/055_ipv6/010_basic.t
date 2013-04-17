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

my @tests = ($test_default);

my @chunks = qw [2001 0 ffff 1 aa abcd e9f];

foreach my $c (1 .. 10) {
    my @units   = @chunks [map {$c  * $_ % @chunks} 1, 2, 3, 5, 7, 11, 13, 17];
    my $address = sprintf "%s:%s:%s:%s:%s:%s:%s:%s" => @units;

    foreach my $test (@tests) {
        $test -> match ($address,
                        test     => "Basic IPv6",
                        captures => [[IPv6 => $address],
                                     map {[unit => $_]} @units]);
    }
}
                          


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
