#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2013041201;
use Regexp::Common510 'Net';

our $r = eval "require Test::NoWarnings; 1";

#
# Check extra & missing separators
#

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

my $address;
foreach my $base (qw [bin oct dec hex]) {

    my $test = Test::Regexp:: -> new -> init (
        pattern      =>  RE (Net => 'IPv4', -base => $base, -Keep => 0),
        keep_pattern =>  RE (Net => 'IPv4', -base => $base, -Keep => 1),
        full_text    =>  1,
        name         => "Net IPv4 -base => '$base'",
    );
        
    foreach my $a (@addresses) {
        my @n = map {sprintf $format {$base} => $_} @$a;

        $address = ".$n[0].$n[1].$n[2].$n[3]";
        $test -> no_match ($address, reason => "Leading separator");

        $address = "$n[0].$n[1].$n[2].$n[3].";
        $test -> no_match ($address, reason => "Trailing separator");

        $address = "$n[0].$n[1]..$n[2].$n[3]";
        $test -> no_match ($address, reason => "Additional separator");

        $address = "$n[0].$n[1]$n[2].$n[3]";
        $test -> no_match ($address, reason => "Missing separator");
    }
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
