********************************************************************************
nanobeep2
by utz 08'2017 * www.irrlichtproject.de
********************************************************************************

ABOUT
=====

nanobeep2 is a tiny sound engine for the ZX Spectrum beeper. Unlike the original
nanobeep, the design goal was not to make the player as small as possible, but
to cram in as much features as possible in less than 100 bytes. 

In it's most basic form, the player takes up 64 bytes of memory. A range of 
additional features can be activated via assembler switches, increasing the size
of the player up to a maximum of 99 bytes.

Core (minimal) player features:

- 2 square wave channels
- global 8-bit tempo resolution
- 8-bit note dividers (~4 octaves, lowest notes may be detuned)
- limited keyboard checking (checks only Space, A, L, Q)

Additional features:

- border masking
- full keyboard checking
- PWM sweep sound
- click drum
- per-pattern tempo setting
- increased note range (6 octaves)


USAGE
=====

There is currently no dedicated editor for the engine, so the only way to make
music for it is to code it directly in assembly.

The player code should be compiled with PASMO.


ASSEMBLER SWITCHES
==================

borderMasking
Mask the coloured stripes in the border. Costs 4 bytes extra, or 6 bytes if the
click drum is also enabled.

fullKeyboardCheck
Implements a full keyhandler that will check all keys. Costs 1 byte extra.

loopToStart
Loop back to the start instead of exiting at the end of a tune. Costs 0 bytes.

pwmSweep
Use a SID-like PWM sweep sound instead of plain square wave for channel 1. Costs
2 bytes.

useDrum
Add a simple interrupting hi-hat like click drum. Tempo offset is not corrected.
Costs 11 bytes.

usePatternSpeed
Allow setting a different tempo value for each pattern. Costs 4 bytes, plus 2
bytes per pattern.

usePrescaling
Allow channels to be shifted 1 octave up or down, effectively increasing the
note range to 6 octaves. Can be set per pattern. Costs 11 bytes, plus 2 bytes
per pattern.


DATA FORMAT
===========

The music data format uses the usual sequence-pattern approach. A sequence of 
pattern pointers (in the order in which they are meant to be played) is followed
by one or more patterns, containing the actual note data.

Sequences must be terminated with a 0-word.

If the usePatternSpeed switch is disabled, you must specify an equate for 
"speed" (0x1..0xff, higher value means slower speed).

Pattern structure is as follows:

1) If the usePatternSpeed switch is enabled, speed is set with a 0-byte, 
   followed by the actual speed value (higher means slower speed).
2) If the usePrescaling switch is enabled, two bytes specifying the prescaling
   for channel 2 and channel 1 follow. Legal values are 0xf (scale down), 0x0 
   (no scaling), and 0x7 (scale up).
3) One or more rows of note data follow. First byte sets the note for channel 1,
   second byte sets channel 2. If the useDrum switch is enabled, then the first
   byte is set to 0xfe to trigger the drum sound, followed by note data for ch1
   and ch2. On rows with no drum, the drum data byte is omitted. Legal note 
   values are 0x1 - 0xfd. 0x0 specifies a rest.
4) Mandatory pattern end marker, a single 0xff byte follows.
