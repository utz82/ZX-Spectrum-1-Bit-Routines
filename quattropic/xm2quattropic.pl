#!/usr/bin/perl

use strict;
use warnings;
use Fcntl qw(:seek);

print "XM 2 QUATTROPIC CONVERTER\n";

my $infile = 'music.xm';
my $outfile = 'music.asm';
my $debuglvl;
my $debug = 0;
my $sdebug = 0;

my @notetab = (	 0,
	 0xC0, 0xCB, 0xD8, 0xE4, 0xF2, 0x100, 0x110, 0x120, 0x131, 0x143, 0x156, 0x16A,
	 0x180, 0x197, 0x1AF, 0x1C9, 0x1E4, 0x201, 0x21F, 0x23F, 0x262, 0x286, 0x2AC, 0x2D5,
	 0x300, 0x32E, 0x35E, 0x391, 0x3C8, 0x401, 0x43E, 0x47F, 0x4C3, 0x50C, 0x558, 0x5AA,
	 0x600, 0x65B, 0x6BC, 0x723, 0x78F, 0x802, 0x87C, 0x8FD, 0x986, 0xA17, 0xAB1, 0xB54,
	 0xC00, 0xCB7, 0xD78, 0xE45, 0xF1E, 0x1005, 0x10F8, 0x11FB, 0x130D, 0x142E, 0x1562, 0x16A7,
	 0x1800, 0x196D, 0x1AF0, 0x1C8A, 0x1E3D, 0x2009, 0x21F1, 0x23F6, 0x2619, 0x285D, 0x2AC3, 0x2D4E,
	 0x3000, 0x32DB, 0x35E1, 0x3915, 0x3C7A, 0x4013, 0x43E2, 0x47EB, 0x4C32, 0x50BA, 0x5587, 0x5A9D,
	 0x6000, 0x65B5, 0x6BC2, 0x722A, 0x78F4, 0x8025, 0x87C4, 0x8FD6, 0x9864, 0xA174, 0xAB0E, 0xB539 );
	 
my @noisetab = ( 0xcd44, 0x0cba, 0x0744, 0x099a, 0x188b, 0x18bb, 0xdd55, 0xed66, 0xc400, 0xb400, 0x0143, 0xc111,
		 0xcd44, 0x0cba, 0x0744, 0x099a, 0x188b, 0x18bb, 0xdd55, 0xed66, 0xc400, 0xb400, 0x0143, 0xc111,
		 0xcd44, 0x0cba, 0x0744, 0x099a, 0x188b, 0x18bb, 0xdd55, 0xed66, 0xc400, 0xb400, 0x0143, 0xc111,
		 0xcd44, 0x0cba, 0x0744, 0x099a, 0x188b, 0x18bb, 0xdd55, 0xed66, 0xc400, 0xb400, 0x0143, 0xc111,
		 0xcd44, 0x0cba, 0x0744, 0x099a, 0x188b, 0x18bb, 0xdd55, 0xed66, 0xc400, 0xb400, 0x0143, 0xc111,
		 0xcd44, 0x0cba, 0x0744, 0x099a, 0x188b, 0x18bb, 0xdd55, 0xed66, 0xc400, 0xb400, 0x0143, 0xc111,
		 0xcd44, 0x0cba, 0x0744, 0x099a, 0x188b, 0x18bb, 0xdd55, 0xed66, 0xc400, 0xb400, 0x0143, 0xc111,
		 0xcd44, 0x0cba, 0x0744, 0x099a, 0x188b, 0x18bb, 0xdd55, 0xed66, 0xc400, 0xb400, 0x0143, 0xc111 );

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

#determine global speed setting
$fileoffset = 76;
sysseek(INFILE, $fileoffset, 0) or die $!;
sysread(INFILE, $ix, 1) == 1 or die $!;
my $speed = ord($ix);
print OUTFILE "\n\tdb $speed\t\t;speed\n\n";

#generate pattern sequence
print OUTFILE ";sequence\nloop\n";
my $ptnval;
for ($fileoffset = 80; $fileoffset < ($songlength+80); $fileoffset++) {
	sysseek(INFILE, $fileoffset, 0) or die $!;
	sysread(INFILE, $ptnval, 1) == 1 or die $!;
	$ptnval = ord($ptnval);
	print OUTFILE "\tdw ptn$ptnval\n";
	#printf(OUTFILE "%x", $ptnval);		
}
print OUTFILE "\tdw 0\n\n;pattern data\n";		


