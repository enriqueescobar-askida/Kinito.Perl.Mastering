package SeqFileIO;

use base ( "FileIO" );
#our @ISA = ( "FileIO" );

use strict;
use warnings;
#use vars '$AUTOLOAD';
use Carp;

# Class data and methods
{
	# A list of all attributes with defaults and read/write/required/noinit properties
	my %_attribute_properties = (
									_filename    => [ '',	'read.write.required'],
									_filedata    => [ [ ],	'read.write.noinit'],
									_date	     => [ '', 	'read.write.noinit'],
									_writemode   => [ '>',	'read.write.noinit'],
									_format      => [ '',   'read.write'],
									_sequence    => [ '',   'read.write'],
									_header      => [ '',   'read.write'],
									_id          => [ '',   'read.write'],
									_accession   => [ '',   'read.write'],
								);
		
	# Return a list of all attributes
	sub _all_attributes
	{
		keys %_attribute_properties;
	}

	# Check if a given property is set for a given attribute
	sub _permissions
	{
		my($self, $attribute, $permissions) = @_;
		$_attribute_properties{$attribute}[1] =~ /$permissions/;
	}

	# Return the default value for a given attribute
	sub _attribute_default
	{
		my($self, $attribute) = @_;
		$_attribute_properties{$attribute}[0];
	}

	my @_seqfileformats = qw(
								_raw
								_embl
								_fasta
								_gcg
								_genbank
								_pir
								_staden
							);
	
	sub isformat
	{
		my($self) = @_;

		for my $format (@_seqfileformats)
		{
			my $is_format = "is$format";

			if($self->$is_format)
			{
				return $format;
			}
		}
		return '_unknown';
	}
}


# Called from object, e.g. $obj->read();
sub read
{
	my ($self, %arg) = @_;

	# Set attributes
	foreach my $attribute ($self->_all_attributes())
	{
		# E.g. attribute = "_filename",  argument = "filename"
		my($argument) = ($attribute =~ /^_(.*)/);

		# If explicitly given
		if (exists $arg{$argument})
		{
			# If initialization is not allowed
			if($self->_permissions($attribute, 'noinit'))
			{
				croak("Cannot set $argument from read: use set_$argument");
			}
			$self->{$attribute} = $arg{$argument};
			# If not given, but required
		}
		elsif($self->_permissions($attribute, 'required'))
		{
			croak("No $argument attribute as required");
			# Set to the default
		}
		else
		{
			$self->{$attribute} = $self->_attribute_default($attribute);
		}
	}

	# Read file data
	unless( open( FileIOFH, $self->{_filename} ) )
	{
		croak("Cannot open file " .  $self->{_filename} );
	}
	$self->{'_filedata'}= [ <FileIOFH> ];
	$self->{'_date'}	= localtime((stat FileIOFH)[9]);
	$self->{'_format'}	= $self->isformat;
	my $parsemethod = 'parse' . $self->{'_format'};
	$self->$parsemethod;

	close(FileIOFH);
}

sub is_raw
{
	my($self) = @_;

	my $seq = join('', @{$self->{_filedata}} );
	($seq =~ /^[ACGNT\s]+$/) ? return 'raw' : 0;
}

sub is_embl
{
	my($self) = @_;

	my($begin,$seq,$end) = (0,0,0);

	foreach( @{$self->{_filedata}} )
	{
		/^ID\s/ && $begin++;
		/^SQ\s/ && $seq++;
		/^\/\// && $end++;
		(($begin == 1) && ($seq == 1) && ($end == 1)) && return 'embl';
	}
	return	;
}

sub is_fasta
{
	my($self) = @_;
	
	my($flag) = 0;
	
	for(@{$self->{_filedata}})
	{
		#This to avoid confusion with Primer, which can have input beginning ">"
		/^\*seq.*:/i && ($flag == 0) && last;
		if( /^>/ && $flag == 1)
		{
			last;
		}
		elsif( /^>/ && $flag == 0)
		{
			$flag = 1;
		}
		elsif( (! /^>/) && $flag == 0)
		{ #first line must start with ">"
			last;
		}
	}
	$flag ? return 'fasta' : return;
}

