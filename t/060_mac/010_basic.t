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
              pattern      => RE (Net => 'MAC', -base => $base, -Keep => 0),
              keep_pattern => RE (Net => 'MAC', -base => $base, -Keep => 1),
              name         => "Net MAC -base => $base"
    );
}
$tester {default} = Test::Regexp:: -> new -> init (
          pattern      => RE (Net => 'MAC', -Keep => 0),
          keep_pattern => RE (Net => 'MAC', -Keep => 1),
          name         => "Net MAC",
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
    dec      => [qw [10 dec]],
    hex      => [qw [default 16 hex HeX]],
    HEX      => [qw [default 16 HEX HeX]],
);

foreach my $Number (0 .. 300) {
    foreach my $base (qw [bin oct dec hex HEX]) {
        my $number  = sprintf $format {$base} => $Number;
        my $address = "$number:$number:$number:$number:$number:$number";

        foreach my $test (@{$test {$base}}) {
            next if $base eq 'HEX' && $test ne 'HEX' && $number =~ /^[0-9]+$/;
            if ($Number <= 255) {
                $tester {$test} -> match ($address,
                                          captures => [[MAC   => $address],
                                                       [octet => $number],
                                                       [octet => $number],
                                                       [octet => $number],
                                                       [octet => $number],
                                                       [octet => $number],
                                                       [octet => $number]]);
            }
            else {
                $tester {$test} -> no_match ($address,
                                             reason => "Octets too large");
            }
        }
    }
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
