#!/usr/bin/perl

use 5.010;

use strict;

use Test::More 0.88;
use Test::Regexp 2013041201;
use Regexp::Common510 'Net';

use warnings;
no  warnings 'syntax';

eval "use Test::Warn; 1" or do {
    plan skip_all => "Test::Warn must be installed for these tests";
    exit;
};

our $r = eval "require Test::NoWarnings; 1";

#
# Check that the patterns fall back to defaults if incorrect values
# are given to -base.
#

my $test;

{
    use warnings 'Regexp::Common510';
    Test::Warn::warnings_like (sub {
        $test = Test::Regexp:: -> new -> init (
                pattern      =>  RE (Net => 'MAC', -base => 9, -Keep => 0),
                keep_pattern =>  RE (Net => 'MAC', -base => 9, -Keep => 1),
                full_text    =>  1,
                name         => "Net MAC -base => '9'",
        )
    } =>  [(qr /Unknown -base '9', falling back to 'HeX'/) x 2],
          "Falling back to base 'HeX'");
}

if ($r) {
    Test::NoWarnings::had_no_warnings ();  # Warn if there were warnings.
    Test::NoWarnings::clear_warnings  ();  # Clear any warnings so far.

    #
    # This should *not* warn.
    #
    no warnings 'Regexp::Common510';
    $test = Test::Regexp:: -> new -> init (
            pattern      =>  RE (Net => 'MAC', -base => 9, -Keep => 0),
            keep_pattern =>  RE (Net => 'MAC', -base => 9, -Keep => 1),
            full_text    =>  1,
            name         => "Net MAC -base => '9'",
    );

    Test::NoWarnings::had_no_warnings ();  # The call should not produce any.
}

#
# It should fall back to base HeX, let's check this.
#
$test -> match ("99:12:34:56:Ab:F9",
                 test     => "Fallback to base HeX",
                 captures => [[MAC   => "99:12:34:56:Ab:F9"],
                              [octet => "99"],
                              [octet => "12"],
                              [octet => "34"],
                              [octet => "56"],
                              [octet => "Ab"],
                              [octet => "F9"]],);
$test -> no_match ("99:12:34:56:171:249",
                   reason => "Fallback to base HeX");

#
# And nothing else should produce warnings.
#
Test::NoWarnings::had_no_warnings () if $r;

done_testing;
