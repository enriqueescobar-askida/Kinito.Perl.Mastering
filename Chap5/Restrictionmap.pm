package Restrictionmap;

use base ( "Restriction" );

#
# A class to find locations of restriction enzyme recognition sites in
#  DNA sequence data, and to display them.
#

use strict;
use warnings;
use Carp;

# Class data and methods
{
	# A list of all attributes with default values.
	my %_attributes = (
							#    key   = restriction enzyme name
							#    value = space-separated string of recognition sites => regular expressions
							_rebase      => { },    # A Rebase.pm object
							_sequence    => '',     # DNA sequence data in raw format (only bases)
							_enzyme      => '',     # space separated string of one or more enzyme names
							_map         => { },    # hash: enzyme names => arrays of locations
							_graphictype => 'text', # one of 'text' or 'png' or some other
							_graphic     => '',     # a graphic display of the restriction map
						);
		
	# Return a list of all attributes
	sub _all_attributes
	{
		keys %_attributes;
	}
}

sub get_graphic
{
	my($self) = @_;

	# If the graphic is not stored, calculate and store it
	unless($self->{_graphic})
	{
		unless($self->{_graphictype})
		{
			croak 'Attribute graphictype not set (default is "text")';
		}

		# if graphictype is "xyz", method that makes the graphic is "_drawmap_xyz"
		my $drawmapfunctionname = "_drawmap_" . $self->{_graphictype};

		# Calculate and store the graphic
		$self->{_graphic} = $self->$drawmapfunctionname;
	}

	# Return the stored graphic
	return $self->{_graphic};
}

#
# Methods to output graphics in text format
#

sub _drawmap_text
{
	my($self) = @_;
	my @annotation = ();
	push(@annotation, _initialize_annotation_text($self->get_sequence));

	foreach my $enzyme ($self->get_enzyme_names)
	{
		_add_annotation_text(\@annotation, $enzyme, $self->get_enzyme_map($enzyme));
	}
	
	# Format the restriction map as sequence and annotation
	my @output = _formatmaptext(50, $self->get_sequence, @annotation);

	# Return output as a string, not an array of lines
	return join('', @output);
}

#  Make a blank string of the same length as the given sequence string 
sub _initialize_annotation_text
{
	my($seq) = @_;

	return ' ' x length($seq);
}

#   Add annotation to an annotation string
sub _add_annotation_text
{
	my($array, $enz, @pos) = @_;

	# $array is a reference to an array of annotations

	# Put the labels for the enzyme name at the correct positions in the annotation
	foreach my $location (@pos)
	{
		# Loop through all the annotation strings as necessary
		for( my $i = 0 ; $i < @$array ; ++$i )
		{
			# If the annotation contains only space characters at that position,
			# insert the annotation
			if(substr($$array[$i], $location-1, length($enz)) eq (' ' x length($enz)))
			{
				substr($$array[$i], $location-1, length($enz)) = $enz;
				last;
				# If the annotation collides, add it to the next annotation string on the
				# next iteration of the "for" loop.
				# But first, if there is not another annotation string, make one
			}
			elsif($i == (@$array - 1))
			{
					push(@$array, _initialize_annotation_text($$array[0]));
			}
		}
	}
}

# Sequence with annotation lines formatted for the page with line breaks
sub _formatmaptext
{
	my($line_length, $seq, @annotation) = @_;
	my(@output) = ();

	# Split strings into lines of $line_length
	for ( my $pos = 0 ; $pos < length($seq) ; $pos += $line_length )
	{
		# Print annotation on top of sequence, using reverse
		foreach my $string ( reverse ($seq, @annotation) )
		{
			# Discard blank lines?
			# if ( substr($string, $pos, $line_length) !~ /[^ \n]/ ) {
			#     next;
			# }
			# Add line to output
			push(@output, substr($string, $pos, $line_length) . "\n");
		}
		# separate the lines
		push(@output,"\n");
	}

	# Return the merged annotation and sequence
	return @output;
}

#
# Method to output graphics in PNG format
#

