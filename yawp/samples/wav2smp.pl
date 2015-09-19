#!/usr/bin/perl

use strict;
use warnings;
use Fcntl qw(:seek);

print "\nWAV2SMP CONVERTER\n";
print "Convert unsigned 8-bit PCM WAV to QAOP sample format\n";
print "Error.\nUsage: [perl] [./]wav2smp.pl <volume (1..3)> <infile.wav> [<outfile.smp>]\n" and die if ($#ARGV < 1 || $#ARGV > 2);

my $volume = $ARGV[0];
$volume = 3 if ($volume > 3);

#check if infile is present, and open it if it is
my $infile = $ARGV[1];
print "$infile not found\n" and die $! if (!-e $infile);
open INFILE, $infile or die "Could not open $infile: $!";
binmode INFILE;

#create outfile
my $outfile;
if ($#ARGV == 1) {
	$outfile = $infile.'.smp';
	open OUTFILE, ">$outfile" or die $!;
	}
else {
	$outfile = $ARGV[2];
	open OUTFILE, ">$outfile" or die $!;
	}

#convert
my $filesize = -s $infile;

print "Converting...\n";
my $ix;
my $jx;
my $fileoffset = 0;
my $inbyte;


for ($ix = 1; $ix < 17; $ix++) {
	print OUTFILE "\n\tdb ";
	for ($jx = 1; $jx < 17; $jx++) {
		$fileoffset = 0 if (($ix*$jx) >= $filesize);
		print "$fileoffset\n";
		sysseek(INFILE, $fileoffset, 0) or die $!;
		sysread(INFILE, $inbyte, 1) == 1 or die $!;
		$inbyte = ord($inbyte);
		$inbyte = abs($inbyte-127)*2;
		$inbyte = int(($inbyte*$volume)/256);
		$inbyte = 0x70 if ($inbyte == 3);
		$inbyte = 0x30 if ($inbyte == 2);
		$inbyte = 0x10 if ($inbyte == 1);
		$fileoffset++;
		print OUTFILE "$inbyte";
		print OUTFILE "," if ($jx < 16);
		}
	}



