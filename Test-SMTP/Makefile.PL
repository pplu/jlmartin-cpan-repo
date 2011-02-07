

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Test::SMTP',
    VERSION_FROM => 'lib/Test/SMTP.pm', # finds \$VERSION
    AUTHOR       => 'Jose Luis Martinez (jlmartinez@capside.com)',
    ABSTRACT     => 'Module to write SMTP Server tests',
    PREREQ_PM    => {
                     'Test::Simple'                   => 0.44,
                     'Net::SMTP_auth'                 => 0,
                     'Test::Builder::Module'          => 0,
                     'Test::More'                     => 0.62,
                     'Test::Builder::Tester'          => 1.02,
                     'Test::Exception'                => 0.21,
                     'Net::Server::Mail'              => 0.13,
		     'Net::Server::Mail::ESMTP::AUTH' => 0,
                     'Test::Pod'                      => 1.00,
		     'Test::Pod::Coverage'            => 1.00
                    },
    LICENSE      => 'perl'
);
