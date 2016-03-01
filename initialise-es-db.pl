#!/usr/bin/env perl
use strict;
use Search::Elasticsearch;

my $es = Search::Elasticsearch->new(
    nodes      => '127.0.0.1:9200'
);

my $index_name = 'ofrecord';

my $result = $es->indices->create( 
	index => $index_name,
	body => {
		analysis => {
			filter => {
                url_stop  => {
					type      => "stop",
					stopwords => ["http", "https"]
                }
			},
			tokenizer => {
				splitPattern => {
					type => 'pattern',
					pattern => '[-/\._:?,&=|;()]+',
				}
			},
			analyzer => {
				url_analyzer => {

					# First, lowercase everything with the built-in tokenizer
					#
					tokenizer    => 'splitPattern',

					# Then, define our analyzer chain: remove generic stopwords,
					# remove URL specific stopwords, apply our custom ngram filter
					#
					filter       => [
						"url_stop", 
						'lowercase',
					],

					type         => "custom"
				}
			}
		}
	}
);

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
	            }
	        }
		},
    }
);
