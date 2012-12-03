package ProjectEuler;
use Mojo::Base "Mojolicious";

sub startup {
    my $self = shift;
    my $r    = $self->routes;

    $r->get( q{/} )->to( "homepage#index" );
}

1;
