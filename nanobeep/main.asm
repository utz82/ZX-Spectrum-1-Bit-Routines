;******************************************************************
;nanobeep
;81 byte beeper engine by utz 09'2015-04'2016
;******************************************************************
;
;ignores kempston
;only reads keys Space,A,Q,1 (can be fixed with 2 additional bytes)
;
;D - add counter ch1
;E - base freq ch1
;B - internal delay counter
;C - add counter ch2
;HL - data pointer
;IY - timer

	org #8000

init
	di
	ld (oldSP),sp
	ld sp,musicdata+2

;******************************************************************
rdseq
	xor a
	pop hl			;pattern pointer to HL
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
	ld a,(hl)		;base freq ch1		
	ld e,a
	inc a			;if A=#ff
	jr z,rdseq
	
	inc a
	jr z,drum

	inc hl			;point to base freq ch2	

	ld iy,(musicdata)	;speed

;******************************************************************
play
	ld a,d
	add a,e
	ld d,a
	
	ld b,48
	
	sbc a,a
	and b
	out (#fe),a

	in a,(#fe)		;read kbd
	rra
	jr nc,exit		;only space,a,q,1 will exit
	;cpl			;comment out the 2 lines above and uncomment this for full keyboard scan
	;and #1f
	;jr z,exit
	
	djnz $

	ld a,c
	add a,(hl)
	ld c,a
	
	ld b,48

	sbc a,a
	and b
	out (#fe),a
	
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
