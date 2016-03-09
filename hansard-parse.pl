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
# name of a list of members
my @members;
# loop through each object called 'housecommons'
for my $day ($dom->find('housecommons')->each) {
	# get the date
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

				# try to understand name
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
				# record the constituency, if it exists
				my $constituency;
				if ($p->at('member > memberconstituency')) {
					$constituency = $p->at('member > memberconstituency')->text;
					# say $constituency;
				}

				# record actual speech
				my $membercontribution = $p->at('membercontribution')->text; # not all_text to avoid <col> elements
				# remove leading ': ' on each contribution
				$membercontribution =~ s!^: !!;
				say "says: " . $membercontribution;
			}
		}
	}
}

