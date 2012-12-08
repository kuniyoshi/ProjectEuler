#!/usr/bin/perl
use 5.10.0;
use utf8;
use strict;
use warnings;
use open qw( :utf8 :std );
use Data::Dumper;
use Path::Class qw( file );
use MongoDB;

chomp( my @lines = <> );

my $client = MongoDB::MongoClient->new( host => "localhost", port => 27017 );
my $database = $client->get_database( "project_euler" );
my $collection = $database->get_collection( "problem" );

foreach my $line ( @lines ) {
    last
        if $line eq "__END__";

    my( $number, $answer ) = split m{[.]\s*}, $line, 2;

    next
        unless $number;
    next
        if $number > 400;

    my $problem = $collection->find_one( { number => $number } )
        or die "find({number: $number})";

    $problem->{answer} = $answer;

    $collection->update( { number => $number }, $problem );
}

exit;

