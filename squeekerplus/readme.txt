********************************************************************************
SQUEEKER PLUS
by utz 07'2016 * www.irrlichtproject.de
********************************************************************************

ABOUT
=====

Squeeker Plus is a 1-bit/beeper engine for the Sinclair ZX Spectrum. It is based 
on an original concept developed by zilogat0r for his Squeeker beeper engine.


FEATURES
========

- 4 tone channels, mixed PFM/PWM synthesis
- 2 interrupting click drums
- per-tick duty cycle envelopes
- channels 1 and 2 can play fixed-pitch noise instead of square waves
- channel 4 can use a fast pitch slide for drum simulation
- mixing at approx. 9511 Hz.


REQUIREMENTS
============

The following tools are required to use the xm2octode2k16 utility

- an XM tracker, for example Milkytracker (http://milkytracker.org) or OpenMPT
  (http://openmpt.org)
- pasmo or a compatible Z80 assembler (http://pasmo.speccy.org)

pasmo must be installed in your search path, or must reside within the
squeekerplus folder.


COMPOSING MUSIC
===============

You can use the included XM template to compose music for Squeeker Plus.
However, this will only give a very rough approximation of how the music will
sound on an actual ZX Spectrum, even more so since not all of the engine's
features can be simulated properly in the template. Also, Squeeker Plus has 

The following restrictions apply:

- The number of channels is fixed.
- The BPM value is fixed. The Speed value can be changed, however.
- Only the provided samples may be used; instruments can be cloned however (see
  below).
- All other effects are ignored, except for the following:
  Bxx - set loop point
  E5x - set detune (only effective for the current note)
  Fxx - set Speed (= number of ticks per row, xx <= $1f). It is reset to the 
        global value at the beginning of a new pattern.
- Click drums should be used in channel 5/6. Only one click drum can be active
  on a given pattern row.
- Click drums and the noise instrument have their pitch fixed at C-4.

A duty cycle envelope can be applied to tone, noise, and pitch slide 
instruments. This can be done in two ways:

1) By setting a value in the volume column ($40 is assumed if no value is set).
2) By enabling the volume envelope in the instrument settings. This method will
   override setting the duty via the pattern volume column. Envelope looping and
   sustain are not supported.
   
Note that running all channels with high duty cycle values will cause the engine
to overload, effectively decreasing overall sound quality.

Very low duty cycle settings may mute the current note. The actual threshold at 
which dropouts will occur depends on the note frequency.
   
In order to use multiple duty cycle envelopes, you will want to clone the
provided sample instruments. To do so, simply load one of the provided .xi
instruments into a free instrument slot. You may rename cloned instruments, but
you may not change the sample data.


The click drums cannot be cloned, and must remain in slots 1 and 2.


CONVERTING
==========

Running one of the provided compile scripts will convert your .xm file into
a .tap file that you can then load on a ZX Spectrum or an emulator.

compile.sh/.cmd will accept the following optional parameters, in this exact 
order:

  -t "song title"
  -c "composer name"
  -a address*
  
Example: compile.cmd -t "My Song" -c "Great Musician"
This will create a BASIC screen which reads "My Song by Great Musician".

Alternatively, you can use interactive-compile.cmd/.sh to interactively set
these parameters.

*The compile address will default to 32768 ($8000), but can be set to any other
location in uncontended RAM.


MUSIC DATA
==========

The music data for Squeeker Plus is split in three sections: Sequence, patterns,
and duty cycle envelopes.

The sequence section must come first. It consists of a list of pointers to the
patterns, in the order in which they are meant to be played. The list must be
terminated with a 0-word. Also, a label named "loop" must be present; this
specifies the location the player will loop to once it has completed the
sequence. The shortest possible sequence section is thus:

loop
	dw pattern0
	dw 0


After the sequence section, patterns and duty cycle sections will follow in 
arbitrary order (even mixing the two is possible).


Patterns consist of one or more rows of note data. The rows are constructed as
follows:

1)  speed + control byte A

The speed is given as (ticks*256). Set bits in the control byte have the
following effect:

bit 0 - skip freq/env reload for ch1
bit 2 - skip freq/env reload for ch2
bit 6 - end of pattern
bit 7 - skip freq/env reload for ch3

On the first row of a pattern, control byte A is always 0, ie. all channel
frequencies and envelope pointers must be set.

2)  noise enable control ch1/2

The high byte sets noise for ch1, the low byte sets noise for ch2. $cb to enable
noise, $00 to disable it.

3)  frequency ch1
4)  envelope pointer ch1
5)  freq ch2
6)  env ch2
7)  freq ch3
8)  env ch3

9)  control byte B

The high byte is always 0. the bits in the low byte have the following effect:

bit 0 - enable pitch slide ch4
bit 2 - trigger click drum 1 (kick)
bit 6 - skip freq/env reload for ch4
bit 7 - trigger click drum 2 (hihat)

10) freq ch4
11) freq ch5

Each entry is one word long. Entries 1, 2, and 9 are mandatory, the rest is
optional, their presence depending on the control bytes. If control byte A is
$40, no further data follows for this pattern.


Duty-cylce envelopes consist of one or more single-byte entries with values
between $00 and $40. They must be terminated with a $80 byte. The shortest valid
envelope is thus

env1
	db $40,$80
