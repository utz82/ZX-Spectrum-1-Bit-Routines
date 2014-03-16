POWW - a 1-bit music routine for ZX Spectrum
written by utz 05'2013
www.irrlichtproject.de
report bugs and suggestions to utz AT my domain


HOW TO USE

There is no dedicated editor for this engine, so you can only make music by editing music.asm directly.
After you've composed your song, assemble poww.asm. I use pasmo for this ($ pasmo -d --tap poww.asm poww.tap),
though the code should be easily adaptable for other assemblers as well.


Note values are inverse, ie. higher values mean lower pitches.
There is no note to pitch conversion, you'll have to figure out the correct values yourself.

Note data is linear, ie. no patterns etc.


The data layout is as follows

   db nn,mm,oo,pp
	
where nn is the drum byte (0 = no drum, 1 = kick, 2 = snare)
      mm is the instrument setting for channel 1.
      oo is the note byte for channel 1 (see below for pitch limits, 0 = mute)
      pp is the note byte for channel 2 (can be any value, 0 = mute)	

Possible instruments for channel 1 are:

 0 - Instrument  1 - max. note val 28
11 - Instrument  2 - max. note val 42
22 - Instrument  3 - max. note val 25
33 - Instrument  4 - max. note val 42
44 - Instrument  5 - max. note val 42
55 - Instrument  6 - max. note val 63
66 - Instrument  7 - max. note val 36
77 - Instrument  8 - max. note val 31
88 - Instrument  9 - max. note val 28
99 - Instrument 10 - max. note val 28

You can use other instrument values, too, but this will cause detuning and destabilize timing.

You can make your own instruments by adding lines to the pwm-table (@pw0 in poww.asm).
Lines must be 11 bytes long, and the sum of all values must be 36.


You can change the song speed by editing line 14 of poww.asm. The value should be at least twice as high as
the value of your lowest note on channel 1. Normally you'll want to keep speed above #80.
