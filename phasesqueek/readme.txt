********************************************************************************
Phase Squeek, aka TOUPEE (Totally Overpowered, Utterly Pointless Extreme Engine)
by utz 08'2016 | www.irrlichtproject.de
********************************************************************************


ABOUT
=====

Phase Squeek is ZX Spectrum beeper music routine with a rather complex synth
core based on an unholy fusion of Shiru's Phaser method with zilogat0r's Sqeeker
method.

The engine can be configured in different ways. In it's standard configuration,
it sports two channels, each using two operators coupled together. However, the
operators can also be decoupled and act as independant channels (so up to four-
voice polyphony is possible). Or you can couple both standard channels together
to form a single, all powerful voice.

While operators are coupled, the following settings can be customized on each
channel:

- frequency (independant dividers for each operator)
- duty cycles (independantly for both ops)
- operator phase 
- coupling method (XOR|OR|AND - OR effectively decouples the operators)

Additionally, channel 1 supports the following settings:

- SID-style duty cycle modulation (independantly for both ops)
- Earth Shaker style duty cycle modulation (independantly for both ops)

Channel 2 instead offers a noise mode for operator 1.

All settings can be updated not only between notes, but also on a per-tick basis
via effect tables.

Last but not least, two interrupting click drums are also available.


COMPOSING MUSIC
===============

Unfortunately, the engine is too complex to be simulated via an XM template, and
it is currently not supported by any beeper editors either. So, for the time
being, music can only be hand-coded in asm. Refer to the music data description
for further details.


MUSIC DATA
==========

Phase Squeek's music data follows the usual sequence-pattern approach, with the
addition of one or more fx tables.

The sequence must be at the start of the data section. It is a simple list of
pointers to the patterns, in the order in which they are to be played. It is
terminated with a 0-word. A label named "loop" must also be present, this
specifies the sequence position to which the player will jump once the sequence
has been completed. The shortest valid sequence is thus:

loop
	dw pattern0
	dw 0
	
Patterns use a flexible layout, the details of which are determined by one or
more control words.

The format is a follows:

________________________________________________________________________________

1) ctrl_0 (mandatory for each row)

bit set   function
0         skip FX table pointer update
2         skip updates for this row -> continue with ctrl_3
6         end of pattern
7         skip updates for channel 1 -> continue with ctrl_2
8..15     global coupling method, can be one of
              a0 - AND
	      a8 - XOR
	      b0 - OR (channels decoupled)
	      
If bit 0 is reset, a word-length pointer to an FX table follows.

________________________________________________________________________________

2) ctrl_1

bit set   function
0         skip update of frequency channel 1 operator 1/2
2         skip update of SID/Earth Shaker effects ch1 op1/2
6         skip update of duty cycle setting ch1 op1/2
7         skip update of phase ch1
8..15     ch1 operator coupling method, see ctrl_0

If bit 0 is reset, two word-length frequency divider values follow.
If bit 6 is reset, duty_setting_ch1op1 * 256 + duty_setting_ch1op2 follows.
If bit 2 is reset, two words specifying the SID/ES effect settings follow.
    ES effect takes an arbitrary 8-bit value as argument. 0 disables the effect.
    To enable the SID effect, add 0xce00.
    To disable the SID effect, add 0xc600.
If bit 7 is set, a word specifying the phase offset of ch1 op1 follows.

Note that setting the duty to a value greater than 0x40 or activating the SID
effect on both operators can overload the engine (ie ch2 may be drowned out).

________________________________________________________________________________

3) ctrl_2

Same as for ctrl_1, but specifying parameters for ch2 instead. There is one
exception, however: Setting bit 2 enables the noise generator on ch2 op1 (in
which case it should be fed a suitable seed value via ch2 op1 frequency - 0x2175
usually does a good job). Resetting bit 2 disables the noise generator.

________________________________________________________________________________
	
4) ctrl_3 (mandatory for each row)

bit set   function
6         trigger click drum 1 (kick)
7         trigger click drum 2 (hihat) if bit 6 was reset
8..15     speed (row length in ticks)

________________________________________________________________________________

NOTE: The first row of the first pattern in the song must set all parameters.


The FX table layout is almost the same as the pattern layout. Notable
differences are:

- all operations take effect on fixed-length frames (aka ticks) rather than 
  pattern rows.
- ctrl_3 is omitted.
- ctrl_0 has the following changes:

bit set   function
0         modify FX table pointer. This can be used to create a table loop, or
          to jump to another FX table.
6         stop FX table execution.

If bit 0 is set, a word-length pointer to an FX table location must follow.


VERSION HISTORY
===============

0.1   initial public release

eof.