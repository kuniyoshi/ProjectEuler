package Mojolicious::Plugin::Team;
use Mojo::Base "Mojolicious::Plugin";

sub register {
    my( $self, $app, $db ) = @_;
    return $db->collection( "team" );
}

1;
