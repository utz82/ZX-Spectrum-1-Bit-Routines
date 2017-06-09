PYTHA
by utz 06'2017
********************************************************************************

About
=====

Pytha is a two-channel music routine for the ZX Spectrum beeper. It is the first
beeper engine to synthesize triangle waves without the use of wavetables.

Features:

- supported waveforms: triangle, saw, rectangle with arbitrary duty cycle, noise
- LFO-powered modulation effects
- 3 customizable click drums (interrupting)
- 16-bit frequency resolution, 8-bit speed resolution


Composing Music
===============

There is currently no dedicated editor for Pytha. For the time being, the only
choice is to write music directly in Assembly language.


Data Format
===========

Music data for Pytha follows the usual sequence-pattern approach. A sequence,
constituting the order list of the song, is followed by one or more pattern 
blocks containing the actual note data.

The sequence contains a list of pointers to individual patterns, in the order in
which they are meant to be played. The sequence is terminated with a 0-word. 
Unless looping is disabled (by setting USE_LOOP to 0 in main.asm), the sequence 
must contain an "mloop" label, which specifies to the point to which the player 
will loop after the sequence has been completed. The shortest legal sequence is
therefore:

mloop
	dw pattern1
	dw 0
	
Patterns contain one or more rows of note data, which are parsed in consecutive
order.

Pattern rows consist of 1-8 words. These have the following function:

word	bits	function
____________________________________________________________________
0		global row flags and row length
		mandatory for every row
	0	if set, skip channel 2 update
	2	if set, trigger click drum
	6	if set, skip channel 1 update
	7	end marker, see below
	8..15	row length (speed)
____________________________________________________________________
1		drum configuration
		omitted if bit 2 of word 0 is reset
	0..7	drum parameter
		if mode = kick, set the slide speed
		if mode = noise, set the volume
	8..14	if mode = kick, set starting pitch
	14..15	set drum mode:	00 = kick
				10 = noise hi (hihat)
				11 = noise lo (snare)
____________________________________________________________________
2		flags and initial modulator offset channel 1
		omitted if bit 6 of word 0 is set
	0	if set, update only frequency divider
	2	enable/disable noise mode
	6	enable/disable modulator lfo
	8..15	initial modulator offset
		modulator and noise settings are ignored if
		bit 0 is set
____________________________________________________________________
3		waveform channel 1
		omitted if bit 6 of word 0 or bit 0 of word 2 is set
		legal values:	$ac9f = triangle
				$009f = rectangle
				$000f = saw
____________________________________________________________________
4		frequency divider channel 1
		omitted if bit 6 of word 0 is set
____________________________________________________________________
5		flags and initial modulator offset channel 2
		omitted if bit 0 of word 0 is set
	0	if set, update only frequency divider
	2	enable/disable noise mode
	6	enable/disable modulator lfo
	8..15	initial modulator offset
		modulator and noise settings are ignored if
		bit 0 is set
____________________________________________________________________
6		waveform channel 2
		omitted if bit 0 of word 0 or word 5 is set
		legal values see word 3
____________________________________________________________________
7		frequency divider channel 2
		omitted if bit 0 of word 0 is set
	

All values must be set on the first row of the first pattern in the sequence. 
Patterns must be terminated with an end marker, which is a single "db $80".


********************************************************************************
http://irrlichtproject.de
