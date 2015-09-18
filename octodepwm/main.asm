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
	
	ld ixh,a		;IX = timer
	ld ixl,0
	
	jp c,drums
drumret	
	
	
	ld (fstack),sp
	
	ld c,#fe
	xor a
	ld b,a

;***************************************************frame1
play
	out (#fe),a	;11---ch8 21
	rrca		;4
cnt1 equ $+1
	ld hl,0		;10
	out (#fe),a	;11---ch1 25
	rrca		;4	
	pop de		;10
	out (#fe),a	;11---ch2 25
	rrca		;4	
	add hl,de	;11
	out (c),b	;12---ch3 27
	sbc a,a		;4
	and #80		;7
	xor b		;4
	ld b,a		;4
	rrca		;4
	out (#fe),a	;11---ch4 33
	rrca		;4	
	ld (cnt1),hl	;16
	out (#fe),a	;11---ch5 31
	rrca		;4
	ld c,#fe	;7
	ld hl,0		;10		;ld sp,xxxx
	out (#fe),a	;11---ch6 32
	rrca		;4
	dec ixl		;8
	dec de		;6
	out (#fe),a	;11---ch7 29
	ld hl,0		;10		;jp nz,play
			;224

	
;***************************************************frame2

	out (#fe),a	;11---ch8 21
	rrca		;4
cnt2 equ $+1
	ld hl,0		;10
	out (#fe),a	;11---ch1 25
	rrca		;4	
	pop de		;10
	out (#fe),a	;11---ch2 25
	rrca		;4	
	add hl,de	;11
	out (c),b	;12---ch3 27
	sbc a,a		;4
	and #40		;7
	xor b		;4
	ld b,a		;4
	rrca		;4
	out (#fe),a	;11---ch4 33
	rrca		;4	
	ld (cnt2),hl	;16
	out (#fe),a	;11---ch5 31
	rrca		;4
	ld c,#fe	;7
	ld hl,0		;10		;ld sp,xxxx
	out (#fe),a	;11---ch6 22
	rrca		;4
	dec ixl
	dec de
	out (#fe),a	;11---ch7 23
	ld hl,0		;10		;jp nz,play
			;208

;***************************************************frame3

	out (#fe),a	;11---ch8 21
	rrca		;4
cnt3 equ $+1
	ld hl,0		;10
	out (#fe),a	;11---ch1 25
	rrca		;4	
	pop de		;10
	out (#fe),a	;11---ch2 25
	rrca		;4	
	add hl,de	;11
	out (c),b	;12---ch3 27
	sbc a,a		;4
	and #20		;7
	xor b		;4
	ld b,a		;4
	rrca		;4
	out (#fe),a	;11---ch4 33
	rrca		;4	
	ld (cnt3),hl	;16
	out (#fe),a	;11---ch5 31
	rrca		;4
	ld c,#fe	;7
	ld hl,0		;10		;ld sp,xxxx
	out (#fe),a	;11---ch6 22
	rrca		;4
	dec ixl
	dec de
	out (#fe),a	;11---ch7 23
	ld hl,0		;10		;jp nz,play
			;208

;***************************************************frame4

	out (#fe),a	;11---ch8 21
	rrca		;4
cnt4 equ $+1
	ld hl,0		;10
	out (#fe),a	;11---ch1 25
	rrca		;4	
	pop de		;10
	out (#fe),a	;11---ch2 25
	rrca		;4	
	add hl,de	;11
	out (c),b	;12---ch3 27
	sbc a,a		;4
	and #10		;7
	xor b		;4
	ld b,a		;4
	rrca		;4
	out (#fe),a	;11---ch4 33
	rrca		;4	
	ld (cnt4),hl	;16
	out (#fe),a	;11---ch5 31
	rrca		;4
	ld c,#fe	;7
	ld hl,0		;10		;ld sp,xxxx
	out (#fe),a	;11---ch6 22
	rrca		;4
	nop		;4		;dec ixl
	nop		;4		;
	dec de
	out (#fe),a	;11---ch7 23
	ld hl,0		;10		;jp nz,play
			;208
	
;***************************************************frame5

	out (#fe),a	;11---ch8 21
	rrca		;4
cnt5 equ $+1
	ld hl,0		;10
	out (#fe),a	;11---ch1 25
	rrca		;4	
	pop de		;10
	out (#fe),a	;11---ch2 25
	rrca		;4	
	add hl,de	;11
	out (c),b	;12---ch3 27
	sbc a,a		;4
	and #8		;7
	xor b		;4
	ld b,a		;4
	rrca		;4
	out (#fe),a	;11---ch4 33
	rrca		;4	
	ld (cnt5),hl	;16
	out (#fe),a	;11---ch5 31
	rrca		;4
	ld c,#fe	;7
	ld hl,0		;10		;ld sp,xxxx
	out (#fe),a	;11---ch6 22
	rrca		;4
	nop		;4		;dec ixl
	nop		;4		;
	dec de
	out (#fe),a	;11---ch7 23
	ld hl,0		;10		;jp nz,play
			;208
	
;***************************************************frame6

	out (#fe),a	;11---ch8 21
	rrca		;4
cnt6 equ $+1
	ld hl,0		;10
	out (#fe),a	;11---ch1 25
	rrca		;4	
	pop de		;10
	out (#fe),a	;11---ch2 25
	rrca		;4	
	add hl,de	;11
	out (c),b	;12---ch3 27
	sbc a,a		;4
	and #4		;7
	xor b		;4
	ld b,a		;4
	rrca		;4
	out (#fe),a	;11---ch4 33
	rrca		;4	
	ld (cnt6),hl	;16
	out (#fe),a	;11---ch5 31
	rrca		;4
	ld c,#fe	;7
	ld hl,0		;10		;ld sp,xxxx
	out (#fe),a	;11---ch6 22
	rrca		;4
	nop		;4		;dec ixl
	nop		;4		;
	dec de
	out (#fe),a	;11---ch7 23
	ld hl,0		;10		;jp nz,play
			;208
	
;***************************************************frame7

	out (#fe),a	;11---ch8 21
	rrca		;4
cnt7 equ $+1
	ld hl,0		;10
	out (#fe),a	;11---ch1 25
	rrca		;4	
	pop de		;10
	out (#fe),a	;11---ch2 25
	rrca		;4	
	add hl,de	;11
	out (c),b	;12---ch3 27
	sbc a,a		;4
	and #2		;7
	xor b		;4
	ld b,a		;4
	rrca		;4
	out (#fe),a	;11---ch4 33
	rrca		;4	
	ld (cnt7),hl	;16
	out (#fe),a	;11---ch5 31
	rrca		;4
	ld c,#fe	;7
	ld hl,0		;10		;ld sp,xxxx
	out (#fe),a	;11---ch6 22
	rrca		;4
	nop		;4		;dec ixl
	nop		;4		;
	dec de
	out (#fe),a	;11---ch7 23
	ld hl,0		;10		;jp nz,play
			;208
	
;***************************************************frame8
	out (#fe),a	;11---ch8 21
	rrca		;4
cnt8 equ $+1
	ld hl,0		;10
	out (#fe),a	;11---ch1 25
	rrca		;4	
	pop de		;10
	out (#fe),a	;11---ch2 25
	rrca		;4	
	add hl,de	;11
	out (c),b	;12---ch3 27
	sbc a,a		;4
	and #1		;7
	xor b		;4
	ld b,a		;4
	rrca		;4
	out (#fe),a	;11---ch4 33
	rrca		;4	
	ld (cnt8),hl	;16
	out (#fe),a	;11---ch5 31
	rrca		;4
	ld c,#fe	;7
fstack equ $+1
	ld sp,0		;10
	out (#fe),a	;11---ch6 32
	rrca		;4
	dec de		;6
	dec ixl		;8
	out (#fe),a	;11---ch7 29
	jp nz,play	;10
			;224
	dec ixh
	jp nz,play

	ld hl,16
	add hl,sp
	jp rdptn0
;******************************************************************
exit
	xor a
	out (#fe),a
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
	xor a		;1
	ld b,a		;1
	ld c,a		;1
	
_druml
	out (#fe),a	;2	
	djnz _druml	;2
	ld b,#20	;2		;b = length, ~ #2-#20 but if bit 4 not set then must use
	xor #10		;1		;xor #10/#18		;2
_xx			
	inc c		;1		;dec c is also possible for different sound
	jr z,dx		;1
	djnz _xx	;2					
	ld b,c		;1
	jr _druml	;2	
	
	
	
drum2					;noise, self-contained, customizable ***
	ld de,#3310	;3		;d = frequency
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
	ld ixl,#c0
	jp drumret

drum3
	ld de,#5510
	jr drum2+3


musicdata
	include "music.asm"
