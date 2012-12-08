package Mojolicious::Plugin::Problem;
use Mojo::Base "Mojolicious::Plugin";

sub register {
    my( $self, $app, $db ) = @_;
    return $db->collection( "problem" );
}

1;
