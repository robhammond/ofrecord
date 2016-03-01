#!/usr/bin/env perl
use strict;
use Search::Elasticsearch;

my $es = Search::Elasticsearch->new(
    nodes      => '127.0.0.1:9200'
);

my $index_name = 'ofrecord';

my $of_record = $es->indices->put_mapping(
    index => $index_name,
 	type => 'member',
    body  => {
    	member => {
	        properties => {
	            person_id => {
	            	type => "string",
	            	index => "not_analyzed"
	            },
	            end_date => {
	            	type => "date"
	            },
	            start_date => {
	            	type => "date"
	            },
	            end_reason => {
	            	type => "string",
	            	index => "not_analyzed"
	            },
	            id => {
	            	type => "string",
	            	index => "not_analyzed"
	            },
	            post_id => {
	            	type => "string",
	            	index => "not_analyzed"
	            },
	            on_behalf_of_id => {
	            	type => "string",
	            	index => "not_analyzed"
	            },
	        }
		},
    }
);
