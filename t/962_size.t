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
    my $in_table;
    while (<$fh>) {
        chomp;
        if (/^\s*\|\s+Pattern\s+\|\s+Size\s+\|/) {
            $in_table = 1;
            next;
        }
        next unless $in_table;
        unless (/^\s*\|/ || /^\s*\+-{5}/) {
            $in_table = 0;
            next;
        }
        if (/^\s* \| \s+ (?<re>RE [^;]+); \s+ \| \s+ (?<size>[0-9]+)/x) {
            my $RE      = $+ {re};
            my $size    = $+ {size} || 0;
            my $pat     = eval $RE;
            if ($@) {
                fail "'$RE' evaluates";
            }
            else {
                is $size, length $pat, "Length of $RE";
            }
        }
    }
    done_testing;
}


__END__
