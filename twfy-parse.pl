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

my $file = 'scrapedxml/debates/debates2011-04-28a.xml';

my $xml = read_file($file);

my $dom = Mojo::DOM->new($xml);
my $i = 0;
my @members;

for my $speech ($dom->find('speech')->each) {

	my $speech_id = $speech->{'id'};
	my $speaker_id = $speech->{'speakerid'};
	my $speaker_name = $speech->{'speakername'};
	my $col_num = $speech->{'colnum'};
	my $time = $speech->{'time'};
	my $url = $speech->{'url'};
	
	for my $p ($speech->find('p')->each) {
		my $pid = $p->{'pid'};
		my $text = $p->all_text;
		my @hon_friends;
		if ($p->at('phrase.honfriend')) {
			for my $hf ($p->find('phrase.honfriend')->each) {
				push @hon_friends, {name => $hf->{'name'}, id => $hf->{'id'}};
			}
		}

		# $es->index(
		# 	index => 'hansard',
		# 	type => 'debates',
		# 	body => {
		# 		speaker_id => $speaker_id,
		# 		speaker_name => $speaker_name,
		# 		speech => $speech,
		# 		hansard_reference => $id,
		# 		hansard_file => $file,
		# 		date => $date,
		# 	}
		# );
		}
	}
}

