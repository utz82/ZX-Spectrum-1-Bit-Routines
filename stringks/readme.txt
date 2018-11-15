*******************************************************************************
STRINGKS
by utz 11'2018 + www.irrlichtproject.de
*******************************************************************************

ABOUT
=====

StringKS is an experimental 1-bit music engine for the ZX Spectrum beeper. It
features 2 channels of tone with Karplus-Strong inspired string synthesis. The
KS ringbuffer can be seeded either from a ROM page, RAM page, a saw waveform,
or a rectangular waveform with variable duty. Ringbuffers support 3-bit volume.
Additionally, it can play PWM-encoded wave data on channel B, and normal
rectangular waves on channel A, both also with 3-bit volume control. Frequency
dividers are 8-bit, so the available note range is rather limited.


COMPOSING
=========

There is currently no dedicated editor for this engine available, so music has
to be composed directly in assembly. Source is written for Pasmo assembler.


DATA FORMAT
===========

Music data for StringKS uses the usual sequence/pattern approach. A sequence
(order list) of pattern pointers is followed by one or more patterns
containing the actual music data.

Sequences must be terminated by a 0-word, followed by a pointer to the loop
point. The simplest valid sequence is therefore

loop_point
    dw pattern0
    dw 0,loop_point

Pattern data consist of rows containing one or more words. The high byte of
the first word sets the speed (as length in ticks) for the given row. The low
byte configures which data follows, and also toggles the overdrive setting. In
detail, set bits in the low byte have the following effect:

bit     function
---------------------------
0       omit channel B data
2       toggle overdrive
6       end of pattern
7       omit channel A data

Overdrive is automatically disabled at the start of a pattern.

Channel data starts with a word specifying which synthesis core to use. The
following cores are available

chX_mute:     mute channel
chX_ks_noise: "classic" Karplus-Strong, using a page in ROM or RAM as source
chX_ks_rect:  "rectangular" Karplus-Strong, using a rectangular wave as source
chX_ks_saw:   "saw" Karplus-Strong, using a saw wave as source
chA_rect:     play a normal rectangular wave. This core is only available on
              channel A.
chB_pwm:      play a PWM sample. Note that this core is only available on
              channel B. It is not fully timing corrected and therefore can
              lead to some slight detune, especially on samples with a strong
              high frequency component.

where X is the given channel, either A or B. Remember that channel B data
goes before channel A.

The core specifier determines which data follows.

chX_mute:     no additional data follows.
chX_ks_noise: 2 words follow. Volume in highest 3 bits of the first word,
              hi-byte of second word is note value, lo-byte is duty comparator
              (as fraction of the note value)
chX_ks_rect:  2 words follow. Volume in highest 3 bits of the first word,
              hi-byte of second word is note value, lo-byte is duty comparator
              (as fraction of the frequency)
chX_ks_saw:   1 word follows, with note value as the hi-byte.
chB_pwm:      2 words follow. First word is pointer to sample, second word has
              volume in highest 3 bits.

Patterns must be terminated by a 0x40 byte.

Note values are 8-bit frequency *counters*, ie. a higher value means lower
frequency. Values must be offset by +1.

Although only the highest 3 bits of volume parameters are effective in the
output, all 8 bits are taken into account for calculations, so setting the
lower bits may increase precision, especially when overdrive is enabled.

After the music data (or optimally directly before the music_data label) you
can add your own seed data, that can be fed into chX_ks_noise. Seed data must
be aligned to a 256-byte border, and can contain any values, however bits 0..5
are generally ignored.