sub _drawmap_png
{
	my($self) = @_;

	# Get text version of graphic
	my @maptext = split( /\n+/, $self->_drawmap_text);

	# Now make a PNG graphic from the text version
	use GD;

	#
	# Layout information: fonts, margins, image size
	#
	# Use built-in GD fixed-width font 'gdMediumBoldFont' (could use TrueType fonts)
	#
	# Font character size in pixels
	my ($fontwidth, $fontheight) = (gdMediumBoldFont->width, gdMediumBoldFont->height);

	# Margins top, bottom, right, left, and between lines
	my ($tmarg, $bmarg, $rmarg, $lmarg, $linemarg) = (10, 10, 10, 10, 5);

	# Image width is length of line times width of a character, plus margins
	my ($imagewidth) = (length($maptext[0]) * $fontwidth) + $lmarg + $rmarg;

	# Image height is height of font plus margin times number of lines, plus margins
	my ($imageheight) =
			(($fontheight + $linemarg) * (scalar @maptext)) + $tmarg + $bmarg;

	my $image = new GD::Image($imagewidth, $imageheight);

	# First one becomes background color
	my $white 	= $image->colorAllocate(255, 255, 255);
	my $black 	= $image->colorAllocate(0, 0, 0);
	my $red 	= $image->colorAllocate(255, 0, 0);

	# Origin at upper left hand corner
	my ($x, $y) = ($lmarg, $tmarg);

	#
	# Draw the lines on the image
	#
	foreach my $line (@maptext)
	{
		chomp $line;
		# Draw annotation in red
		if($line =~ / /)
		{ #annotation has spaces
			$image->string(gdMediumBoldFont, $x, $y, $line, $red);
			# Draw sequence in black
		}
		else
		{ #sequence
			$image->string(gdMediumBoldFont, $x, $y, $line, $black);
		}
		$y += ($fontheight + $linemarg);
	}

	return $image->png;
}

#
# Method to output graphics in JPEG format
#

sub _drawmap_jpg
{
	my($self) = @_;

	# Get text version of graphic
	my @maptext = split( /\n+/, $self->_drawmap_text);

	# Now make a JPEG graphic from the text version
	use GD;

	#
	# Layout information: fonts, margins, image size
	#
	# Use built-in GD fixed-width font 'gdMediumBoldFont' (could use TrueType fonts)
	#
	# Font character size in pixels
	my ($fontwidth, $fontheight) = (gdMediumBoldFont->width, gdMediumBoldFont->height);

	# Margins top, bottom, right, left, and between lines
	my ($tmarg, $bmarg, $rmarg, $lmarg, $linemarg) = (10, 10, 10, 10, 5);

	# Image width is length of line times width of a character, plus margins
	my ($imagewidth) = (length($maptext[0]) * $fontwidth) + $lmarg + $rmarg;

	# Image height is height of font plus margin times number of lines, plus margins
	my ($imageheight) =
			(($fontheight + $linemarg) * (scalar @maptext)) + $tmarg + $bmarg;

	my $image = new GD::Image($imagewidth, $imageheight);

	# First one becomes background color
	my $white 	= $image->colorAllocate(255, 255, 255);
	my $black 	= $image->colorAllocate(0, 0, 0);
	my $red 	= $image->colorAllocate(255, 0, 0);

	# Origin at upper left hand corner
	my ($x, $y) = ($lmarg, $tmarg);

	#
	# Draw the lines on the image
	#
	foreach my $line (@maptext)
	{
		chomp $line;
		# Draw annotation in red
		if($line =~ / /)
		{ #annotation has spaces
			$image->string(gdMediumBoldFont, $x, $y, $line, $red);
			# Draw sequence in black
		}
		else
		{ #sequence
			$image->string(gdMediumBoldFont, $x, $y, $line, $black);
		}
		$y += ($fontheight + $linemarg);
	}

	return $image->jpeg;
}

=head1 Restrictionmap

Restrictionmap: Given a Rebase object, sequence, and list of restriction enzyme
	names, return the locations of the recognition sites in the sequence

=head1 Synopsis

	use Restrictionmap;

	use Rebase;

	use strict;
	use warnings;

	my $rebase = Rebase->new(
		dbmfile => 'BIONET',
	bionetfile => 'bionet.212'
	);

	my $restrict = Restrictionmap->new(
		rebase => $rebase,
	enzyme => 'EcoRI HindIII',
	sequence => 'ACGAATTCCGGAATTCG',
	graphictype => 'text',
	);

	print "Locations are ", join ' ', $restrict->get_enzyme_map('EcoRI'), "\n";

	print $restrict->get_graphic;

=head1 AUTHOR

James Tisdall

=head1 COPYRIGHT

Copyright (c) 2003, James Tisdall

=cut

1;
