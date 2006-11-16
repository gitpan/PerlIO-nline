#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "perlio.h"
#include "perliol.h"

IV
PerlIONLine_pushed(pTHX_ PerlIO *f, const char *mode, SV *arg, PerlIO_funcs *tab)
{
    if (!PerlIO_apply_layers(aTHX_ f, mode, ":eol(LF-CRLF)"))
        return 0;
    return -1;
}


PerlIO_funcs PerlIO_nline = {
        sizeof(PerlIO_funcs),
        "nline",
        0,       /* dummy layer: we just push :eol */
        PERLIO_K_BUFFERED | PERLIO_K_UTF8, 
/* we *aren't* CANCRLF: the point is to avoid that and push/pop layer instead */
        PerlIONLine_pushed,
        NULL,
        NULL, /* open: we want to be pushed */
        NULL,
        NULL, /* getarg: for MULTIARG layers only */
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL
};

MODULE = PerlIO::nline		PACKAGE = PerlIO::nline

PROTOTYPES: DISABLE

BOOT:  
  #ifdef PERLIO_LAYERS
        PerlIO_define_layer(aTHX_ &PerlIO_nline);
  #endif
