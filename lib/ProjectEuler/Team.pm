package ProjectEuler::Team;
use Mojo::Base "Mojolicious::Controller";
use Data::Session;
use Data::Team;

sub index {
    my $self  = shift;
    my @teams = $self->team->query->sort( { name => 1 } )->all;

    $self->stash( teams => \@teams );
    $self->render( template => "team/index" );
}

sub join {
    my $self   = shift;
    my $name   = $self->stash( "name" );
    my $digest = Data::Session::get_digest( $name );

    Data::Team::touch( $self->team, $name );

    $self->session( digest => $digest );
    $self->ext_session->update(
        { digest => $digest },
        {
            digest => $digest,
            team   => $name,
        },
        { upsert => 1 },
    );

    return $self->redirect_to( q{/} );
}

sub record {
    my $self = shift;
    my $name = $self->stash( "name" );
    my $team = $self->team->find_one( { name => $name } )
        or return $self->render_not_found;

    my $problems = Data::Team::get_problems( $team, $self->problem );

    my %count;
    $count{passage} = grep { $_->{result} } @{ $problems };
    $count{failure} = grep { exists $_->{result} && !$_->{result} } @{ $problems };
    $count{left}    = $self->problem->count - $count{passage} - $count{failure};

    $self->stash(
        team     => $team,
        count    => \%count,
        problems => $problems,
    );
    $self->render( template => "team/record" );
}

1;
