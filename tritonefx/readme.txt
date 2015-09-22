********************************************************************************
Tritone FX
by utz 09'2015
original Tritone code by Shiru 03'2011
********************************************************************************


About
*****

Tritone FX is a rewrite of the Tritone routine by Shiru. Like in the original, 
there are 3 tone channels with variable duty cycle. However, Tritone FX adds a
few twists.

Things added:

- Effects tables: Tritone FX can change pitch, duty, and note lengths on the fly
  during note playback, using table-based fx execution. With this, it is no
  longer necessary to use the player at hypersonic speeds to achieve some of the
  effects heard in more advanced Tritone tracks, for example by Strobe or
  brightentayle.
  
- Noise. Channel 1 can be used to output noise instead of tone. Toggeling the
  output mode of ch1 can be done via an fx command, so you can combine noise and
  tone in one note.

- Per-row tempo control: The song tempo can be set at any time.

Things changed:

- Channel volume difference is less pronounced than in the original Tritone. The
  loudest channel is ch2 (40%), followed by ch3 (32%), followed by ch1 (28%).
  
- Data format is changed completely, so original 

Things removed:

- Click drums. Removed because they would create too much bloat in the song 
  data. I believe they are no longer needed, given the added functionality.

Unfortunately there is currently no editor available for this routine, and it
would be too complex to simulate it via an XM template. So, for the time being,
the only option is to code the music by hand, in asm.



Music Data Format
*****************

Tritone FX music consists of 3 sections: The song sequence, the pattern data,
and the effect tables. The song sequence must come first. Pattern data and 
effects tables can be located anywhere except at the start, the two can even be 
mixed.

The song sequence contains the order in which the patterns are to be played. It
is terminated with a 0-word. 

After the player has completed the sequence, it will loop back to the position 
specified by the mandatory "loop" label. The shortest legal song sequence would 
therefore be:

loop
	dw pattern01
	dw 0

To disable looping, uncomment line 36 in main.asm.


Pattern data consists of 7 words per row, which are as follows

offset	function
(words)

+0	tempo*256 + noise flag (#00 = noise disabled, #01 = noise enabled)
+1	duty_ch1*256 + duty_ch2
+2	modulator mode (#ac00 - xor; #b400 - or, #a400 - and, #0000 - nop)
+3	base frequency ch2
+4	base frequency ch1
+5	base frequency modulator
+6	fx table pointer

An example row in a pattern:

	dw #2000,#8080,#ac00,#0100,#0400,#1000,fxtab01

In this example, the tempo will be set to #20 ticks, and noise is off. Duty 
for both channels will be set to #80 (50:50 square wave). The modulator runs
in XOR mode. Channel 2 plays a low bass frequency. Channel 1 plays a mid-
range frequency, with the modulator running at 2x the frequency of ch1, 
emphasizing on the upper harmonics of ch1. The effects table @fxtab01 will 
be executed.

Patterns must be terminated with a 0-byte.


Effects tables can be any length, but the maximum number of steps that are
executed is determined by the current tempo setting (= number of ticks).
See the following section for details on how to design effects tables.



Effects
*******

Effects are triggered once every 256 sound loop iterations. This is a rather
fast rate - for a typical arpeggio, you'd need to set a new frequency once 
every 3-4 rows in the fx table.

Effects take 0-3 word length arguments. The following effects are available:

fxNone
No effect will be executed on the current tick.

fxStop
Stop the fx table execution for this note.

fxJump,<label>
Jump to an arbitrary label on any fx table. Can be used to loop fx by
jumping backwards in the current table.

fxSetFCh1,<frequency>
fxSetFCh2,<frequency>
fxSetFCh3,<frequency>
Set the frequency of the given channel to the value given as argument.

fxSetFCh12,<frequency1>,<frequency2>
fxSetFCh13,<frequency1>,<frequency3>
fxSetFCh23,<frequency2>,<frequency3>
Set the frequencies of the given channel pair to the values given as args.

fxSetFCh123,<frequency1>,<frequency2>,<frequency3>
Set the frequencies of all 3 channels to the given values.

fxSetFChxxxCont,<frequencyx>,(...),<next effect>(,<args>,...)
Same as above, then execute another effect given as argument.

fxSetDCh1,<duty*256>
fxSetDCh2,<duty*256>
fxSetDCh3,<duty*256>
Set the wave duty of the given channel to the given value. The high byte of 
this word determines the duty, the low byte is always 0.

fxSetDCh12,<duty1*256+duty2>
fxSetDCh13,<duty1*256+duty3>
fxSetDCh23,<duty2*256+duty3>
Set the wave duties of the given channel pair to the given values.

fxSetDch123,<duty1*256+duty2>,<duty3*256>
Set the wave duties of all channels to the given values. The low byte of
the second argument is always 0.

fxStopNoise
Disable noise mode, and mute channel 1.

fxStopNoiseCont,<next effect>(,<args>,...)
Disable noise, and execute another effect given as argument.

fxStopNoiseSetFCh1,<frequency>
Disable noise mode, and set the frequency of channel 1 to the give value.

fxStartNoiseSetFCh1,<frequency>
Enable noise mode, and set the frequency of channel 1 to the give value.

fxStartNoiseSetFCh1Cont,<frequency>,<next effect>(,<args>,...)
Enable noise mode, set the frequency of channel 1 to the give value, and
execute another effect given as argument.

fxCutCh1
fxCutCh2
fxCutCh3
Cut the note of the given channel. Same effect as setting the given
channel's frequency to 0, but also resets the channel's counter.



An example fx table for a looping octave arpeggio:

fxtab01
	dw fxNone
t1lp
	dw fxNone
	dw fxNone
	dw fxSetFCh1,#400
	dw fxNone
	dw fxNone
	dw fxNone
	dw fxSetFCh1,#800
	dw fxNone
	dw fxNone
	dw fxNone
	dw fxSetFCh1,#1000
	dw fxNone
	dw fxNone
	dw fxNone
	dw fxSetFCh1,#200
	dw fxJump,t1lp

Hints
*****

In theory, an infinite number of effects can be chained by using the
xxxCont effect commands. However, this will lead to slowdowns if 
(ab)used too much.

You can control the volume and sound of the noise with the Ch1 duty
setting.


