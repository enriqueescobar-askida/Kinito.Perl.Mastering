use strict;
use warnings;

#use lib "/home/tisdall/MasteringPerlBio/development/lib";

use Geneticcode1;

my $dna = 'AACCTTCCTTCCGGAAGAGAG';

# Initialize variables
my $protein = '';

# Translate each three-base codon to an amino acid, and append to a protein 
for(my $i=0; $i < (length($dna) - 2) ; $i += 3)
{
	$protein .= Geneticcode1::codon2aa( substr($dna,$i,3) );
}

print $protein, "\n";
