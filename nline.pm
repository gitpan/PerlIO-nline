package PerlIO::nline;

# /*

use 5.008;
use strict;
use warnings;

our $VERSION = '0.01';

use Inline C => <<'EOC', NAME => "PerlIO::nline", VERSION => '0.01', BOOT => <<'EOC';

/* C to compile */

#include <perlio.h>
#include <perliol.h>

#define noperl /* to stop Inline::C binding to Perl */

#define Debug noop

static void noop(const char *s, ...) { return; }

typedef struct {
        PerlIOBuf base;
        STDCHAR  *lie;
        bool      read_cr, writ_cr;
} PerlIONLine;

noperl IV
PerlIONLine_pushed(pTHX_ PerlIO *f, const char *mode, SV *arg, PerlIO_funcs *tab)
{
        PerlIONLine *s = PerlIOSelf(f, PerlIONLine);

        if(PerlIOBase(PerlIONext(f))->flags & PERLIO_F_UTF8)
                PerlIOBase(f)->flags |= PERLIO_F_UTF8;
        else
                PerlIOBase(f)->flags &= ~PERLIO_F_UTF8;

        s->lie = NULL;
        s->read_cr = s->writ_cr = 0;

        return PerlIOBuf_pushed(aTHX_ f, mode, arg, tab);
}

noperl void
PerlIONLine_clearerr(pTHX_ PerlIO *f)
{
        PerlIONLine *s;
        
        if(PerlIOValid(f)) {
                s = PerlIOSelf(f, PerlIONLine);
                if(PerlIOBase(f)->flags & PERLIO_F_EOF) {
                        Debug("eof: clear status\n");
                        s->lie = NULL;
                        s->read_cr = s->writ_cr = 0;
                }
        }

        PerlIOBase_clearerr(aTHX_ f);
}

static void
find_lie(PerlIO *f)
{
        PerlIONLine *s = PerlIOSelf(f, PerlIONLine);
        PerlIOBuf   *b = PerlIOSelf(f, PerlIOBuf);
        STDCHAR *i;
        
        assert(!s->lie);
        assert(PerlIOBase(f)->flags & PERLIO_F_RDBUF);
        assert(b->ptr < b->end);

        if(s->read_cr && *(b->ptr) == 0xa) {
                Debug("skipping \\n\n");
                b->ptr++;
                if(b->ptr == b->end) {
                        PerlIOBase(f)->flags &= ~PERLIO_F_RDBUF;
                        return;
                }
        }
        s->read_cr = 0;

        Debug("looking for lie from %08x to %08x\n", b->ptr, b->end);

        for(i = b->ptr; i < b->end; i++) {
                Debug("looking for lie: %02x\n", *i);

                if(*i == 0xd) {
                        *i = 0xa;
                        if(i++ < (b->end - 1)) {
                                if(*i == 0xa) {
                                        s->lie  = i;
                                        Debug("lieing at %08x\n", s->lie);
                                        return;
                                }
                        } else {
                                s->read_cr = 1;
                                Debug("just read cr\n");
                        }
                }
        }

        s->lie = b->end;
}

noperl SSize_t
PerlIONLine_get_cnt(pTHX_ PerlIO *f)
{
        PerlIONLine *s = PerlIOSelf(f, PerlIONLine);
        PerlIOBuf   *b = PerlIOSelf(f, PerlIOBuf);

        if(!b->buf)          PerlIO_get_base(f);

        if(PerlIOBase(f)->flags & PERLIO_F_RDBUF) {
                if(!s->lie)
                        find_lie(f);
                return s->lie - b->ptr;
        }
        return 0;
}

noperl void
PerlIONLine_set_ptrcnt(pTHX_ PerlIO *f, STDCHAR *ptr, SSize_t cnt)
{
        PerlIONLine *s = PerlIOSelf(f, PerlIONLine);
        PerlIOBuf   *b = PerlIOSelf(f, PerlIOBuf);

        if(!b->buf) PerlIO_get_base(f);

        b->ptr = ptr;
        assert(b->ptr >= b->buf);
        assert(PerlIO_get_cnt(f) == cnt);
        
        if(b->ptr == s->lie && s->lie < b->end) {
                b->ptr++;
                s->lie = NULL;
        }

        if(b->ptr == b->end) {
                s->lie = NULL;
                PerlIOBase(f)->flags &= ~PERLIO_F_RDBUF;
        } else
                PerlIOBase(f)->flags |= PERLIO_F_RDBUF;

        Debug("ptr: %08x, lie: %08x, end: %08x\n", b->ptr, s->lie, b->end);
}

noperl SSize_t
PerlIONLine_write(pTHX_ PerlIO *f, const void *vbuf, Size_t count)
{
        PerlIONLine *s = PerlIOSelf(f, PerlIONLine);
        PerlIOBuf   *b = PerlIOSelf(f, PerlIOBuf);
        const STDCHAR *i, *start = vbuf, *end = vbuf + count;

        if(s->writ_cr && *start == 0xa) start++;
        s->writ_cr = 0;
        
        if(!(PerlIOBase(f)->flags & PERLIO_F_CANWRITE))
                return 0;

        for(i = start; i < end; i++) {
                if(*i == 0xd || *i == 0xa) {
                        if(PerlIOBuf_write(aTHX_ f, start, i - start) < i - start)
                                return i - (STDCHAR*)vbuf;
                        if(PerlIOBuf_write(aTHX_ f, "\xd\xa", 2) < 2)
                                return i - (STDCHAR*)vbuf;
                        /* XXX what to do if we just write the \xd? */

                        if(*i == 0xd) {
                                if(i == end - 1)
                                        s->writ_cr = 1;
                                else
                                        if(i[1] == 0xa)
                                                i++;
                        }

                        start = i + 1;
                }
        }

        if(start < end)
                return (start + PerlIOBuf_write(aTHX_ f, start, end - start))
                    - (STDCHAR*)vbuf;

        return count;
}

PerlIO_funcs PerlIO_nline = {
        sizeof(PerlIO_funcs),
        "nline",
        sizeof(PerlIONLine),
        PERLIO_K_BUFFERED | PERLIO_K_UTF8, 
/* we *aren't* CANCRLF: the point is to avoid that and push/pop layer instead */
        PerlIONLine_pushed,
        PerlIOBuf_popped,
        NULL, /* open: we want to be pushed */
        PerlIOBase_binmode,
        NULL, /* getarg: for MULTIARG layers only */
        PerlIOBase_fileno,
        PerlIOBuf_dup,
        PerlIOBuf_read,
        PerlIOBuf_unread,
        PerlIONLine_write,
        PerlIOBuf_seek,
        PerlIOBuf_tell,
        PerlIOBuf_close,
        PerlIOBuf_flush,
        PerlIOBuf_fill,
        PerlIOBase_eof,
        PerlIOBase_error,
        PerlIONLine_clearerr,
        PerlIOBase_setlinebuf,
        PerlIOBuf_get_base,
        PerlIOBuf_bufsiz,
        PerlIOBuf_get_ptr,
        PerlIONLine_get_cnt,
        PerlIONLine_set_ptrcnt
};
        
EOC
{
  #ifdef PERLIO_LAYERS
        PerlIO_define_layer(aTHX_ &PerlIO_nline);
  #endif
}

EOC

# /*

1;
__END__

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

# */
