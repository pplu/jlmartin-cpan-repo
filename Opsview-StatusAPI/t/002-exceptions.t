
use Test::More tests => 4;
use Test::Exception;
use Opsview::StatusAPI;

my $api;

dies_ok(sub {
  $api = Opsview::StatusAPI->new('password' => 'password', 'host' => '127.0.0.1');
}, 'Passing no user dies');

dies_ok(sub {
  $api = Opsview::StatusAPI->new('password' => 'password', 'host' => '127.0.0.1');
}, 'Passing no password dies');

dies_ok(sub {
  $api = Opsview::StatusAPI->new('user' => 'user', 'password' => 'password');
}, 'Passing no host dies');

$api = Opsview::StatusAPI->new('user' => 'user', 'password' => 'password', 'host' => '127.0.0.1');

throws_ok(sub {
  $api->host
}, qr/must specify host/);

