#!/usr/bin/perl

use strict;
use warnings;

# Make connection with MySQL database

use DBI;

my $database= 'homologs';
my $server 	= 'localhost';
my $user 	= 'tisdall';
my $passwd 	= 'NOTmyPASSWORD';

my $homologs = DBI->connect("dbi:mysql:$database:$server",
							$user,
							$passwd);
my $sqlinit = $homologs->prepare("show tables");
$sqlinit->execute();
while (my $row = $sqlinit->fetchrow_arrayref)
{
	print join("\t", @$row), "\n";
}

my $flag = 0;
my $table;
my @tables;
my $sql;

while(<>)
{
	# skip blank lines
	if(/^\s*$/)
	{
		next;
	# begin new table
	}
	elsif(/^TABLE\t(\w+)/)
	{
		$flag = 1;
		$table = $1;
		push(@tables, $table);
		# Delete all rows in database table
		my $droprows = $homologs->prepare("delete from $table");
		$droprows->execute();
		# get fieldnames, prepare SQL statement
	}
	elsif($flag == 1)
	{
		$flag = 2;
		my @fieldnames = split;
		my $query = "insert into  $table (" . join(",", @fieldnames) . ") values (" . "?, " x (@fieldnames-1) . "?)";
		$sql = $homologs->prepare($query);

	# get row, execute SQL statement
	}
	elsif($flag == 2)
	{
		my @fields = split;
		$sql->execute( @fields);
	}
}

# Check if tables were updated

foreach my $table (@tables)
{
	print "\nTable: $table\n\n";
	my $query = "select * from $table";
	my $sql = $homologs->prepare($query);
	$sql->execute();

	while (my $row = $sql->fetchrow_arrayref)
	{
		print join("\t", @$row), "\n";
	}
}

# Break connection with MySQL database

$homologs->disconnect;

exit;

