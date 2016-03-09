#!/usr/bin/env perl
use strict;
use warnings;
use Modern::Perl;
use File::Slurp;
use Mojo::DOM;
use Data::Dumper;

# work with a single sample file
my $file = 'S6CV0001P0.xml';
# read XML file into a variable
my $xml = read_file($file);
# Convert XML into a DOM (Document Object Model), i.e. a list of objects
my $dom = Mojo::DOM->new($xml);
# loop through each object called 'housecommons'
for my $day ($dom->find('housecommons')->each) {
	# get the date & print out result
	my $date = $day->at('date')->{'format'};
	say $date;
	
	# loop through each debate
	for my $debates ($day->find('debates')->each) {
		# loop through each paragraph
		for my $p ($debates->find('p')->each) {
			# record paragraph id data
			my $id = $p->{'id'};
			# if the paragraph contains a member name
			if ($p->at('member')) {
				# record member name
				my $member = $p->at('member')->text;
				say $member;
				# record the constituency, if it exists
				my $constituency;
				if ($p->at('member > memberconstituency')) {
					$constituency = $p->at('member > memberconstituency')->text;
				}
				# record actual speech
				my $membercontribution = $p->at('membercontribution')->text; # not all_text to avoid <col> elements
				# remove leading ': ' on each contribution
				$membercontribution =~ s!^: !!;
				say $membercontribution;
			}
		}
	}
}