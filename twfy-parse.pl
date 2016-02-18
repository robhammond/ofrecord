#!/usr/bin/env perl
use strict;
use warnings;
use Modern::Perl;
use File::Slurp;
use Mojo::DOM;
use Search::Elasticsearch;
use Data::Dumper;

my $es = Search::Elasticsearch->new(
    nodes      => '127.0.0.1:9200'
);

my $file = 'S6CV0001P0.xml';

my $xml = read_file($file);

my $dom = Mojo::DOM->new($xml);
my $i = 0;
my @members;

for my $day ($dom->find('housecommons')->each) {

	my $date = $day->at('date')->{'format'};
	say $date;
	
	# say Dumper $cont;
	for my $debates ($day->find('debates')->each) {
		
		for my $p ($debates->find('p')->each) {
			# record paragraph id data
			my $id = $p->{'id'};

			if ($p->at('member')) {
				my $member = $p->at('member')->text;

				# regex for name formats
				# 
				my ($fn, $ln, $title, $salut);
				if ($member =~ m{^(Mrs?\.|Miss|Sir) ([-a-zA-Z']+) ([-a-zA-Z']+)$}) { # full name - also needs something like ( [A-Z]\.)+? to capture middle names
					$fn = $2;
					$ln = $3;
					say "1: $fn $ln";
					push @members, "$fn $ln";
				} elsif ($member =~ m{^(Mrs?\.|Miss|Sir|The) (.*?) \((Mrs?\.|Miss|Sir) ([-a-zA-Z']+) ([-a-zA-Z']+)\)$}) { # title & name
					$fn = $4;
					$ln = $5;
					say "2: $fn $ln";
					push @members, "$fn $ln";
				} elsif ($member =~ m{^(Mrs?\.|Miss|Sir) ([-a-zA-Z.']+) ?([-a-zA-Z.']+)?$}) { # abbreviated name
					say "3: $2";
				} else {
					say "Other: $member";
				}

				# names are too inconsistent, so let's try using/training Google's knowledge graph API to find the right person
				# https://developers.google.com/apis-explorer/#p/kgsearch/v1/kgsearch.entities.search?indent=true&prefix=true&query=James+A.+Dunn&types=Person&_h=3&
				# type = person
				# description = politician
				# or
				# https://en.wikipedia.org/wiki/List_of_United_Kingdom_MPs#Lists_by_general_election
				# https://en.wikipedia.org/wiki/List_of_MPs_elected_in_the_United_Kingdom_general_election,_1979
				
				
				# say $member;

				my $constituency;
				if ($p->at('member > memberconstituency')) {
					$constituency = $p->at('member > memberconstituency')->text;
					# say $constituency;
					# if constituency exists, must be the first mention of said MP
					# thus..
					# insert logic here to transform name to shortcut?
				}

				# then try & coerce name into full name & id

				# actual speech
				my $membercontribution = $p->at('membercontribution')->text; # not all_text to avoid <col> elements
				$membercontribution =~ s!^: !!;
				$i++;
				# say $i;
				# say "says: " . $membercontribution;

				# normalise member??? need to somehow

				# $es->index(
				# 	index => 'hansard',
				# 	type => 'debates',
				# 	body => {
				# 		person => $member,
				# 		constituency => $constituency,
				# 		contribution => $membercontribution,
				# 		hansard_reference => $id,
				# 		hansard_file => $file,
				# 		date => $date,
				# 	}
				# );
			}
		}
	}
}

