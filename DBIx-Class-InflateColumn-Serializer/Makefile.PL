use inc::Module::Install;
  
name           'DBIx-Class-InflateColumn-Serializer';
license        'perl';
author         'Jose Luis Martinez (jlmartinez@capside.com)';
abstract       'Inflators to serialize data structures for DBIx::Class';
perl_version   '5.008';

all_from       'lib/DBIx/Class/InflateColumn/Serializer.pm';

requires      'DBIx::Class';
recommends    'JSON';
recommends    'YAML';

test_requires 'DBD::SQLite';
test_requires 'JSON';
test_requires 'YAML';
test_requires 'Test::More';
test_requires 'Test::Exception';

WriteAll;
