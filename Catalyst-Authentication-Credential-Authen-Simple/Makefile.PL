

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Catalyst::Authentication::Credential::Authen::Simple',
    VERSION_FROM => 'lib/Catalyst/Authentication/Credential/Authen/Simple.pm', # finds \$VERSION
    AUTHOR       => 'Jose Luis Martinez (jlmartinez@capside.com)',
    ABSTRACT     => 'Verify credentials with the Authen::Simple framework',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
		     'Test::More'   => 0,
		     'Authen::Simple' => 0,
		     'Catalyst::Runtime' => 5.7,
		     'Catalyst::Plugin::Authentication' => '>= 1.0'
                    },
    LICENSE      => 'perl'
);
