#use lib "/home/tisdall/MasteringPerlBio/development/lib";

use RebaseDB;

use strict;
use warnings;

# will rebuild database
#my $rebase = RebaseDB->new(bionetfile => 'bionet.212', mysql => 'rebase:localhost');

my $rebase = RebaseDB->new(
    mysql => 'rebase:localhost',
    bionetfile => 'bionet.212'
);

my $enzyme = 'EcoRI';

print "Looking up restriction enzyme $enzyme\n";

my @sites = $rebase->get_recognition_sites($enzyme);
print "Sites are @sites\n";

my @res = $rebase->get_regular_expressions($enzyme);
print "Regular expressions are @res\n";

$enzyme = 'HindIII';

print "Looking up restriction enzyme $enzyme\n";

@sites = $rebase->get_recognition_sites($enzyme);
print "Sites are @sites\n";

@res = $rebase->get_regular_expressions($enzyme);
print "Regular expressions are @res\n";


print "Rebase bionet file is ", $rebase->get_bionetfile, "\n";
