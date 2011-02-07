use inc::Module::Install;

# Define metadata
name           'Catalyst-View-RRDGraph';
version_from   'lib/Catalyst/View/RRDGraph.pm';
author         'Jose Luis Martinez (jlmartinez@capside.com)';
abstract       'RRD Graph View Class';

requires       'Catalyst::Runtime'  => 0;
requires       'Catalyst::Plugin::Static::Simple' => 0.17;
requires       'RRDs' => 0;
requires       'MRO::Compat' => 0;

test_requires  'Test::Simple'  => '0.44';
test_requires  'Test::MockObject' => 0;

license 'perl';

WriteAll;

