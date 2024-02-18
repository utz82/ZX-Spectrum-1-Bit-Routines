***********************************************************************************************
RAWP music routine for ZX Spectrum
by utz 08'2014
***********************************************************************************************

2 custom waveform channels, hihat


Requirements:
=============

In order to use rawp, you will need

- pasmo or another Z80 assembler of your choice
- zmakebas
- Perl for compiling the music from an XM file
- Milkytracker or another XM tracker for writing music

Writing Music
=============

You can compose music using the included music.xm template. It gives only a rough impression of
how the music will sound on actual hardware though.

You can set the song speed with the global "Spd" setting, or at any point with command Fxx. BPM
  settings are ignored.

Instruments 01-11 go in tracks 1 and 2. You can in theory use notes from C-1 to B-7. However,
  you may notice that the lower octaves are out of audible range with most instruments. Notes
  in higher octaves are prone to detuning, which is not reflected in the xm template.

  You can use manual detune on both tone channels with command E5x.

  You can use effects 1xx/2xx in track 1 to activate pitch slide up/down. The effect parameters
  are ignored. The speed of the pitch slide depends on the note counter value in channel 2. You
  can use the dummy instrument (instrument 13) in track 2 to set the note counter for channel 2
  without triggering an instrument. A higher notes means slower slide speed. The counter value
  on channel 1 will wrap once it reaches 0 or 255, use short steps to avoid the retrigger.
  It is ultimately impossible to emulate the actual effect in XM, so it is best edited manually
  in the asm file. See data format section for details.

You can put the hihat (instrument 12) in any channel, it's pitch will be ignored.

You can specify the order loop point with command Cxx (not Bxx!) somewhere on an empty track.

All other effect commands are ignored. Except for Fxx/Cxx, effect settings affect the current
  row only.


Compiling
=========

Provided you have Perl and pasmo installed on your system, simply run the
compile.bat resp. compile.sh scripts.


rawp Music Data Format
==========================

You can also code the music.asm file by hand, if you like. The music data consists of an
order list containing the sequence of patterns, and the pattern data itself.
The order list must be ended with dw #0000, followed by a loop point address.
Patterns must end with db #ff.

byte 1 = speed+hihat or pattern end marker (#ff)
  Speed can be #04..#fc, must be a multiple of 2. Add 1 to the value to trigger the hihat.

byte 2 - instrument ch1
  Valid values are #00 (silence), #01-#10. Add #80 to the value for pitch slide down,
  or #c0 for pitch slide up. See also byte 4. Examples:

  Hard kick: db #xx,#81,#08,#00,#10
  Slide up:  db #xx,#c1,#10,#c0,#20

byte 3 - note counter value ch1.
  Valid values are #00-#ff. Values are inverse, ie. higher value means lower tone.

byte 4 - instrument ch2
  Valid values are #00 (silence), #01-#10. You can add #80/#c0 as an auxiliary parameter for
  a pitch slide present on ch1.

byte 5 - note counter value ch2
  Same as byte 3.


rawp Sample Data Format
==========================

If you feel adventurous, you can add your own samples to sampledata.asm, or change the existing
ones. Samples must be 256 bytes long, and may only consist of values #00 and #10 (unless you
want funky colors to appear in the border area). The player reads chunks of 4 sample bytes and
combines them into one volume level.


Trivia
======

rawp stands for "Reasonably Accurate Waveform Playback".
