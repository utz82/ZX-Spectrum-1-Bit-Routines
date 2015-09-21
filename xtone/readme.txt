********************************************************************************
xtone beeper routine for ZX Spectrum
by utz 09'2015
********************************************************************************

Features
********

- 6 channels with square wave sound (sort of)
- 16-bit frequency precision
- variable duty cycle
- per-step speed control
- 3 interrupting click drums


Requirements
************

The following tools are required to use the xm2xtone utility

- an XM tracker, for example Milkytracker (http://milkytracker.org)
- pasmo or a compatible Z80 assembler (http://pasmo.speccy.org)
- Perl (http://www.perl.org/get.html)

pasmo and Perl must be installed in your search path, or must reside within the
xtone folder.


Composing Music
***************

You can compose music for the xtone player using the XM template that comes
bundled with xtone. However, this will only give a very rough estimate of how 
the music will sound on an actual ZX Spectrum.

When using the XM template, consider the following:

- You may not change the number of channels.
- Notes must be in channel 1-6.
- Drums must be in channel 7-8, and you cannot set more than one per row.
- Changes to the BPM value or to the instruments have no effect.
- You may change the speed value globally, or at any point by using command Fxx, 
  where xx must be in the range of 0-$1f.
- The note range is limited from C-0 to B-5.
- You may set note detune with command E5x.
- All other effect commands, as well as volume settings will be ignored.

When you're done composing, simply run the provided compile.bat (Win) resp.
compile.sh scripts to generate a .tap file of your music. If you only want to
generate the music data, run xm2xtone.pl without any arguments.



Data Format
***********

xtone music data consists of a song sequence, followed by the pattern data. The 
song sequence is a list of pointers to the actual note patterns, in the order in
which they are played. The sequence is terminated by a 0-word. At some point in 
the sequence you must specify the label "loop", which is where the player will 
jump to after it has completed the sequence. The shortest possible sequence would
thus be:

loop
	dw ptn00
	dw 0

Following this are the note patterns. Each row in the patterns consists of 9
words (18 bytes).

word 1: speed * 256 + drum triggers (1 = kick, 5 = snare, $81 = hihat)
word 2: duty ch1 * 256 + duty ch2 * 16 + duty ch3 + duty ch4/16
word 3: duty ch5 * 256 + duty ch6
word 4: frequency ch1
word 5: frequency ch2
word 6: frequency ch3
word 7: frequency ch4
word 8: frequency ch5
word 9: frequency ch6

In order to mute a channel, simply set the frequency to 0.

Note patterns are terminated with a single $40 byte.

