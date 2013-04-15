#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Test::Regexp 2013041501;
use Regexp::Common510 'Net';

our $r = eval "require Test::NoWarnings; 1";

#
# Testing that names that look like they are IP addresses are not matched.
#
# There's no need to test the patterns with "-rfc1035 => 1", as they fail
# on labels starting with digits anyway.
#

my $test_default    =   Test::Regexp:: -> new -> init (
    pattern         =>  RE (Net => 'domain'),
    keep_pattern    =>  RE (Net => 'domain', -Keep => 1),
    full_text       =>  1,
    name            => "Net domain",
);
my $test_space      =   Test::Regexp:: -> new -> init (
    pattern         =>  RE (Net => 'domain', -allow_space => 1),
    keep_pattern    =>  RE (Net => 'domain', -allow_space => 1, -Keep => 1),
    full_text       =>  1,
    name            => "Net domain -allow_space => 1",
);

my @tests   = ($test_default, $test_space);

my @ok_ips  = qw [0.0.0.0 127.0.0.1 192.168.10.255 255.255.255.255];
my @not_ips = qw [0.0.0 127.O.O.1 192.168.10.256];

foreach my $test (@tests) {
    foreach my $ip (@ok_ips) {
        $test -> no_match ( $ip,
                            reason => "IP address should not match");
        $test -> no_match ("$ip.tld",
                            reason => "Name starts with IP address");
        $test -> no_match ("host.$ip.tld",
                            reason => "Internal IP address");
    }
    foreach my $ip (@not_ips) {
        $test -> match ($ip,
                         test => "Not quite an IP address",
                         captures => [[domain => $ip]]);
        $test -> match ("$ip.tld",
                         test => "Not quite an IP address",
                         captures => [[domain => "$ip.tld"]]);
        $test -> match ("host.$ip.tld",
                         test => "Not quite an IP address",
                         captures => [[domain => "host.$ip.tld"]]);
    }
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
