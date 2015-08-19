#!perl

use strict;
use warnings;
use English;

use GraphViz;

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

my $gr = GraphViz->new();

# Split the contents (delimited by double \n) into individual pkg dependencies
my @pkg_deps = split(/\n\s*\n/, $content);
for my $pkg_dep (@pkg_deps) {
    my @lines = split(/\n/, $pkg_dep);
    @lines == 3 or die 'Expected only 3 lines per pkg dependency info, got '
                        . scalar(@lines) .  ". Something's wonky\n";

    my ($pkg_name, $pkg_desc, $pkg_dependants) = @lines;
    
    #remove the version since 'required by' doesn't list it, so we can't use it
    $pkg_name =~ s/\t\(.*\)$//; 

    $pkg_dependants =~ s/^\s+Required by: //;
    my @dependants = split(/, /, $pkg_dependants);

    print "$pkg_name is required by @dependants\n";
    #GraphViz ignores this if node already exists, so no need for check
    $gr->add_node($pkg_name); 
    $gr->add_edge($_) foreach (@dependants);
}

$gr->as_svg('cyg_dependency.svg');

