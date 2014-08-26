;ntropic
;beeper routine by utz 01'14, revised 08'14 (irrlichtproject.de)
;bugfixes suggested by kphair
;2ch tone, 1ch noise, click drum
;uses ROM data in range #0000-~#3800
;this code is public domain

	org 32768

begin	di
	;push ix
	push iy
	ld c,0			;initialize speed counter
	ld (oldSP),sp
	ld sp,intStack

reset	ld hl,ptab		;setup pattern sequence table pointer
	
lpt	ld e,(hl)		;read pattern pointer
	inc hl
	ld d,(hl)
	ld a,e
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
	db #31			;ld sp,nn
oldSP
	dw 0
	pop iy
	;pop ix
	ei
	ret

;****************************************************************************************
main	push hl			;preserve data pointer
	ld ix,skip1
	
	
rdata	ld iyh,#10		;output switch mask
	
	pop hl			;restore data pointer
	
	ld a,(hl)		;read drum byte
	inc a			;and exit if it was #ff
	ret z
	
	ld a,(hl)		;read speed
	and %11111110
	ld b,a

	ld a,(hl)
	rra
	call c,drum
	
	inc hl
	xor a
	
	in a,(#fe)		;read keyboard
	cpl
	and #1f
	ret nz
	
	ld a,(hl)		;read counter ch1
	
	or a			;mute switch ch1
	jr nz,rsk1
	ld iyh,a
	
rsk1	ld d,a
	ld e,a
	
	inc hl
		
	push hl			;read counter ch2
	exx
	pop hl
	ld b,#10
	ld a,(hl)
	
	or a			;mute switch ch2
	jr nz,rsk2
	ld b,a
	
rsk2	ld d,a
	ld e,d
	ld hl,skip2
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
sndlp	ex af,af'	;4
	out (#fe),a	;11
	dec d		;4	;decrement counter ch1
	jp nz,wait1	;10	;if counter=0
	
m1 equ $+1
	xor iyh		;8	;flip output mask and reset counter
	ld d,e		;4
skip1	

	ex af,af'	;4
	exx		;4
	pop af		;10	;load output mask ch2
				;44t output for ch1
	
	
	out (#fe),a	;11
	dec d		;4	;decrement counter ch2
	jp nz,wait2	;10	;if counter=0
	
m2 equ $+1
	xor b		;4	;flip output mask and reset counter
	ld d,e		;4
skip2	
	push af		;11	;preserve output mask ch2
	exx		;4
	
	
noise	ld a,(hl)	;7	;read byte from ROM
				;43t output for ch2
	and #10		;7	;waste some time
	
	out (#fe),a	;11	;output whatever
	bit 7,h		;8	;check if ROM pointer has rolled over to #ffxx
	jp nz,wait3	;10
	
	dec hl		;6	;decrement ROM pointer
	nop		;4	;waste some time
	
dtim
	dec bc		;6	;decrement timer
	ld a,b		;4
	or c		;4
	jp nz,sndlp	;10	;repeat sound loop until bc=0
			;184
	
	pop af			;clean stack
	jr rdata		;read next note

;****************************************************************************************
wait1	nop		;4
	jp (ix)		;8

wait2	nop		;4
	jp (hl)		;4
	
wait3	jp dtim		;10

	
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
;internal stack

	ds 10			;5 stack locations
intStack

;****************************************************************************************	
;music data

include "music.asm"

end
	