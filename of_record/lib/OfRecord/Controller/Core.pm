package OfRecord::Controller::Core;
use Mojo::Base 'Mojolicious::Controller';

sub home {
	my $self = shift;

	my $es = $self->es;
	my $mps = $es->search(
		index => 'ofrecord',
		type => 'hansard',
		body => {
			# query => $query,
			aggs => {
				names => {
					terms => {
						field => 'speaker_name.raw',
						size => 0
					}
				}
			},
		}
	);

	$self->render( mps => $mps );
}

1;
