#!/usr/bin/env perl
use strict;
use Search::Elasticsearch;

my $es = Search::Elasticsearch->new(
    nodes      => '127.0.0.1:9200'
);

my $index_name = 'hansard';

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

my $streams = $es->indices->put_mapping(
    index => $index_name,
 	type => 'item',
    body  => {
    	item => {
	        properties => {
	        	source_url => {
					type => "multi_field",
					fields => {
						url => {
							type => "string",
							index => "not_analyzed",
						},
						searchable => {
							type => "string",
							index => "analyzed",
							analyzer => "url_analyzer",
						},
					}
				},
	        	title => {
	        		type => 'string',
	        		fields => {
    					length => {
    						type => 'token_count',
    						analyzer => 'standard'
    					}
    				}
	        	},
	        	headline => { # this should really be a multi-field with an untouched version
	        		type => 'string',
	        		fields => {
    					length => {
    						type => 'token_count',
    						analyzer => 'standard'
    					}
    				}
	        	},
	        	article_id => {
	        		type => 'string',
	        		index => 'not_analyzed'
	        	},
	        	source => {
	        		type => 'string',
	        		index => 'not_analyzed'
	        	},
	        	word_count => {
	        		# can be done by ES
	        		type => 'long'
	        	},
	        	author => {
					type => "multi_field",
					fields => {
						author => {
							type => "string",
							index => "analyzed",
							analyzer => "english",
						},
						untouched => {
							type => "string",
							index => "not_analyzed",
						},
					}
				},
				text => {
					type => "string",
					index => "analyzed",
					index_options => "offsets",
					analyzer => "english",
					fields => {
    					length => {
    						type => 'token_count',
    						analyzer => 'english'
    					}
    				},
				},
				date => {
					type => "date",
				},
				epoch => {
					type => "long"
				},
				alchemy_entities => {
					type => "nested",
					properties => {
						response => {
							type => 'string',
							index => 'not_analyzed'
						},
						text => {
							type => 'string',
							index => 'not_analyzed'
						},
						type => {
							type => 'string',
							index => 'not_analyzed'
						},
						relevance => {
							type => 'float'
						},
						count => {
							type => 'long'
						},
						disambiguated => {
							type => 'nested',
							properties => {
								yago => {
									type => 'string',
									index => 'not_analyzed'
								},
								freebase => {
									type => 'string',
									index => 'not_analyzed'
								},
								dbpedia => {
									type => 'string',
									index => 'not_analyzed'
								},
								name => {
									type => 'string'
								},
								website => {
									type => 'string',
									index => 'not_analyzed'
								},
								subType => {
									type => 'string',
									index => 'not_analyzed'
								},
								crunchbase => {
									type => 'string',
									index => 'not_analyzed'
								},
								umbel => {
									type => 'string',
									index => 'not_analyzed'
								},
								ciaFactbook => {
									type => 'string',
									index => 'not_analyzed'
								},
								census => {
									type => 'string',
									index => 'not_analyzed'
								},
								musicBrainz => {
									type => 'string',
									index => 'not_analyzed'
								},
								geo => {
									type => 'geo_point',
									fielddata => {
										format => 'compressed',
										precision => '1cm'
									}
								},
								geonames => {
									type => 'string',
									index => 'not_analyzed'
								},
							}
						}
					}
				}
    		},
    	}
    }
);

my $tweets = $es->indices->put_mapping(
    index => $index_name,
 	type => 'tweet',
    body  => {
    	tweet => {
	        properties => {
	        	favorites => {
	        		type => 'long',
	        	},
	        	created_at => {
	        		type => 'date',
	        	},
	        	tweet_id => {
	        		type => 'long',
	        	},
	        	url => {
	        		type => 'string'
	        	},
	        	retweets => {
	        		type => 'long'
	        	},
	        	screen_name => {
	        		type => 'string'
	        	},
	        	updated => {
					type => "date",
				},
				status_text => {
    				type => 'string',
    				fields => {
    					length => {
    						type => 'token_count',
    						analyzer => 'standard'
    					}
    				}
				},
				hashtags => {
    				type => 'nested',
    				properties => {
    					text => {
    						type => 'string'
    					}
    				}
				},
				article_id => {
	        		type => 'string',
	        		index => 'not_analyzed'
	        	},
    		},
    	}
    }
);

my $fb = $es->indices->put_mapping(
    index => $index_name,
 	type => 'facebook_post',
    body  => {
    	facebook_post => {
	        properties => {
	        	post_id => {
    				type => 'string'
    			},
    			shares => {
    				type => 'long'
    			},
    			created_at => {
    				type => 'date'
    			},
    			updated_at => {
    				type => 'date'
    			},
    			message => {
    				type => 'string',
    				fields => {
    					length => {
    						type => 'token_count',
    						analyzer => 'standard'
    					}
    				}
    			},
    			etag => {
    				type => 'string',
    				index => 'not_analyzed'
    			},
    			link => {
    				type => 'string',
    				index => 'not_analyzed'
    			},
    			article_id => {
    				type => 'string',
    				index => 'not_analyzed'
    			},
    			from_name => {
    				type => 'string',
    				index => 'not_analyzed'
    			},
    			from_id => {
    				type => 'long'
    			},
    		},
    	}
    }
);

