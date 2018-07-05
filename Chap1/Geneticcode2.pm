package Geneticcode2;

use strict;
use warnings;

my(%genetic_code) = (
					'TCA' => 'S',    # Serine
					'TCC' => 'S',    # Serine
					'TCG' => 'S',    # Serine
					'TCT' => 'S',    # Serine
					'TTC' => 'F',    # Phenylalanine
					'TTT' => 'F',    # Phenylalanine
					'TTA' => 'L',    # Leucine
					'TTG' => 'L',    # Leucine
					'TAC' => 'Y',    # Tyrosine
					'TAT' => 'Y',    # Tyrosine
					'TAA' => '_',    # Stop
					'TAG' => '_',    # Stop
					'TGC' => 'C',    # Cysteine
					'TGT' => 'C',    # Cysteine
					'TGA' => '_',    # Stop
					'TGG' => 'W',    # Tryptophan
					'CTA' => 'L',    # Leucine
					'CTC' => 'L',    # Leucine
					'CTG' => 'L',    # Leucine
					'CTT' => 'L',    # Leucine
					'CCA' => 'P',    # Proline
					'CCC' => 'P',    # Proline
					'CCG' => 'P',    # Proline
					'CCT' => 'P',    # Proline
					'CAC' => 'H',    # Histidine
					'CAT' => 'H',    # Histidine
					'CAA' => 'Q',    # Glutamine
					'CAG' => 'Q',    # Glutamine
					'CGA' => 'R',    # Arginine
					'CGC' => 'R',    # Arginine
					'CGG' => 'R',    # Arginine
					'CGT' => 'R',    # Arginine
					'ATA' => 'I',    # Isoleucine
					'ATC' => 'I',    # Isoleucine
					'ATT' => 'I',    # Isoleucine
					'ATG' => 'M',    # Methionine
					'ACA' => 'T',    # Threonine
					'ACC' => 'T',    # Threonine
					'ACG' => 'T',    # Threonine
					'ACT' => 'T',    # Threonine
					'AAC' => 'N',    # Asparagine
					'AAT' => 'N',    # Asparagine
					'AAA' => 'K',    # Lysine
					'AAG' => 'K',    # Lysine
					'AGC' => 'S',    # Serine
					'AGT' => 'S',    # Serine
					'AGA' => 'R',    # Arginine
					'AGG' => 'R',    # Arginine
					'GTA' => 'V',    # Valine
					'GTC' => 'V',    # Valine
					'GTG' => 'V',    # Valine
					'GTT' => 'V',    # Valine
					'GCA' => 'A',    # Alanine
					'GCC' => 'A',    # Alanine
					'GCG' => 'A',    # Alanine
					'GCT' => 'A',    # Alanine
					'GAC' => 'D',    # Aspartic Acid
					'GAT' => 'D',    # Aspartic Acid
					'GAA' => 'E',    # Glutamic Acid
					'GAG' => 'E',    # Glutamic Acid
					'GGA' => 'G',    # Glycine
					'GGC' => 'G',    # Glycine
					'GGG' => 'G',    # Glycine
					'GGT' => 'G',    # Glycine
				);


#
# codon2aa
#
# A subroutine to translate a DNA 3-character codon to an amino acid
#   Version 3, using hash lookup

sub codon2aa
{
	my($codon) = @_;
	$codon = uc $codon;

	if(exists $genetic_code{$codon})
	{
		return $genetic_code{$codon};
	}
	else
	{
		die "Bad codon '$codon'!!\n";
	}
}

#
# dna2peptide 
#
# A subroutine to translate DNA sequence into a peptide

sub dna2peptide
{
	my($dna) = @_;

	# Initialize variables
	my $protein = '';

	# Translate each three-base codon to an amino acid, and append to a protein 
	for(my $i=0; $i < (length($dna) - 2) ; $i += 3)
	{
		$protein .= codon2aa( substr($dna,$i,3) );
	}

	return $protein;
}

# translate_frame
#
# A subroutine to translate a frame of DNA

sub translate_frame
{
	my($seq, $start, $end) = @_;
	my $protein;

	# To make the subroutine easier to use, you won't need to specify
	#  the end point-it will just go to the end of the sequence
	#  by default.
	unless($end)
	{
		$end = length($seq);
	}

	# Finally, calculate and return the translation
	return dna2peptide ( substr ( $seq, $start - 1, $end -$start + 1) );
}

1;
