#!/usr/bin/perl

use strict;
use warnings;
use Fcntl qw(:seek);

print "XM 2 NTROPIC CONVERTER\n";

my $infile = 'music.xm';
my $outfile = 'music.asm';
my $debuglvl;
my $debug = 0;
my $sdebug = 0;
my @notetab = (255, 241, 227, 214, 202, 191, 180, 170, 161, 152, 143, 135, 128, 120, 114, 107, 101, 96, 90, 85, 80, 76, 72, 68, 64, 60, 57, 54, 51, 48, 45, 43, 40, 38, 36, 34, 32, 30, 28, 27, 25, 24, 23, 21, 20, 19, 18, 17, 16, 15, 14, 13, 13, 12, 11, 11, 10, 9, 9, 8, 8, 8, 7, 7, 6, 6, 6, 5, 5, 5, 4, 4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1);

#pass dummy command line parameter if none present
$debuglvl = $#ARGV + 1;
$ARGV[0] = '-0' if ($debuglvl == 0);

#check if music.xm is present, and open it if it is
if ( -e $infile ) {
	print "Converting...\n";
	open INFILE, $infile or die "Could not open $infile: $!";
	binmode INFILE;
} 
else {
	print "$infile not found\n";
	exit 1;
}

#delete music.asm if it exists
unlink $outfile if ( -e $outfile );

#create new music.asm
open OUTFILE, ">$outfile" or die $!;
print OUTFILE "\nptab\n";

#setup variables
my ($binpos, $fileoffset, $ptnoffset, $ix, $uniqueptns, $headlength, $packedlength, $plhibyte, $ptnlengthx, $ptnusage);
use vars qw/$songlength/;
my $detune2 = 0;
my $detune3 = 0;

#check if xm is version 1.04
sysseek(INFILE, 0x3a, 0) or die $!;
sysread(INFILE, $ix, 1) == 1 or die $!;
$ix = ord($ix);
if ($ix <= 3) {
	print "Error: XM version < 1.04. Please use a more recent editor.\n";
	close INFILE;
	close OUTFILE;
	exit 1;
}
print "Using XM version 1.0$ix\n" if ( $ARGV[0] eq '-v' );

#check if module has correct number of channels (4)
sysseek(INFILE, 68, 0) or die $!;
sysread(INFILE, $ix, 1) == 1 or die $!;
if ( ord($ix) != 4 ) {
	print "Error: Invalid number of channels in module\n";
	close INFILE;
	close OUTFILE;
	exit 1;
}

#determine song length
sysseek(INFILE, 64, 0) or die $!;
sysread(INFILE, $songlength, 1) == 1 or die $!;
$songlength = ord($songlength);
print "song length:\t\t $songlength \n" if ( $ARGV[0] eq '-v' );

#determine number of unique patterns
sysseek(INFILE, 70, 0) or die $!;
sysread(INFILE, $uniqueptns, 1) == 1 or die $!;
$uniqueptns = ord($uniqueptns);
print "unique patterns:\t $uniqueptns \n" if ( $ARGV[0] eq '-v' );


#locate the pattern headers within the .xm source file and check pattern lengths
my (@ptnoffsetlist, @ptnlengths);

sysseek(INFILE, 341, 0) or die $!;
sysread(INFILE, $ptnlengthx, 1) == 1 or die $!;
$ptnlengths[0] = ord($ptnlengthx);

$ptnoffsetlist[0] = 336;
$fileoffset = $ptnoffsetlist[0];
print "pattern 0 starts at $ptnoffsetlist[0], length $ptnlengths[0] rows \n" if ( $ARGV[0] eq '-v' );
if ( ($uniqueptns) >= 2 ) {
	for ($ix = 1; $ix < $uniqueptns; $ix++) {
		sysseek(INFILE, $fileoffset, 0) or die $!;	#read ptn header length
		sysread(INFILE, $headlength, 1) == 1 or die $!;
		$headlength = ord($headlength);
		
		$fileoffset = ($fileoffset) + 5;		#read ptn lengths
		sysseek(INFILE, $fileoffset, 0) or die $!;
		sysread(INFILE, $ptnlengthx, 1) == 1 or die $!;
		$ptnlengths[$ix] = ord($ptnlengthx);
		
		$fileoffset = ($fileoffset) + 2;		#read packed data length
		sysseek(INFILE, $fileoffset, 0) or die $!;
		sysread(INFILE, $packedlength, 1) == 1 or die $!;
		$packedlength = ord($packedlength);
		$fileoffset++;
		sysseek(INFILE, $fileoffset, 0) or die $!;
		sysread(INFILE, $plhibyte, 1) == 1 or die $!;
		$packedlength = $packedlength + ord($plhibyte)*256;

		$ptnoffsetlist[$ix] = ($ptnoffsetlist[($ix)-1]) + ($headlength) + ($packedlength);
		print "pattern $ix starts at $ptnoffsetlist[$ix], length $ptnlengths[$ix] rows\n" if ( $ARGV[0] eq '-v' );
		
		$fileoffset = $fileoffset + $packedlength + 1;	#calculate pos of next ptn header
	}
}

