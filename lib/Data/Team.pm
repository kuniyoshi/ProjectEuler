package Data::Team;
use strict;
use warnings;
use parent "Data";
use List::Util qw( max );

sub set_count {
    my( $teams, $max_count ) = @_;

    foreach my $team ( @{ $teams } ) {
        my $answer = $team->{answer} || { };

        my %count = ( all => $max_count );
        $count{passage} = grep { $_->{result} }
                          values %{ $answer };
        $count{failure} = grep { exists $_->{result} && !$_->{result} }
                          values %{ $answer };
        $count{left}    = $count{all} - $count{passage} - $count{failure};

        $team->{count} = \%count;
    }

    return;
}

sub get_max_solved_count {
    my $teams = shift;
    return max(
        map { $_->{count}{passage} + $_->{count}{failure} } @{ $teams },
    );
}

sub set_percentage {
    my( $teams, $max_solved_count ) = @_;
    $max_solved_count ||= 1;

    foreach my $team ( @{ $teams } ) {
        my $count = $team->{count};
        my %percentage = (
            passage => int( $count->{passage} / $max_solved_count * 100 ),
            failure => int( $count->{failure} / $max_solved_count * 100 ),
        );
        $team->{percentage} = \%percentage;
    }

    return;
}

sub touch {
    my( $collection, $name ) = @_;

    unless ( $collection->find_one( { name => $name } ) ) {
        $collection->insert( { name => $name } );
    }

    return;
}

sub get_problems {
    my( $team, $problem_collection ) = @_;
    my @problems;

    foreach my $number ( keys %{ $team->{answer} || { } } ) {
        my $answer  = $team->{answer}{ $number };
        my $problem = $problem_collection->find_one( { number => int $number } );
        $problem->{result}  = $answer->{result};
        $problem->{snippet} = $answer->{snippet};
        push @problems, $problem;
    }

    @problems = sort { $a->{number} <=> $b->{number} } @problems;

    return \@problems;
}

sub set_answer {
    my( $team, $problem, $snippet, $result )
        = @{ { @_ } }{ qw( team problem snippet does_correct ) };
    @{ $team->{answer}{ $problem->{number} } }{ qw( snippet result ) }
        = ( $snippet, $result );
    return $team;
}

1;
