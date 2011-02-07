#!/usr/bin/perl

use Nagios::Plugin::DieNicely;
use Carp;

my $obj = MyModule->new();

package MyModule;

sub new{
	confess "confessed and Nagios can detect me";
}

1;
