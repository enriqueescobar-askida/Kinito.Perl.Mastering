#!/usr/bin/perl

use strict;
use warnings;

my $time = localtime;

print "Content-type: text/html\n\n";

print <<EndOfHTML;
<html>
<head>
<title>Double stranded RNA can regulate genes</title>
</head>
<body>
<h2>Double stranded RNA can regulate genes</h2>
<p>A recent article in <b>Nature</b> describes the important
discovery of <i>RNA interference</i>, the action of snippets
of double-stranded RNA in suppressing gene expression.
</p>
<p>
The discovery has provided a powerful new tool in investigating
gene function, and has raised many questions about the
nature of gene regulation in a wide variety of organisms.
</p>
<p>
This page was created $time.
</p>
</body>
</html>
EndOfHTML
