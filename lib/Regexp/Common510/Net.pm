package Regexp::Common510::Net;

use 5.010;
use strict;
use warnings;
no  warnings 'syntax';

our $VERSION = '2013041001';

use Regexp::Common510;

use warnings::register;

my %IP4map  = (
    16      => 'hex',
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


pattern  Net           => 'IPv4',
         -config       => {
            -sep       =>  '\.',
            -base      =>   10,
         },
         -pattern      => \&IPv4,
;


sub IPv4 {
    my %args = @_;

    my $base = $args {-base};
       $base = $IP4map {$base} if $IP4map {$base};

    warnings::warn ("Unknown -base '$base', falling back to default 'dec'\n")
       if (!$base || !$IP4unit {$base}) && warnings::enabled;

    my $byte = $IP4unit {$base};

    my $sep = $args {-sep};
    eval {qr /$sep/} or do {
        $sep = '\.';
        warnings::warn ("Cannot compile pattern '$sep' for the separator -- " .
                        "failling back to default /\\./\n")
               if warnings::enabled;
    };

    return '(?k<IPv4>:'                .
           "(?k<byte1>:$byte)(?:$sep)" .
           "(?k<byte2>:$byte)(?:$sep)" .
           "(?k<byte3>:$byte)(?:$sep)" .
           "(?k<byte4>:$byte))";
}


1;

__END__

=head1 NAME

Regexp::Common510::Net - Abstract

=head1 SYNOPSIS

=head1 DESCRIPTION

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
