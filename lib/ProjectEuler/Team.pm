package ProjectEuler::Team;
use Mojo::Base "Mojolicious::Controller";
use Data::Session;
use Data::Team;
use Data::Problem;

sub index {
    my $self = shift;
    $self->render( template => "team/index" );
}

sub record {
    my $self       = shift;
    my $name       = $self->stash( "name" );
    my $team       = Data::Team->new->collection->find_one( { name => $name } );
    my $collection = Data::Problem->new->collection;
    my %count;
    my @problems;

    if ( $team ) {

        foreach my $number ( keys %{ $team->{answer} } ) {
            my $answer  = $team->{answer}{ $number };
            my $problem = $collection->find_one( { number => int $number } );
            $problem->{result} = $answer->{result};
            $problem->{snippet} = $answer->{snippet};
            push @problems, $problem;
        }
    }

    @problems = sort { $a->{number} <=> $b->{number} } @problems;
    $count{passage} = grep { $_->{result} } @problems;
    $count{failure} = grep { exists $_->{result} && !$_->{result} } @problems;
    $count{left}    = $collection->count - $count{passage} - $count{failure};

    $self->stash(
        team     => $team,
        count    => \%count,
        problems => \@problems,
    );
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
    return $self->redirect_to( q{/} );
#$self->render( template => "team/join" );
}

1;
