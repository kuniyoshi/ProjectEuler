package Data::Problem;
use strict;
use warnings;
use parent "Data::Base";

sub collection {
    my $self = shift;
    return $self->{_collection} || $self->database->get_collection( "problem" );
}

1;
