#!/usr/bin/env perl
use strict;
use warnings;
use Modern::Perl;
use Digest::MD5 qw(md5_hex);
use File::Slurp;
use Mojo::DOM;
use Search::Elasticsearch;
use DateTime::Format::ISO8601;
use Data::Dumper;

my $es = Search::Elasticsearch->new(
    nodes      => '127.0.0.1:9200'
);

my $res = $es->search(
	index => 'ofrecord',
	type => 'hansard',
	body => {
		query => {
			match_all => {}
		}
	}
);

