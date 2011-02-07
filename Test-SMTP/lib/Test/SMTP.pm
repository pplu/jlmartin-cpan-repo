package Test::SMTP;

use strict;
use warnings;

BEGIN {
    use Exporter ();
    use Carp;
    use Net::SMTP;
    use Test::Builder::Module;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
    $VERSION     = '0.02';
    @ISA         = qw(Net::SMTP Test::Builder::Module);
    #Give a hoot don't pollute, do not export more than needed by default
    @EXPORT      = qw();
    @EXPORT_OK   = qw(plan);
    %EXPORT_TAGS = ();
}

=head1 NAME

Test::SMTP - Module for writing SMTP Server tests

=head1 SYNOPSIS

    use Test::SMTP;

    plan tests => 10;
    # Constructors
    my $client1 = Test::SMTP->connect_ok('connect to mailhost',
                                         Host => '127.0.0.1', AutoHello => 1);
    $client1->mail_from_ok('test@example.com', 'Accept an example mail from');
    $client1->rcpt_to_ko('test2@example.com', 'Reject an example domain in rcpt to');
    $client1->quit_ok('Quit OK');
    my $client2 = Test::SMTP->connect_ok('connect to mailhost',
                                         Host => '127.0.0.1', AutoHello => 1);
    ...


=head1 DESCRIPTION


This module is designed for easily building tests for SMTP servers.

Test::SMTP is a subclass of Net::SMTP, that in turn is a subclass of Net::Cmd
and IO::Socket::INET. Don't be too confident of it beeing a Net::SMTP subclass for too much time, though.

=head1 PLAN

=over 4

=item plan

Plan tests a la Test::More. Exported on demand (not necessary to export if you are already using a test module that exports plan). 

  use Test::SMTP qw(plan);
  plan tests => 5;

=cut

sub plan {
    my $tb = __PACKAGE__->builder;
    $tb->plan(@_);
}

=back 

=head1 CONSTRUCTOR

=over 4

=item connect_ok($name, Host => $host, AutoHello => 1, [ Timeout => 1 ])

Passes if the client connects to the SMTP Server. Everything after I<name> is passed to the Net::SMTP I<new> method. returns a Test::SMTP object. 

Net::SMTP parameters of interest: 
Port => $port (connect to non-standard SMTP port)
Hello => 'my (he|eh)lo' hello to send to the server
Debug => 1 Outputs via STDERR the conversation with the server

You have to pass AutoHello => 1, this will enable auto EHLO/HELO negotiation.

=cut

sub connect_ok {
    my ($class, $name, %params) = @_;

    if ((not defined($params{'AutoHello'})) or ($params{'AutoHello'} != 1)){
        croak "Can only handle AutoHello for now...";
    }

    my $smtp = Net::SMTP->new(%params);

    my $tb = __PACKAGE__->builder();
    $tb->ok(defined $smtp, $name);

    if (not defined($smtp)){
        return undef;
    }

    bless $smtp, $class;
    return $smtp;
}

=item connect_ko($name, Host => $host, [ Timeout => 1 ])

Passes test if the client does not connect to the SMTP Server. Everything after I<name> is passed to the Net::SMTP I<new> method.

=cut

sub connect_ko {
    my ($class, $name, @params) = @_;

    my $smtp = Net::SMTP->new(@params);
    my $tb = __PACKAGE__->builder();

    $tb->ok(not(defined $smtp), $name);

    if (not defined $smtp){
        return undef;
    }

    bless $smtp, $class;
    return $smtp;
}

=back

=head1 TEST METHODS

=over 4

=cut

=item code_is ($expected, $name)

Passes if the last SMTP code returned by the server was I<expected>.

=cut

sub code_is {
    my ($self, $expected, $name) = @_;
    my $tb = __PACKAGE__->builder();

    $tb->cmp_ok($self->code(), '==', $expected, $name);
}

=item code_isnt ($expected, $name)

Passes if the last SMTP code returned by the server was'nt I<expected>.

=cut

sub code_isnt {
    my ($self, $expected, $name) = @_;
    my $tb = __PACKAGE__->builder();

    $tb->cmp_ok($self->code(), '!=', $expected, $name);
}

=item code_is_success($name)

Passes if the last SMTP code returned by the server indicates success.

=cut

sub code_is_success {
    my ($self, $name) = @_;
    my $tb = __PACKAGE__->builder();

    if (_is_between($self->code(), 200, 399)){
        $tb->ok(1, $name);
    } else {
        $tb->ok(0, $name);
        $self->_smtp_diag;
    }
}

