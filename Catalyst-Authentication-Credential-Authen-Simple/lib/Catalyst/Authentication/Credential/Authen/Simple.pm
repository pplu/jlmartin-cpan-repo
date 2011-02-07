package Catalyst::Authentication::Credential::Authen::Simple;

our $VERSION = '0.01';

use Authen::Simple;
use Module::Load;

sub new {
    my ($class, $config, $app, $realm) = @_;
    my $self = {};
    bless $self, $class;

    unless (defined $config->{'authen'}){
        die "No Authen::Simple classes specified for Credential::Authen::Simple in 'authen' key"
    }

    if (ref($config->{'authen'}) ne 'ARRAY') {
        $config->{'authen'} = [ $config->{'authen'}  ];
    }

    my @auth_arr;
    foreach my $auth (@{ $config->{'authen'}  }){
        my $class = "Authen::Simple::$auth->{'class'}";
        $app->log->debug("Loading class: $class");
        load $class;
        push @auth_arr, $class->new(%{ $auth->{'args'} });
    }

    $self->{'_config'}->{'password_field'} ||= 'password';
    $self->{'_auth'} = new Authen::Simple(@auth_arr);

    return $self;

}

sub authenticate {
    my ($self, $c, $realm, $authinfo) = @_;

    my $user = $authinfo->{'username'};
    my $password = $authinfo->{'password'};

    ## because passwords may be in a hashed format, we have to make sure that we remove the
    ## password_field before we pass it to the user routine, as some auth modules use
    ## all data passed to them to find a matching user...
    my $userfindauthinfo = {%{$authinfo}};
    delete($userfindauthinfo->{$self->{'_config'}->{'password_field'}});

    my $user_obj = $realm->find_user($userfindauthinfo, $c);
    if (not ref($user_obj)) {
        $c->log->debug("Unable to locate user matching user info provided") if $c->debug;
        return;
    }

    unless (defined $password) {
        $c->log->debug("Can't login a user without a password") if $c->debug;
        return 0;
    }

    if ($self->{'_auth'}->authenticate($user, $password)){
        $c->log->debug("User $user Authenticated");
        return $user_obj;
    } else {
        $c->log->debug("None of the Authen::Simple classes authed $user");
        return;
    }
}

#################### main pod documentation begin ###################

=head1 NAME

Catalyst::Authentication::Credential::Authen::Simple - Verify credentials with the Authen::Simple framework

=head1 SYNOPSIS

  use Catalyst qw(Authentication);
  # later on ...
  if ($c->authenticate({ username => 'myusername', 
                         password => 'mypassword' })){
    my $long_name = $c->user->get('LongName');
    # Hello Mr $long_name 
  }

=head1 DESCRIPTION

This module helps your Cataylst Application authenticate against a lot of credential databases thanks to the Authen::Simple framework.

=head1 USAGE

Just configure your Catalyst App Authentication to use class 'Authen::Simple' as the credential verifier, and give it a set of Authen::Simple classes. You can pass arguments to the Authen::Simple:XXX class constructors with the 'args' key. Note that the authen key is an array. If more than one class is specified, when your app authenticates, the username and password is submitted to each class until one of the classes returns that the user/pass pair is valid. If no class validates the credentials, the user is not able to log in.

  'Plugin::Authentication' => {
    'realms' => {
      'default' => {
        'store' => { ... }
        'credential' => {
          'class' => 'Authen::Simple',
          'authen' => [
            {
              'class' => 'Passwd',
              'args' => {
                'path' => '/etc/shadow'
              }
            },
            {
              'class' => 'SSH',
              'args' => {
                'host' => 'host.company.com'
              }
            }
          ]
        }
      }
    }
  }

=head2 new

Called by Catalyst::Authentication. Instances the Authen::Simple classes read from the configuration.

=cut

=head2 authenticate 

 Usage     : Call $c->authenticate({ username => ..., password => ...}); 
 Returns   : User object if the credentials are verified successfully. undef if user not authenticated.

=cut

=head1 AUTHOR

    Jose Luis Martinez
    CPAN ID: JLMARTIN
    CAPSiDE
    jlmartinez@capside.com
    http://www.pplusdomain.net

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

Authen::Simple and all of the Authen::Simple::XXX classes

=cut

#################### main pod documentation end ###################


1;

