package Regexp::Common510::Net;

use 5.010;
use strict;
use warnings;
no  warnings 'syntax';

our $VERSION = '2013041001';

use Regexp::Common510;

my $sequence_constructor;

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

my %IPv6_unit = (
    hex => [q {0|[1-9a-f][0-9a-f]{0,3}},          # Leading zero not allowed
            q {[0-9a-f]{1,4}},                    # Leading zero allowed
            q {[1-9a-f][0-9a-f]{0,3}},            # Zero not allowed
            q {[1-9a-f][0-9a-f]{0,3}|0[1-9a-f][0-9a-f]{0,2}|} .
            q {00[1-9a-f][0-9a-f]?|000[1-9a-f]}], # 0 not allowed, but may lead

    HeX => [q {0|[1-9a-fA-F][0-9a-fA-F]{0,3}},    # Leading zero not allowed
            q {[0-9a-fA-F]{1,4}},                 # Leading zero allowed
            q {[1-9a-fA-F][0-9a-fA-F]{0,3}},      # Zero not allowed
            q {[1-9a-fA-F][0-9a-fA-F]{0,3}|0[1-9a-fA-F][0-9a-fA-F]{0,2}|} .
            q {00[1-9a-fA-F][0-9a-fA-F]?|000[1-9a-fA-F]}],
                                                  # 0 not allowed, but may lead

    HEX => [q {0|[1-9A-F][0-9A-F]{0,3}},          # Leading zero not allowed
            q {[0-9A-F]{1,4}},                    # Leading zero allowed
            q {[1-9A-F][0-9A-F]{0,3}},            # Zero not allowed
            q {[1-9A-F][0-9A-F]{0,3}|0[1-9A-F][0-9A-F]{0,2}|} .
            q {00[1-9A-F][0-9A-F]?|000[1-9A-F]}], # 0 not allowed, but may lead
);


#
# Pattern for IPv4 addresses. 
#
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

#
# Pattern for MAC addresses.
#
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

#
# Pattern for domains (host names). From RFC 1101 and RFC 1035.
#
pattern  Net         => 'domain',
         -config     => {
            -rfc1035     =>  0,
            -allow_space =>  0,
         },
         -pattern    => \&domain_constructor,
;


