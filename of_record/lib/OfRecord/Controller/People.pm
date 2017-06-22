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

sub search {
    my $self = shift;
    my $es = $self->es;
    my $q = $self->param('q');
    
    my $results = $es->search(
        index => 'ofrecord',
        type => 'person',
        body  => {
            query => {
                match => {
                    full_name => $q
                }
            },
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

    my $members = $es->search(
        index => 'ofrecord',
        type => 'member',
        body => {
            query => {
                match => {
                    person_id => $id,
                }
            }
        }
    );

	$self->render( 
		res => $results,
        members => $members,
	);
}

sub edit_people {
    my $self = shift;
    
    my $es = $self->es;

    my $results = $es->search(
        index => 'ofrecord',
        type => 'person',
        body => {
            query => {
                match_all => {}
            }
        }
    );

    $self->render( 
        res => $results,
    );
}

sub edit_person {
    my $self = shift;
    return $self->reply->exception("No ID!") unless $self->param('id');
    my $es = $self->es;

    my $id = $self->param('id');

    my $results = $es->get(
        index => 'ofrecord',
        type => 'person',
        id => md5_hex($id),
    );

    my $members = $es->search(
        index => 'ofrecord',
        type => 'member',
        body => {
            query => {
                match => {
                    person_id => $id,
                }
            }
        }
    );

    $self->render( 
        res => $results,
        members => $members,
    );
}

sub save_person {
    my $self = shift;
    return $self->reply->exception("No id!") unless $self->param('id');
    my $es = $self->es;

    my $id = $self->param('id');

    my $results = $es->get(
        index => 'ofrecord',
        type => 'person',
        id => md5_hex($id),
    );

    my $members = $es->search(
        index => 'ofrecord',
        type => 'member',
        body => {
            query => {
                match => {
                    person_id => $id,
                }
            }
        }
    );

    my $res = $es->update(
        index => 'ofrecord',
        type => 'person',
        id => md5_hex($id),
        body => {
            doc => {
                twitter_username => $self->param('twitter'),
                wikipedia_url => $self->param('wikipedia'),
            }
        }
    );

    $self->redirect_to('/');
}

sub words {
    my $self = shift;
    return $self->render() unless $self->param('id');
    my $es = $self->es;

    my $id = $self->param('id');

    my $person = $es->get(
        index => 'ofrecord',
        type => 'person',
        id => md5_hex($id),
    );
    
    my $results = $es->search(
        index => 'ofrecord',
        type => 'hansard',
        body => {
            query => {
                match => {
                    person_id => $id,
                }
            },
            size => 0,
            aggs => {
                words => {
                    significant_terms => {
                        field => 'speech',
                        # size => 500,
                    }
                },
                
            }
        }
    );
    # $log->info(p $results);

    $self->render( 
        res => $results,
        person => $person,
    );
}

sub verbosity {
    my $self = shift;
    my $es = $self->es;
    
    my $results = $es->search(
        index => 'ofrecord',
        type => 'hansard',
        body => {
            # query => {
            #     match => {
            #         speaker_id => $id,
            #     }
            # },
            size => 0,
            aggs => {
                verbosity => {
                    terms => {
                        field => 'person_id',
                        # size => 500,
                    }
                },
                
            }
        }
    );
    $log->info(p $results);

    $self->render( 
        res => $results,
    );
}


1;