sub is_gcg
{
	my($self) = @_;
	
	my($i,$j) = (0,0);
	
	for(@{$self->{_filedata}})
	{
		/^\s*$/ && next;
		/Length:.*Check:/ && ($i += 1);
		/^\s*\d+\s*[a-zA-Z\s]+/ && ($j += 1);
		($i == 1) && ($j == 1) && return('gcg');
	}
	return;
}


sub is_genbank
{
	my($self) = @_;
	
	my $Features = 0;
	
	for(@{$self->{_filedata}})
	{
		/^LOCUS/ && ($Features += 1);
		/^DEFINITION/ && ($Features += 2);
		/^ACCESSION/ && ($Features += 4);
		/^ORIGIN/ &&  ($Features += 8);
		/^\/\// && ($Features += 16);
		($Features == 31) && return 'genbank';
	}
	return;
}

sub is_pir
{
	my($self) = @_;
	
	my($ent,$ti,$date,$org,$ref,$sum,$seq,$end) = (0,0,0,0,0,0,0,0);
	
	for(@{$self->{_filedata}})
	{
		/ENTRY/ && $ent++;
		/TITLE/ && $ti++;
		/DATE/ && $date++;
		/ORGANISM/ && $org++;
		/REFERENCE/ && $ref++;
		/SUMMARY/ && $sum++;
		/SEQUENCE/ && $seq++;
		/\/\/\// && $end++;
		$ent == 1 && $ti == 1 && $date >= 1 && $org >= 1 && $ref >= 1 && $sum == 1 && $seq == 1 && $end == 1 && return 'pir';
	}
	return;
}

sub is_staden
{
	my($self) = @_;
	for(@{$self->{_filedata}})
	{
		/<-+([^-]*)-+>/ && return 'staden';
	}
	0;
}

sub put_raw
{
	my($self) = @_;
	
	my($out);
	($out = $self->{_sequence}) =~ tr/a-z/A-Z/;
	return($out);
}