#generate pattern sequence
my $ptnval;
for ($fileoffset = 80; $fileoffset < ($songlength+80); $fileoffset++) {
	sysseek(INFILE, $fileoffset, 0) or die $!;
	sysread(INFILE, $ptnval, 1) == 1 or die $!;
	$ptnval = ord($ptnval);
	print OUTFILE "\tdw ptn$ptnval\n";
	#printf(OUTFILE "%x", $ptnval);		
}
print OUTFILE "\tdw 0\n\n";		


#convert pattern data
my (@ch1, @ch2, @ch3, @ch4, @drums, @speed);
my ($rows, $cpval, $temp, $mx, $jx, $nx);
for ($ix = 0; $ix <= ($uniqueptns)-1; $ix++) {

	$ptnusage = IsPatternUsed($ix);

	if ($ptnusage == 1) {

		print OUTFILE "ptn$ix\n";
	
		$fileoffset = 76;				#initialize values
		sysseek(INFILE, $fileoffset, 0) or die $!;
		sysread(INFILE, $jx, 1) == 1 or die $!;
		$speed[0] = ord($jx)*2;
		print "Global speed:\t\t $speed[0]\n" if ( $ARGV[0] eq '-v' && $ix == 0);
		$drums[0] = 0;
		$ch2[0] = 0;	#tone
		$ch3[0] = 0;	#tone
		$ch4[0] = 0;	#noise
	
		$fileoffset = $ptnoffsetlist[$ix] + 9;
	
		for ($rows = 1; $rows <= $ptnlengths[($ix)]; $rows++) {	#Achtung! Row values offset by -1 so we can preload dummy values
			$speed[$rows] = $speed[$rows-1];		#set default speed
			$drums[$rows] = 0;
			$ch2[$rows] = $ch2[$rows-1];
			$ch3[$rows] = $ch3[$rows-1];
			$ch4[$rows] = 0;
		
			for ($mx = 0; $mx <=3; $mx++) {				#reading 4 tracks per row
				sysseek(INFILE, $fileoffset, 0) or die $!;	#read control byte of row
				sysread(INFILE, $cpval, 1) == 1 or die $!;
				$cpval = ord($cpval);
		
				if ($cpval >= 128) {				#if we have compressed data
			
					$fileoffset++;
			
					if ($cpval != 128) {

						sysseek(INFILE, $fileoffset, 0) or die $!;	#read first data byte of row
						sysread(INFILE, $temp, 1) == 1 or die $!;
						$temp = ord($temp);
				
						if (($cpval&1) == 1) {				#if bit 0 is set, it's note -> counter val.		
							if ($temp >= 95 || $temp <=12) {
								$debug++ if ($temp != 97 && $temp != 0);	#correction for stop note signal
								$temp = 0;
							}
							$temp = $notetab[($temp-12)] if (($temp) >= 12 && ($temp) <= 95);
							$ch2[$rows] = $temp if ($mx == 0);
							$ch3[$rows] = $temp if ($mx == 1);
							$ch4[$rows] = 0x30 if ($mx == 2 && $temp != 0);
							$fileoffset++;
							sysseek(INFILE, $fileoffset, 0) or die $!;	#read next byte of row
							sysread(INFILE, $temp, 1) == 1 or die $!;
							$temp = ord($temp);
						}
			
						if (($cpval&2) == 2) {				#if bit 1 is set, it's instrument -> if val = 3..5, set drum val.
							$drums[$rows] = $temp-2 if ($temp == 3 && $drums[$rows] == 0);
							$fileoffset++;
							sysseek(INFILE, $fileoffset, 0) or die $!;	#read next byte of row
							sysread(INFILE, $temp, 1) == 1 or die $!;
							$temp = ord($temp);
						}
			
						if (($cpval&4) == 4) {				#if bit 2 is set, it's volume -> ignore
							$fileoffset++;
							sysseek(INFILE, $fileoffset, 0) or die $!;	#read next byte of row
							sysread(INFILE, $temp, 1) == 1 or die $!;
							$temp = ord($temp);
						}
					
					
						if (($cpval&8) == 8 && $temp == 15) {		#if bit 3 is set and value is $f, it's Fxx command
							$fileoffset++;
							sysseek(INFILE, $fileoffset, 0) or die $!;	#read next byte of row
							sysread(INFILE, $temp, 1) == 1 or die $!;
							$temp = ord($temp);
							if (($cpval&16) == 16 && $temp <= 0x20) {
								$speed[$rows] = $temp * 2;	#setting speed if bit 4 is set
							}
							$fileoffset++;
						}
					
						if (($cpval&8) == 8 && $temp == 14) {		#if bit 3 is set and value is $e
							$fileoffset++;
							sysseek(INFILE, $fileoffset, 0) or die $!;	#read next byte of row
							sysread(INFILE, $temp, 1) == 1 or die $!;
							$temp = ord($temp);
							if (($cpval&16) == 16 && ($temp&0xf0) == 0x50) {	#if upper nibble = 5, it's detune
								$temp = 8 - ($temp&15);			#ignore upper nibble
								$ch2[$rows] = $ch2[$rows] + $temp if ($mx == 0 && ($ch2[$rows] + $temp) >= 1);	#setting detune if bit 4 is set
								$detune2 = $temp if ($mx == 0 && $ch2[$rows] >= 1);
								$ch3[$rows] = $ch3[$rows] + $temp if ($mx == 1 && ($ch3[$rows] + $temp) >= 1);
								$detune3 = $temp if ($mx == 1 && $ch3[$rows] >= 1);
							}
							if (($cpval&16) == 16 && ($temp&0xf0) == 0xc0) {	#if upper nibble = #c, it's note cut
								$ch4[$rows] = ($temp&15) * 2;		#ignore upper nibble and multiply lower by 4
							}
							$fileoffset++;
						}
					}
				}
				else {			#if we have uncompressed data
					$temp = $cpval;
					if ($temp >= 95 || $temp <=12) {
						$debug++ if ($temp != 97 && $temp != 0);
						$temp = 0;
					}
					$temp = $notetab[($temp-12)] if (($temp) >= 12 && ($temp) <= 95);
					$ch2[$rows] = $temp if ($mx == 0);
					$ch3[$rows] = $temp if ($mx == 1);
					$ch4[$rows] = 0x30 if ($mx == 2 && $temp != 0);
					$fileoffset++;
					sysseek(INFILE, $fileoffset, 0) or die $!;	#read next byte of row
					sysread(INFILE, $temp, 1) == 1 or die $!;
					$temp = ord($temp);
				
					$drums[$rows] = $temp-2 if ($temp == 3 && $drums[$rows] == 0);
					$fileoffset++;
					sysseek(INFILE, $fileoffset, 0) or die $!;	#read next byte of row
					sysread(INFILE, $temp, 1) == 1 or die $!;
					$temp = ord($temp);
				
					$fileoffset++;
					sysseek(INFILE, $fileoffset, 0) or die $!;	#read next byte of row
					sysread(INFILE, $temp, 1) == 1 or die $!;
					$temp = ord($temp);
					$cpval = $temp;
				
					$fileoffset++;
					sysseek(INFILE, $fileoffset, 0) or die $!;	#read next byte of row
					sysread(INFILE, $temp, 1) == 1 or die $!;
					$temp = ord($temp);
					if ($cpval == 0x0f) {
						$speed[$rows] = $temp * 2;		#setting speed
					}
					if ($cpval == 0x0e && ($temp&0xf0) == 0x50) {	#set detune
						$temp = 8 - ($temp&15);
						$ch2[$rows] = $ch2[$rows] + $temp if ($mx == 0 && ($ch2[$rows] + $temp) >= 1);	#setting detune if bit 4 is set
						$detune2 = $temp if ($mx == 0 && $ch2[$rows] >= 1);
						$ch3[$rows] = $ch3[$rows] + $temp if ($mx == 1 && ($ch3[$rows] + $temp) >= 1);
						$detune3 = $temp if ($mx == 1 && $ch3[$rows] >= 1);
					}
					if ($cpval == 0x0c && ($temp&0xf0) == 0xc0) {	#if upper nibble = #c, it's note cut
						$ch4[$rows] = ($temp&15) * 2;		#ignore upper nibble and multiply lower by 4
					}
					$fileoffset++;
				
				}
			}
		
			$ch1[$rows] = $speed[$rows] + $drums[$rows];
		
			print OUTFILE "\tdb ",'#';
			printf(OUTFILE "%x", $ch1[$rows]);
			print OUTFILE ',#';
			printf(OUTFILE "%x", $ch2[$rows]);
			print OUTFILE ',#';
			printf(OUTFILE "%x", $ch3[$rows]);
			print OUTFILE ',#';
			printf(OUTFILE "%x", $ch4[$rows]);
			print OUTFILE "\n";
		
			$ch2[$rows] = $ch2[$rows] - $detune2;
			$detune2 = 0;
			$ch3[$rows] = $ch3[$rows] - $detune3;
			$detune3 = 0;
		}
	
		print OUTFILE "\tdb ",'#ff',"\n\n";
	}
}

print "WARNING: $debug out of range note(s) replaced with rests.\n" if ( $debug >= 1);
#print "WARNING: $sdebug invalid tempo value(s) replaced with fallback values.\n" if ( $sdebug >= 1);

print "SUCCESS!\n";

#close files and exit
close INFILE;
close OUTFILE;
exit 0;

#check if a pattern is actually used
sub IsPatternUsed {
my ($fileoffset, $ptnval);
my $usage = 0;
my $patnum = $_[0];
	for ($fileoffset = 80; $fileoffset < ($songlength+80); $fileoffset++) {
	sysseek(INFILE, $fileoffset, 0) or die $!;
	sysread(INFILE, $ptnval, 1) == 1 or die $!;
	$usage = 1 if ($patnum == ord($ptnval));
	}
	return($usage);
}

