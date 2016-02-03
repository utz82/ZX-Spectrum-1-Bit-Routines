;wtfx - wavetable player with fx
;by utz 02'2016

;hl     - add counter ch1
;hl'    - add counter ch2
;de/de' - temporarily hold base freq. values and sample pointers
;c/c'   - #fe
;b/b'   - timer lo/hi-byte


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
	
	ld sp,loop		;get loop point
	jr rdseq+3
	
exit
oldSP equ $+1
	ld sp,0
	pop hl
	exx
	ei
	ret

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

	pop af
	jr z,rdseq
	
	ld b,0			;set timer
	ld c,#fe
	
	pop de			;freq.ch1
	pop hl			;smp.ch1
	
	exx
	
	ld b,a
	ld c,#fe
	pop de			;freq.ch2
	pop hl			;smp.ch2
	pop ix			;fx table address
	
	ld (patpntr),sp		;preserve pattern pointer
	
	ld sp,buffer+8		;load buffer pointer
	
	ld a,(hl)		;load initial sample ch2
	push hl
	push de
	
	ld hl,0			;prepare add counter ch2
	exx
	ex af,af'
	
	push hl
	push de
	
	ld a,(hl)		;load initial sample ch1
	ld hl,0			;prepare add counter ch1
	

playRow
;*********************************************************************
frame1					;calculate counter ch1
	out (c),a		;12	ch1/1
	rlca			;4__16
	out (c),a		;12	ch1/2	
	rlca			;4__16	ch1/3		
	out (c),a		;12
	rlca			;4
	nop			;4
	nop			;4__24
	out (c),a		;12	ch1/4	
	rlca			;4
	ex af,af'		;4
	nop			;4
	nop			;4
	nop			;4__32
	
	out (c),a		;12	ch2/1
	rlca			;4__16
	out (c),a		;12	ch2/2	
	rlca			;4
	nop			;4
	dec b			;4__24	adjust timer
	out (c),a		;12	ch2/3
	rlca			;4
	pop de			;10	base freq ch1
	dec sp			;6__32	timing
	out (c),a		;12	ch2/4	
	rlca			;4
	ex af,af'		;4
	add hl,de		;11	add to counter ch1
	ld r,a			;9__40	timing

;*********************************************************************
frame2					;load sample ch1
	out (c),a		;12	ch1/1
	rlca			;4__16
	out (c),a		;12	ch1/2	
	rlca			;4__16	ch1/3		
	out (c),a		;12
	rlca			;4
	nop			;4
	nop			;4__24
	out (c),a		;12	ch1/4	
	rlca			;4
	ex af,af'		;4
	nop			;4
	nop			;4
	nop			;4__32
	
	out (c),a		;12	ch2/1
	rlca			;4__16
	out (c),a		;12	ch2/2	
	rlca			;4
	nop			;4
	nop			;4__24	ch2/3
	out (c),a		;12
	rlca			;4
	inc sp			;6	timing
	pop de			;10_32	base sample pointer ch1
	out (c),a		;12	ch2/4	
	rlca			;4
	ex af,af'		;4
	ld e,h			;4	set sample pointer lo-byte ch1
	ld a,(de)		;7	load sample
	ld r,a			;9__40	timing

;*********************************************************************	
frame3					;calculate counter ch2
	out (c),a		;12	ch1/1
	rlca			;4__16
	out (c),a		;12	ch1/2	
	rlca			;4__16	ch1/3		
	out (c),a		;12
	rlca			;4
	nop			;4
	nop			;4__24
	out (c),a		;12	ch1/4	
	rlca			;4
	ex af,af'		;4
	nop			;4
	nop			;4
	nop			;4__32
	
	out (c),a		;12	ch2/1
	rlca			;4__16
	out (c),a		;12	ch2/2	
	rlca			;4
	nop			;4
	exx			;4__24	ch2/3
	out (c),a		;12
	rlca			;4
	pop de			;10	base freq ch2
	dec sp			;6__32	timing
	out (c),a		;12	ch2/4	
	rlca			;4
	ex af,af'		;4
	add hl,de		;11	add to counter ch2
	ld r,a			;9__40	timing

;*********************************************************************
frame4					;load sample ch2		
	out (c),a		;12	ch1/1
	rlca			;4__16
	out (c),a		;12	ch1/2	
	rlca			;4__16	ch1/3		
	out (c),a		;12
	rlca			;4
	nop			;4
	nop			;4__24
	out (c),a		;12	ch1/4	
	rlca			;4
	ex af,af'		;4
	nop			;4
	nop			;4
	nop			;4__32
	
	out (c),a		;12	ch2/1
	rlca			;4__16
	out (c),a		;12	ch2/2	
	rlca			;4
	nop			;4
	nop			;4__24	ch2/3
	out (c),a		;12
	rlca			;4
	inc sp			;6	timing
	pop de			;10_32	base sample pointer ch2
	out (c),a		;12	ch2/4	
	rlca			;4
	ld e,h			;4	set sample pointer lo-byte ch2
	ld a,(de)		;7	load sample
	ld r,a			;9	timing	
	ex af,af'		;4__40

