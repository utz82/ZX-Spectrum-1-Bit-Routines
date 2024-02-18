***********************************************************************************************
qaop - beeper music routine for ZX Spectrum
by utz 08'2015
***********************************************************************************************

qaop features two channels of arbitrary waveform (sample) playback, and some interrupting click
drums.

The routine must be assembled aligned to a 256-byte border.


Using the XM Converter
======================

Unfortunately, the included XM converter is very limited and does not provide an easy option to
add user-made samples.

In order to convert an XM song to a qaop binary, you'll need the following tools:

- an XM tracker, for example Milkytracker (http://milkytracker.org)
- zmakebas
- pasmo or a compatible Z80 assembler (http://pasmo.speccy.org)
- Perl (http://www.perl.org/get.html)

pasmo and Perl must be installed in your search path, or must reside within the
nanobeep folder.

When using the XM template, consider the following:

- The number of channels cannot be changed.

- Changing the BPM setting has no effect, and tempo can be set only globally.

- Tones must be in channel 1 or 2. You can use any note from C-2 to B-6.

- You can use effect E5x (detune) on channels 1 and 2.

- You can use effect Fxx (tempo) anywhere. xx must be $01-$1f.

- All other effects are ignored.

- Click drums (instruments 1-3) must be in channel 3 or 4. There can only be one
  click drum per row.


By default, the player will loop back to the start of the song. You can change
the loop point manually, by moving the "loop" label in music.asm to another
row in the sequence. You can disable looping altogether by uncommenting line 45
in main.asm.

When you're done with composing, simply run the provided compile.bat resp.
compile.sh scripts to convert your XM file into a ZX Spectrum .tap file. To
convert only the XM file, run xm2qaop.pl.


Adding New Samples to the Converter
===================================

There is no easy way of doing this, unfortunately. The procedure is as follows:

Step 1: Make a sample in qaop's native format (see next section for details)
Step 2: Append the sample to the @instruments array in xm2qaop.pl (near the end)
Step 3: Sample a C-4 note, and add it to the XM template. Sample looping should
        be activated, of course.



qaop Sample Data Format
==========================

qaop lets you use your own samples, or rather looped waveforms. Samples must be included in
samples.asm. Check out the /samples folder for inspiration.

qaop samples have a fixed length of 256 bytes. The format is unsigned PCM, meaning all bytes
in the sample denote a relative volume. Bytes can take any value from 0 (silent) to 6 (loudest).
However, the maximum combined volume level of both channels is 6, so if you want to avoid
overdrive/distortion, do not use sample volumes >3. It's usually not a problem to use sample
volumes up to 4, though.

You can use the included wav2smp.pl script to convert unsigned raw (header-less) 8-bit PCM WAV
files to qaop .smp format.



qaop Music Data Format
==========================

The music data consists of an order list containing the sequence of patterns, and the pattern
data itself. The order list must be ended with dw #0000, followed by a loop point address.
Patterns must end with db #40.

Layout of the rows in pattern data is as follows:

offset   length   function
   [+0     byte   #40 = end marker]
    +0     word   speed*256 + click drum (0 = none, 1 = kick, 5 = snare, 81 = hihat)
    +2     word   frequency ch1
    +4     word   frequency ch2
    +6     word   sample addresses [hi-byte ch1*256] + [hi-byte ch2]

When using click drums, the speed must be manually decremented in the pattern data. Length and
pitch of the click drums can be manually adjusted in main.asm.


Trivia
======

qaop stands for "Quite Accurate Overdriven Player".
