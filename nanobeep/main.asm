;******************************************************************
;nanobeep
;86 byte beeper engine by utz 09'2015
;******************************************************************
;
;ignores kempston
;only reads keys Space,A,Q,1 (can be fixed with 2 additional bytes)
;
;D - add counter ch1
;IXH - base freq ch1
;C - add counter ch2
;E - base freq ch2
;L - timer

	org #8000

init
	di
	ld (oldSP),sp
	ld sp,musicdata+2

;******************************************************************
rdseq
	xor a
	pop hl			;pattern pointer to DE
	or h
	jr nz,rdptn
	;jr exit		;uncomment to disable looping
	
	ld sp,loop
	jr rdseq

drum
	ex de,hl
	ld h,a
	ld l,#fe
	ld c,l
	ld b,h
	otir
	ex de,hl

;******************************************************************	
rdptn
	inc hl	
	ld a,(hl)
	ld ixh,a		;base freq ch1
	inc a			;if A=#ff
	jr z,rdseq
	
	inc a
	jr z,drum

	inc hl		
	ld e,(hl)		;base freq ch2

	ld iy,(musicdata)	;speed

;******************************************************************
play
	ld a,d
	add a,ixh
	ld d,a
	
	sbc a,a
	and #10
	out (#fe),a

	in a,(#fe)		;read kbd
	rra
	jr nc,exit		;only space,a,q,1 will exit
	;cpl			;comment out the 2 lines above and uncomment this for full keyboard scan
	;and #1f
	;jr z,exit

	ld b,49
	djnz $

	ld a,c
	add a,e
	ld c,a

	sbc a,a
	and #10
	out (#fe),a

	ld b,49
	djnz $

	dec iy
	ld a,iyh
	or b
	jr nz,play
	
	jr rdptn
	
;******************************************************************			
exit
oldSP equ $+1
	ld sp,0
	ei
	ret
;******************************************************************

musicdata
	include "music.asm"