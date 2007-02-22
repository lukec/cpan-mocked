package mocked;
use strict;
use warnings;

=head1 NAME

mocked - use mocked libraries in unit tests

=head1 SYNOPSIS

  # use a fake LWP::Simple for testing from t/lib/LWP/Simple.pm
  use mocked 'LWP::Simple';
  my $text = get($url);

=head1 DESCRIPTION

Often during unit testing, you may find the need to use mocked libraries
to test edge cases, or prevent unit tests from using slow or external
code.

This is where mocking libraries can help.

When you mock a library, you are creating a fake one that will be used
in place of the real one.  The code can do as much or as little as is
needed.

Use mocked.pm as a safety measure (be sure you're actually using the
mocked module), and as a way to document the tests for future
maintainers.

=cut

our $VERSION = '0.02';

=head1 FUNCTIONS

=head2 import

This function will make sure the module you specify is loaded from t/lib.

=cut

sub import {
    my $class = shift;
    my $module = shift;

    my $mock_path = 't/lib';
    my @old_inc = @INC;
    @INC = ($mock_path);
    eval "require $module";
    @INC = @old_inc;
    die if $@;

    my $import = $module->can('import');
    @_ = ($module, @_);
    goto &$import if $import;
}

=head1 AUTHOR

Luke Closs, C<< <cpan at 5thplane.com> >>

=head1 MAD CREDS TO

Ingy döt ne, for only.pm

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
