package ProjectEuler::Homepage;
use Mojo::Base "Mojolicious::Controller";
use Readonly;
use List::Util qw( first max );
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
            my $key     = $answer->{ $number }{result} ? "passage" : "failure";
            $problem->{ $key } //= [ ];
            push @{ $problem->{ $key } }, $team->{name};
            $problem->{tried}++;
        }
    }

    my $page = Data::Page->new( scalar( @problems ), $COLS_PER_ROW, 1 );
    my @rows = map {
        $page->current_page( $_ );
        [ $page->splice( \@problems ) ];
    } ( $page->first_page .. $page->last_page );

    my $problem_count = Data::Problem->new->collection->count;

    foreach my $team ( @teams ) {
        my %count = ( all => $problem_count );
        $count{passage} = grep { $_->{result} } values %{ $team->{answer} || { } };
        $count{failure} = grep { exists $_->{result} && !$_->{result} } values %{ $team->{answer} || { } };
        $count{left} = $count{all} - $count{passage} - $count{failure};
        $team->{count} = \%count;
    }

    my $max_solved_count = max(
        map { $_->{count}{passage} + $_->{count}{failure} } @teams,
    );

    foreach my $team ( @teams ) {
        my $count = $team->{count};
        my %percentage = (
            passage => int( $count->{passage} / $max_solved_count * 100 ),
            failure => int( $count->{failure} / $max_solved_count * 100 ),
        );
        $team->{percentage} = \%percentage;
    }

    $self->stash(
        rows  => \@rows,
        teams => \@teams,
    );
    $self->render( template => "homepage/index" );
}

1;
