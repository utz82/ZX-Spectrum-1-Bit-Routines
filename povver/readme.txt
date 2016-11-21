********************************************************************************
povver v0.1 - 3 channel beeper engine with volume control
by utz 11'2016
********************************************************************************


About
=====

povver is an experimental 3-channel beeper engine for the ZX Spectrum. It 
features a simple volume control mechanism which is achieved through dual 
oscillators running with a phase offset. The results are perhaps not as
impressive as what can be achieved through digital multi-core synthesis, but
it consumes much less RAM.

Aside from volume control, povver also features

- simple volume envelopes
- noise mode for channel 1
- customizable click drums
- per step tempo control
- compact music data format



Composing Music
===============

Currently, no editor exists for povver, so any music must be hand-crafted as
assembly data. See the following section on how to construct the necessary
music.asm files.


Data Format
===========

Music data for povver follows the usual sequence-pattern approach.

The sequence contains one or more pointers to patterns, in the order in which
they are to be played. A label named "mLoop" must be present in the sequence to
determine the position the player will loop to after it has completed the 
sequence. (To disable looping, uncomment lines 27-28 in main.asm.) The sequence 
must be terminated with a 0-byte. The shortest legal sequence is thus:

mLoop
   dw pattern
   dw 0


Patterns contain the actual musical score. povver uses a rather compact scheme


word  bit     function
==========================================================================
0             tempo*256|flags
      0       skip update ch1
      2       skip update ch2
      6       end of pattern (see below)
      7       skip update ch3
      8..15   tempo (row length as number of ticks/frames)

1             freq_div1|volume|envelope_flag (omitted when word 0, bit 0 set)
      0..10   frequency divider ch1
      11..14  initial phase offset (volume) ch1. 0 = loudest, #f = quietest
      15      enable volume envelope ch1
      
2             as above, but for ch2 (omitted when word 0, bit 2 set)

3             as above, but for ch3 (omitted when word 0, bit 3 set)

4             drum|noise_enable
      0       trigger kick
      2       trigger hihat
              Only one drum trigger can be used per row.
      6       enable noise mode ch1 (requires suitable seed as freq_div1)
      8..15   set click drum parameters
              for kick, bit 8..15 = initial pitch (higher value = higher pitch)
	      for noise, bit 8 sets type (lower pitch if set), bit 9..15 sets
	      volume (higher value = louder)

The first pattern in the sequence must set all parameters.
Word 1 must be set at the start of each pattern.
Each pattern must end with a pattern end flag (#40).
