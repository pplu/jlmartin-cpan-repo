#!/usr/bin/perl

use Nagios::Plugin::DieNicely;
use FakeModule;

my $obj = FakeModule->new();

eval {
    $obj->mydie();
};

print "OK";
exit 0;

1;
