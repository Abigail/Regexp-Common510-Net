package Regexp::Common510::Net;

use 5.010;
use strict;
use warnings;
no  warnings 'syntax';

our $VERSION = '2013041001';

use Regexp::Common510;


my %octet_map  = (
    16      => 'HeX',
    10      => 'dec',
     8      => 'oct',
     2      => 'bin',
);

my %octet_unit = (
    dec => q {25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2}},
    oct => q {[0-3]?[0-7]{1,2}},
    hex => q {[0-9a-f]{1,2}},
    HeX => q {[0-9a-fA-F]{1,2}},
    HEX => q {[0-9A-F]{1,2}},
    bin => q {[0-1]{1,8}},
);


pattern  Net         => 'IPv4',
         -config     => {
            -sep     =>  '\.',
            -base    =>  'dec',
         },
         -extra_args => [
            -nr_of_octets  =>  4,
            -fallback_base => 'dec',
            -fallback_sep  => '\.',
         ],
         -pattern    => \&octet_constructor,
;

pattern  Net         => 'MAC',
         -config     => {
            -sep     =>  ':',
            -base    =>  'HeX',
         },
         -extra_args => [
            -nr_of_octets  =>  6,
            -fallback_base => 'HeX',
            -fallback_sep  => ':',
         ],
         -pattern    => \&octet_constructor,
;

pattern  Net         => 'domain',
         -config     => {
            -rfc1035     =>  0,
            -allow_space =>  0,
         },
         -pattern    => \&domain_constructor,
;


pattern  Net         => 'IPv6',
         -config     => {
            -leading_zero   =>  1,
            -trailing_ipv4  =>  1,
         },
         -pattern    => \&ipv6_constructor,
;



sub octet_constructor {
    my %args    = @_;

    my $name    = $args {-Name} [0];
    my $warn    = $args {-Warn};

    my $base    = $args {-base};
       $base    = $octet_map {$base} if $octet_map {$base};

    my $fb_base = $args {-fallback_base};

    warn ("Unknown -base '$base', falling back to '$fb_base'\n")
       if (!$base || !$octet_unit {$base}) && $warn;

    my $octet = $octet_unit {$base || ""} || $octet_unit {$fb_base};

    my $sep = $args {-sep};
    eval {qr /$sep/} or do {
        my $fb_sep = $args {-fallback_sep};
        warn ("Cannot compile pattern /$sep/ for the separator -- " .
              "falling back to default /$fb_sep/\n") if $warn;
        $sep = $fb_sep;
    };

    return "(?k<$name>:"
         . join ("(?:$sep)" => ("(?k<octet>:$octet)") x $args {-nr_of_octets})
         . ")";
}


my $letter      =  "[A-Za-z]";
my $let_dig     =  "[A-Za-z0-9]";
my $let_dig_hyp = "[-A-Za-z0-9]";

sub domain_constructor {
    my %args    = @_;

    my $lead;

    #
    # RFC 1101 allows host and domain names to start with a digit,
    # while the original RFC 1035 did not allow that. However, if
    # it starts with a digit, it may not look like an IPv4 address.
    #
    if ($args {-rfc1035}) {
        $lead = $letter;
    }
    else {
        my $IPv4 = Regexp::Common510::RE (Net => 'IPv4', -sep  => '\.',
                                                         -base => 'dec');
        $lead = "(?!$IPv4(?:[.]|\$))$let_dig";
    }

    my $part   = "$lead(?:(?:$let_dig_hyp){0,61}$let_dig)?";
    my $domain = "$part(?:\\.$part)*";
       $domain = "(?: |$domain)" if $args {-allow_space};

    return "(?k<domain>:$domain)";
}



