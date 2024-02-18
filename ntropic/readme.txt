***********************************************************************************************
NTROPIC music routine for ZX Spectrum
by utz 01'2014, revised 08'2014
***********************************************************************************************

2 square wave channels, 1 noise channel, drums


Requirements:
=============

In order to use ntropic, you will need

- pasmo or another Z80 assembler of your choice
- zmakebas for compiling the BASIC loader
- Perl for compiling the music from an XM file
- Milkytracker or another XM tracker for writing music

Writing Music
=============

You can compose music using the included music.xm template. It gives only a rough impression of
how the music will sound on actual hardware though.

You can set the song speed with the global "Spd" setting, or at any given point with command
Fxx. BPM settings are ignored.

Notes go in tracks 1 and 2. You can use notes from C#0 to B-7. However, notes in higher octaves
are prone to detuning, which is not reflected in the xm template.

You can use manual detune on both tone channels with command E5x.

Track 3 is the noise channel. The pitch is ignored. You can set the length with command ECx.
Note that this gives only a rough estimate on how long the noise will sound.

You can put the drum in any channel, it's pitch will be ignored.

All other effect commands are ignored.


Compiling
=========

Provided you have Perl and pasmo installed on your system, simply run the
compile.bat resp. compile.sh scripts.


ntropic Music Data Format
==========================

You can also code the music.asm file by hand, if you like. The music data consists of an
order list containing the sequence of patterns, followed by the pattern data itself.
The order list must be ended with dw #0000, patterns must end with db #ff.


byte 1 = speed+drum or pattern end marker (#ff)
drum can be 0 (no drum), or 1 (kick)
speed can be #04..#fc, must be a multiple of 2

bytes 2-3 = tone counters ch1-ch2
values are inverse, ie. higher value means lower tone

byte 4 = noise length
values can 0-#30, 0 = off
