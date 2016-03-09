#!/usr/bin/env perl
use strict;
use warnings;
use Modern::Perl;
use Mojo::Log;
use Search::Elasticsearch;
use Net::Twitter;
use Scalar::Util 'blessed';
use Date::Manip::Date;
use Data::Dumper;

my $log = Mojo::Log->new;

# twitter API auth data - need to add your own
my $consumer_key    = '';
my $consumer_secret = '';
my $token           = '';
my $token_secret    = '';

# create new Twitter object
my $nt = Net::Twitter->new(
    traits   => [qw/OAuth API::RESTv1_1/],
    consumer_key        => $consumer_key,
    consumer_secret     => $consumer_secret,
    access_token        => $token,
    access_token_secret => $token_secret,
    ssl => 1,
);

my $es = Search::Elasticsearch->new(
    nodes      => '127.0.0.1:9200'
);
my $res = $es->search(
    index => 'ofrecord',
    type => 'person',
    body => {
        query => {
            filtered => {
                filter => {
                    exists => {
                        field => 'twitter_username'
                    }
                }
            }
        }
    }
);

say Dumper $res;

for my $screen_name (@{$res->{'hits'}->{'hits'}}) {

    my $max_id = '469129847919640576'; # a tweet id at the maximum time you want to reach
    my $count = 100;
    until ($count <= 1) {
        last if $max_id < $since_id;

        $log->info($max_id);

        my $r = $nt->user_timeline({ max_id => $max_id, screen_name => $screen_name, count => 100, trim_user => 1 });

        $log->info("getting tweets for $screen_name...");

        $count = scalar @$r;

        for my $tweet (@$r) {

            my $dm = new Date::Manip::Date;
            my $err = $dm->parse($tweet->{'created_at'});
            my $unix = $dm->printf('%s');

            say $screen_name;
            say $text;

            # $es->create(
            #     index => 'twitter',
            #     type => 'tweet',
            #     id => $tweet->{'id'},
            #     ignore => [409],
            #     body => {
            #         orig_created_at => $tweet->{'created_at'},
            #         created_at => $unix,
            #         text => $tweet->{'text'},
            #         screen_name => $screen_name,
            #         tweet_id => $tweet->{'id_str'},
            #         retweet_count => $tweet->{'retweet_count'},
            #         favorite_count => $tweet->{'favorite_count'},
            #         in_reply_to_screen_name => $tweet->{'in_reply_to_screen_name'},
            #         in_reply_to_status_id_str => $tweet->{'in_reply_to_status_id_str'},
            #         geo => $tweet->{'geo'},
            #         entities => $tweet->{'entities'},
            #         from_source => $tweet->{'source'},
            #     }
            # );

            $max_id = $tweet->{'id'};

        }
        sleep(4);
    }
}