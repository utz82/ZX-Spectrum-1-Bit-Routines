********************************************************************************
BEEPERTOY v0.1
by utz 06'2016 * www.irrlichtproject.de
********************************************************************************

================================================================================
About
================================================================================

BEEPERTOY is a multi-paradigm sound routine for the ZX Spectrum beeper. It 
generates sound through a number of different methods, including pulse frequency
modulation, pulse interleaving, and wavetable synthesis. It also features some
advanced effects such as low- and high-pass filters, and a simple reverb.

Beepertoy is made up of a number of different "cores", each providing a 
different configuration. The user can switch between cores at any time between
two notes.

The available configurations as of version 0.1 are:

1) SQUEEKER EMULATOR: 4 channels of short pulse with configurable width
2) 4x PIN: 4 channels of pin pulse
3) TRITONE EMULATOR: 3 channels of square wave with configurable duty, with 
      various noise/glitch modes
4) OCTODE EMULATOR: 8 channels of pin pulse
5) 3x WAVETABLE + FILTERS: 3 channels of wavetable synthesis (256B tables), 
      optional global lo/hi-pass 
6) 2x SQUARE + FILTERS + VOLUME + FX: 2 channels of square wave with 
      configurable duty cycle, volume control, reverb or fixed-pitch sample, 
      optional global lo-pass, one of the channels can play noise
7) ROM NOISE: simple noise generator
	  
All configurations provide additional support for configurable click drums.


================================================================================
NMOS vs CMOS Z80
================================================================================

Beepertoy uses the OUT (C),0 command, which has different effects on NMOS
(original Spectrum) and CMOS (many Spectrum clones) CPUs. The driver will
attempt to detect the CPU type on startup and patch the code accordingly.
However, this is somewhat unreliable and may fail on some machines. You can
disable CPU detection and force compilation to either NMOS or CMOS by modifying
line 34 in main.asm. To force the NMOS version, simply comment out the line.
To force the CMOS version, replace the CALL to "detectCPU" with a CALL to
"patchCMOS".

Credit for the MOS detection code goes to introspec and JtN.


================================================================================
Usage
================================================================================

Unfortunately Beepertoy is too complex to simulate via an XM template, so 
currently music can only be made by coding in assembly.


SEQUENCE

Music data for Beepertoy must always start with a song sequence, ie. a list of
patterns in the desired play order. The sequence list is terminated with a 
0-word. The sequence must also contain the label "loop" at some point - this 
specifies the position the player will loop to once it has reached the end of
the sequence. To disable looping, uncomment line 60 in main.asm.


WAVETABLES/SAMPLES

Samples in Beepertoy are simple 256-byte PCM wavetables. Normally, each
wavetable should contain a single waveform. When using more complex waveforms
(for example percussion), trigger them at a low frequency.

Each byte in a wavetable represents a relative sample volume at a given time.
The maximum combined relative volume of all samples used at a given pattern row
must not exceed 12. Usually this means that all values in your sample should be
between 0 and 4.

All samples must be included in the samples.asm file. You can provide an empty 
samples.asm file if you don't want to use samples, however you can not omit it 
unless you modify main.asm accordingly.


PATTERN DATA

The layout of the pattern data varies depending on which synthesis configuration
is used. However, there are a few common traits.

Most importantly, all patterns must terminate with a single byte with the value 
0x40.

All pattern rows start with a word containing the speed (length of the row in 
ticks, that is) in the high byte, and drum flags in the low byte. The speed 
value should not exceed 0x3f. The drum flags are as follows:

bit 0: hi-hat
bit 2: kick
bit 7: snare

Only one of the flags may be set in any given row.

If a drum is used, the second entry of the pattern row is a word specifying the
volume of the drum. The low byte is the actual volume (0x80 is the maximum, 
volume decreases with both lower and higher values). The high byte is always 0.
If the current row does not use click drums, this word is omitted.

After this, everything depends on the synth configuration you intend to use. A
description of the various configurations follows.


================================================================================
SQUEEKER EMULATOR
================================================================================

As the name suggests, this configuration uses the synthesis method from 
Zilogat0r's Squeeker engine. It supports 4 channels, but unlike with the
original Squeeker, each channel can have it's own duty cycle setting. A data
row for this configuration is constructed as follows:

dw <SPEED * 256 + FLAGS>
[dw <DRUM VOL>]
dw <DUTY.CHANNEL1 * 256 + DUTY.CH2>
dw <DUTY.CH3 * 256 + DUTY.CH4>
dw squeekpin0
dw <FREQUENCY.CH4>
dw <FREQ.CH1>
dw <FREQ.CH2>
dw <FREQ.CH3>


================================================================================
4x PIN
================================================================================

Ordinary 4-channel accumulating PFM (pin pulse) synthesis. This configuration is
really quite basic. It is considered for removal in a later version of 
Beepertoy. For now, data rows are constructed as follows:

dw <SPEED * 256 + FLAGS>
[dw <DRUM VOL>]
dw 0
dw 0
dw accupin0
dw <FREQ.CH1>
dw <FREQ.CH2>
dw <FREQ.CH3>
dw <FREQ.CH4>


================================================================================
TRITONE EMULATOR
================================================================================

