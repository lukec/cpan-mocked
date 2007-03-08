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

my @to_delete;
sub write_module {
    my $module = shift;
    for my $mod_ref (@_) {
        my $file = $mod_ref->{file};
        my $version = $mod_ref->{version};
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
