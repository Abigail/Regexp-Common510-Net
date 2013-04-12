#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2013041201;
use Regexp::Common510 'Net';

our $r = eval "require Test::NoWarnings; 1";

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

foreach my $base (qw [bin oct dec hex]) {

    my $format = $format {$base};

    foreach my $sep (':', ' ', "\x{1362}") {
        my $test = Test::Regexp:: -> new -> init (
            pattern      =>  RE (Net => 'IPv4', -base => $base, -sep => $sep,
                                                -Keep => 0),
            keep_pattern =>  RE (Net => 'IPv4', -base => $base, -sep => $sep,
                                                -Keep => 1),
            full_text    =>  1,
            name         => "Net IPv4 -base => '$base', -sep => /$sep/"
        );
        
        foreach my $a (@addresses) {
            my $address_p1 = sprintf "$format%s$format%s$format%s$format" =>
                                      $$a [0], $sep, $$a [1], $sep,
                                      $$a [2], $sep, $$a [3];
            my $address_f1 = sprintf "$format%s$format%s$format%s$format" =>
                                      $$a [0], $sep, $$a [1], $sep,
                                      $$a [2], '.',  $$a [3];
            my $address_f2 = sprintf "$format%s$format%s$format%s$format" =>
                                      $$a [0], '.',  $$a [1], '.',
                                      $$a [2], '.',  $$a [3];
            $test -> match ($address_p1,
                            captures => [
                                [IPv4  => $address_p1],
                                [octet => sprintf ($format => $$a [0])],
                                [octet => sprintf ($format => $$a [1])],
                                [octet => sprintf ($format => $$a [2])],
                                [octet => sprintf ($format => $$a [3])]]);

            $test -> no_match ($address_f1,
                               reason => "Incorrect separator");
            $test -> no_match ($address_f2,
                               reason => "Incorrect separator");
        }
    }

    my $sep  = ':{1,3}';
    my $test = Test::Regexp:: -> new -> init (
        pattern      =>  RE (Net => 'IPv4', -base => $base, -sep => $sep,
                                            -Keep => 0),
        keep_pattern =>  RE (Net => 'IPv4', -base => $base, -sep => $sep,
                                            -Keep => 1),
        full_text    =>  1,
        name         => "Net IPv4 -base => '$base', -sep => /$sep/"
    );

    foreach my $a (@addresses) {
        my $address_p1 = sprintf "$format%s$format%s$format%s$format" =>
                                  $$a [0], '::',  $$a [1], ':',
                                  $$a [2], ':::', $$a [3];

        my $address_f1 = sprintf "$format%s$format%s$format%s$format" =>
                                  $$a [0], '::',  $$a [1], '::::',
                                  $$a [2], ':::', $$a [3];
        my $address_f2 = sprintf "$format%s$format%s$format%s$format" =>
                                  $$a [0], '.',   $$a [1], '.',
                                  $$a [2], '.',   $$a [3];

        $test -> match ($address_p1,
                        captures => [
                            [IPv4  => $address_p1],
                            [octet => sprintf ($format => $$a [0])],
                            [octet => sprintf ($format => $$a [1])],
                            [octet => sprintf ($format => $$a [2])],
                            [octet => sprintf ($format => $$a [3])]]);

        $test -> no_match ($address_f1,
                           reason => "Second separator too long");
        $test -> no_match ($address_f2,
                           reason => "Incorrect separator");
    }
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
