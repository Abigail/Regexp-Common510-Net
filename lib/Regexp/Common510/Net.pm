package Regexp::Common510::Net;

use 5.010;
use strict;
use warnings;
no  warnings 'syntax';

our $VERSION = '2013041001';

use Regexp::Common510;

use warnings::register;

my %IP4map  = (
    16      => 'HeX',
    10      => 'dec',
     8      => 'oct',
     2      => 'bin',
);

my %IP4unit = (
    dec => q {25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2}},
    oct => q {[0-3]?[0-7]{1,2}},
    hex => q {[0-9a-f]{1,2}},
    HeX => q {[0-9a-fA-F]{1,2}},
    HEX => q {[0-9A-F]{1,2}},
    bin => q {[0-1]{1,8}},
);


pattern  Net       => 'IPv4',
         -config   => {
            -sep   =>  '\.',
            -base  =>  'dec',
         },
         -pattern  => \&IPv4,
;



sub IPv4 {
    my %args = @_;

    my $base = $args {-base};
       $base = $IP4map {$base} if $IP4map {$base};

    warnings::warn ("Unknown -base '$base', falling back to default 'dec'\n")
       if (!$base || !$IP4unit {$base}) && warnings::enabled;

    my $octet = $IP4unit {$base};

    my $sep = $args {-sep};
    eval {qr /$sep/} or do {
        $sep = '\.';
        warnings::warn ("Cannot compile pattern '$sep' for the separator -- " .
                        "failling back to default /\\./\n")
               if warnings::enabled;
    };

    return '(?k<IPv4>:'                 .
           "(?k<octet>:$octet)(?:$sep)" .
           "(?k<octet>:$octet)(?:$sep)" .
           "(?k<octet>:$octet)(?:$sep)" .
           "(?k<octet>:$octet))";
}


1;

__END__

=head1 NAME

Regexp::Common510::Net - Abstract

=head1 SYNOPSIS

 use Regexp::Common510 'Net';

 my $pat = RE Net => 'IPv4';

 "127.0.0.1" =~ /$pat/ and say "IP address found";

=head1 DESCRIPTION

This module deliver pattern related to network entities. It should not be
used directly, but loaded using C<< Regexp::Common510 >>. See that module
for a general description of the interface.

This module provides the following patterns:

=head2 C<< IPv4 >>

The C<< IPv4 >> pattern matches IP version 4 addresses. By default, it
matches against addresses written in decimals, and separated by dots.
But this can be configured. The following configuration parameters are
available:

=over 2

=item C<< -sep => PAT >> (default C<< '\.' >>)

The separator being used, by default a dot. If one wants to match IP addresses
where the octets are separated by semi-colons, one would do:

  $pat = RE Net => 'IPv4', -sep => ':';

=item C<< -base => 2|bin|8|oct|10|dec|16|hex|HeX|HEX >> (default C<< dec >>).

Specifies whether the octets should be binary, octal, decimal or hexadecimal,
with decimal being the default. Use C<< bin >> or C<< 2 >> for octets in
binary, C<< 8 >> or C<< oct >> for octets in octal, and C<< 10 >> or C<< dec >>
for octets in decimal. For hexadecimal, there are a few more options:
C<< 16 >> and C<< HeX >> specify that the hexadecimal numbers may be specified
in either lower case C<< [a-f] >> or upper case C<< [A-F] >>; C<< hex >> only
allows hexadecimal digits in lower case, and C<< HEX >> in upper case.

=back

Leading zeros are allowed, but the octet may not be longer than it would
take to represent 255 (the maximum value of an octet); so a binary octet 
is at most 8 characters long, octal and decimal octets are at most 3
characters long, while hexadecimal octets are not longer than 2 characters.

Empty octets are not allowed.

=head3 Capturing

If the C<< -Keep >> option is used (see L<< Regexp::Common510 >>), the
following named captures are done:

=over 2

=item C<< IPv4 >>

The entire address.

=item C<< octet >>

The four octets. Note that there are four capture groups with the name
C<< octet >>, so one has to look at C<< $- {octet} >> to inspect all
of them.

=back 

=head3 Examples

 "127.0.0.1"      =~ RE Net => 'IPv4';
 "127 0 0 1"      =~ RE Net => 'IPv4', -sep  => ' ';
 "7f.0.0.1"       =~ RE Net => 'IPv4', -base => 'hex';
 "7f.0.0.1"       =~ RE Net => 'IPv4', -base => 'HeX';
 "7F.0.0.1"       !~ RE Net => 'IPv4', -base => 'hex';
 "01111111.0.0.1" =~ RE Net => 'IPv4', -base => 2;

 "127.0.0.1"      =~ RE Net => 'IPv4', -Keep => 1;
 say $+ {IPv4};         # 127.0.0.1
 say $+ {octet1};       # 127
 say $+ {octet2};       #   0
 say $+ {octet3};       #   0
 say $+ {octet4};       #   1


=head1 BUGS

=head1 TODO

=head1 SEE ALSO

=head1 DEVELOPMENT

The current sources of this module are found on github,
L<< git://github.com/Abigail/Regexp-Common510-Net.git >>.

=head1 AUTHOR

Abigail, L<< mailto:cpan@abigail.be >>.

=head1 COPYRIGHT and LICENSE

Copyright (C) 2013 by Abigail.

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),   
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHOR BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

=head1 INSTALLATION

To install this module, run, after unpacking the tar-ball, the 
following commands:

   perl Makefile.PL
   make
   make test
   make install

=cut
