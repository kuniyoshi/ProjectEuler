package Mojolicious::Plugin::Session;
use Mojo::Base "Mojolicious::Plugin";

sub register {
    my( $self, $app, $db ) = @_;
    return $db->collection( "session" );
}

1;
