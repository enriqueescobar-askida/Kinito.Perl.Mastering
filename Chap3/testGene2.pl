#!/usr/bin/perl

#
# Test the second version of the Gene module
#

use strict;
use warnings;

# Change this line to show the folder where you store Gene2.pm
#use lib "/home/tisdall/MasteringPerlBio/development/lib";
use Gene2;

#
# Create object, print values
#
print "Object 1:\n\n";

my $obj1 = Gene2->new(
						name		=> "Aging",
						organism	=> "Homo sapiens",
						chromosome	=> "23",
						pdbref		=> "pdf9999.ref"
					); 

print $obj1->get_name, "\n";
print $obj1->get_organism, "\n";
print $obj1->get_chromosome, "\n";
print $obj1->get_pdbref, "\n";

#
# Create another object, print values ... some will be unset
#
print "\n\nObject 2:\n\n";

my $obj2 = Gene2->new(
						organism	=> "Homo sapiens",
						name		=> "Aging",
					); 

print $obj2->get_name, "\n";
print $obj2->get_organism, "\n";
print $obj2->get_chromosome, "\n";
print $obj2->get_pdbref, "\n";

#
# Reset some of the values, print them
#
$obj2->set_name("RapidAging");
$obj2->set_chromosome("22q");
$obj2->set_pdbref("pdf9876.ref");

print "\n\n";

print $obj2->get_name, "\n";
print $obj2->get_organism, "\n";
print $obj2->get_chromosome, "\n";
print $obj2->get_pdbref, "\n";

print "\nCount is ", Gene2->get_count, "\n\n";

#
# Create another object, print values: but this fails
# because the "name" value is required (see Gene2.pm)
#
print "\n\nObject 3:\n\n";

my $obj3 = Gene2->new(
						organism	=> "Homo sapiens",
						chromosome	=> "23",
						pdbref		=> "pdf9999.ref"
					); 

print "\nCount is ", Gene2->get_count, "\n\n";