=item code_isnt_success($name)

Passes if the last SMTP code returned by the server doesn't indicate success.

=cut

sub code_isnt_success {
    my ($self, $name) = @_;
    my $tb = __PACKAGE__->builder();

    if (_is_between($self->code(), 200, 399)){
        $tb->ok(0, $name);
        $self->_smtp_diag;
    } else {
        $tb->ok(1, $name);
    }
}

=item code_is_failure($name)

Passes if the last SMTP code returned by the server indicates failure (either
temporary or permanent).

=cut

sub code_is_failure {
    my ($self, $name) = @_;
    my $tb = __PACKAGE__->builder();

    if (not _is_between($self->code(), 200, 399)){
        $tb->ok(1, $name);
    } else {
        $tb->ok(0, $name);
        $self->_smtp_diag;
    }
}

=item code_isnt_failure($name)

Passes if the last SMTP code returned by the server doesn't indicate failure (either
temporary or permanent).

=cut

sub code_isnt_failure {
    my ($self, $name) = @_;
    my $tb = __PACKAGE__->builder();

    if (not _is_between($self->code(), 200, 399)){
        $tb->ok(0, $name);
        $self->_smtp_diag;
    } else {
        $tb->ok(1, $name);
    }
}

=item code_is_temporary($name)

Passes if the last SMTP code returned by the server indicates temporary failure

=cut

sub code_is_temporary {
    my ($self, $name) = @_;
    my $tb = __PACKAGE__->builder();

    if (_is_between($self->code(), 400, 499)){
        $tb->ok(1, $name);
    } else {
        $tb->ok(0, $name);
        $self->_smtp_diag;
    }
}

=item code_isnt_temporary($name)

Passes if the last SMTP code returned by the server doesn't indicate temporary failure

=cut

sub code_isnt_temporary {
    my ($self, $name) = @_;
    my $tb = __PACKAGE__->builder();

    if (_is_between($self->code(), 400, 499)){
        $tb->ok(0, $name);
        $self->_smtp_diag;
    } else {
        $tb->ok(1, $name);
    }
}

=item code_is_permanent($name)

Passes if the last SMTP code returned by the server indicates permanent failure

=cut

sub code_is_permanent {
    my ($self, $name) = @_;
    my $tb = __PACKAGE__->builder();

    if (_is_between($self->code(), 500, 599)){
        $tb->ok(1, $name);
    } else {
        $tb->ok(0, $name);
        $self->_smtp_diag;
    }
}

=item code_isnt_permanent($name)

Passes if the last SMTP code returned by the server doesn't indicate permanent failure

=cut

sub code_isnt_permanent {
    my ($self, $name) = @_;
    my $tb = __PACKAGE__->builder();

    if (_is_between($self->code(), 500, 599)){
        $tb->ok(0, $name);
        $self->_smtp_diag;
    } else {
        $tb->ok(1, $name);
    }
}

=item message_like(qr/REGEX/, $name)

Passes if the last SMTP message returned by the server matches the regex.

=cut

sub message_like {
    my ($self, $expected, $name) = @_;
    my $tb = __PACKAGE__->builder();

    my $message = $self->message();
    $tb->like($message, $expected, $name);
}

=item message_unlike(qr/REGEX/, $name)

Passes if the last SMTP message returned by the server does'nt match the regex.

=cut

sub message_unlike {
    my ($self, $expected, $name) = @_;
    my $tb = __PACKAGE__->builder();

    my $message = $self->message();
    $tb->unlike($message, $expected, $name);
}

=item rset_ok($name)

Send a RSET command to the server. Pass if command was successful

=cut

sub rset_ok {
    my ($self, $name) = @_;
    my $tb = __PACKAGE__->builder();

    if ($self->reset){
        $tb->ok(1, $name);
    } else {
        $tb->ok(0, $name);
        $self->_smtp_diag;
    }
}

=item rset_ko($name)

Send an RSET to the server. Pass if command was not successful

=cut

sub rset_ko {
    my ($self, $name) = @_;
    my $tb = __PACKAGE__->builder();

    if ($self->reset){
        $tb->ok(0, $name);
        $self->_smtp_diag;
    } else {
        $tb->ok(1, $name);
    }
}

=item supports_ok($capa, $name)

Passes test if server said it supported I<capa> capability on ESMTP EHLO

=cut

