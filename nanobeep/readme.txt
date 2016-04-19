********************************************************************************
nanobeep by utz 09'2015 - 04'2016
2 channel beeper engine for ZX Spectrum
********************************************************************************


About
*****

nanobeep is a tiny beeper engine with minimalistic features. It features two
channels of PFM-synthesized tone, with rather large pin pulses. In addition,
there is a single interrupting click drum.

nanobeep comes in three different versions: regular, light, and ultra.

The "ultra" version is just 56 bytes long. However, it does cut some corners in
order to achieve that size. Namely, there is no loop support, no click drum, and
the screen border is not masked. Also, concurrent pin pulses are not duplicated,
meaning that when playing notes whose frequencies are multiples of each other
(for example, C-2 and C-3), the lower note will not be played.

The "light" player is 73 bytes. It adds border masking, loop support, and the
click drum. However, it still does not duplicate concurrent pulses, so it 
suffers from the same issue as the "ultra" version in that respect.

The regular version is 77 bytes. This one has slightly better sound, as it
properly duplicates concurrent pulses.

Only keys Space, A, Q, and L will be checked. A full keyboard check can be added
at the cost of just 2 additional bytes. See the source for details on how to 
implement this.


Requirements
************

The following tools are required to convert an XM track to a nanobeep binary:

- an XM tracker, for example Milkytracker (http://milkytracker.org)
- pasmo or a compatible Z80 assembler (http://pasmo.speccy.org)
- Perl (http://www.perl.org/get.html)

pasmo and Perl must be installed in your search path, or must reside within the
nanobeep folder.



Composing Music
***************

You can compose music for the nanobeep routine using the provided XM template.
This gives only a rough estimate of how the music will sound on an actual 
ZX Spectrum though. 

When using the XM template, consider the following:

- The number of channels cannot be changed.

- Changing the BPM setting has no effect, and tempo can be set only globally.

- You can use effect E5x (detune) on tone channels. All other effects will be
ignored.

- Tones must be in channel 1 or 2. The click drum must be in channel 3 or 4.

- You can use any note from C-0 to B-4. However, low notes will be detuned, and
notes in the 4th octave exceed the Nyquist limit, possibly leading to some
rather strange effects.

By default, the player will loop back to the start of the song. You can change
the loop point manually, by moving the "loop" label in music.asm to another
row in the sequence. You can disable looping altogether by uncommenting line 28
in main.asm.

When you're done with composing, simply run one of the provided compile 
scripts. This will convert your XM file into a ZX Spectrum .tap file. To
convert only the XM file, run xm2nanobeep.pl. To produce the correct data for
the "ultra" version of the player, you must run xm2nanobeep.pl with an 
additional "-u" argument.


Data Format
***********

nanobeep music data defines a 16-bit tempo value at offset 0. The higher the
value, the slower the tempo.

This is followed by the song sequence. The song sequence is a list of pointers
to the actual note patterns, in the order in which they are played. Pointers
must be offset by -1.

The sequence is terminated by a 0-word. At some point in the sequence you must
specify the label "loop", which is where the player will jump to after it has
completed the sequence. The shortest possible sequence would thus be:

loop
	dw ptn00-1
	dw 0

Following this are the note patterns. Each row in the patterns consists of 2-3
bytes.

Byte 1 is the drum and always has the value $fe. This byte is omitted if no 
drum is to be played. In the "ultra" version, this byte is always omitted.
Bytes 2 and 3 are the note vales for channel 2 and 3, respectively.

In order to mute a channel, simply set the frequency to 0.

Note patterns are terminated with a $ff byte.