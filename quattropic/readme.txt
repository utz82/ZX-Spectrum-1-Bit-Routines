********************************************************************************
quattropic by utz 08'2015
4 channel beeper engine for ZX Spectrum
********************************************************************************


About
*****

quattropic offers 4 channels of square wave tone with variable pulse width. One
of the channels can be used play noise of varying length, pitch, and timbre.
Furthermore, you can activate a fast pitch slide on one of the channels to 
produce percussive sounds. You can switch between the modes (tone/noise/slide) 
on a step-by-step basis.

The quattropic package includes the ZMakeBas utility by Russell Marks.


Requirements
************

The following tools are required to convert an XM to a quattropic binary:

- an XM tracker, for example Milkytracker (http://milkytracker.org)
- pasmo or a compatible Z80 assembler (http://pasmo.speccy.org)

pasmo must be installed in your search path, or must reside within the
quattropic folder.

When compiling the quattropic package from source, you first need to build 
xm2quattropic.cpp and zmakebas.c.


Composing Music
***************

You can compose music for the quattropic routine using the provided XM template.
This has a few drawbacks, however. First of all, the template gives only a rough
estimate of how the music will sound on an actual ZX Spectrum. Secondly, you can
not take care of the engine's full capabilities this way, as it would be too
complex to simulate via XM.

When using the XM template, consider the following:

- Do not change the number of channels.
- Changing the BPM setting has no effect.
- Instruments 1-4 (tone) can be in any channel.
- Instruments 5-8 (noise) can only be used in channel 4.
- Instruments 9-A (slide) can only be used in channel 3.

The pitch of the noise instruments impacts timbre, but not necessarily the 
actual pitch. Also, octaves are disregarded for noise instruments. The XM
template does not accurately reproduce this behaviour.

The slide instruments (9, A) will reset on every row. This behaviour is not
reproduced in the XM template.

You can use effect ECx (note cut) on channel 4. You can also use effect E5x
(detune) on all of the channels. All other effects will be ignored.

Channels are not 100% equal in volume. Channel 3 is slightly louder than the
rest. There are only marginal differences between the other channels.

By default, the player will loop back to the start of the song. You can change
the loop point manually, by moving the "loop" label in music.asm to another
row in the sequence. You can disable looping altogether by uncommenting line 47
in main.asm.

When you're done with composing, simply run the provided compile.cmd resp. 
compile.sh scripts to convert your XM file into a ZX Spectrum .tap file. 

compile.cmd/.sh will accept the following optional parameters (in the exact 
order listed here):

  -t "song title"
  -c "composer name"
  -a address (must be a decimal number between 32768 and ~60000)
  
Example: compile.cmd -t "My Song" -c "Great Musician" -a 40000
This will create a BASIC screen which reads "My Song by Great Musician", and 
assemble the player+data at address 40000.

Alternatively, you can use interactive-compile.cmd/.sh to interactively set
these parameters.


Data Format
***********

quattropic music data defines an 8-bit tempo value at offset 0. The higher the
value, the slower the tempo.

This is followed by the song sequence. The song sequence is a list of pointers
to the actual note patterns, in the order in which they are played. The 
sequence is terminated by a 0-word. At some point in the sequence you must
specify the label "loop", which is where the player will jump to after it has
completed the sequence. The shortest possible sequence would thus be:

loop
	dw ptn00
	dw 0

Following this are the note patterns. Each row in the patterns consists of 7
words, resp 14 bytes.

word 1: (speed - note length) * 256 + play mode (0 = tone, 1 = noise, 
        4 = slide, $80 = noise+slide)
word 2: duty ch1 * 256 + duty ch2
word 3: duty ch3 * 256 + duty ch4 (duty can also be set for noise/slide)
word 4: frequency ch1
word 5: frequency ch2
word 6: frequency ch3
word 7: frequency ch4

In order to mute a channel, simply set the frequency to 0.

Note patterns are terminated with a $40 byte.