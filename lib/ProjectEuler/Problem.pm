package ProjectEuler::Problem;
use autodie qw( open close );
use Mojo::Base "Mojolicious::Controller";
use Readonly;
use File::Temp qw( tempfile );
use Data::Session;
use Data::Team;

Readonly my $TEMPLATE => "project_euler_XXXXXX";
Readonly my $TIMEOUT  => 5;

sub index {
    my $self    = shift;
    my $number  = $self->stash( "number" );
    my $problem = $self->problem->find_one( { number => int $number } )
        or return $self->render_not_found;
    my( $team, $result, $snippet, $tried );

    my $prebious_problem = $self->problem->find_one( { number => $number - 1 } );
    my $next_problem     = $self->problem->find_one( { number => $number + 1 } );

    if ( my $session = $self->ext_session->find_one( { digest => $self->session( "digest" ) } ) ) {
        $team    = $self->team->find_one( { name => $session->{team} } );
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
    my $problem = $self->problem->find_one( { number => int $number } )
        or return $self->render_not_found;
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

    $does_correct = $result eq $problem->{answer};

    if ( my $session = $self->ext_session->find_one( { digest => $self->session( "digest" ) } ) ) {
        my $team = $self->team->find_one( { name => $session->{team} } );
        $team = Data::Team::set_answer(
            team         => $team,
            problem      => $problem,
            snippet      => $snippet,
            does_correct => $does_correct,
        );
        $self->team->update(
            { name => $team->{name} },
            $team,
        );
    }

    $self->stash(
        problem      => $problem,
        result       => $result,
        does_correct => $does_correct,
    );
    $self->render( template => "problem/answer" );
}

1;
