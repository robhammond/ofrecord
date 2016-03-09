#!/usr/bin/env perl
use strict;
use warnings;
use Modern::Perl;
use File::Slurp;
use Mojo::DOM;
use Digest::MD5 qw(md5_hex);
use Search::Elasticsearch;
use Data::Dumper;

my $es = Search::Elasticsearch->new(
    nodes      => '127.0.0.1:9200'
);

my $file = 'wikipedia-commons.xml';

my $fh = read_file($file);
say "file read!";
my $dom = Mojo::DOM->new($fh);

my @members;

for my $person ($dom->find('personinfo')->each) {

	my $id = $person->{'id'};
	# delete $person->{'id'};

	my $wikipedia_url = $person->{'wikipedia_url'};

	say $wikipedia_url;
	
	$es->update(
		index => 'ofrecord',
		type => 'person',
		id => md5_hex($id),
		body => {
			doc => {
				wikipedia_url => $wikipedia_url
			}
		}
	);
}