A somewhat loose emulation of Shiru's Tritone engine, this configuration plays 3
channels of square wave with configurable duty cycles. Some channels can be 
configured to play noise or glitchy sounds instead of tone. It runs twice as 
fast, and plays at double pitch compared to the other configurations. Channels 1
and 2 have the same volume, channel 3 is about 45% louder.

Data rows are constructed as follows:

dw <SPEED * 256 + FLAGS>
[dw <DRUM VOL>]
dw <DUTY.CHANNEL1 * 256 + DUTY.CH2>
dw <DUTY.CH3 * 256 + FX_CONFIG>
dw tritone0
dw <FREQ.CH2>
dw <FREQ.CH3>
dw <FREQ.CH1>

The following FX CONFIGurations are available

CONFIG  effect
#07     no effect
#05     vibrato ch2 (strength varies depending on freq.ch2, often quite subtle)
#04     play noise on ch2
#02     glitch ch2
#00     glitch ch3

In order to play noise, you need to feed ch2 with a suitable frequency value.
#35d1 is usually a good bet.


================================================================================
OCTODE EMULATOR
================================================================================

This configuration emulates Shiru's Octode engine, providing 8 channels of pin
pulse sound. However, unlike the original it uses 16-bit note counters. Some
corners had to be cut in order to achieve this within the limitations of 
Beepertoy. As a result, you cannot run this config with all channels muted. 
Channel 8 must always have a note set, and the note value must be between #0100 
and #e000. Also, the sound core runs very slightly out of sync. Speed is off by 
about -0.13%, and pitch is off by about -0,52% compared to the other 
configurations.

Data rows are constructed as follows:

dw <SPEED * 256 + FLAGS>
[dw <DRUM VOL>]
dw <FREQ.CH1>
dw <FREQ.CH2>
dw octode0
dw <FREQ.CH3>
dw <FREQ.CH4>
dw <FREQ.CH5>
dw <FREQ.CH6>
dw <FREQ.CH7>
dw <FREQ.CH8> (must be >= #1000 && < #e000)


================================================================================
3x WAVETABLE + FILTERS
================================================================================

This configuration allows you to play 3 channels of table-based waveforms
(samples), with optional global filters. Data rows are constructed as follows:

dw <SPEED * 256 + FLAGS>
[dw <DRUM VOL>]
dw #0
dw <FILTER_CONFIG_A>
dw <FILTER_CONFIG_B>
dw <FREQ.CH1>
dw <SAMPLE.CH1>
dw <FREQ.CH2>
dw <SAMPLE.CH2>
dw <FREQ.CH3>
dw <SAMPLE.CH3>

The following FILTER CONFIGurations are available:

CONFIG_A   CONFIG_B  effect
#0         core0hs   hi-pass (not very effective, unfortunately)
#17cb      core0S    no filter
#0         core0S    lo-pass, high cut-off
#2fcb      core0S    lo-pass, low cut-off

Note that the filters can kill the sound entirely at very low volumes.


================================================================================
2x SQUARE + FILTERS + VOLUME + FX
================================================================================

This configuration allows you to play 2 channels of square waves with
configurable duty cycle, with optional global lo-pass and reverb. Reverb is not
very effective, and may at times lead to rather unexpected results. You can also 
deactivate reverb, or play a fixed-pitch sample instead. Both channels have
volume control. Channel 2 can be configured to play noise.

Data rows are constructed as follows:

dw <SPEED * 256 + FLAGS>
[dw <DRUM VOL>]
dw <REVERB_CONFIG_A>
dw <REVERB_CONFIG_B>
dw <NOISE> ("core0" to disable, "core0n" to enable)
dw <FREQ.CH1>
dw <DUTY.CH1 * 256 + VOLUME.CH1>
dw <FREQ.CH2>
dw <DUTY.CH2 * 256 + VOLUME.CH2>
dw <FILTER_CONFIG>

The combined volume of both channels must not exceed 8 when reverb or sample
playback is enabled, and must not exceed 12 when reverb/sample playback is
disabled. For sample playback, the sample may not exceed a volume of 4.

The following REVERB CONFIGurations are available:

CONFIG_A              CONFIG_B              effect
dw reverbBuffer       dw reverbBuffer+#nn   enable reverb with delay length #nn
dw reverbBufferEmpty  dw reverbBuffer       disable reverb
dw <SAMPLE>           dw reverbBuffer       enable fixed-pitch sample playback

The following FILTER CONFIGurations are available:

CONFIG    effect
#17cb     no filter   
#0        lo-pass, high cut-off
#2fcb     lo-pass, low cut-off

Note that the lo-pass can kill the sound entirely at very low volumes.

In order to play noise, you need to feed ch2 with a suitable frequency value.
#35d1 is usually a good bet.


================================================================================
ROM NOISE
================================================================================

This configuration will simply read values from the ROM (and eventually, RAM),
and send them to the beeper, producing some ear-deafening noises.

Data rows are constructed as follows:

dw <SPEED * 256 + FLAGS>
[dw <DRUM VOL>]
dw <POINTER TO ROM> (eg. dw 0)
dw 0
dw romNoise0

Parsing is fast at 1792 bytes per tick, meaning you will have played the entire
ZX Spectrum address space after about 37 ticks.


================================================================================
GREETINGS AND THANKS TO
================================================================================

Alone Coder, Factor6, garvalf, introspec, Mister Beep, Shiru, TDM, Tufty, 
Zilogat0r

================================================================================
eof.