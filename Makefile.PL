use 5.008;
use Inline::MakeMaker;

WriteMakefile(
    NAME              => 'PerlIO::nline',
    VERSION_FROM      => 'nline.pm',
    PREREQ_PM         => { 'Inline::C' => '0.00' },
    ABSTRACT_FROM     => 'nline.pm',
    AUTHOR            => 'Ben Morrow <PerlIO-nline@morrow.me.uk'
);
