;BetaPhase - ZX Spectrum beeper engine
;experimental pulse-interleaving synthesis without duty threshold comparison
;by utz 10'2016, based on an original concept by Shiru

include "equates.h"


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
	ld (preScale1),a	;preScale1|phase reset enable
	jr nc,_skipPhaseReset
	
	pop de			;pop phase offset
	ld hl,0
	
_skipPhaseReset
	ld bc,#0900		;nop \ add hl,bc
	jr nz,_setDutyMod
	
	ld bc,#4aed		;adc hl,bc
	
_setDutyMod
	ld (dutyMod1),bc
				;duty mod on/off
	pop bc			;mixMethod + postScale1
	ld a,c
	ld (mix1),a
	ld a,b
	ld (postScale1),a
	
	pop bc			;freq divider
	
	ex af,af'

skipUpdate1			;***ch2***
	jp pe,skipUpdate2
	
	ld (_restoreHL),hl
	ex af,af'
	
	pop af			;preScale2|phase reset enable
	ld (preScale2),a	
	jr nc,_skipPhaseReset	;phase reset yes/no
	
	pop iy
	ld ix,0

_skipPhaseReset
	pop hl			;mix method|postScale2
	ld (mix2),hl
				
	pop hl			;freq div
	ld (noteDiv2),hl
	
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

	add hl,bc		;11		;ch1 (duty mod)
	ex de,hl		;4
dutyMod1
	nop			;4
	add hl,bc		;11		;switch add|adc	PROBLEM: adc is 2 bytes, 15t
	
	ld a,d			;4
preScale1
	nop			;4		;switch rrca/rlca/... *2
mix1
	xor h			;4		;switch xor|or|and|nop
	ret c			;5		;timing TODO: careful, this will fail if mix op doesn't reset carry
postScale1
	nop			;4		;also for rlc h... osc 2 off = noise? rlc l & prescale? or move it down 
						
	
	out (#fe),a		;11___80 (ch3)
	
	ex de,hl		;4	
	ld a,0			;7		;timing

	
	add ix,sp		;15		;ch2 (duty mod)
dutyMod2					
	add iy,sp		;15		;switch add|adc
	ld a,ixh		;8

preScale2
	nop			;4
mix2 equ $+1
	xor iyh			;8
postScale2
	nop			;4
	
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
