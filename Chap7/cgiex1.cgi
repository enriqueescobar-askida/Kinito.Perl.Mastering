#!/usr/bin/perl

use strict;
use warnings;

use CGI qw/:standard/;

my $time = localtime;

print header,
	start_html('Double stranded RNA can regulate genes'),
	h2('Double stranded RNA can regulate genes'),
	start_form,
	p,
"A recent article in <b>Nature</b> describes the important
discovery of <i>RNA interference</i>, the action of snippets
of double-stranded RNA in suppressing gene expression.",
	p,
"The discovery has provided a powerful new tool in investigating
gene function, and has raised many questions about the
nature of gene regulation in a wide variety of organisms.",
	p,
"This page was created $time.",
	p,
	end_form;