#
# Pattern for IPv6 addresses. From RFC 2373 and RFC 5952.
#
pattern  Net         => 'IPv6',
         -config     => {
            -leading_zeros       =>   0,
            -trailing_ipv4       =>   0,
            -single_compression  =>   0,
            -max_compression     =>   1,
            -base                =>  'hex',
            -rfc2373             =>   0,
            -lax                 =>   0,
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
# IPv6 addresses discussed in RFC 2373 and RFC 5952
# See also RFC 6052, RFC 4291, RFC 3513.
#
sub ipv6_constructor {
    my %args               =  @_;

    my $NR_UNITS           =  8;
    my $SEP                = ':';

    my $name               = $args {-Name} [0];
    my $warn               = $args {-Warn};

    my $base               = $args {-base};
    my $lz                 = $args {-leading_zeros} ? 1 : 0;
    my $ipv4               = $args {-trailing_ipv4};
    my $single_compression = $args {-single_compression};
    my $max_compression    = $args {-max_compression};

    if ($args {-lax}) {
        $base               = 'HeX';
        $lz                 =  1;
        $ipv4               =  0;
        $single_compression =  1;
        $max_compression    =  0;
    }

    if ($args {-rfc2373}) {
        $base               = 'HeX';
        $lz                 =  1;
        $ipv4               =  1;
        $single_compression =  1;
        $max_compression    =  0;
    }

    if (!$IPv6_unit {$base}) {
        warn "Unknown -base '$base', falling back to 'HeX'\n" if $warn;
        $base = 'HeX';
    }

    my $unit           = $IPv6_unit {$base} [$lz]     or die;
       $unit           = "(?k<unit>:$unit)";
    my $non_zero_unit  = $IPv6_unit {$base} [2 + $lz] or die;
       $non_zero_unit  = "(?k<unit>:$non_zero_unit)";
    my $zero_unit      = $lz ? "0{1,4}" : 0;
       $zero_unit      = "(?k<unit>:$zero_unit)";

    my $IPv4;
       $IPv4           = Regexp::Common510::RE (Net => 'IPv4', -sep  => '\.',
                                                               -base => 'dec',
                                                               -Keep => 'raw')
                         if $ipv4;

    my @patterns;

    #
    # It may be that there are no compressions.
    #
    if ($max_compression) {
        my $pat = $sequence_constructor -> (
            non_zero_unit       => $non_zero_unit,
            zero_unit           => $zero_unit,
            length              => $NR_UNITS,
            max_zeros           =>  1,
            may_end_with_zero   =>  1,
            may_start_with_zero =>  1,
        );
        push @patterns => $pat;
        if ($ipv4) {
            my $pat = $sequence_constructor -> (
                non_zero_unit       => $non_zero_unit,
                zero_unit           => $zero_unit,
                length              => $NR_UNITS - 2,
                max_zeros           =>  1,
                may_end_with_zero   =>  1,
                may_start_with_zero =>  1,
            );
            #
            # Due to a bug in Perl, we need the trailing, empty-matching
            # (?<unit>) sub-patterns.
            #
            push @patterns => "$pat(?k<unit>:)(?k<unit>:)\\.${IPv4}"
        }
    }
    else {
        push @patterns => join  $SEP => ($unit) x  $NR_UNITS;
        push @patterns => join ($SEP => ($unit) x ($NR_UNITS - 2)) .
             "(?k<unit>:)(?k<unit>:)\\.${IPv4}" if $ipv4;
    }

    my $max_seq_length = $single_compression ? $NR_UNITS - 1 : $NR_UNITS - 2;
    #
    # Since we prefer longest match, we have to go for the
    # trailing IPv4 option first.
    #
    my @ipv4_vals      = $ipv4 ? (1, 0) : (0);

    #
    # Construct sub-patterns for compressions.
    #
    foreach my $ipv4_val (@ipv4_vals) {
        my $max_seq_l = $max_seq_length - 2 * $ipv4_val;
        for (my $l = 0; $l <= $max_seq_l; $l ++) {
            #
            # We prefer to do longest match, so larger $r gets priority
            #
            for (my $r = $max_seq_l - $l; $r >= 0; $r --) {
                #
                # $l is the number of blocks left of the double colon,
                # $r is the number of blocks left of the double colon,
                # $m is the number of omitted blocks
                #
                my $m = $NR_UNITS - 2 * $ipv4_val - $l - $r;

                my $patl;
                if ($l == 0) {
                    $patl = "";
                }
                elsif ($max_compression) {
                    #
                    # We cannot have as many (or more) zero units in succession
                    # as there are compressed units. Nor can there be a zero
                    # unit just before the compression.
                    #
                    $patl = $sequence_constructor -> (
                        non_zero_unit         =>  $non_zero_unit,
                        zero_unit             =>  $zero_unit,
                        length                =>  $l,
                        max_zeros             =>  $m - 1,
                        may_start_with_zero   =>   1,
                        may_end_with_zero     =>   0,
                    );
                }
                else {
                    $patl = join $SEP => ($unit) x  $l;
                }

                my $patr;
                if ($r == 0) {
                    $patr = "";
                }
                elsif ($max_compression) {
                    #
                    # We cannot have more zero units in succession as there are
                    # compressed units. Nor can there be a zero unit just after
                    # the compression.
                    #
                    $patr = $sequence_constructor -> (
                        non_zero_unit         =>  $non_zero_unit,
                        zero_unit             =>  $zero_unit,
                        length                =>  $r,
                        max_zeros             =>  $m,
                        may_start_with_zero   =>   0,
                        may_end_with_zero     =>   1,
                    );
                }
                else {
                    $patr = join $SEP => ($unit) x  $r;
                }

                my $patm = "(?k<unit>:)" x $m;
                my $pat4 = $ipv4_val ? "(?k<unit>:)(?k<unit>:)\\.${IPv4}"
                                     : "";
                push @patterns => "(?:$patl$SEP$patm$SEP$patr$pat4)";
            }
        }
    }

    local $" = "|";

    return "(?k<IPv6>:(?|@patterns))";
}


$sequence_constructor = sub {
    my %args                = @_;
    my $non_zero_unit       = $args       {non_zero_unit};
    my $zero_unit           = $args           {zero_unit};
    my $length              = $args              {length};
    my $max_zeros           = $args           {max_zeros};
    my $may_end_with_zero   = $args   {may_end_with_zero};
    my $may_start_with_zero = $args {may_start_with_zero};

    #
    # All possible sequences
    #
    my @bits = map {sprintf "%0${length}b" => $_} 0 .. 2 ** $length - 1;

    #
    # Filter
    #
    my $filter = "0" x ($max_zeros + 1);

    @bits = grep {!/$filter/} @bits;
    @bits = grep {!/^0/}      @bits unless $may_start_with_zero;
    @bits = grep {!/0$/}      @bits unless $may_end_with_zero;

    #
    # We need a little trick. To make sure we capture a trailing unit
    # like '0007' correctly, we need to match trailing non-zero units
    # before trailing zero units.
    #
    @bits = map {scalar reverse} sort {$b cmp $a} map {scalar reverse} @bits;

    my @patterns = map {
        join ":" => map {$_ ? $non_zero_unit : $zero_unit} split // => $_
    } @bits;

    local $" = "|";

    return "(?|@patterns)";
};


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




=head2 C<< IPv6 >>

The C<< IPv6 >> matches IP version 6 addresses. RFC 2373 defines 
textual representation of those addresses. An IPv6 address is 128 bits,
written down as 8 16-bit parts. Each 16-bit part is written as a 
hexadecimal number (at most 4 characters); the 16-bit parts are separated
by colons. Because sequences of parts that are equal to 0 are common,
they can be compressed by leaving out the entire sequence (and the colons
that separate them), leaving a double colon to indicate the compression.
At most one compression is allowed. It's also allowed to replace the last
32 bits with an IPv4 address, with a dot separating the IPv6 part and the
IPv4 part. Some examples of valid IPv6 addresses:

    2001:abcd:0:0:0:1:c0a8:7f01
    2001:aBCd:0000:0000:0000:0001:c0A8:7f01
    2001:abcd::1:c0a8:7f01
    2001:aBCd:0:0:0:1:192.168.127.1
    2001:abcd::1:192.168.127.1
    ::1:c0a8:7f01
    2001:abcd::
    ::

The first five are different respresentations of the same address. 

That the same address can be represented in different ways is something
that RFC 5952 addresses. It inflicts the following rules to create a
canonical address:

=over 2

=item 1

Addresses must use lower case letters for C<< a .. f >>.

=item 2

A single 16-bit unit that is equal to 0 may not be compressed.

=item 3

If the address contains a sequence to 2 or more parts that are 0, a
compression must happen. Of all possible compressions, the longest
possible compression must be chosen. If there is a choice of longest
possible compressions; the left-most must be taken.

=item 4

Leading zeros in a 16-bit part are not allowed.

=item 5

It is not allowed to represent the last 32 bits as an IPv4 address.

=back

By default, the pattern matches addresses that follow the specification
of RFC 5952, that is, the pattern matches canonical addresses. 

The following configuration options are available:

=over 2

=item C<< -base => hex|HeX|HEX >> (default C<< hex >>)

This flag indicates whether lower case letters must be used, upper case 
letters, or that either case is allowed. C<< -base => 'hex' >> (the default)
means the address must use lower case letters. C<< -base => 'HEX' >> 
matches addresses that use upper case letters, while C<< -base => 'HeX' >>
means the hexadecimal digits exceeding 9 can be written in either case.

=item C<< -leading_zeros => BOOL >> (default C<< 0 >>)

If the C<< -leading_zeros >> parameter is used (with a true value), the
pattern will accept addresses with the 16-bit parts use leading zeros.

=item C<< -single_compression => BOOL >> (default C<< 0 >>)

If the C<< -single_compression >> parameter is used (with a true value), the
pattern will accept addresses where a single 16-bit unit is compressed.

=item C<< -max_compression => BOOL >> (default C<< 1 >>)

The C<< -max_compression >> parameter is used to indicate whether or not
we require addresses to use a maximal possible compression. This means that
an address that does not use a compression, but has 2 or more 16-bit parts
in sequence that are 0, are not matched. By default, this flag is enabled,
so if you want to match addresses that may not use compression, or uses a
non-optimal compression, you need to turn this option off.

=item C<< -trailing_ipv4 => BOOL >> (default C<< 0 >>)

If the C<< -trailing_ipv4 >> parameter is used (with a true value), the
pattern will accept addresses where the final 32 bits are represented 
as an IPv4 address.

=item C<< -rfc2373 => BOOL >> (default C<< 0 >>)

Using this parameter enables the pattern to recognize addresses as 
defined in RFC 2373. It is a shorthand for C<< -base => 'HeX',
-leading_zero => 1, -single_compression => 1, -max_compression => 0,
-trailing_ipv4 => 1 >>. This is pattern that will accept the most.

=item C<< -lax => BOOL >> (default C<< 0 >>)

Using this parameter enables the pattern to recognize addresses as 
defined in RFC 2373, except addresses where the last 32 bits are represented
as an IPv4 address. It is a shorthand for C<< -base => 'HeX',
-leading_zero => 1, -single_compression => 1, -max_compression => 0,
-trailing_ipv4 => 0 >>.

=back

=head3 Capturing

If the C<< -Keep >> option is used (see L<< Regexp::Common510 >>), the
following named captures are done:

=over 2

=item C<< IPv6 >>

This captures the entire address.

=item C<< unit >>

There will be 8 captures named C<< unit >>, each capturing a 16-bit part.
Do note that when there is a compression, there will still be 8 C<< unit >>
captures; the compressed parts will capture as empty strings. If the
last 32 bits are represented as an IPv4 address, there will still be 8
captures named C<< unit >> -- the last two will be empty strings.

=item C<< IPv4 >>

Only present if C<< -trailing_ipv4 => 1 >> or C<< -rfc2373 => 1 >> is used.
Captures the last 32 bits, if represented as an IPv4 address. Otherwise,
the value will be undefined.

=item C<< octet >>

Only present if C<< -trailing_ipv4 => 1 >> or C<< -rfc2373 => 1 >> is used.
There will be four captures named C<< octet >>, and match the 8-bit parts
of the IPv4 address. If the matched address does not end with an IPv4 
address, the four C<< octet >> values will be undefined. (C<< $- {octet} >>
will be a reference to an array containing four undefined values).

=back

=head3 Examples

 "2001:abcd::1:c0a8:7f01"    =~ RE Net => 'IPv6';
 "2001:ABCD::1:C0A8:7F01"    =~ RE Net => 'IPv6', -base => 'HEX';
 "::"                        =~ RE Net => 'IPv6';
 "2001:abcd::0001:c0a8:7f01" =~ RE Net => 'IPv6', -leading_zeros => 1;
 "1234:0:0:0:0:1.127.0.0.1"  =~ RE Net => 'IPv6', -rfc2373 => 1;

 "2001:abcd::1:c0a8:7f01"    =~ RE Net => 'IPv6', -Keep => 1;
 say $+ {IPv6};              #  2001:abcd::1:c0a8:7f01
 say $- {unit} [0];          #  2001
 say $- {unit} [1];          #  abcd
 say $- {unit} [2];          #  ''
 say $- {unit} [3];          #  ''
 say $- {unit} [4];          #  ''
 say $- {unit} [5];          #  1
 say $- {unit} [6];          #  c0a8
 say $- {unit} [7];          #  7f01

 "1234::1.127.0.0.1"         =~ RE Net => 'IPv6', -rfc2373 => 1, -Keep => 1;
 say $+ {IPv6};              #  1234::1.127.0.0.1
 say $- {unit} [0];          #  1234
 say $- {unit} [1];          #  ''
 say $- {unit} [2];          #  ''
 say $- {unit} [3];          #  ''
 say $- {unit} [4];          #  ''
 say $- {unit} [5];          #  1
 say $- {unit} [6];          #  ''
 say $- {unit} [7];          #  ''
 say $+ {IPv4};              # 127.0.0.1
 say $- {octet} [0];         # 127
 say $- {octet} [1];         # 0
 say $- {octet} [2];         # 0
 say $- {octet} [3];         # 1

=head3 Notes on pattern sizes and performance

The patterns generated are quite large, and the size can vary quite a lot
depending on the parameters. Large patterns may have a performance impact.
Patterns that have C<< -max_compression => 1 >> (which includes the
default) will contain a lot of alternations, and may perform a lot of
backtracking before matching (or failing).

Here is an selection of patterns, and their sizes:

 +---------------------------------------------+-------+
 | Pattern                                     |  Size |
 +---------------------------------------------+-------+
 | RE Net => 'IPv6';                           | 24985 |
 | RE Net => 'IPv6', -base          => 'HeX';  | 30043 |
 | RE Net => 'IPv6', -leading_zeros =>    1;   | 73255 |
 | RE Net => 'IPv6', -rfc2373       =>    1;   | 10540 |
 | RE Net => 'IPv6', -lax           =>    1;   |  4379 |
 | RE Net => 'IPv6', -Keep          =>    1;   | 31670 |
 +---------------------------------------------+-------+

The default pattern is the most restrictive pattern, recognizing only
canonical addresses. This may not be the best pattern to use if your
goal is to extract IPv6 addresses from a text, and you want to be more
generous in what you accept. In that case, you may want to consider
C<< RE Net => 'IPv6', -lax => 1 >> or C<< RE Net => 'IPv6', -rfc2373 => 1 >>.



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
