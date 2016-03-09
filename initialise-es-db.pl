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
	            speaker_id => {
	            	type => "string",
	            	index => "not_analyzed"
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

$result = $es->indices->put_mapping(
    index => $index_name,
 	type => 'person',
    body  => {
    	person => {
	        properties => {
	            full_name => {
	            	type => "multi_field",
					fields => {
						full_name => {
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
	            person_id => {
	            	type => "string",
	            	index => "not_analyzed"
	            },
	            twitter_username => {
	            	type => "string",
	            	index => "not_analyzed"
	            },
	        }
		},
    }
);

$result = $es->indices->put_mapping(
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