;*********************************************************************	
frame5					;update timer and reload stack pntr		
	out (c),a		;12	ch1/1
	rlca			;4__16
	out (c),a		;12	ch1/2	
	rlca			;4__16	ch1/3		
	out (c),a		;12
	rlca			;4
	nop			;4
	nop			;4__24
	out (c),a		;12	ch1/4	
	rlca			;4
	ex af,af'		;4
	nop			;4
	nop			;4
	nop			;4__32
	
	out (c),a		;12	ch2/1
	rlca			;4__16
	out (c),a		;12	ch2/2	
	rlca			;4
	nop			;4
	exx			;4__24	ch2/3
	out (c),a		;12
	rlca			;4
	ld sp,buffer+2		;10	reload stack pointer
	dec sp			;6__32	timing
	out (c),a		;12	ch2/4	
	rlca			;4
	ex af,af'		;4
	dec sp			;6	timing
	dec b			;4	decrement timer lo-byte
	jp nz,playRow		;10_40	and loop
				;200/200

;*********************************************************************	
	exx			;4	;decrement timer hi-byte
	dec b			;4
	exx			;4
	
	ld sp,ix		;10
	pop iy			;14
	jp (iy)			;8

tExecNone
	inc ix
	inc ix
tExecStop
	ld sp,buffer		;10
	jp nz,playRow		;10
				;64
	jp rdptn
	
tExecLoop
	pop ix
	ld sp,ix
	pop iy
	jp (iy)
	
tf1
	pop de
	ld (buffer),de
	ld de,4
	add ix,de
	ld sp,buffer
	jp nz,playRow
	jp rdptn

tf1s1
	pop de
	ld (buffer),de
	pop de
	ld d,a
	ld a,e
	ld (buffer+3),a
	ld a,d
	ld de,5
	add ix,de
	ld sp,buffer
	jp nz,playRow
	jp rdptn
	
tf1s1f2
	pop de			;note ch1
	ld (buffer),de
	pop de			;note ch2
	ld (buffer+4),de
	pop de
	ld d,a
	ld a,e
	ld (buffer+3),a
	ld a,d
	ld de,7
	add ix,de
	ld sp,buffer
	jp nz,playRow
	jp rdptn
	
tf1s1s2
	pop de
	ld (buffer),de
	ld b,a
	pop de
	ld a,e
	ld (buffer+3),a
	ld a,d
	ld (buffer+7),a
	ld a,b
	ld de,6
	ld b,d
	add ix,de
	ld sp,buffer
	jp nz,playRow
	jp rdptn

tf1s1f2s2
	pop de
	ld (buffer),de
	pop de
	ld (buffer+4),de
	ld b,a
	pop de
	ld a,e
	ld (buffer+3),a
	ld a,d
	ld (buffer+7),a
	ld a,b
	ld de,8
	ld b,d
	add ix,de
	ld sp,buffer
	jp nz,playRow
	jp rdptn

tf1f2
	pop de
	ld (buffer),de
	pop de
	ld (buffer+4),de
	ld de,6
	add ix,de
	jp nz,playRow
	jp rdptn
	
tf1f2s2
	pop de
	ld (buffer),de
	pop de
	ld (buffer+4),de
	pop de
	ld d,a
	ld a,e
	ld (buffer+7),a
	ld a,d
	ld de,7
	add ix,de
	ld sp,buffer
	jp nz,playRow
	jp rdptn

tf1s2
	pop de
	ld (buffer),de
	pop de
	ld d,a
	ld a,e
	ld (buffer+7),a
	ld a,d
	ld de,5
	add ix,de
	ld sp,buffer
	jp nz,playRow
	jp rdptn

ts1
	pop de
	ld d,a
	ld a,e
	ld (buffer+3),a
	ld a,d
	ld de,3
	add ix,de
	ld sp,buffer
	jp nz,playRow
	jp rdptn
	
ts1f2
	pop de
	ld d,a
	ld a,e
	ld (buffer+3),a
	ld a,d
	pop de
	ld (buffer+4),de
	ld de,5
	add ix,de
	ld sp,buffer
	jp nz,playRow
	jp rdptn
	
ts1f2s2
	pop de
	ld (buffer+4),de
	ld b,a
	pop de
	ld a,e
	ld (buffer+3),a
	ld a,d
	ld (buffer+7),a
	ld a,b
	ld de,6
	ld b,d
	add ix,de
	ld sp,buffer
	jp nz,playRow
	jp rdptn
	
tf2
	pop de
	ld (buffer+4),de
	ld de,4
	add ix,de
	jp nz,playRow
	jp rdptn
	
tf2s2
	pop de
	ld (buffer+4),de
	pop de
	ld d,a
	ld a,e
	ld (buffer+7),a
	ld a,d
	ld de,5
	add ix,de
	ld sp,buffer
	jp nz,playRow
	jp rdptn

ts2
	pop de
	ld d,a
	ld a,e
	ld (buffer+7),a
	ld a,d
	ld de,3
	add ix,de
	ld sp,buffer
	jp nz,playRow
	jp rdptn
	
buffer					;5 words: freq.ch1, smp.ch1, freq.ch2, smp.ch2, fx table
	ds 8
	
samples
	include "samples.asm"
	
musicdata
	include "music.asm"
