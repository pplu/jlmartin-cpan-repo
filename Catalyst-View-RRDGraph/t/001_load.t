# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 3;

BEGIN { use_ok( 'Catalyst::View::RRDGraph' ); 
        use_ok( 'Catalyst::Helper::View::RRDGraph');
}

my $object = Catalyst::View::RRDGraph->new ();
isa_ok ($object, 'Catalyst::View::RRDGraph');

