VIBRA
by utz 07'2017 * irrlichtproject.de
********************************************************************************


About
=====

Vibra is a ZX Spectrum beeper music engine with two tone channels and a 
dedicated noise channel. The tone channels support customizable vibrato and
slide effects. The vibrato effect has 7 speed settings, and 255 depth levels. 
Effective vibrato speed depends on the note frequency used. Tone channels are 
unbalanced, that means the second channel will play at approx. 80% volume of the
first channel.

The noise channel supports 255 pitch levels, and 127 volume levels. Noise 
generator is only updated if there is enough free CPU time, so data reads etc.
may affect the noise timbre.

The usual interrupting click drums are absent from this engine, as the available
effects should be sufficient to create drum sounds.

The engine reloads song data on the fly during playback, thus mitigating the
common problem of row transition noises for the most part.

Technical details:

- 12-bit note frequency dividers
- 8-bit noise pitch dividers
- 7-bit noise volume
- 3-bit vibrato speed (relative to note frequency)
- 8-bit vibrato depth
- 8-bit slide speed
- mixing at 7812.5 Hz


Composing Music
===============

At the time of writing, there is no dedicated editor/converter for the engine,
so the only possibility is to write music directly in assembly data statements.


Configurable Parameters
=======================

Looping can be configured by defining "looping" as either 1 or 0 in main.asm. If
defined as 1, the player will loop back to the specified loop point once the
song sequence is completed. If defined as 0, the player will exit to BASIC at
the end of the song.


Data Format
===========

Music data for Vibra follows the usual approach: a sequence (order list) is
followed by one or more patterns.

The sequence contains a list of word-length pointers to the actual patterns, in
the order in which they are to be played. The list must be terminated by a 
0-word. If looping is enabled (see above), a loop point must be specified 
somewhere in the sequence by setting the "mloop" label. The shortest valid
sequence is thus:

mloop
    dw ptn0
    dw 0
	
The sequence is followed by one or more patterns, containing the actual note and
effects data. The music data consists of a mandatory control word, followed by
1-5 optional data words. The data is laid out as follows:


word   bits    function
--------------------------------------------------------------------------------
0              control word
       0       if set, skip channel 1 update
       2       if set, skip ch2 update
       6       pattern end marker, see below
       7       if set, skip noise channel update
       8..13   speed (row length)
       14..15  unused (must always be reset)
       
1              frequency divider ch1
       0..11   divider
       15      if set, skip ch1 fx update
       
2              fx settings ch1
       0..7    vibrato depth or slide speed
               Slides will wrap around unless the frequency divider used is a
	       multiple of the slide speed given.
       8..15   fx type: 0 = slide down, 0x80 = slide up, other values = vibrato
       8..14   vibrato speed (higher = slower).
               ATTN: Only the highest set bit is evaluated. If bit 14 is set, 
	       bit 8..13 must be reset (engine will crash otherwise).
	       
3..4           same as word 1..2, but for ch2

5      0..6    noise volume (threshold)
       8..11   noise pitch
       
Bits not mentioned above are ignored.


Patterns must be terminated with "dw #0040". Optional fields are never required,
however you may still wish to set them on the first row of the first pattern in
the sequence.
