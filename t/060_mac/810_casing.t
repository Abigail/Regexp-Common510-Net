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
# Check casing of hex/HEX
#

my $test_hex = Test::Regexp:: -> new -> init (
      pattern      =>  RE (Net => 'MAC', -base => 'hex', -Keep => 0),
      keep_pattern =>  RE (Net => 'MAC', -base => 'hex', -Keep => 1),
      full_text    =>  1,
      name         => "Net MAC -base => hex"
);

my $test_HEX = Test::Regexp:: -> new -> init (
      pattern      =>  RE (Net => 'MAC', -base => 'HEX', -Keep => 0),
      keep_pattern =>  RE (Net => 'MAC', -base => 'HEX', -Keep => 1),
      full_text    =>  1,
      name         => "Net MAC -base => HEX"
);



foreach my $Number (0 .. 41) {
    my $Number1 = sprintf "%x" =>       $Number;
    my $Number2 = sprintf "%x" =>  83 - $Number;
    my $Number3 = sprintf "%x" =>  84 + $Number;
    my $Number4 = sprintf "%x" => 167 - $Number;
    my $Number5 = sprintf "%x" => 168 + $Number;
    my $Number6 = sprintf "%x" => 251 - $Number;

    next if "$Number1$Number2$Number3$Number4$Number5$Number6" =~ /^[0-9]+$/;

    my $address_hex = "$Number1:$Number2:$Number3:$Number4:$Number5:$Number6";
    my $address_HEX = uc $address_hex;

    $test_hex -> no_match ($address_HEX,
                           reason => "Wrongly cased hex digits");
    $test_HEX -> no_match ($address_hex,
                           reason => "Wrongly cased hex digits");
      
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