#convert pattern data
my (@ch1, @ch2, @ch3, @ch4, @duty1, @duty2, @duty3, @duty4, @mode, @nlength);
my ($rows, $cpval, $temp, $temp2, $mx, $jx, $nx, $duty12, $duty34, $modlen, $noteval);
my $detune1 = 0;
my $detune2 = 0;
my $detune3 = 0;
my $detune4 = 0;
for ($ix = 0; $ix <= ($uniqueptns)-1; $ix++) {

	$ptnusage = IsPatternUsed($ix);

	if ($ptnusage == 1) {

		print OUTFILE "ptn$ix\n";

		#$drums[0] = 0;				#initialize values
		$ch1[0] = 0;
		$ch2[0] = 0;	#tone
		$ch3[0] = 0;	#tone/noise
		$ch4[0] = 0;	#tone/slide
		$duty1[0] = 0x80;
		$duty2[0] = 0x80;
		$duty3[0] = 0x80;
		$duty4[0] = 0x80;
		$mode[0] = 0;
		$nlength[0] = 0xff;
	
		$fileoffset = $ptnoffsetlist[$ix] + 9;
	
		for ($rows = 1; $rows <= $ptnlengths[($ix)]; $rows++) {	#Achtung! Row values offset by -1 so we can preload dummy values
			$ch1[$rows] = $ch1[$rows-1];
			$ch2[$rows] = $ch2[$rows-1];
			$ch3[$rows] = $ch3[$rows-1];
			$ch4[$rows] = $ch4[$rows-1];
			$duty1[$rows] = $duty1[$rows-1];
			$duty2[$rows] = $duty2[$rows-1];
			$duty3[$rows] = $duty3[$rows-1];
			$duty4[$rows] = $duty4[$rows-1];
			if ($mode[$rows-1] == 1 || $mode[$rows-1] == 0x80 && $ch4[$rows-1] != 0) {
				$mode[$rows] = 1;
			} else {
				$mode[$rows] = 0;
			}
			@nlength[$rows] = 0xff;
		
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
							$temp = 0 if ($temp == 97);		#silence
							$noteval = $temp;
							$temp = $notetab[$temp];
							$ch1[$rows] = $temp if ($mx == 0);
							$ch2[$rows] = $temp if ($mx == 1);
							$ch3[$rows] = $temp if ($mx == 2);
							$ch4[$rows] = $temp if ($mx == 3);
							$fileoffset++;
							sysseek(INFILE, $fileoffset, 0) or die $!;	#read next byte of row
							sysread(INFILE, $temp, 1) == 1 or die $!;
							$temp = ord($temp);
						}
			
						if (($cpval&2) == 2) {				#if bit 1 is set, it's instrument
							if ($temp == 1 || $temp == 5 || $temp == 9) {
								$duty1[$rows] = 0x80 if ($mx == 0);
								$duty2[$rows] = 0x80 if ($mx == 1);
								$duty3[$rows] = 0x80 if ($mx == 2);
								$duty4[$rows] = 0x80 if ($mx == 3);
							}
							if ($temp == 2 || $temp == 6 || $temp == 10) {
								$duty1[$rows] = 0x40 if ($mx == 0);
								$duty2[$rows] = 0x40 if ($mx == 1);
								$duty3[$rows] = 0x40 if ($mx == 2);
								$duty4[$rows] = 0x40 if ($mx == 3);
							}
							if ($temp == 3 || $temp == 7) {
								$duty1[$rows] = 0x20 if ($mx == 0);
								$duty2[$rows] = 0x20 if ($mx == 1);
								$duty3[$rows] = 0x20 if ($mx == 2);
								$duty4[$rows] = 0x20 if ($mx == 3);
							}
							if ($temp == 4 || $temp == 8) {
								$duty1[$rows] = 0x10 if ($mx == 0);
								$duty2[$rows] = 0x10 if ($mx == 1);
								$duty3[$rows] = 0x10 if ($mx == 2);
								$duty4[$rows] = 0x10 if ($mx == 3);
							}
							print "WARNING: Noise instrument used on wrong channel at ptn $ix\n" if ($temp >= 5 && $temp <= 8 && $mx != 3);
							print "WARNING: Slide instrument used on wrong channel\n" if ($temp >= 9 && $temp <= 10 && $mx != 2);
							$mode[$rows] = 1 if ($mode[$rows] == 0 && $temp >= 5 && $temp <= 8);
							$mode[$rows] = 4 if ($mode[$rows] == 0 && $temp >= 9);
							$mode[$rows] = 0x80 if ($mode[$rows] > 0 && $temp >= 9);
							
							if ($mode[$rows] == 1 || $mode[$rows] == 0x80 && $ch4[$rows] > 0) {
								$ch4[$rows] = $noisetab[$noteval];
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
					
					
# 						if (($cpval&8) == 8 && $temp == 15) {		#if bit 3 is set and value is $f, it's Fxx command
# 							$fileoffset++;
# 							sysseek(INFILE, $fileoffset, 0) or die $!;	#read next byte of row
# 							sysread(INFILE, $temp2, 1) == 1 or die $!;
# 							$temp2 = ord($temp2);
# 							if (($cpval&16) == 16 && $temp2 <= 0x20) {
# 								#$speed[$rows] = $temp2 * 2;	#setting speed if bit 4 is set
# 							}
# 							$fileoffset++;
# 						}
					
						if (($cpval&8) == 8 && $temp == 14) {		#if bit 3 is set and value is $e
							$fileoffset++;
							sysseek(INFILE, $fileoffset, 0) or die $!;	#read next byte of row
							sysread(INFILE, $temp, 1) == 1 or die $!;
							$temp = ord($temp);
							if (($cpval&16) == 16 && ($temp&0xf0) == 0x50) {	#if upper nibble = 5, it's detune
								$temp = 8 - ($temp&15);			#ignore upper nibble
								$ch1[$rows] = $ch1[$rows] - int($ch1[$rows]*$temp/100) if ($mx == 0);	#setting detune if bit 4 is set
								$detune1 = $temp if ($mx == 0);
								$ch2[$rows] = $ch2[$rows] - int($ch2[$rows]*$temp/100) if ($mx == 1);	#setting detune if bit 4 is set
								$detune2 = $temp if ($mx == 1);
								$ch3[$rows] = $ch3[$rows] - int($ch3[$rows]*$temp/100) if ($mx == 2);	#setting detune if bit 4 is set
								$detune3 = $temp if ($mx == 2);
								$ch4[$rows] = $ch4[$rows] - int($ch4[$rows]*$temp/100) if ($mx == 3);	#setting detune if bit 4 is set
								$detune4 = $temp if ($mx == 3);
								
							}
							if (($cpval&16) == 16 && ($temp&0xf0) == 0xc0) {	#if upper nibble = #c, it's note cut
								$nlength[$rows] = $speed - ($temp&15) if ($speed > ($temp&15));		#ignore upper nibble and multiply lower by 2
							}
							$fileoffset++;
						}
					}
				}
				else {			#if we have uncompressed data
					$temp = $cpval;
					$temp = 0 if ($temp == 97);		#silence
					$noteval = $temp;
					$temp = $notetab[$temp];
					$ch1[$rows] = $temp if ($mx == 0);
					$ch2[$rows] = $temp if ($mx == 1);
					$ch3[$rows] = $temp if ($mx == 2);
					$ch4[$rows] = $temp if ($mx == 3);
					$fileoffset++;
					sysseek(INFILE, $fileoffset, 0) or die $!;	#read next byte of row
					sysread(INFILE, $temp, 1) == 1 or die $!;
					$temp = ord($temp);
				
					if ($temp == 1 || $temp == 5 || $temp == 9) {
						$duty1[$rows] = 0x80 if ($mx == 0);
						$duty2[$rows] = 0x80 if ($mx == 1);
						$duty3[$rows] = 0x80 if ($mx == 2);
						$duty4[$rows] = 0x80 if ($mx == 3);
					}
					if ($temp == 2 || $temp == 6 || $temp == 10) {
						$duty1[$rows] = 0x40 if ($mx == 0);
						$duty2[$rows] = 0x40 if ($mx == 1);
						$duty3[$rows] = 0x40 if ($mx == 2);
						$duty4[$rows] = 0x40 if ($mx == 3);
					}
					if ($temp == 3 || $temp == 7) {
						$duty1[$rows] = 0x20 if ($mx == 0);
						$duty2[$rows] = 0x20 if ($mx == 1);
						$duty3[$rows] = 0x20 if ($mx == 2);
						$duty4[$rows] = 0x20 if ($mx == 3);
					}
					if ($temp == 4 || $temp == 8) {
						$duty1[$rows] = 0x10 if ($mx == 0);
						$duty2[$rows] = 0x10 if ($mx == 1);
						$duty3[$rows] = 0x10 if ($mx == 2);
						$duty4[$rows] = 0x10 if ($mx == 3);
					}
					print "WARNING: Noise instrument used on wrong channel at ptn $ix\n" if ($temp >= 5 && $temp <= 8 && $mx != 3);
					print "WARNING: Slide instrument used on wrong channel\n" if ($temp >= 9 && $temp <= 10 && $mx != 2);
					$mode[$rows] = 1 if ($mode[$rows] == 0 && $temp >= 5 && $temp <= 8);
					$mode[$rows] = 4 if ($mode[$rows] == 0 && $temp >= 9);
					$mode[$rows] = 0x80 if ($mode[$rows] > 0 && $temp >= 9);
							
					if ($mode[$rows] == 1 || $mode[$rows] == 0x80 && $ch4[$rows] > 0) {
						$ch4[$rows] = $noisetab[$noteval];
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
# 					if ($cpval == 0x0f) {
# 						#$speed[$rows] = $temp * 2;		#setting speed
# 					}
					if ($cpval == 0x0e && ($temp&0xf0) == 0x50) {	#set detune
						$temp = 8 - ($temp&15);			#ignore upper nibble
						$ch1[$rows] = $ch1[$rows] - int($ch1[$rows]*$temp/100) if ($mx == 0);	#setting detune if bit 4 is set
						$detune1 = $temp if ($mx == 0);
						$ch2[$rows] = $ch2[$rows] - int($ch2[$rows]*$temp/100) if ($mx == 1);	#setting detune if bit 4 is set
						$detune2 = $temp if ($mx == 1);
						$ch3[$rows] = $ch3[$rows] - int($ch3[$rows]*$temp/100) if ($mx == 2);	#setting detune if bit 4 is set
						$detune3 = $temp if ($mx == 2);
						$ch4[$rows] = $ch4[$rows] - int($ch4[$rows]*$temp/100) if ($mx == 3);	#setting detune if bit 4 is set
						$detune4 = $temp if ($mx == 3);
					}
					if ($cpval == 0x0c && ($temp&0xf0) == 0xc0) {	#if upper nibble = #c, it's note cut
						$nlength[$rows] = $speed - ($temp&15) if ($speed > ($temp&15));
					}
					$fileoffset++;
				
				}
			}

			$modlen = ($nlength[$rows]*256)+$mode[$rows];
			$duty12 = $duty1[$rows]*256 + $duty2[$rows];
			$duty34 = $duty3[$rows]*256 + $duty4[$rows];
		
			print OUTFILE "\tdw ",'#';
			printf(OUTFILE "%x", $modlen);
			print OUTFILE ',#';
			printf(OUTFILE "%x", $duty12);
			print OUTFILE ',#';
			printf(OUTFILE "%x", $duty34);
			print OUTFILE ',#';
			printf(OUTFILE "%x", $ch1[$rows]);
			print OUTFILE ',#';
			printf(OUTFILE "%x", $ch2[$rows]);
			print OUTFILE ',#';
			printf(OUTFILE "%x", $ch3[$rows]);
			print OUTFILE ',#';
			printf(OUTFILE "%x", $ch4[$rows]);
			print OUTFILE "\n";
		
			$ch1[$rows] = $ch1[$rows] - $detune1;
			$detune2 = 0;
			$ch2[$rows] = $ch2[$rows] - $detune2;
			$detune2 = 0;
			$ch3[$rows] = $ch3[$rows] - $detune3;
			$detune3 = 0;
			$ch4[$rows] = $ch4[$rows] - $detune4;
			$detune3 = 0;
		}
	
		print OUTFILE "\tdb ",'#40',"\n\n";
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

