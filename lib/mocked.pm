package mocked;
use strict;
use warnings;

our $VERSION = '0.01';

sub import {
    my $class = shift;
    my $module = shift;

    my $mock_path = 't/lib';
    unshift @INC, $mock_path;
    eval "require $module";
    shift @INC;
    die if $@;

    my $import = $module->can('import');
    @_ = ($module, @_);
    goto &$import if $import;
}

1;
