package t::TestUtils;
use strict;
use warnings;
use File::Path qw/mkpath rmtree/;
use base 'Exporter';

our @EXPORT_OK = qw/write_module/;

write_module(
    'Foo::Bar',
    { file => "lib/Foo/Bar.pm",   version => '0.01' },
    { file => "t/lib/Foo/Bar.pm", version => 'Mocked' },
);
write_module(
    'Foo::Moose',
    { file => "lib/Foo/Moose.pm",   version => '0.01' },
    { file => "t/lib/Foo/Moose.pm", version => 'Mocked' },
);
write_module(
    'Foo::Baz',
    { file => "lib/Foo/Baz.pm",   version => '0.01' },
    { file => "t/ERK/Foo/Baz.pm", version => 'Mocked' },
);
write_module(
    'Foo::PreLoaded',
    { file => "lib/Foo/PreLoaded.pm",   version => '0.01' },
    { file => "t/lib/Foo/PreLoaded.pm", version => 'Mocked' },
);

# Create a module that uses URI.pm
my $unmocked_code = <<'EOT';
use unmocked 'URI';

sub foo {
    my $u = URI->new('http://awesnob.com');
    return $u->host;
}
EOT
write_module(
    'Foo::UsingUnmocked',
    { file => 'lib/Foo/UsingUnmocked.pm', version => '0.01', 
        extra_code => $unmocked_code },
    { file => 't/lib/Foo/UsingUnmocked.pm', version => 'Mocked', 
        extra_code => $unmocked_code },
);

my $other_file = q{lib/Foo/Other.pm};
write_module(
    'Foo::PreLoaded',
    { file => $other_file,               version => '0.01' },
    { file => "t/lib/Foo/WhatWeWant.pm", version => 'Mocked' },
);
open(my $fh, qq{>>$other_file}) or die "Could not open '$other_file' for append";
print $fh qq{
package Foo::WhatWeWant;

use strict;
use warnings;
use base 'Exporter';
our \@EXPORT_OK = qw(\$awesome);

our \$VERSION = '0.01';
our \$awesome = 'like, totally';

sub module_filename {
  return '$other_file';
}

1;
};
close($fh) or die "Could not close '$other_file' for append";


my @to_delete;
sub write_module {
    my $module = shift;
    for my $mod_ref (@_) {
        my $file = $mod_ref->{file};
        my $version = $mod_ref->{version};
        my $extra_code = $mod_ref->{extra_code} || '';
        (my $d = $file) =~ s#(.+)/.+#$1#;
        unless (-d $d) {
            mkpath $d or die "Can't mkpath $d: $!";
            push @to_delete, $d;
        }
        open(my $fh, ">$file") or die "Can't open $file: $!";
        print $fh <<EOT;
package $module;
use strict;
use warnings;
use base 'Exporter';
our \@EXPORT_OK = qw(\$awesome);

our \$VERSION = '$version';
our \$awesome = 'like, totally';

sub module_filename {
    return '$file';
}

$extra_code

1;
EOT
        close $fh or die "Can't write $file: $!";
        push @to_delete, $file;
    }
}

END {
    for my $f (@to_delete) {
        if (-f $f) {
            unlink $f or die "Can't unlink $f: $!";
        }
        elsif (-d $f) {
            rmtree $f or die "Can't rmtree $f: $!";
        }
    }
}

1;
