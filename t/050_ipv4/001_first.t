#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;
use Regexp::Common510 'Net';

our $r = eval "require Test::NoWarnings; 1";

ok "127.0.0.1" =~ RE (Net => 'IPv4'), "IPv4 pattern";

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
