;ntropic
;beeper routine by utz 01'14 (irrlichtproject.de)
;2ch tone, 1ch noise, click drum, size 151 bytes
;uses ROM data in range #0000-#3800
;this code is public domain

	org #8000

begin	di
reset	ld hl,ptab		;setup pattern sequence table pointer
	
lpt	ld e,(hl)		;read pattern pointer
	inc hl
	ld d,(hl)
	xor a
	or d
	jr z,reset		;if d=0, loop to start
	;jr z,exit		;or exit
	inc hl
	push hl			;preserve pattern pointer
	ex de,hl		;put data pointer in hl

	call main
	
	pop hl
	jr z,lpt		;if no key has been pressed, read next pattern
	
exit	ld hl,#2758		;restore hl' for return to BASIC
	exx
	ei
	ret

;****************************************************************************************
main	push hl			;preserve data pointer
	
rdata	ld a,#10
	ld (m1),a
	ld (m2),a
	
	ld a,(speed)
	ld b,a			;timer
	;ld c,b
	pop hl			;restore data pointer
	
	ld a,(hl)		;read drum byte
	inc a			;and exit if it was #ff
	ret z
	
	dec a
	call nz,drum
	
	inc hl
	
	in a,(#fe)		;read keyboard
	cpl
	and #1f
	ret nz
	
	ld a,(hl)		;read counter ch1
	
	or a			;mute switch ch1
	jr nz,rsk1
	ld (m1),a
	
rsk1	ld d,a
	ld e,a
	
	inc hl
		
	push hl			;read counter ch2
	exx
	pop hl
	ld a,(hl)
	
	or a			;mute switch ch2
	jr nz,rsk2
	ld (m2),a
	
rsk2	ld d,a
	ld e,d
	exx
	
	inc hl
	ld a,(hl)		;read noise length val
	inc hl
	push hl			;preserve data pointer
	ld h,a			;setup ROM pointer for noise, length to h	
	xor a			;mask for ch1
	ld l,a			;and part 2 of ROM pointer setup
	ex af,af'
	xor a			
	push af			;mask for ch2

;****************************************************************************************
sndlp	ex af,af'
	dec d			;decrement counter ch1
	jr nz,skip1		;if counter=0
	
m1 equ $+1
	xor #10			;flip output mask and reset counter
	ld d,e
skip1	out (#fe),a

	ex af,af'
	exx
	pop af			;load output mask ch2	
	dec d			;decrement counter ch2
	jr nz,skip2		;if counter=0
	
m2 equ $+1	
	xor #10			;flip output mask and reset counter
	ld d,e
skip2	out (#fe),a
	push af			;preserve output mask ch2
	exx
	
	
noise	ld a,(hl)		;read byte from ROM
	out (#fe),a		;output whatever
	
	bit 7,h			;check if ROM pointer has rolled over to #ffxx
	jr nz,dtim
	
	dec hl			;decrement ROM pointer
	
dtim	dec bc			;decrement timer
	ld a,b
	or c
	jr nz,sndlp		;repeat sound loop until bc=0
	
	pop af			;clean stack
	jr rdata		;read next note

;****************************************************************************************	
drum	push hl			;preserve data pointer
	push bc			;preserve timer
	ld hl,#3000		;setup ROM pointer - change val for different drum sounds
	ld de,#0809		;loopldiloop
	ld b,72
	
dlp3	ld a,(hl)		;read byte from ROM
	out (#fe),a		;output whatever

	dec hl			;decrement ROM pointer #2b/#23 (inc hl)
	;inc hl			;use this instead for quieter click drum
	dec bc			;decrement timer

dlp4	dec d
	jr nz,dlp4
	
	ld d,e
	inc e
	djnz dlp3
	
	pop bc			;restore timer
	pop hl
	dec b			;adjust timing
	ret

;****************************************************************************************	
;music data

include "music.asm"

end
	