package AuthTestApp2;

use Catalyst qw/Authentication/;

use Test::More;
use Test::Exception;

sub authed_ok : Local {
	my ( $self, $c ) = @_;

	ok(!$c->user, "no user");
        my $authd = $c->authenticate( { "username" => $c->request->param('username'),
	                               "password" => $c->request->param('password') });
	ok($authd, "logged in");
	ok(defined($c->user->get('name')), "user object is ok");

	if ($authd){
	    $c->response->body( "authed " . $c->user->get('name') );
	} else {
            $c->response->body( "not authed" );
	}

        $c->logout;
	ok(!$c->user, "no user");
}


sub authed_ko : Local {
	my ( $self, $c ) = @_;

	ok(!$c->user, "no user");
        my $authd = $c->authenticate( { "username" => $c->request->param('username'),
	                               "password" => $c->request->param('password') });
	ok(not($authd), "not logged in");
	ok(!$c->user, "user object not present");

	if ($authd){
	    $c->response->body( "authed" );
	} else {
            $c->response->body( "not authed" );
	}

        $c->logout;
	ok(!$c->user, "no user");
}

__PACKAGE__->config->{'Plugin::Authentication'} = {
  'realms' => {
    'default' => {
      'store' => {
        'class' => 'Minimal',
        'users' => {
          bob => { name => "Bob Smith" },
          john => { name => "John Smith" }
	}
      },
      'credential' => {
        'class' => 'Authen::Simple',
        'authen' => [
          {
            'class' => 'OnlyOne',
            'args' => {
              'pass' => 'uniquepass'
            }
          }
        ],
      }
    }
  }
};

__PACKAGE__->setup();
