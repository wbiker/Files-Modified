use v6.c;
unit class Files::Modified:ver<0.0.1>;

use IO::Prompt;
use File::Storage;

=begin pod

=head1 NAME

Files::Modified - blah blah blah

=head1 SYNOPSIS

  use Files::Modified;

=head1 DESCRIPTION

Files::Modified is ...

=head1 AUTHOR

wbiker <wbiker@gmx.at>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 wbiker

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

has File::Storage $.file-storage is required;
has @.file-extensions;
has @.search-paths is required;

#`(
# compares the modification time of the files from fs and
# config file and saves the names and modification times from the fs
# in the config file.
# )
method get-modified-files() {
    my %file-modified = $!file-storage.load();

    my @all-files;
    for @!search-paths -> $path {
        @all-files.append: find-all-files($path, @!file-extensions);
    }

    my @files-mod;
    for @all-files -> $file-to-check {
        if %file-modified{$file-to-check.path()} {
            if %file-modified{$file-to-check.path()} ne $file-to-check.modified.Num {
                @files-mod.push: $file-to-check;
            }
        }
        else {
            @files-mod.push: $file-to-check;
        }

        %file-modified{$file-to-check.path()} = $file-to-check.modified.Num;
    }

    $!file-storage.save(%file-modified);

    return @files-mod;
}

method update-modification-date() {
    self.get-modified-files();
}

sub find-all-files($path, @file-extensions) {
    unless $path.IO.e {
        warn "$path does not exists.";
        return;
    }

    # if a directory dive in and look for all groovy files
    my @files;
    @files = find-files($path.IO, @file-extensions);

    return @files;
}

#`(
#   looks for all files with certain extension in a path and goes recursive through
#   the sub directories as well
#)
sub find-files(IO::Path $path, @file-extensions) {
    my @test-files;

    if $path.f {
        if $path.basename ~~ / \. @file-extensions $/ {
            @test-files.push: $path;
            return @test-files;
        }
    }

    for $path.IO.dir -> $file {
        if $file.d {
            @test-files.append(find-files($file));
            next;
        }

        if @file-extensions.elems > 0 && $file.basename !~~ / \. @file-extensions $/ {
            next;
        }

        @test-files.push: $file;
    }

    @test-files;
}
