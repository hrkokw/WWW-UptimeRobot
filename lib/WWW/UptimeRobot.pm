package WWW::UptimeRobot;

use Moo;

use LWP::UserAgent;
use JSON;
use URI;
use Params::Validate qw( validate );
use Try::Tiny;

use Data::Dumper qw( Dumper ); 
use Carp;

use strict;
use warnings;


=head1 NAME

WWW::UptimeRobot - Inteface to API service at WWW::UptimeRobot

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

#
# accessors/attributes
#

has hostname => ( 
    is      => 'rw',
    default => 'api.uptimerobot.com'
);

has https    => ( is => 'rw', default => 1 );
has api_key  => ( is => 'rw', required => 1 );
has format   => ( is => 'ro', default => 'json' ); 

has debug_level => ( is => 'rw', default => sub { return 0 } );

has ua       => ( 
    is  => 'lazy',
    isa => sub { 
        die "Incorrect 'ua' format" unless ref $_[0] && $_[0]->isa('LWP::UserAgent')
    },
    builder => 1
);

has json  => ( is => 'lazy' );

has request  => ( is => 'rw' );
has response => ( is => 'rw' );
has error    => ( is => 'rw' );

#
# builders
#

sub _build_ua {
    LWP::UserAgent->new(
        agent       => __PACKAGE__ . "/$VERSION"
    );
}

sub _build_json {
    # utf8?
    JSON->new;
}

# 
# methods
# 

sub _send_request {
    my $self = shift;
    my %p    = validate @_, { 
        method => 1,
        params => 0, # hashref
    };

    my $uri = $self->_build_request_uri;

    $uri->query_form(
        apiKey         => $self->api_key,
        format         => $self->format,
        noJsonCallback => 1,
        ( exists $p{params} ? %{ $p{params} } : () )
    );

    $uri->path( $p{method} );

    return $self->_parse_response( $self->ua->get( $uri ) );
}

sub _parse_response {
    my $self = shift;
    my $resp = shift;

    croak "Failed to received response from server"
        unless $resp;
    
    $self->debug( "Received response: " . $resp->content );    
    
    # server level error
    if ( !$resp->is_success ) {
        croak "Received network level error from server: " . $resp->status_line;
    }

    # not crazy about this
    try {
        $self->response( $self->json->decode( $resp->content ) );
    }
    catch {
        # flag error here or throw below? 
        $self->error( "Unable to parse JSON response: $_" );
        #print STDERR "Unable to parse JSON response: $_\n";
    };

    croak "Failed to receive or parse data in response"
        unless $self->response;

    # service level error
    if ( !$self->response->{stat} || $self->response->{stat} !~ /^ok$/i ) {
        # decode response error if there
        croak "Error in API level request: " . ( $self->response->{message} || "Unknown" );
    }
    
    return $self->response;
}

# not crazy about this, consider moving this into an accessor
sub _build_request_uri {
    my $self = shift;

    # this feels wrong
    return URI->new(
        sprintf( "%s://%s", 
            ( $self->https ? 'https' : 'http' ),
            $self->hostname
        )
    ); 
}

sub debug {
    my $self = shift;

    return unless $self->debug_level > 1;

    print STDERR @_, "\n";
}

# 
# api methods
#
sub get_monitors {
    my $self = shift;

    $self->_send_request( method => 'getMonitors', params => { @_ } );
}

sub get_alert_contacts {
    shift->_send_request( method => 'getAlertContacts' );
}

1; # End of WWW::UptimeRobot

__END__

=head1 SYNOPSIS

Quick summary of what the module does.

    use WWW::UptimeRobot;

    my $robot = WWW::UptimeRobot->new( api_key => 'magic-key' );
    my $resp = $robot->get_monitors;

    # don't ask me on the format
    if ( $resp->{monitors} && $resp->{monitors}->{monitor} ) {
        my $monitors = $resp->{monitors}->{monitor};

        foreach my $monitor ( @$monitors ) {
            print "name: ", $monitor->{friendlyname}, ", url: ", $monitor->{url}, "\n";
        }
    }

=head1 METHODS

=head2 new 

=over

=item * api_key  - api key from uptime robot (required)

=item * hostname - hostname of uptime robot service (default: )

=item * ua - custom user agent

=back 

=head1 API METHODS

The following are methods that correspond to Uptime Robot's API methods.

=head2 get_monitors 

Retrieves all monitors for current account: L<http://www.uptimerobot.com/api.asp#getMonitors>

=head2 get_alert_contacts

Retrieves all alert contacts including status

=head1 Utility Methods 

The following are methods used for various purposes

=head2 monitor_type(id)

Decodes 'id' into value

=head2 others to come....


=head1 AUTHOR

Lee Carmichael, C<< <lee at leecarmichael.com> >>

=head1 BUGS

Please report any bugs or feature requests to GITHUB

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::UptimeRobot

You can also look for information at:

=over 4

=item * Github Issue Tracker

L<https://github.com/lecar-red/WWW-UptimeRobot/issues>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-UptimeRobot>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-UptimeRobot>

=item * Search CPAN

L<http://metacpan.org/dist/WWW-UptimeRobot/>

=back

=head1 SEE ALSO

C<LWP::UserAgent>, C<Moo>

=head1 ACKNOWLEDGEMENTS

Uptime Robot for nice service!

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Lee Carmichael.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

