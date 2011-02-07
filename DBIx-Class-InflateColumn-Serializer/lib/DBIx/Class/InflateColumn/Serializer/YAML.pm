package DBIx::Class::InflateColumn::Serializer::YAML;

=head1 NAME

DBIx::Class::InflateColumn::Serializer::YAML - YAML Inflator

=head1 SYNOPSIS

  package MySchema::Table;
  use base 'DBIx::Class';

  __PACKAGE__->load_components('InflateColumn::Serializer', 'Core');
  __PACKAGE__->add_columns(
    'data_column' => {
      'data_type' => 'VARCHAR',
      'size'      => 255,
      'serializer_class'   => 'YAML'
    }
  );

Then in your code...

  my $struct = { 'I' => { 'am' => 'a struct' };
  $obj->data_column($struct);
  $obj->update;

And you can recover your data structure with:

  my $obj = ...->find(...);
  my $struct = $obj->data_column;

The data structures you assign to "data_column" will be saved in the database in YAML format.

=cut

use strict;
use warnings;
use YAML;
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
        my $s = YAML::Dump(shift);
        croak "serialization too big" if (length($s) > $size);
        return $s;
      };
  } else {
      return sub {
        return YAML::Dump(shift); 
      };
  }
}

=item get_unfreezer

Called by DBIx::Class::InflateColumn::Serializer to get the routine that deserializes
the data stored in the column. Returns a coderef.

=cut

sub get_unfreezer {
  return sub {
    return YAML::Load(shift);
  };
}


1;
