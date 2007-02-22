#!/usr/bin/perl
use strict;
use warnings;
use Test::More qw/no_plan/;
use t::TestUtils;

BEGIN { # test setup
    use lib 'lib';
    use mocked 'Foo::Bar' => qw/$awesome/;
    require Foo::Moose;
    import Foo::Moose;
}

Load_mocked_library: {
    is $Foo::Bar::VERSION, 'Mocked', "Mocked module loaded";
    is $awesome, 'like, totally', "We're awesome";
    is Foo::Bar::module_filename(), 't/lib/Foo/Bar.pm';

    is $Foo::Moose::VERSION, '0.01', 'Real moose loaded';
    is Foo::Moose::module_filename(), 'lib/Foo/Moose.pm';
}

