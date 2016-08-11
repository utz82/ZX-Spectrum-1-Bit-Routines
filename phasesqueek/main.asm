;Phase Squeek aka TOUPEE (Totally Overpowered, Utterly Pointless Extreme Engine)
;version 0.1
;ZX Spectrum beeper engine
;by utz 08'2016 * www.irrlichtproject.de

BORDER equ #ff
noise equ #2175
	include "freqtab.asm"	;note name equates, can be omitted

	org origin

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
	pop bc			;pattern pointer to DE
	or b
	ld (seqpntr),sp
	jr nz,rdptn0
	
	;jp exit		;uncomment to disable looping
	
	ld sp,loop		;get loop point
	jr rdseq+3

;******************************************************************
rdptn0
	ld (ptnpntr),bc
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


ptnpntr equ $+1
	ld sp,0
	
	pop af			;global ctrl (F) and method (A)
	jr z,rdseq
	jr c,_noFxUpdate
	
	pop bc			;fx table pointer
	ld (fxPointer),bc

_noFxUpdate
	jp pe,_ctrl_3		;no updates for this row
	
	ld (globalMethod),a
	
	jp m,_ctrl_2		;no updates for ch1
	
	
	pop af			;ch1 ctrl (F) and method (A)
	ld (method1),a
	
	jr c,_noF1Update
	
	pop hl			;frequency ch1 op1
	ld (freq1A),hl
	pop hl			;frequency ch1 op2
	ld (freq1B),hl

_noF1Update
	jr z,_noDuty1Update
	
	pop de			;duties ch1 op1/2
	
_noDuty1Update
	jp pe,_noSID1Update
	
	pop bc			;SID/ES ch1 op1
	ld (sid1A),bc
	pop bc			;SID/ES ch1 op2
	ld (sid1B),bc
		
_noSID1Update
	jp m,_noPhase1Update	

	pop hl			;phase ch1
	ld ix,0
	
_noPhase1Update
_ctrl_2
	pop af			;ch2 ctrl (F) and method (A)
	
	ld (method2),a
	exx
	jr c,_noF2Update
	
	pop hl			;freq ch2 op1
	ld (freq2A),hl
	pop hl			;freq ch2 op2
	ld (freq2B),hl

_noF2Update
	jr z,_noDuty2Update
	
	pop de			;duties ch2 op1/2
	
_noDuty2Update
	ld a,0
	jp po,_setNoise2
	
	ld a,#cb
	
_setNoise2
	ld (noise2),a		;a=0 - noise disabled, a=#cb - noise enabled
	jp m,_noPhase2Update
	
	pop hl			;phase ch2
	ld iy,0
	
_noPhase2Update
	exx
_ctrl_3
	pop af			;drum ctrl (F) and speed
	
	jp z,drum1
	jp m,drum2
	
	ld c,0			;set speed (length counter) lo-byte
	ex af,af'
	
drumret
	ld (ptnpntr),sp

;*******************************************************************************
playNote
freq1A equ $+1
	ld sp,0			;10
	add hl,sp		;11
	ld a,d			;4
sid1A
shaker1A equ $+1				;add a,n = c6, adc a,n = c6
 	adc a,0			;7
 	ld d,a			;4
	add a,h			;4
	sbc a,a			;4
	ld b,a			;4
	
freq1B equ $+1
	ld sp,0			;10
	add ix,sp		;15
	ld a,e			;4
sid1B
shaker1B equ $+1
 	adc a,0			;7
 	ld e,a			;4
	add a,ixh		;4
	sbc a,a			;4
method1
	xor b			;4		;xor = a8, or = b0, and = a0
	ld b,a			;4		;preserve output state ch1
	
	exx			;4	
	
freq2A equ $+1
	ld sp,0			;10
	add hl,sp		;11
noise2
	rlc h			;8		;rlc h = cb 04 - noise enable
						;nop,inc b = 00 04 - noise disable 
	ld a,d			;4
	add a,h			;4
	sbc a,a			;4
	ld b,a			;4
	
freq2B equ $+1
	ld sp,0			;10
	add iy,sp		;15
	ld a,e			;4
	add a,iyh		;8
	sbc a,a			;4
method2
	xor b			;4
	
	exx			;4

globalMethod
	xor b			;4		;combine with state ch1
	ret c			;5		;timing
	
	out (#fe),a		;11
	
	dec c			;4		;timer
	
	jp nz,playNote		;10
				;232
	
;*******************************************************************************
updateTimer
		
fxPointer equ $+1
	ld sp,0
	
	pop af			;global ctrl (F) and method (A)
	jr z,_stopFx
	jp pe,_noUpdate		;no updates for this row
	jr nc,_noFxPntrReset
	
	exx
	pop bc			;fx table pointer reset
	ld (fxPointer),bc
	exx
	jp updateTimer
	
_noFxPntrReset
	ld (globalMethod),a
	
	jp m,_ctrl_2		;no updates for ch1
	
	
	pop af			;ch1 ctrl (F) and method (A)
	ld (method1),a
	
	jr c,_noF1Update
	
	pop hl			;frequency ch1 op1
	ld (freq1A),hl
	pop hl			;frequency ch1 op2
	ld (freq1B),hl

_noF1Update
	jr z,_noDuty1Update
	
	pop de			;duties ch1 op1/2
	
_noDuty1Update
	jp pe,_noSID1Update
	
	exx
	pop bc			;SID/ES ch1 op1
	ld (sid1A),bc
	pop bc			;SID/ES ch1 op2
	ld (sid1B),bc
	exx
		
_noSID1Update
	jp m,_noPhase1Update	

	pop hl			;phase ch1
	ld ix,0
	
_noPhase1Update
_ctrl_2
	pop af			;ch2 ctrl (F) and method (A)
	
	ld (method2),a
	exx
	jr c,_noF2Update
	
	pop hl			;freq ch2 op1
	ld (freq2A),hl
	pop hl			;freq ch2 op2
	ld (freq2B),hl

_noF2Update
	jr z,_noDuty2Update
	
	pop de			;duties ch2 op1/2
	
_noDuty2Update
	ld a,0
	jp po,_setNoise2
	
	ld a,#cb
	
_setNoise2
	ld (noise2),a		;a=0 - noise disabled, a=#cb - noise enabled
	jp m,_noPhase2Update
	
	pop hl			;phase ch2
	ld iy,0
	
_noPhase2Update
	exx	

_noUpdate
	ld (fxPointer),sp

_stopFx
	ex af,af'
	dec a
	jp z,rdptn
	ex af,af'
	jp playNote

;*******************************************************************************
drum2
	ld (HLrestore),hl
	ex af,af'

	ld hl,hat1
	ld b,hat1end-hat1
	jr drentry
drum1

	ld (HLrestore),hl
	ex af,af'
	
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
	ld c,#19		;7	;correct frame length

HLrestore equ $+1
	ld hl,0
	jp drumret		;10
	
kick1					;27*16*4 + 27*32*4 + 27*64*4 + 27*128*4 + 27*256*4 = 53568, + 20*33 = 53568 -> -231 loops -> C = #19
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
;*******************************************************************************
exit
oldSP equ $+1
	ld sp,0
	pop hl
	exx
	ei
	ret

;*******************************************************************************
musicData
	include "music.asm"
		