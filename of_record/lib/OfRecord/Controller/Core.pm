package OfRecord::Controller::Core;
use Mojo::Base 'Mojolicious::Controller';

sub home {
	my $self = shift;

	my $es = $self->es;
	my $mps = $es->search(
		index => 'ofrecord',
		type => 'person',
		body => {
			# query => $query,
			aggs => {
				names => {
					terms => {
						field => 'full_name.raw',
						size => 0
					}
				}
			},
		}
	);

	$self->render( mps => $mps );
}

1;
