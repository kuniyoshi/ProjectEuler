package ProjectEuler::Problem;
use autodie qw( open close );
use Mojo::Base "Mojolicious::Controller";
use Readonly;
use File::Temp qw( tempfile );
use Data::Problem;

Readonly my $TEMPLATE => "project_euler_XXXXXX";
Readonly my $TMPDIR   => "/tmp";

sub find_problem {
    my $self    = shift;
    my $number  = shift
        or return;
    my $problem = Data::Problem->new->collection->find_one( { number => int $number } )
        or return;

    return $problem;
}

sub index {
    my $self    = shift;
    my $number  = $self->stash( "number" )
        or return $self->render_not_found;
    my $problem = $self->find_problem( $number )
        or return $self->render_not_found;

    $self->stash( problem => $problem );
    $self->render( template => "problem/index" );
}

sub answer {
    my $self    = shift;
    my $snippet = $self->req->param( "answer" );
    my $number  = $self->req->param( "number" );
    my $problem = $self->find_problem( $number );
    my $does_correct;

    $snippet =~ s{\r\n}{\n}g;

    my( $FH,  $filename ) = tempfile( $TEMPLATE, DIR => $TMPDIR );
warn "filename: $filename";
    print { $FH } $snippet, "\n";
    close $FH;
    system( "chmod", "+x", $filename ) == 0
        or die "Could not chmod +x $filename: $!";
    chomp( my $result = `$filename` );

    if ( $result eq $problem->{answer} ) {
        $does_correct = 1;
    }

    $self->stash(
        problem      => $problem,
        result       => $result,
        does_correct => $does_correct,
    );
    $self->render( template => "problem/answer" );
}

1;
