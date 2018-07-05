package Rebase;

#
# A simple class to provide access to restriction enzyme data from Rebase
#  including regular expression translations of recognition sites
#

use strict;
use warnings;
use Carp;
use DB_File;

# Class data and methods
{
	# A hash of all attributes with default values
	my %_attributes = (
						_rebase      => { },
						#    key   = restriction enzyme name
						#    value = space-separated string of sites => regular expressions
						_bionetfile  => '??',
						_dbmfile     => '??',
						_mode        => 0444,
					);
		
	# Return a list of all attributes
	sub _all_attributes
	{
		keys %_attributes;
	}
		
	# Return the value of an attribute
	sub _attribute_value
	{
		my($self,$attribute) = @_;
		$_attributes{$attribute};
	}
}

# The constructor method
# Called from class, e.g. $obj = Rebase->new( dbmfile => 'DBMFILE' );
sub new
{
	my ($class, %arg) = @_;

	# Create a new object
	my $self = bless {}, $class;

	# DBM file must be given as "dbmfile" argument
	unless($arg{dbmfile})
	{
		croak("No dbm file specified");
	}

	# Set the attributes for the provided arguments
	foreach my $attribute ($self->_all_attributes())
	{
		# E.g. attribute = "_name",  argument = "name"
		my($argument) = ($attribute =~ /^_(.*)/);
	
		# Initialize to defaults
		$self->{$attribute} = $self->_attribute_value($attribute);
	
		# Override defaults with arguments
		if (exists $arg{$argument})
		{
			if($argument eq 'rebase')
			{
				croak "Cannot set attribute rebase";
			}
			$self->{$attribute} = $arg{$argument};
		}
	}

	# Open or create the DBM file
	unless(tie %{$self->{_rebase}}, 'DB_File', $arg{dbmfile}, O_RDWR|O_CREAT, $self->{_mode}, $DB_HASH)
	{
		my $permissions = sprintf "%lo", $self->{_mode};
		croak "Cannot open DBM file $arg{dbmfile} with mode $permissions";
	}

	# If "bionetfile" argument given, calculate the hash from the bionet file
	if($arg{bionetfile})
	{
		# Empty the hash
		%{$self->{_rebase}} = (); 

		# Recalculate the hash
		$self->parse_rebase;
	}

	return $self;
}


# For this simple class I have no AUTOLOAD or DESTROY

# No get_rebase method, I don't want to pass around a huge hash

# No "set" mutators: all initialization done by way of "new" constructor

sub get_regular_expressions
{
	my($self, $enzyme) = @_;

	my(%sites) = split(' ', $self->{_rebase}{$enzyme});

	# May have duplicate values
	return values %sites;
}

sub get_recognition_sites
{
	my($self, $enzyme) = @_;

	my(%sites) = split(' ', $self->{_rebase}{$enzyme});

	return keys %sites;
}

sub get_bionetfile
{
	my($self) = @_;

	return $self->{_bionetfile};
}

sub get_dbmfile
{
	my($self) = @_;

	return $self->{_dbmfile};
}

sub get_mode
{
	my($self) = @_;

	return $self->{_mode};
}


