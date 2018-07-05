#!/usr/bin/perl

#
# Test the third version of the Gene module
#

use strict;
use warnings;

# Change this line to show the folder where you store Gene3.pm
#use lib "/home/tisdall/MasteringPerlBio/development/lib";
use Gene3;

print "Object 1:\n\n";

# Create first object
my $obj1 = Gene3->new(
						name		=> "Aging",
						organism	=> "Homo sapiens",
						chromosome	=> "23",
						pdbref		=> "pdf9999.ref"
					); 

# Print the attributes of the first object
print $obj1->get_name, "\n";
print $obj1->get_organism, "\n";
print $obj1->get_chromosome, "\n";
print $obj1->get_pdbref, "\n";
# Test AUTOLOAD failure: try uncommenting one or both of these lines
#print $obj1->get_exon, "\n";
#print $obj1->getexon, "\n";

print "\n\nObject 2:\n\n";

# Create second object
my $obj2 = Gene3->new(
						organism	=> "Homo sapiens",
						name		=> "Aging",
					); 

# Print the attributes of the second object ... some will be unset
print $obj2->get_name, "\n";
print $obj2->get_organism, "\n";
print $obj2->get_chromosome, "\n";
print $obj2->get_pdbref, "\n";

# Reset some of the attributes of the second object
$obj2->set_name("RapidAging");
$obj2->set_chromosome("22q");
$obj2->set_pdbref("pdf9876.ref");
$obj2->set_author("D. Enay");
$obj2->set_date("February 9, 1952");

print "\n\n";

# Print the reset attributes of the second object
print $obj2->get_name, "\n";
print $obj2->get_organism, "\n";
print $obj2->get_chromosome, "\n";
print $obj2->get_pdbref, "\n";
print $obj2->citation, "\n";

# Use a class method to report on a statistic about all existing objects
print "\nCount is ", Gene3->get_count, "\n\n";

print "\n\nObject 3:\n\n";

# Create a third object: but this fails
#  because the "name" value is required (see Gene.pm)
my $obj3 = Gene3->new(
						organism	=> "Homo sapiens",
						chromosome	=> "23",
						pdbref		=> "pdf9999.ref"
					); 

# This line is not reached due to the fatal failure to
#  create the third object
print "\nCount is ", Gene3->get_count, "\n\n";
