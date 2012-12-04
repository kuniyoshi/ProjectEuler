package Data::Base;
use strict;
use warnings;
use MongoDB;

my $client = MongoDB::MongoClient->new();
my $database = $client->get_database( "problem_euler" );
my $collection = $database->get_collection( "problem" );

sub new { bless { }, shift }

sub client {
    my $self = shift;
    return $self->{_client} || MongoDB::MongoClient->new( host => "localhost", port => 27017 );
}

sub database {
    my $self = shift;
    return $self->{_database} || $self->client->get_database( "problem_euler" );
}

1;
