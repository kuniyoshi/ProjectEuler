package ProjectEuler::Homepage;
use Mojo::Base "Mojolicious::Controller";
use Readonly;
use Data::Page;
use Data::Problem;

Readonly my $COLS_PER_ROW => 20;

sub index {
    my $self = shift;
    my @problems = Data::Problem->new->collection->query->sort( { number => 1 } )->all;
    my $page = Data::Page->new( scalar( @problems ), $COLS_PER_ROW, 1 );
    my @rows = map {
        $page->current_page( $_ );
        [ $page->splice( \@problems ) ];
    } $page->first_page .. $page->last_page;
    $self->stash( message => "foobar" );
    $self->stash( rows => \@rows );
    $self->render( template => "homepage/index" );
}

1;
