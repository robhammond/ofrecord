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
	        	speech => {
	        		type => "text",
					index => "analyzed",
					analyzer => "english", # removes stopwords etc
        		},
	            speaker_name => {
	            	type => "text",
					fields => {
						raw => {
							type => "keyword",
						},
					}
	            },
	            member_id => {
	            	type => "keyword",
            	},
            	person_id => {
	            	type => "keyword",
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
	            	type => "text",
					fields => {
						raw => {
							type => "keyword",
						},
					}
	            },
	            person_id => {
	            	type => "keyword",
	            },
	            # identifiers => {
	            # 	type => 'nested',
	            # 	properties => {
	            # 		identifier => {
	            # 			type => 'keyword'
	            # 		}
	            # 	}
	            # },
	            twitter_username => {
	            	type => "keyword",
	            },
	            wikipedia_url => {
	            	type => "keyword",
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
	            	type => "keyword",
	            },
	            end_date => {
	            	type => "date"
	            },
	            start_date => {
	            	type => "date"
	            },
	            end_reason => {
	            	type => "keyword",
	            },
	            member_id => {
	            	type => "keyword",
	            },
	            post_id => {
	            	type => "keyword",
	            },
	            on_behalf_of_id => {
	            	type => "keyword",
	            },
	        }
		},
    }
);
