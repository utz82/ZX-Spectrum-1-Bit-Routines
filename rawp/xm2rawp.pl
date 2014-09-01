#!/usr/bin/perl

use strict;
use warnings;
use Fcntl qw(:seek);

print "XM 2 RAWP CONVERTER\n";

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

#setup variables
my ($binpos, $ptnoffset, $fileoffset, $ix, $uniqueptns, $headlength, $packedlength, $plhibyte, $ptnlengthx);
use vars qw/$songlength/;		#define var globally
my $detune2 = 0;
my $detune3 = 0;
my $inst2 = 0;
my $inst3 = 0;
my $looppoint = 80;

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

$ptnoffsetlist[0] = 336;
$fileoffset = $ptnoffsetlist[0];

for ($ix = 0; $ix < $uniqueptns; $ix++) {
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

	$ptnoffsetlist[($ix+1)] = ($ptnoffsetlist[($ix)]) + ($headlength) + ($packedlength);
	print "pattern $ix starts at $ptnoffsetlist[$ix], length $ptnlengths[$ix] rows\n" if ( $ARGV[0] eq '-v' );
		
	$fileoffset = $fileoffset + $packedlength + 1;	#calculate pos of next ptn header
}


#convert pattern data
my (@ch1, @n2, @ch2, @n3, @ch3, @drums, @speed);
my ($rows, $cpval, $temp, $temp2, $temp3, $mx, $jx, $nx);
for ($ix = 0; $ix <= ($uniqueptns)-1; $ix++) {

	if (IsPatternUsed($ix) == 1) {
		print OUTFILE "_ptn$ix\n";
	
		$fileoffset = 76;				#initialize values
		sysseek(INFILE, $fileoffset, 0) or die $!;
		sysread(INFILE, $jx, 1) == 1 or die $!;
		$speed[0] = ord($jx)*2;
		print "Global speed:\t\t $speed[0]\n" if ( $ARGV[0] eq '-v' && $ix == 0);
		$drums[0] = 0;
		$ch2[0] = 0;	#tone
		$ch3[0] = 0;	#tone
		$n2[0] = 0;	#instrument
		$n3[0] = 0;
	
		$fileoffset = $ptnoffsetlist[$ix] + 9;
	
		for ($rows = 1; $rows <= $ptnlengths[($ix)]; $rows++) {	#Achtung! Row values offset by -1 so we can preload dummy values
			$speed[$rows] = $speed[$rows-1];		#set default speed
			$drums[$rows] = 0;
			$ch2[$rows] = $ch2[$rows-1];
			$ch3[$rows] = $ch3[$rows-1];
			$n2[$rows] = $n2[$rows-1];
			$n3[$rows] = $n3[$rows-1];
		
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
								$n2[$rows] = $temp;
								$n3[$rows] = $temp;
							}
							$temp = $notetab[($temp-12)] if (($temp) >= 12 && ($temp) <= 95);
							$ch2[$rows] = $temp if ($mx == 0);
							$ch3[$rows] = $temp if ($mx == 1);
							$fileoffset++;
							sysseek(INFILE, $fileoffset, 0) or die $!;	#read next byte of row
							sysread(INFILE, $temp, 1) == 1 or die $!;
							$temp = ord($temp);
						}
			
						if (($cpval&2) == 2) {				#if bit 1 is set, it's instrument -> if val = 3..5, set drum val.
							$drums[$rows] = $temp-0x11 if ($temp == 0x12 && $drums[$rows] == 0);
							$n2[$rows] = $temp if ($temp <= 0x11 && $mx == 0);
							$n3[$rows] = $temp if ($temp <= 0x11 && $mx == 1);
							$n3[$rows] = 0 if ($temp == 0x13 && $mx == 1);
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
							sysread(INFILE, $temp2, 1) == 1 or die $!;
							$temp2 = ord($temp2);
							#print "set Fxx to $temp\n";
							if (($cpval&16) == 16 && $temp2 <= 0x20) {
								$speed[$rows] = $temp2 * 2;	#setting speed if bit 4 is set
							}
							$fileoffset++ if (($cpval&16) == 16);
						}
				
						if (($cpval&8) == 8 && $temp == 14) {		#if bit 3 is set and value is $e
							print "set Exx\n";
							$fileoffset++;
							sysseek(INFILE, $fileoffset, 0) or die $!;	#read next byte of row
							sysread(INFILE, $temp3, 1) == 1 or die $!;
							$temp = ord($temp3);
							if (($cpval&16) == 16 && ($temp3&0xf0) == 0x50) {	#if upper nibble = 5, it's detune
								$temp3 = 8 - ($temp3&15);			#ignore upper nibble
								$ch2[$rows] = $ch2[$rows] + $temp3 if ($mx == 0 && ($ch2[$rows] + $temp3) >= 1);	#setting detune if bit 4 is set
								$detune2 = $temp3 if ($mx == 0 && $ch2[$rows] >= 1);
								$ch3[$rows] = $ch3[$rows] + $temp3 if ($mx == 1 && ($ch3[$rows] + $temp3) >= 1);
								$detune3 = $temp3 if ($mx == 1 && $ch3[$rows] >= 1);
							}
							$fileoffset++ if (($cpval&16) == 16);
						}
					
						if (($cpval&8) == 8 && $temp == 1) {		#if bit 3 is set and value is $1, it's pitch slide up
							$fileoffset++;
							$fileoffset++ if (($cpval&16) == 16);
							$n2[$rows] = $n2[$rows] + 0xc0 if ($mx == 0);
							$inst2 = 0xc0 if ($mx == 0);
							$n3[$rows] = $n3[$rows] + 0xc0 if ($mx == 1);
							$inst3 = 0xc0 if ($mx == 1);
						}
					
						if (($cpval&8) == 8 && $temp == 2) {		#if bit 3 is set and value is $2, it's pitch slide down
							$fileoffset++;
							$fileoffset++ if (($cpval&16) == 16);
							$n2[$rows] = $n2[$rows] + 0x80 if ($mx == 0);
							$inst2 = 0x80 if ($mx == 0);
							$n3[$rows] = $n3[$rows] + 0x80 if ($mx == 1);
							$inst3 = 0x80 if ($mx == 1);
						}
					
						if (($cpval&8) == 8 && $temp == 0x0c) {		#if bit 3 is set and value is $c, set loop point
							$fileoffset++;
							sysseek(INFILE, $fileoffset, 0) or die $!;
							sysread(INFILE, $temp, 1) == 1 or die $!;
							$looppoint = ord($temp)+80;
							$fileoffset++ if (($cpval&16) == 16);
						}
					}
					#print "$speed[$rows]\n";
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
					$fileoffset++;
					sysseek(INFILE, $fileoffset, 0) or die $!;	#read next byte of row
					sysread(INFILE, $temp, 1) == 1 or die $!;
					$temp = ord($temp);
				
					$drums[$rows] = $temp-0x11 if ($temp == 0x12 && $drums[$rows] == 0);
					$n2[$rows] = $temp if ($temp <= 0x11 && $mx == 0);
					$n3[$rows] = $temp if ($temp <= 0x11 && $mx == 1);
					$n3[$rows] = 0 if ($temp == 0x13 && $mx == 1);
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
						$ch2[$rows] = $ch2[$rows] + $temp if ($mx == 0 && ($ch2[$rows] + $temp) >= 1);
						$detune2 = $temp if ($mx == 0 && $ch2[$rows] >= 1);
						$ch3[$rows] = $ch3[$rows] + $temp if ($mx == 1 && ($ch3[$rows] + $temp) >= 1);
						$detune3 = $temp if ($mx == 1 && $ch3[$rows] >= 1);
					}
				
					if ($cpval == 1) {				#if value is $1, it's pitch slide up
						$n2[$rows] = $n2[$rows] + 0xc0 if ($mx == 0);
						$inst2 = 0xc0 if ($mx == 0);
						$n3[$rows] = $n3[$rows] + 0xc0 if ($mx == 1);
						$inst3 = 0xc0 if ($mx == 1);
					}
					
					if ($cpval== 2) {				#if value is $2, it's pitch slide down
						$n2[$rows] = $n2[$rows] + 0x80 if ($mx == 0);
						$inst2 = 0x80 if ($mx == 0);
						$n3[$rows] = $n3[$rows] + 0x80 if ($mx == 1);
						$inst3 = 0x80 if ($mx == 1);
					}
				
					if ($cpval == 0x0c) {				#if value is $c, set loop point
						$looppoint = $temp+80;
					}
				
					$fileoffset++;
				
				}
			}
			#print "$speed[$rows]\n";
			$ch1[$rows] = $speed[$rows] + $drums[$rows];
		
			print OUTFILE "\tdb ",'#';
			printf(OUTFILE "%x", $ch1[$rows]);
			print OUTFILE ',#';
			printf(OUTFILE "%x", $n2[$rows]);
			print OUTFILE ',#';
			printf(OUTFILE "%x", $ch2[$rows]);
			print OUTFILE ',#';
			printf(OUTFILE "%x", $n3[$rows]);
			print OUTFILE ',#';
			printf(OUTFILE "%x", $ch3[$rows]);
			print OUTFILE "\n";
		
			$ch2[$rows] = $ch2[$rows] - $detune2;
			$detune2 = 0;
			$ch3[$rows] = $ch3[$rows] - $detune3;
			$detune3 = 0;
			$n2[$rows] = $n2[$rows] - $inst2;
			$inst2 = 0;
			$n3[$rows] = $n3[$rows] - $inst3;
			$inst3 = 0;
		}
	
		print OUTFILE "\tdb ",'#ff',"\n\n";
		
	}
}

#generate pattern sequence
my $ptnval;
print OUTFILE "\n_orderList\n";
for ($fileoffset = 80; $fileoffset < ($songlength+80); $fileoffset++) {
	print OUTFILE "_loop\n" if ($looppoint == $fileoffset);
	sysseek(INFILE, $fileoffset, 0) or die $!;
	sysread(INFILE, $ptnval, 1) == 1 or die $!;
	$ptnval = ord($ptnval);
	print OUTFILE "\tdw _ptn$ptnval\n";	
}
print OUTFILE "\tdw 0\n\tdw _loop\n\n";

print "WARNING: $debug out of range note(s) replaced with rests.\n" if ( $debug >= 1);

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
