#!/usr/bin/perl
use 5.10.0;
use utf8;
use strict;
use warnings;
use open qw( :utf8 :std );
use Data::Dumper;
use MongoDB;
use Data::Page;

my $client = MongoDB::MongoClient->new( host => "localhost", port => 27017 );
my $database = $client->get_database( "problem_euler" );
my $collection = $database->get_collection( "test" );

my $bar = $collection->find_one( { foo => "bar" } );
say Dumper $bar;

$collection->update(
    { foo => "bar" },
    {
        int( rand 10 ) => 3,
    },
    { upsert => 1 },
);



__END__
my @problems = $collection->query->sort( { number => 1 } )->all;

my $page = Data::Page->new( scalar( @problems ), 10, 1 );

foreach my $i ( $page->first_page .. $page->last_page ) {
    $page->current_page( $i );
    my @list = $page->splice( \@problems );
    say join " - ", map { $_->{number} } @list;
}

__END__
my $id = $collection->insert( { id => 1, foo => "bar" } );
say $id;
say Dumper $id;
my $data = $collection->find_one( { _id => $id } );
say Dumper $data;

exit;

