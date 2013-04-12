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

my @garbage = (' ', 'foobar', ':/?@');

my %format =  (
    bin      => '%b',
    oct      => '%o',
    dec      => '%d',
    hex      => '%02x',
);

foreach my $base (qw [bin oct dec hex]) {

    my $f = $format {$base};

    my $test = Test::Regexp:: -> new -> init (
        pattern      => RE (Net => 'MAC', -base => $base, -Keep => 0),
        keep_pattern => RE (Net => 'MAC', -base => $base, -Keep => 1),
        name         => "Net MAC -base => '$base'",
    );
        
    foreach my $a (@addresses) {
        my $address = sprintf "$f:$f:$f:$f:$f:$f" => map {hex} @$a;

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
