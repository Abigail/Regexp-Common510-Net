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
# Check octets using the incorrect base
#

my @tests = (
    [bin => 'oct', 11001100,      350, 10101111, 1011010],
    [bin => 'dec', 11001100, 11101000,      175, 1011010],
    [bin => 'hex', 11001100, 11101000, 10101111,     '5a'],

    [oct => 'bin', 11001100,      350,      257,     132],
    [oct => 'dec',      314,      350,      178,     132],
    [oct => 'hex',      314,      350,      257,     '5a'],

    [dec => 'bin', 11001100,      232,      175,      90],
    [dec => 'oct',      204,      350,      175,      90],
    [dec => 'hex',      204,      232,      175,     '5a'],

    [dec => 'bin', 11001100,      'e8',     'af',    '5a'],
    [dec => 'oct',      'cc',     350,      'af',    '5a'],
    [dec => 'dec',      'cc',     'e8',     175,     '5a'],
);

my %format =  (
    bin      => '%b',
    oct      => '%o',
    dec      => '%d',
    hex      => '%x',
);

my %tester;
foreach my $base (qw [bin oct dec hex]) {

    $tester {$base} = Test::Regexp:: -> new -> init (
        pattern      => RE (Net => 'IPv4', -base => $base, -Keep => 0),
        keep_pattern => RE (Net => 'IPv4', -base => $base, -Keep => 1),
        name         => "Net IPv4 -base => '$base'",
    );
}

        
foreach my $test (@tests) {
    my ($base, $wrong_base, @octets) = @$test;
    my $address = join '.' => @octets;

    $tester {$base} -> no_match ($address, reason => "Octet in $wrong_base");
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
