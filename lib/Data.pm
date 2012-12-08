package Data;
use strict;
use warnings;
use MongoDB;

sub new {
    my $class = shift;
    my %param = @_;
    my $self  = bless \%param, $class;
    return $self;
}

sub client {
    my $self = shift;
    return $self->{_client} || MongoDB::MongoClient->new(
        host => $self->{host},
        port => $self->{port},
    );
}

sub database {
    my $self = shift;
    return $self->{_database} || $self->client->get_database( $self->{database} );
}

sub collection {
    my $self  = shift;
    my $name  = shift;
    my $class = join q{::}, ref( $self ), ucfirst lc $name;

    eval "require $class"
        or die;

    return $self->database->get_collection( $name );
}

1;
