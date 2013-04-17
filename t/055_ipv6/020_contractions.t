#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2013041201;
use Regexp::Common510 'Net';

our $r = eval "require Test::NoWarnings; 1";

my $test_default    = Test::Regexp:: -> new -> init (
    pattern         => RE (Net => 'IPv6', -Keep => 0),
    keep_pattern    => RE (Net => 'IPv6', -Keep => 1),
    full_text       => 1,
    name            => "Net IPv6",
);
my $test_no_max_con = Test::Regexp:: -> new -> init (
    pattern         => RE (Net => 'IPv6', -Keep => 0, -max_contraction => 0),
    keep_pattern    => RE (Net => 'IPv6', -Keep => 1, -max_contraction => 0),
    full_text       => 1,
    name            => "Net IPv6 -max_contraction => 0",
);
my $test_single_con = Test::Regexp:: -> new -> init (
    pattern         => RE (Net => 'IPv6', -Keep => 0, -single_contraction => 1),
    keep_pattern    => RE (Net => 'IPv6', -Keep => 1, -single_contraction => 1),
    full_text       => 1,
    name            => "Net IPv6 -single_contraction => 1",
);
my $test_leading_zeros = Test::Regexp:: -> new -> init (
    pattern         => RE (Net => 'IPv6', -Keep => 0, -leading_zeros => 1),
    keep_pattern    => RE (Net => 'IPv6', -Keep => 1, -leading_zeros => 1),
    full_text       => 1,
    name            => "Net IPv6 -leading_zeros => 1",
);


my @chunks = qw [2001 1d0 ffff 1 aa 98ba abcd e9f];
my @lz     = qw [0fff 0ed 0b 00a9 008 0007];
my @mz     = qw [00 000 0000];

