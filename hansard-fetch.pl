#!/usr/bin/env perl
use strict;
use warnings;
use Modern::Perl;
use Mojo::UserAgent;

# my $first = 'http://www.hansard-archive.parliament.uk/The_Official_Report,_House_of_Commons_(6th_Series)_Vol_1_(March_1981)_to_2004/S6CV0001P0.zip'
# my $last = 'http://www.hansard-archive.parliament.uk/The_Official_Report,_House_of_Commons_(6th_Series)_Vol_1_(March_1981)_to_2004/ S6CV0424P2.zip'
# my $url = 'http://www.hansard-archive.parliament.uk/The_Official_Report,_House_of_Commons_(6th_Series)_Vol_1_(March_1981)_to_2004';

for (my $i = 1; $i <= 424; $i++) {
	my $num = sprintf("%04d", $i);
	# say $num;
	my $url = 'http://www.hansard-archive.parliament.uk/The_Official_Report,_House_of_Commons_(6th_Series)_Vol_1_(March_1981)_to_2004/S6CV' . $num . 'P2.zip';
	my $ua = Mojo::UserAgent->new;
	$ua->transactor->name('Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.86 Safari/537.36');
	my $tx = $ua->get($url);
	if ($tx->success) {
		$tx->res->content->asset->move_to('archive-' . $num . 'P2' . '.zip');
	}
	
	sleep(0.7);
}