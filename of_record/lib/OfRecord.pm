package OfRecord;
use Mojo::Base 'Mojolicious';
use Search::Elasticsearch;

# This method will run once at server start
sub startup {
	my $self = shift;

	# helper to add commas to numbers
	$self->helper('thousandify' => sub {
		my $self = shift;
		my $number = shift;
		return unless $number;
		$number =~ s/(\d{1,3}?)(?=(\d{3})+$)/$1,/g;
		return "$number";
	});

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

	$r->get('/people')->to('people#home');
	$r->get('/people/edit')->to('people#edit_people');
	$r->get('/people/search')->to('people#search');
	$r->get('/people/verbosity')->to('people#verbosity');
	$r->get('/person')->to('people#person');
	$r->get('/person/words')->to('people#words');
	$r->get('/person/edit')->to('people#edit_person');
	$r->post('/person/edit')->to('people#save_person');

	$r->get('/trends')->to('trends#home');
}

1;
