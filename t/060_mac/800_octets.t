#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2013040301;
use Regexp::Common510 'Net';

our $r = eval "require Test::NoWarnings; 1";

my @addresses = (
    ['01', '23', '45', '67', '89', 'AB'],
    ['00', '00', '00', '00', '00', '00'],
    ['FF', 'FF', 'FF', 'FF', 'FF', 'FF'],
);

my %format =  (
    bin      => '%b',
    oct      => '%o',
    dec      => '%d',
    hex      => '%02x',
);

my $c = 0;
my $address;
foreach my $base (qw [bin oct dec hex]) {
    my $f = $format {$base};

    foreach my $Sep ('\.', ':') {
        my $test = Test::Regexp:: -> new -> init (
            pattern      => RE (Net => 'MAC', -base => $base, -sep => $Sep,
                                              -Keep => 0),
            keep_pattern => RE (Net => 'MAC', -base => $base, -sep => $Sep,
                                              -Keep => 1),
            name         => "Net MAC -base => '$base', -sep => /$Sep/"
        );
        my $sep = substr $Sep, -1;
        
        foreach my $a (@addresses) {
            my @a = map {hex} @$a;
            $address = sprintf "$f%s$f%s$f%s$f%s$f" =>
                                $a [0], $sep, $a [1], $sep, $a [2], $sep,
                                $a [3], $sep, $a [4];

            $test -> no_match ($address,
                               reason => "Not enough octets");

            $address = sprintf "$f%s$f%s$f%s$f%s$f%s$f%s$f" =>
                                $a [0], $sep, $a [1], $sep, $a [2], $sep,
                                $a [3], $sep, $a [4], $sep, $a [5], $sep,
                                $a [$c % 6];

            $test -> no_match ($address,
                               reason => "Too many octets");

            $c ++;
        }
    }
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
