********************************************************************************
fluidcore
by utz 03'2016
********************************************************************************


ABOUT
=====

fluidcore is a 4 channel PCM wavetable player for the ZX Spectrum beeper, using
looped 256 byte waveforms. It offers a total of 17 volume levels, and can 
handle up to ~860% overdrive when the maximum volume level is exceeded. Sound is
mixed at approximately 23 KHz.


VERSIONS
========

fluidcore comes in two versions - for NMOS and CMOS Z80 CPUs. Most original ZX
models use an NMOS CPU, most clones use a CMOS CPU. It's easy to tell which CPU 
your Spectrum is sporting - if you get no sound and/or white stripes in the 
border area with the NMOS version, you've got a CMOS CPU. For emulators, the 
NMOS version will usually be the right choice.

Furthermore, sources are also included for a version that automatically detects
the MOS type and patches the code accordingly. It will however fail to detect 
CMOS Z80 on models without an AY chip. To use this version, back up main.asm,
and rename main-autodetect.asm to main.asm.


REQUIREMENTS
============

You'll need the pasmo assembler installed or present in your search path in
order to use the XM converter.

When building from source, you'll also need to compile xm2fluid.cpp and 
zmakebas.c.


COMPOSING MUSIC
===============

You can compose music using the provided music.xm template in conjunction with
the xm2fluid utility. This will only give a rough approximation of how the music
will sound on an actual or emulated ZX Spectrum, however.

The following restrictions apply:

- You cannot change the BPM.
- Instrument settings are ignored, except for partial mapping support (see 
  below)
- The volume column is ignored.
- Notes C-0 - G#0 have a special function, see below.

Furthermore, all effects are ignored, except:

- Bxx (jump to order - can be used to set the loop point)
- E5x (finetune - pitch translation isn't very accurate however)
- Fxx (change speed), with xx being in the range of 0x01-0x1f

The available instruments have their volume level stated in the name. If the
total volume level of the instruments in a given pattern row exceed 17, sound
will be overdriven. The XM template does not reflect this. The total volume 
level on a given row must not exceed 146. 

Certain instruments, like kicks and noise, are meant to be played at specific
fixed pitches. This can be achieved by using notes in the lowest octave, from
C-0 to G#0. Their pitch is not accurately represented in the XM template. 
Furthermore, pitch will affect these instruments (especially noise) in a 
non-linear fashion - again, the XM template does not reflect this behaviour. As
a general guideline, kicks will retrigger after 16 ticks at C-0, after 8 ticks
at D-0, after 4 ticks at E-0, and even faster on higher notes. Drums and noise
are also retriggered on every pattern row (as are all other instruments).

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
  
* For ideal size, the compile address should be calculated with the formula 
"N * 0x100 + 0x60", where N is a number higher than 0x80. So good choices are
0x8060 (32864), 0x8160 (33120), 0x8260 (33376), etc. When using main-
autodetect.asm, the magic formula is "N * 0x100 + 0x5a".


HINTS: 

- To disable looping, uncomment line 48 in main.asm.

- If you're not satisfied with the standard speed settings, try playing with
  the values in lines 69, 78, and 143 of main.asm. The following restrictions
  apply:
  - the value in lines 69 and 78 must be the same, and must be an odd value.
  - the value in line 143 must be exactly one less than the one used in lines
    69/78.
  - the value in line 143 must have bits 4 and 5 set.


ADDING SAMPLES
==============

You can add your own wavetables/samples to the player. Samples must be exactly
256 bytes long, and must be put into the /samples subfolder. Check the included 
ones for further details.

In order to add samples to the XM template/converter, you must do the following:

1) Append the sample's name to samplelist.txt.
2) Include a render of the sample in music.xm - the according instrument
   position must be the same as in samplelist.txt.
   
You can use the following procedure for rendering samples:

1) Add a blank instrument in music.xm
2) Create a pattern with a single C-4 note of that instrument
3) Compile the song, run it in an emulator, and record the sound
4) Import the recorded sound to the blank instrument in music.xm, and enable
   looping in the sample editor.
   
   
MUSIC DATA FORMAT
=================

Music data is split into two sections, song sequence and pattern data. 

The song sequence must come first. It is a list of pointers to the actual note 
patterns, in the order in which they are played. The sequence is terminated by 
a 0-word. At some point in the sequence you must specify the label "loop", which
is where the player will jump to after it has completed the sequence. The 
shortest possible sequence would thus be:

loop
	dw ptn00
	dw 0
	
Note: For technical reasons, the XM converter defines the loop label as an
equate at the end of the music data.

Following this are the note patterns. Each row in the patterns consists of 7
words, resp 14 bytes.

word 1: speed * 256 + 0 (flags, reserved for further use)
word 2: frequency ch1
word 3: frequency ch2
word 4: <hi-byte sample pointer ch1> * 256 + <hi-byte sample pointer ch2>
word 5: frequency ch3
word 6: frequency ch4
word 7: <hi-byte sample pointer ch3> * 256 + <hi-byte sample pointer ch4>

In order to mute a channel, simply set the frequency to 0, and the sample to
"instr0".

Note patterns are terminated with a $40 byte.


CREDITS
=======

All code by utz^irrlicht project, except:
- The MOS detection code was supplied by introspec, based on an idea by JtN. 
- The ZMakeBas utility used by the xm2fluid converter is by Russell Marks.

********************************************************************************
www.irrlichtproject.de
********************************************************************************