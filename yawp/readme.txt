********************************************************************************
yawp (Yet Another Wave Player)
by utz 09'2015
********************************************************************************


Features
********

- 3 channel PCM WAV playback
- 2 bit sample depth
- 5 octaves note range
- 16-bit frequency resolution
- per-row speed control
- 16.2 KHz mixing


Requirements
************

The following tools are required to use the xm2yawp utility

- an XM tracker, for example Milkytracker (http://milkytracker.org)
- pasmo or a compatible Z80 assembler (http://pasmo.speccy.org)
- Perl (http://www.perl.org/get.html)

pasmo and Perl must be installed in your search path, or must reside within the
yawp folder.


Composing Music
***************

You can compose music for the yawp player using the XM template that comes 
bundled with Octode PWM. However, this will only give a very rough estimate of
how the music will sound on an actual ZX Spectrum.

When using the XM template, consider the following:

- You may not change the number of channels.
- Notes must be in channel 1-3.
- Changes to the BPM value or to the instruments have no effect.
- You may change the speed value globally, or at any point by using command Fxx, 
  where xx must be in the range of 0-$1f.
- The note range is limited from C-0 to B-4.
- You may set note detune with command E5x.
- All other effect commands, as well as volume settings will be ignored.

By default, yawp modules loop back to the start. You can change this
manually by moving the "loop" label in music.asm to another position in the
sequence. To disable looping entirely, uncomment line 47 in main.asm.

When you're done composing, simply run the provided compile.bat (Win) resp.
compile.sh scripts to generate a .tap file of your music. If you only want to
generate the music data, run xm2yawp.pl without any arguments.


Adding New Samples to the Converter
***********************************

There is no easy way of doing this, unfortunately. The procedure is as follows:

Step 1: Make a sample in qaop's native format (see next section for details)
Step 2: Append the sample to the @instruments array in xm2yawp.pl (near the end)
Step 3: Sample a C-4 note, add it to the XM template as a new instrument, and
        activate sample looping.



yawp Sample Data Format
***********************

qaop lets you use your own samples, or rather looped waveforms. Samples must be included in
samples.asm. Check out the /samples folder for inspiration.

qaop samples have a fixed length of 256 bytes. The format is unsigned PCM, meaning all bytes
in the sample denote a relative volume. Sample byte volumes are defined as follows:
    #00 - silence
    #10 - 33% volume
    #30 - 66% volume
    #70 - 100% volume
Other values are not permitted.

You can use the included wav2smp.pl script to convert unsigned raw (header-less) 8-bit PCM WAV
files to yawp .smp format.


Data Format
***********

The music data consists of an order list containing the sequence of patterns, and the pattern 
data itself. The order list must be ended with a 0-word and must include a "loop" label 
somewhere. The shortest legal sequence is thus:

loop
       dw ptn01
       dw 0
       
Layout of the rows in pattern data is as follows:

offset   length   function
   [+0     byte   #00 = end marker]
    +0     word   [hi-byte of sample pointer ch3]*256 + speed
    +2     word   frequency ch1
    +4     word   frequency ch2
    +6     word   frequency ch3
    +6     word   [hi-byte of sample pointer ch1*256] + [hi-byte of sample pointer ch2]

Patterns must end with a 0-byte.