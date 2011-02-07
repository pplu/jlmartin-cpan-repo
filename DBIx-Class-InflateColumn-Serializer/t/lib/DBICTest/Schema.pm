package # hide from PAUSE
    DBICTest::Schema;

use base qw/DBIx::Class::Schema/;

no warnings qw/qw/;

__PACKAGE__->load_classes(qw/
  SerializeStorable
  SerializeJSON
  SerializeYAML
  /);

1;
