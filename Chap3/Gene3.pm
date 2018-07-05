package Gene3;

#
# A third version of the Gene.pm module
#

use strict;
use warnings;
our $AUTOLOAD; # before Perl 5.6.0 say "use vars '$AUTOLOAD';"
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
	my $self = bless {
						_name        => $arg{name}      || croak("Error: no name"),
						_organism    => $arg{organism}  || croak("Error: no organism"),
						_chromosome  => $arg{chromosome}|| "????",
						_pdbref      => $arg{pdbref}    || "????",
						_author      => $arg{author}	|| "????",
						_date	     => $arg{date}	|| "????",
					}, $class;
	$class->_incr_count();
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
		croak "No such attribute '$attribute' exists in the class ", ref($self);
	}

	# Turn off strict references to enable "magic" AUTOLOAD speedup
	no strict 'refs';

	# AUTOLOAD accessors
	if($operation eq 'get')
	{
		# define subroutine
		*{$AUTOLOAD} = sub { shift->{$attribute} };

		# AUTOLOAD mutators
	}
	elsif($operation eq 'set')
	{
		# define subroutine
		*{$AUTOLOAD} = sub { shift->{$attribute} = shift; };

		# set the new attribute value
		$self->{$attribute} = $newvalue;
	}

	# Turn strict references back on
	use strict 'refs';

	# return the attribute value
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
# This is an example of a method that is both accessor and mutator, depending on the
# number of arguments provided to it.
sub citation
{
	my ($self, $author, $date) = @_;
	$self->{_author} 		= set_author($author) if $author;
	$self->{_date} 			= set_date($date) if $date;
	return ($self->{_author}, $self->{_date})
}

1;
