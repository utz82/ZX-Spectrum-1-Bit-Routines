;povver
;experimental beeper engine with phase offset volume control
;by utz 11'2016

	include "equates.h"	;optional

	org #8000
	
	di
	exx
	ld b,0			;timer lo
	push hl			;preserve HL' for return to BASIC
	ld (oldSP),sp
	ld hl,musicData
	ld (seqpntr),hl

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
	
	pop af			;speed + ctrl
	jr z,rdseq
	
	ld c,a			;speed
	
	jr c,noUpd1
	
	ex af,af'
	
	ld hl,0			;reset counter
	
	pop de			;freq+offset ch1+env toggle
	ld a,d
	rlca	
	jr nc,_noEnv		;if bit 15 is set
	
	ld h,#24		;enable envelope
_noEnv
	rlca			;bit 14-11 is phase offset
	rlca
	rlca
	rlca
	and #f
	jr z,_skip		;if phase offset != 0
	
	inc a			;inc phase offset by 1 (so $f -> $10 = full phase inversion)
_skip
	ld iyh,a		;set phase offset
	
	ld a,d			;mask phase offset from frequency divider
	and #7
	ld d,a
	
	ld a,h			;set envelope
	ld (env1),a
	ld h,0
	
	ex af,af'
	
noUpd1
	jp pe,noUpd2
	
	ex af,af'
	exx
	
	ld hl,0
	
	pop bc
	ld a,b
	rlca
	jr nc,_noEnv
	
	ld h,#24
_noEnv
	rlca
	rlca
	rlca
	rlca
	and #f
	jr z,_skip
	
	inc a
_skip
	ld ixh,a
	
	ld a,b
	and #7
	ld b,a
	
	ld a,h
	ld (env2),a
	ld h,0
	
	exx
	ex af,af'
	
	
noUpd2
	jp m,noUpd3
	
	exx
	ld iyl,0
	pop de
	ld a,d
	rlca
	jr nc,_noEnv
	ld iyl,#2c
_noEnv
	rlca
	rlca
	rlca
	rlca
	and #f
	jr z,_skip
	
	inc a
_skip
	ld ixl,a
	
	ld a,d
	and #7
	ld d,a
	ld (div3),de
	
	ld a,iyl
	ld (env3),a
	
	ld de,0
	
	exx
noUpd3
	pop af
	jp c,drum1
	jp pe,drum2
	
drumRet
	jr z,enableNoise
	xor a
	ld (pNoise),a
	ld (pNoise+1),a
	jp nDone
	
enableNoise
	ld a,#cb
	ld (pNoise),a
	ld a,4
	ld (pNoise+1),a

nDone
	ld (ptnpntr),sp
div3 equ $+1
	ld sp,0
	
;*******************************************************************************
playNote
	add hl,de		;11		;ch1
	ld a,h			;4
	out (#fe),a		;11__40 (ch3b)

pNoise
	ds 2			;8		;noise switch, cb 04 = rlc h

	add a,iyh		;8		;iyh = phase offset
	
	exx			;4
	
	or a			;4		;timing
	ret c			;5		;timing
	
	out (#fe),a		;11__40 (ch1a)

	
	add hl,bc		;11		;ch2
	ld a,h			;4
	
	ds 2			;8		;timing
	inc bc			;6		;timing
	
	out (#fe),a		;11__40 (ch1b)

	add a,ixh		;8		
	
	ex de,hl		;4
	
	or a			;4		;timing
	ret c			;5		;timing
	
	out (#fe),a		;11__32 (ch2a)
	
	dec bc			;6		;timing
	
	add hl,sp		;11		;ch3
	ld a,h			;4
	out (#fe),a		;11__32 (ch2b)

	add a,ixl		;8
	
	ex de,hl		;4
	exx			;4
	
	or a			;4		;timing
	ret c			;5		;timing
	nop			;4		;timing

	out (#fe),a		;11__40 (ch3a)
	
	dec b			;4
	jp nz,playNote		;10
				;224

	db #fd	
env1
	nop					;fd 24 = inc iyh
						;fd 25 = dec ixh

	db #dd
env2
	nop					;dd 24 = inc ixh
						;dd 25 = dec ixh
	
	db #dd
env3
	nop					;fd 2c = inc ixl
						;fd 2d = dec ixl
	
	dec c
	jp nz,playNote
	
	jp readPtn

;*******************************************************************************
drum1						;kick

	
	ld (deRest),de
	ld (bcRest),bc
	ld (hlRest),hl

	ld d,a					;A = start_pitch<<1
	ld e,b					;B = 0
	ld h,b
	ld l,b
	
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
	and #ff					;border
	out (#fe),a
	djnz xlllp
	dec c
	jr nz,xlllp

						;45680 (/224 = 203.9)
deRest equ $+1
	ld de,0
	ld a,#34				;correct speed offset

drumEnd
hlRest equ $+1
	ld hl,0
bcRest equ $+1
	ld bc,0
	ld b,a

	ex af,af'
	jp drumRet				
	

	
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
				
	ld bc,#ff03				;length
sloop
	add hl,hl		;11
	sbc a,a			;4
	xor l			;4
	ld l,a			;4

dvol equ $+1	
	cp #80			;7		;volume
	sbc a,a			;4
	
	and #ff			;7		;border
	out (#fe),a		;11
	djnz sloop		;13/7 : 65 * 256 * B : B=3 -> 49920 (/224 = 222.8)

	dec c			;4
	jr nz,sloop		;12 : (16 - 6) * B : B=3 -> +30
				;			+load/wrap
				;49903 w/ b=#ff (/224 = 222.8)
	ld a,#21				;correct speed offset
	jr drumEnd

	
	
;*******************************************************************************
musicData
	include "music.asm"
