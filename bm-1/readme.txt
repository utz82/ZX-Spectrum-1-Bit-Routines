********************************************************************************
BM-1, aka BeepModular-1
by utz 02'2017 * irrlichtproject.de | github.com/utz82
********************************************************************************


About
=====

BM-1 is an experimental sound routine for the ZX Spectrum beeper. It features a
highly versatile synthesis core that can be modified during runtime, which 
makes it possible to generate a near-endless range of different sounds.


Features include:

- 2 tone channels, 12-bit or 15-bit frequency dividers
- patches: on-the-fly modifications of the synthesis algorithm
- volume control (8 levels per channel, availability depends on patch)
- tables: change pitch and fx parameters per tick
- functions: arbitrary code execution/modification once per tick
- customizable click drums
- per-step tempo control
- compact player size (375 bytes, can be reduced by disabling features)
- optimized data format

With patches, you can produce

- variable duty cycles
- phatness/harmonics control
- fake chords
- bytebeat-like glitches
- SIDsound (duty sweep)
- noise




Usage
=====

Unfortunately no editor exists for this engine, so any music must be composed
directly in assembly. Furthermore, at least a basic understand of Z80 machine
code is required, as BM-1 makes use of actual code snippets (called "patches")
embedded within the song data. Note that it is perfectly possible to crash the 
player through use of invalid code.

The code is intended to be assembled with Pasmo.




Music Data Format
=================

Music data for BM-1 consists of a sequence, one or more patterns, one or more
patches, one or more fx tables (omitted when USETABLES is set to 0 in main.asm),
and optionally blocks of code to be executed by fx tables.



SEQUENCE:

A list of pattern pointers in the order in which they are to be played. The list
is terminated with a 0-word. Unless USELOOP is set to 0 in main asm, a label 
called "mloop" must be used within the sequence to specify the position the 
player will loop to after completing the sequence. A simple valid sequence thus
may look like this:

mloop
	dw ptn0
	dw 0


	
PATTERNS:

Patterns contain the actual music data. Each pattern row contains 2-11 word-
length entries. The layout is as follows:

