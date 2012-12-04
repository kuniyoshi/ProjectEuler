#!/usr/bin/perl
use 5.10.0;
use utf8;
use strict;
use warnings;
use open qw( :utf8 :std );
use Data::Dumper;
use Encode qw( decode );
use Mojo::URL;
use Mojo::UserAgent;
use MongoDB;

my $client = MongoDB::MongoClient->new( host => "localhost", port => 27017 );
my $database = $client->get_database( "problem_euler" );
my $collection = $database->get_collection( "problem" );

my $base = Mojo::URL->new(
    "http://odz.sakura.ne.jp/projecteuler/index.php?cmd=read&page=Problem%203",
);
my @urls = map { my $url = $base->clone; $url->query->param( page => "Problem $_" ); $url }
           ( 1 .. 400 );

my $ua = Mojo::UserAgent->new(
    agent => "problemfetcher",
);

my $dagger = chr 8224;

foreach my $url ( @urls ) {
    say $url;
    my $dom = $ua->get( $url )->res->dom;
    my( $title, $body ) = split m{\s*$dagger\s*}, $dom->at( "#body" )->all_text, 2;
    my( $number ) = $title =~ m{(\d+)}
        or die "Could not find problem number from response.";
    $collection->update(
        { number => int( $number ) },
        { number => int( $number ), title => $title, problem => $body, source => "$url" },
        { upsert => 1 },
    );
}

exit;

__END__
