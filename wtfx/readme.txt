********************************************************************************
wtfx - wavetable player with fx
by utz 02'2016 * www.irrlichtproject.de
********************************************************************************


==================================== ABOUT =====================================

wtfx is a two-channel beeper with almost distortion-free wavetable playback. It
can be used to create complex sound effects, thanks to it's table-based fx 
system. The sound is mixed at 17.5 KHz, and there are 4 volume levels per 
channel. Channel volumes are asynchronous, with channel 2 being slightly louder
than channel 1. Tempo can be controlled per step.

The player is provided in source format only, to be assembled with pasmo.


================================== COMPOSING ===================================

There is currently no editor available for this player, and it is too complex to
simulate via an XM template. So unfortunately the only possibility to make music
with it is by hand-coding all the data in asm. For reference, an example note
table has been included.

You can also configure a few things in main.asm. To disable looping, uncomment
line 39. If you want more fine-grained speed control, replace both nops in line
114 and 115 with "dec b". If you don't want to use any effects, comment out
lines 84, 280-288, and 292-487, and omit the fx pointers in the pattern data.


================================== WAVETABLES ==================================

All used wavetables must be linked in 'samples.asm'. The wavetables themselves
must be exactly 256 bytes long, and may only use the following values:

0x00 - silence
0x88 - 25% volume
0xcc - 50% volume
0xee - 75% volume
0xff - 100% volume

More complex waveforms may fail to play properly.

See /samples for some examples.

You can also create wavetables with the included wav2smp.pl utility, using
headerless unsigned 8-bit wav samples as input. The syntax is as follows:

wav2smp.pl <volume> <infile> [<outfile>]

where volume is a value between 1 and 4.


============================== MUSIC DATA FORMAT ===============================

wtfx music data is split into three sections: song sequence, patterns, and fx
tables.

The song sequence must come first in music.asm. It consists of a list of
pointers to patterns, according to the order in which they are to be played. It
must contain a label named "loop", the position of which defines the loop point
to which the player will jump after it has finished playing the song. The song
sequence is terminated with 0x0000. The shortest possible sequence is therefore

loop
     dw pattern0
     dw 0

After the song sequence, there should be one or more patterns of note data. 
These are organized in rows of 6 words. The order is as follows:

1. tempo * 256 + flags (always 0, reserved for further use)
2. 16-bit note value channel 1
3. pointer to wavetable channel 1
4. 16-bit note value channel 2
5. pointer to wavetable channel 2
6. pointer to fx table

Patterns must be terminated with 0x40.

Last but not least, some fx tables are needed. These consist of one or more
commands, which are in turn followed by 0-4 word or byte length arguments.
The following commands are available:


command    arguments                  function

tExecNone  none                       do not execute any fx on this row
tExecStop  none                       stop wavetable execution for this row
tExecLoop  loop pointer               jump to an arbitrary point in the current
                                      or another fx table. Additionally, execute				      
			              the next command at the loop point.
tf1        note value ch1             change note of ch1 to the given value
tf1s1      note value ch1,            change ch1 note and wavetable to the given 
           hi-byte of wavetab ch1     values
tf1s1f2    note value ch1,            change both notes and wavetable ch1 to the
           hi-byte of wavetab ch1,    given values
	   note value ch2
tf1s1s2    note value ch1,            change note value ch1 and both wavetables
           hi-byte of wavetab ch1,
	   hi-byte of wavetab ch2
tf1f2      note value ch1,            change both note values
           note value ch2
tf1f2s2    note value ch1,            change both note values and wavetable ch2
           note value ch2,
	   hi-byte of wavetab ch2
tf1s2      note value ch1,            change ch1 note and ch2 wavetable to the  
           hi-byte of wavetab ch2     given values
tf1s1f2s2  note value ch1,            change all notes and wavetables pointers
	   note value ch2,            to the given values
	   hi-byte of wavetab ch1,    ATTN: order of arguments is changed here!
	   hi-byte of wavetab ch2
ts1        hi-byte of wavetab ch1     change wavetable ch1 to the given value
ts1f2      hi-byte of wavetab ch1,    change wavetable ch1 and note value ch2 to
           note value ch2             the given values
ts1f2s2    note value ch2,            change both wavetable pointers and the        
	   hi-byte of wavetab ch1,    note value of ch2
	   hi-byte of wavetab ch2     ATTN: order of arguments is changed here!
ts1s2      hi-byte of wavetab ch1,    change both wavetable pointers
           hi-byte of wavetab ch2
tf2        note value ch2             change note of ch2 to the given value
tf2s2      note value ch2,            change ch2 note and wavetable to the given 
           hi-byte of wavetab ch2     values
ts2        hi-byte of wavetab ch2     change wavetable ch2 to the given value

The order in which the patterns and fx tables are provided has no importance.
See 'music.asm' for more details.

================================================================================
