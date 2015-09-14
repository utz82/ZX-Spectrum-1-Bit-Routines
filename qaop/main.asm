;qaop beeper engine by utz 08'2015
;"quite accurate overdriven player"


;IX,DE = counters ch1
;IY,SP = counters ch2
;BC = smp pointer 1
;HL = smp pointer 2

;HL' = output buffer pntr, l=smp
;D' = backup L
;E' = speed-lo
;A' = speed-hi
;C' = #fe


	org #8000
samples
	nop
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
	ld hl,sequence
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

	ld e,a			;timer lo = 0
	exx

patpntr equ $+1			;fetch pointer to pattern data
	ld sp,0

	pop af			;speed+end
	jp z,rdseq	
	
	ld h,a	
	jp c,drum1
drumret	
	ld a,h
	
	ex af,af'
	
	xor a
	
	pop de			;freq ch1
	pop hl			;freq ch2
	pop bc			;samples
	
	ld (patpntr),sp		;preserve data pointer
	
	ld sp,hl		;freq ch2 to sp
	ld h,c			;sample 2 to HL
	ld l,a
	ld c,a			;sample 1 now in BC
	
	ld ix,0
	ld iy,0
	exx


	ld hl,volbuf
	ld d,l
	ld c,#fe
	xor a
	
	ex af,af'

;******************************************************************	
	ex af,af'
play
	outi			;16		;output vol.state 3
				;----36
	
	exx			;4		
						;xor a			;4
	add ix,de		;15		;add counters ch1
	adc a,c			;4		;move sample pointer if necessary
	ld c,a			;4
	
	exx			;4
	outi			;16		;output vol.state 4
				;----47
	exx			;4
			
	xor a			;4
	add iy,sp		;15		;add counters ch2
	adc a,l			;4		;move sample pointer if necessary
	ld l,a			;4
	
	exx			;4
	outi			;16		;output vol.state 5
				;----51
	exx			;4
	
	ld a,(bc)		;7		;add sample volumes
	add a,(hl)		;7
		
	exx			;4
	outi			;16		;output vol.state 6
				;----38

	add a,d			;4		;add volume offset
	ld l,a			;4
	nop			;4
	
	outi			;16		;output vol.state 1
				;----28
	nop			;4
	nop			;4

	outi			;16		;output vol.state 2
				;----24
	xor a			;4
	dec e			;4
	jr nz,play		;12	;224
	
	ex af,af'
	dec a
	jr nz,play-1
	
 	jp rdptn

;******************************************************************
exit
oldSP equ $+1
	ld sp,0
	pop hl
	exx
	ei
	ret
;******************************************************************

drum1
	jp m,drum2
	jp pe,drum3
	
	xor a		;1
	ld b,a		;1
	ld c,a		;1
	
_druml
	out (#fe),a	;2	
	djnz _druml	;2
	ld b,#10	;2		;b = length, ~ #2-#20 but if bit 4 not set then must use
	xor b		;1		;xor #10/#18		;2
_xx			
	inc c		;1		;dec c is also possible for different sound
	jp z,drumret
	djnz _xx	;2					
	ld b,c		;1
	jr _druml	;2


drum2
	ld de,#5510	;3		;d = frequency	
	jr drumx

drum3
	ld de,#2210

drumx
	xor a		;1
	ld bc,#200	;3		;bc = length	
_druml
	out (#fe),a	;2	;11
	add hl,de	;1	;11
	jr nc,_yy	;2	;12/7
	xor e		;1	;4
_yy
	rlc h		;2	;8
	cpi		;2	;16
	jp pe,_druml
	
	dec sp
	dec sp
	pop hl
	exx
	ld e,#78
	exx
	jp drumret

;******************************************************************

IF ((HIGH($))<(HIGH($+12)))		;align to next page if necessary
	org 256*(1+(HIGH($)))
.WARNING volume buffer crosses page boundary, realigned to next page
ENDIF

volbuf
	db 0,0,0,0,0,0
	db #18,#18,#18,#18,#18,#18
	db #18,#18,#18,#18,#18,#18

	
	org 256*(1+(HIGH($)))
;samples
	include "samples.asm"
	
musicdata
	include "music.asm"
