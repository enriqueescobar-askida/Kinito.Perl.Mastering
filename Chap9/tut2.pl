use Bio::Perl;
use strict;
use warnings;

# this script will only work with an internet connection
# on the computer it is run on

my $seq_object = get_sequence('swissprot',"ROA1_HUMAN");

# uses the default database - nr in this case
my $blast_result = blast_sequence($seq_object);

write_blast(">roa1.blast",$blast_result);
