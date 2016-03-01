package OfRecord::Controller::People;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Log;
use List::Util qw( max min );
use Digest::MD5 qw(md5_hex);
use Data::Printer;

my $log = Mojo::Log->new;

sub home {
	my $self = shift;
	my $es = $self->es;
	
	my $results = $es->search(
        index => 'ofrecord',
        type => 'person',
        body  => {
            query => {match_all => {}},
        },
        size => 10,
        from => 0,
    );
    # $log->info(p $results);

    my $total_results = $results->{'hits'}->{'total'};

	$self->render( 
		results => $results->{'hits'}->{'hits'},
		total_results => $total_results,
	);
}

sub person {
	my $self = shift;
	return $self->render() unless $self->param('id');
	my $es = $self->es;

    my $id = $self->param('id');
	
	my $results = $es->get(
        index => 'ofrecord',
        type => 'person',
        id => md5_hex($id),
    );
    $log->info(p $results);

	$self->render( 
		# results => $results,
	);
}


1;