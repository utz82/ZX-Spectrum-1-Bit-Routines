# Pulsatilla

## About

Pulsatilla is an experimental music engine for ZX Spectrum beeper that combines two different 1-bit synthesis techniques. Two of the engine's channels use the Squeeker synthesis method developed by Zilogat0r, and the other two channels use classic pulse interleaving. Alternatively, the two Squeeker channels can be combined into a single, Phaser-type dual oscillator channel.

All channels feature full-range pulse width control. PuInt channel volumes are asynchronous, with channel 4 being about 1/2 louder than channel 3. Channel 1 can generate noise instead of tones, and Channel 4 can generate a pulse width sweep instead of fixed duty cycle sound. Precise phase control allows for fine-grained volume and timbre effects.

The included UD drum synthesizer provides interrupting click drums. Drum sounds are mixed from a noise generator and a sliding tone generator.

The engine takes 418 bytes and runs at 15625 Hz (224 cycles per sample).


## Music Data Format

Pulsatilla encodes music data as a sequence of steps, with additional instrument definitions for the drum synth.

### Sequence

The song sequence is a list of pointers to step definitions, in the order in which they are to be played. The sequence end is marked with a 0-word, followed by a pointer to the sequence loop point. A basic 1-step sequence would look like this:

	.loop
        dw .step00
		dw 0
		dw .loop

When disabling song looping in the player, you can omit the loop point definition.

### Steps

Steps encode a single row of music data. A full reload of all user-modifiable parameters takes 27 bytes. The actual layout of a step's data is configured through one or more control bytes, which allows omitting of any unused data bytes.

The full data structure is as follows:

offset | bit    | function
-------|--------|---------
0      | 0      | trigger drum
       | 2      | set ch3
       | 6      | set ch1
       | 7      | set ch2
       | 8      | set ch4
       | 9      | reduce step length by 1/2 tick
       | 10..15 | Step length in ticks. Drum delay must be adjusted manually.
2      |        | pointer to drum instrument
4      | 0      | set note ch1
       | 2      | set phase ch1
       | 6      | set pulse width ch1
       | 7      | enable noise mode
5      |        | pulse width ch1
6      |        | frequency divider ch1
8      |        | phase ch1
10     | 0      | set note ch2
       | 2      | set phase ch2
       | 6      | set pulse width ch2
       | 7      | enable ch1/2 Phaser mixing (reset bit enables Squeeker mixing)
11	   |        | pulse width ch2
12     |        | frequency divider ch2
14     |        | phase ch2
16     | 0      | set note ch3
       | 2      | set phase ch3
       | 6      | set duty ch3
17	   |        | duty ch3
18     |        | frequency divider ch3
20     |        | phase ch3
22     | 0      | set note ch4
       | 2      | set phase ch4
       | 6      | set pulse width ch4
       | 7      | enable PWM sweep
23     |        | pulse width ch4
24     |        | frequency divider ch5
26     |        | phase ch4

Any unused data can be omitted. For example, to only set a new note for channel 1, the step should look like this:

    dw #2004      ; step length 16 ticks (0x20>>1), set bit 2 to load ch1 data
	db 1          ; only set note
	dw DIVIDER    ; note frequency divider

The first step of a song should initialize all parameters. When setting a rest on channel 1 or 2, you should also either set the channel's duty or its phase to 0 in order to avoid blocking the other channel.

### Drum Instruments

Drum instrument definitions take 7 bytes. Their usage is as follows:

offset | function
-------|---------
0      | volume kick¹
1      | volume noise¹
2      | kick sweep speed (lower = faster sweep, 0 interpreted as 256)
3      | kick initial pitch (higher value = higher pitch)
4      | noise freq divider (lower = higher pitch, 0 interpreted as 256)
5      | length lo (0 interpreted as 256)
6      | length hi

¹ [0..0xf] << 8, combined kick+noise volume shall not exceed 255
