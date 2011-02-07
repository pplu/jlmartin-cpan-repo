package DBIx::Class::InflateColumn::Serializer::JSON;

=head1 NAME

DBIx::Class::InflateColumn::Serializer::JSON - JSON Inflator

=head1 SYNOPSIS

  package MySchema::Table;
  use base 'DBIx::Class';

  __PACKAGE__->load_components('InflateColumn::Serializer', 'Core');
  __PACKAGE__->add_columns(
    'data_column' => {
      'data_type' => 'VARCHAR',
      'size'      => 255,
      'serializer_class'   => 'JSON'
    }
  );

Then in your code...

  my $struct = { 'I' => { 'am' => 'a struct' };
  $obj->data_column($struct);
  $obj->update;

And you can recover your data structure with:

  my $obj = ...->find(...);
  my $struct = $obj->data_column;

The data structures you assign to "data_column" will be saved in the database in JSON format.

=cut

use strict;
use warnings;
use JSON::Any;
use Carp;

=over 4

=item get_freezer

Called by DBIx::Class::InflateColumn::Serializer to get the routine that serializes
the data passed to it. Returns a coderef.

=cut

sub get_freezer{
  my ($class, $column, $info, $args) = @_;

  if (defined $info->{'size'}){
      my $size = $info->{'size'};
      return sub {
        my $s = JSON::Any->to_json(shift);
        croak "serialization too big" if (length($s) > $size);
        return $s;
      };
  } else {
      return sub {
        return JSON::Any->to_json(shift);
      };
  }
}

=item get_unfreezer

Called by DBIx::Class::InflateColumn::Serializer to get the routine that deserializes
the data stored in the column. Returns a coderef.

=cut

sub get_unfreezer {
  return sub {
    return JSON::Any->from_json(shift);
  };
}


1;
