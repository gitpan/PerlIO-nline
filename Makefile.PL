use 5.008;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'PerlIO::nline',
    VERSION_FROM      => 'nline.pm',
    PREREQ_PM         => { 
        XSLoader => '0.00',
        'PerlIO::eol' => '0.02'
    },
    ABSTRACT_FROM     => 'nline.pm',
    AUTHOR            => 'Ben Morrow <PerlIO-nline@morrow.me.uk>'
);
