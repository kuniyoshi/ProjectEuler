package Mojolicious::Plugin::Db;
use Mojo::Base "Mojolicious::Plugin";
use Data;

sub register {
    my( $self, $app, $conf ) = @_;

    my $db = Data->new(
        host     => $conf->{host},
        port     => $conf->{port},
        database => $conf->{database},
    );

    return $db;
}

1;
