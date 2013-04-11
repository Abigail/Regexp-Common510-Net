#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2013040301;
use Regexp::Common510 'Net';

our $r = eval "require Test::NoWarnings; 1";

#
# Check whether all the numbers 0 .. 255 match, and others do not.
#

my %tester;
foreach my $base (qw [bin oct dec hex]) {
    $tester {$base} = Test::Regexp:: -> new -> init (
              pattern      => RE (Net => 'IPv4', -base => $base, -Keep => 0),
              keep_pattern => RE (Net => 'IPv4', -base => $base, -Keep => 1),
              name         => "Net IPv4 -base => $base"
    );
}

my %format =  (
    bin      => '%b',
    oct      => '%o',
    dec      => '%d',
    hex      => '%x',
);


foreach my $Number (0 .. 63) {
    foreach my $base (qw [bin oct dec hex]) {
        my $format     = $format {$base};
        my $Number1    = sprintf $format =>       $Number;
        my $Number2    = sprintf $format => 127 - $Number;
        my $Number3    = sprintf $format => 128 + $Number;
        my $Number4    = sprintf $format => 255 - $Number;
        my $Number5    = sprintf $format => 256 + $Number;
        my $Number6    = "1$Number4";
        my $address_p1 = sprintf "$Number1.$Number2.$Number3.$Number4";
        my $address_f1 = sprintf "$Number5.$Number2.$Number3.$Number4";
        my $address_f2 = sprintf "$Number1.$Number2.$Number3.$Number6";

        $tester {$base} -> match ($address_p1,
                                  captures => [[IPv4  => $address_p1],
                                               [octet => $Number1],
                                               [octet => $Number2],
                                               [octet => $Number3],
                                               [octet => $Number4]]);
        $tester {$base} -> no_match ($address_f1,
                                     reason => "Leading octet to big");
        $tester {$base} -> no_match ($address_f2,
                                     reason => "Trailing octet to big");
    }
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
