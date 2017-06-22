package OfRecord::Common;
use Mojo::Base 'Mojolicious::Plugin';

use Net::IP::Match::Regexp qw( create_iprange_regexp match_ip );
use Mojo::URL;
use Mojo::Util qw(url_escape);
use Data::Validate::Domain;
use Data::Validate::IP;
use List::Util qw( max min );
use POSIX qw( ceil );

sub register {
	my ($self, $app) = @_;

	# Controller alias helpers
	for my $name (qw(paginate)) {
		$app->helper($name => sub { shift->$name(@_) });
	}

	$app->helper(paginate  => \&paginate);
}

sub new {
    my $class = shift;
    my $self = { @_ };
    
    bless ($self, $class);

    return $self;
}

# core functions
sub paginate {
    my ($self, $data) = @_;
    my ($paging_info);
    if ( $data->{'total_hits'} == 0 ) {
        # Alert the user that their search failed.
        $paging_info = '';
    } else {

        # Calculate the nums for the first and last hit to display.
        my $last_result = min( ( $data->{'offset'} + $data->{'num'} ), $data->{'total_hits'} );
        my $first_result = min( ( $data->{'offset'} + 1 ), $last_result );

        # Calculate first and last hits pages to display / link to.
        my $current_page = int( $first_result / $data->{'num'} ) + 1;
        my $last_page    = ceil( $data->{'total_hits'} / $data->{'num'} );
        my $first_page   = max( 1, ( $current_page - 9 ) );
        $last_page = min( $last_page, ( $current_page + 10 ) );

        ########################################
        # loop thru hash ref to add params
        ########################################
        my $i = 0;
        while (my ($key, $value) = each(%{$data->{'params'}})) {
            my $sep;
            if ($i == 0) { $sep = '?' } else { $sep = '&'}
            $data->{'path'} .= "$sep$key=" . url_escape $value;
            $i++;
        }

        if ($data->{'offset'} == 0) {
            my $sep = '?';
            if ($data->{'path'} =~ m{\?}) { $sep = '&' }
            $data->{'path'} .= $sep . "offset=0";
        }

        # Generate the "Prev" link.
        if ( $current_page > 1 ) {
            my $new_offset = ( $current_page - 2 ) * $data->{'num'};
            $data->{'path'} =~ s/(?<=offset=)\d+/$new_offset/;
            $paging_info .= qq|<li><a href="$data->{path}">Prev</a></li>|;
        }

        # Generate paging links.
        for my $page_num ( $first_page .. $last_page ) {
            # say "Page num: $page_num";
            if ( $page_num == $current_page ) {
                $paging_info .= qq|<li class="active"><a href="">$page_num</a></li> |;
            } else {
                my $new_offset = ( $page_num - 1 ) * $data->{'num'};
                $data->{'path'} =~ s/(?<=offset=)\d+/$new_offset/;
                $paging_info .= qq|<li><a href="$data->{path}">$page_num</a></li>|;
            }
        }

        # Generate the "Next" link.
        if ( $current_page != $last_page ) {
            my $new_offset = $current_page * $data->{'num'};
            $data->{'path'} =~ s/(?<=offset=)\d+/$new_offset/;
            $paging_info .= qq|<li><a href="$data->{path}">Next</a></li>|;
        }

    }

    return $paging_info;
}

1;