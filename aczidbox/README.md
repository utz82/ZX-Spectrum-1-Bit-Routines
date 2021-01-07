# ACZIDBOX
by [utz/irrlicht project](https://irrlichtproject.de) 01'2021

## About

Aczidbox is a 1-bit sound engine for the ZX Spectrum beeper. It
implements a simplified version of
[Phase Distortion Synthesis](https://en.wikipedia.org/wiki/Phase_distortion_synthesis),
as introduced by the Casio CZ range of synthesizers.

The two tone channels each feature a 16-bit base oscillator and a LFO-controlled
12-bit resonant oscillator. Channels each use 7 bits of volume information
internally, which are reduced to 4 bits for the final mix.

3 different configurable click drum modes are available: synthesized kicks,
synthesized noise, and PWM sample playback. Drums interrupt tone playback.

The core synthesis runs at 7812 Hz (double 224 cycle loop).


## Compilation Flags

Set these flags to 1 to enable, or 0 to disable a feature. All features are
enabled by default.

- **ACZ_LOOPING**: Song looping.
- **ACZ_LOUDNESS**: Increase the global volume, at the const of a slightly worse
sound quality.
- **ACZ_SYNTH_KICK**: Kick drum synthesizer.
- **ACZ_SYNTH_NOISE**: Noise drum synthesizer.
- **ACZ_PWM_DRUM**: PWM drum player.

Disabling any of the latter 3 features will reduce the player size.


## Music Data Format

Aczidbox' music data format follows the conventional sequence/pattern approach.

The sequence determines the overall structure of the song. It must be listed at
the start of the music data. It consists of a list of words, which are pointers
to patterns. The sequence end must be marked with a 0-word, followed by a word
defining the loop point within the sequence. The loop point can be omitted when
song looping has been disabled (see above).


### Pattern Format

Pattern can be of arbitrary length. A pattern row has the following format:

bytes | name              | function
------|-------------------|---------
1     | `ctrl0`           | [see Control Bytes](#control-bytes)
1     | `timer_hi`        | row length (must be manually adjusted after drum)
2     | `drum`            | drum instrument pointer
1     | `ctrl1`           | [see Control Bytes](#control-bytes)
1     | `timer_lo_offset` | see [Adjusting Drum Timing](#adjusting-drum-timing)
2     | `res_mod1`        | resonance LFO speed channel1 (0..0xff << 8)
2     | `note_ch1`        | base frequency ch1
2     | `res_ch1`         | initial resonance frequency ch1
2     | `res_mod2`        | resonance LFO speed ch2
2     | `note_ch2`        | base frequency ch2
2     | `res_ch2`         | initial resonance frequency ch2

All entries except `ctrl0` and `timer_hi` are optional, and their presence or
absence is determined by the [Control Bytes](#control-bytes).

Each pattern must be terminated by a 0x40 byte.


#### Control Bytes

Pattern data uses a simple compression scheme to eliminate redundant data. Each
row of pattern data begins with a control byte, which determines what data
follows. The meaning of the first control byte is different, depending on the
state of its bit 2.

If bit 2 is reset, then `drum` and `ctrl1` are omitted. In this case, a set bit
0 signals that `res_mod1`, `note_ch1` and `res_ch1` are omitted. A set bit 7
signals that `res_mod2`, `note_ch2` and `res_ch2` are omitted.

If bit 2 of `ctrl0` is set, then `drum` and `ctrl1` are present. In this case, a
set bit 0 signals that a synthesized kick drum will be played. A set bit 7
signals that a PWM drum will be played. If neither bit 0 nor 7 are set, a
synthesized noise drum will be played.

If `ctrl1` is present, then it works like `ctrl0` with bit 2 reset.


#### Adjusting Drum Timing

Row length is not adjusted automatically after playing a drum, so this must be
done manually in the music data. Since drum lengths have four times the
resolution of note lengths, it may be necessary to adjust the lower 8 bits of
the note timer. Adding 0xc0 to `timer_lo_offset` reduces the note length by 0.25
ticks, adding 0x80 reduces it by 0.5 ticks, and adding 0x40 reduces it by 0.75
ticks.

**Example:**

Assume a note row length of 8 ticks , where a drum of length 5 plays. Since one
tick of drum equals 4 ticks of note row length, the row length must be adjusted
by -(5/4) ticks. In order to do this, first adjust `timer_hi` to 7, which
balances out 4 of the 5 drum ticks. To balance out the last tick, set
`timer_lo_offset` to 0xc0.


### Drum Instrument Format

The data format for drum instruments is different for each drum type.

#### Synthesized Kick Drum

bytes | function
------|---------
1     | volume (1..7 << 4)
1     | length (4 drum ticks = 1 main synth tick)
1     | sweep speed (bit mask, more bits means faster speed)
1     | initial pitch (higher value = higher pitch)
2     | decay mode (`NO_DECAY`, `LINEAR_DECAY[_X2]`, `EXPONENTIAL_DECAY`)

#### Synthesized Noise Drum

bytes | function
------|---------
2     | volume (1..7 << 12)
1     | pitch (1 is highest)
1     | length (4 drum ticks = 1 main synth tick)

#### PWM Drum

bytes | function
------|---------
1     | length (4 drum ticks = 1 main synth tick)
1     | volume (1..7 << 4)
2     | drum data pointer

The drum data pointer must point to a 0-terminated block of 8-bit, pulse width
modulated sample data.