sub supports_ok {
    my ($self, $capa, $name) = @_;
    my $tb = __PACKAGE__->builder();

    if (defined $self->supports($capa)){
        $tb->ok(1, $name);
    } else {
        $tb->ok(0, $name);
    }
}

=item supports_ko($capa, $name)

Passes test if server didn't say it supported I<capa> capability on ESMTP EHLO

=cut

sub supports_ko {
    my ($self, $capa, $name) = @_;
    my $tb = __PACKAGE__->builder();

    if (defined $self->supports($capa)){
        $tb->ok(0, $name);
        $tb->diag("Server supports the feature $capa with " . $self->supports($capa));
    } else {
        $tb->ok(1, $name);
    }
}

=item supports_cmp_ok($capability, $operator, $expected, $name)

Compares server I<capa> capability extra information with I<operator> against I<expected>.

=cut

sub supports_cmp_ok {
    my ($self, $capa, $operator, $expected, $name) = @_;
    my $tb = __PACKAGE__->builder();

    my $val = $self->supports($capa);
    $tb->cmp_ok($val, $operator, $expected, $name);
}

=item supports_like($capability, qr/REGEX/, $name)

Passes if server I<capa> capability extra information matches against I<REGEX>.

=cut

sub supports_like {
    my ($self, $capa, $expected, $name) = @_;
    my $tb = __PACKAGE__->builder();

    my $val = $self->supports($capa);
    $tb->like($val, $expected, $name);
}

=item supports_unlike($capability, qr/REGEX/, $name)

Passes if server I<capa> capability extra information doesn't match against I<REGEX>.

=cut

sub supports_unlike {
    my ($self, $capa, $expected, $name) = @_;
    my $tb = __PACKAGE__->builder();

    my $val = $self->supports($capa);
    $tb->unlike($val, $expected, $name);
}

=item banner_like(qr/REGEX/, $name)

Passes if server banner matches against I<REGEX>.

=cut

sub banner_like {
    my ($self, $qr, $name) = @_;
    my $tb = __PACKAGE__->builder();

    $tb->like($self->banner(), $qr, $name);
}

=item banner_unlike(qr/REGEX/, $name)

Passes if server banner doesn't match against I<REGEX>.

=cut

sub banner_unlike {
    my ($self, $qr, $name) = @_;
    my $tb = __PACKAGE__->builder();

    $tb->unlike($self->banner(), $qr, $name);
}

=item domain_like(qr/REGEX/, $name)

Passes if server's announced domain matches against I<REGEX>.

=cut

sub domain_like {
    my ($self, $qr, $name) = @_;
    my $tb = __PACKAGE__->builder();

    $tb->like($self->domain(), $qr, $name);
}

=item domain_unlike(qr/REGEX/, $name)

Passes if server's announced domain doesn't match against I<REGEX>.

=cut

sub domain_unlike {
    my ($self, $qr, $name) = @_;
    my $tb = __PACKAGE__->builder();

    $tb->unlike($self->domain(), $qr, $name);
}

=item mail_from_ok($from, $name)

Sends a MAIL FROM: I<from> to the server. Passes if the command succeeds

=cut

sub mail_from_ok {
    my ($self, $from, $name) = @_;
    my $tb = __PACKAGE__->builder();

    if ($self->mail_from($from)) {
        $tb->ok(1, $name);
    } else {
        $tb->ok(0, $name);
        $self->_smtp_diag;
    }
}

=item mail_from_ko($from, $name)

Sends a MAIL FROM: I<from> to the server. Passes if the command isn't successful

=cut

sub mail_from_ko {
    my ($self, $from, $name) = @_;
    my $tb = __PACKAGE__->builder();

    if (not $self->mail_from($from)) {
        $tb->ok(1, $name);
    } else {
        $tb->ok(0, $name);
        $self->_smtp_diag;
    }
}

=item rcpt_to_ok($to, $name)

Sends a RCPT TO: I<to> to the server. Passes if the command succeeds

=cut

sub rcpt_to_ok {
    my ($self, $to, $name) = @_;
    my $tb = __PACKAGE__->builder();

    if ($self->rcpt_to($to)) {
        $tb->ok(1, $name);
    } else {
        $tb->ok(0, $name);
        $self->_smtp_diag;
    }
}

=item rcpt_to_ko($to, $name)

Sends a RCPT TO: I<to> to the server. Passes if the command isn't successful

=cut

sub rcpt_to_ko {
    my ($self, $to, $name) = @_;
    my $tb = __PACKAGE__->builder();

    if (not $self->rcpt_to($to)) {
        $tb->ok(1, $name);
    } else {
        $tb->ok(0, $name);
        $self->_smtp_diag;
    }
}

