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

# prepare an SQL statement
my $query	= "show tables";
my $sql		= $homologs->prepare($query);

# execute an SQL statement
$sql->execute();

# retrieve and print results
while (my $row = $sql->fetchrow_arrayref)
{
	print join("\t", @$row), "\n";
}

# Break connection with MySQL database
$homologs->disconnect;

exit;
