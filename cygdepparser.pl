#!perl

use strict;
use warnings;
use English;

my $infilename;

if (@ARGV) {
    $infilename = shift;
}
elsif (-e 'input.txt') {
    $infilename = 'input.txt';
}
else {
    die "You don't give me an argument, you don't have the decency to place" .
        "an input.txt in my folder...\nWhat exactly do you expect me to do?\n";
}

open my $infile, '<', $infilename;
local $INPUT_RECORD_SEPARATOR;
my $content = <$infile>;

# Split the contents (delimited by double \n) into individual pkg dependencies
my @pkg_deps = split(/\n\s*\n/, $content);
for my $pkg_dep (@pkg_deps) {
    $pkg_dep =~ s/\t/    /g;           #tab creates weirdness in printing
    my @lines = split(/\n/, $pkg_dep);
    @lines == 3 or die 'Expected only 3 lines per pkg dependency info, got '
                        . scalar(@lines) .  ". Something's wonky\n";

    my ($pkg_name, $pkg_desc, $pkg_requires) = @lines;
    $pkg_requires =~ s/^\s+Required by: //;
    my @requires = split(/, /, $pkg_requires);

    print "$pkg_name requires @requires\n";
}

