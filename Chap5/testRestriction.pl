#!/usr/bin/perl

#use lib "/home/tisdall/MasteringPerlBio/development/lib";
use Restriction;
use Rebase;
use strict;
use warnings;

my $rebase = Rebase->new(
							dbmfile => 'BIONET',
							bionetfile => 'bionet.212'
						);

my $restrict = Restriction->new(
									rebase => $rebase,
									enzyme => 'EcoRI, HindIII',
									sequence => 'ACGAATTCCGGAATTCG',
								);

print "EcoRI data in Rebase is ", $rebase->{_rebase}{'EcoRI'}, "\n";
print "Sequence is ", 			$restrict->get_sequence, "\n";
print "Locations for EcoRI are ", join(' ', $restrict->get_enzyme_map('EcoRI')), "\n";

