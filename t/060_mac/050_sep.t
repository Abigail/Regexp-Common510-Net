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

my %format =  (
    bin      => '%b',
    oct      => '%o',
    dec      => '%d',
    hex      => '%x',
);

foreach my $base (qw [bin oct dec hex]) {

    my $f = $format {$base};

    foreach my $sep ('\.', ' ', "\x{1362}") {
        my $test = Test::Regexp:: -> new -> init (
            pattern      => RE (Net => 'MAC', -base => $base, -sep => $sep,
                                               -Keep => 0),
            keep_pattern => RE (Net => 'MAC', -base => $base, -sep => $sep,
                                               -Keep => 1),
            name         => "Net MAC -base => '$base', -sep => /$sep/"
        );

        my $s = substr $sep, -1;
        
        foreach my $a (@addresses) {
            my @a = map {hex} @$a;
            my $address_p1 = sprintf "$f%s$f%s$f%s$f%s$f%s$f" =>
                                      $a [0],  $s, $a [1],  $s, $a [2],  $s,
                                      $a [3],  $s, $a [4],  $s, $a [5];
            my $address_f1 = sprintf "$f%s$f%s$f%s$f%s$f%s$f" =>
                                      $a [0],  $s, $a [1],  $s, $a [2],  $s,
                                      $a [3], ':', $a [4],  $s, $a [5];
            my $address_f2 = sprintf "$f%s$f%s$f%s$f%s$f%s$f" =>
                                      $a [0], ':', $a [1], ':', $a [2], ':',
                                      $a [3], ':', $a [4], ':', $a [5];
            $test -> match ($address_p1,
                            captures => [
                                [MAC   => $address_p1],
                                [octet => sprintf ($f => $a [0])],
                                [octet => sprintf ($f => $a [1])],
                                [octet => sprintf ($f => $a [2])],
                                [octet => sprintf ($f => $a [3])],
                                [octet => sprintf ($f => $a [4])],
                                [octet => sprintf ($f => $a [5])]]);

            $test -> no_match ($address_f1,
                               reason => "Incorrect separator");
            $test -> no_match ($address_f2,
                               reason => "Incorrect separator");
        }
    }

    my $sep  = ':{1,3}';
    my $test = Test::Regexp:: -> new -> init (
        pattern      => RE (Net => 'MAC', -base => $base, -sep => $sep,
                                          -Keep => 0),
        keep_pattern => RE (Net => 'MAC', -base => $base, -sep => $sep,
                                          -Keep => 1),
        name         => "Net MAC -base => '$base', -sep => /$sep/"
    );

    foreach my $a (@addresses) {
        my @a = map {hex} @$a;
        my $address_p1 = sprintf "$f%s$f%s$f%s$f%s$f%s$f" =>
                                  $a [0], '::', $a [1], ':',  $a [2], ':::',
                                  $a [3], ':',  $a [4], '::', $a [5];

        my $address_f1 = sprintf "$f%s$f%s$f%s$f%s$f%s$f" =>
                                  $a [0], '::', $a [1], ':',  $a [2], '::::',
                                  $a [3], ':',  $a [4], '::', $a [5];

        $test -> match ($address_p1,
                        captures => [
                            [MAC   => $address_p1],
                            [octet => sprintf ($f => $a [0])],
                            [octet => sprintf ($f => $a [1])],
                            [octet => sprintf ($f => $a [2])],
                            [octet => sprintf ($f => $a [3])],
                            [octet => sprintf ($f => $a [4])],
                            [octet => sprintf ($f => $a [5])]]);

        $test -> no_match ($address_f1,
                           reason => "Second separator too long");
    }
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
