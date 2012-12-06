package ProjectEuler::Problem;
use autodie qw( open close );
use Mojo::Base "Mojolicious::Controller";
use Readonly;
use File::Temp qw( tempfile );
use Data::Problem;
use Data::Session;
use Data::Team;

Readonly my $TEMPLATE => "project_euler_XXXXXX";
Readonly my $TIMEOUT  => 5;

sub find_problem {
    my $self    = shift;
    my $number  = shift
        or return;
    my $problem = Data::Problem->new->collection->find_one( { number => int $number } )
        or return;

    return $problem;
}

sub get_session {
    my $self = shift;
    return Data::Session->new->collection->find_one(
        { digest => $self->signed_cookie( "d" ) },
    );
}

sub index {
    my $self    = shift;
    my $number  = $self->stash( "number" )
        or return $self->render_not_found;
    my $problem = $self->find_problem( $number )
        or return $self->render_not_found;
    my( $team, $result, $snippet, $tried );

    my $prebious_problem = $self->find_problem( $number - 1 );
    my $next_problem     = $self->find_problem( $number + 1 );

    my $session = $self->get_session;

    if ( $session ) {
        $team    = Data::Session->get_team( $session );
        $result  = $team->{answer}{ $problem->{number} }{result};
        $snippet = $team->{answer}{ $problem->{number} }{snippet};
        $tried   = !!$snippet;
    }

    $self->stash(
        prebious_problem => $prebious_problem,
        next_problem     => $next_problem,
        problem          => $problem,
        result           => $result,
        snippet          => $snippet,
        tried            => $tried,
        team             => $team,
    );
    $self->render( template => "problem/index" );
}

sub answer {
    my $self    = shift;
    my $snippet = $self->req->param( "answer" );
    my $number  = $self->req->param( "number" );
    my $problem = $self->find_problem( $number );
    my( $result, $does_correct );

    $snippet =~ s{\r\n}{\n}g;

    eval {
        local $SIG{ALRM} = sub { die "too long.\n" };
        alarm $TIMEOUT;

        my( $FH,  $filename ) = tempfile( $TEMPLATE, TMPDIR => 1, UNLINK => 1 );
        print { $FH } $snippet, "\n";
        close $FH;
        system( "chmod", "+x", $filename ) == 0
            or die "Could not chmod +x $filename: $!";
        chomp( $result = `$filename` );

        alarm 0;
    };

    if ( my $e = $@ ) {
        warn $e;
    }

    if ( $result eq $problem->{answer} ) {
        $does_correct = 1;
    }

    if ( my $session = $self->get_session ) {
        $self->record(
            problem      => $problem,
            snippet      => $snippet,
            does_correct => $does_correct,
            team         => Data::Session->get_team( $session ),
        );
    }

    $self->stash(
        problem      => $problem,
        result       => $result,
        does_correct => $does_correct,
    );
    $self->render( template => "problem/answer" );
}

sub record {
    my $self  = shift;
    my( $problem, $snippet, $result, $team )
        = @{ { @_ } }{ qw( problem snippet does_correct team ) };
    @{ $team->{answer}{ $problem->{number} } }{ qw( snippet result ) }
        = ( $snippet, $result );
    Data::Team->new->collection->update(
        { name => $team->{name} },
        $team,
    );
}

1;
