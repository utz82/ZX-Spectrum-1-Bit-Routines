;******************************************************************
;Octode 2k15 - 8ch beeper engine
;
;original code: Shiru 02'11
;"XL" version: introspec 10'14-04'15
;"2k15" version: utz 09'15
;******************************************************************

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
	ld iyl,0
	ld (oldSP),sp
	ld hl,musicdata
	ld (seqpntr),hl

;******************************************************************
rdseq
seqpntr equ $+1
	ld sp,0
	xor a
	pop hl			;pattern pointer to HL
	or h
	ld (seqpntr),sp
	jr nz,rdptn0	
	;jp exit		;uncomment to disable looping
	
	ld sp,loop		;get loop point
	jr rdseq+3

;******************************************************************
rdptn0	
	ld sp,hl		;fetch pattern pointer
rdptn
	xor a
	out (#fe),a

	in a,(#1f)		;read joystick
maskKempston equ $+1
	and #1f
	ld c,a
	in a,(#fe)		;read kbd
	cpl
	or c
	and #1f
	jp nz,exit

	pop af
	jr z,rdseq
	
	jp c,drums
drumret	
	ld b,a			;B,B' = timer
	
	pop de			;freq8
	ld (fstack),sp
	
fstack equ $+1
	ld hl,0
	exx
	
	ld bc,#fe
	xor a

;***************************************************frame1
play

cnt1 equ $+1
	ld hl,0		;10
	pop de		;10
	add hl,de	;11
	ld (cnt1),hl	;16
			;-47
	
	rra		;4
	out (c),a	;12
	nop		;4	
	rrca		;4
	out (c),a	;12
			;4
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (#fe),a	;11
	rrca		;4
	out (#fe),a	;11
	rrca		;4
	out (#fe),a	;11
	rrca		;4
	nop
			;184
	
;***************************************************frame2

cnt2 equ $+1
	ld hl,0		;10
	pop de		;10
	add hl,de	;11
	ld (cnt2),hl	;16
			;-47
	
	rra		;4
	out (c),a	;12
	nop	
	rrca		;4
	out (c),a	;12
	
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (#fe),a	;11
	rrca		;4
	out (#fe),a	;11
	rrca		;4
	out (#fe),a	;11
	rrca		;4
	nop
			;184

;***************************************************frame3

cnt3 equ $+1
	ld hl,0		;10
	pop de		;10
	add hl,de	;11
	ld (cnt3),hl	;16
			;-47
	
	rra		;4
	out (c),a	;12
	nop	
	rrca		;4
	out (c),a	;12
	
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (#fe),a	;11
	rrca		;4
	out (#fe),a	;11
	rrca		;4
	out (#fe),a	;11
	rrca		;4
	nop
			;184

;***************************************************frame4

cnt4 equ $+1
	ld hl,0		;10
	pop de		;10
	add hl,de	;11
	ld (cnt4),hl	;16
			;-47
	
	rra		;4
	out (c),a	;12
	nop	
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (#fe),a	;11
	rrca		;4
	out (#fe),a	;11
	rrca		;4
	out (#fe),a	;11
	rrca		;4
	nop
			;184
	
;***************************************************frame5

cnt5 equ $+1
	ld hl,0		;10
	pop de		;10
	add hl,de	;11
	ld (cnt5),hl	;16
			;-47
	
	rra		;4
	out (c),a	;12
	nop	
	rrca		;4
	out (c),a	;12
	
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (#fe),a	;11
	rrca		;4
	out (#fe),a	;11
	rrca		;4
	out (#fe),a	;11
	rrca		;4
	dec b
			;184
	
;***************************************************frame6

cnt6 equ $+1
	ld hl,0		;10
	pop de		;10
	add hl,de	;11
	ld (cnt6),hl	;16
			;-47
	
	rra		;4
	out (c),a	;12
	nop	
	rrca		;4
	out (c),a	;12
	
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (#fe),a	;11
	rrca		;4
	out (#fe),a	;11
	rrca		;4
	out (#fe),a	;11
	rrca		;4
	dec b
			;184
	
;***************************************************frame7

cnt7 equ $+1
	ld hl,0		;10
	pop de		;10
	add hl,de	;11
	ld (cnt7),hl	;16
			;-47
	
	rra		;4
	out (c),a	;12
	nop	
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (#fe),a	;11
	rrca		;4
	out (#fe),a	;11
	rrca		;4
	out (#fe),a	;11
	rrca		;4
	dec b
			;184
	
;***************************************************frame8
	exx		;4
	ld sp,hl	;6
	add ix,de	;15
	nop		;4
	exx		;4
			;33

	rra		;4
	out (c),a	;12
	nop		;4
	rrca		;4
	out (c),a	;12
	nop		;4
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (#fe),a	;11
	rrca		;4
	out (#fe),a	;11
	rrca		;4
	out (#fe),a	;11
	rrca		;4
			;129
			;170
	dec b		;4	
	jp nz,play	;10
			;184
	exx
	dec b
	exx
	jp nz,play

	ld hl,14
	add hl,sp
	ld sp,hl
	jp rdptn
;******************************************************************
exit
oldSP equ $+1
	ld sp,0
	pop hl
	exx
	ei
	ret
;******************************************************************

drums
	jp pe,drum2
	jp m,drum3

drum1					;k(l)ick
	ex af,af'
	xor a		;1
	ld b,a		;1
	ld c,a		;1
	
_druml
	out (#fe),a	;2	
	djnz _druml	;2
	ld b,#60	;2		;b = length, ~ #2-#20 but if bit 4 not set then must use
	xor #10		;1		;xor #10/#18		;2
_xx			
	inc c		;1		;dec c is also possible for different sound
	jr z,dx		;1
	djnz _xx	;2					
	ld b,c		;1
	jr _druml	;2	
	
	
	
drum2					;noise, self-contained, customizable ***
	ld de,#3310	;3		;d = frequency
	ex af,af'
	xor a		;1
	ld bc,#b0	;3		;bc = length
	
_druml
	out (#fe),a	;2	;11
	add hl,de	;1	;11
	jr nc,_yy	;2	;12/7
	xor e		;1	;4
_yy
	rlc h		;2	;8
	cpi		;2	;16
	jp pe,_druml


dx
	ex af,af'
	jp drumret

drum3
	ld de,#5510
	jr drum2+3


musicdata
	include "music.asm"
