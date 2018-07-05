#use lib "/home/tisdall/MasteringPerlBio/development/lib";

use Restrictionmap;
use Rebase;
use SeqFileIO;

use strict;
use warnings;

my $rebase = Rebase->new(
							dbmfile => 'BIONET',
							bionetfile => 'bionet.212',
							mode => '0666',
						);

my $restrict = Restrictionmap->new(
									rebase => $rebase,
									enzyme => 'EcoRI HindIII',  # GAATTC # AAGCTT
									sequence => 'ACGAATTCCGGAATTCG',
									graphictype => 'text',
								);

print "Locations are ", join ' ', $restrict->get_enzyme_map('EcoRI'), "\n";

print $restrict->get_graphic;

## Some bigger sequence

my $biggerseq = SeqFileIO->new;
$biggerseq->read(filename => 'map.fasta');
#$biggerseq->read(filename => 'sampleecori.dna');

my $restrict2 = Restrictionmap->new(
										rebase => $rebase,
										enzyme => 'EcoRI HindIII',  # GAATTC # AAGCTT
										sequence => $biggerseq->get_sequence,
										graphictype => 'text',
									);

print "\nHere is the map of the bigger sequence:\n\n";

print $restrict2->get_graphic;
