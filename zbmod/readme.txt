********************************************************************************
zbmod beeper routine for ZX Spectrum
by utz 06'2016
********************************************************************************


About
=====

zbmod is a simple mod player for the ZX Spectrum beeper. It mixes 3 channels of 
PCM WAV samples in realtime, at a rate of approximately 9.1 KHz.

zbmod comes in two different flavours - for NMOS and CMOS Z80 CPUs. Original
ZX models use an NMOS CPU, most clones use a CMOS CPU. It's easy to tell which 
CPU your Spectrum is sporting - if you get no sound and/or white stripes in the 
border area with the NMOS version, you've got a CMOS CPU.

The NMOS/CMOS versions do not work properly on emulators, they will produce a
high-pitched parasite tone. Hence, a special emulator version has been included,
which will counter-act this problem to some extend.


Requirements
============

The following tools are required to use the xm2octode2k16 utility

- an XM tracker, for example Milkytracker (http://milkytracker.org) or OpenMPT
  (http://openmpt.org)
- pasmo or a compatible Z80 assembler (http://pasmo.speccy.org)

pasmo must be installed in your search path, or must reside within the
zbmod folder.


Composing Music
===============

You can compose music for the zbmod player by converting ordinary 4-channel
XMs with the included xm2zbmod utility.

Any XM fed into xm2zbmod will be subject to these restrictions:

- The XM must have exactly 4 channels.
- Any data in the 4th channel is ignored.
- The note range is limited from C#0 to C-4. Notes in the lowest octaves may be
  detuned.
- All sample data must be 8-bit. (Milkytracker has a built-in command to convert
  samples to 8-bit via the "Optimize" menu.)
- Ping-pong and one-shot sample looping are not supported.
- The amount of samples you can use is restricted by the Spectrum's memory. A
  warning will be issued either by the converter or the assembler if the limit
  has been exceeded. Normally, you should get away with around 100 KB of sample
  data.
- Instrument settings are ignored.
- All notes will be cut at the end of a pattern.
- The global BPM must be set to 86, and cannot be changed.
- You may change the speed value globally, or at any point by using command Fxx, 
  where xx must be in the range of 0-$1f.
- You may set note detune with command E5x.
- You may set the sequence loop point with command Bxx.
- All other effect commands, including volume settings will be ignored.
- The resulting sound quality will of course be much, much lower.


By default, zbmod will loop until a key is pressed. To disable looping,
uncomment line 57 in main.asm.

When you're done with composing, simply run the provided compile.cmd resp. 
compile.sh scripts to convert your XM file into ZX Spectrum .tap files (see the
"About" section for details on the different output files). 

compile.cmd/.sh will accept the following optional parameters (in the exact 
order listed here):

  -t "song title"
  -c "composer name"
  -a address
  
Example: compile.cmd -t "My Song" -c "Great Musician"
This will create a BASIC screen which reads "My Song by Great Musician".

Alternatively, you can use interactive-compile.cmd/.sh to interactively set
these parameters.

HINT 1: If you get a lot of noise between rows, you can manually adjust the 
nextFrame pointers in the sample data. These normally point to "core0". Increase
the value after "core" until the noise is reduced. The maximum is "core21".

HINT 2: It is usually a good idea to send your samples through a low-pass filter
with a cutoff of around 4400 Hz, because any frequency above this threshold will
produce aliasing sounds in zbmod.



Data Format
===========

SAMPLE DATA

Sample data is maintained in two files, "samples.asm" and "sampletab.asm".
"samples.asm" contains the actual sample data. It starts with an obligatory 
entry that looks like this:

smp0	db 1,0
	
After this, an arbitrary number of PCM samples may follow. Each sample should
be prefixed by a label, and end with a 0-byte. The actual sample data is 
unsigned and may contain values from 1 (lowest relative volume - not 0!) to 8
(highest relative volume).

"sampletab.asm" contains a list of pointers to the samples in "samples.asm".
There are two list entries for every sample. The first is the sample loop point-
if you don't want the sample to loop set this value to "smp0". The second value
is the actual pointer to the start of the sample, ie. the label you used in 
"samples.asm". The first line in the sample table must be

	dw smp0,smp0

This is the "silent sample", you use this to mute a channel.

MUSIC DATA

zbmod music data consists of a song sequence, followed by one or more patterns.

The song sequence is a list of pointers to the patterns, in the order in which
they are to be played. The sequence must contain the label "loop" somewhere,
this is where the player will loop to once it has finished the sequence. The
sequence list must be terminated with a 0-word. The shortest possible sequence
thus looks like this:

loop             ;loop point
     dw ptn00    ;pointer to pattern 0
     dw 0        ;end marker
     
Patterns consist of one or more rows of note and instrument data. The layout is
as follows:

First byte is the flag byte. Flags are

bit 0 - data for channels 3 is omitted
bit 2 - data for channels 2 is omitted
bit 6 - data for channels 1 is omitted
bit 7 - pattern end

The second byte is the row length in ticks.

If bit 6 of the flag byte is cleared, the next byte sets the sample for channel
1. It is an 8-bit pointer to an entry in the sample table (sampletab.asm). Thus, 
to use sample 1, you would set this byte to 4 (because each entry is 4 bytes and
the silent sample is the first entry in the table). This is followed by an 8-bit 
frequency counter value.

If bit 2 of the flag byte is cleared, data for channel 2 follows. This works the
same as for channel 1.

If bit 0 of the flag byte is cleared, data for channel 3 follows. This works 
like with the other channels, but after the sample and frequency bytes you must
add a data word pointing directly to the desired sample (not to the table).

All pattern rows are terminated by a word-length pointer to next core to be 
executed in the player. This sets the initial relative volume for this row. It 
is often sufficient to set this to "core0" (ie. starting volume = 0), however 
for cleaner sound you might want to point to another of zbmod's 22 cores.

Note: On the first row of each pattern, you must set the data for all channels
(ie. flag must be 0). Also, each pattern must be terminated with a stand-alone
flag byte set to 0x80.