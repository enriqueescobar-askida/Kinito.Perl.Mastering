#!/usr/bin/perl

use strict;
use warnings;
#use lib "/home/tisdall/MasteringPerlBio/development/lib";

use FileIO;

my $obj = FileIO->new();

$obj->read(
			filename => 'file1.txt'
			);

print "The file name is ", $obj->get_filename, "\n";
print "The contents of the file are:\n", $obj->get_filedata;
print "\nThe date of the file is ", $obj->get_date, "\n";

$obj->set_date('today');

print "The reset date of the file is ", $obj->get_date, "\n";

print "The write mode of the file is ", $obj->get_writemode, "\n";

print "\nResetting the data and filename\n";
my @newdata = ("line1\n", "line2\n");

$obj->set_filedata( \@newdata );

print "Writing a new file \"file2.txt\"\n";

$obj->write(filename => 'file2.txt');

print "Appending to the new file \"file2.txt\"\n";

$obj->write(filename => 'file2.txt', writemode => '>>');

print "Reading and printing the data from \"file2.txt\":\n";

my $file2 = FileIO->new();

$file2->read(
				filename => 'file2.txt'
			);

print "The file name is ", $file2->get_filename, "\n";
print "The contents of the file are:\n", $file2->get_filedata;
