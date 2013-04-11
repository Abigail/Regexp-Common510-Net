#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Regexp::Common510 'Net';

our $r = eval "require Test::NoWarnings; 1";

ok "01:23:45:67:89:AB" =~ RE (Net => 'MAC'), "MAC pattern";

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
