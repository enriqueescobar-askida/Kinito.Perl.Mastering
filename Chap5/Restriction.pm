package Restriction;

#
# A class to find locations of restriction enzyme recognition sites in
#  DNA sequence data.
#

use strict;
use warnings;
use Carp;

# Class data and methods
{
	# A list of all attributes with default values.
	# "enzyme" is given as an argument possibly multiple time, set as key to _map hash
	my %_attributes = (
						_rebase      => { },  # A Rebase.pm hash-based object
						#    key   = restriction enzyme name
						#    value = space-separated string of recognition sites => regular expressions
						_sequence    => '',   # DNA sequence data in raw format (only bases)
						_map         => { },  # a hash: keys are enzyme names, values are arrays of locations 
						_enzyme      => '',   # space- or comma-separated enzyme names, set as key to _map hash
					);

	# Global variable to keep count of existing objects
	my $_count = 0;
		
	# Return a list of all attributes
	sub _all_attributes
	{
		keys %_attributes;
	}

	# Manage the count of existing objects
	sub get_count
	{
		$_count;
	}
	sub _incr_count
	{
		++$_count;
	}
	sub _decr_count
	{
		--$_count;
	}
}

# The "new" constructor method, called from class, e.g.
sub new
{
	my ($class, %args) = @_;
	# Create a new object
	my $self = bless {}, $class;

	# Set the attributes for the provided arguments
	foreach my $attribute ($self->_all_attributes())
	{
		# E.g. attribute = "_name",  argument = "name"
		my($argument) = ($attribute =~ /^_(.*)/);

		if (exists $args{$argument})
		{
			if($argument eq 'enzyme')
			{
				# permit space or comma separated enzyme names
				$args{$argument} =~ s/,/ /g;
			}
			$self->{$attribute} = $args{$argument};
		}
	}

	# Check that the correct arguments are given
	if( not defined $self->{_rebase} )
	{
		croak "A Rebase object must be given as an argument";
	}
	elsif( ref($self->{_rebase}) ne 'Rebase' )
	{
		croak "The argument to rebase is not a Rebase object";
	}
	elsif( not defined $self->{_sequence} )
	{
		croak "A sequence must be given as an argument";
	}

	# Calculate the locations for each enzyme, store in _map hash attribute
	foreach my $enzyme (split(" ", $self->{_enzyme}))
	{
		$self->map_enzyme($enzyme);
	}

	$self->_incr_count;

	return $self;
}


# For this simple class I have no AUTOLOAD or DESTROY

# No get_rebase method, I don't want to pass around a huge hash

# No set mutators: all initialization done by way of "new" constructor

# No clone method.  Each sequence and set of enzymes can be easily calculated
#  by means of a "new" command.


sub map_enzyme
{
	my($self, $enzyme) = @_;

	my(@positions) = ();

	my(@res) = $self->get_regular_expressions($enzyme);

	foreach my $re (@res)
	{
		push @positions, $self->match_positions($re);
	}

	@{$self->{_map}{$enzyme}} = @positions;
	return @positions;
}

sub get_regular_expressions
{
	my($self, $enzyme) = @_;

	my(%sites) = split(' ', $self->{_rebase}{_rebase}{$enzyme});

	# May have duplicate values
	return values %sites;
}

# Find positions of a regular expression in the sequence
sub match_positions
{
	my($self, $regexp) = @_;

	my @positions = (  );

	# Determine positions of regular expression matches
	while ( $self->{_sequence} =~ /$regexp/ig )
	{
		push @positions, ($-[0] + 1 );
	}

	return(@positions);
}

sub get_enzyme_map
{
	my($self, $enzyme) = @_;

	@{$self->{_map}{$enzyme}};
}

sub get_enzyme_names
{
	my($self) = @_;

	keys %{$self->{_map}};
}
sub get_sequence
{
	my($self) = @_;

	$self->{_sequence};
}

sub get_map
{
	my($self) = @_;

	%{$self->{_map}};
}


=head1 Restriction

Restriction: Given a Rebase object, sequence, and list of restriction enzyme
	names, return the locations of the recognition sites in the sequence

=head1 Synopsis

	use Restriction;

	use Rebase;

	use strict;
	use warnings;

	my $rebase = Rebase->new(
		dbmfile => 'BIONET',
	bionetfile => 'bionet.212'
	);

	my $restrict = Restriction->new(
		rebase => $rebase,
	enzyme => 'EcoRI, HindIII',
	sequence => 'ACGAATTCCGGAATTCG',
	);

	print "Locations for EcoRI are ", join(' ', $restrict->get_enzyme_map('EcoRI')), "\n";

=head1 AUTHOR

James Tisdall

=head1 COPYRIGHT

Copyright (c) 2003, James Tisdall

=cut

1;
