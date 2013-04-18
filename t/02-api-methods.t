#!perl 

use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Exception;
use Test::LWP::UserAgent;
use WWW::UptimeRobot;
use JSON;

use Data::Dumper qw( Dumper );

BEGIN {
    plan tests => 5;

    use_ok( 'WWW::UptimeRobot' ) || print "Bail out!\n";
}

{
    my $host    = 'api.fakerobot.com';
    my $test_ua = create_lwp_tester();
    my $robot;

    lives_ok { 
        $robot = WWW::UptimeRobot->new(
            api_key  => 'notvalid',
            https    => 0,
            ua       => $test_ua,
            hostname => $host
        )
    } 'new';

    my $resp;
    
    throws_ok { $resp = $robot->get_monitors; } 
        qr/Error in API level request: apiKey/, 'api key error';

    #
    # make good call
    #

    # some pretend key
    $robot->api_key('valid');

    lives_ok { $resp = $robot->get_monitors } 'get_monitors';

    is_deeply $resp->{monitors}, mock_monitors_data(), 'monitors return data';

}


done_testing();

# create useragent to handling mapping calls
sub create_lwp_tester {
    my $ua = Test::LWP::UserAgent->new;

    # might be best to use host parameter to set this up
    $ua->map_response(
        qr{http://api\.fakerobot\.com/getMonitors},

        # kind of feels like this should be somewhere where 
        # i can pass in each type of mock return data
        sub {
            my $req   = shift;
            my %param = $req->uri->query_form;
            my $body  = {};

            $body = check_key( $param{apiKey} );

            return http_response( $body )
                if $body->{stat} eq 'error';

            $body->{monitors} = mock_monitors_data(); 

            return HTTP::Response->new(
                '200', 'OK', [ 'Content-Type' => 'text/html' ],
                to_json $body
            );
        }
    );

    return $ua;
}

sub check_key {
    my $k = shift;

    return ( 
        $k && $k eq 'valid' ? 
            { stat => 'ok' } :
            # fake out bad response
            { 
                stat    => 'error',
                id      => 101,
                message => 'apiKey is wrong'
            }
    );
}

sub http_response {
    my $body = shift || {};
    
    return HTTP::Response->new( 
        '200', 'OK', [ 'Content-Type' => 'text/html' ],
        to_json $body
    );
}

sub mock_monitors_data {
    return {
        'monitor' => [
            {
                'keywordvalue' => '',
                'keywordtype' => '0',
                'status' => '2',
                'httpusername' => '',
                'alltimeuptimeratio' => '99.9',
                'port' => '',
                'friendlyname' => 'leecarmichael.com',
                'subtype' => '',
                'httppassword' => '',
                'url' => 'http://www.leecarmichael.com',
                'id' => '1',
                'type' => '1'
            },
            {
                'keywordvalue' => '',
                'keywordtype' => '0',
                'status' => '2',
                'httpusername' => '',
                'alltimeuptimeratio' => '99.9',
                'port' => '',
                'friendlyname' => 'perl.org',
                'subtype' => '',
                'httppassword' => '',
                'url' => 'http://www.perl.org',
                'id' => '11662',
                'type' => '2'
            },
        ] 
    };
}
