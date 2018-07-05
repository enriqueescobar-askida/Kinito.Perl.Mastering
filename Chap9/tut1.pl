use Bio::Perl;

# this script will only work with an internet connection
# on the computer it is run on
$seq_object = get_sequence('swissprot',"ROA1_HUMAN");

write_sequence(">roa1.fasta",'fasta',$seq_object);
