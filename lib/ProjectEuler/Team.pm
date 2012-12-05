package ProjectEuler::Team;
use Mojo::Base "Mojolicious::Controller";
use Data::Session;
use Data::Team;

sub index {
    my $self = shift;
    $self->render( template => "team/index" );
}

sub record {
    my $self = shift;
    my $name = $self->stash( "name" );
    $self->stash( team => Data::Team->new->collection->find_one( { name => $name } ) );
    $self->render( template => "team/record" );
}

sub join {
    my $self    = shift;
    my $name    = $self->stash( "name" );
    my $digest  = Data::Session->get_digest( $name );
    my $cookie  = $self->signed_cookie( d => $digest, { path => q{/} } );
    my $session = { digest => $digest, team => $name };
    Data::Session->new->collection->update(
        { digest => $digest },
        $session,
        { upsert => 1 },
    );
    $self->stash( team => Data::Session->get_team( $session ) );
    $self->render( template => "team/join" );
}

1;
