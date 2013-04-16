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
# are given to -base and -sep
#

my $test;

{
    use warnings 'Regexp::Common510';
    Test::Warn::warnings_like (sub {
        $test = Test::Regexp:: -> new -> init (
                pattern      =>  RE (Net => 'IPv4', -base => 9, -Keep => 0),
                keep_pattern =>  RE (Net => 'IPv4', -base => 9, -Keep => 1),
                full_text    =>  1,
                name         => "Net IPv4 -base => '9'",
        )
    } =>  [(qr /Unknown -base '9', falling back to 'dec'/) x 2],
          "Falling back to base 'dec'");
}

if ($r) {
    Test::NoWarnings::had_no_warnings ();  # Warn if there were warnings.
    Test::NoWarnings::clear_warnings  ();  # Clear any warnings so far.

    #
    # This should *not* warn.
    #
    no warnings 'Regexp::Common510';
    $test = Test::Regexp:: -> new -> init (
            pattern      =>  RE (Net => 'IPv4', -base => 9, -Keep => 0),
            keep_pattern =>  RE (Net => 'IPv4', -base => 9, -Keep => 1),
            full_text    =>  1,
            name         => "Net IPv4 -base => '9'",
    );

    Test::NoWarnings::had_no_warnings ();  # The call should not produce any.
}

#
# It should fall back to base 10, let's check this.
#
$test -> match ("99.12.34.56",
                 test     => "Fallback to base 10",
                 captures => [[IPv4  => "99.12.34.56"],
                              [octet => "99"],
                              [octet => "12"],
                              [octet => "34"],
                              [octet => "56"]],);
$test -> no_match ("9a.12.34.56",
                   reason => "Fallback to base 10");

#
# And nothing else should produce warnings.
#
Test::NoWarnings::had_no_warnings () if $r;

done_testing;
