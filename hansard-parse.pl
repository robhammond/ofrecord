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
				say $member;

				my $constituency;
				if ($p->at('member > memberconstituency')) {
					$constituency = $p->at('member > memberconstituency')->text;
				}
				# don't 
				my $membercontribution = $p->at('membercontribution')->text; # not all_text to avoid <col> elements
				$membercontribution =~ s!^: !!;
				$i++;
				say $i;
				# say "says: " . $membercontribution;

				# normalise member??? need to somehow

				$es->index(
					index => 'hansard',
					type => 'debates',
					body => {
						person => $member,
						constituency => $constituency,
						contribution => $membercontribution,
						hansard_reference => $id,
						hansard_file => $file,
						date => $date,
					}
				);
			}
		}
	}
}

