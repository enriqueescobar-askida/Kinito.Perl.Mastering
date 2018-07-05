#!/usr/bin/perl

use strict;
use warnings;
#use lib "/home/tisdall/MasteringPerlBio/development/lib";

use SeqFileIO;

#
# First test basic FileIO operations
#  (plus format attribute)
#

my $obj = SeqFileIO->new();

$obj->read(
			filename => 'file1.txt'
			);

print "The file name is ", $obj->get_filename, "\n";
print "The contents of the file are:\n", $obj->get_filedata;
print "\nThe date of the file is ", $obj->get_date, "\n";
print "The format of the file is ", $obj->get_format, "\n";

$obj->set_date('today');

print "The reset date of the file is ", $obj->get_date, "\n";

print "The write mode of the file is ", $obj->get_writemode, "\n";

print "\nResetting the data and filename\n";
my @newdata = ("line1\n", "line2\n");

$obj->set_filedata( \@newdata );

print "Writing a new file \"file2.txt\"\n";

$obj->write(filename => 'file2.txt');

print "Appending to the new file \"file2.txt\"\n";

$obj->write(filename => 'file2.txt',
			writemode => '>>');

print "Reading and printing the data from \"file2.txt\":\n";

my $file2 = SeqFileIO->new();

$file2->read(
				filename => 'file2.txt'
			);

print "The file name is ", $file2->get_filename, "\n";
print "The contents of the file are:\n", $file2->get_filedata;
print "The format of the file is ", $file2->get_format, "\n";

print <<'HEADER';


##########################################
#
# Test file format recognizing and reading
#
##########################################

HEADER

my $genbank = SeqFileIO->new();
$genbank->read(
				filename => 'record.gb'
				);
print "The file name is ", $genbank->get_filename, "\n";
print "\nThe date of the file is ", $genbank->get_date, "\n";
print "The format of the file is ", $genbank->get_format, "\n";
print "The contents of the file are:\n", $genbank->get_filedata;

print "\n####################\n####################\n####################\n";

my $raw = SeqFileIO->new();
$raw->read(
			filename => 'record.raw'
			);
print "The file name is ", $raw->get_filename, "\n";
print "\nThe date of the file is ", $raw->get_date, "\n";
print "The format of the file is ", $raw->get_format, "\n";
print "The contents of the file are:\n", $raw->get_filedata;

print "\n####################\n####################\n####################\n";

my $embl = SeqFileIO->new();
$embl->read(
				filename => 'record.embl'
				);
print "The file name is ", $embl->get_filename, "\n";
print "\nThe date of the file is ", $embl->get_date, "\n";
print "The format of the file is ", $embl->get_format, "\n";
print "The contents of the file are:\n", $embl->get_filedata;

print "\n####################\n####################\n####################\n";

my $fasta = SeqFileIO->new();
$fasta->read(
				filename => 'record.fasta'
				);
print "The file name is ", $fasta->get_filename, "\n";
print "\nThe date of the file is ", $fasta->get_date, "\n";
print "The format of the file is ", $fasta->get_format, "\n";
print "The contents of the file are:\n", $fasta->get_filedata;

print "\n####################\n####################\n####################\n";

my $gcg = SeqFileIO->new();
$gcg->read(
			filename => 'record.gcg'
			);
print "The file name is ", $gcg->get_filename, "\n";
print "\nThe date of the file is ", $gcg->get_date, "\n";
print "The format of the file is ", $gcg->get_format, "\n";
print "The contents of the file are:\n", $gcg->get_filedata;

print "\n####################\n####################\n####################\n";

my $staden = SeqFileIO->new();
$staden->read(
				filename => 'record.staden'
				);
print "The file name is ", $staden->get_filename, "\n";
print "\nThe date of the file is ", $staden->get_date, "\n";
print "The format of the file is ", $staden->get_format, "\n";
print "The contents of the file are:\n", $staden->get_filedata;

print "\n####################\n####################\n####################\n";


print <<'REFORMAT';


##########################################
#
# Test file format reformatting and writing
#
##########################################

REFORMAT

print "At this point there are ", $staden->get_count, " objects.\n\n";

print "######\n###### Testing put methods\n######\n\n";

print "\nPrinting staden data in raw format:\n";
print $staden->put_raw;

print "\nPrinting staden data in embl format:\n";
print $staden->put_embl;

print "\nPrinting staden data in fasta format:\n";
print $staden->put_fasta;

print "\nPrinting staden data in gcg format:\n";
print $staden->put_gcg;

print "\nPrinting staden data in genbank format:\n";
print $staden->put_genbank;

print "\nPrinting staden data in PIR format:\n";
print $staden->put_pir;
