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

my @tests = ($test_default, $test_space, $test_1035, $test_space_1035);

#
# Make it so that the GCD of the sizes of each pair of sets is 1.
#
my @pass_tlds    = qw [tld t-l-d t--d];
my @fail_tlds    = qw [-tld tld- ---];
my @pass_hosts   = qw [host ho-st h---t h-o-s-t];
my @fail_hosts   = qw [-host --host host-- host- -];
my @pass_domains = qw [domain do---main d-o-m-a-i-n];
my @fail_domains = qw [-domain domain- --];

foreach my $host (@pass_hosts) {
    foreach my $test (@tests) {
        #
        # 1 level, correct host
        #
        $test -> match ($host,
                        test     => "Correct use of hyphens",
                        captures => [[domain => $host]]);
    }

    foreach my $tld (@pass_tlds) {
        #
        # 2 level, correct host & tld
        #
        my $address = "$host.$tld";
        foreach my $test (@tests) {
            $test -> match ($address,
                            test     => "Correct use of hyphens",
                            captures => [[domain => $address]]);
        }
    }

    foreach my $tld (@fail_tlds) {
        #
        # 2 level, correct host; incorrect tld
        #
        my $address = "$host.$tld";
        foreach my $test (@tests) {
            $test -> no_match ($address,
                               reasonn  => "Incorrect use of hyphens in tld");
        }
    }
}

foreach my $host (@fail_hosts) {
    foreach my $test (@tests) {
        #
        # 1 level, incorrect host
        #
        $test -> no_match ($host,
                           reason   => "Incorrect use of hyphens in host");
    }
    foreach my $tld (@pass_tlds, @fail_tlds) {
        #
        # 2 level, incorrect host
        #
        my $address = "$host.tld";
        foreach my $test (@tests) {
            $test -> no_match ($address,
                               reason   => "Incorrect use of hyphens in host",
                               captures => [[domain => $address]]);
        }
    }
}


foreach my $host (@pass_hosts) {
    foreach my $tld (@pass_tlds) {
        foreach my $domain (@pass_domains) {
            #
            # 3 level, all correct
            #
            my $address = "$host.$domain.$tld";
            foreach my $test (@tests) {
                $test -> match ($address,
                                test     => "Correct use of hypens; 3 level",
                                captures => [[domain => $address]]);
            }
        }
        foreach my $domain (@fail_domains) {
            #
            # 3 level, domain fail
            #
            my $address = "$host.$domain.$tld";
            foreach my $test (@tests) {
                $test -> no_match ($address,
                                   reason   => "Incorrect use of hypens in " .
                                               "domain");
            }
        }
    }
}


foreach my $host (@pass_hosts) {
    foreach my $tld (@pass_tlds) {
        foreach my $p_domain (@pass_domains) {
            foreach my $f_domain (@fail_domains) {
                #
                # 4 level, one domain incorrect
                #
                my $address1 = "$host.$p_domain.$f_domain.$tld";
                my $address2 = "$host.$f_domain.$p_domain.$tld";
                foreach my $test (@tests) {
                    $test -> no_match ($address1,
                                       reason => "Incorrect use of hyphens " .
                                                 "in domain");
                    $test -> no_match ($address2,
                                       reason => "Incorrect use of hyphens " .
                                                 "in domain");
                }
            }
        }
    }
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
