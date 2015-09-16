;******************************************************************
;xtone - 6ch beeper engine
;by utz 09'2015
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
	ld sp,hl
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

	pop af
	jr z,rdseq
	ld iyh,a		;IY = timer
	
	jp c,drums

drumret
	ld l,#f0
	pop de
	ld a,d
	and l
	ld (duty1),a
	ld a,d
	add a,a
	add a,a
	add a,a
	add a,a
	ld (duty2),a

	ld a,e
	and l
	ld (duty3),a
	ld a,e
	add a,a
	add a,a
	add a,a
	add a,a
	ld (duty4),a
	
	pop de
	ld a,d
	ld (duty5),a
	ld a,e
	ld (duty6),a


	ld (fstack),sp		;pattern data serves as buffer for loading freq. values during play loop

	ld bc,#18fe
	ld d,b
	ld e,b
	ld h,b
	ld l,b
	
	exx
	
	ld bc,#18fe
	
	ld hl,0
	ld (cnt1),hl
	ld (cnt2),hl
	ld (cnt3),hl
	ld (cnt4),hl
	ld (cnt5),hl
	ld (cnt6),hl
	
	jp play

;****************************************frame6end	
	out (c),h		;12
				;-34
	exx			;4
play
;****************************************frame1
cnt1 equ $+1			

	ld hl,0			;10
	pop de			;10	
	out (c),b		;12
				;-32 (+exx -36)
	
	add hl,de		;11
	dec de			;6	;waste some time
	ld a,h			;4
	exx			;4
	out (c),b		;12
				;-37
	
	exx			;4	
	ld (cnt1),hl		;16
	exx			;4
	out (c),d		;12
				;-36
		
	exx			;4
duty1 equ $+1
	cp #80			;7
	sbc a,a			;4
	and #18			;7
	exx			;4
	out (c),e		;12
				;-38
	
	exx			;4
	ld b,a			;4
	exx			;4
	ld a,r			;9
	out (c),l		;12
				;-35
											
	ld a,r			;9	;waste 18t for dec iyl, jp nz, play-3 resp ld sp,xxxx
	ld a,r			;9
	nop			;4
	out (c),h		;12
				;-34

	exx			;4
				;216
				
				
;****************************************frame2
cnt2 equ $+1			

	ld hl,0			;10
	pop de			;10	
	out (c),b		;12
				;-32 (+exx -36)
	
	add hl,de		;11
	dec de
	ld a,h			;4
	exx			;4
	out (c),b		;12
				;-31
	
	exx			;4	
	ld (cnt2),hl		;16
	exx			;4
	out (c),d		;12
				;-36
		
	exx			;4
duty2 equ $+1
	cp #80			;7
	sbc a,a			;4
	and #18			;7
	exx			;4
	out (c),e		;12
				;-38
	
	nop			;4
	nop			;4
	ld b,a			;4
	ld a,r			;9
	out (c),l		;12
				;-33
											
	ld a,r			;9	;waste 18t for dec iyl, jp nz, play-3 resp ld sp,xxxx
	ld a,r			;9
	nop
	out (c),h		;12
				;-34

	exx			;4
	
;****************************************frame3
cnt3 equ $+1			

	ld hl,0			;10
	pop de			;10	
	out (c),b		;12
				;-32 (+exx -36)
	
	add hl,de		;11
	dec de
	ld a,h			;4
	exx			;4
	out (c),b		;12
				;-31
	
	exx			;4	
	ld (cnt3),hl		;16
	exx			;4
	out (c),d		;12
				;-36
		
	exx			;4
duty3 equ $+1
	cp #80			;7
	sbc a,a			;4
	and #18			;7
	exx			;4
	out (c),e		;12
				;-38
	
	nop			;4
	nop			;4
	ld d,a			;4
	ld a,r			;9
	out (c),l		;12
				;-33
											
	ld a,r			;9	;waste 18t for dec iyl, jp nz, play-3 resp ld sp,xxxx
	ld a,r			;9
	nop
	out (c),h		;12
				;-34

	exx			;4
	
;****************************************frame4
cnt4 equ $+1			

	ld hl,0			;10
	pop de			;10	
	out (c),b		;12
				;-32 (+exx -36)
	
	add hl,de		;11
	dec de
	ld a,h			;4
	exx			;4
	out (c),b		;12
				;-31
	
	exx			;4	
	ld (cnt4),hl		;16
	exx			;4
	out (c),d		;12
				;-36
		
	exx			;4
duty4 equ $+1
	cp #80			;7
	sbc a,a			;4
	and #18			;7
	exx			;4
	out (c),e		;12
				;-38
	
	dec iyl			;8
	ld e,a			;4
	ld a,r			;9
	out (c),l		;12
				;-33
											
	ld a,r			;9	;waste 18t for dec iyl, jp nz, play-3 resp ld sp,xxxx
	ld a,r			;9
	nop
	out (c),h		;12
				;-34

	exx			;4
	
;****************************************frame5
cnt5 equ $+1			

	ld hl,0			;10
	pop de			;10	
	out (c),b		;12
				;-32 (+exx -36)
	
	add hl,de		;11
	dec de
	ld a,h			;4
	exx			;4
	out (c),b		;12
				;-31
	
	exx			;4	
	ld (cnt5),hl		;16
	exx			;4
	out (c),d		;12
				;-36
		
	exx			;4
duty5 equ $+1
	cp #80			;7
	sbc a,a			;4
	and #18			;7
	exx			;4
	out (c),e		;12
				;-38
	
	dec iyl			;8
	ld h,a			;4
	ld a,r			;9
	out (c),l		;12
				;-33
											
	ld a,r			;9	;waste 18t for dec iyl, jp nz, play-3 resp ld sp,xxxx
	ld a,r			;9
	nop
	out (c),h		;12
				;-34

	exx			;4


				
;****************************************frame6
cnt6 equ $+1			

	ld hl,0			;10
	pop de			;10	
	out (c),b		;12
				;-32 (+exx -36)
	
	add hl,de		;11
	dec de
	ld a,h			;4
	exx			;4
	out (c),b		;12
				;-31
	
	exx			;4	
	ld (cnt6),hl		;16
	exx			;4
	out (c),d		;12
				;-36
		
	exx			;4
duty6 equ $+1
	cp #80			;7
	sbc a,a			;4
	and #18			;7
	exx			;4
	out (c),e		;12
				;-38
	
	dec iyl			;8
	ld l,a			;4	
fstack equ $+1
	ld sp,0			;10	;reload frequency pointer
	out (#fe),a		;11
				;-35
											
	dec iyl			;8
	nop
	jp nz,play-3		;10
	
	dec iyh
	jp nz,play-3
	
	ld hl,12
	add hl,sp
	;ld sp,hl
	
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
	ld de,#7710	;3		;d = frequency
	xor a		;1
	ld bc,#d0	;3		;bc = length
	
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
	ld ixl,#a0
	jp drumret

drum3
	ld de,#5510
	jr drum2+3



musicdata
	include "music.asm"
	