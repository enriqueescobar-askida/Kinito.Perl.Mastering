package Gene2;

#
# A second version of the Gene.pm module
#

use strict;
use warnings;
use Carp;

# Class data and methods, that refer to the collection of all objects
# in the class, not just one specific object
{
	my $_count = 0;
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

# The constructor for the class
sub new
{
	my ($class, %arg) = @_;
	my $self = bless
	{
		_name        => $arg{name}      || croak("Error: no name"),
		_organism    => $arg{organism}  || croak("Error: no organism"),
		_chromosome  => $arg{chromosome}|| "????",
		_pdbref      => $arg{pdbref}    || "????",
	}, $class;
	$class->_incr_count();
	return $self;
}

# Accessors, for reading the values of data in an object
sub get_name	   { $_[0] -> {_name} 		}
sub get_organism   { $_[0] -> {_organism}	}
sub get_chromosome { $_[0] -> {_chromosome}	}
sub get_pdbref	   { $_[0] -> {_pdbref}		}

# Mutators, for writing the values of object data
sub set_name
{
	my ($self, $name) = @_;
	$self -> {_name} 		= $name if $name;
}
sub set_organism
{
	my ($self, $organism) = @_;
	$self -> {_organism} 	= $organism if $organism;
}
sub set_chromosome
{
	my ($self, $chromosome) = @_;
	$self -> {_chromosome} 	= $chromosome if $chromosome;
}
sub set_pdbref
{
	my ($self, $pdbref) = @_;
	$self -> {_pdbref}		= $pdbref if $pdbref;
}

1;
