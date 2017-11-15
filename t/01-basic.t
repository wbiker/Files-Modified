use v6.c;
use Test;
use Files::Modified;
use File::Storage;

# Create test directories
mkdir "test";
# touch test files to set a modification time.
update-modification-date();

my $fs = File::Storage.new(storage-config-path-name => "test");
my $fm = Files::Modified.new(
    file-storage => $fs,
    file-extensions => (),
    search-paths => <test>
    );

my @files-found = $fm.get-modified-files();
# check just the file names. No IO::Path object needed.
@files-found = @files-found.map: { .basename };
is @files-found.sort, <programm.groovy data.xml data.doc addresses.xml xml.xml xml.doc>.sort, "Found all files not already stored";

# second test with just groovy files
$fm = Files::Modified.new(
    file-storage => $fs,
    file-extensions => <groovy>,
    search-paths => <test>
    );

# touch test files again.
update-modification-date();

@files-found = $fm.get-modified-files();
# check just the file names. No IO::Path object needed.
@files-found = @files-found.map: { .basename };
is @files-found.sort, <programm.groovy>, "Found all groovy files";

# third test with groovy and xml files.
$fm = Files::Modified.new(
    file-storage => $fs,
    file-extensions => <groovy xml>,
    search-paths => <test>
    );

# touch test files again.
update-modification-date();

@files-found = $fm.get-modified-files();
# check just the file names. No IO::Path object needed.
@files-found = @files-found.map: { .basename };
is @files-found.sort, <programm.groovy data.xml xml.xml addresses.xml>.sort, "Found all groovy and xml files";

# remove test storage file.
$fs.get-storage-file-path().unlink;

# remove test directory
"test".IO.dir.map: { .unlink };
"test".IO.rmdir;

done-testing;

sub update-modification-date() {
    "test/programm.groovy".IO.spurt: "";
    "test/data.xml".IO.spurt: "";
    "test/data.doc".IO.spurt: "";
    "test/addresses.xml".IO.spurt: "";
    "test/xml.xml".IO.spurt: "";
    "test/xml.doc".IO.spurt: "";
}
