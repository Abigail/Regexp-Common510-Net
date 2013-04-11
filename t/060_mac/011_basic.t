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
              pattern      => RE (Net => 'MAC', -base => $base, -Keep => 0),
              keep_pattern => RE (Net => 'MAC', -base => $base, -Keep => 1),
              name         => "Net MAC -base => $base"
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
        my $Num1       = sprintf $format =>       $Number;
        my $Num2       = sprintf $format => 127 - $Number;
        my $Num3       = sprintf $format => 128 + $Number;
        my $Num4       = sprintf $format => 255 - $Number;
        my $Num5       = sprintf $format =>  64 + $Number;
        my $Num6       = sprintf $format => 191 - $Number;
        my $Num7       = sprintf $format => 256 + $Number;
        my $Num8       = "1$Num4";
        my $address_p1 = sprintf "$Num1:$Num2:$Num3:$Num4:$Num5:$Num6";
        my $address_f1 = sprintf "$Num7:$Num2:$Num3:$Num4:$Num5:$Num6";
        my $address_f2 = sprintf "$Num1:$Num2:$Num3:$Num4:$Num5:$Num8";

        $tester {$base} -> match ($address_p1,
                                  captures => [[MAC   => $address_p1],
                                               [octet => $Num1],
                                               [octet => $Num2],
                                               [octet => $Num3],
                                               [octet => $Num4],
                                               [octet => $Num5],
                                               [octet => $Num6]]);
        $tester {$base} -> no_match ($address_f1,
                                     reason => "Leading octet to big");
        $tester {$base} -> no_match ($address_f2,
                                     reason => "Trailing octet to big");
    }
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
