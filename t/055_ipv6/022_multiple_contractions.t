#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2013041801;
use t::Patterns;

our $r = eval "require Test::NoWarnings; 1";


my @chunks = qw [2001 1d0 ffff 1 aa 98ba abcd e9f];

#
# No multiple contractions
#
my %seen;
for (my $i = 0; $i <= 6; $i ++) {
    my $i_chunks = join ":" => @chunks [0 .. $i - 1];
    for (my $m1 = 1; $i + $m1 <= 7; $m1 ++) {
        for (my $j = 0; $i + $m1 + $j <= 7; $j ++) {
            my $j_chunks = join ":" => @chunks [$i + $m1 .. $i + $m1 + $j - 1];
            for (my $m2 = 1; $i + $m1 + $j + $m2 <= 8; $m2 ++) {
                for (my $k = 0; $i + $m1 + $j + $m2 + $k <= 6; $k ++) {
                    my $k_chunks = join ":" =>
                                        @chunks [$i + $m1 + $j + $m2 ..
                                                 $i + $m1 + $j + $m2 + $k - 1];
                    my $address = "${i_chunks}::${j_chunks}::${k_chunks}";
                    next if $seen {$address} ++;
                    foreach my $test ($IPv6_default, $IPv6_no_max_con, 
                                      $IPv6_single_con, $IPv6_lz,
                                      $IPv6_ipv4, $IPv6_rfc2373) {
                        $test -> no_match (
                            $address,
                            reason => "Multiple contractions"
                        )
                    }
                }
            }
        }
    }
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
