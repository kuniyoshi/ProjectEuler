package Data::Session;
use strict;
use warnings;
use parent "Data::Base";
use Digest::MD5 qw( md5_hex );
use Data::Team;

sub get_digest { md5_hex( join q{::}, { }, @_ ) }

sub collection {
    my $self = shift;
    return $self->{_collection} || $self->database->get_collection( "session" );
}

sub get_team {
    my $class   = shift;
    my $session = shift;
    my $team    =  Data::Team->new->collection->find_one( { name => $session->{team} } );

    unless ( $team ) {
        $team = { name => $session->{team} };
        Data::Team->new->collection->insert( $team );
    }

    return $team;
}

1;
