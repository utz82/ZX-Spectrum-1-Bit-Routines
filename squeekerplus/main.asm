;Squeeker Plus
;ZX Spectrum beeper engine by utz
;based on Squeeker by zilogat0r

BORDER equ #ff

	org origin
	

;HL = add counter ch1
;DE = add counter ch2
;IX = add counter ch3
;IY = add counter ch4
;BC = basefreq ch1-4
;SP = buffer pointer

	org #8000
	
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
	ld hl,musicData
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

;******************************************************************
rdptn0
	;ld (ptnpntr),de
	ex de,hl
	ld sp,hl
	ld iy,0
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


;ptnpntr equ $+1
;	ld sp,0	
	
	pop af
	jr z,rdseq
	
	ld i,a
	
	exx
	
	pop hl
	ld a,h
	ld (noise1),a
	ld a,l
	ld (noise2),a
	
	jr c,ld2
	pop hl
	ld (fch1),hl
	pop hl
	ld (envset1),hl
	ld a,(hl)
	ld (duty1),a
	exx
	ld hl,0
	exx
ld2	
	jp pe,ld3
	pop hl
	ld (fch2),hl
	pop hl
	ld (envset2),hl
	ld a,(hl)
	ld (duty2),a
	exx
	ld de,0
	exx
ld3
	jp m,ld4	
	pop hl
	ld (fch3),hl
	pop hl
	ld (envset3),hl
	ld a,(hl)
	ld (duty3),a
	ld ix,0
ld4	
	pop af
	jr z,ldx
	pop hl
	ld (fch4),hl		;freq 4
	ld de,0
	jr nc,nokick
	ex de,hl
nokick
	pop hl
	ld (envset4),hl
	ld a,(hl)
	ld (duty4),a

ldx	
	jp pe,drum1
	jp m,drum2
	xor a
	ld c,a
drumret
	ex af,af'	
	

		
	;ld (ptnpntr),sp
	ld b,#80
	
	exx
	
;******************************************************************
playNote

fch1 equ $+1
	ld bc,0			;10
	add hl,bc		;11
noise1
	db #00,#04		;8	;replaced with cb 04 (rlc h) for noise
					; - 04 is inc b, which has no effect
duty1 equ $+1
	ld a,0			;7
	add a,h			;4
	exx			;4
	rl c			;8
	exx			;4
	
	ex de,hl		;4
fch2 equ $+1
	ld bc,0			;10
	add hl,bc		;11
noise2
	db #00,#04		;8
duty2 equ $+1
	ld a,0			;7
	add a,h			;4
	ex de,hl		;4
	exx			;4
	rl c			;8
	exx			;4

fch3 equ $+1
	ld bc,0			;10
	add ix,bc		;15
	
duty3 equ $+1
	ld a,0			;7
	add a,ixh		;8
	exx			;4
	rl c			;8
	exx			;4
				;176

fch4 equ $+1
	ld bc,0			;10
	add iy,bc		;15
duty4 equ $+1
	ld a,0			;7
	add a,iyh		;8
	
	exx			;4
	ld a,#f			;7
	adc a,c			;4
	ld c,0			;7
	exx			;4
	
	and BORDER		;7
	out (#fe),a		;11
	
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	
	ex (sp),hl		;19
	ex (sp),hl		;19
	ex (sp),hl		;19
	ex (sp),hl		;19
	
	jp playNote		;10
				;368

;******************************************************************
updateTimer
	ex af,af'
	
	exx
	
envset1 equ $+1			;update duty envelope pointers
	ld hl,0
	inc hl
	ld a,(hl)
	cp b			;check for envelope end (b = #80)
	jr z,e2
	ld (duty1),a
	ld (envset1),hl
e2	
envset2 equ $+1
	ld hl,0
	inc hl
	ld a,(hl)
	cp b
	jr z,e3
	ld (duty2),a
	ld (envset2),hl
e3
envset3 equ $+1
	ld hl,0
	inc hl
	ld a,(hl)
	cp b
	jr z,e4
	ld (duty3),a
	ld (envset3),hl
e4	
envset4 equ $+1
	ld hl,0
	inc hl
	ld a,(hl)
	cp b
	jr z,eex
	ld (duty4),a
	ld (envset4),hl

eex
	ld hl,(fch4)		;update ch4 pitch
	srl d			;if pitch slide is enabled, de = freq.ch4
	rr e			;else, de = 0
	
	ld a,d			;TEMP FIX added 16/08/24 to solve "low note on ch4" bug
	or e			;
	jr nz,_skip		;
	
	sbc hl,de		;thus, freq.ch4 = freq.ch4 - int(freq.ch4/2)
	ld (fch4),hl		;if pitch slide is enabled, else no change
 	
	ld iy,0			;reset add counter ch4 so it isn't accidentally
_skip				;left in a "high" state
	
	exx
	
	ld a,i
	dec a
	jp z,rdptn
	ld i,a
	jp playNote

;******************************************************************
exit
oldSP equ $+1
	ld sp,0
	pop hl
	exx
	ei
	ret
;******************************************************************
drum2
	ld hl,hat1
	ld b,hat1end-hat1
	jr drentry
drum1
	ld hl,kick1		;10
	ld b,kick1end-kick1	;7
drentry
	xor a			;4
_s2	
	xor BORDER		;7
	ld c,(hl)		;7
	inc hl			;6
_s1	
	out (#fe),a		;11
	dec c			;4
	jr nz,_s1		;12/7    
	
	djnz _s2		;13/8
	ld a,#6d		;7	;correct tempo
	jp drumret		;10
	
kick1					;27*16*4 + 27*32*4 + 27*64*4 + 27*128*4 + 27*256*4 = 53568, + 20*33 = 53568 -> -147,4 loops -> AF' = #6D
	ds 4,#10
	ds 4,#20
	ds 4,#40
	ds 4,#80
	ds 4,0
kick1end

hat1
	db 16,3,12,6,9,20,4,8,2,14,9,17,5,8,12,4,7,16,13,22,5,3,16,3,12,6,9,20,4,8,2,14,9,17,5,8,12,4,7,16,13,22,5,3
	db 12,8,1,24,6,7,4,9,18,12,8,3,11,7,5,8,3,17,9,15,22,6,5,8,11,13,4,8,12,9,2,4,7,8,12,6,7,4,19,22,1,9,6,27,4,3,11
	db 5,8,14,2,11,13,5,9,2,17,10,3,7,19,4,3,8,2,9,11,4,17,6,4,9,14,2,22,8,4,19,2,3,5,11,1,16,20,4,7
	db 8,9,4,12,2,8,14,3,7,7,13,9,15,1,8,4,17,3,22,4,8,11,4,21,9,6,12,4,3,8,7,17,5,9,2,11,17,4,9,3,2
	db 22,4,7,3,8,9,4,11,8,5,9,2,6,2,8,8,3,11,5,3,9,6,7,4,8
hat1end

env0
	db 0,#80
	
musicData
	include "music.asm"