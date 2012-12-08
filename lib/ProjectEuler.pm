package ProjectEuler;
use Mojo::Base "Mojolicious";
use Data::Dumper;

sub startup {
    my $self = shift;
    my $r    = $self->routes;

    $self->secret( 'sPPyYKIK6Sogs1A4PMFwSHv2ML9eCIJk' );
    $self->sessions->cookie_name( "d" );

    my $config  = $self->plugin( "Config" );
    my $db      = $self->plugin( "db", { %{ $config->{db} } } );
    my $problem = $self->plugin( "problem", $db );
    my $team    = $self->plugin( "team",    $db );
    my $session = $self->plugin( "session", $db );
    $self->helper( db          => sub { $db      } );
    $self->helper( problem     => sub { $problem } );
    $self->helper( team        => sub { $team    } );
    $self->helper( ext_session => sub { $session } );

    $self->helper(
        dump => sub {
            Data::Dumper->new( [ splice @_, 1 ] )->Terse( 1 )->Indent( 1 )->Sortkeys( 1 )->Dump
        },
    );

    $r->get(  q{/}               )->to( "homepage#index" );
    $r->get(  "/problem/:number" )->to( "problem#index" );
    $r->post( "/problem/answer"  )->to( "problem#answer" );
    $r->get(  "/team/"           )->to( "team#index" );
    $r->get(  "/team/:name"      )->to( "team#record" );
    $r->post( "/team/:name"      )->to( "team#join" );
    $r->get(  "/session"         )->to( "session#index" );
}

1;
