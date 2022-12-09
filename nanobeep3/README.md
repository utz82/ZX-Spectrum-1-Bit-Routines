# nanobeep3

## About

What is the smallest possible multi-channel beeper engine on ZX Spectrum? While nanobeep3 may not be the definitive answer to that question, it is an exploration of this precise subject matter.

Small beeper engines were first explored by Shiru in 2011. The result was Huby, a 100 byte (later reduced to 99 bytes) 2-channel pin pulse engine with 8-bit frequency resolution, global speed, an interrupting click drum, and a compact data format using fixed-length patterns.

In 2016 I published nanobeep, which clocked in at 56 bytes, albeit by cutting some corners, namely omitting the click drum (can be added for an additional 15 bytes) and a slightly less efficient data format. Furthermore, I used an "incomplete" keypress check in the form

        in a,(#fe)
	    rra
	    jr nc,key_pressed

which will only check the first keyboard column, saving two bytes from a full check. Considering that this column includes the Space bar, I feel that this is an acceptable compromise. Most importantly though, the sound quality of nanobeep's pin pulse synthesis algorithm is hardly acceptable.

In 2017, I released nanobeep2. The goal for this one was not to beat nanobeep's size, but rather to improve the sound and cram as many features as possible into a sub-100 byte engine. The bare-bones 64 byte version features pulse interleaving synthesis, but again no click drum, which costs an additional 11 bytes. More features such as PWM sweep, per-pattern speed and extended note range can be added, each increasing the player size by a few bytes.

I've since pondered the small engine category many times, ultimately coming to the conclusion that nanobeep's 56 bytes cannot be beat. Or can it?

It depends on how we define what constitutes a proper multi-channel engine. If we throw all possible requirements except "it should play at least two-channel music" out of the window, we can come up with 14 bytes of code that do exactly that:

	    di
        ld sp,music_data
	play
		add hl,de               ; classic 12-bit divider algorithm
        ld a,h                  ; tracking bit 4 produces a square wave
		exx
        out (#fe),a
        djnz .play
		pop de
        jr .read+2              ; transitions will be audible, so adjust timing

Well, it certainly does the trick, but it's pretty much unacceptable in any other respect. The data size would be huge, as it requires a new data word every ~11K cycles, and it does not even check for the end of the tune, not to mention the missing keypress check.

Let's address some of these issues. Adding a keypress check does not leave much room for experimentation, so we will just use the "incomplete" checking code from nanobeep. The next thing to note is that since the engine core is so fast, our 12-bit frequency dividers are not that useful, as a good part of the audible range can be covered with just the lower 8 bits. With a bit of wiggling, we can squeeze a good 4 octaves into this. While this does not actually solve our "big data" problem yet, it is at least a step in the right direction, cutting data size in half. Finally, we will add an end check, bringing the total engine size up to 38 bytes.

		di
		xor a
		ld d,a                  ; must null both D regs since we never set them
		exx
		ld d,a
		push hl                 ; preserve hl' for return to BASIC
		ld (.old_sp),sp
		ld sp,music_data

	play
		in a,(#fe)              ; incomplete keypress check
		rra
		jr nc,.exit

		add hl,de
		ld a,h
		exx
		out (#fe),a
		djnz play

		dec sp                  ; offset SP since we throw away the lo byte
		pop af                  ; get next frequency divider

		ld e,a
		inc a                   ; 0xff marks song end
		jr nz,play+7

	exit
	old_sp = $+1
		ld sp,0
		pop hl
		exx
		ei
		ret

The next step towards fixing the data size problem is to implement sequencing. Bolting sequencing onto the above code would bring us well above 56 bytes, so we need a better idea.

Since we're no longer using 12-bit dividers, we could use the C registers to hold the dividers at the cost of 1 additional byte, freeing up the DE registers in the process. That gives us not one, but two potential pointers, meaning we can also split up the patterns to have per-channel patterns. With this, we don't need the C registers either, as we can just read data from (de).

		di
		exx
		push hl
		ld (.old_sp),sp
		ld sp,music_data
		pop de
		exx
		pop de

	play
		ld a,(de)
		inc a
		jr nz,skip
		pop de
		inc d
		jr z,exit
	skip
	    dec a                  ; needed to facilitate rests
		add a,l
		ld l,a
		adc a,h
		sub l
		ld h,a
	rret
		exx
		out (#fe),a
		djnz play

		inc de

		in a,(#fe)
		rra
		jr c,rret

	exit
	old_sp = $+1
		ld sp,0
		pop hl
		exx
		ei
		ret

We also need two dummy pointers at the start of the sequence to properly initialize the player, bringing up the total size to 49 bytes. Now we still need to implement proper step length counting, so we do not need to duplicate large amounts of pattern data. Simply bolting on 16-bit counting would not quite cut it, since it would require at least 9 additional bytes: 3 bytes for the counting itself, and 6 bytes for setup, as both BC registers need to be initialized to avoid a prolonged, noisy warm-up. So we need to rethink our design once more.

Since we have enough registers free, we can actually implement per-channel patterns, which makes for a highly efficient data scheme. And since our two channels work exactly the same way, we only need to implement the data reader once and simply swap the register set to switch between channels. As it turns out, it is also practical to implement variable note lengths, making our data scheme even more efficient.

		di
		ld hl,music_data.pend-1    ; point to a pattern end and set note length
		ld bc,1                    ; to 1 in order to initialize this channel
		exx
		push hl
		ld (.old_sp),sp
		ld sp,music_data

		jr .read_sequence

	.read_keys
		in a,(#fe)
		rra
		jr nc,.exit

	.play
		exx
		ld a,(hl)
		add a,e
		ld e,a
		adc a,d
		sub e
		ld d,a
		out (#fe),a

		dec bc
		ld a,b
		or c
		jr nz,.play

	.read_pattern
		inc hl                      ; read next pattern byte (length)
		ld b,(hl)                   ; if it's #ff, end of pattern is reached
		inc hl                      ; point to note byte
		inc b
		jr nz,.read_keys

	.read_sequence
		pop hl
		inc h
		jr nz,.read_pattern+1

	.exit
	.old_sp = $+1
		ld sp,0
		pop hl
		exx
		ei
		ret

And there we have it, a complete beeper engine in 54 bytes. A whopping 2 bytes better than nanobeep.


## Features

- 2 square wave channels
- 8-bit frequency dividers, usable range c-2 - b-5 (lower notes available, but possibly detuned)
- per-row tempo
- compact data scheme
- code size 54 bytes


## Music Data Layout

nanobeep3 uses a standard sequence/pattern data layout with per-channel patterns.

## Sequence

The sequence defines the order in which patterns are played. It consists of a list of pattern pointers, offset by -256. The sequence end is marked by the value 0xff00.

Since patterns are split per channel, can have arbitrary length, and the first channel is loaded with a 1-frame delay, care must be taken when constructing the sequence, so that pattern pointers are passed to the correct channel. Consider the following:

    ;; sequence
	    dw p00,p01      ;; p00 goes to channel 1, p01 goes to channel 2
		dw p02,p03      ;; p01 has not finished playing here, so both p02 and
		                ;; p03 go to channel 1!

	p00 = $-#100
	    db #07,c2       ;; 8 ticks
		db #07,c3       ;; 8 ticks
		db #ff

	p01 = $-#100
	    db #3f,c1       ;; 64 ticks
		db #ff

	p02 = $-#100
		db #07,c4
		db #07,c5

	p03 = $-#100
	    db #3f,g1
		db #ff

The safest option is to always use pairs of patterns of the same length.

## Patterns

Patterns hold note data for a single channel. Each row in a pattern holds two 8-bit values: The note length in ticks, offset by -1, and the frequency divider. The pattern end is marked by the value 0xff.
