use 5.008;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'PerlIO::nline',
    VERSION_FROM      => 'nline.pm',
    PREREQ_PM         => { XSLoader => "0.00" },
#    OBJECT            => 'lib/PerlIO/nline.o',
    ABSTRACT_FROM     => 'nline.pm',
    AUTHOR            => 'Ben Morrow <PerlIO-nline@morrow.me.uk'
);
