package OfRecord::Controller::Trends;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Log;
use Search::Query;
use DateTime;
use List::Util qw( max min );
use Data::Printer;
use Data::Dumper;

my $log = Mojo::Log->new;

sub home {
    my $self = shift;
    
    my $es = $self->es;
    my $q = $self->param('q');

    my $interval = $self->param('interval') || 'day';

    # can use "extended bounds" to change range of dates as per below url:
    # http://seanmcgary.com/posts/elasticsearch-date-histogram-aggregation---filling-in-the-empty-buckets
    my $from = $self->param('from') || DateTime->now()->subtract(years => 1)->ymd;
    my $to = $self->param('to') || DateTime->now()->ymd;

    my $filters = [
        {
            range => {
                date => {
                    gte => $from,
                    lte => $to,
                }
            }
        }
    ];

    if ($self->param('person_id')) {
        # push @$filters, { term => { 'person_id' => $self->param('person_id') } };
    }
    my $q1 = { match_all => {} };

    if ($self->param('q')) {
        my $field = $self->param('field');
        if (!$field) {
            $field = 'speech';
        }
        $q1 = { 
            query_string => {
                default_field => $field,
                query => $self->param('q'),
                default_operator => 'AND', 
            } 
        };
    }
    
    my $query = { 
        filtered => {
            query => $q1,
            filter => {
                bool => {
                    must => $filters,
                }
            }
        }
    };
    # if ($q) {
    #   $query = {match_phrase => { body_text => $q }};
    # }
    my $d_format = 'yyyy-MM-dd';
    if ($interval eq 'hour') {
        $d_format = "date_time_no_millis";
    }

    my $res = $es->search(
        index => 'ofrecord',
        type => 'hansard',
        body => {
            query => $query,
            aggs => {
                speeches_over_time => {
                    date_histogram => {
                        field => 'date',
                        interval => $interval,
                        format => $d_format,
                        min_doc_count => 0,
                    },
                    aggs => {
                        avg_words => {
                            avg => {
                                field => 'word_count'
                            }
                        },
                    }
                },
            }
        },
        size => 0,
    );

    $log->info(Dumper($res));
    my $buckets = $res->{'aggregations'}->{'speeches_over_time'}->{'buckets'};
    my ($series, $axis);
    for my $b (@$buckets) {
        push @$series, $b->{'doc_count'};
        push @$axis, $b->{'key_as_string'};
    }

    $self->render( 
        axis => $axis, 
        series => $series, 
        res => $res,
        from => $from,
        to => $to,
        params => $self->req->params->to_string,
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