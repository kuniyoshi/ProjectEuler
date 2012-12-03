package ProjectEuler::Homepage;
use Mojo::Base "Mojolicious::Controller";

sub index {
    my $self = shift;
    $self->stash( message => "foobar" );
    $self->stash( rows_ref => [ [ 1 .. 5 ], [ 6 .. 10 ], [ 11 .. 15 ] ] );
    $self->render( template => "homepage/index" );
}

1;
