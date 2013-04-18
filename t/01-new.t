#!perl -T

use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

BEGIN {
    plan tests => 2;

    use_ok( 'WWW::UptimeRobot' ) || print "Bail out!\n";
}

{
    my $robot;

    $robot = eval { WWW::UptimeRobot->new };

    ok $@, "missing required parameters";
}

done_testing();
