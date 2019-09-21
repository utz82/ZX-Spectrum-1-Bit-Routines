# ARCHIE
by [utz/irrlicht project](http://irrlichtproject.de) 09'2019


## About

Archie is an experimental 1-bit sound engine for the ZX Spectrum Beeper. It
draws inspiration from other modern beeper engines such as Pytha, povver, and
Tritone Digi.

Archie uses the pulse interleaving technique to create 5 tone channels with
asynchronous volume. The first 4 channels are intended to be used in pairs with
controllable phase offset. This simple setup is useful for producing a range of
different, sometimes surprising effects. The 5th channel is a regular pulse wave
channel with duty cycle control and duty cycle sweep.

Channels 1a and 2a are playing at roughly 1/3rd of the volume of channel 1 and
2, respectively. The 5th channel plays at about 2/3rds of the volume of channel
1/2.

In addition to the tone channels, Archie features an interrupting click drum
channel with 3-bit volume control. Click drums are arbitrary PWM samples played
at 31250 Hz. The core synthesis runs at 15625 Hz (standard 224 cycle loop).


## Example Uses of Async Volume with Phase Offset

Notation   | Explanation
-----------|------------
f1         | frequency divider channel 1
f1a        | frequency divider channel 1a
P1a        | phase offset channel 1a
f2,f2a,P2a | as above, but for channel 2/2a
f3         | frequency divider channel 3
d3         | duty cycle channel 3


**Sine Wave:** To (crudely) simulate a sine wave, use _f1a = 3 * f1_ and
_P1a = 0x1000_. For a more triangle-y sound, combine channel 1a with channel 3
instead, using _d3 = 0_.

**Sine Wave with Additional 7th:** As above, but detune _f1a_ or _f1_ slightly.

**Saw Wave:** Use _f1a = 2 * f3_ and _P1a = 0_

**Volume Control:** Use _f1a = f2a_ with a variable phase offset. _P1a = 0x1000_
will produce the lowest volume.

Examples using channels 1/1a will equally work on channels 2/2a.


## Music Data Format

Archie's music data format follows the common sequence/pattern approach.

The sequence determines the overall structure of the song. It must be listed at
the start of the music data. It consists of a list of words, which are pointers
to patterns. The sequence end must be marked with a 0-word, followed by a word
defining the loop point within the sequence. The loop word can be omitted if
looping has been disabled in main.asm (by setting the LOOPING variable to 0).

Patterns are units containing one or more rows of notes and effect parameters.
Rows are constructed as follows:

offset (byte) | function
--------------|--------------------------------------------------------------
0             | Global Control (see below)
1             | Row Length in ticks
2             | Phase Offset Channel 1a (0..0x1000)
4             | Frequency Divider CH1a (12-bit)
6             | Frequency Divider CH1
8             | Phase Offset CH2a
10            | Frequency Divider CH2a
12            | Frequency Divider CH2
14            | Frequency Divider CH3
16            | CH3 Duty Sweep (0xfd to enable, 0 to disable)
17            | Duty Cycle CH3 (see below)
18            | Drum Control/Length in half ticks (see below)
19            | Drum Volume (3-bit, permitted values are (0x10..0x70) & 0xf0)
20            | pointer to drum sample

#### Global Control

The bits in the global control byte have the following significance

bit | function
----|----------------------------------------
0   | skip CH1 update (omit data bytes 2-7)
2   | skip CH2 update (omit data bytes 8-11)
6   | pattern end marker
7   | skip CH3 update (omit data bytes 12-15)


### Duty Cycle CH3

value    | function
---------|---------
0        | skip duty cycle reset (useful for arpeggios with duty sweep enabled)
0x1..0xf | set duty cycle to 3.125%..46.875%
0x20     | set duty cycle to 50%


#### Drum Control

If the drum control byte (data byte 18) is set to 0, no click drum is played
and data bytes 20-21 are omitted. Otherwise, data byte 18 signifies the drum
length in half ticks (eg. a drum length of 2 equals a row length of 1). The user
must ensure that the drum length does not exceed the row length.
