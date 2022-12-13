# Pindsvin

## About

Pindsvin is a music engine for the ZX Spectrum beeper that combines two distinct synthesis approaches. Two channels are synthesized using the Squeeker method as developed by Zilogat0r, and three channels are synthesized using Pulse Frequency Modulation, using the pulse accumulating approach pioneered by introspec. The Squeeker channels can also be combined into a dual-oscillator Phaser-type generator.

The Squeeker channels feature pulse-width control, while the PFM channels feature volume control. Furthermore, the engine features interrupting PWM drums with volume control.

The engine runs at 11986.3 Hz (292t loop), and offers 7-bit tempo control at half-tick resolution. The engine size is 330 bytes.



## Music Data Format

Pindsvin encodes music data as a sequence of steps, with additional instrument definitions for the drum synth.

### Sequence

The song sequence is a list of pointers to step definitions, in the order in which they are to be played. The sequence end is marked with a 0-word, followed by a pointer to the sequence loop point. A basic 1-step sequence would look like this:

	.loop
        dw .step00
		dw 0
		dw .loop

When disabling song looping in the player, you can omit the loop point definition.

### Steps

Steps encode a single row of music data. A full reload of all user-modifiable parameters takes 25 bytes. The actual layout of a step's data is configured through the two control bytes CTRL0 and CTRL1. Any data field which does not have its corresponding flag bit in CTRL0/1 set can be omitted.

The full data structure is as follows:

| offset | bit  | function                                    |
|--------|------|---------------------------------------------|
| 0      |      | CTRL0                                       |
|        | 0    | update ch3                                  |
|        | 2    | update ch5                                  |
|        | 6    | update ch4                                  |
|        | 7    | trigger PWM drum                            |
| 1      | 0..5 | row length in ½ ticks¹                      |
| 2      |      | drum length in ½ ticks                      |
| 3      | 4..7 | drum volume                                 |
| 4      |      | drum data pointer                           |
| 6      |      | volume ch3                                  |
| 7      |      | note ch3                                    |
| 9      |      | volume ch3                                  |
| 10     |      | note ch3                                    |
| 12     |      | volume ch3                                  |
| 13     |      | note ch3                                    |
| 14     |      | CTRL1                                       |
|        | 0    | update mixing mode                          |
|        | 2    | update ch2                                  |
|        | 6    | update ch1                                  |
|        | 7    | set phase ch1/ch2                           |
| 15     |      | mixing mode: 0xb1 = Squeeker, 0xa9 = Phaser |
| 16     |      | duty ch1                                    |
| 17     |      | note ch1                                    |
| 19     |      | duty ch2                                    |
| 20     |      | note ch2                                    |
| 22     |      | phase ch1                                   |
| 24     |      | phase ch2                                   |

¹ PWM drum delay must be adjusted manually


### Drum Data

Drum data is encoded as a sequence of 8-bit Pulse Width Modulation deltas, ie. each 8-bit value represents a time (in samples) until the next zero crossing. Drum samples play at a rate of 23973 Hz, which you should match when converting PCM data (for example with Jeff Alyanak's [pcm2pwm](https://github.com/JeffAlyanak/pcm2pwm) utility). The end of a drum data block must be marked with a 0-byte.
