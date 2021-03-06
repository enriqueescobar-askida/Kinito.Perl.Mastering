package Gene;

#
# A fourth and final version of the Gene.pm class
#

use strict;
use warnings;
our $AUTOLOAD; # before Perl 5.6.0 say "use vars '$AUTOLOAD';"
use Carp;

# Class data and methods
{
	# A list of all attributes with default values and read/write/required properties
	my %_attribute_properties = (
								_name        => [ '????',	'read.required'],
								_organism    => [ '????',	'read.required'],
								_chromosome  => [ '????',	'read.write'],
								_pdbref      => [ '????',	'read.write'],
								_author      => [ '????',	'read.write'],
								_date	     => [ '????',	'read.write'],
								);
		
	# Global variable to keep count of existing objects
	my $_count = 0;

	# Return a list of all attributes
	sub _all_attributes
	{
		keys %_attribute_properties;
	}

	# Check if a given property is set for a given attribute
	sub _permissions
	{
		my($self, $attribute, $permissions) = @_;
		$_attribute_properties{$attribute}[1] =~ /$permissions/;
	}

	# Return the default value for a given attribute
	sub _attribute_default
	{
		my($self, $attribute) = @_;
		$_attribute_properties{$attribute}[0];
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

# The constructor method
# Called from class, e.g. $obj = Gene->new();
sub new
{
	my ($class, %arg) = @_;
	# Create a new object
	my $self = bless {}, $class;

	foreach my $attribute ($self->_all_attributes())
	{
		# E.g. attribute = "_name",  argument = "name"
		my($argument) = ($attribute =~ /^_(.*)/);
		# If explicitly given
		if (exists $arg{$argument})
		{
			$self->{$attribute} = $arg{$argument};
		# If not given, but required
		}
		elsif($self->_permissions($attribute, 'required'))
		{
			croak("No $argument attribute as required");
		# Set to the default
		}
		else
		{
			$self->{$attribute} = $self->_attribute_default($attribute);
		}
	}
	$class->_incr_count();
	return $self;
}

# The clone method
# All attributes will be copied from the calling object, unless
# specifically overridden
# Called from an exisiting object, e.g. $cloned_obj = $obj1->clone();
sub clone
{
	my ($caller, %arg) = @_;
	# Extract the class name from the calling object
	my $class = ref($caller);
	# You can only call "clone" from an object, not the class
	unless ($class)
	{
		carp "Need an existing object to clone";
		return;
	}
	# Create a new object
	my $self = bless {}, $class;

	foreach my $attribute ($self->_all_attributes())
	{
		# E.g. attribute = "_name",  argument = "name"
		my($argument) = ($attribute =~ /^_(.*)/);
		# If explicitly given
		if (exists $arg{$argument})
		{
			$self->{$attribute} = $arg{$argument};
		# Otherwise copy attribute of new object from the calling object
		}
		else
		{
				$self->{$attribute} = $caller->{$attribute};
		}
	}
	$self->_incr_count();
	return $self;
}



# This takes the place of such accessor definitions as:
#  sub get_attribute { ... }
# and of such mutator definitions as:
#  sub set_attribute { ... }
sub AUTOLOAD
{
	my ($self, $newvalue) = @_;

	my ($operation, $attribute) = ($AUTOLOAD =~ /(get|set)(_\w+)$/);
	
	# Is this a legal method name?
	unless($operation && $attribute)
	{
		croak "Method name $AUTOLOAD is not in the recognized form (get|set)_attribute\n";
	}
	unless(exists $self->{$attribute})
	{
		croak "No such attribute $attribute exists in the class ", ref($self);
	}

	# Turn off strict references to enable "magic" AUTOLOAD speedup
	no strict 'refs';

	# AUTOLOAD accessors
	if($operation eq 'get')
	{
		# Complain if you can't get the attribute
		unless($self->_permissions($attribute, 'read'))
		{
			croak "$attribute does not have read permission";
		}

		# Install this accessor definition in the symbol table
		*{$AUTOLOAD} = sub {
								my ($self) = @_;
								unless($self->_permissions($attribute, 'read'))
								{
									croak "$attribute does not have read permission";
								}
								$self->{$attribute};
							};

	# AUTOLOAD mutators
	}
	elsif($operation eq 'set')
	{
		# Complain if you can't set the attribute
		unless($self->_permissions($attribute, 'write'))
		{
			croak "$attribute does not have write permission";
		}
	
		# Set the attribute value
		$self->{$attribute} = $newvalue;
	
		# Install this mutator definition in the symbol table
		*{$AUTOLOAD} = sub {
								my ($self, $newvalue) = @_;
								unless($self->_permissions($attribute, 'write'))
								{
									croak "$attribute does not have write permission";
								}
								$self->{$attribute} = $newvalue;
							};
	}

	# Turn strict references back on
	use strict 'refs';

	# Return the attribute value
	return $self->{$attribute};
}

# When an object is no longer being used, this will be automatically called
# and will adjust the count of existing objects
sub DESTROY
{
	my($self) = @_;
	$self->_decr_count();
}

# Other methods.  They do not fall into the same form as the majority handled by AUTOLOAD
sub citation
{
	my ($self, $author, $date) = @_;
	$self->{_author} 	= set_author($author) if $author;
	$self->{_date} 		= set_date($date) if $date;
	return ($self->{_author}, $self->{_date})
}

1;

=head1 Gene

Gene: objects for Genes with a minimum set of attributes

=head1 Synopsis

	use Gene;

	my $gene1 = Gene->new(
		name => 'biggene',
		organism => 'Mus musculus',
		chromosome => '2p',
		pdbref => 'pdb5775.ent',
		author => 'L.G.Jeho',
		date => 'August 23, 1989',
	);

	print "Gene name is ", $gene1->get_name();
	print "Gene organism is ", $gene1->get_organism();
	print "Gene chromosome is ", $gene1->get_chromosome();
	print "Gene pdbref is ", $gene1->get_pdbref();
	print "Gene author is ", $gene1->get_author();
	print "Gene date is ", $gene1->get_date();

	$clone = $gene1->clone(name => 'biggeneclone');

	$gene1-> set_chromosome('2q');
	$gene1-> set_pdbref('pdb7557.ent');
	$gene1-> set_author('G.Mendel');
	$gene1-> set_date('May 25, 1865');

	$clone->citation('T.Morgan', 'October 3, 1912');

	print "Clone citation is ", $clone->citation;

=head1 AUTHOR

A kind reader

=head1 COPYRIGHT

Copyright (c) 2003, We Own Gene, Inc.

=cut
