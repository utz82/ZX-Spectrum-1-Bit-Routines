# tftone

## About

tftone is a re-implementation of Shiru's famous Tritone engine. Like in the original, each channel has a different volume: Channel 2 is twice as loud as channel 1, which is in turn twice as loud as channel 3. Tritone's synth drums are replaced by PWM sampled drums with variable volume.

### Advantages

The main advantage of tftone is that it eliminates row transition noise by reading music data during playback. This makes tftone better suited for fast "speed 1" compositions. To extend the possibilities of high-speed trickery even further, tftone updates at much shorter intervals - a tick in tftone is approximately ¼ as long as in the original Tritone.

### Caveats

Playback speed is slightly lower at 16204 Hz, vs. 18229 Hz in the original.

Data loading is asynchronous, ie. channels are updated consecutively, rather than simultaneously. An update cycle takes 2808 cycles. While this is fast enough to be not noticeable in practice, it means you cannot rely on channel phases staying in sync. More importantly, drums are triggered *after* channel data has been reloaded, which may have undesirable effects on short attack transients.

No border masking is applied, which may cause problems for people with photo-sensitivity. The player is rather large, occupying 1036 bytes of memory.

## Music Data Format

tftone's data format uses the common sequence/pattern approach. A sequence of pattern pointers is followed by one or more patterns containing the actual note data.

#### Sequence

The end of the sequence must be marked with a 0-word, followed by a loop point definition. The shortest valid sequence would thus look like

    .loop
	    dw .pattern00
		dw 0
		dw .loop

#### Patterns

Patterns are constructed as follows:

| offset | bit | function                                                                    |
|--------|-----|-----------------------------------------------------------------------------|
| 0      |     | Control                                                                     |
|        | all | all bits reset: pattern end                                                 |
|        | 7   | set ch1                                                                     |
|        | 6   | set ch2                                                                     |
|        | any | if bit 6 is set, set no other bit to set ch3, else set any other single bit |
| 1      |     | frequency divider ch3                                                       |
| 3      |     | duty ch3                                                                    |
| 4      |     | frequency divider ch2                                                       |
| 6      |     | duty ch2                                                                    |
| 7      |     | frequency divider ch1                                                       |
| 9      |     | duty ch1                                                                    |
| 10     |     | 0 = drum trigger, else row length¹ in ticks                                 |
| 11     |     | drum length (in ticks, 1 drum tick = 2 note ticks)                          |
| 12     |     | drum volume (4-bit, (0x10..0xf0) & 0xf0)                                    |
| 13     |     | pointer to PWM data                                                         |
| 15     |     | row length¹ (only if drum was triggered)                                    |

¹ The effective number of ticks *T* is calculated from the given row length value *l* as follows:

    T = (l & 0xfc) - ((~l + 1) & 3)

A few examples to illustrate the effect of this:

| row length value | effective row length |
|------------------|----------------------|
| 4                | 4                    |
| 5                | 1                    |
| 6                | 2                    |
| 7                | 3                    |
| 8                | 8                    |
| 9                | 5                    |


All unused data fields shall be omitted. Eg. when not changing any of the notes/duties and not triggering a drum, you would only write the Control byte, followed directly by the row length.

For a row without any changes, write a control byte with two of the lower 6 bits set.

Drum timing offset must be corrected manually.

#### Drum samples

Drum data is encoded as a sequence of 8-bit Pulse Width Modulation deltas, ie. each 8-bit value represents a time (in samples) until the next zero crossing. Drum samples play at a rate of 32407 Hz, which you should match when converting PCM data (for example with Jeff Alyanak's [pcm2pwm](https://github.com/JeffAlyanak/pcm2pwm) utility). The end of a drum data block must be marked with a 0-byte.
