#/usr/bin/perl

use strict;
use warnings;
#use lib "/home/tisdall/MasteringPerlBio/development/lib";
use Rebase;

{
	print " Use with 'bionetfile' to create and populate a dbm file\n";
	my $rebase = Rebase->new(dbmfile => 'BIONET',
							bionetfile => 'bionet.212',
							mode => 0644);
	
	my $enzyme = 'EcoRI';
	
	print "Looking up restriction enzyme $enzyme\n";
	
	my @sites = $rebase->get_recognition_sites($enzyme);
	print "Sites are @sites\n";
	
	my @res = $rebase->get_regular_expressions($enzyme);
	print "Regular expressions are @res\n";
	
	print "DBM file is ", $rebase->get_dbmfile, "\n";
	print "Rebase bionet file is ", $rebase->get_bionetfile, "\n";
}

{
	print " Use without 'bionetfile' to attach to existing dbm file\n";
	my $rebase = Rebase->new(dbmfile => 'BIONET',
								mode => 0444);
	
	my $enzyme = 'EcoRI';
	
	print "Looking up restriction enzyme $enzyme\n";
	
	my @sites = $rebase->get_recognition_sites($enzyme);
	print "Sites are @sites\n";
	
	my @res = $rebase->get_regular_expressions($enzyme);
	print "Regular expressions are @res\n";
	
	print "DBM file is ", $rebase->get_dbmfile, "\n";
	print "Rebase bionet file is ", $rebase->get_bionetfile, "\n";
}
