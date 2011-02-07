
use Test::More;

my $tests = [
	{ 'plugin' => './t/bin/die_in_script.pl',  text => 'died and Nagios can detect me', ecode => 2},
	{ 'plugin' => './t/bin/croak_in_script.pl', text => 'croaked and Nagios can detect me', ecode => 2},
	{ 'plugin' => './t/bin/confess_in_script.pl', text => 'confessed and Nagios can detect me', ecode =>2 },
	{ 'plugin' => './t/bin/die_in_module.pl', text => 'died and Nagios can detect me', ecode => 2 },
	{ 'plugin' => './t/bin/croak_in_module.pl', text => 'croaked and Nagios can detect me', ecode => 2 },
	{ 'plugin' => './t/bin/confess_in_module.pl', text => 'confessed and Nagios can detect me', ecode => 2 },
	{ 'plugin' => './t/bin/die_in_extmodule.pl', text => 'died and Nagios can detect me', ecode => 2 },
	{ 'plugin' => './t/bin/croak_in_extmodule.pl', text => 'croaked and Nagios can detect me', ecode => 2 },
	{ 'plugin' => './t/bin/confess_in_extmodule.pl', text => 'confessed and Nagios can detect me', ecode => 2 },
];

plan tests => (scalar(@$tests) * 2);

foreach my $test (@$tests) {
    my ($rc, $out) = run_plugin($test->{'plugin'});
    cmp_ok($rc, '==', $test->{'ecode'}, "Exit code $test->{'ecode'} for ' . $test->{'plugin'}");
    like($out, qr/$test->{'text'}/, 'Expected output ok');
}

sub run_plugin {
    my ($plugin) = @_;
    my $output = `perl -I blib/lib -I t/lib $plugin 2>/dev/null`;
    chomp $output;
    my $rc = $? >> 8;
    return ( $rc, $output );
}
