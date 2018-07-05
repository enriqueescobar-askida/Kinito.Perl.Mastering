#!/usr/bin/perl

#
# Approximate string matching using dynamic programming
#
#   Find the closest match to the pattern in the text
#

use strict;
use warnings;

my $pattern = 'EIQADEVRL';
print "PATTERN:\n$pattern\n";

my $text = 'SVLQDRSMPHQEILAADEVLQESEMRQQDMISHDE';
print "TEXT:\n$text\n";

my $TLEN = length $text;
my $PLEN = length $pattern;

# D is the Distance matrix, which shows the "edit distance" between
# substrings of the pattern and the text.
# It is implemented as a reference to an anonymous array.
my $D = [];

# The rows correspond to the text
# Initialize row 0 of D.
for (my $t=0; $t <= $TLEN ; ++$t)
{
	$D->[$t][0] = 0;
}

# The columns correspond to the pattern
# Initialize column 0 of D.
for (my $p=0; $p <= $PLEN ; ++$p)
{
	$D->[0][$p] = $p;
}

# Compute the edit distances.
for (my $t=1; $t <= $TLEN ; ++$t)
{
	for (my $p=1; $p <= $PLEN ; ++$p)
	{

		$D->[$t][$p] =

	# Choose whichever of the three alternatives has the least cost
		min3(
			# First alternative
			# The text and pattern may or may not match at this character ...
			substr($text, $t-1, 1) eq substr($pattern, $p-1, 1) 
				? $D->[$t-1][$p-1]  # If they match, no increase in edit distance!
				:  $D->[$t-1][$p-1] + 1,
	
			# Second alternative
				# If the text is missing a character
			$D->[$t-1][$p] + 1,
	
			# Third alternative
				# If the pattern is missing a character
			$D->[$t][$p-1] + 1
			)
	}
}

# Print D, the resulting edit distance array
for (my $p=0; $p <= $PLEN ; ++$p)
{
	for (my $t=0; $t <= $TLEN ; ++$t)
	{
		print $D->[$t][$p], " ";
	}
	print "\n";
}

my @matches = ();
my $bestscore = 10000000;

# Find the best match(es).
# The edit distances appear in the the last row.
for (my $t=1 ; $t <= $TLEN ; ++$t)
{
	if( $D->[$t][$PLEN] < $bestscore)
	{
		$bestscore = $D->[$t][$PLEN];
		@matches = ($t);
	}
	elsif( $D->[$t][$PLEN] == $bestscore)
	{
		push(@matches, $t);
	}
}
	
# Report the best match(es).
print "\nThe best match for the pattern $pattern\n";
print "has an edit distance of $bestscore\n";
print "and appears in the text ending at location";
print "s" if ( @matches > 1);
print " @matches\n";
	

sub min3
{
	my($i, $j, $k) = @_;
	my($tmp);

	$tmp = ($i < $j ? $i : $j);
	$tmp < $k ? $tmp : $k;
}
