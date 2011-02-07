package Nagios::Plugin::DieNicely;
use strict;

BEGIN {
     use vars qw($VERSION);
     $VERSION     = '0.01';
}


$SIG{__DIE__} = \&_nagios_die;

sub _nagios_die {
    print "CRITICAL - ", @_;
    # EXIT Nagios CRITICAL
    exit 2;
}

=head1 NAME

Nagios::Plugin::DieNicely - Die in a Nagios output compatible way

=head1 SYNOPSIS

  use Nagios::Plugin::DieNicely;

  ... your code goes here ...

=head1 DESCRIPTION

When your Nagios plugins, or the modules that they use raise an exception with I<die>, I<croak> or I<confess>, the exception gets lost, and Nagios treats the output as an UNKNOWN state with no output from the plugin, as STDERR gets discarded by Nagios.

This module overrides perl's default behaviour of using exit code 255 and printing the error to STDERR for exit code 2 (Nagios CRITICAL), and outputing the error to STDOUT with "CRITICAL - " prepended to the exception.

=head1 TODO

 - People might want WARNING (or OK) on die
 - Get the shortname of the module through Nagios::Plugin if it is beeing used
 - Issue perl warnings to STDOUT, and possbily issue WARNING or CRITICAL

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


=cut

#################### main pod documentation end ###################


1;
# The preceding line will help the module return a true value

