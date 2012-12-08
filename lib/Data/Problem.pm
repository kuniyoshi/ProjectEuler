package Data::Problem;
use strict;
use warnings;
use parent "Data";
use List::Util qw( first );

sub set_team_state {
    my( $problems, $teams ) = @_;

    foreach my $team ( @{ $teams } ) {
        my $answer = $team->{answer}
            or next;

        foreach my $number ( keys %{ $answer } ) {
            my $problem = first { $_->{number} == $number } @{ $problems };
            my $key     = $answer->{ $number }{result} ? "passage" : "failure";
            $problem->{ $key } //= [ ];
            push @{ $problem->{ $key } }, $team->{name};
            $problem->{tried}++;
        }
    }

    return;
}

1;
