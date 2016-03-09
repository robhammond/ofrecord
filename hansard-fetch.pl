#!/usr/bin/env perl
use strict;
use warnings;
use Modern::Perl;
use Mojo::UserAgent;

# loop through all 424 zip files
for (my $i = 1; $i <= 424; $i++) {
	# filename needs 4 trailing zeroes
	my $num = sprintf("%04d", $i);
	# specify URL, with relevant number
	my $url = 'http://www.hansard-archive.parliament.uk/The_Official_Report,_House_of_Commons_(6th_Series)_Vol_1_(March_1981)_to_2004/S6CV' . $num . 'P2.zip';
	# create a new 'browser'
	my $ua = Mojo::UserAgent->new;
	# (optional) tell the website we're a real browser
	$ua->transactor->name('Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.86 Safari/537.36');
	# fetch the URL
	my $tx = $ua->get($url);
	# if the response isn't an error
	if ($tx->success) {
		# copy the result's content to a local location
		$tx->res->content->asset->move_to('archive-' . $num . 'P2' . '.zip');
	}
	# pause the program for 0.7 seconds
	sleep(0.7);
}