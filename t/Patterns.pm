package t::Patterns;

use strict;

use Regexp::Common510 'Net';
use Exporter ();
use Test::Regexp 2013041801;

use warnings;
no  warnings 'syntax';

our @ISA    = qw [Exporter];
our @EXPORT = qw [$IPv6_default $IPv6_HEX $IPv6_HeX
                  $IPv6_lz $IPv6_lz_HEX $IPv6_lz_HeX
                  $IPv6_no_max_com $IPv6_single_com
                  $IPv6_ipv4 $IPv6_rfc2373 @IPv6];


our $IPv6_default       =   Test::Regexp:: -> new -> init (
     pattern            =>  RE (Net => 'IPv6', -Keep => 0),
     keep_pattern       =>  RE (Net => 'IPv6', -Keep => 1),
     full_text          =>  1,
     name               => "Net IPv6",
     tags               => {-base => 'hex', -max_compression => 1},
);

our $IPv6_HEX           =   Test::Regexp:: -> new -> init (
     pattern            =>  RE (Net => 'IPv6', -Keep => 0, -base => 'HEX'),
     keep_pattern       =>  RE (Net => 'IPv6', -Keep => 1, -base => 'HEX'),
     full_text          =>  1,
     name               => "Net IPv6 -base => 'HEX'",
     tags               => {-base => 'HEX', -max_compression => 1},
);

our $IPv6_HeX           =   Test::Regexp:: -> new -> init (
     pattern            =>  RE (Net => 'IPv6', -Keep => 0, -base => 'HeX'),
     keep_pattern       =>  RE (Net => 'IPv6', -Keep => 1, -base => 'HeX'),
     full_text          =>  1,
     name               => "Net IPv6 -base => 'HeX'",
     tags               => {-base => 'HeX', -max_compression => 1},
);

our $IPv6_lz            =   Test::Regexp:: -> new -> init (
     pattern            =>  RE (Net => 'IPv6', -Keep          => 0,
                                               -leading_zeros => 1),
     keep_pattern       =>  RE (Net => 'IPv6', -Keep          => 1,
                                               -leading_zeros => 1),
     full_text          =>  1,
     name               => "Net IPv6 -leading_zeros => 1",
     tags               => {-leading_zeros   => 1, -base => 'hex',
                            -max_compression => 1},
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
     tags               => {-leading_zeros   => 1, -base => 'HEX',
                            -max_compression => 1},
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
     tags               => {-leading_zeros   => 1, -base => 'HeX',
                            -max_compression => 1},
);  

our $IPv6_no_max_com    =   Test::Regexp:: -> new -> init (
     pattern            =>  RE (Net => 'IPv6', -Keep => 0,
                                               -max_compression => 0),  
     keep_pattern       =>  RE (Net => 'IPv6', -Keep => 1,
                                               -max_compression => 0),
     full_text          =>  1,
     name               => "Net IPv6 -max_compression => 0",
     tags               => {-max_compression => 0, -base => 'hex'},
);

our $IPv6_single_com    =   Test::Regexp:: -> new -> init (
     pattern            =>  RE (Net => 'IPv6', -Keep => 0,
                                               -single_compression => 1),
     keep_pattern       =>  RE (Net => 'IPv6', -Keep => 1,
                                               -single_compression => 1),
     full_text          =>  1,
     name               => "Net IPv6 -single_compression => 1",
     tags               => {-max_compression    => 1, -base => 'hex',
                            -single_compression => 1},
);   

our $IPv6_leading_zeros =   Test::Regexp:: -> new -> init (
     pattern            =>  RE (Net => 'IPv6', -Keep => 0, -leading_zeros => 1),
     keep_pattern       =>  RE (Net => 'IPv6', -Keep => 1, -leading_zeros => 1),
     full_text          =>  1,
     name               => "Net IPv6 -leading_zeros => 1",
     tags               => {-max_compression => 1, -base => 'hex',
                            -leading_zeros   => 1},
);

our $IPv6_ipv4          =   Test::Regexp:: -> new -> init (
     pattern            =>  RE (Net => 'IPv6', -Keep => 0, -trailing_ipv4 => 1),
     keep_pattern       =>  RE (Net => 'IPv6', -Keep => 1, -trailing_ipv4 => 1),
     full_text          =>  1,
     name               => "Net IPv6 -trailing_ipv4 => 1",
     tags               => {-max_compression => 1, -ipv4            => 1},
);

our $IPv6_rfc2373       =   Test::Regexp:: -> new -> init (
     pattern            =>  RE (Net => 'IPv6', -Keep => 0, -rfc2373 => 1),
     keep_pattern       =>  RE (Net => 'IPv6', -Keep => 1, -rfc2373 => 1),
     full_text          =>  1,
     name               => "Net IPv6 -rfc2373 => 1",
     tags               => {-max_compression => 0, -base => 'HeX',
                            -leading_zeros   => 1, -single_compression => 1,
                            -ipv4            => 1},
);

our @IPv6 = ($IPv6_default, $IPv6_HEX, $IPv6_HeX, $IPv6_lz, $IPv6_lz_HEX,
             $IPv6_lz_HeX, $IPv6_no_max_com, $IPv6_single_com, $IPv6_ipv4,
             $IPv6_rfc2373);
