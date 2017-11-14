;Pytha Beeper Engine
;by utz 06'2017 * www.irrlichtproject.de
;2 channels of tone, triangle/rectangle/saw/noise waveforms

USE_LOOP equ 1
USE_DRUMS equ 1
include "equates.h"

	org #8000

	di
	ld c,#fe
	exx
	push hl			;preserve HL' for return to BASIC
	ld (oldSP),sp
	ld hl,music_data
	ld (seqpntr),hl
	ld ixl,0		;timer lo
	ld c,#fe

;*******************************************************************************
read_seq
seqpntr equ $+1
	ld sp,0
	xor a
	pop iy
	or iyh
	ld (seqpntr),sp
	jr nz,read_ptn0

IF USE_LOOP = 1	
	ld sp,mloop		;get loop point
	jr read_seq+3
ENDIF
;*******************************************************************************
exit
oldSP equ $+1
	ld sp,0
	pop hl
	exx
	ei
	ret

;*******************************************************************************
read_ptn0
	ld sp,iy			;set pattern pointer

read_ptn
	in a,(#fe)			;read kbd
	cpl
	and #1f
	jr nz,exit


	pop af				;flags|speed
	jp m,read_seq
	ld ixh,a			;speed
IF USE_DRUMS = 1
	jp pe,drum
ENDIF
drum_return
	jr z,no_ch1_reload
	
	ex af,af'			;load data ch1
	pop af
	jr c,note_only_ch1 
	
	ld b,a				;offset
	
	ld hl,0
	ld a,h	
	jr nz,set_mod_ch1		;if Z then disable modulator
	
	ld a,4				;inc b
set_mod_ch1
	ld (mod_enable1),a
	jp po,set_noise1
	
	ld hl,#04cb			;rlc h = noise enable
set_noise1
	ld (noise1),hl
	
	pop hl				;waveform
	ld (waveform1),hl
	
note_only_ch1
	ld hl,0
	pop de				;freq divider
	
	ex af,af'
	
no_ch1_reload
	exx
	jr c,no_ch2_reload
			
	pop af				;load data ch2
	jr c,note_only_ch2 
	
	ld b,a				;offset
	
	ld hl,0
	ld a,h	
	jr nz,set_mod_ch2		;if Z then disable modulator
	
	ld a,4				;inc b
set_mod_ch2
	ld (mod_enable2),a
	jp po,set_noise2
	
	ld hl,#04cb			;rlc h = noise enable
set_noise2
	ld (noise2),hl
	
	pop hl				;waveform
	ld (waveform2),hl
	
note_only_ch2
	ld hl,0
	pop de				;freq divider

no_ch2_reload

;*******************************************************************************
;TODO update release with new (correct) timing, update equates.h, update demo song
sound_loop
	exx			;4
	
	add hl,de		;11	;ch1 accu	
	ld a,h			;4
	add a,b			;4	;apply modulator
	or h			;4
	rlca			;4
waveform1
	sbc a,a			;4	;replace with rrca for saw wave
	xor h			;4	;replace with nop for saw/square wave
	rrca			;4
	out (#fe),a		;11__64
	rrca			;4
	out (c),a		;12__16
noise1
	ds 2			;8	;noise w/ rlc h
	rrca			;4
	nop			;4
	exx			;4
	out (c),a		;12__32
	
_ch2	
	add hl,de		;11	;ch2 accu
	
	ld a,h			;4
	add a,b			;4	;apply modulator
	or h			;4
	ret c			;5	;timing
	rlca			;4
waveform2
	sbc a,a			;4	;replace with rrca for saw wave
	xor h			;4	;replace with nop for saw/square wave
	rrca			;4
	out (#fe),a		;12__64
	rrca			;4
	out (c),a		;12__16
noise2
	ds 2			;8	;noise w/ rlc h
	rrca			;4
	dec ixl			;8
	out (c),a		;12__32
	
	jp nz,sound_loop	;10
				;216

mod_enable2	
	inc b				;replace this with nop to disable modulation
	exx

mod_enable1
	inc b				;replace this with nop to disable modulation
	exx
	
	dec ixh
	jp nz,sound_loop
	
	exx
	jp read_ptn
	
;*******************************************************************************
IF USE_DRUMS = 1
drum
	ex af,af'
	ld (deRest),de
	ld (hlRest),hl
	ld (bcRest),bc
	
	pop de
	ld a,d
	rlca
	jr c,drum2
	
drum1					;kick, 
	ld d,a				;D = start pitch
	ld a,e
	ld (slideSpeed),a
	ld e,0
	ld h,e
	ld l,e
	ld c,#3				;length
	
xlllp
	add hl,de
	jr c,noUpd
	ld a,e
slideSpeed equ $+1
	sub #10				;speed
	ld e,a
	sbc a,a
	add a,d
	ld d,a
noUpd
	ld a,h
	and #ff				;border
	out (#fe),a
	djnz xlllp
	dec c
	jr nz,xlllp
				;45680 (/224 = 203.9)
	
	ld ixl,#34			;correct speed offset

drum_end
deRest equ $+1
	ld de,0
hlRest equ $+1
	ld hl,0
bcRest equ $+1
	ld bc,0
	ex af,af'	
	jp drum_return		
	

	
drum2						;noise
	rlca
	ld a,e
	ld (dvol),a
	ld hl,1					;#1 (snare) <- 1011 -> #1237 (hat)
	jr z,d2init
	
	ld hl,#1237
	
d2init				
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
	ld ixl,#21		;correct speed offset
	jr drum_end
ENDIF
	
	
;*******************************************************************************
music_data
	include "music.asm"
