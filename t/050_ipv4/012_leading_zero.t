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
# Check leading zeros
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
    bin      => '%08b',
    oct      => '%03o',
    dec      => '%03d',
    hex      => '%02x',
);

my $c = 0;
foreach my $item ([bin => 0b1111111], 
                  [oct => 077],
                  [dec => 99],
                  [hex => 0xf]) {
    my ($base, $max) = @$item;
    my  $format      = $format {$base};
    foreach my $Number (0 .. $max) {
        my $number   = sprintf $format => $Number;
        my $address  = "$number.$number.$number.$number";

        $tester {$base} -> match ($address,
                                  test     => "Leading zeros",
                                  captures => [[IPv4  => $address],
                                               [octet => $number],
                                               [octet => $number],
                                               [octet => $number],
                                               [octet => $number]]);

        $address = $c % 4 == 0 ? "0$number.$number.$number.$number"
                 : $c % 4 == 1 ? "$number.0$number.$number.$number"
                 : $c % 4 == 2 ? "$number.$number.0$number.$number"
                 : $c % 4 == 3 ? "$number.$number.$number.0$number"
                 : die "Eh?";
        $tester {$base} -> no_match ($address,
                                     reason => "Too many leading zeros");
        $c ++;
    }
    foreach my $Number ($max + 1 .. $max + 10) {
        my $number  = sprintf $format => $Number;
        my $address = $c % 4 == 0 ? "0$number.$number.$number.$number"
                    : $c % 4 == 1 ? "$number.0$number.$number.$number"
                    : $c % 4 == 2 ? "$number.$number.0$number.$number"
                    : $c % 4 == 3 ? "$number.$number.$number.0$number"
                    : die "Eh?";
        $tester {$base} -> no_match ($address,
                                     reason => "Leading zero not allowed");
        $c ++;
    }
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
