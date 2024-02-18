********************************************************************************
Octode 2k15 beeper routine for ZX Spectrum
by utz 09'2015
original code by Shiru 02'11
"XL" version by introspec 10'14-04'15
********************************************************************************

Features
********

Octode 2k15 is a rewrite of the original Octode engine by Shiru, resp. the "XL"
mod by introspec. The player has been modified to avoid the detuning issues
found in these earlier versions.

- 8 channels with PFM (pin pulse) sound
- 16-bit frequency precision
- variable duty cycle
- per-step speed control
- 3 interrupting click drums


Requirements
************

The following tools are required to use the xm2octode2k15 utility

- an XM tracker, for example Milkytracker (http://milkytracker.org)
- zmakebas
- pasmo or a compatible Z80 assembler (http://pasmo.speccy.org)
- Perl (http://www.perl.org/get.html)

pasmo and Perl must be installed in your search path, or must reside within the
octode2k15 folder.


Composing Music
***************

You can compose music for the Octode 2k15 player using the XM template that
comes bundled with Octode2k15. However, this will only give a very rough
estimate of how the music will sound on an actual ZX Spectrum.

When using the XM template, consider the following:

- You may not change the number of channels.
- Notes must be in channel 1-8.
- Drums must be in channel 9-10, and you cannot set more than one drum per row.
- Changes to the BPM value or to the instruments have no effect.
- You may change the speed value globally, or at any point by using command Fxx,
  where xx must be in the range of 0-$1f.
- The note range is limited from C-0 to B-5.
- You may set note detune with command E5x.
- All other effect commands, as well as volume settings will be ignored.
- The music data is rather large, so song length is limited to ~30 64-step
  patterns.

By default, Octode 2k15 modules loop back to the start. You can change this
manually by moving the "loop" label in music.asm to another position in the
sequence. To disable looping entirely, uncomment line 37 in main.asm.

When you're done composing, simply run the provided compile.bat (Win) resp.
compile.sh scripts to generate a .tap file of your music. If you only want to
generate the music data, run xm2octode2k15.pl without any arguments.



Data Format
***********

Octode 2k15 music data consists of a song sequence, followed by the pattern data.
The song sequence is a list of pointers to the actual note patterns, in the order
in which they are played. The sequence is terminated by a 0-word. At some point
in the sequence you must specify the label "loop", which is where the player will
jump to after it has completed the sequence. The shortest possible sequence would
thus be:

loop
	dw ptn00
	dw 0

Following this are the note patterns. Each row in the patterns consists of 9
words (18 bytes).

word 1: speed * 256 + drum triggers (1 = kick, 5 = snare, $81 = hihat)
word 2: frequency ch8
word 3: frequency ch1
word 4: frequency ch2
word 5: frequency ch3
word 6: frequency ch4
word 7: frequency ch5
word 8: frequency ch6
word 9: frequency ch7

In order to mute a channel, simply set the frequency to 0.

Note patterns are terminated with a single $40 byte.