sub put_embl
{
	my($self) = @_;
	
	my(@out,$tmp,$len,$i,$j,$a,$c,$g,$t,$o);
	
	$len = length($self->{_sequence});
	$a		=	($self->{_sequence} =~ tr/Aa//);
	$c		=	($self->{_sequence} =~ tr/Cc//);
	$g		=	($self->{_sequence} =~ tr/Gg//);
	$t		=	($self->{_sequence} =~ tr/Tt//);
	$o		=	($len - $a - $c - $g - $t);
	$i		=	0;
	$out[$i++] = sprintf("ID   %s %s\n",$self->{_header}, $self->{_id} );
	$out[$i++] = "XX\n";
	$out[$i++] = sprintf("SQ   sequence %d BP; %d A; %d C; %d G; %d T; %d other;\n", $len, $a, $c, $g, $t, $o);
	for($j = 0 ; $j < $len ; )
	{
		$out[$i] .= sprintf("%s",substr($self->{_sequence},$j,10));
		$j += 10;
		if( $j < $len && $j % 60 != 0 )
		{
			$out[$i] .= " ";
		}
		elsif ($j % 60 == 0 )
		{
			$out[$i++] .= "\n";
		}
	}
	if($j % 60 != 0 )
	{
		$out[$i++] .= "\n";
	}
	$out[$i] = "//\n";
	return @out;
}

sub put_fasta
{
	my($self) = @_;
	
	my(@out,$len,$i,$j);
	
	$len = length($self->{_sequence});
	$i = 0;
	$out[$i++] = "> " . $self->{_header} . "\n";
	for($j=0; $j<$len ; $j += 50)
	{
		$out[$i++]=sprintf("%.50s\n",substr($self->{_sequence},$j,50));
	}
	return @out;
}

sub put_gcg
{
	my($self) = @_;
	
	my(@out,$len,$i,$j,$cnt,$sum);
	$len = length($self->{_sequence});
	
	#calculate Checksum
	for($i=0; $i<$len ;$i++)
	{
		$cnt++;
		$sum += $cnt * ord(substr($self->{_sequence},$i,1));
		($cnt == 57)&& ($cnt=0);
	}
	$sum %= 10000;
	
	$i = 0;
	$out[$i++] = sprintf("%s\n",$self->{_header});
	$out[$i++] = sprintf("    %s Length: %d (today)  Check: %d  ..\n", $self->{_id}, $len, $sum);
	for($j = 0 ; $j < $len ; )
	{
		if( $j % 50 == 0)
		{
			$out[$i] = sprintf("%8d  ",$j+1);
		}
		$out[$i] .= sprintf("%s",substr($self->{_sequence},$j,10));
		$j += 10;
		if( $j < $len && $j % 50 != 0 )
		{
			$out[$i] .= " ";
		}
		elsif ($j % 50 == 0 )
		{
			$out[$i++] .= "\n";
		}
	}
	if($j % 50 != 0 )
	{
		$out[$i] .= "\n";
	}
	return @out;
}


sub put_genbank
{
	my($self) = @_;
	
	my(@out,$len,$i,$j,$cnt,$sum);
	my($seq) = $self->{_sequence};
	
	$seq =~ tr/A-Z/a-z/;
	$len = length($seq);
	for($i=0; $i<$len ;$i++)
	{
		$cnt++;
		$sum += $cnt * ord(substr($seq,$i,1));
		($cnt == 57) && ($cnt=0);
	}
	$sum %= 10000;
	$i = 0;
	$out[$i++] = sprintf("LOCUS       %s       %d bp\n",$self->{_id}, $len);
	$out[$i++] = sprintf("DEFINITION  %s , %d bases, %d sum.\n", $self->{_header}, $len, $sum);
	$out[$i++] = sprintf("ACCESSION  %s\n", $self->{_accession}, );
	$out[$i++] = sprintf("ORIGIN\n");
	for($j = 0 ; $j < $len ; )
	{
		if( $j % 60 == 0)
		{
			$out[$i] = sprintf("%8d  ",$j+1);
		}
		$out[$i] .= sprintf("%s",substr($seq,$j,10));
		$j += 10;
		if( $j < $len && $j % 60 != 0 )
		{
			$out[$i] .= " ";
		}
		elsif($j % 60 == 0 )
		{
			$out[$i++] .= "\n";
		}
	}
	if($j % 60 != 0 )
	{
		$out[$i] .= "\n";
		++$i;
	}
	$out[$i] = "//\n";
	return @out;
}

sub put_pir
{
	my($self) = @_;
	
	my($seq) = $self->{_sequence};
	my(@out,$len,$i,$j,$cnt,$sum);
	$len = length($seq);
	for($i=0; $i<$len ;$i++)
	{
		$cnt++;
		$sum += $cnt * ord(substr($seq,$i,1));
		($cnt==57) && ($cnt=0);
	}
	$sum %= 10000;
	$i = 0;
	$out[$i++] = sprintf("ENTRY           %s\n",$self->{_id});
	$out[$i++] = sprintf("TITLE           %s\n",$self->{_header});
	#JDT ACCESSION out if defined
	$out[$i++] = sprintf("DATE            %s\n",'');
	$out[$i++] = sprintf("REFERENCE       %s\n",'');
	$out[$i++] = sprintf("SUMMARY         #Molecular-weight %d  #Length %d  #Checksum %d\n",0,$len,$sum);
	$out[$i++] = sprintf("SEQUENCE\n");
	$out[$i++] = sprintf("                5        10        15        20        25        30\n");
	for($j=1; $seq && $j < $len ; $j += 30)
	{
		$out[$i++] = sprintf("%7d ",$j);
		$out[$i++] = sprintf("%s\n", join(' ',split(//,substr($seq, $j - 1,length($seq) < 30 ? length($seq) : 30))) );
	}
	$out[$i++] = sprintf("///\n");
	return @out;
}


sub put_staden
{
	my($self) = @_;
	
	my($seq) = $self->{_sequence};
	my($i,$j,$len,@out);
	
	$i = 0;
	$len = length($self->{_sequence});
	$out[$i] = ";\<------------------\>\n";
	substr($out[$i],int((20-length($self->{_id}))/2),length($self->{_id})) = $self->{_id};
	$i++;
	for($j=0; $j<$len ; $j+=60)
	{
		$out[$i++]=sprintf("%s\n",substr($self->{_sequence},$j,60));
	}
	return @out;
}

sub parse_raw
{
	my($self) = @_;
	
	## Header and ID should be set in calling program after this 
	my($seq);
	
	$seq = join('',@{$self->{_filedata}});
	if( ($seq =~ /^([acgntACGNT\-\s]+)$/))
	{
		($self->{_sequence} = $seq) =~ s/\s//g;
	}
	else
	{
		carp("parse_raw failed");
	}
}


sub parse_embl
{
	my($self) = @_;
	
	my($begin,$seq,$end,$count) = (0,0,0,0);
	my($sequence,$head,$acc,$id);
	
	for(@{$self->{_filedata}})
	{
		++$count;
		if(/^ID/)
		{
			$begin++;
			/^ID\s*(.*\S)\s*/ && ($id = ($head = $1)) =~ s/\s.*//;
		}
		elsif(/^SQ\s/)
		{
			$seq++;
		}
		elsif(/^\/\//)
		{
			$end++;
		}
		elsif($seq == 1)
		{
			$sequence .= $_;
		}
		elsif(/^AC\s*(.*(;|\S)).*/)
		{ #put this here - AC could be sequence
			$acc .= $1;
		}
		if($begin == 1 && $seq == 1 && $end == 1)
		{
			$sequence =~ tr/a-zA-Z//cd;
			$sequence =~ tr/a-z/A-Z/;
			$self->{_sequence} = $sequence;
			$self->{_header} = $head; 
			$self->{_id} = $id;
			$self->{_accession} = $acc;
			return 1;
		}
	}
	return;
}

sub parse_fasta
{
	my($self) = @_;
	
	my($flag,$count) = (0,0);
	my($seq,$head,$id);
	
	for(@{$self->{_filedata}})
	{
		#avoid confusion with Primer, which can have input beginning ">"
		/^\*seq.*:/i && ($flag = 0) && last;
	
		if(/^>/ && $flag == 1)
		{ 
			last;
		}
		elsif(/^>/ && $flag == 0)
		{
			/^>\s*(.*\S)\s*/ && ($id=($head=$1)) =~ s/\s.*//;
			$flag=1;
		}
		elsif( (! /^>/) && $flag == 1)
		{
			$seq .= $_;
		}
		elsif( (! /^>/) && $flag == 0)
		{
			last;
		}
		++$count;
	}
	if($flag)
	{
		$seq =~ tr/a-zA-Z-//cd;
		$seq =~ tr/a-z/A-Z/;
	
		$self->{_sequence} 	= $seq;
		$self->{_header} 	= $head;
		$self->{_id} 		= $id;
	}
}


sub parse_gcg
{
	my($self) = @_;
	
	my($seq,$head,$id);
	my($count,$flag) = (0,0);
	
	for(@{$self->{_filedata}})
	{
		if(/^\s*$/)
		{ 
			;
		}
		elsif($flag == 0 && /Length:.*Check:/)
		{
			/^\s*(\S+).*Length:.*Check:/;
			$flag=1;
			($id=$1) =~ s/\s.*//;
		}
		elsif($flag == 0 && /^\S/)
		{
			($head = $_) =~ s/\n//; 
		}
		elsif($flag == 1 && /^\s*[^\d\s]/)
		{
			last;
		}
		elsif($flag == 1 && /^\s*\d+\s*[a-zA-Z \t]+$/)
		{
			$seq .= $_;
		}
		$count++;
	}
	$seq =~ tr/a-zA-Z//cd;
	$seq =~ tr/a-z/A-Z/;
	$head = $id unless $head;
	
	$self->{_sequence} = $seq;
	$self->{_header} = $head;
	$self->{_id} = $id;
	
	return 1;
}


sub parse_genbank
{
	my($self) = @_;
	
	my($count,$features,$flag,$seqflag) = (0,0,0,0);
	my($seq,$head,$id,$acc);
	
	for(@{$self->{_filedata}})
	{
		if( /^LOCUS/ && $flag == 0 )
		{
			/^LOCUS\s*(.*\S)\s*$/;
			($id=($head=$1)) =~ s/\s.*//;
			$features += 1;
			$flag = 1;
		}
		elsif( /^DEFINITION\s*(.*)/ && $flag == 1)
		{
			$head .= " $1";
			$features += 2;
		}
		elsif( /^ACCESSION/ && $flag == 1 )
		{
			/^ACCESSION\s*(.*\S)\s*$/;
			$head .= " ".($acc=$1);
			$features += 4;
		}
		elsif( /^ORIGIN/ )
		{
			$seqflag = 1;
			$features += 8;
		}
		elsif( /^\/\// )
		{
			$features += 16;
		}
		elsif( $seqflag == 0 )
		{
			; 
		}
		elsif($seqflag == 1)
		{ 
			$seq .= $_;
		}
		++$count;
		if($features == 31)
		{
			$seq =~ tr/a-zA-Z//cd;
			$seq =~ tr/a-z/A-Z/;
		
			$self->{_sequence} 	= $seq;
			$self->{_header} 	= $head;
			$self->{_id}		= $id;
			$self->{_accession}	= $acc;
		
			return 1;
		}
	}
	return;
}

sub parse_pir
{
	my($self) = @_;
	
	my($begin,$tit,$date,$organism,$ref,$summary,$seq,$end,$count) = (0,0,0,0,0,0,0,0,0);
	my($flag,$seqflag) = (0,0);
	my($sequence,$header,$id,$acc);
	
	for(@{$self->{_filedata}})
	{
		++$count;
		if( /^ENTRY\s*(.*\S)\s*$/ && $flag == 0 )
		{
			$header=$1;
			$flag=1;
			$begin++;
		}
		elsif( /^TITLE\s*(.*\S)\s*$/ && $flag == 1 )
		{
			$header .= $1;
			$tit++;
		}
		elsif( /ORGANISM/ )
		{
			$organism++;
		}
		elsif( /^ACCESSIONS\s*(.*\S)\s*$/ && $flag == 1 )
		{
			($id=($acc=$1)) =~ s/\s*//;
		}
		elsif( /DATE/ )
		{
			$date++;
		}
		elsif( /REFERENCE/ )
		{
			$ref++;
		}
		elsif( /SUMMARY/ )
		{
			$summary++;
		}
		elsif( /^SEQUENCE/ )
		{
			$seqflag = 1;
			$seq++;
		}
		elsif( /^\/\/\// && $flag == 1 )
		{
			$end++;
		}
		elsif( $seqflag == 0)
		{
			next;
		}
		elsif( $seqflag == 1 && $flag == 1)
		{
			$sequence .= $_;
		}
		if	( $begin == 1 && $tit == 1 && $date >= 1 && $organism >= 1
				&& $ref >= 1 && $summary == 1 && $seq == 1 && $end == 1 
			)
		{
			$sequence =~ tr/a-zA-Z//cd;
			$sequence =~ tr/a-z/A-Z/;
		
			$self->{_sequence} = $seq;
			$self->{_header} = $header;
			$self->{_id} = $id;
			$self->{_accession} = $acc;
		
			return 1;
		}
	}
	return;
}



sub parse_staden
{
	my($self) = @_;
	
	my($flag,$count) = (0,0);
	my($seq,$head,$id);
	for(@{$self->{_filedata}})
	{
		if( /<---*\s*(.*[^-\s])\s*-*--->(.*)/ && $flag == 0 )
		{
		$id = $head = $1;
		$seq .= $2;
		$flag = 1;
		}
		elsif( /<---*(.*)-*--->/ && $flag == 1 )
		{
			$count--;
			last;
		}
		elsif( $flag == 1 )
		{
			$seq .= $_;
		}
		++$count;
	}
	if( $flag )
	{
		$seq =~ s/-/N/g;
		$seq =~ tr/a-zA-Z-//cd;
		$seq =~ tr/a-z/A-Z/;
	
		$self->{_sequence} = $seq;
		$self->{_header} = $head;
		$self->{_id} = $id;
	
		return 1;
	}
	return;
}

sub parse_unknown
{
	return;
}

1;
