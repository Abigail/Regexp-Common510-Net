#!/usr/bin/perl

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;

sub process_file;

eval "use Test::Pod 1.00; 1" or
      plan skip_all => "Test::Pod required for testing POD";

use Regexp::Common510 'Net';

my @files = Test::Pod::all_pod_files ();


subtest $_ => sub {process_file $_} foreach @files;


done_testing;


sub process_file {
    my $file = shift;
    open my $fh, "<", $file or plan skip_all => "Failed to open file $file: $!";
    my $in_examples;
    my %minus;
    my %plus;
    while (<$fh>) {
        chomp;
        if (/^=head3 Examples/) {
            $in_examples = 1;
            next;
        }
        next unless $in_examples;
        if (/^=/) {
            $in_examples = 0;
            next;
        }
        if (/^\s+ "(?<subject>[^"]+)" \s+ (?<op>=~|!~) \s+
                   (?<re>RE [^;]+)/x) {
            my $subject = $+ {subject};
            my $op      = $+ {op};
            my $RE      = $+ {re};
            my $pat     = eval $RE;
            if ($@) {
                fail "'$RE' evaluates";
            }
            else {
                if ($op eq '=~') {
                    ok $subject =~ /^$pat$/, "'$subject' =~ $RE";

                    #
                    # Copy %- and %+
                    #
                    %minus = ();
                    while (my ($key, $value) = each %-) { 
                        $minus {$key} = [@$value];
                    }
                    %plus = ();
                    while (my ($key, $value) = each %+) { 
                        $plus {$key} = $value;
                    }
                }
                else {
                    ok $subject !~ /^$pat$/, "'$subject' !~ $RE";
                }
            }
        }
        if (/^\s+ say \s+ (?<plus_minus>\$[-+][^;]+); \s+ \#
                      \s+ (?<value>.*\S)/x) {
            my $plus_minus = $+ {plus_minus};
            my $value      = $+ {value};
               $value      = $1 if $value =~ /^'(.*)'\s*$/;
            my $ps_val     = $plus_minus;
            $ps_val        =~ s/^\$\+/\$plus/;
            $ps_val        =~ s/^\$-/\$minus/;
            $ps_val        = eval $ps_val;
            if ($@) {
                fail "Evaluating $plus_minus";
            }
            else {
                is $ps_val, $value, "$plus_minus eq '$value'";
            }
        }
    }
    done_testing;
}


__END__
