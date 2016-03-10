#!/usr/bin/env perl
use strict;
use warnings;
use Modern::Perl;
use Digest::MD5 qw(md5_hex);
use File::Slurp;
use Mojo::DOM;
use Search::Elasticsearch;
use DateTime::Format::ISO8601;
use Lingua::StanfordCoreNLP;
use Data::Dumper;

$ENV{'LINGUA_CORENLP_JAR_PATH'} = '/Users/robhammond/stanford-corenlp-full-2015-12-09';
$ENV{'LINGUA_CORENLP_VERSION'} = '3.6.0';

my $es = Search::Elasticsearch->new(
    nodes      => '127.0.0.1:9200'
);

my $res = $es->search(
	index => 'ofrecord',
	type => 'hansard',
	body => {
		query => {
			filtered => {
				filter => {
					range => {
						word_count => {
							gte => 500
						}
					}
				}
			}
		}
	}
);

# say $res->{'hits'}->{'hits'}->[0]->{'_source'}->{'speech'};
# die;


# Create a new NLP pipeline (make corefs bidirectional)
my $pipeline = new Lingua::StanfordCoreNLP::Pipeline(1);
 
# Get annotator properties:
my $props = $pipeline->getProperties();
 
# These are the default annotator properties:
$props->put('annotators', 'tokenize, ssplit, pos, lemma, ner, parse');
 
# Update properties:
$pipeline->setProperties($props);
 
# Process text
# (Will output lots of debug info from the Java classes to STDERR.)
my $result = $pipeline->process(
   $res->{'hits'}->{'hits'}->[1]->{'_source'}->{'speech'}
);
 
my @seen_corefs;
 
# Print results
for my $sentence (@{$result->toArray}) {
   print "\n[Sentence ID: ", $sentence->getIDString, "]:\n";
   print "Original sentence:\n\t", $sentence->getSentence, "\n";
 
   print "Tagged text:\n";
   for my $token (@{$sentence->getTokens->toArray}) {
      # printf "\t%s/%s/%s [%s]\n",
      #        $token->getWord,
      #        $token->getPOSTag,
      #        $token->getNERTag,
      #        $token->getLemma;
      say $token->getWord .' - '. $token->getNERTag;
   }
 
   # print "Dependencies:\n";
   # for my $dep (@{$sentence->getDependencies->toArray}) {
   #    printf "\t%s(%s-%d, %s-%d) [%s]\n",
   #           $dep->getRelation,
   #           $dep->getGovernor->getWord,
   #           $dep->getGovernorIndex,
   #           $dep->getDependent->getWord,
   #           $dep->getDependentIndex,
   #           $dep->getLongRelation;
   # }
 
   # print "Coreferences:\n";
   # for my $coref (@{$sentence->getCoreferences->toArray}) {
   #    printf "\t%s [%d, %d] <=> %s [%d, %d]\n",
   #           $coref->getSourceToken->getWord,
   #           $coref->getSourceSentence,
   #           $coref->getSourceHead,
   #           $coref->getTargetToken->getWord,
   #           $coref->getTargetSentence,
   #           $coref->getTargetHead;
 
   #    print "\t\t(Duplicate)\n"
   #       if(grep { $_->equals($coref) } @seen_corefs);
 
   #    push @seen_corefs, $coref;
   # }
}