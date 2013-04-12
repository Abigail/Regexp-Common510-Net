#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Regexp::Common510 'Net';

our $r = eval "require Test::NoWarnings; 1";

ok "host.example.com" =~ RE (Net => 'domain'), "Domain pattern";

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
