#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2013041201;
use Regexp::Common510 'Net';

our $r = eval "require Test::NoWarnings; 1";

my $test_default    =   Test::Regexp:: -> new -> init (
    pattern         =>  RE (Net => 'domain'),
    keep_pattern    =>  RE (Net => 'domain', -Keep => 1),
    full_text       =>  1,
    name            => "Net domain",
);
my $test_1035       =   Test::Regexp:: -> new -> init (
    pattern         =>  RE (Net => 'domain', -rfc1035 => 1),
    keep_pattern    =>  RE (Net => 'domain', -rfc1035 => 1, -Keep => 1),
    full_text       =>  1,
    name            => "Net domain -rfc1035 => 1",
);
my $test_space      =   Test::Regexp:: -> new -> init (
    pattern         =>  RE (Net => 'domain', -allow_space => 1),
    keep_pattern    =>  RE (Net => 'domain', -allow_space => 1, -Keep => 1),
    full_text       =>  1,
    name            => "Net domain -allow_space => 1",
);
my $test_space_1035 =   Test::Regexp:: -> new -> init (
    pattern         =>  RE (Net => 'domain', -allow_space => 1, -rfc1035 => 1),
    keep_pattern    =>  RE (Net => 'domain', -allow_space => 1, -rfc1035 => 1,
                                             -Keep => 1),
    full_text       =>  1,
    name            => "Net domain -allow_space => 1",
);


my $space        =  ' ';
my $double_space =  '  ';
my @label_spaces = ("foo. .bar", " .bar", "foo. ");

foreach my $test ($test_space, $test_space_1035) {
    $test -> match ($space, 
                     captures => [[domain => $space]],
                     test     => "Single space should match");
    $test -> no_match ($double_space,
                        reason => "Only single spaces allowed");
    foreach my $domain (@label_spaces) {
        $test -> no_match ($domain,
                           reason => "Single space may only happen if there " .
                                     "is only one label");
    }
}

foreach my $test ($test_default, $test_1035) {
    foreach my $domain ($space, $double_space, @label_spaces) {
        $test -> no_match ($domain, 
                            reason => "Spaces are not allowed");
    }
}



Test::NoWarnings::had_no_warnings () if $r;

done_testing;
