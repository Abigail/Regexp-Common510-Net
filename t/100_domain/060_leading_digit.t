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

my @tests = ($test_default, $test_1035, $test_space, $test_space_1035);

#
# Make it so that the GCD of the sizes of each pair of sets is 1.
#
my @tlds      = qw [com net nl biz xxx A];
my @d_hosts   = qw [123host 7a 7890 0];
my @hosts     = qw [host X www123];
my @d_domains = qw [1domain 000example 007];
my @domains   = qw [domain domain EXAMPLE PeRl mine123];


#
# Create names with either a host or a domain starting with a digit.
# Both a digit are fine as well.
#
foreach my $tld (@tlds) {
    foreach my $d_host (@d_hosts) {
        #
        # 2 level, hosts start with digit
        #
        my $address = "$d_host.$tld";
        foreach my $test ($test_default, $test_space) {
            $test -> match ($address,
                            test     => "Host starts with digit",
                            captures => [[domain => $address]]);
        }
        foreach my $test ($test_1035, $test_space_1035) {
            $test -> no_match ($address,
                               reason => "Host starts with digit");
        }
        foreach my $domain (@domains, @d_domains) {
            #
            # 3 level, hosts start with digit
            #
            my $address = "$d_host.$domain.$tld";
            foreach my $test ($test_default, $test_space) {
                $test -> match ($address,
                                test     => "Host starts with digit",
                                captures => [[domain => $address]]);
            }
            foreach my $test ($test_1035, $test_space_1035) {
                $test -> no_match ($address,
                                   reason => "Host starts with digit");
            }
        }
    }
    foreach my $host (@hosts) {
        foreach my $domain (@d_domains) {
            #
            # 3 level, domain starts with digit
            #
            my $address = "$host.$domain.$tld";
            foreach my $test ($test_default, $test_space) {
                $test -> match ($address,
                                test     => "Domain starts with digit",
                                captures => [[domain => $address]]);
            }
            foreach my $test ($test_1035, $test_space_1035) {
                $test -> no_match ($address,
                                   reason => "Domain starts with digit");
            }
        }
        foreach my $d_domain (@d_domains) {
            foreach my $domain (@domains) {
                #
                # 4 level, one of domains starts with digit
                #
                my $address1 = "$host.$d_domain.$domain.$tld";
                my $address2 = "$host.$domain.$d_domain.$tld";
                foreach my $test ($test_default, $test_space) {
                    foreach my $address ($address1, $address2) {
                        $test -> match ($address,
                                        test     => "Domain starts with digit",
                                        captures => [[domain => $address]]);
                    }
                }
                foreach my $test ($test_1035, $test_space_1035) {
                    foreach my $address ($address1, $address2) {
                        $test -> no_match ($address,
                                           reason => "Domain starts with digit")
                    }
                }
            }
        }
    }
}




Test::NoWarnings::had_no_warnings () if $r;

done_testing;
