#!/usr/bin/env perl
use strict;
use Search::Elasticsearch;

my $es = Search::Elasticsearch->new(
    nodes      => '127.0.0.1:9200'
);

my $index_name = 'ofrecord';

my $of_record = $es->indices->put_mapping(
    index => $index_name,
 	type => 'hansard',
    body  => {
    	hansard => {
	        properties => {
	            speaker_name => {
	            	type => "multi_field",
					fields => {
						speaker_name => {
							type => "string",
							index => "analyzed",
							analyzer => "english",
						},
						raw => {
							type => "string",
							index => "not_analyzed",
						},
					}
	            },
	            date => {
	            	type => "date",
	            },
	            datetime => {
	            	type => "date",
	            }
	        }
		},
    }
);