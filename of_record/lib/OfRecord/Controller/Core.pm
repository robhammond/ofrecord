package OfRecord::Controller::Core;
use Mojo::Base 'Mojolicious::Controller';

sub home {
	my $self = shift;

	$self->render( );
}

1;
