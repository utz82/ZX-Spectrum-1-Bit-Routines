********************************************************************************
wtbeep v0.1 - 3 channel beeper engine
by utz 11'2016 * www.irrlichtproject.de
********************************************************************************


About
=====

wtbeep is an experimental 3-channel beeper engine for the ZX Spectrum. It offers
a set of 32 different "waveforms" to chose from. Also included are two click
drums with configurable parameters.


Composing Music
===============

Currently, no editor exists for wtbeep, so any music must be hand-crafted as
assembly data. See the following section on how to construct the necessary
music.asm files.


Waveforms
=========

The following waveforms are available:

#00  50% square
#01  32% square
#02  25% square
#03  19% square
#04  12.5% square
#05  6.25% square
#06  duty sweep (fast)
#07  duty sweep (slow)
#08  duty sweep (very slow)
#09  duty sweep (very slow, inverted start duty)
#0a  duty sweep (slow) +octave
#0b  duty sweep (slow) -octave
#0c  duty sweep (fast) -octave
#0d  vowel 1
#0e  vowel 2
#0f  vowel 3
#10  vowel 4
#11  vowel 5
#12  vowel 6
#13  rasp 1
#14  rasp 2
#15  phat rasp
#16  phat 2
#17  phat 3
#18  phat 4
#19  phat 5
#1a  phat 6
#1b  phat 7
#1c  noise 1
#1d  noise 2
#1e  noise 3
#1f  noise 4

Waveforms #13..#16 and #19..#1b play 2 octaves lower, the lowest octaves are
pretty much useless in these cases.



Data Format
===========

Music data for wtbeep follows the usual sequence-pattern approach.

The sequence contains one or more pointers to patterns, in the order in which
they are to be played. A label named "mLoop" must be present in the sequence to
determine the position the player will loop to after it has completed the 
sequence. (To disable looping, uncomment lines 30-31 in main.asm.) The sequence 
must be terminated with a 0-byte. The shortest legal sequence is thus:

mLoop
   dw pattern
   dw 0


Patterns contain the actual musical score. wtbeep uses a rather compact scheme 
to encode pattern data.


word  bit     function
==========================================================================
0     *       tempo*256|flags
      0       skip update ch1
      2       skip update ch2
      6       end of pattern (see below)
      7       skip update ch3
      8..15   tempo (row length as number of ticks/frames)

1     *       freq_div1|waveform1 (omitted when word 0, bit 0 set)
      0..10   frequency divider ch1
      11..15  waveform ch1
      
2     *       as above, but for ch2 (omitted when word 0, bit 2 set)

3     *       as above, but for ch3 (omitted when word 0, bit 3 set)

4     *       click drum
              Only one drum trigger can be used per row.
	      If no drum trigger is used, the high byte is omitted and only a
	      0-byte is written.
      0       trigger kick
      2       reset sweep counters
      6       trigger hihat
      8..15   click drum parameters
              for kick, bit 8..15 = initial pitch (higher value = higher pitch)
	      for noise, bit 8 sets type (lower pitch if set), bit 9..15 sets
	      volume (higher value = louder)

The first pattern in the sequence must set all parameters.
Word 1 must be set at the start of each pattern.
Each pattern must end with a pattern end flag (#40).

For further information, refer to the example music.asm file, and the equates.h
file.