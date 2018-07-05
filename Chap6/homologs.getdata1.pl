#!/usr/bin/perl

use strict;
use warnings;

my $flag = 0;
my $table;
my @table;
my @fieldnames;
my @fields;

while(<>)
{
	if(/^\s*$/)
	{
		# skip blank lines
		;
	}
	elsif(/^TABLE\t(\w+)/)
	{
		# output previous table
		print(@table) if $flag;
		$flag = 1;
	# begin new table
		@table = ();
		$table = $1;
		push(@table, "\nTable is $table\n");
	}
	elsif($flag == 1)
	{
		@fieldnames = split;
		$flag = 2;
		push(@table, "Fields are ", join("|", @fieldnames), "\n");
	}
	elsif($flag == 2)
	{
		@fields = split;
		push(@table, join("|", @fields) . "\n");
	}
}

# output last table
print @table;
