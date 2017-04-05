macro reset_all
	ds 10
endm

macro saw_wave		;expects paramX_7 = #0f (rrca)
	ds 6
	rrca
	ds 3
endm

macro harmonics		;expects paramX_7 = #07 (rlca)		
	rrca
	rrca
	rrca
	ds 3
	rlca
	ds 3
endm

macro noise
	rlc h
	ds 2
endm

macro noise2
	rlc h
	and h
	nop
endm

macro noise3
	rlc h
	sbc a,a
	or h
endm

macro noise4
	rlc h
	or h
	xor l
endm

macro pfm		;use on both channels for true pin pulse experience
	sbc a,a		;use iyh instead of ixh when only using on ch2
	or ixh
	add a,a
	ld ixh,a
	ds 4
endm

macro noise_vol_ch1	;expects param1_7 = #0f (rrca)
	cp ixh
	sbc a,a
	and ixl
	nop
	rrca
	rlc h
	nop
endm

macro noise_vol_ch2	;expects param2_7 = #0f (rrca)
	cp iyh
	sbc a,a
	and iyl
	nop
	rrca
	rlc h
	nop
endm

macro supersquare_ch1
	exx
	add a,b
	ds 4
	sub b
	exx
	ds 2
endm

macro supersquare_ch2
	add a,b
	ds 5
	sub b
	ds 3
endm

macro organ_ch1		;expects param1_7 = #07 (rlca)
	add a,ixh	;recommended: ixh = #01..#0f
	or h		;use and h for slightly different sound
	rrca
	rrca
	rrca
	rlca
	ds 3
endm

macro organ_ch2		;expects param2_7 = #07 (rlca)
	add a,iyh	;recommended: iyh = #01..#0f
	or h		;use and h for slightly different sound
	rrca
	rrca
	rrca
	rlca
	ds 3
endm


macro duty_vol_ch1	;expects param1_7 = #0f (rrca)
	cp ixh
	sbc a,a
	and ixl
	nop
	rrca
	ds 3
endm

macro duty_vol_ch2	;expects param2_7 = #0f (rrca)
	cp iyh
	sbc a,a
	and iyl
	nop
	rrca
	ds 3
endm


macro sid_sound_ch1	;expects param1_7 = #9f (sbc a,a)
	sbc a,a
	add a,ixh
	ld ixh,a
	cp h
	ds 3
endm

macro sid_sound_ch2	;expects param2_7 = #9f (sbc a,a)
	sbc a,a
	add a,iyh
	ld iyh,a
	cp h
	ds 3
endm


macro fake_chord_ch1	;may also produce glitches, or nothing special at all
	xor ixl		;depending on freq_div and value in ixl
	ld h,a
	cp ixh
	sbc a,a
	ds 4
endm

macro fake_chord_ch2	;may also produce glitches, or nothing special at all
	xor iyl		;depending on freq_div and value in iyl
	ld h,a
	cp iyh
	sbc a,a
	ds 4
endm


macro phaserlike
	daa
	rlca
	cpl
	xor h
	rrca
	rrca
	ds 4
endm

macro oboe		;expects paramX_7 = #0f (rrca)
	daa
	rlca
	rlca
	cpl
	xor h
	nop
	rrca
	ds 3
endm

macro hardnheavy
	daa
	cpl
	xor h
	rrca
	ds 2
	ds 4
endm

macro phat1
	daa			;15	phat rasp
	rrca
	rrca
	cpl
	or h
	nop
	ds 4
endm

macro phat2
	daa			;16	phat 2
	rrca
	rrca
	cpl
	and h
	nop
	ds 4
endm

macro phat3
	daa			;19	phat 5
	rrca
	rrca
	cpl
	xor h
	nop
	ds 4
endm

macro phat4
	cpl			;13	rasp 1
	daa
	sbc a,a
	rlca
	and h
	nop
	ds 4
endm

macro slightly_phat
	rlca			;1b	phat 7
	rlca
	sbc a,a
	and h
	rlca
	nop
	ds 4
endm
