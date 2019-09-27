# Velvet
by [utz/irrlicht project](http://irrlichtproject.de) 09'2019


## About

Velvet is a [PFM](https://en.wikipedia.org/wiki/Pulse_Frequency_Modulation)
sound engine for the ZX Spectrum beeper with support for Crushed Additive Random
Noise, a type of velvet noise [first described by Kurt James Werner](http://dafx2019.bcu.ac.uk/papers/DAFx2019_paper_53.pdf).

It features 3 tone channels and a dedicated noise channel, all with volume
envelopes. Additionally, an interrupting, customizable kick drum is availble.
Synthesis runs at 14583 Hz (240 cycles per core loop).


## Data Format

Velvet's music data format follows the usual sequence/pattern approach.

The sequence determines the overall structure of the song. It must be listed at
the start of the music data. It consists of a list of words, which are pointers
to patterns. The sequence end must be marked with a 0-word, followed by a word
defining the loop point within the sequence. The loop word can be omitted if
looping has been disabled in main.asm (by setting the LOOPING variable to 0).

Patterns are units containing one or more rows of notes and effect parameters.
Rows are constructed as follows:

offset (byte) | function
--------------|---------------------------------------------------------------
0             | control byte 1 (see below)
1             | unused, reserved for further use
2             | envelope pointer noise channel
4             | envelope pointer tone channel 1
6             | frequency divider tone channel 1
8             | envelope pointer tone channel 2
10            | frequency divider tone channel 2
12            | control byte 2 (see below)
13            | row length in ticks
14            | envelope pointer tone channel 3
16            | frequency divider tone channel 3
18            | kick drum volume ((1..7)<<4)
19            | kick drum length in half-ticks
20            | kick drum sweep speed (bit mask, more bits ~ faster sweep)
21            | kick drum initial pitch (0x1f is a good default)
22            | kick drum decay mode (one of `NO_DECAY, LINEAR_DECAY, LINEAR_DECAY_X2, EXPONENTIAL_DECAY`)

The bits in control byte 1 have the following significance when set:

bit | function
----|-------------
0   | skip noise update (omit data bytes 2-3)
2   | skip tone channel 1 update (omit data bytes 4-7)
6   | end of pattern
7   | skip tone channel 2 update (omit data bytes 8-11)

The bits in control byte 2 have the following significance:

bit | function
----|-----------
0   | if set and bit 7 also set, row length -= 1/2 tick
6   | if set, skip tone channel 3 update (omit data bytes 14-17)
7   | if not set, do not play kick drum (omit data bytes 18-23)

Velvet does NOT automatically adjust the row length after a kick drum is played.
This means you must account for this by subtracting (kick_length / 2) from the
row length (data byte 13). If the kick drum's length is an odd value, you also
need to set bit 0 of control byte 2.

#### Envelopes

Envelopes can have arbitrary length, and envelope values are 8-bit. A 0-byte
marks the end of an envelope. For noise, values of 8 and higher are recomended.
Lower values may be useful when the tone channels are busy, but when used on
solo noise parts, they will cause an unpleasent, cyclic sound. For tones, it is
recommended to stay in the range of 1..8, otherwise drop-outs may occur.
