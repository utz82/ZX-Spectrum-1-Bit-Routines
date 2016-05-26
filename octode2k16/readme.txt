********************************************************************************
Octode 2k16 beeper routine for ZX Spectrum
by utz 05'2016
original code by Shiru 02'11
"XL" version by introspec 10'14-04'15
********************************************************************************


About
=====

Octode 2k16 is yet another rewrite of the Octode beeper routine (written by 
Shiru in 2011). More accurately, it is a rewrite of Octode PWM with cleaner
sound and an improved frequency range. However, unlike Octode PWM it does not 
feature variable duty cycles.

- 8 channels with square wave sound
- 16-bit frequency precision
- per-step speed control
- 3 interrupting click drums
- drum volume can be controlled to some extend

Octode 2k16 comes in two versions - for NMOS and CMOS Z80 CPUs. Most original 
ZX models use an NMOS CPU, most clones use a CMOS CPU. It's easy to tell which 
CPU your Spectrum is sporting - if you get no sound and/or white stripes in the 
border area with the NMOS version, you've got a CMOS CPU. For emulators, the 
NMOS version will usually be the right choice.


Requirements
============

The following tools are required to use the xm2octode2k16 utility

- an XM tracker, for example Milkytracker (http://milkytracker.org) or OpenMPT
  (http://openmpt.org)
- pasmo or a compatible Z80 assembler (http://pasmo.speccy.org)

pasmo must be installed in your search path, or must reside within the
octode2k16 folder.


Composing Music
===============

You can compose music for the Octode 2k16 player using the XM template that 
comes bundled with Octode 2k16. However, this will only give a very rough 
estimate of how the music will sound on an actual ZX Spectrum.

When using the XM template, consider the following:

- You may not change the number of channels.
- Tones must be in channel 1-8.
- The note range is limited from C-0 to B-6. Beware that notes above C-5 will
  be aliased.
- Drums should be in channel 9-10, and you can only use one drum per row.
- Drums have a fixed pitch, mapped to C-4 in the template.
- You can use the volume column to set the drum's volume. This is most effective
  on the hihat, it has little effect on the kick.
- Changes to the BPM value or to the instruments have no effect.
- You may change the speed value globally, or at any point by using command Fxx, 
  where xx must be in the range of 0-$1f.
- You may set note detune with command E5x.
- You may set the sequence loop point with command Bxx.
- All other effect commands, including volume settings on tones will be ignored.


By default, Octode 2k16 will loop until a key is pressed. To disable looping, 
uncomment line 53 in main.asm.

When you're done with composing, simply run the provided compile.cmd resp. 
compile.sh scripts to convert your XM file into two ZX Spectrum .tap files -
one for NMOS and one for CMOS models (see "About" section for details). 

compile.cmd/.sh will accept the following optional parameters (in the exact 
order listed here):

  -t "song title"
  -c "composer name"
  -a address*
  
Example: compile.cmd -t "My Song" -c "Great Musician"
This will create a BASIC screen which reads "My Song by Great Musician".

Alternatively, you can use interactive-compile.cmd/.sh to interactively set
these parameters.



Data Format
===========

Octode 2k16 uses a somewhat unusual data format. It follows the common sequence-
pattern approach, but stores the actual note data in seperate row-length 
buffers.


The song sequence must follow directly after the musicData label (that is, at 
the top of music.asm). It consists of a list of pointers to the actual patterns,
in the order in which they are played. The sequence is terminated by a 0-word. 
At some point in the sequence you must specify the label "loop", which is where 
the player will jump to after it has completed the sequence.


Patterns and row buffers can be located anywhere in the music data. If memory
is sparse, you could even squeeze data into the gaps between the 8 sound cores.

Patters consist of one or more rows, which in turn contain 2-3 word length
entries. The first word is the control word, which is constructed as
(row speed * 256) + drum trigger. Drum triggers are

0x00 - no drum
0x01 - hihat
0x04 - kick
0x80 - snare

If the drum trigger is not zero, the next word is the drum volume. The high
byte of this is always 0, the low byte can be any value. A value of 0x80 
signifies the highest volume, both lower and higher values signify lower
volumes.

The last word is a pointer to a row buffer, containing the actual note data
for the given pattern row.

Patterns must be terminated with 0x40.


Last but not least, there should be at least one row buffer. Row buffers
consist of 8 words, representing 8 frequency (counter) values. To silence a
channel, simply set it's frequency to 0. Row buffers do not need to be 
terminated.


A minimal song data set would thus look like this:

loop
     dw pattern
     dw 0
pattern
     dw #1001,#0080,row
     db #40
row
     dw #200,#400,#300,#0,#0,#0,#0,#0
