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
# Check leading zeros
#

my %tester;
foreach my $base (qw [bin oct dec hex]) {
    $tester {$base} = Test::Regexp:: -> new -> init (
              pattern      =>  RE (Net => 'MAC', -base => $base, -Keep => 0),
              keep_pattern =>  RE (Net => 'MAC', -base => $base, -Keep => 1),
              full_text    =>  1,
              name         => "Net MAC -base => $base"
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
        my $num      = sprintf $format => $Number;
        my $address  = "$num:$num:$num:$num:$num:$num";

        $tester {$base} -> match ($address,
                                  test     => "Leading zeros",
                                  captures => [[MAC   => $address],
                                               [octet => $num],
                                               [octet => $num],
                                               [octet => $num],
                                               [octet => $num],
                                               [octet => $num],
                                               [octet => $num]]);

        $address = $c % 6 == 0 ? "0$num:$num:$num:$num:$num:$num"
                 : $c % 6 == 1 ? "$num:0$num:$num:$num:$num:$num"
                 : $c % 6 == 2 ? "$num:$num:0$num:$num:$num:$num"
                 : $c % 6 == 3 ? "$num:$num:$num:0$num:$num:$num"
                 : $c % 6 == 4 ? "$num:$num:$num:$num:0$num:$num"
                 : $c % 6 == 5 ? "$num:$num:$num:$num:$num:0$num"
                 : die "Eh?";
        $tester {$base} -> no_match ($address,
                                     reason => "Too many leading zeros");
        $c ++;
    }
    foreach my $Number ($max + 1 .. $max + 10) {
        my $num     = sprintf $format => $Number;
        my $address = $c % 6 == 0 ? "0$num:$num:$num:$num:$num:$num"
                    : $c % 6 == 1 ? "$num:0$num:$num:$num:$num:$num"
                    : $c % 6 == 2 ? "$num:$num:0$num:$num:$num:$num"
                    : $c % 6 == 3 ? "$num:$num:$num:0$num:$num:$num"
                    : $c % 6 == 4 ? "$num:$num:$num:$num:0$num:$num"
                    : $c % 6 == 5 ? "$num:$num:$num:$num:$num:0$num"
                    : die "Eh?";
        $tester {$base} -> no_match ($address,
                                     reason => "Leading zero not allowed");
        $c ++;
    }
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