word 0: drum_parameter << 8 | control_byte0
        ctrl0 bit 7 set: trigger noise click drum
	                 -> drum_param bit 0..6 sets volume
			    drum_param bit 7 toggles high/low pitch (set = hi)
        ctrl0 bit 6 set: end of pattern (all patterns should terminate with 
	                 db #40).
        ctrl0 bit 2 set: trigger kick click drum (ignored when bit 7 is set)
	                 -> drum_param set starting pitch
        ctrl0 bit 0 set: skip loading all channel parameters (omit words 1..8)
	drum_param should be 0 if no click drums are triggered (affects lo-byte
	  of tempo counter)
	  
word 1: patch_param1_7 << 8 | control_byte1
        ctrl1 bit 7 set: skip patch_param1_8..11
	ctrl1 bit 6 set: no patch update (omit word 2)
	ctrl1 bit 2 set: skip patch_param1_1..6
	ctrl1 bit 0 set: skip all updates for ch1 (omit words 2..4)
	
word 2: patch_pointer_ch1

word 3: frequency_divider_ch1
        if bit 15 is reset, omit word 4
	
word 4: generic_parameter_ch1

word 5: patch_param2_7 << 8 | control_byte2
        ctrl1 bit 7 set: skip patch_param2_8..11
	ctrl1 bit 6 set: no patch update (omit word 6)
	ctrl1 bit 2 set: skip patch_param2_1..6
	ctrl1 bit 0 set: skip all updates for ch2 (omit word 6..8)
	
word 6: patch_pointer_ch2

word 7: frequency_divider_ch2
        if bit 15 is reset, omit word 8
	
word 8: generic_parameter_ch2

word 9: row_tempo << 8 | control_byte3
        ctrl3 bit 6 set: skip table_pointer update (omit word 10)
	
word 10: table_pointer

All values except the generic parameters must be initialized at the beginning of
the sequence.

Each pattern must end with and end marker (= db #40, see ctrl0), unless followed
by another pattern (which will be loaded once the current one is completed).



TABLES:

Tables contain additional data, which is parsed once per row tick (eg. at a rate
of about 61 Hz). Tables can modify the frequency dividers, and the generic
parameters. They can also modify everything else via function execution. The 
layout is as follows:

word 0: control_byte0
        ctrl0 bit 7 set: perform table jump (pointer to table location follows)
	ctrl0 bit 6 set: stop table execution (hi-byte can be omitted)
	ctrl0 bit 2 set: execute function (pointer to function follows)
	ctrl0 bit 0 set: no update on this tick (hi-byte is omitted)
	any of the above, omit word 1..5

word 1: control_byte1
        ctrl1 bit 7 set: skip freq_div2 update (omit word 4)
	ctrl1 bit 6 set: skip freq_div1 update (omit word 2)
	ctrl1 bit 2 set: skip generic_param2 update (omit word 5)
	ctrl1 bit 0 set: skip generic_param1 update (omit word 3)
	
word 2: frequency_divider_ch1

word 3: generic_parameter_ch1

word 4: frequency_divider_ch2

word 5: generic_parameter_ch2

Each tables must end with either a table jump, or a table stop (= db #40), 
unless followed by another table (which will be loaded once the current one is 
completed).



PATCHES:

Patches are code templates, which are copied into the synthesis core at runtime.
They consist 10 single-byte, 4-cycle instructions, or an equivalent amout of 
2-byte, 8-cycle instructioins. The first 6 instructions or the last 4 
instructions may be omitted, if the control bytes of pattern row that sets the 
patch (ctrl1 resp. ctrl2) are set accordingly. An additional instruction is
set directly by the control byte. Instructions are executed as follows:

- Instruction 1..6 are executed before the first OUT command (patchX_1..6), ie. 
  before the channel starts playing. At this point the channel frequency counter 
  has been updated, and the high-byte of the counter has been loaded into the 
  accumulator A.
- The additional instruction set by the ctrl1/2 is executed between the first
  and the second OUT command (patchX_7), ie. after the channel has played for 
  16 cycles
- Instruction 8-10 are executed between the second and the third OUT command
  (patchX_8..11), ie. after the channel has played for 16+32=48 cycles. After 
  the third OUT command, the channel will continue to play for another 64 
  cycles, resulting in a total playtime of 128 cycles per sound loop iteration.

As mentioned before, only instructions that align to 4 cycles per instruction 
byte can be used. It is entirely possible to break the player with patch code, 
hence caution is advised. Some general rules of thumb:

- Stick to instructions that modify either the accumulator A, or the generic 
  parameters (IXH/IXL for ch1, IYH/IYL for ch2). 
- Be extra careful when modifying registers D,E,H,L and their shadow 
  counterparts.
- It is almost certainly a bad idea to use indirect jumps (jp (hl/ix/iy)).
- It is almost certainly a bad idea to modify registers B, C, B', C'.



Some standard patches are provided as macros in patches.h, check them for
further reference.



FUNCTIONS:

Functions can contain arbitrary code, which may modify any sound parameter and/
or the synthesis core. Function code is triggered by table execution.

Each function must end with a jump to either noTableExec or tblStdUpdate. When
jumping to noTableExec, the player will return to the synthesis core. When
jumping to tblStdUpdate, the player will immediately parse another row of table 
data instead.

Using functions poses a significant risk of breaking/crashing the engine, of
course. Do not use this feature unless you have a good understanding of how the
engine code works.

Generally speaking, any operations involving the stack is almost guaranteed to
crash the player.




Assembler Switches
==================

At the top of main.asm, you will find 3 switches:

USETABLES - enables tables
USEDRUMS - enables click drums
USELOOP - enables looping

Set any of these switches to 0 to disable the feature. This will reduce the
player size. Disabling tables will reduce the player size by 63 bytes, disabling
click drums will reduce the size by 99 bytes, and disabling looping will reduce
the size by 5 bytes.