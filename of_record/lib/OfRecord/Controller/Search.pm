package OfRecord::Controller::Search;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Log;
use Search::Query;
use List::Util qw( max min );
use Data::Printer;

my $log = Mojo::Log->new;

sub home {
	my $self = shift;
	return $self->render() unless $self->param('q');
	my $es = $self->es;

    my %params;
    
    $params{'q'}      = $self->param('q');
    $params{'offset'} = $self->param('offset') || 0;
    $params{'num'}    = $self->param('num') || 20;
    $params{'export'} = $self->param('export') || 0;
    $params{'type'}   = $self->param('type') || 'article';

    my $parser = Search::Query->parser;
    my $qparse = $parser->parse($params{'q'});

    my (@clauses, @negatives);

    for my $plus ($qparse->{'+'}) {
        if ($plus) {
            push @clauses, _process_query($plus);
        }
    }

    for my $minus ($qparse->{'-'}) {
        if ($minus) {
            push @negatives, _process_query($minus);
        }
    }

    my $bool_query = { bool => {} };
    if (scalar @clauses > 0) {
        $bool_query->{'bool'}->{'must'} = \@clauses;
    }
    if (scalar @negatives > 0) {
        $bool_query->{'bool'}->{'must_not'} = \@negatives;
    }
	
	my $results = $es->search(
        index => 'ofrecord',
        type => 'hansard',
        body  => {
            query => $bool_query,
            highlight => {
                fields => {
                    speech => {fragment_size => 175, type => 'plain'},
                }
            },
            sort => {
                datetime => {order => 'desc'}
            }
        },
        size => $params{'num'},
        from => $params{'offset'},
    );
    # $log->info(p $results);

    my $total_results = $results->{'hits'}->{'total'};

    my $last_result  = min( ( $params{'offset'} + $params{'num'} ), $total_results );
    my $first_result = min( ( $params{'offset'} + 1 ), $last_result );

	$self->render( 
		results => $results->{'hits'}->{'hits'},
		total_results => $total_results,
		first_result => $first_result,
		last_result => $last_result,
        pages => $self->paginate({
            total_hits => $total_results,
            path => $self->req->url->path,
            params => $self->req->params->to_hash,
            num => $params{'num'},
            offset => $params{'offset'},
        }),
	);
}

sub _process_query {
    my $input = shift;

    my @bool_term;
    
    for my $clause (@$input) {

        my $field = $clause->{'field'};
        
        if (!$field) {
            push @bool_term, { 
                multi_match => { 
                    query => $clause->{'value'}, 
                    fields => [
                        'speech', 
                        'speaker_name', 
                    ],
                    # operator => "and",
                    type => 'phrase' 
                }
            };
        } elsif ($field eq 'speaker') {
            push @bool_term, { match => { "speaker_name" => $clause->{'value'} }};
        } elsif ($field =~ m{^word_count_(gt|gte|lt|lte)$}) {
            my $range_type = $1;
            push @bool_term, {
                range => {
                    word_count => {
                        $range_type => $clause->{'value'}
                    }
                }
            };
        } elsif ($field =~ m{^(date)_from$}) {
            my $range_type = $1;
            push @bool_term, {
                range => {
                    $range_type => {
                        gte => $clause->{'value'}
                    }
                }
            };
        } elsif ($field =~ m{^(date)_to$}) {
            my $range_type = $1;
            push @bool_term, {
                range => {
                    $range_type => {
                        lte => $clause->{'value'}
                    }
                }
            };
        } else {
            push @bool_term, { 
                multi_match => { 
                    query => $clause->{'value'}, 
                    fields => [
                        'speech', 
                        'speaker_name', 
                    ],
                    # operator => "and",
                    type => 'phrase' 
                }
            };
        }
    }
    return \@bool_term;
}

1;