#!/usr/bin/perl

# webrebase1 - a web interface to the Rebase modules

# To install in web, make a directory to hold your Perl modules in web space
use lib "/var/www/html/re";

use Restrictionmap;
use Rebase;
use SeqFileIO;
use CGI qw/:standard/;

use strict;
use warnings;


print header,
	start_html('Restriction Maps on the Web'),
	h1('<font color=orange>Restriction Maps on the Web</font>'),
	hr,
	start_multipart_form,
	'<font color=blue>',
	h3("1) Restriction enzyme(s)?  "),
	textfield('enzyme'), p,
	h3("2) Sequence filename (fasta or raw format):  "),
	filefield(
				-name=>'fileseq',
				-default=>'starting value',
				-size=>50,
				-maxlength=>200,
			), p,
	strong(em("or")),
	h3("Type sequence:  "),
	textarea(
				-name=>'typedseq',
				-rows=>10,
				-columns=>60,
				-maxlength=>1000,
			), p,
	h3("3) Make restriction map:"),
	submit, p,
	'</font>',
	hr,
	end_form;

if (param())
{
	my $sequence = '';

	# must have exactly one of the two sequence input methods specified
	if(param('typedseq') and param('fileseq'))
	{
		print "<font color=red>You have given a file AND typed in sequence: do only one!</font>", hr;
		exit;
	}
	elsif(not param('typedseq') and not param('fileseq'))
	{
		print "<font color=red>You must give a sequence file OR type in sequence!</font>", hr;
		exit;
	}
	elsif(param('typedseq'))
	{
		$sequence = param('typedseq');
	}
	elsif(param('fileseq'))
	{
		my $fh = upload('fileseq');
		while (<$fh>)
		{
			/^\s*>/ and next; # handles fasta file headers
			$sequence .= $_;
		}
	}

	# strip out non-sequence characters
	$sequence =~ s/\s//g;
	$sequence = uc $sequence;
	my $rebase = Rebase->new(
								#omit "bionetfile" attribute to avoid recalculating the DBM file
								dbmfile => 'BIONET',
								mode => '0444',
							);

	my $restrict = Restrictionmap->new(
										enzyme => param('enzyme'),
										rebase => $rebase,
										sequence => $sequence,
										graphictype => 'text',
									);

	print "Your requested enzyme(s): ",em(param('enzyme')),p,
	"<code><pre>\n";
	(my $paramenzyme = param('enzyme')) =~ s/,/ /g;
	foreach my $enzyme (split(" ", $paramenzyme))
	{
		print "Locations for $enzyme: ",
		join(' ', $restrict->get_enzyme_map($enzyme)), "\n";
	}
	print "\n\n\n";
	print $restrict->get_graphic,
	"</pre></code>\n",
	hr;
}

print end_html;