#
# '::' is one of the addresses constructed...
#
for (my $i = 0; $i <= 7; $i ++) {
    state $c_lz = 0;
    state $c_mz = 0;
    state $c_nz = 0;
    my @left    = @chunks [0 .. $i - 1];
    my $left    =  join ":" => @left;
    my @left_z  = @left; $left_z  [-1] = 0 if @left_z;
    my $left_z  =  join ":" => @left_z;
    my @left_lz = @left; $left_lz [-1] = $lz [$c_lz ++ % @lz] if @left_lz;
    my $left_lz =  join ":" => @left_lz;
    my @left_mz = @left; $left_mz [-1] = $mz [$c_mz ++ % @mz] if @left_mz;
    my $left_mz =  join ":" => @left_mz;
    my @left_nz = @left; $left_nz [$c_nz ++ % (@left_nz - 1)] = 0
                                                              if @left_nz > 1;
    my $left_nz =  join ":" => @left_nz;
    my $l       = @left;
    for (my $j = $i + 1; $j <= 8; $j ++) {
        #
        # _z   Zero
        # _lz  Leading zero(s)
        # _mz  Multiple zeros
        # _nz  Non-flanking zero
        # _zl  Zero on left
        # _zr  Zero on right
        # _lzl Leading zero(s) on left
        # _lzr Leading zero(s) on right
        # _mzl Multiple zeros on left
        # _mzr Multiple zeros on right
        #
        my @right        = @chunks [$j .. 7];
        my $right        =  join ":" => @right;
        my @right_z      = @right; $right_z  [0] = 0 if @right_z;
        my $right_z      =  join ":" => @right_z;
        my @right_lz     = @right; $right_lz [0] = $lz [$c_lz ++ % @lz]
                                                     if @right_lz;
        my $right_lz     =  join ":" => @right_lz;
        my @right_mz     = @right; $right_mz [0] = $mz [$c_mz ++ % @mz]
                                                     if @right_mz;
        my $right_mz     =  join ":" => @right_mz;
        my @right_nz     = @right;
                           $right_nz [1 + $c_nz ++ % (@right_nz - 1)] = 0
                                                     if @right_nz > 1;
        my $right_nz     =  join ":" => @right_nz;

        my $address      = "${left}::${right}";
        my $address_zl   = "${left_z}::${right}";
        my $address_zr   = "${left}::${right_z}";
        my $address_lzl  = "${left_lz}::${right}";
        my $address_lzr  = "${left}::${right_lz}";
        my $address_mzl  = "${left_mz}::${right}";
        my $address_mzr  = "${left}::${right_mz}";
        my $address_nzl  = "${left_nz}::${right}";
        my $address_nzr  = "${left}::${right_nz}";
        my $r            = @right;

        my $m            = 8 - $l - $r;

        my @captures     = ([IPv6 => $address],
                             map {[unit => $_]} @left,   ("") x $m, @right);
        my @captures_zl  = ([IPv6 => $address_zl],
                             map {[unit => $_]} @left_z, ("") x $m, @right);
        my @captures_zr  = ([IPv6 => $address_zr],
                             map {[unit => $_]} @left,   ("") x $m, @right_z);
        my @captures_lzl = ([IPv6 => $address_lzl],
                            map {[unit => $_]} @left_lz, ("") x $m, @right);
        my @captures_lzr = ([IPv6 => $address_lzr],
                             map {[unit => $_]} @left,   ("") x $m, @right_lz);
        my @captures_nzl = ([IPv6 => $address_nzl],
                            map {[unit => $_]} @left_nz, ("") x $m, @right);
        my @captures_nzr = ([IPv6 => $address_nzr],
                             map {[unit => $_]} @left,   ("") x $m, @right_nz);

        if ($m == 1) {
            foreach my $test ($test_default, $test_no_max_con,
                              $test_leading_zeros) {
                $test -> no_match (
                    $address,
                    reason   => "Contraction of 1 unit"
                )
            }
            foreach my $test ($test_single_con) {
                $test -> match (
                    $address,
                    test     => "Contraction of 1 unit",
                    captures => \@captures,
                )
            }
        }
        else {
            foreach my $test ($test_default, $test_no_max_con,
                              $test_single_con, $test_leading_zeros) {
                $test -> match (
                    $address,
                    test     => "Contraction ${l}::${r}",
                    captures => \@captures,
                );
            }

            if ($l) {
                foreach my $test ($test_default, $test_single_con,
                                  $test_leading_zeros) {
                    $test -> no_match (
                        $address_zl,
                         reason => "0 unit before contraction",
                    );
                }
                foreach my $test ($test_no_max_con) {
                    $test -> match (
                        $address_zl,
                        test     => "0 unit before contraction",
                        captures => \@captures_zl,
                    );
                }
                foreach my $test ($test_leading_zeros) {
                    $test -> match (
                        $address_lzl,
                        test     => "Leading zero before contraction",
                        captures => \@captures_lzl
                    );
                    $test -> no_match (
                        $address_mzl,
                        reason   => "Multiple zeros before contraction",
                    );
                }
            }
            
            if ($l > 1) {
                foreach my $test ($test_default, $test_no_max_con,
                                  $test_leading_zeros, $test_single_con) {
                    $test -> match (
                        $address_nzl,
                        test     => "Non-flanking zero left of contraction",
                        captures => \@captures_nzl,
                    )
                }
            }

            if ($r) {
                foreach my $test ($test_default, $test_single_con,
                                  $test_leading_zeros) {
                    $test -> no_match (
                        $address_zr,
                         reason => "0 unit after contraction",
                    );
                }
                foreach my $test ($test_no_max_con) {
                    $test -> match (
                        $address_zr,
                        test     => "0 unit after contraction",
                        captures => \@captures_zr,
                    );
                }
                foreach my $test ($test_leading_zeros) {
                    $test -> match (
                        $address_lzr,
                        test     => "Leading zero after contraction",
                        captures => \@captures_lzr
                    );
                    $test -> no_match (
                        $address_mzr,
                        reason   => "Multiple zeros after contraction",
                    );
                }
            }

            if ($r > 1) {
                foreach my $test ($test_default, $test_no_max_con,
                                  $test_leading_zeros, $test_single_con) {
                    $test -> match (
                        $address_nzr,
                        test     => "Non-flanking zero right of contraction",
                        captures => \@captures_nzr,
                    )
                }
            }
        }
    }
}

#
# Tests that something really is contracted
#
for (my $i = 1; $i < 8; $i ++) {
    my @copy = @chunks;
    splice @copy, $i, 0, "";
    my $address = join ":" => @copy;
    foreach my $test ($test_default, $test_no_max_con, 
                      $test_single_con, $test_leading_zeros) {
        $test -> no_match (
            $address,
            reason => "Contracting 0 units"
        )
    }
}
{
    my $address = join ":" => @chunks;
    foreach my $test ($test_default, $test_no_max_con, 
                      $test_single_con, $test_leading_zeros) {
        foreach my $address ("::$address", "${address}::") {
            $test -> no_match (
                $address,
                reason => "Contracting 0 units"
            )
        }
    }
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
