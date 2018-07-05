use Bio::Perl;
use strict;
use warnings;

my $gbfilename = 'AI129902.genbank';

# will guess file format from extension
my $seq_object0 = read_sequence($gbfilename);

# forces genbank format
my $seq_object1 = read_sequence($gbfilename,'genbank');

my $fastafilename = 'array.fasta';

# reads an array of sequences
my @seq_object_array = read_all_sequences($fastafilename,'fasta');

# sequences are Bio::Seq objects, so the following methods work
# for more info see L<Bio::Seq>, or do 'perldoc Bio/Seq.pm'

print "Sequence name is ",$seq_object1->display_id,"\n";
print "Sequence acc  is ",$seq_object1->accession_number,"\n";
print "First 5 bases is ",$seq_object1->subseq(1,5),"\n";

# get the whole sequence as a single string

my $sequence_as_a_string = $seq_object1->seq();

# writing sequences

my $gbfilenameout = 'bpout.genbank';

write_sequence(">$gbfilenameout",'genbank',$seq_object1);

write_sequence(">$gbfilenameout",'genbank',@seq_object_array);

# making a new sequence from just strings you have
# from something else

my $seq_object2 = new_sequence("ATTGGTTTGGGGACCCAATTTGTGTGTTATATGTA",
	"myname","AL12232");


# getting a sequence from a database (assumes internet connection)

my $seq_object3 = get_sequence('swissprot',"ROA1_HUMAN");

my $seq_object4 = get_sequence('embl',"AI129902");

my $seq_object5 = get_sequence('genbank',"3598416");

# BLAST a sequence (assummes an internet connection)

my $blast_report = blast_sequence($seq_object3);

write_blast(">blast.out",$blast_report);

