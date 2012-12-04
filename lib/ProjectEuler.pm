package ProjectEuler;
use Mojo::Base "Mojolicious";

sub startup {
    my $self = shift;
    my $r    = $self->routes;

    $r->get( q{/} )->to( "homepage#index" );
    $r->get( "/problem/:number" )->to( "problem#index" );
    $r->post( "/problem/answer" )->to( "problem#answer" );
}

1;
