;wtbeep 0.2
;experimental beeper engine for ZX Spectrum
;by utz 11'2016 * www.irrlichtproject.de
;bugfixes by Shiru 01'2018


	include "equates.h"

	org #8000
	
	di
	exx
	ld c,0			;timer lo
	push hl			;preserve HL' for return to BASIC
	ld (oldSP),sp
	ld hl,musicData
	ld (seqpntr),hl
	ld ix,0
	ld iy,0

;*******************************************************************************
rdseq
seqpntr equ $+1
	ld sp,0
	xor a
	pop de			;pattern pointer to DE
	or d
	ld (seqpntr),sp
	jr nz,rdptn0
	
	ld sp,mLoop		;get loop point		;comment out to disable looping
	jr rdseq+3					;comment out to disable looping

;*******************************************************************************
exit
oldSP equ $+1
	ld sp,0
	pop hl
	exx
	ei
	ret

;*******************************************************************************
rdptn0
	ld (ptnpntr),de

readPtn
	in a,(#fe)		;read kbd
	cpl
	and #1f
	jr nz,exit


ptnpntr equ $+1
	ld sp,0	
	
	pop af			;timer + ctrl
	jr z,rdseq
	
	ld b,a			;timer (# ticks)
	
	jr c,_noUpd1
	
	ex af,af'
	
	ld h,HIGH(mixAlgo)
	pop de
	ld a,d
	
	and #f8
	ld l,a
	
	ld a,(hl)
	ld (algo1),a
	inc l
	ld a,(hl)
	ld (algo1+1),a
	inc l
	ld a,(hl)
	ld (algo1+2),a
	inc l
	ld a,(hl)
	ld (algo1+3),a
	inc l
	ld a,(hl)
	ld (algo1+4),a
	
	ld hl,0
	
	ld a,d
	and #7
	ld d,a
	
	ex af,af'
	
_noUpd1
	jp pe,_noUpd2
	
	exx
	ex af,af'
	
	ld h,HIGH(mixAlgo)
	pop bc
	ld a,b
	
	and #f8
	ld l,a
	
	ld a,(hl)
	ld (algo2),a
	inc l
	ld a,(hl)
	ld (algo2+1),a
	inc l
	ld a,(hl)
	ld (algo2+2),a
	inc l
	ld a,(hl)
	ld (algo2+3),a
	inc l
	ld a,(hl)
	ld (algo2+4),a
	
	ld hl,0
	
	ld a,b
	and #7
	ld b,a	
	
	ex af,af'
	exx
	
_noUpd2
	jp m,_noUpd3
	
	exx
	
	pop de
	ld a,d
	ex af,af'
	ld a,d
	and #7
	ld d,a
	ld (fdiv3),de
	
	ex af,af'
	and #f8
	ld e,a
	ld d,HIGH(mixAlgo)
	
	ld a,(de)
	ld (algo3),a
	inc e
	ld a,(de)
	ld (algo3+1),a
	inc e
	ld a,(de)
	ld (algo3+2),a
	inc e
	ld a,(de)
	ld (algo3+3),a
	inc e
	ld a,(de)
	ld (algo3+4),a
	
	ld de,0
	exx

_noUpd3
	pop af
	jp po,_noSweepReset
	
	ld iy,0					;reset sweep registers
	ld ixh,0
_noSweepReset
	jr c,drum1
	jr z,drum2
	dec sp
drumRet	
	
	ld (ptnpntr),sp
	
fdiv3 equ $+1
	ld sp,0

;*******************************************************************************
playNote
	add hl,de	;11	
	ld a,h		;4

algo1	
	ds 5		;20

	out (#fe),a	;11___64
	
	exx		;4
	
	add hl,bc	;11
	ld a,h		;4

algo2	
	ds 5		;20
	
	inc bc		;6		;timing
	out (#fe),a	;11___56
	
	ex de,hl	;4
	
	add hl,sp	;11
	ld a,h		;4

algo3	
	ds 5		;20
	
	dec bc		;6		;timing
	nop		;4
	
	ex de,hl	;4
	
	out (#fe),a	;11___64
	
	
	exx		;4
	
	dec c		;4
	jp nz,playNote	;10
			;184
	
	inc iyl				;update sweep counters
	ld a,iyl
	rrca
	rrca
	ld iyh,a
	rrca
	ld ixh,a
	
	dec b
	jp nz,playNote

	jp readPtn
	
;*******************************************************************************
drum2						;noise
	ld (hlRest),hl
	ld (bcRest),bc
	
	ld b,a
	ex af,af'
	
	ld a,b
	ld hl,1					;#1 (snare) <- 1011 -> #1237 (hat)
	rrca
	jr c,setVol
	ld hl,#1237

setVol	
	and #7f
	ld (dvol),a	
				
	ld bc,#a803				;length
sloop
	add hl,hl		;11
	sbc a,a			;4
	xor l			;4
	ld l,a			;4

dvol equ $+1	
	cp #80			;7		;volume
	sbc a,a			;4
				
	or #7			;7		;border
	out (#fe),a		;11
	djnz sloop		;13/8

	dec c			;4
	jr nz,sloop		;12

	jr drumEnd
	
drum1						;kick
	ld (deRest),de
	ld (bcRest),bc
	ld (hlRest),hl

	ld d,a					;A = start_pitch<<1
	ld e,0					;B = 0
	ld h,e
	ld l,e
	
	ex af,af'
	
	srl d					;set start pitch
	rl e
	
	ld c,#3					;length
	
xlllp
	add hl,de
	jr c,_noUpd
	ld a,e
_slideSpeed equ $+1
	sub #10					;speed
	ld e,a
	sbc a,a
	add a,d
	ld d,a
_noUpd
	ld a,h					
	or #7					;border
	out (#fe),a
	djnz xlllp
	dec c
	jr nz,xlllp

						;45680 (/224 = 248.3)
deRest equ $+1
	ld de,0


drumEnd
hlRest equ $+1
	ld hl,0
bcRest equ $+1
	ld bc,0
	
	ld c,6					;adjust timer
	jp drumRet

;*******************************************************************************
IF (LOW($))!=0
	org 256*(1+(HIGH($)))
ENDIF

mixAlgo

	ds 8			;00	50% square
	
	daa			;02	32% square
	and h
	ds 6
	
	rlca			;01	25% square
	and h
	ds 6
	
	daa			;03	19% square
	cpl
	and h
	ds 5
	
	inc a			;04	12.5% square
	inc a
	xor h
	rrca
	ds 4
	
	inc a			;05	6.25% square
	xor h
	rrca
	ds 5

	add a,iyl		;06	duty sweep (fast) (cpl, dec a is not needed, but makes for a nicer attack env)
	cpl
	dec a
	or h
	ds 3
	
	add a,iyh		;07	duty sweep (slow)
	cpl
	dec a
	or h
	ds 3
	
	add a,ixh		;08	duty sweep (very slow, start lo)
	cpl
	dec a
	and h
	ds 3

	add a,ixh		;09	duty sweep (very slow, start hi)
	and h
	ds 5
	

	add a,iyh		;0a	duty sweep (slow) + oct
	rlca
	xor h
	ds 4

	add a,iyh		;0b	duty sweep (slow) - oct
	rrca
	xor h
	ds 4
	
	add a,iyl		;0c	duty sweep (fast) - oct
	rrca
	xor h
	ds 4

	daa			;0d	vowel 1
	rlca
	cpl
	xor h
	ds 4
	
	daa			;0e	vowel 2
	rlca
	rlca
	cpl
	xor h
	ds 3
	
	daa			;0f	vowel 3
	cpl
	xor h
	ds 5

	rrca			;10	vowel 4
	rrca
	sbc a,a
	and h
	rlca
	ds 3
	
	rlca			;11	vowel 5
	rlca
	xor h
	rlca
	ds 4
	
	rrca			;12	vowel 6
	sbc a,a
	and h
	rlca
	ds 4
	
	cpl			;13	rasp 1
	daa
	sbc a,a
	rlca
	and h
	ds 3
	
	rlca			;14	rasp 2
	rlca
	sbc a,a
	and h
	ds 4

	daa			;15	phat rasp
	rrca
	rrca
	cpl
	or h
	ds 3

	daa			;16	phat 2
	rrca
	rrca
	cpl
	and h
	ds 3
	
	daa			;17	phat 3
	rlca
	rlca
	cpl
	and h
	ds 3

	daa			;18	phat 4
	rlca
	cpl
	and h
	ds 4
	
	daa			;19	phat 5
	rrca
	rrca
	cpl
	xor h
	ds 3
	
	cpl			;1a	phat 6
	daa
	sbc a,a
	rlca
	xor h
	ds 3
	
	rlca			;1b	phat 7
	rlca
	sbc a,a
	and h
	rlca
	ds 3
	
	rlc h			;1c	noise 1
	and h
	ds 5
	
	rlc h			;1e	noise 2
	sbc a,a
	or h
	ds 4
	
	rlc h			;1d	noise 3
	ds 6
	
	rlc h			;1f	noise 4
	or h
	xor l
	ds 5

;*******************************************************************************
musicData
	include "music.asm"
