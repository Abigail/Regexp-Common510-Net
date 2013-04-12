#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2013041201;
use Regexp::Common510 'Net';

our $r = eval "require Test::NoWarnings; 1";

my @addresses = (
    [127,   0,   0,   1],   # Localhost
    [192, 168,   0,   1],   # Private network
    [204, 232, 175,  90],   # Github
    [107,   6, 106,  82],   # XKCD
);

my %format =  (
    bin      => '%b',
    oct      => '%o',
    dec      => '%d',
    hex      => '%x',
);

my $c = 0;
my $address;
foreach my $base (qw [bin oct dec hex]) {
    my $format = $format {$base};

    foreach my $Sep ('\.', ':') {
        my $test = Test::Regexp:: -> new -> init (
            pattern      =>  RE (Net => 'IPv4', -base => $base, -sep => $Sep,
                                                -Keep => 0),
            keep_pattern =>  RE (Net => 'IPv4', -base => $base, -sep => $Sep,
                                                -Keep => 1),
            full_text    =>  1,
            name         => "Net IPv4 -base => '$base', -sep => /$Sep/"
        );
        my $sep = substr $Sep, -1;
        
        foreach my $a (@addresses) {
            $address = sprintf "$format%s$format%s$format" =>
                                $$a [0], $sep, $$a [1], $sep, $$a [2];

            $test -> no_match ($address,
                               reason => "Not enough octets");

            $address = sprintf "$format%s$format%s$format%s$format%s$format" =>
                                $$a [0], $sep, $$a [1], $sep,
                                $$a [2], $sep, $$a [3], $sep, $$a [$c % 4];

            $test -> no_match ($address,
                               reason => "Too many octets");

            $c ++;
        }
    }
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
