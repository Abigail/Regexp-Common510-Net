#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2013041201;
use Test::Warn;
use Regexp::Common510 'Net';


our $r = eval "require Test::NoWarnings; 1";

#
# Check that the patterns fall back to defaults if incorrect values
# are given to -base and -sep
#

my $test;

RE Net => 'IPv4';

warnings_like {
    $test = Test::Regexp:: -> new -> init (
            pattern      =>  RE (Net => 'IPv4', -base => 9, -Keep => 0),
            keep_pattern =>  RE (Net => 'IPv4', -base => 9, -Keep => 1),
            full_text    =>  1,
            name         => "Net IPv4 -base => '9'",
    )
}  [(qr /Unknown -base '9', falling back to 'dec'/) x 2],
   "Falling back to base 'dec'";


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
