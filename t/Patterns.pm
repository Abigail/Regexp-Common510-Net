package t::Patterns;

use strict;

use Regexp::Common510 'Net';
use Exporter ();

use warnings;
no  warnings 'syntax';

our @ISA    = qw [Exporter];
our @EXPORT = qw [$IPv6_default $IPv6_HEX $IPv6_HeX
                  $IPv6_lz $IPv6_lz_HEX $IPv6_lz_HeX
                  $IPv6_no_max_con $IPv6_single_con
                  $IPv6_rfc2373 @IPv6];


our $IPv6_default       =   Test::Regexp:: -> new -> init (
     pattern            =>  RE (Net => 'IPv6', -Keep => 0),
     keep_pattern       =>  RE (Net => 'IPv6', -Keep => 1),
     full_text          =>  1,
     name               => "Net IPv6",
);

our $IPv6_HEX           =   Test::Regexp:: -> new -> init (
     pattern            =>  RE (Net => 'IPv6', -Keep => 0, -base => 'HEX'),
     keep_pattern       =>  RE (Net => 'IPv6', -Keep => 1, -base => 'HEX'),
     full_text          =>  1,
     name               => "Net IPv6 -base => 'HEX'",
);
our $IPv6_HeX           =   Test::Regexp:: -> new -> init (
     pattern            =>  RE (Net => 'IPv6', -Keep => 0, -base => 'HeX'),
     keep_pattern       =>  RE (Net => 'IPv6', -Keep => 1, -base => 'HeX'),
     full_text          =>  1,
     name               => "Net IPv6 -base => 'HeX'",
);
our $IPv6_lz            =   Test::Regexp:: -> new -> init (
     pattern            =>  RE (Net => 'IPv6', -Keep          => 0,
                                               -leading_zeros => 1),
     keep_pattern       =>  RE (Net => 'IPv6', -Keep          => 1,
                                               -leading_zeros => 1),
     full_text          =>  1,
     name               => "Net IPv6 -leading_zeros => 1",
);
our $IPv6_lz_HEX        =   Test::Regexp:: -> new -> init (
     pattern            =>  RE (Net => 'IPv6', -Keep          =>  0,
                                               -leading_zeros =>  1,
                                               -base          => 'HEX'),
     keep_pattern       =>  RE (Net => 'IPv6', -Keep          =>  1,
                                               -leading_zeros =>  1,
                                               -base          => 'HEX'),
     full_text          =>  1,
     name               => "Net IPv6 -leading_zeros => 1, -base => 'HEX'",
);
our $IPv6_lz_HeX        =   Test::Regexp:: -> new -> init (
     pattern            =>  RE (Net => 'IPv6', -Keep          =>  0,
                                               -leading_zeros =>  1,
                                               -base          => 'HeX'),
     keep_pattern       =>  RE (Net => 'IPv6', -Keep          =>  1,
                                               -leading_zeros =>  1,
                                               -base          => 'HeX'),
     full_text          =>  1,
     name               => "Net IPv6 -leading_zeros => 1, -base => 'HeX'",
);  

our $IPv6_no_max_con    =   Test::Regexp:: -> new -> init (
     pattern            =>  RE (Net => 'IPv6', -Keep => 0,
                                               -max_contraction => 0),  
     keep_pattern       =>  RE (Net => 'IPv6', -Keep => 1,
                                               -max_contraction => 0),
     full_text          =>  1,
     name               => "Net IPv6 -max_contraction => 0",
);
our $IPv6_single_con    =   Test::Regexp:: -> new -> init (
     pattern            =>  RE (Net => 'IPv6', -Keep => 0,
                                               -single_contraction => 1),
     keep_pattern       =>  RE (Net => 'IPv6', -Keep => 1,
                                               -single_contraction => 1),
     full_text          =>  1,
     name               => "Net IPv6 -single_contraction => 1",
);   
our $IPv6_leading_zeros =   Test::Regexp:: -> new -> init (
     pattern            =>  RE (Net => 'IPv6', -Keep => 0, -leading_zeros => 1),
     keep_pattern       =>  RE (Net => 'IPv6', -Keep => 1, -leading_zeros => 1),
     full_text          =>  1,
     name               => "Net IPv6 -leading_zeros => 1",
);
our $IPv6_rfc2373       =   Test::Regexp:: -> new -> init (
     pattern            =>  RE (Net => 'IPv6', -Keep => 0, -rfc2373 => 1),
     keep_pattern       =>  RE (Net => 'IPv6', -Keep => 1, -rfc2373 => 1),
     full_text          =>  1,
     name               => "Net IPv6 -rfc2373 => 1",
);

our @IPv6 = ($IPv6_default, $IPv6_HEX, $IPv6_HeX, $IPv6_lz, $IPv6_lz_HEX,
             $IPv6_lz_HeX, $IPv6_no_max_con, $IPv6_single_con, $IPv6_rfc2373);
