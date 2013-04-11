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
    [127,   0,   0,   1],   # Localhost
    [192, 168,   0,   1],   # Private network
    [204, 232, 175,  90],   # Github
    [107,   6, 106,  82],   # XKCD
);

my @garbage = (' ', 'foobar', ':/?@');

my %format =  (
    bin      => '%b',
    oct      => '%o',
    dec      => '%d',
    hex      => '%x',
);

foreach my $base (qw [bin oct dec hex]) {

    my $format = $format {$base};

    my $test = Test::Regexp:: -> new -> init (
        pattern      => RE (Net => 'IPv4', -base => $base, -Keep => 0),
        keep_pattern => RE (Net => 'IPv4', -base => $base, -Keep => 1),
        name         => "Net IPv4 -base => '$base'",
    );
        
    foreach my $a (@addresses) {
        my $address = sprintf "$format.$format.$format.$format" => @$a;

        foreach my $garbage (@garbage) {
            $test -> no_match ("$address$garbage",
                                reason => "Trailing garbage");
            $test -> no_match ("$garbage$address",
                                reason => "Leading garbage");
            $test -> no_match ("$garbage",
                                reason => "Garbage");
        }
    }

    $test -> no_match ("", reason => "Empty string");
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
