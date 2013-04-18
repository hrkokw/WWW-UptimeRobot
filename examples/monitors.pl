#!/usr/bin/perl

use lib qw( ../lib );

use WWW::UptimeRobot;
use Data::Dumper qw( Dumper );

use strict;
use warnings;

#
# main
#

my $key   = shift || die "Missing required api key\n";
my $robot = WWW::UptimeRobot->new( api_key => $key, https => 0 );

print Dumper( $robot->get_monitors );

exit;
