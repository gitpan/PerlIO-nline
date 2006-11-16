package PerlIO::nline;

use 5.008;
use strict;
use warnings;

use PerlIO::eol;
use XSLoader;

our $VERSION = '0.04';

XSLoader::load __PACKAGE__, $VERSION;

1;

=head1 NAME

PerlIO::nline - Perl extension for newline translation

=head1 SYNOPSIS

  binmode STDOUT, ":nline";

=head1 DESCRIPTION

This module is deprecated in favour of PerlIO::eol, c.f.. The current
version just pushes C<:eol(LF-CRLF)>. This means that C<:nline> won't
show up in the output of C<PerlIO::get_layers> any more.

=head1 THANKS TO

Audrey Tang, for taking my half-baked idea and turning it into something
useful :).

=head1 SEE ALSO

L<PerlIO::eol>.

=head1 AUTHOR

Ben Morrow, E<lt>PerlIO-nline@morrow.me.ukE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Ben Morrow

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=cut
