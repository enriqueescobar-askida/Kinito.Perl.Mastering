#!/usr/bin/perl

#
# GD graphics
#

use strict;
use warnings;
use Carp;
use GD::Graph::bars;

my %dataset = ( 1 => 3,
				2 => 17,
				3 => 34,
				4 => 23,
				5 => 25,
				6 => 20,
				7 => 12,
				8 => 3,
				9 => 1
				);

# create new image
my $graph = new GD::Graph::bars(600, 300);
	
# discover maximum values of x and y for graph parameters
my( $xmax) = sort {$b <=> $a} keys %dataset;
my( $ymax) = sort {$b <=> $a} values %dataset;
# how many ticks to put on y axis
my $yticks = int($ymax / 5) + 1;
	
# define input arrays and enter 0 if undefined x value
my(@xsizes) = (0 .. $xmax);
my(@ycounts) = ();
foreach my $x (@xsizes)
{
	if ( defined $dataset{$x})
	{
		push @ycounts, $dataset{$x};
	}
	else
	{
		push @ycounts, 0;
	}
}

# set parameters for graph
$graph->set(
				transparent		=> 0,
				title			=> "Summary of mutation data",
				x_label			=> 'Mutants per cluster',
				y_label			=> 'Number of mutants',
				x_all_ticks		=> 1,
				y_all_ticks		=> 0,
				y_tick_number	=> $yticks,
				zero_axis		=> 0,
				zero_axis_only	=> 0,
			);
	
# plot the data on the graph
my $gd = $graph->plot(
						[ \@xsizes,
						\@ycounts
						]
					);

# output file
my $pngfile = "gdgraph1.png";
unless(open(PNG, ">$pngfile"))
{
	croak "Cannot open $pngfile:$!\n";
}

# set output file handle PNG to binary stream
# (this is important sometimes, for example doing
# GCI programming on some operating systems
binmode PNG;

# print the image to the output file
print PNG $gd->png;
