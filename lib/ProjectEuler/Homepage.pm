package ProjectEuler::Homepage;
use Mojo::Base "Mojolicious::Controller";
use Readonly;
use List::Util qw( first );
use Data::Page;
use Data::Problem;
use Data::Team;

Readonly my $COLS_PER_ROW => 20;

sub index {
    my $self     = shift;
    my @problems = Data::Problem->new->collection->query->sort( { number => 1 } )->all;
    my @teams    = Data::Team->new->collection->query->sort( { name => 1 } )->all;

    foreach my $team ( @teams ) {
        my $answer = $team->{answer}
            or next;

        foreach my $number ( keys %{ $answer } ) {
            my $problem = first { $_->{number} == $number } @problems;
            $problem->{team}{ $team->{name} } = $answer->{ $number }{result};
        }
    }

    my $page = Data::Page->new( scalar( @problems ), $COLS_PER_ROW, 1 );
    my @rows = map {
        $page->current_page( $_ );
        [ $page->splice( \@problems ) ];
    } ( $page->first_page .. $page->last_page );

    $self->stash( message => "foobar" );
    $self->stash( rows => \@rows );
    $self->render( template => "homepage/index" );
}

1;
