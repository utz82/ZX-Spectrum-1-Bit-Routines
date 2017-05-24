;BetaPhase - ZX Spectrum beeper engine - r0.4
;experimental pulse-interleaving synthesis without duty threshold comparison
;by utz 2016-2017, based on an original concept by Shiru

	org #8000

	di	
	exx
	push hl			;preserve HL' for return to BASIC
	push ix
	push iy
	ld (oldSP),sp
	ld hl,musicData
	ld (seqpntr),hl

;*******************************************************************************
rdseq
	exx
seqpntr equ $+1
	ld sp,0
	xor a
	pop de			;pattern pointer to DE
	or d
	ld (seqpntr),sp
	jr nz,rdptn0
	
	;jp exit		;uncomment to disable looping
	ld sp,mloop		;get loop point
	jr rdseq+3

;*******************************************************************************
rdptn0
	ld (ptnpntr),de
	ld e,0			;reset timer lo-byte
	
rdptn
	exx
	in a,(#fe)		;read kbd
	cpl
	and #1f
	jp nz,exit


ptnpntr equ $+1
	ld sp,0
	
	pop af			;
	jr z,rdseq
	
	jr c,skipUpdate1	;***ch1***
	ex af,af'

	pop af
	ld (preScale1A),a	;preScale1A|phase reset enable
	jr nc,_skipPhaseReset
	
	pop de			;pop phase offset
	ld hl,0
	
_skipPhaseReset
	ld a,#7a		;ld a,d
	jr nz,_setDutyMod
	
	ld a,#82		;add a,d
_setDutyMod
	ld (dutyMod),a
	

	pop bc			;mixMethod + preScale1B
	ld (preScale1B),bc
	
	pop bc			;freq divider
	
	ld a,b			;disable output on rests
	or c
 	jr nz,_skipPhaseReset2

	ld a,#af		;#af = xor a
	ld (mix1),a

_skipPhaseReset2
	
	ex af,af'

skipUpdate1			;***ch2***
	jp pe,skipUpdate2
	
	ld (_restoreHL),hl
	ex af,af'
	
	pop af			;mix2|phase reset enable
	ld (mix2),a	
	jr nc,_skipPhaseReset	;phase reset yes/no
	
	pop iy
	ld ix,0

_skipPhaseReset
	jr nz,_noDutyMod2
	
	pop af
	ld (dutyMod2),a
_noDutyMod2

	pop hl			;preScale2A/B
	ld (preScale2A),hl
				
	pop hl			;freq div
	ld (noteDiv2),hl
	
	ld a,h
	or l
	jr nz,_skipPhaseReset2	;disable output on rests
	
	ld a,#af		;#af = xor a
	ld (mix2),a
_skipPhaseReset2
	
	ex af,af'
_restoreHL equ $+1
	ld hl,0	

skipUpdate2			;***ch3***
	exx
	jp m,skipUpdate3
	ex af,af'
	
	pop hl			;postscale + slide amount
	ld a,h
	ld (postScale3),a
	ld a,l
	ld (slideAmount),a
	
	pop bc			;freq divider ch3 + slide dir
	
	ld hl,#809f		;sbc a,a \ add a,b
	ld a,#d6		;sub n
	sla b			;bit 7 set = slide up
	jr nc,_slideDown
	
	ld hl,#9188		;adc a,b \ sub c
	ld a,#ce		;add a,n

_slideDown
	ld (slideDirectionA),a
	ld (slideDirectionB),hl
	sra b			;restore freqdiv hi-byte
	
	ld hl,0			;phase reset
	ex af,af'
	
skipUpdate3
	ld d,a			;timer
	ld (ptnpntr),sp

noteDiv2 equ $+1
	ld sp,0	
	
;*******************************************************************************	
playNote
	exx			;4

	add hl,bc		;11		;ch1 (phaser/sid/noise)
	ex de,hl		;4
	add hl,bc		;11

	sbc a,a			;4		;sync for duty modulation
dutyMod	
	ld a,d			;4		;ld a,d = #7a (disable), add a,d = #82 (enable)
preScale1A
	nop			;4		;switch rrca/rlca/... *2 | ld d,a = #57 (enable sweep) | rlc d = #cb(02) for noise
preScale1B
	nop			;4		;also for rlc h... osc 2 off = noise? rlc l & prescale? or move it down | #(cb)02 for noise
mix1
	xor h			;4		;switch xor|or|and|or a|xor a (disable output)
	ret c			;5		;timing TODO: careful, this will fail if mix op doesn't reset carry

	out (#fe),a		;11___80 (ch3)
	
	ex de,hl		;4	
	ld a,0			;7		;timing

	
	add ix,sp		;15		;ch2 (phaser/noise)					
	add iy,sp		;15
	ld a,ixh		;8

preScale2A
	nop			;4
preScale2B
	nop			;4
mix2 equ $+1
	xor iyh			;8

	exx			;4
	out (#fe),a		;11___80 (ch1)	

	
	add hl,bc		;11		;ch3 (slide)
	jr nc,noSlideUpdate	;7/12
	
	ld a,c			;4
slideDirectionA
slideAmount equ $+1
	add a,0			;7		;add a,n = #ce, sub n = #d6
	ld c,a			;4
	
slideDirectionB
	adc a,b			;4		;sbc a,a	;adc a,b; sub c = #9188 | sbc a,a; add a,b = #809f
	sub c			;4		;add a,d
	ld b,a			;4
		
slideReturn
	ld a,h			;4
postScale3
	nop			;4		;switch
	out (#fe),a		;11___64 (ch2)
	
	dec e			;4
	jp nz,playNote		;10
				;224

	ld a,ixl				;duty modulator ch2
dutyMod2 equ $+1
	add a,0
	ld ixl,a
	
	ld a,ixh
	adc a,0
	ld ixh,a
			
	dec d
	jp nz,playNote
	
	ld (noteDiv2),sp
	jp rdptn

;*******************************************************************************	
noSlideUpdate
	jr _aa			;12
_aa	jp slideReturn		;10+12+12=34

;*******************************************************************************
exit
oldSP equ $+1
	ld sp,0
	pop iy
	pop ix
	pop hl
	exx
	ei
	ret
;*******************************************************************************
musicData
	include "music.asm"
