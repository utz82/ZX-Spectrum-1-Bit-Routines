;******************************************************************
;yawp
;3 channel pcm player for ZX Spectrum beeper
;by utz 09'2015
;******************************************************************


;IX - add counter 1
;IY - add counter 2
;HL' - add counter 3
;SP - base freq 1/2/3
;DE - sample pointer 1
;HL - sample pointer 2
;DE' - sample pointer 3
;B,C' - timer
;C used, value doesn't matter


	org #8000

	di
init
	ei			;detect kempston
	halt
	in a,(#1f)
	inc a
	jr nz,_skip
	ld (maskKempston),a
_skip	
	di
	exx
	push hl			;preserve HL' for return to BASIC
	ld (oldSP),sp
	ld hl,musicdata
	ld (seqpntr),hl

;******************************************************************
rdseq
seqpntr equ $+1
	ld sp,0
	xor a
	pop de			;pattern pointer to DE
	or d
	ld (seqpntr),sp
	jr nz,rdptn0
	
	;jp exit		;uncomment to disable looping
	
	ld sp,loop
	jr rdseq+3

;******************************************************************
rdptn0
	ld (patpntr),de	
rdptn
	in a,(#1f)		;read joystick
maskKempston equ $+1
	and #1f
	ld c,a
	in a,(#fe)		;read kbd
	cpl
	or c
	and #1f
	jp nz,exit

patpntr equ $+1			;fetch pointer to pattern data
	ld sp,0
	
	pop de			;sample pointer 3/end + speed
	
	or e
	jr z,rdseq
	
	ld c,e			;c=speed		
	ld e,0
	ld h,e			;reset add counter 3
	ld l,e

	exx
	pop hl			;base freq 1
	ld (freq1),hl
	
	pop hl
	ld (freq2),hl
	
	pop hl
	ld (freq3),hl
	
	pop de			;sample pointers 1,2
	ld h,e
	
	xor a
	ld e,a
	ld l,a
	ld b,a
	
	ld (patpntr),sp		;preserve data pointer	
	
	ld ix,0			;reset add counters 1,2
	ld iy,0

	ld a,(de)		;preload sample pointer 1
		
play
;*******************************************************frame1

	out (#fe),a	;11--28 ch3-3
	
	rrca		;4
freq1 equ $+1
	ld sp,0		;10	
	out (#fe),a	;11--25 ch1-1
	
	rrca		;4
	add ix,sp	;15
	out (#fe),a	;11--30 ch1-2
		
	sbc a,a		;4		;update sample pointer
	add a,e
	ld e,a
	nop		;4		;waste time for exx
	ld a,(hl)	;7		;reload sample pointer 2
	out (#fe),a	;11--34 ch1-3
	
	rrca		;4
	exx		;4
	out (#fe),a	;11--19 ch2-1
	
	rrca		;4
	nop		;4
	out (#fe),a	;11--19 ch2-2
	
	ld a,(de)	;7		;reload sample pointer 3
	out (#fe),a	;11--18 ch2-3
	
	rrca		;4
	exx		;4
	out (#fe),a	;11--19 ch3-1
	
	rrca		;4
	nop		;4		;waste time for dec b
	ret c		;5		;waste time
	out (#fe),a	;11--24 ch3-2

	ld sp,0		;10		;waste time for jp nz,play	
	ld a,(de)	;7		;reload sample pointer 1
			;216
	
;*******************************************************frame2
	out (#fe),a	;11--28
	
	rrca		;4
freq2 equ $+1
	ld sp,0		;10
	out (#fe),a	;11--25
	
	rrca		;4
	add iy,sp	;15
	out (#fe),a	;11--30
	
	sbc a,a		;4
	add a,l		;4
	ld l,a		;4
	ld a,(hl)	;7
	nop		;4
	out (#fe),a	;11--34
	
	rrca		;4
	exx		;4
	out (#fe),a	;11--19
	
	rrca		;4
	nop		;4
	out (#fe),a	;11--19
	
	ld a,(de)	;7
	out (#fe),a	;11--18
	
	rrca		;4
	exx		;4
	out (#fe),a	;11--19
		
	rrca		;4
	dec b		;4		;decrement timer
	ret c		;5
	out (#fe),a	;11--24
	
	ld sp,0		;10
	ld a,(de)	;7
	
;*******************************************************frame3
	out (#fe),a	;11--28
	
	rrca		;4
freq3 equ $+1
	ld sp,0		;10
	out (#fe),a	;11--25
	
	rrca		;4
	exx		;4
	add hl,sp	;11
	out (#fe),a	;11--30

	sbc a,a		;4
	add a,e		;4
	ld e,a		;4
	exx		;4
	ld a,(hl)	;7
	out (#fe),a	;11--34
	
	rrca		;4
	exx		;4
	out (#fe),a	;11--19
	
	rrca		;4
	nop		;4
	out (#fe),a	;11--19
	
	ld a,(de)	;7
	out (#fe),a	;11--18
	
	rrca		;4
	exx		;4
	out (#fe),a	;11--19
	
	rrca		;4
	ret c		;5
	dec b		;4		;decrement timer
	out (#fe),a	;11--24
	
	ld a,(de)	;7
	jp nz,play	;10
	
	exx
	dec c
	exx
	jp nz,play
	
	jp rdptn
;*******************************************************	
		
exit
oldSP equ $+1
	ld sp,0
	pop hl
	exx
	ei
	ret
;******************************************************************

	
musicdata
	include music.asm

	org 256*(1+(HIGH($)))
samples
	include samples.asm