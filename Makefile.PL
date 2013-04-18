use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'WWW::UptimeRobot',
    AUTHOR           => q{Lee Carmichael <lee@leecarmichael.com>},
    VERSION_FROM     => 'lib/WWW/UptimeRobot.pm',
    ABSTRACT_FROM    => 'lib/WWW/UptimeRobot.pm',
    LICENSE          => 'Artistic_2_0',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More'      => 0,
        'Test::Exception' => 0,
        'Test::LWP::UserAgent' => 0,
    },
    PREREQ_PM => {
        'LWP::UserAgent'    => 0,
        'Moo'               => 0,
        'Params::Validate'  => 0,
        'JSON'              => 0,
        'URI'               => 0,
        'Data::Dumper'      => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'WWW-UptimeRobot-*' },
);
