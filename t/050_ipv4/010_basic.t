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
foreach my $base (qw [bin oct dec hex HeX HEX]) {
    $tester {$base} = Test::Regexp:: -> new -> init (
              pattern      => RE (Net => 'IPv4', -base => $base, -Keep => 0),
              keep_pattern => RE (Net => 'IPv4', -base => $base, -Keep => 1),
              name         => "Net IPv4 -base => $base"
    );
}
$tester {default} = Test::Regexp:: -> new -> init (
          pattern      => RE (Net => 'IPv4', -Keep => 0),
          keep_pattern => RE (Net => 'IPv4', -Keep => 1),
          name         => "Net IPv4",
);
$tester {hEx} = $tester {HeX};

my %format =  (
    default  => '%d',
    bin      => '%b',
    oct      => '%o',
    dec      => '%d',
    hex      => '%x',
    HeX      => '%x',
    hEx      => '%X',
    HEX      => '%X',
);

foreach my $Number (0 .. 300) {
    foreach my $base (qw [default bin oct dec hex HeX hEx HEX]) {
        my $number  = sprintf $format {$base} => $Number;
        next if $base eq 'hEX' && $number =~ /^[0-9]+$/; # Done already
        my $address = "$number.$number.$number.$number";
        if ($Number <= 255) {
            $tester {$base} -> match ($address,
                                      captures => [[IPv4  => $address],
                                                   [byte1 => $number],
                                                   [byte2 => $number],
                                                   [byte3 => $number],
                                                   [byte4 => $number]]);
        }
        else {
            $tester {$base} -> no_match ($address);
        }
    }
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
