package PerlIO::nline;

use 5.008;
use strict;
use warnings;

use XSLoader;

our $VERSION = '0.03';

XSLoader::load __PACKAGE__, $VERSION;

1;

=head1 NAME

PerlIO::nline - Perl extension for newline translation

=head1 SYNOPSIS

  binmode STDOUT, ":nline";

=head1 DESCRIPTION

This layer translates any of \r, \n or \r\n into \n on input, and into
\r\n on output. It is probably a bad idea to mix it with :crlf on one 
filehandle: in particular, under DOSish systems it is definitely a good
idea to push :raw before you start.

Note that if this layer is pushed underneath (i.e. before) a layer such 
as, say, :encoding(utf16) which produces binary data, the output will be
nonsense.

=head1 SEE ALSO

L<PerlIO::crlf|:crlf>, L<PerlIO|PerlIO>.

=head1 AUTHOR

Ben Morrow, E<lt>PerlIO-nline@morrow.me.ukE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2003 by Ben Morrow

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=cut
