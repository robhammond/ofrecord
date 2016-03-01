package OfRecord;
use Mojo::Base 'Mojolicious';
use Search::Elasticsearch;

# This method will run once at server start
sub startup {
	my $self = shift;

	# elasticsearch
	$self->attr( es => sub { 
		Search::Elasticsearch->new(
		    nodes      => '127.0.0.1:9200',
	    );
	});
	$self->helper('es' => sub { shift->app->es });

	# Router
	my $r = $self->routes;

	# Normal route to controller
	$r->get('/')->to('core#home');

	$r->get('/search')->to('search#home');
}

1;
