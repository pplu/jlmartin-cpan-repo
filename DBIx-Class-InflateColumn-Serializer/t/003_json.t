use strict;
use warnings;

use Test::More;
use Test::Exception;
use lib qw(t/lib);
use DBICTest;

#eval { require JSON::Any };
#plan( skip_all => 'JSON::Any not installed; skipping' ) if $@;

my $schema = DBICTest->init_schema();

plan tests => 9;

my $struct_hash = {
    b => 1,
    c => [
        { d => 2 },
    ],
    e => 3,
};

my $struct_array = [
    'b',
    {
        c => 1,
        d => 2
    },
    'e',
];

my $rs = $schema->resultset("SerializeJSON");
my ($stored, $inflated);

$stored = $rs->create({ 
  'testtable_id' => 2
});

ok($stored->update({ 'serial1' => $struct_hash, 'serial2' => $struct_array }), 'deflation');

#retrieve what was serialized from DB
undef $stored;
$stored = $rs->find({'testtable_id' => 2});

ok($inflated = $stored->serial1, 'hashref inflation');
is_deeply($inflated, $struct_hash, 'the stored hash and the orginial are equal');
ok($inflated = $stored->serial2, 'arrayref inflation');
is_deeply($inflated, $struct_array, 'the stored array and the orginial are equal');

throws_ok(sub {
  $stored->update({ 'serial1' => { 'bigkey' => 'n' x 1024 }
                  });
}, qr/serialization too big/, 'Serialize result bigger than size of column');


ok($stored->update({ 'serial2' => { 'bigkey' => 'n' x 1024 }
                   })
,'storing a serialization too big for a column without size');

undef $stored;
$stored = $rs->find({'testtable_id' => 2});

TODO: {
  local $TODO = 'sqlite doesn\'t truncate TEXT fields...';

  throws_ok(sub {
    $inflated = $stored->serial2
  }, qr/unexpected end of string/, 'the serialization is truncated, but at least we get an exception');

};

$stored->update({ 'serial1' => undef });

undef $stored;
$stored = $rs->find({'testtable_id' => 2});

ok(not(defined($stored->serial1)), 'serial1 is undefined');

