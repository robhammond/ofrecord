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

my $file = 'scrapedxml/debates/debates2011-04-27f.xml';

my $xml = read_file($file);

my $dom = Mojo::DOM->new($xml);
my $i = 0;
my @members;

for my $speech ($dom->find('speech')->each) {
	# ignore motions
	next if ($speech->{'pwmotiontext'});
	# ignore nospeaker
	next if ($speech->{'nospeaker'});
	# extract date
	# debates2011-04-27f.xml

	my $speech_id = $speech->{'id'};
	my $speaker_id = $speech->{'speakerid'};
	my $speaker_name = $speech->{'speakername'};
	my $col_num = $speech->{'colnum'};
	my $time = $speech->{'time'};
	my $url = $speech->{'url'};
	my @hon_friends;
	my @text;
	my $html;
	
	for my $p ($speech->find('p')->each) {
		# skip commentary, ie 'rose'
		# next if (($p->{'class'}) && ($p->{'class'} eq 'italic'));
		my $pid = $p->{'pid'};
		# my $text = $p->all_text;
		# say $speaker_name;
		# say $p->all_text;
		push @text, $p->all_text;
		$html .= "$p ";
		
		if ($p->at('phrase.honfriend')) {
			for my $hf ($p->find('phrase.honfriend')->each) {
				push @hon_friends, {name => $hf->{'name'}, id => $hf->{'id'}};
			}
		}
	}

	say "$speaker_name $url";
	
	
	# $es->index(
	# 	index => 'hansard',
	# 	type => 'debates',
	# 	body => {
	# 		speech_id => $speech_id,
	# 		speaker_id => $speaker_id,
	# 		speaker_name => $speaker_name,
	# 		col_num => $col_num,
	# 		time => $time,
	# 		url => $url,
	# 		date => $date,
	# 	}
	# );
}

