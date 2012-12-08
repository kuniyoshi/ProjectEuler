package ProjectEuler::Homepage;
use Mojo::Base "Mojolicious::Controller";
use Readonly;
use Data::Page;
use Data::Problem;
use Data::Team;

Readonly my $COLS_PER_ROW => 20;

sub index {
    my $self     = shift;
    my @problems = $self->problem->query->sort( { number => 1 } )->all;
    my @teams    = $self->team->query->sort( { name => 1 } )->all;

    Data::Problem::set_team_state( \@problems, \@teams );

    my $page = Data::Page->new( scalar( @problems ), $COLS_PER_ROW, 1 );
    my @rows = map {
        $page->current_page( $_ );
        [ $page->splice( \@problems ) ];
    } ( $page->first_page .. $page->last_page );

    Data::Team::set_count( \@teams, $self->problem->count );
    Data::Team::set_percentage( \@teams, Data::Team::get_max_solved_count( \@teams ) );

    $self->stash(
        rows  => \@rows,
        teams => \@teams,
    );
    $self->render( template => "homepage/index" );
}

1;
