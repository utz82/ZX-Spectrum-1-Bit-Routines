#!/usr/bin/perl

use strict;
use warnings;
use Fcntl qw(:seek);

print "XM 2 QAOP CONVERTER\n";

my $infile = 'music.xm';
my $outfile = 'music.asm';
my $debuglvl;
my $debug = 0;
#my $sdebug = 0;

my @notetab = (	 0,
	 0x400,0x43D,0x47D,0x4C2,0x50A,0x557,0x5A8,0x5FE,0x65A,0x6BA,0x721,0x78D,
	 0x800,0x87A,0x8FB,0x984,0xA14,0xAAE,0xB50,0xBFD,0xCB3,0xD74,0xE41,0xF1A,
	 0x1000,0x10F4,0x11F6,0x1307,0x1429,0x155C,0x16A1,0x17F9,0x1966,0x1AE9,0x1C82,0x1E34,
	 0x2000,0x21E7,0x23EB,0x260E,0x2851,0x2AB7,0x2D41,0x2FF2,0x32CC,0x35D1,0x3905,0x3C68,
	 0x4000,0x43CE,0x47D6,0x4C1C,0x50A3,0x556E,0x5A83,0x5FE4,0x6598,0x6BA3,0x7209,0x78D1,
	 0x8000,0x879D,0x8FAD,0x9838,0xA145,0xAADC,0xB505,0xBFC9,0xCB30,0xD745,0xE412,0xF1A2 );
	 
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
my ($binpos, $fileoffset, $ptnoffset, $ix, $uniqueptns, $headlength, $packedlength, $plhibyte, $ptnlengthx, $ptnusage);
use vars qw/$songlength/;


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


#generate pattern sequence
print OUTFILE "sequence\nloop\n";
my $ptnval;
for ($fileoffset = 80; $fileoffset < ($songlength+80); $fileoffset++) {
	sysseek(INFILE, $fileoffset, 0) or die $!;
	sysread(INFILE, $ptnval, 1) == 1 or die $!;
	$ptnval = ord($ptnval);
	print OUTFILE "\tdw ptn$ptnval\n";	
}
print OUTFILE "\tdw 0\n\n;pattern data\n";		


#convert pattern data
my (@ch1, @ch2, @ch3, @ch4, @instr1, @instr2, @drums, @instrlist); # @instr3, @instr4,
my ($rows, $cpval, $temp, $temp2, $mx, $jx, $nx, $drumspeed);
my $detune1 = 0;
my $detune2 = 0;

#determine global speed setting
my @speed;
$fileoffset = 76;
sysseek(INFILE, $fileoffset, 0) or die $!;
sysread(INFILE, $ix, 1) == 1 or die $!;
$speed[0] = ord($ix)*256;