sub parse_rebase
{
	my($self) = @_;

	# handles multiple definition lines for an enzyme name
	# also handles alternate enzyme names on a line

	# Read in the bionet(Rebase) file
	unless(open(BIONETFH, $self->{_bionetfile}))
	{
		croak("Cannot open bionet file $self->{_bionetfile}");
	}

	while(<BIONETFH>)
	{
		my @names = ();

		# Discard header lines
		next if ( 1 .. /Rich Roberts/ );  # discard all lines from the first line
									# to the first line containing "Rich Roberts"

		# Discard blank lines
		next unless /\S/;  # discard a line unless it contains something not whitespace
	
		# Split the two (or three if includes parenthesized name) fields
		my @fields = split;

		# Get and store the recognition site
		my $site = pop @fields;
		# For the purposes of this exercise, I'll ignore cut sites (^).
		# This is not something you'd want to do in general, however!
		$site =~ s/\^//g;

		# Get and store the name and the recognition site.
		# Add alternate (parenthesized) names
		# from the middle field, if any
		foreach my $name (@fields)
		{
			$name =~ tr/)(//d;  # delete parentheses
			push @names, $name;
		}

		# Store the data into the hash, avoiding duplicates (ignoring ^ cut sites)
		# and ignoring reverse complements
		# Because these values are stored via DBM, I cannot use anything but
		#  a scalar string to store the site/regularexpression pairs, space-separated
		#  (but see the exercises)
		foreach my $name (@names)
		{
			# Add new enzyme definition
			unless(exists $self->{_rebase}{$name})
			{
				$self->{_rebase}{$name} = "$site " . IUB_to_regexp($site);
				next;
			}

			my(%defined_sites) = split(' ', $self->{_rebase}{$name});

			# Omit already defined sites
			if(exists $defined_sites{$site})
			{
				next;
				# Omit reverse complements of already defined sites
			}
			elsif(exists $defined_sites{revcomIUB($site)})
			{
				next;
				# Add the additional site
			}
			else
			{
				$self->{_rebase}{$name}  .= " $site " . IUB_to_regexp($site);
			}
		}
	}
	return 1;
}

sub revcomIUB
{
	my($seq) = @_;

	my $revcom = reverse complementIUB($seq);

	return $revcom;
}

sub complementIUB
{
	my($seq) = @_;

	(my $com = $seq) =~ tr [ACGTRYMKSWBDHVNacgtrymkswbdhvn]
							[TGCAYRKMWSVHDBNtgcayrkmwsvhdbn];
							
	return $com;
}

# Translate IUB ambiguity codes to regular expressions 
# IUB_to_regexp
#
# A subroutine that, given a sequence with IUB ambiguity codes,
# outputs a translation with IUB codes changed to regular expressions
#
# These are the IUB ambiguity codes
# (Eur. J. Biochem. 150: 1-5, 1985):
# R = G or A
# Y = C or T
# M = A or C
# K = G or T
# S = G or C
# W = A or T
# B = not A (C or G or T)
# D = not C (A or G or T)
# H = not G (A or C or T)
# V = not T (A or C or G)
# N = A or C or G or T 

sub IUB_to_regexp
{
	my($iub) = @_;

	my $regular_expression = '';

	my %iub2character_class = (
								A => 'A',
								C => 'C',
								G => 'G',
								T => 'T',
								R => '[GA]',
								Y => '[CT]',
								M => '[AC]',
								K => '[GT]',
								S => '[GC]',
								W => '[AT]',
								B => '[CGT]',
								D => '[AGT]',
								H => '[ACT]',
								V => '[ACG]',
								N => '[ACGT]',
							);

	# Remove the ^ signs from the recognition sites
	$iub =~ s/\^//g;

	# Translate each character in the iub sequence
	for ( my $i = 0 ; $i < length($iub) ; ++$i )
	{
		$regular_expression.= $iub2character_class{substr($iub, $i, 1)};
	}

	return $regular_expression;
}

1;

=head1 Rebase

Rebase: A simple interface to recognition sites and translations of them into
		regular expressions, from the Restriction Enzyme Database (Rebase)

=head1 Synopsis

	use Rebase;

	# Use "bionetfile" to create and populate dbm file
	my $rebase = Rebase->new(
		dbmfile => 'BIONET',
	bionetfile => 'bionet.212',
	mode => 0644
	);

	# Use without "bionetfile" to attach to existing dbm file
	my $rebase = Rebase->new(
		dbmfile => 'BIONET',
	mode => 0444
	);

	my $enzyme = 'EcoRI';

	print "Looking up restriction enzyme $enzyme\n";

	my @sites = $rebase->get_recognition_sites($enzyme);
	print "Sites are @sites\n";

	my @res = $rebase->get_regular_expressions($enzyme);
	print "Regular expressions are @res\n";

	print "DBM file is ", $rebase->get_dbmfile, "\n";
	print "Rebase bionet file is ", $rebase->get_bionetfile, "\n";


=head1 AUTHOR

James Tisdall

=head1 COPYRIGHT

Copyright (c) 2003, James Tisdall

=cut
