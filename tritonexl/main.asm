;******************************************************************
;Tritone FX
;3ch beeper engine by utz 09'2015
;original Tritone code by Shiru 03'2011
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
	jr nz,exit


patpntr equ $+1			;fetch pointer to pattern data
	ld sp,0

	pop hl			;speed+noise+duty1
	or l			;A is already 0 from before	
	jp z,rdseq
	
	xor a
	bit 7,h
	jr z,noNoise
	ld a,7			;rlca
noNoise
	ld (noise),a
	
	ld a,h
	and #7f
	ld c,a			;timer			
	ld b,0
	
	ld a,l
	ld (duty1),a
	
	pop hl			;duties
	ld a,h
	ld (duty2),a
	ld a,l
	ld (duty3),a
	
	pop de			;freq3
	
	exx 
	
	pop bc			;freq2	
	pop de			;freq1
	pop hl			;fx table pointer

	ld (patpntr),sp		;preserve data pointer
	
	ld sp,hl		;fx table pointer to sp
	ld hl,0			;reset add counters
	ld ix,0
	ld iy,0
	
	exx
	
	ld a,#10

	;HL - add counter ch1
	;DE - base val ch1
	;IX - add counter ch2
	;BC - base val ch2
	;IY - add counter ch2
	;DE' - base val ch2
	;CB' - timer
	;HL' - method jump pointer
	;SP - method table pointer

;******************************************************************
play
	exx		;4
	nop		;4
	out (#fe),a	;11---ch2: 73t

	ld a,0		;7	;waste time	

	add hl,de	;11	;update counter ch1
	ld a,h		;4
noise
	nop		;4	;rlca = #07
	ld h,a		;4
	
duty1 equ $+1
	cp #80		;7
	sbc a,a		;4
	and #10		;7
	out (#fe),a	;11---ch3: 59t
	
	add ix,bc	;15	;update counter ch2
	ld a,ixh	;8
duty2 equ $+1
	cp #80		;7
	sbc a,a		;4
	and #10		;7
	out (#fe),a	;11---ch1: 52t
	
	exx		;4
	
	add iy,de	;11	;update counter ch3
	ld a,iyh	;8
duty3 equ $+1
	cp #80		;7
	sbc a,a		;4
	and #10		;7
	
	djnz play	;13
			;184
;******************************************************************
	pop hl			;get fx jump pointer
	jp (hl)

fxNone				;no effect
	dec sp			;waste some time to prevent slowdowns when actual fx are triggered
	inc sp
	dec c
	jp nz,play
	
	jp rdptn	


fxStop				;stop fx table execution
	dec sp
	dec sp		
	dec c
	jp nz,play
	jp rdptn

fxJump				;jump to another fx table position (e.g. loop or jump to another fx table)
	pop hl
	ld sp,hl
	dec c
	jp nz,play
	jp rdptn
	
fxSetFCh1
	dec c
	exx
	pop de
	jp nz,play+1
	jp rdptn
	
fxSetFCh1Cont
	exx
	pop de
	exx
	pop hl
	jp (hl)

fxSetFCh2
	dec c
	exx
	pop bc
	jp nz,play+1
	jp rdptn
	
fxSetFCh2Cont
	exx
	pop bc
	exx
	pop hl
	jp (hl)

fxSetFCh3
	pop de
	dec c
	jp nz,play
	jp rdptn
	
fxSetFCh3Cont
	pop de
	pop hl
	jp (hl)

fxSetFCh12
	dec c
	exx
	pop de
	pop bc
	jp nz,play+1
	jp rdptn
	
fxSetFCh12Cont
	exx
	pop de
	pop bc
	exx
	pop hl
	jp (hl)

fxSetFCh13
	exx
	pop de
	exx
	pop de
	dec c
	jp nz,play
	jp rdptn
	
fxSetFCh13Cont
	exx
	pop de
	exx
	pop de
	pop hl
	jp (hl)

fxSetFCh123
	exx
	pop de
	pop bc
	exx
	pop de
	dec c
	jp nz,play
	jp rdptn
	
fxSetFCh123Cont
	exx
	pop de
	pop bc
	exx
	pop de
	pop hl
	jp (hl)

fxSetFCh23
	exx
	pop bc
	exx
	pop de
	dec c
	jp nz,play
	jp rdptn
	
fxSetFCh23Cont
	exx
	pop bc
	exx
	pop de
	pop hl
	jp (hl)

fxSetDCh1
	ex af,af'
	pop af
	ld (duty1),a
	ex af,af'
	dec c
	jp nz,play
	jp rdptn

fxSetDCh2
	ex af,af'
	pop af
	ld (duty2),a
	ex af,af'
	dec c
	jp nz,play
	jp rdptn

fxSetDCh3
	ex af,af'
	pop af
	ld (duty3),a
	ex af,af'
	dec c
	jp nz,play
	jp rdptn

fxSetDCh12
	ex af,af'
	pop hl
	ld a,h
	ld (duty1),a
	ld a,l
	ld (duty2),a
	ex af,af'
	dec c
	jp nz,play
	jp rdptn

fxSetDCh13
	ex af,af'
	pop hl
	ld a,h
	ld (duty1),a
	ld a,l
	ld (duty3),a
	ex af,af'
	dec c
	jp nz,play
	jp rdptn

fxSetDCh123
	ex af,af'
	pop hl
	ld a,h
	ld (duty1),a
	ld a,l
	ld (duty2),a
	pop af
	ld (duty3),a
	ex af,af'
	dec c
	jp nz,play
	jp rdptn

fxSetDCh23
	ex af,af'
	pop hl
	ld a,h
	ld (duty2),a
	ld a,l
	ld (duty3),a
	ex af,af'
	dec c
	jp nz,play
	jp rdptn
	
fxStopNoise
	dec c
	ex af,af'
	xor a
	ld (noise),a
	exx
	ld d,a
	ld e,a
	ld h,a
	ld l,a
	ex af,af'
	jp nz,play+1
	jp rdptn

fxStopNoiseSetFCh1
	ex af,af'
	xor a
	ld (noise),a
	ex af,af'
	dec c
	exx
	pop de
	jp nz,play+1
	jp rdptn

fxStartNoiseSetFCh1
	ex af,af'
	ld a,7
	ld (noise),a
	ex af,af'
	dec c
	exx
	pop de
	jp nz,play+1
	jp rdptn
	
fxStopNoiseCont
	ex af,af'
	xor a
	ld (noise),a
	ex af,af'
	exx
	ld d,a
	ld e,a
	ld h,a
	ld l,a
	exx
	pop hl
	jp (hl)
	
fxStartNoiseSetFCh1Cont
	ex af,af'
	ld a,7
	ld (noise),a
	ex af,af'
	exx
	pop de
	exx
	pop hl
	jp (hl)
	

fxStartNoiseCont

fxCutCh1
	dec c
	exx
	ld de,0
	ld h,d
	ld l,d
	jp nz,play+1
	jp rdptn

fxCutCh2
	dec c
	exx
	ld bc,0
	ld ix,0
	jp nz,play+1
	jp rdptn

fxCutCh3
	dec c
	ld de,0
	ld iy,0
	jp nz,play
	jp rdptn


musicdata
	include "music.asm"
