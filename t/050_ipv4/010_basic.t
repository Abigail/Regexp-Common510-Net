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
foreach my $base (qw [bin 2 oct 8 dec 10 hex HeX HEX 16]) {
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

my %format =  (
    bin      => '%b',
    oct      => '%o',
    dec      => '%d',
    hex      => '%x',
    HEX      => '%X',
);

my %test = (
    bin      => [qw [2 bin]],
    oct      => [qw [8 oct]],
    dec      => [qw [default 10 dec]],
    hex      => [qw [16 hex HeX]],
    HEX      => [qw [16 HEX HeX]],
);

foreach my $Number (0 .. 300) {
    foreach my $base (qw [bin oct dec hex HEX]) {
        my $number  = sprintf $format {$base} => $Number;
        my $address = "$number.$number.$number.$number";

        foreach my $test (@{$test {$base}}) {
            next if $base eq 'HEX' && $test ne 'HEX' && $number =~ /^[0-9]+$/;
            if ($Number <= 255) {
                $tester {$test} -> match ($address,
                                          captures => [[IPv4  => $address],
                                                       [octet => $number],
                                                       [octet => $number],
                                                       [octet => $number],
                                                       [octet => $number]]);
            }
            else {
                $tester {$test} -> no_match ($address);
            }
        }
    }
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
