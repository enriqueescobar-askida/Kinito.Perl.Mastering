package SequenceIO;

use strict;
use warnings;


# get_file_data
#
# A subroutine to get data from a file given its filename

sub get_file_data
{
	my($filename) = @_;

	# Initialize variables
	my @filedata = (  );

	open(GET_FILE_DATA, $filename) or die "Cannot open file '$filename':$!\n\n";

	@filedata = <GET_FILE_DATA>;

	close GET_FILE_DATA;

	return @filedata;
}

# extract_sequence_from_fasta_data
#
# A subroutine to extract FASTA sequence data from an array

sub extract_sequence_from_fasta_data
{
	my(@fasta_file_data) = @_;

	# Declare and initialize variables
	my $sequence = '';

	foreach my $line (@fasta_file_data)
	{

		# discard blank line
		if ($line =~ /^\s*$/)
		{
			next;
		# discard comment line
		}
		elsif($line =~ /^\s*#/)
		{
			next;

		# discard fasta header line
		}
		elsif($line =~ /^>/)
		{
			next;
		# keep line, add to sequence string
		}
		else
		{
			$sequence .= $line;
		}
	}
	# remove non-sequence data (in this case, whitespace) from $sequence string
	$sequence =~ s/\s//g;

	return $sequence;
}

# print_sequence
#
# A subroutine to format and print sequence data 

sub print_sequence
{
	my($sequence, $length) = @_;

	# Print sequence in lines of $length
	for ( my $pos = 0 ; $pos < length($sequence) ; $pos += $length )
	{
		print substr($sequence, $pos, $length), "\n";
	}
}

1;