=item data_ok($name)

Sends a DATA command to the server. Passes if the command is successful. After calling this method,
you should call datasend.

=cut

sub data_ok {
    my ($self, $name) = @_;
    my $tb = __PACKAGE__->builder();

    if ($self->data == 1){
        $tb->ok(1, $name);
    } else {
        $tb->ok(0, $name);
        $self->_smtp_diag;
    }
}

=item data_ko($name)

Sends a DATA command to the server. Passes if the command is'nt successful

=cut

sub data_ko {
    my ($self, $name) = @_;
    my $tb = __PACKAGE__->builder();

    if ($self->data != 1){
        $tb->ok(1, $name);
    } else {
        $tb->ok(0, $name);
        $self->_smtp_diag;
    }
}

#sub datasend {
#    my ($self, $data) = @_;
#
#    if (ref($data) eq 'ARRAY'){
#        $self::SUPER->datasend($data);
#    }
#}

=item dataend_ok($name)

Sends a .<CR><LF> command to the server. Passes if the command is successful.

=cut

sub dataend_ok {
    my ($self, $name) = @_;
    my $tb = __PACKAGE__->builder();

    if ($self->dataend() == 1){
        $tb->ok(1, $name);
    } else {
        $tb->ok(0, $name);
        $self->_smtp_diag();
    }
}

=item dataend_ko($name)

Sends a .<CR><LF> command to the server. Passes if the command is not successful.

=cut

sub dataend_ko {
    my ($self, $name) = @_;
    my $tb = __PACKAGE__->builder();

    if ($self->dataend() != 1){
        $tb->ok(1, $name);
    } else {
        $tb->ok(0, $name);
        $self->_smtp_diag();
    }
}

=item help_like([HELP_ON], qr/REGEX/, $name)

Sends HELP I<HELP_ON> command to the server. If the returned text matches I<REGEX>, the test passes. To test
plain HELP command, pass undef in HELP_ON.

=cut

sub help_like {
    my ($self, $help_on, $expected, $name) = @_;
    my $tb = __PACKAGE__->builder();

    $tb->like($self->help($help_on), $expected, $name);
}

=item help_unlike([HELP_ON], qr/REGEX/, $name)

Sends HELP I<HELP_ON> command to the server. If the returned text doesn't match I<REGEX>, the test
passes. To test plain HELP command, pass undef in HELP_ON.

=cut

sub help_unlike {
    my ($self, $help_on, $expected, $name) = @_;
    my $tb = __PACKAGE__->builder();

    $tb->unlike($self->help($help_on), $expected, $name);
}

=item quit_ok($name)

Send a QUIT command to the server. Pass if command was successful

=cut

sub quit_ok {
    my ($self, $name) = @_;
    my $tb = __PACKAGE__->builder();
    $self->quit();
    if (_is_between($self->code(), 200, 399)){
        $tb->ok(1, $name);
    } else {
        $tb->ok(0, $name);
        $self->_smtp_diag;
    }
}

=item quit_ko($name)

Send a QUIT command to the server. Pass if command was'nt successful

=cut

sub quit_ko {
    my ($self, $name) = @_;
    my $tb = __PACKAGE__->builder();
    $self->quit();
    if (_is_between($self->code(), 200, 399)){
        $tb->ok(0, $name);
        $self->_smtp_diag;
    } else {
        $tb->ok(1, $name);
    }
}

sub _is_between {
    my ($what, $start, $end) = @_;
    return ($what >= $start and $what <= $end);
}

sub _smtp_diag {
    my $self = shift;
    my $tb = __PACKAGE__->builder();
    $tb->diag(sprintf("  Got from server %s %s\n", $self->code, $self->message));
}

=back

=head1 NON TEST METHODS

=over 4

=item mail_from($from)

Issues a MAIL FROM: I<from> command to the server.

=cut

sub mail_from {
   return shift->command("MAIL", "FROM:", @_)->response() == Net::Cmd::CMD_OK
}

=item rcpt_to($to)

Issues a RCPT TO: I<to> command to the server.

=cut

sub rcpt_to {
   return shift->command("RCPT", "TO:", @_)->response() == Net::Cmd::CMD_OK
}

=back

=head1 AUTHOR

    Jose Luis Martinez
    CAPSiDE
    jlmartinez@capside.com
    http://www.pplusdomain.net/
    http://www.capside.com/

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=cut


1;

