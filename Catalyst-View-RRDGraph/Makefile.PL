

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Catalyst::View::RRDGraph',
    VERSION_FROM => 'lib/Catalyst/View/RRDGraph.pm', # finds \$VERSION
    AUTHOR       => 'Jose Luis Martinez (jlmartinez@capside.com)',
    ABSTRACT     => 'RRD Graph View Class',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                     'Catalyst::Runtime' => 0,
                     'Catalyst::Plugin::Static::Simple' => '>= 0.17'
                    },
);
