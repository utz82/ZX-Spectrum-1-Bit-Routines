# ulasyn

a ZX Spectrum beeper engine with filters


## Features

- 2 pulse wave channels
- variable duty cycle
- duty cycle sweep with variable speed
- noise mode (channel 2 only)
- volume control (up to 6 levels)
- filters with variable cutoff (6 levels for lo-pass, 5 levels for hi-pass)
- sample rate 9114 Hz
- interrupting PWM sampled drums at 18229 Hz with 7 pitch and 3 volume levels
- player size 3333 bytes (when assembled at a 256b border)



## Data Format

ulasyn uses a standard sequence-pattern approach for song data.

The sequence of pattern pointers must be terminated with a 0-word, followed by a
pointer to the song's loop point.


### Pattern Data

Pattern data rows are encoded as follows:

Byte 0 is a control byte. If bit 6 is set, it marks the end of a pattern. If bit
7 is set, a PWM sample will play on this row. If bit 0 is set, channel 1 is
updated. If bit 2 is set, channel 2 is updated.

Byte 1 is always the row length in ticks. Then drum and channel data may follow
according to the initial control byte.

A PWM sample trigger consists of 6 bytes:

byte | function
-----|---------
0..1 | PWM sample pointer
2..3 | sample play length in ticks (8.8 fixed point, must not exceed row length)
4    | volume (3-bit, remapping: bit 0 -> bit 4, bit 1 -> bit 6, bit 2 -> bit 0)
5    | pitch mask (more bits set, higher pitch)

A channel update starts with a control byte. If bit 6 is set, the frequency for
the given channel is updated. A set bit 0 means the duty and sweep speed are
updated. A set bit 2 means the filter table pointer is updated.

The second byte of a channel update is unused on channel 1. On channel 2, it
sets the noise mask. A mask of 0 disables noise mode. Then follows the actual
channel data according to the channel's control byte. Frequencies are given as
16-bit clock dividers, followed by an 8-bit duty cycle sweep speed (0 disables
sweep), followed by an 8-bit duty cycle resp. starting value for the sweep,
followed by a 16-bit pointer to a filter lookup table.

The first row of a song must contain a full update of both channels.


### Filter tables

 ulasyn's filters use pre-calculated transformation tables. The following tables
 are predefined:

- `t_filter_off_vol1` .. `t_filter_off_vol6`
- `t_lp_cutoff1_vol2` .. `t_lp_cutoff1_vol6`
- `t_lp_cutoff1dot5_vol1` .. `t_lp_cutoff1dot5_vol6`
- `t_lp_cutoff2_vol2` .. `t_lp_cutoff2_vol6`
- `t_lp_cutoff3_vol2` .. `t_lp_cutoff3_vol6`
- `t_lp_cutoff4_vol2` .. `t_lp_cutoff4_vol6`
- `t_lp_cutoff5_vol2` .. `t_lp_cutoff5_vol6`
- `t_hp_cutoff1_vol2` .. `t_hp_cutoff1_vol6`
- `t_hp_cutoff2_vol3` .. `t_hp_cutoff1_vol6`
- `t_hp_cutoff3_vol4` .. `t_hp_cutoff1_vol6`
- `t_hp_cutoff4_vol5` .. `t_hp_cutoff1_vol6`
- `t_hp_cutoff5_vol6`

`t_lp_cutoff1dot5_*` are using experimentally derived values which are inexact.
Their characteristics differ slightly from the other, mathematically derived
low-pass filters. They will usually be good enough as an intermediate step
between cutoff1 and cutoff2 in a simulated filter sweep.

You can define your own filter tables. A filter table must be aligned to a
16-byte border, and must contain 14 entries in the range of 0..6. Each entry *n*
in the table represents the result of transitioning from volume n>>1 to volume
(n & 1) * maximum_volume.


### Noise mode

Noise mode uses a new twister type number generator that can create a wide range
of different sounds. A good starting point for obtaining standard white-ish
noise is to use 0x2712 as clock divider, 0x76 as a mask, and a duty between 0x30
and 0xc0. Note that filters may not work well with noise mode enabled.


### PWM data

Each 8-bit PWM sample data must be terminated with a 0-byte.
