#!/usr/bin/perl

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;

eval "use Test::Pod 1.00; 1" or
      plan skip_all => "Test::Pod required for testing POD";

all_pod_files_ok ();


__END__