#
# IPv6 addresses discussed in RFC 2373
#
sub ipv6_constructor {
    1;
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
where the octets are separated by colons, one would do:

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
of them. (<< @{$- {octet}} >> lists them all).

=back 

=head3 Examples

 "127.0.0.1"      =~ RE Net => 'IPv4';
 "127 0 0 1"      =~ RE Net => 'IPv4', -sep  => ' ';
 "7f.0.0.1"       =~ RE Net => 'IPv4', -base => 'hex';
 "7f.0.0.1"       =~ RE Net => 'IPv4', -base => 'HeX';
 "7F.0.0.1"       !~ RE Net => 'IPv4', -base => 'hex';
 "01111111.0.0.1" =~ RE Net => 'IPv4', -base =>  2;

 "127.0.0.1"      =~ RE Net => 'IPv4', -Keep =>  1;
 say $+ {IPv4};         # 127.0.0.1
 say $- {octet} [0];    # 127
 say $- {octet} [1];    #   0
 say $- {octet} [2];    #   0
 say $- {octet} [3];    #   1



=head2 C<< MAC >>

The C<< MAC >> pattern matches MAC addresses (or formally known as
I<< EUI-48 >> addresses), which are used for various network related
technologies, perhaps most notably for Ethernet addresses.

By default, the pattern recognizes addresses that are written using
hexadecimal numbers, with each octet separated by colons (C<< : >>).
But this can be configured using the following parameters:

=over 2

=item C<< -sep => PAT >> (default C<< ':' >>)

The separator being used, by default a colon. If one wants to match MAC
addresses where the octets are separated by dots, one would do:

  $pat = RE Net => 'MAC', -sep => '\.';

=item C<< -base => 2|bin|8|oct|10|dec|16|hex|HeX|HEX >> (default C<< HeX >>).

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

=item C<< MAC >>

The entire address.

=item C<< octet >>

The six octets. Note that there are six capture groups with the name
C<< octet >>, so one has to look at C<< $- {octet} >> to inspect all
of them. (<< @{$- {octet}} >> lists them all).

=back 

=head3 Examples

 "01:23:45:67:89:AB"      =~ RE Net => 'MAC';
 "01-23-45-67-89-AB"      =~ RE Net => 'MAC', -sep  => '-';
 "1:35:69:103:137:171"    =~ RE Net => 'MAC', -base => 'dec';
 "01:23:45:67:89:AB"      !~ RE Net => 'MAC', -base => 'hex';

 "01:23:45:67:89:AB"      =~ RE Net => 'MAC', -Keep =>  1;
  say $+ {MAC};                 # 01:23:45:67:89:AB
  say $- {octet} [0];           # 01
  say $- {octet} [1];           # 23
  say $- {octet} [2];           # 45
  say $- {octet} [3];           # 67
  say $- {octet} [4];           # 89
  say $- {octet} [5];           # AB



=head2 C<< domain >>

The C<< domain >> pattern matches domain names (and host names) as defined
by RFC 1035 and RFC 1101. Domain names consist of one or more so-called
labels, with the labels separated by dots. Labels consist of (ASCII) letters,
digits and hyphens. A label may not start or end with a hyphen.

RFC 1035 forbids labels to start with a digit, but RFC 1101 has relaxed
this restriction; labels are allowed to start with digits, as long as
the result does not appear to contain an IP address. By default, the 
pattern follows the RFC 1101 relaxation. Hence, domains like C<< 3M.com >>
and C<< 92920v.nl >> will be recognized.

A single space is also a valid domain name. However, for most applications
using this pattern this is undesired behaviour; hence, by default, the
pattern will B<< not >> match a single space.

The pattern can be configured as follows:

=over 2

=item C<< -rfc1035 => BOOL >> (default false)

If the C<< -rfc1035 >> parameter is given, the pattern will not allow
labels to start with digits (as per RFC 1035).

=item C<< -allow_space => BOOL >> (default false)

If the C<< -allow_space >> parameter is given, the pattern will match
a single space as well.

=back

=head3 Capturing

If the C<< -Keep >> option is used (see L<< Regexp::Common510 >>), only
one capture is done, named C<< domain >>, which matches the entire domain.

=head3 Caveat

RFC 1035 limits domain names to 255 characters. The pattern does B<< not >>
check for this limit. (Labels are limited to 63 characters, and the pattern
does check against that).

=head3 Examples

  "www.example.com"       =~ RE Net => 'domain';
  "some-host-name"        =~ RE Net => 'domain';
  "3M.com"                =~ RE Net => 'domain';
  "3M.com"                !~ RE Net => 'domain', -rfc1035     => 1;
  " "                     !~ RE Net => 'domain';
  " "                     =~ RE Net => 'domain', -allow_space => 1;


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
