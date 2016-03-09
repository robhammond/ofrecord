#!/usr/bin/env perl
use strict;
use warnings;
use Modern::Perl;
use File::Slurp;
use Mojo::JSON qw(decode_json);
use Digest::MD5 qw(md5_hex);
use Search::Elasticsearch;
use Data::Dumper;

my $es = Search::Elasticsearch->new(
    nodes      => '127.0.0.1:9200'
);

# open file
my $file = 'people.json';
my $fh = read_file($file);
# decode JSON file
my $json = decode_json($fh);

# loop through people
for my $person (@{$json->{'persons'}}) {

	my $id = $person->{'id'};
	# disabmiguate ID type
	$person->{'person_id'} = $id;
	delete $person->{'id'};
	
	# try and get a 'full' name
	my $full_name;
	for my $n (@{$person->{'other_names'}}) {
		if ($n->{'given_name'} && $n->{'family_name'}) {
			$full_name = $n->{'given_name'} . " " . $n->{'family_name'};
			# say $full_name;
			$person->{'full_name'} = $full_name;
		} elsif ($n->{'given_name'} && $n->{'lordname'}) {
			$full_name = $n->{'given_name'} . " " . $n->{'lordname'};
			# say $full_name;
		}
	}
	
	if ($full_name) {
		$person->{'full_name'} = $full_name;
	}
	# insert into search index
	$es->index(
		index => 'ofrecord',
		type => 'person',
		id => md5_hex($id),
		body => $person,
	);
}
# loop through members
for my $member (@{$json->{'memberships'}}) {

	my $id = $member->{'id'};
	# disabmiguate ID type
	$member->{'member_id'} = $id;
	delete $member->{'id'};
	
	$es->index(
		index => 'ofrecord',
		type => 'member',
		id => md5_hex($id),
		body => $member,
	);
}