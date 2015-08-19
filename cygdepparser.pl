#!perl
#This Free software is licensed under WTFPL
#Full license text at http://www.wtfpl.net/about/

use strict;
use warnings;
use English;

use GraphViz;

my $infilename;
my $outfilename = 'cyg_dependency.svg';

if (@ARGV) {
    $infilename = shift;
    $outfilename = ($infilename =~ s/(\.txt)?$/.svg/r);
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

my $gr = GraphViz->new(rankdir => 1,    #left-to-right graph arrows
                       epsilon => 0.001, #take your time with layout processing
                       name => 'Cygwin_dependency_graph'); #title, no spaces or dots

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

    #GraphViz ignores this add_node if node already exists, so no need for check
    #And if this node had been previously added with empty tooltip, this call
    #adds tooltip and changes it into a plaintext node. How cool is that!
    $gr->add_node($pkg_name, shape => 'plaintext', tooltip => $pkg_desc);
    foreach (@dependants) {
        $gr->add_node($_, tooltip => ' '); #prevent default tooltip `nodeNN`
        $gr->add_edge($_ => $pkg_name);
    }
}

print "Writing to $outfilename\n";
$gr->as_svg($outfilename);

