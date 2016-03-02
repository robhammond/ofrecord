#!/usr/bin/env perl
use strict;
use warnings;
use Modern::Perl;
use File::Slurp;
use Mojo::DOM;
use Search::Elasticsearch;
use DateTime::Format::ISO8601;
use Data::Dumper;

my $es = Search::Elasticsearch->new(
    nodes      => '127.0.0.1:9200'
);

# my $file = 'scrapedxml/debates/debates2011-04-27f.xml';

opendir my $dir, "./scrapedxml/debates/" or die "Cannot open directory: $!";
my @files = readdir $dir;
closedir $dir;
# my @files = ("debates2011-04-28a.xml");
for my $file (@files) {
	next unless $file =~ m{\.xml};
	next unless $file =~ m{debates(19[89]|2)};
	# extract date
	my ($date) = $file =~ m{debates([0-9]+-[0-9]+-[0-9]+)};# debates2011-04-27f.xml

	my $xml = read_file("./scrapedxml/debates/" . $file);
	say $file;

	my $dom = Mojo::DOM->new($xml);
	my $i = 0;
	my @members;

	for my $speech ($dom->find('speech')->each) {
		# ignore motions
		next if ($speech->{'pwmotiontext'});
		# ignore nospeaker
		next if ($speech->{'nospeaker'});
		# next unless the speech has a speaker
		next unless ($speech->{'speakername'});

		my $speech_id = $speech->{'id'};
		my $speaker_id = $speech->{'speakerid'};
		my $speaker_name = $speech->{'speakername'};
		my $col_num = $speech->{'colnum'};
		my $time = $speech->{'time'};
		my $url = $speech->{'url'};
		my @hon_friends;
		my @text;
		my $html;
		my $word_count = 0;
		
		for my $p ($speech->find('p')->each) {
			# skip commentary, ie 'rose'
			# next if (($p->{'class'}) && ($p->{'class'} eq 'italic'));
			my $pid = $p->{'pid'};
			my $par = $p->all_text;
			# say $speaker_name;
			# say $p->all_text;
			push @text, $par;
			$html .= "$p ";
			
			if ($p->at('phrase.honfriend')) {
				for my $hf ($p->find('phrase.honfriend')->each) {
					push @hon_friends, {name => $hf->{'name'}, id => $hf->{'id'}};
				}
			}
			my $words = $p->all_text;
			my $wc = $words =~ s/((^|\s)\S)/$1/g;
			$word_count += $wc;
		}

		my $all_text = join("\n\n", @text);

		my $data = {
			speech_id => $speech_id,
			speaker_id => $speaker_id,
			speaker_name => $speaker_name,
			col_num => $col_num,
			url => $url,
			date => $date,
			word_count => $word_count,
			speech => $all_text,
			hon_friends => \@hon_friends,
		};

		if ($time) {
			$time =~ s!\d(\d\d)!$1!;
			$time = $date . 'T' . $time . 'Z';
			eval {
			    my $t_date = DateTime::Format::ISO8601->parse_datetime($time);
			};
			if ( $@ ) {
				print "ERROR: date not valid"
			} else {
				$data->{'datetime'} = $time;
			}
		}
		
		$es->index(
			index => 'ofrecord',
			type => 'hansard',
			body => $data,
		);
	}

}