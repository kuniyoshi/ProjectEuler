package ProjectEuler::Adm::Problem;
use Mojo::Base "Mojolicious::Controller";

sub index {
    my $self = shift;
    my @problems = $self->problem->query->sort( { number => 1 } )->all;

    $self->stash(
        problems => \@problems,
    );
    $self->render( template => "adm/problem/index" );
}

sub view {
    my $self   = shift;
    my $number = $self->stash( "number" );
    my $problem = $self->problem->find_one( { number => int $number } )
        or return $self->render_not_found;

    $self->stash( problem => $problem );
    $self->render( template => "adm/problem/view" );
}

sub edit {
    my $self    = shift;
    my $number  = $self->stash( "number" );
    my $problem = $self->problem->find_one( { number => int $number } )
        or return $self->render_not_found;
    my $title   = $self->req->param( "title" );
    my $text    = $self->req->param( "problem" );
    my $answer  = $self->req->param( "answer" );

    $self->problem->update(
        { number => $problem->{number} },
        {
            %{ $problem },
            title   => $title,
            problem => $text,
            answer  => $answer,
        },
    );

    return $self->redirect_to( $self->url_for( "current", number => q{} ) );
}

1;
