package FakeModule;

use Carp;

sub new {
   my ($class) = @_;
   my $self = {};
   bless ($self, $class);
   return $self;
}

sub mydie {
   die "died and Nagios can detect me";

}

sub mycroak {
   croak "croaked and Nagios can detect me";
}

sub myconfess {
   confess "confessed and Nagios can detect me"
}

1;
