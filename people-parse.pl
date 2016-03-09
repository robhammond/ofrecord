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

my $file = 'people.json';

my $fh = read_file($file);
say "file read!";
my $json = decode_json($fh);
say "file decoded!";
my $i = 0;
my @members;

for my $person (@{$json->{'persons'}}) {

	my $id = $person->{'id'};
	# delete $person->{'id'};

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
	
	# say Dumper $person;
	say $id . ' ' . $full_name;
	$person->{'person_id'} = $person->{'id'};
	delete $person->{'id'};
	
	$es->index(
		index => 'ofrecord',
		type => 'person',
		id => md5_hex($id),
		body => $person,
	);
}

for my $member (@{$json->{'memberships'}}) {

	my $id = $member->{'id'};
	
	$es->index(
		index => 'ofrecord',
		type => 'member',
		id => md5_hex($id),
		body => $member,
	);
}