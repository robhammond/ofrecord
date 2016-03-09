# README #

Of Record is a system for storing and analysing what our elected officials say, to help understand why they might say it

Requirements:

For basic scraping, you need to install Perl and Mojolicious.

Install Perl on:

- Windows: http://learn.perl.org/installing/windows.html
- Mac OSX: http://learn.perl.org/installing/osx.html

Install Mojolicious: http://mojolicious.org

# Running the website #
To run the website you'll need to install [Elasticsearch](https://www.elastic.co/products/elasticsearch)

Then run `initialise-es-db.pl` to set the mappings.

Then run `people-parse.pl` to parse the 'people.json' file from TheyWorkForYou

Then run `people-add-twitter-profiles.pl` to parse the 'twitter.xml' file from TheyWorkForYou

Then run `people-add-wikipedia-profiles.pl` to parse the 'wikipedia-commons.xml' file from TheyWorkForYou