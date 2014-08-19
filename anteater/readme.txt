***********************************************************************************************
ANTEATER music routine for ZX Spectrum
by utz 08'2014
***********************************************************************************************

1 square wave channel, 1 pwm channel, drums


Requirements:
=============

In order to use anteater, you will need

- pasmo or another Z80 assembler of your choice
- Perl for compiling the music from an XM file
- Milkytracker or another XM tracker for writing music

Writing Music
=============

You can compose music using the included music.xm template. It gives only a rough impression of
how the music will sound on actual hardware though.

You can set the song speed with the global "Spd" setting, or at any given point with command
Fxx. Valid values are 1..$1f (31). BPM settings are ignored.

Notes go in tracks 1 and 2. Track 1 is the square wave channel, track 2 is the PWM channel.
You can use notes from C-1 to B-7. However, notes in higher octaves are prone to detuning, 
which is not reflected in the xm template.

You can use manual detune on both tone channels with command E5x.

You can put drums in any channel, their pitch will be ignored.

All other effect commands are ignored.


Compiling
=========

Provided you have Perl and pasmo installed on your system, simply run the
compile.bat resp. compile.sh scripts.


anteater Music Data Format
==========================

You can also code the music.asm file by hand, if you like. The music data consists of an
order list containing the sequence of patterns, followed by the pattern data itself.
The order list must be ended with dw #0000, patterns must end with db #ff.


byte 1 = speed+drum or pattern end marker (#ff)
drum can be 0 (no drum), 1 (kick), 2 (snare) or 3 (hihat)
speed can be #04..#fc, must be a multiple of 4

bytes 2-3 = tone counters ch1-ch2
values are inverse, ie. higher value means lower tone

Trivia
======

The name "anteater" is a reference to the game "Ant Attack" by Sandy White and Angela Sutherland,
which is probably the first game on the Speccy to use pulse interleaving beeper sound.

