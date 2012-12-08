package Data::Session;
use strict;
use warnings;
use parent "Data";
use Digest::SHA qw( sha1_base64 );
use Data::Team;

sub get_digest { sha1_base64( join q{::}, { }, @_ ) }

sub get_team {
    my( $session, $team_collection ) = @_;

    my $team = $team_collection->find_one( { name => $session->{team} } );
    return $team
        if $team;

    $team = { name => $session->{team} };
    $team_collection->insert( $team );

    return $team;
}

1;
