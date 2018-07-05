package RebaseDB;

#
# A simple class to provide access to restriction enzyme data from Rebase
#  including regular expression translations of recognition sites
# Data is stored in a MySQL database
#

use strict;
use warnings;
use DBI;
use Carp;

# Class data and methods
{
	# A hash of all attributes with default values
	my %_attributes = (
							_rebase      => { },  # unused in this implementation
							#    key   = restriction enzyme name
							#    value = space-separated string of sites => regular expressions
							_mysql       => '??', #  e.g. mysql => 'rebase:localhost',
							_dbh         => '',   # database handle from DBI->connect
							_bionetfile  => '??', # source of data from e.g. "bionet.212" file
						);
		
	# Return a list of all attributes
	sub _all_attributes
	{
		keys %_attributes;
	}
}

# The constructor method
# Called from class, e.g. $obj = Rebase->new( mysql => 'localhost:rebase' );
sub new
{
	my ($class, %arg) = @_;
	# Create a new object
	my $self = bless {}, $class;

	# Set the attributes for the provided arguments
	foreach my $attribute ($self->_all_attributes())
	{
		# E.g. attribute = "_name",  argument = "name"
		my($argument) = ($attribute =~ /^_(.*)/);

		if (exists $arg{$argument})
		{
			if($argument eq 'rebase')
			{
				croak "Cannot set attribute rebase";
			}
			$self->{$attribute} = $arg{$argument};
		}
	}

	# MySQL host:database string must be given as "mysql" argument
	unless($arg{mysql})
	{
		croak("No MySQL host:database specified");
	}

	# Connect to the Rebase database
	my $user 	= 'tisdall';
	my $passwd 	= 'considerthechild';
	my $dbh;
	unless($dbh = DBI->connect("dbi:mysql:$arg{mysql}",
								$user,
								$passwd))
	{
		carp "Cannot connect to MySQL database at $arg{dbmfile}";
		return;
	}
	$self->setDBhandle($dbh);

	# If "bionetfile" argument given, populate the database from the bionet file
	if($arg{bionetfile})
	{
		$self->parse_rebase();
	}

	return $self;
}


# For this simple class we have no AUTOLOAD or DESTROY
# No "set" mutators: all initialization done by way of "new" constructor

sub get_regular_expressions
{
	my($self, $enzyme) = @_;

	my $dbh = $self->getDBhandle;
	my $sth = $dbh->prepare(
								'select Regex from REGEXES, ENZYMES where
								ENZYMES.EnzId = REGEXES.EnzId and ENZYMES.Enzyme=?'
							);
	$sth->execute($enzyme);

	my @regexes;
	while( my $row = $sth->fetchrow_arrayref)
	{
		push(@regexes, $$row[0]);
	}
	return @regexes;
}

sub getDBhandle
{
	my($self) = @_;

	return $self->{_dbh};
}

sub setDBhandle
{
	my($self, $dbh) = @_;

	return $self->{_dbh} = $dbh;
}

sub get_recognition_sites
{
	my($self, $enzyme) = @_;

	my $dbh = $self->getDBhandle;
	my $sth = $dbh->prepare(
								'select Site from SITES, ENZYMES
								where ENZYMES.EnzId = SITES.EnzId and ENZYMES.Enzyme=?'
							);
	$sth->execute($enzyme);

	my @sites;
	while( my $row = $sth->fetchrow_arrayref)
	{
		push(@sites, $$row[0]);
	}
	return @sites;
}

sub get_bionetfile
{
	my($self) = @_;

	return $self->{_bionetfile};
}