for ($ix = 0; $ix <= ($uniqueptns)-1; $ix++) {

	$ptnusage = IsPatternUsed($ix);

	if ($ptnusage == 1) {

		print OUTFILE "ptn$ix\n";

		#initialize values
		$ch1[0] = 0;
		$ch2[0] = 0;	#tone
		$instr1[0] = 0;
		$instr2[0] = 0;
		$drums[0] = 0;
	
		$fileoffset = $ptnoffsetlist[$ix] + 9;
	
		for ($rows = 1; $rows <= $ptnlengths[($ix)]; $rows++) {	#Achtung! Row values offset by -1 so we can preload dummy values
			$ch1[$rows] = $ch1[$rows-1];
			$ch2[$rows] = $ch2[$rows-1];
			$instr1[$rows] = $instr1[$rows-1];
			$instr2[$rows] = $instr2[$rows-1];
			$speed[$rows] = $speed[$rows-1];
			$drums[$rows] = 0;
		
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
							if ($temp > 84 || $temp < 13) {
								$debug++ if ($temp != 97 && $temp != 0);
								$temp = 0;
							}
							else {		
								$temp = $temp-12;
							}
							$ch1[$rows] = $notetab[$temp] if ($mx == 0);
							$ch2[$rows] = $notetab[$temp] if ($mx == 1);
							$instr1[$rows] = 0 if ($mx == 0 && $ch1[$rows] == 0);
							$instr2[$rows] = 0 if ($mx == 1 && $ch2[$rows] == 0);
							$fileoffset++;
							sysseek(INFILE, $fileoffset, 0) or die $!;	#read next byte of row
							sysread(INFILE, $temp, 1) == 1 or die $!;
							$temp = ord($temp);
						}
			
						if (($cpval&2) == 2) {				#if bit 1 is set, it's instrument
							if ($temp > 3) {
								$instr1[$rows] = $temp if ($mx == 0 && $ch1[$rows] != 0);
								$instr2[$rows] = $temp if ($mx == 1 && $ch2[$rows] != 0);			
							
								push @instrlist, $temp unless (grep(/^$temp$/, @instrlist));
							}
							else {
								$drums[$rows] = 1 if ($temp == 1);
								$drums[$rows] = 5 if ($temp == 2);
								$drums[$rows] = 0x81 if ($temp == 3);
							}
							
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
							if (($cpval&16) == 16 && $temp2 <= 0x20) {
								$speed[$rows] = $temp2*256;	#setting speed if bit 4 is set
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
								$ch1[$rows] = $ch1[$rows] - int($ch1[$rows]*$temp/100) if ($mx == 0);	#setting detune if bit 4 is set
								$detune1 = $temp if ($mx == 1);
								$ch2[$rows] = $ch2[$rows] - int($ch2[$rows]*$temp/100) if ($mx == 1);	#setting detune if bit 4 is set
								$detune2 = $temp if ($mx == 1);								
							}
							$fileoffset++;
						}						
						
					}
				}
				else {			#if we have uncompressed data
					$temp = $cpval;
					if ($temp > 84 || $temp < 13) {
						$debug++ if ($temp != 97 && $temp != 0);
						$temp = 0;
					}
					else {		
						$temp = $temp-12;
					}
					$ch1[$rows] = $notetab[$temp] if ($mx == 0);
					$ch2[$rows] = $notetab[$temp] if ($mx == 1);
					$instr1[$rows] = 0 if ($mx == 0 && $ch1[$rows] == 0);
					$instr2[$rows] = 0 if ($mx == 1 && $ch2[$rows] == 0);
					$fileoffset++;
					sysseek(INFILE, $fileoffset, 0) or die $!;	#read next byte of row
					sysread(INFILE, $temp, 1) == 1 or die $!;
					$temp = ord($temp);
				
					if ($temp > 3) {
						$instr1[$rows] = $temp-3 if ($mx == 0 && $ch1[$rows] != 0);
						$instr2[$rows] = $temp-3 if ($mx == 1 && $ch2[$rows] != 0);			
							
						push @instrlist, $temp unless (grep(/^$temp$/, @instrlist));
					}
					else {
						$drums[$rows] = 1 if ($temp == 1);
						$drums[$rows] = 5 if ($temp == 2);
						$drums[$rows] = 0x81 if ($temp == 3);
					}
							
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
 						$speed[$rows] = $temp*256;			#setting speed
 					}
					if ($cpval == 0x0e && ($temp&0xf0) == 0x50) {	#set detune
						$temp = 8 - ($temp&15);			#ignore upper nibble
						$ch1[$rows] = $ch1[$rows] - int($ch1[$rows]*$temp/100) if ($mx == 0);	#setting detune if bit 4 is set
						$detune1 = $temp if ($mx == 1);
						$ch2[$rows] = $ch2[$rows] - int($ch2[$rows]*$temp/100) if ($mx == 1);	#setting detune if bit 4 is set
						$detune2 = $temp if ($mx == 1);
					}	
					$fileoffset++;
				
				}
			}

			$drumspeed = $speed[$rows] + $drums[$rows];

			print OUTFILE "\tdw #";
			printf(OUTFILE "%x", $drumspeed);
			print OUTFILE ',#';
			printf(OUTFILE "%x", $ch1[$rows]);
			print OUTFILE ',#';
			printf(OUTFILE "%x", $ch2[$rows]);
			print OUTFILE ",instr$instr1[$rows]*256+instr$instr2[$rows]";		#writing instruments as symbols so we can define them later
			print OUTFILE "\n";
			
			$ch1[$rows] = $ch1[$rows] - $detune1;
			$detune2 = 0;
			$ch2[$rows] = $ch2[$rows] - $detune2;
			$detune2 = 0;		
		}
	
		print OUTFILE "\tdb #40\n\n";
	}
}

print "WARNING: $debug out of range note(s) replaced with rests.\n" if ( $debug >= 1);
print "SUCCESS!\n";

#close music.asm and exit
close INFILE;
close OUTFILE;


#generate sample list
$outfile = 'samples.asm';

#delete music.asm if it exists
unlink $outfile if ( -e $outfile );

#create new samples.asm
open OUTFILE, ">$outfile" or die $!;

my @instruments = (	'01-kick1_v4.smp',
			'02-kick1_v5.smp',
			'03-kick-short_v4.smp',
			'04-noise-periodic_v3.smp',
			'05-noise-oneshot_v4.smp',
			'06-noise-short_v3.smp',
			'07-cowbell3.smp',
			'08-square_d50_v4.smp',
			'09-square_d50_v3.smp',
			'0a-square_d50_v2.smp',
			'0b-square_d50_v1.smp',
			'0c-triangle-v4.smp',
			'0d-triangle-oneshot-v4.smp',
			'0e-bellcurve-v4.smp',
			'0f-phat4x_v4.smp',
			'10-square25-v3.smp',
			'11-square25-v2.smp',
			'12-square25-v1.smp',
			'13-pin-v3.smp',
			'14-pin_v2.smp',
			'15-saw-v3.smp',
			'16-fast-triangle-v3.smp',
			'17-pin-chord037.smp',
			'18-full-chord037.smp');

#print OUTFILE "\tds 256,0\t\t\t;00 silence\n";
print OUTFILE "\tinstr0 equ samples/256\t;silence\n";
$jx = 1;
foreach $ix (@instrlist) {
#foreach (@instruments) {
	print OUTFILE "\t",'include "samples/',"$instruments[($ix-4)]",'"',"\n";	#write sample include
	print OUTFILE "\tinstr$ix equ $jx+samples/256\n";				#write instrument equate
	$jx++;
}

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

