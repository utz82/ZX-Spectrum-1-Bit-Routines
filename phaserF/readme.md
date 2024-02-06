# PhaserF

Phaser-type ZX Spectrum beeper engine with filters

## Features

- 2 Phaser channels, XOR/OR/AND mixing
- variable duty for both oscillators (channel 2 only)
- volume control (up to 6 levels)
- filters with variable cutoff (6 levels for lo-pass, 5 levels for hi-pass)
- sample rate 9114 Hz
- interrupting PWM sampled drums at 27343 Hz with 7 pitch and 3 volume levels
- player size 3333 bytes (when assembled at a 256b border)

Channel 2 can be split into two independent pulse wave channels that are mixed
Squeeker-style (OR mixing). Beware that changing channel 2's mixing mode is slow
(~200t), so avoid doing so if you are concerned about transition noise.


## Data Format

PhaserF uses a standard sequence-pattern approach for song data.

The sequence of pattern pointers must be terminated with a 0-word, followed by a
pointer to the song's loop point.


### Pattern Data

Pattern data rows are encoded as follows:

Byte 0 is a control byte. If bit 6 is set, it marks the end of a pattern. If bit
7 is set, a PWM sample will play on this row. If bit 0 is set, channel 1 is
updated. If bit 2 is set, channel 2 is updated.

Byte 1 is always the row length, from 1 to 0x3f ticks. Then drum and channel
data may follow according to the initial control byte.

A PWM sample trigger consists of 6 bytes:

byte | function
-----|---------
0..1 | sample play length in ticks (8.8 fixed point, must not exceed row length)
2..3 | PWM sample pointer
4    | volume (2-bit; remapping bit 0 -> bit 4, bit 1 -> bit 6)
5    | pitch mask (more bits set, higher pitch)

An update for channel 1 starts with a control byte. If bit 6 is set, a 16-bit
clock divider follows, to be used as the frequency of the first oscillator. If
bit 1 is set, a clock divider for the second oscillator follows. If bit 2 is
set, the mix mode is changed to one of `MIX_AND` (0xa400), `MIX_OR` (0xb400), or
`MIX_XOR` (0xac00). If bit 7 is set, a pointer to the filter table to be used
follows.

The second byte of the channel 1 update controls the phase. If it is 0, no phase
reset occurs. Otherwise, the phase of both oscillators is set to one less than
the given value. Then follows the remaining channel data, in the order described
above. Unused data is omitted.

An update for channel 2 works the same as for channel 1, with the following
differences:

- Instead of the mix mode, the oscillator duties are set when bit 2 of the
control byte is set. One byte per channel, the duty for oscillator 2 comes
first.
- If the phase byte is 1, two additional bytes follow the regular channel data.
The first one sets the mix mode to one of `MIX_CH2_AND` (0xa2), `MIX_CH2_OR`
(0xb2), or `MIX_CH2_XOR` (0xaa). The second byte sets the phase for both
oscillators.

The first row of a song must contain a full update of both channels.


### Filter tables

PhaserF's filters use pre-calculated transformation tables. The following tables
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

You can define your own filter tables. A filter table must be aligned to a
16-byte border, and must contain 14 entries in the range of 0..6. Each entry *n*
in the table represents the result of transitioning from volume n>>1 to volume
(n & 1) * maximum_volume.


### PWM data

Each 8-bit PWM sample data must be terminated with a 0-byte.