sub parse_rebase
{
	my($self) = @_;

	# handles multiple definition lines for an enzyme name
	# also handles alternate enzyme names on a line

	# Get database handle
	my $dbh 	= $self->getDBhandle();

	# Delete existing tables, recreate them
	# Prepare statement handles with "bind" variables and autoincrement

	# ENZYMES table
	my $drop 	= $dbh->prepare('drop table if exists ENZYMES');
	$drop->execute();
	my $create = $dbh->prepare(
									"CREATE TABLE ENZYMES ( EnzId int(11) NOT NULL auto_increment default '0',
									Enzyme varchar(255) NOT NULL default '', PRIMARY KEY  (EnzId)) TYPE=MyISAM"
								);
	$create->execute();
	# Prepare filehandles outside of "while" loop
	my $enzymes_select = $dbh->prepare(
										'select EnzId from ENZYMES where Enzyme=?'
									);
	my $enzymes_insert =  $dbh->prepare(
										'insert ENZYMES ( EnzId, Enzyme ) values ( NULL, ? )'
									); 

	# SITES table
	$drop = $dbh->prepare('drop table if exists SITES');
	$drop->execute();
	$create = $dbh->prepare(
								"CREATE TABLE SITES ( SiteId int(11) NOT NULL auto_increment default '0',
								EnzId int(11) NOT NULL default '0', Site varchar(255) NOT NULL default '',
								PRIMARY KEY  (SiteId)) TYPE=MyISAM"
							);
	$create->execute();
	# Prepare filehandles outside of "while" loop
	my $sites_insert = $dbh->prepare(
										'insert SITES ( SiteId, EnzId, Site ) values ( NULL, ?, ? )'
									);
	my $sites_select = $dbh->prepare(
										'select EnzId, Site from SITES where EnzId=? and Site=?'
									);
	my $sitesrevcom_select = $dbh->prepare(
											'select EnzId, Site from SITES where EnzId=? and Site=?'
										);


	# REGEXES table
	$drop = $dbh->prepare('drop table if exists REGEXES');
	$drop->execute();
	$create = $dbh->prepare(
								"CREATE TABLE REGEXES ( RegexId int(11) NOT NULL auto_increment default '0',
								EnzId int(11) NOT NULL default '0', Regex varchar(255) NOT NULL default '',
								PRIMARY KEY  (RegexId)) TYPE=MyISAM"
							);
	$create->execute();
	# Prepare filehandles outside of "while" loop
	my $regexes_insert = $dbh->prepare(
										'insert REGEXES ( RegexId, EnzId, Regex ) values ( NULL, ?, ? )'
									);

	my $lastid =  $dbh->prepare('select LAST_INSERT_ID() as pk');

	# Read in the bionet(Rebase) file
	unless(open(BIONETFH, $self->get_bionetfile))
	{
		croak("Cannot open bionet file " . $self->get_bionetfile);
	}

	while(<BIONETFH>)
	{
		my @names = ();

		# Discard header lines
		( 1 .. /Rich Roberts/ ) and next;

		# Discard blank lines
		/^\s*$/ and next;
	
		# Split the two (or three if includes parenthesized name) fields
		my @fields = split( " ", $_);

		# Get and store the recognition site
		my $site = pop @fields;
		# For the purposes of this exercise, we'll ignore cut sites (^).
		# This is not something you'd want to do in general, however!
		$site =~ s/\^//g;
	
		# Get and store the name and the recognition site.
		# Add alternate (parenthesized) names
		# from the middle field, if any
		foreach my $name (@fields)
		{
			if($name =~ /\(.*\)/)
			{
				$name =~ s/\((.*)\)/$1/;
			}
			push @names, $name;
		}

		# Store the data into the database, avoiding duplicates (ignoring ^ cut sites)
		# and ignoring reverse complements
		foreach my $name (@names)
		{
			my $pk;
			my $row;

			# if enzyme exists
			$enzymes_select->execute($name);
			if($row = $enzymes_select->fetchrow_arrayref)
			{
				# get its "pk"
				$pk = $$row[0];
			}
			else
			{
				# Add new enzyme definition
				$enzymes_insert->execute($name);

				# Get last autoincremented primary id
				$lastid->execute();
				my $pkhash = $lastid->fetchrow_hashref;
				$pk = $pkhash->{pk};
			}

			# if pk,site exist go to top of loop
			$sites_select->execute($pk, $site);
			if($row = $sites_select->fetchrow_arrayref)
			{
				next;
			}
			# and if pk,revcomIUB(site) exist go to top of loop
			$sitesrevcom_select->execute($pk, revcomIUB($site));
			if($row = $sitesrevcom_select->fetchrow_arrayref)
			{
				next;
			}

			# Add new site definition
				#  since neither pk,site nor
			#  pk,revcomIUB(site) exists.
			$sites_insert->execute($pk, $site);

			# Add new regex definition
			$regexes_insert->execute($pk, IUB_to_regexp($site));
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

=head1 RebaseDB

Rebase: A simple interface to recognition sites and translations of them into
		regular expressions, from the Restriction Enzyme Database (Rebase)

=head1 Synopsis

	use RebaseDB;

	my $rebase = RebaseDB->new(
		mysql => 'rebase:localhost',
	bionetfile => 'bionet.212'
	);

	my $enzyme = 'EcoRI';

	print "Looking up restriction enzyme $enzyme\n";

	my @sites = $rebase->get_recognition_sites($enzyme);
	print "Sites are @sites\n";

	my @res = $rebase->get_regular_expressions($enzyme);
	print "Regular expressions are @res\n";

	my $enzyme = 'HindIII';

	print "Looking up restriction enzyme $enzyme\n";

	my @sites = $rebase->get_recognition_sites($enzyme);
	print "Sites are @sites\n";

	my @res = $rebase->get_regular_expressions($enzyme);
	print "Regular expressions are @res\n";

	print "Rebase bionet file is ", $rebase->get_bionetfile, "\n";


=head1 AUTHOR

James Tisdall

=head1 COPYRIGHT

Copyright (c) 2003, James Tisdall

=cut
