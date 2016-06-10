;beepertoy v0.1
;multi-core beeper player
;by utz 06'2016

;core0		2ch pulse, duty, vol, reverb or fixed pitch smp, cust. lo-pass
;core0n		1ch pulse, 1ch noise, duty, vol, reverb or fixed pitch smp, cust. lo-pass
;core0hs	3ch wavetable, hi-pass
;core0S		3ch wavetable, cust. lo-pass
;accupin0	4ch pin pulse (accumulating)
;sqeekpin0	4ch pin pulse (squeeker style)
;romNoise0	ROM noise


outhi equ #41ed
outlo equ #71ed
PCTRL equ #15fe
tritoneMask1 equ #16
tritoneMask2 equ #13
tritoneMask3 equ #14

	org #8000

init
	call detectCPU
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
	exx
	ld (oldSP),sp
	ld hl,musicData
	ld (seqpntr),hl

;******************************************************************
rdseq
seqpntr equ $+1
	ld sp,0
	xor a
	pop hl			;pattern pointer to HL
	or h
	ld (seqpntr),sp
	jr nz,rdptn0
	
	jp exit		;uncomment to disable looping
	
	ld sp,loop		;get loop point
	jr rdseq+3

;******************************************************************
updateTimer0
	nop
	dw outlo
updateTimer
	ex af,af'		;4
	ld a,i			;9
	dec a			;4
	jr z,setStack		;12/7
	ld i,a			;9
	jp (hl)			;4
				;37
setStack
	ld hl,10
	add hl,sp
	ld sp,hl
	jp readNextRow
				
updateTimerHS0
	nop
	dw outlo
updateTimerHS
	ex af,af'		;4
	ld a,i			;9
	dec a			;4
	jr z,setStackHS		;12/7
	ld i,a			;9
	jp (hl)			;4
				;37
setStackHS
	ld hl,12
	add hl,sp
	ld sp,hl
	jp readNextRow
				
updateTimerAP
	ex af,af'		;4
	ld h,a
	ld a,i			;9
	dec a			;4
	jr z,setStackAP		;12/7
	ld i,a			;9
	ld a,h
	jp accupin		;10
	
setStackAP
	ld hl,8
	add hl,sp
	ld sp,hl
	jp readNextRow
	
setStackSP
	ld hl,6
	add hl,sp
	ld sp,hl
	jp readNextRow

;******************************************************************
exit
oldSP equ $+1
	ld sp,0
	pop hl
	exx
	ei
	ret
;******************************************************************

rdptn0
	ld sp,hl
readNextRow
	in a,(#1f)		;read joystick
maskKempston equ $+1
	and #1f
	ld c,a
	in a,(#fe)		;read kbd
	cpl
	or c
	and #1f
	jp nz,exit

	pop af
	jr z,rdseq
	
	ld i,a			;timer
	
	jr c,drumNoise
	jp pe,drumKick
	jp m,drumSnare
drumRet
	
	xor a			;clear timer lo
	ex af,af'	
	
	exx
	pop hl			;get reverbBuf read pointer
	pop de			;get reverbBuf write pointer
	exx
	
	pop hl			;get core jump

patchCmosOut equ $+3	
	ld bc,PCTRL
	ld ix,0
	ld iy,0
	jp (hl)


drumNoise	
	ld de,#35d1	;10
drumX
	ld hl,0
	pop bc		;10		;duty in C, B = 0
	
_dlp	
	add hl,de	;11
	ld a,h		;4
	cp c		;4
	sbc a,a		;4
	and #1e		;7
	out (#fe),a	;11
	rlc h		;8
	djnz _dlp	;13/8 - 62*256 = 15872
	
	ld d,b		;4	;reset DE
	ld e,b		;4
	ld a,#ad	;7	;adjust row length
	ex af,af'	;4
	jp drumRet	;10
			;15933/15943 ~ 83 sound loop iterations

drumKick
	ld de,1
	jr drumX

drumSnare
	ld de,5
	jr drumX
	
	
;SP	data pointer
;IX,IY	add counters ch1/2
;DE	base freq/duty/vol (dynamic)
;HL	jump pointer/SP restore, H also used to temporarily hold vol ch1
;BC	output ctrl
;HL'	reverb buffer read pointer -> points to empty buffer for no verb
;DE'	reverb buffer write pointer
;BC'	free
;A'/I	timer


;*******************************************************************************
IF (LOW($))!=0
	org 256*(1+(HIGH($)))
ENDIF
		
core0S
	dw outlo		;12__
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4	
	ld a,(bc)		;7
	ld (_shift2),de		;20
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	
	sub 0			;7
	sra a			;8
_shift2
	ds 2			;8
	add a,0			;7
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	
	ld r,a			;9	;timing
	jp (hl)			;4	;jump to next core
				;384

octode0
	pop hl
	ld (oc.f3),hl
	ld (oc.stackrestore),sp
	xor a
	ld b,a
	ex af,af'
	ld c,a
	dec c			;timer-lo to C'
	ex af,af'		
	exx
	ld b,h
	ld c,l


octode
	add ix,de		;15
	sbc a,0			;7
	
	add hl,bc		;11

	exx			;4
	sbc a,b			;4
	
	pop de			;10
oc.f4 equ $+1
	ld hl,0			;10
	add hl,de		;11
	ld (oc.f4),hl		;16
	sbc a,b			;4
	
	pop de			;10
oc.f5 equ $+1
	ld hl,0			;10
	add hl,de		;11
	ld (oc.f5),hl		;16
	sbc a,b			;4
	
	pop de			;10
oc.f6 equ $+1
	ld hl,0			;10
	add hl,de		;11
	ld (oc.f6),hl		;16
	sbc a,b			;4
	
	pop de			;10
oc.f7 equ $+1
	ld hl,0			;10
	add hl,de		;11
	ld (oc.f7),hl		;16
	sbc a,b			;4
	
	pop de			;10
oc.f8 equ $+1
	ld hl,0			;10
	add hl,de		;11
	ld (oc.f8),hl		;16
	sbc a,b			;4
	
oc.f3 equ $+1
	ld sp,0			;10
	add iy,sp		;15
	sbc a,b			;4
	
	out (#fe),a		;11
	cp d			;7	;!!!d.h. freq8 cannot be >~#c000
	ccf			;4
	adc a,b			;4

oc.stackrestore equ $+1
	ld sp,0			;10
	
	dec c			;4
	jp nz,oc.timerReturn	;10
	dec c
	ld h,a
	ld a,i
	dec a
	jr z,restoreStackOC
	ld i,a
	ld a,h
	
oc.timerReturn
	exx			;4	
	
	jp octode		;10
				;386

restoreStackOC
	ld hl,10
	add hl,sp
	ld sp,hl
	jp readNextRow	
				
;******************************************************************************
	org 256*(1+(HIGH($)))
core1S
	dw outhi		;12__
	nop			;4
	dw outlo		;12__16
	
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	exx			;4	;rs
	
	ld r,a			;9	;timing
	;------------------	;192
				
	dw outhi		;12
	nop			;4
	dw outlo		;12
	
	exx			;4	;rs'
	
	ld a,(bc)		;7
	ld (_shift2),de		;20
	
	exx			;4	;rs
	add a,l			;4	;add sample values
	
	sub 1			;7
	sra a			;8
_shift2
	ds 2			;8
	add a,1			;7	;y[i] = y[i-1]+0.25*(x[i]-y[i-1])
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	jr _x			;12
_x	jr _y			;12
_y	jp (hl)			;4	;jump to next core
				;192

accupin0
	xor a
accupin
	pop de			;10
	add ix,de		;15
	adc a,0			;7
	
	pop de			;10
	add iy,de		;15
	adc a,0			;7
	
	exx			;4
	pop bc			;10
	add hl,bc		;11
	adc a,0			;7
	
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	adc a,0			;7
	ex de,hl		;4
	
	exx			;4
	
	ld h,(hl)		;7	;timing
	nop			;4
	
	ld hl,-8		;10
	add hl,sp		;11
	ld sp,hl		;6
	
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	
	jp z,_noOut		;10
	
	dw outhi		;12
	
	dec a			;4
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimerAP	;10
	ex af,af'		;4
	
	jp accupin		;10
				;384
	
_noOut
	dw outlo		;12
	nop			;4
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimerAP	;10
	ex af,af'		;10
	
	jp accupin		;10


	org 256*(HIGH($)) + #b0
coreN12hs
	dw outhi		;12__
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4	
	ld a,(bc)		;7
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	
	exx			;4	;rs'
	ld e,a			;4	;temporarily hold x[i]
	sub d			;4
	sub 12			;7
	sra a			;8
	sra a			;8	;y[i] = 0.25*(y[i-1]+x[i]-x[i-1])
	ld e,d			;4	;preserve x[i]
	exx			;4	;rs
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	jr _x			;12
_x	nop
	
	jp (hl)			;4	;jump to next core
				;384

;*******************************************************************************
	org 256*(1+(HIGH($)))
	
core2S
	dw outhi		;12__
	inc de			;6	;timing
	nop			;4
	pop de			;10	;fetch ch1.basefreq
	dw outlo		;12__32
	
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	
	exx			;4	;rs
		
	ld a,(hl)		;7	;timing
	;------------------	;192
				
	dw outhi		;12__
	jr _x			;12	;timing
_x	ds 2			;8
	dw outlo		;12__32
	
	exx			;4	;rs'
	ld c,h			;4
	ld a,(bc)		;7
	ld (_shift2),de		;20
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	
	sub 2			;7
	sra a			;8
_shift2
	ds 2			;8
	add a,2			;7
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	nop			;4
	jp (hl)			;4	;jump to next core
				;192	

squeekpin0
	ld hl,0
	pop de
	exx
	ld a,h
	ld (sq.duty1),a
	ld a,l
	ld (sq.duty2),a
	ld a,d
	ld (sq.duty3),a
	ld a,e
	ld (sq.duty4),a
	ld (sq.stackrestore),sp
	xor a
	ld c,a
	ld l,a
	ld h,a
	
squeekpin
	rl c			;8
	pop de			;10
	add hl,de		;11
sq.duty1 equ $+1
	ld a,0			;7
	add a,h			;4
	
	rl c			;8
	pop de			;10
	add ix,de		;15
sq.duty2 equ $+1
	ld a,0			;7
	add a,ixh		;8
	
	rl c			;8
	pop de			;10
	add iy,de		;15
sq.duty3 equ $+1
	ld a,0			;7
	add a,iyh		;8
	
	rl c			;8
	exx			;4
	add hl,de		;10
sq.duty4 equ $+1
	ld a,0			;7
	add a,h			;4
	exx			;4
	
	ld a,15			;7
	adc a,c			;4
	out (#fe),a		;11
	
sq.stackrestore equ $+1
	ld sp,0			;10
	
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimerSP	;10
	ex af,af'		;4
	
	jr _x			;12
_x	jr _y			;12
_y	ld r,a			;9
	
	jp squeekpin		;10
				;237 -147

updateTimerSP
	ex af,af'		;4
	ld a,i			;9
	dec a			;4
	jp z,setStackSP		;10
	ld i,a			;9
	jp squeekpin		;10

	
	org 256*(HIGH($)) + #b0
coreN11hs
	dw outhi		;12__
	ld a,(hl)		;7	;timing
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	exx			;4	;rs
	
	jr _x			;12
_x	nop			;4
	dw outlo		;12__176
	
	nop			;4	
	;------------------	;192
				
	dw outhi		;12__
	
	exx			;4	;rs'
	pop bc			;10
	ld c,h			;4	
	ld a,(bc)		;7
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	ret c			;5	;timing
	
	exx			;4	;rs'
	ld e,a			;4	;temporarily hold x[i]
	sub d			;4
	sub 11			;7
	sra a			;8
	sra a			;8	;y[i] = 0.25*(y[i-1]+x[i]-x[i-1])
	ld e,d			;4	;preserve x[i]
	exx			;4	;rs
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS0	;10
	ex af,af'		;4
	nop			;4
	jr _y			;12
_y	
	dw outlo		;12__176
	
	jp (hl)			;4	;jump to next core
				;192
;*******************************************************************************
	org 256*(1+(HIGH($)))

core3S
	dw outhi		;12__
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	ld a,(hl)		;7	;timing
	nop			;4
	dw outlo		;12__48
	
	inc de			;6	;timing
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	
	exx			;4	;rs

	;------------------	;192
				
	dw outhi		;12__
	
	exx			;4	;rs'
	ld c,h			;4
	ld a,(bc)		;7
	ld a,(bc)		;7	;timing
	inc bc			;6	;timing
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	dw outlo		;12__48
	
	exx			;4
	ld (_shift2),de		;20
	exx			;4
	
	sub 3			;7
	sra a			;8
_shift2
	ds 2			;8
	add a,3			;7
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	sub 1			;7
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	jp (hl)			;4	;jump to next core
				;192


detectCPU
	ei
	halt
	di
	ld bc,#fffd		; read and save the value in R0
	xor a
	out (c),a
	in l,(c)
	ld de,#bfff		; put something different, non-zero and non-#FF into R0. i also tried to make
				; the change relatively small, so that this test can be run along with the music.
	ld a,l
	and %11111100
	xor %00000100
	or %00000001
	ld h,a
	ld b,d
	out (c),a

	ld b,e			; read R0 to see if AY is actually available
	in a,(c)
	cp h
	jr z,AYIsPresent

	xor a
	ret


AYIsPresent			; if AY is present, execute "out (c), 0", read the resulting value back to see what it is
	ld b,d
	db #ed,#71
	ld b, e
	in a,(c)

	ld b,d			; and recover the original value
	out (c),l

; 	scf			; on NMOS processors it should be 0, on CMOS - #FF
; 	ret nz
; 	ccf
; 	ret
	jr nz,patchCMOS
	ret

patchCMOS
	xor a
	ld (patchCmosOut),a
	ret

	
	org 256*(HIGH($)) + #b0
coreN10hs
	dw outhi		;12__
	ld a,(hl)		;7	;timing
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	exx			;4	;rs
	
	dw outlo		;12__160
	
	jr _x			;12
_x	ds 2			;8	
	;------------------	;192
				
	dw outhi		;12__
	
	exx			;4	;rs'
	pop bc			;10
	ld c,h			;4	
	ld a,(bc)		;7
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	ret c			;5	;timing
	
	exx			;4	;rs'
	ld e,a			;4	;temporarily hold x[i]
	sub d			;4
	sub 10			;7
	sra a			;8
	sra a			;8	;y[i] = 0.25*(y[i-1]+x[i]-x[i-1])
	ld e,d			;4	;preserve x[i]
	exx			;4	;rs
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS0	;10
	ex af,af'		;4
	dw outlo		;12__160
	
	nop			;4
	jr _y			;12
_y	jp (hl)			;4	;jump to next core
				;192
;*******************************************************************************
	org 256*(1+(HIGH($)))
	
core4S
	dw outhi		;12__
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	
	ld r,a			;9	;timing
	dw outlo		;12__64
		
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	
	exx			;4	;rs
	nop			;4
	;------------------	;192
				
	dw outhi		;12__
	
	exx			;4	;rs'	
	ld a,(bc)		;7
	inc bc			;6	;timing
	ld (_shift2),de		;20
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	
	sub 4			;7
	
	dw outlo		;12__64
	
	sra a			;8
_shift2
	ds 2			;8
	add a,4			;7
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	ld a,(hl)		;7	;timing
	ld a,(hl)		;7	;timing
	ds 2			;8
	jp (hl)			;4	;jump to next core
				;192

tritone0
	ex af,af'
	srl a				;tritone is twice as fast, thus needs
					;extra drum timing correction
	ex af,af'
	pop bc
	pop de
	ld hl,0
	exx
	pop bc
	ld a,h
	ld (tr.duty1),a
	ld a,l
	ld (tr.duty2),a
	ld a,d
	ld (tr.duty3),a
	ld a,e
	ld (tr.fxEnable),a
	ld hl,0
tritone
	add hl,bc		;11
tr.duty1 equ $+1
	ld a,0			;7
	cp h			;4
	sbc a,a			;4
	and tritoneMask1	;7
	out (#fe),a		;11__80
	exx			;4
	
	add hl,bc		;11
tr.duty2 equ $+1
	ld a,0			;7
	cp h			;4
	sbc a,a			;4
tr.fxEnable equ $+1
	db #cb,#07		;8	;07=rlc a (off), 04=rlc h (noise)
					;02=rlc d (glitch ch3),00=rlc b (gl.ch2)
	and tritoneMask2	;7
	out (#fe),a		;11__56
	
	add ix,de		;15
tr.duty3 equ $+1
	ld a,0			;7
	cp ixh			;8
	sbc a,a			;4
	and tritoneMask3	;7
	exx			;4
	
	out (#fe),a		;11__56
	ex af,af'		;4
	dec a			;4
	jp z,updateTimerTR	;10
	ex af,af'		;4
	
	nop			;4
	jp tritone		;10
				;192
updateTimerTR
	ex af,af'
	ld a,i
	dec a
	jp z,readNextRow
	ld i,a
	jp tritone

	org 256*(HIGH($)) + #b0
coreN9hs
	dw outhi		;12__
	
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	
	add a,l			;4	;add sample values
	
	exx			;4	;rs'
	inc bc			;6	;timing
	pop bc			;10	;same as above for ch3
	exx			;4	;rs
	
	dw outlo		;12__144
			
	exx			;4	;rs'		
	add hl,bc		;11
	pop bc			;10	
	exx			;4	;rs
	ld c,#fe		;7	;timing
	;------------------	;192
				
	dw outhi		;12__
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	ld c,h			;4	
	ld a,(bc)		;7
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	ret c			;5	;timing
	
	exx			;4	;rs'
	ld e,a			;4	;temporarily hold x[i]
	sub d			;4
	sub 9			;7
	sra a			;8
	sra a			;8	;y[i] = 0.25*(y[i-1]+x[i]-x[i-1])
	ld e,d			;4	;preserve x[i]
	exx			;4	;rs
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	nop			;4

	dw outlo		;12__144

	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	nop			;4
	ld a,(hl)		;7	;timing
	ld a,(hl)		;7	;timing
	jp (hl)			;4	;jump to next core
				;192
;*******************************************************************************
	org 256*(1+(HIGH($)))
	
core5S
	dw outhi		;12__
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	nop			;4
	dw outlo		;12__80
		
	
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	
	exx			;4	;rs
	ld r,a			;9	;timing
	;------------------	;192
				
	dw outhi		;12__
	
	exx			;4	;rs'	
	ld a,(bc)		;7
	inc bc			;6	;timing
	ld (_shift2),de		;20
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	
	sub 5			;7
	sra a			;8
_shift2
	ds 2			;8

	dw outlo		;12__80
	
	add a,5			;7
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	ld a,(hl)		;7	;timing
	jr _x			;12	;timing
_x	ds 2			;8
	jp (hl)			;4	;jump to next core
				;192




	org 256*(HIGH($)) + #b0
coreN8hs
	dw outhi		;12__
	
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	nop			;4
	dw outlo		;12__128
		
	exx			;4	;rs'
	
	inc bc			;6	;timing
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	
	ld a,(hl)		;7	;timing
	exx			;4	;rs
	;------------------	;192
				
	dw outhi		;12__
	
	exx			;4	;rs'
	ld c,h			;4	
	ld a,(bc)		;7
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	ret c			;5	;timing
	
	exx			;4	;rs'
	ld e,a			;4	;temporarily hold x[i]
	sub d			;4
	sub 8			;7
	sra a			;8
	sra a			;8	;y[i] = 0.25*(y[i-1]+x[i]-x[i-1])
	ld e,d			;4	;preserve x[i]
	exx			;4	;rs
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4

	dw outlo		;12__128
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	jr _y			;12
_y	ld a,(hl)		;7	;timing
	ld a,(hl)		;7	;timing
	jp (hl)			;4	;jump to next core
				;192
;*******************************************************************************
	org 256*(1+(HIGH($)))
	
core6S
	dw outhi		;12__
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	
	pop de			;10	;same as above for ch2
	add iy,de		;15

	ld r,a			;9	;timing
	dw outlo		;12__96
	
	ld l,a			;4	;preserve value	

	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	
	exx			;4	;rs
	nop			;4
	;------------------	;192
				
	dw outhi		;12__
	
	exx			;4	;rs'	
	ld a,(bc)		;7
	ld (_shift2),de		;20
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	ret c			;5	;timing
	
	sub 6			;7
	sra a			;8
_shift2
	ds 2			;8
	add a,6			;7
	
	ld hl,-14		;10	;reset stack
	dw outlo		;12__96
	
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	ld a,(hl)		;7	;timing
	ld a,(hl)		;7	;timing
	ld r,a			;9	;timing
	
	jp (hl)			;4	;jump to next core
				;192


	org 256*(HIGH($)) + #b0
coreN7hs
	dw outhi		;12__
	ld a,(hl)		;7	;timing
	
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8

	dw outlo		;12__112
	
	ld l,a			;4	;preserve value	

	ld a,(de)		;7
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	
	inc bc			;6	;timing
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	
	exx			;4	;rs
	;------------------	;192 -2
				
	dw outhi		;12__
	
	exx			;4	;rs'	
	ld a,(bc)		;7
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	
	exx			;4	;rs'
	ld e,a			;4	;temporarily hold x[i]
	sub d			;4
	sub 7			;7
	sra a			;8
	sra a			;8	;y[i] = 0.25*(y[i-1]+x[i]-x[i-1])
	ld e,d			;4	;preserve x[i]
	exx			;4	;rs
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	ld h,(hl)		;7	;timing
	nop			;4
	dw outlo		;12__112
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	jr _y			;12
_y	jr _z			;12
_z	jp (hl)			;4	;jump to next core
				;192
;*******************************************************************************
	org 256*(1+(HIGH($)))
	
core7S
	dw outhi		;12__
	ld a,(hl)		;7	;timing
	
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8

	dw outlo		;12__112
	
	ld l,a			;4	;preserve value	

	ld a,(de)		;7
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	
	inc bc			;6	;timing
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	
	exx			;4	;rs
	;------------------	;192 -2
				
	dw outhi		;12__
	
	exx			;4	;rs'	
	ld a,(bc)		;7
	ld (_shift2),de		;20
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	
	sub 7			;7
	sra a			;8
_shift2
	ds 2			;8
	add a,7			;7
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	nop			;4
	dw outlo		;12__112
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	jr _y			;12
_y	jr _z			;12
_z	jp (hl)			;4	;jump to next core
				;192


	org 256*(HIGH($)) + #b0
coreN6hs
	dw outhi		;12__
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	
	pop de			;10	;same as above for ch2
	add iy,de		;15

	ld r,a			;9	;timing
	dw outlo		;12__96
	
	ld l,a			;4	;preserve value	

	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	
	exx			;4	;rs
	nop			;4
	;------------------	;192
				
	dw outhi		;12__
	
	exx			;4	;rs'	
	ld a,(bc)		;7
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	
	exx			;4	;rs'
	ld e,a			;4	;temporarily hold x[i]
	sub d			;4
	sub 6			;7
	sra a			;8
	sra a			;8	;y[i] = 0.25*(y[i-1]+x[i]-x[i-1])
	ld e,d			;4	;preserve x[i]
	exx			;4	;rs
	
	ld hl,-14		;10	;reset stack
	
	jr _x			;12	;timing
_x	dw outlo		;12__96	
	
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	ld a,(hl)		;7	;timing
	jr _y			;12
_y	nop			;4
	jp (hl)			;4	;jump to next core
				;192
;*******************************************************************************
	org 256*(1+(HIGH($)))
	
core8S
	dw outhi		;12__
	
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	nop			;4
	dw outlo		;12__128
		
	exx			;4	;rs'
	
	inc bc			;6	;timing
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	
	ld a,(hl)		;7	;timing
	exx			;4	;rs
	;------------------	;192
				
	dw outhi		;12__
	
	exx			;4	;rs'
	ld c,h			;4	
	ld a,(bc)		;7
	ld (_shift2),de		;20
	exx			;4	;rs
	
	add a,l			;4	;add sample values

	sub 8			;7
	sra a			;8
_shift2
	ds 2			;8
	add a,8			;7
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	inc hl			;6	;timing
	pop hl			;10	;get base core address
	
	dw outlo		;12__128
	
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	ld a,(hl)		;7	;timing
	ld a,(hl)		;7	;timing
	nop			;4
	jp (hl)			;4	;jump to next core
				;192
				

	org 256*(HIGH($)) + #b0
coreN5hs
	dw outhi		;12__
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	nop			;4
	dw outlo		;12__80
		
	
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	
	exx			;4	;rs
	ld r,a			;9	;timing
	;------------------	;192
				
	dw outhi		;12__
	
	exx			;4	;rs'	
	ld a,(bc)		;7
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	
	exx			;4	;rs'
	ld e,a			;4	;temporarily hold x[i]
	sub d			;4
	sub 5			;7
	sra a			;8
	sra a			;8	;y[i] = 0.25*(y[i-1]+x[i]-x[i-1])
	exx			;4	;rs
	
	ld hl,-14		;10	;reset stack
	dw outlo		;12__80
	
	exx			;4	;rs'
	ld e,d			;4	;preserve x[i]
	exx			;4	;rs
	
	
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	ld a,(hl)		;7	;timing
	jr _x			;12	;timing
_x	ds 2			;8
	jp (hl)			;4	;jump to next core
				;192
;*******************************************************************************
	org 256*(1+(HIGH($)))
	
core9S
	dw outhi		;12__
	
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	
	add a,l			;4	;add sample values
	
	exx			;4	;rs'
	inc bc			;6	;timing
	pop bc			;10	;same as above for ch3
	exx			;4	;rs
	
	dw outlo		;12__144
			
	exx			;4	;rs'		
	add hl,bc		;11
	pop bc			;10	
	exx			;4	;rs
	ld c,#fe		;7	;timing
	;------------------	;192
				
	dw outhi		;12__
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	ld c,h			;4	
	ld a,(bc)		;7
	ld (_shift2),de		;20
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	
	sub 9			;7
	sra a			;8
_shift2
	ds 2			;8
	add a,9			;7
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	inc hl			;6	;timing
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer

	dw outlo		;12__144
	
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4

	ld a,(hl)		;7	;timing
	ld a,(hl)		;7	;timing
	jp (hl)			;4	;jump to next core
				;192
				

	org 256*(HIGH($)) + #b0
coreN4hs
	dw outhi		;12__
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	
	ld r,a			;9	;timing
	dw outlo		;12__64
		
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	
	exx			;4	;rs
	nop			;4
	;------------------	;192
				
	dw outhi		;12__
	
	exx			;4	;rs'	
	ld a,(bc)		;7
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	
	exx			;4	;rs'
	ld e,a			;4	;temporarily hold x[i]
	sub d			;4
	sub 4			;7
	exx			;4	;rs
	
	ld hl,-14		;10	;reset stack
	dw outlo		;12__64
	
	exx			;4	;rs'
	
	sra a			;8
	sra a			;8	;y[i] = 0.25*(y[i-1]+x[i]-x[i-1])
	
	ld e,d			;4	;preserve x[i]
	exx			;4	;rs
	
	
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	ld a,(hl)		;7	;timing
	jr _x			;12	;timing
_x	ds 2			;8
	jp (hl)			;4	;jump to next core
				;192
;*******************************************************************************
	org 256*(1+(HIGH($)))
	
core10S
	dw outhi		;12__
	ld h,#ff		;7
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	exx			;4	;rs
	
	dw outlo		;12__160
	
	jr _x			;12
_x	ds 2			;8	
	;------------------	;192
				
	dw outhi		;12__
	
	exx			;4	;rs'
	pop bc			;10
	ld c,h			;4	
	ld a,(bc)		;7
	ld (_shift2),de		;20
	exx			;4	;rs
	
	add a,l			;4	;add sample values

	sub 10			;7
	sra a			;8
_shift2
	ds 2			;8
	add a,10		;7
	
		;ld hl,-14		;10	;reset stack ;TODO WARN unverified
	ld l,-14		;7
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	ret c			;5	;timing
	
	ex af,af'		;4	;update timer
	dec a			;4
	
	jp z,updateTimerHS0	;10
	dw outlo		;12__160
	
	ex af,af'		;4
	
	jr _y			;12
_y	jp (hl)			;4	;jump to next core
				;192 -2
				
	
	org 256*(HIGH($)) + #b0
coreN3hs
	dw outhi		;12__
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	ld a,(hl)		;7	;timing
	nop			;4
	dw outlo		;12__48
	
	inc de			;6	;timing
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	
	exx			;4	;rs

	;------------------	;192
				
	dw outhi		;12__
	
	exx			;4	;rs'
	ld c,h			;4
	ld a,(bc)		;7
	ld a,(bc)		;7	;timing
	inc bc			;6	;timing
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	dw outlo		;12__48
	
	exx			;4	;rs'
	ld e,a			;4	;temporarily hold x[i]
	
	sub d			;4
	sub 3			;7
	sra a			;8
	sra a			;8	;y[i] = 0.25*(y[i-1]+x[i]-x[i-1])
	
	ld e,d			;4	;preserve x[i]
	exx			;4	;rs
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	ld a,(hl)		;7	;timing
	ld a,(hl)		;7	;timing
	nop			;4
	jp (hl)			;4	;jump to next core
				;192
;*******************************************************************************
	org 256*(1+(HIGH($)))
	
core11S
	dw outhi		;12__
	ld a,(hl)		;7	;timing
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	exx			;4	;rs
	
	jr _x			;12
_x	nop			;4
	dw outlo		;12__176
	
	nop			;4	
	;------------------	;192
				
	dw outhi		;12__
	
	exx			;4	;rs'
	pop bc			;10
	ld c,h			;4	
	ld a,(bc)		;7
	ld (_shift2),de		;20
	exx			;4	;rs
	
	add a,l			;4	;add sample values

	sub 11			;7
	sra a			;8
_shift2
	ds 2			;8
	add a,11		;7

	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS0	;10
	ex af,af'		;4
	nop			;4
	jp _y			;10
_y	
	dw outlo		;12__176
	
	jp (hl)			;4	;jump to next core
				;192
				

	org 256*(HIGH($)) + #b0
coreN2hs
	dw outhi		;12__
	inc de			;6	;timing
	nop			;4
	pop de			;10	;fetch ch1.basefreq
	dw outlo		;12__32
	
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	
	exx			;4	;rs
		
	ld a,(hl)		;7	;timing
	;------------------	;192
				
	dw outhi		;12__
	jr _x			;12	;timing
_x	ds 2			;8
	dw outlo		;12__32
	
	exx			;4	;rs'
	ld c,h			;4
	ld a,(bc)		;7
	
	exx			;4	;rs
	add a,l			;4	;add sample values
	exx			;4	;rs'
	
	ld e,a			;4	;temporarily hold x[i]
	
	sub d			;4
	sub 2			;7
	sra a			;8
	sra a			;8	;y[i] = 0.25*(y[i-1]+x[i]-x[i-1])
	
	ld e,d			;4	;preserve x[i]
	exx			;4	;rs
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	ld a,(hl)		;7
	nop			;4
	jp (hl)			;4	;jump to next core
				;192
;*******************************************************************************
	org 256*(1+(HIGH($)))
	
core12S
	dw outhi		;12__
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4	
	ld a,(bc)		;7
	ld (_shift2),de		;20
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	
	sub 12			;7
	sra a			;8
_shift2
	ds 2			;8
	add a,12		;7
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	
	ld r,a			;9	;timing
	jp (hl)			;4	;jump to next core
				;384
				

	org 256*(HIGH($)) + #b0
coreN1hs
	dw outhi		;12__
	nop			;4
	dw outlo		;12__16
	
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	exx			;4	;rs
	
	ld r,a			;9	;timing
	;------------------	;192
				
	dw outhi		;12
	nop			;4
	dw outlo		;12
	
	exx			;4	;rs'
	
	ld a,(bc)		;7
	
	exx			;4	;rs
	add a,l			;4	;add sample values
	exx			;4	;rs'
	
	ld e,a			;4	;temporarily hold x[i]
	
	sub d			;4
	sub 1			;7
	sra a			;8
	sra a			;8	;y[i] = 0.25*(y[i-1]+x[i]-x[i-1])
	
	ld e,d			;4	;preserve x[i]
	exx			;4	;rs
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	ld a,(hl)		;7	;timing
	jr _x			;12
_x	jr _y			;12
_y	jp (hl)			;4	;jump to next core
				;192
;*******************************************************************************
;*******************************************************************************
;*******************************************************************************
IF (LOW($))!=0
	org 256*(1+(HIGH($)))
ENDIF
core0						;volume 0, 0t
basec equ HIGH($)

	dw outlo		;12__
	pop de			;10	;base freq 1
	add ix,de		;15
	pop de			;10	;duty/vol ch1
	ld a,ixh		;8
	cp d			;4	;duty
	sbc a,a			;4
	and e			;4	;volume	
	ld h,a			;4	;preserve v.ch1
	
	pop de			;10	;base freq 2
	add iy,de		;15
	ld a,iyh		;8
	pop de			;10
	
	cp d			;4
	sbc a,a			;4
	and e			;4
	
	add a,h			;4
	
	exx			;4
	rra			;4	;pre-shift buffer to make sure it's <=4
	ld (de),a		;7	;save in verb buffer
	rla			;4
	add a,(hl)		;7	;add reverb buffer
	exx			;4
	
		
	pop hl			;10	;filter amount, dw 0 or dw #2fcb
	ld (_shift2),hl		;16	
	;-------------------	
	
	
	sra a			;8
_shift2
	dw 0			;8
	
	
	exx			;4	
	inc e			;4	
	inc l			;4
	
	exx			;4
	
	ld hl,-12		;10	;value for resetting sp	
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;jump base (determines lp/no filt)
	
	add a,h			;4
	ld h,a			;4
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ld a,(hl)		;7	;timing
	ds 3			;12			
	
	jp (hl)			;4
				;192*2
				
				
	org 256*(HIGH($))+#50

core0n						;volume 0, 0t

	dw outlo		;12__
	pop de			;10	;base freq 1
	add ix,de		;15
	pop de			;10	;duty/vol ch1
	ld a,ixh		;8
	cp d			;4	;duty
	sbc a,a			;4
	and e			;4	;volume	
	ld h,a			;4	;preserve v.ch1
	
	pop de			;10	;base freq 2
	add iy,de		;15
	ld a,iyh		;8
	rlca			;4
	ld iyh,a		;8
	pop de			;10
	
	cp d			;4
	sbc a,a			;4
	and e			;4
	
	add a,h			;4
	
	exx			;4
	rra			;4	;pre-shift buffer to make sure it's <=4
	ld (de),a		;7	;save in verb buffer
	rla			;4
	add a,(hl)		;7	;add reverb buffer
	exx			;4
	
		
	pop hl			;10	;filter amount, dw 0 or dw #2fcb
	ld (_shift2),hl		;16	
	;-------------------	
	
	
	sra a			;8
_shift2
	dw 0			;8
	
	
	exx			;4	
	inc e			;4	
	inc l			;4
	
	exx			;4
	
	ld hl,-12		;10	;value for resetting sp	
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;jump base (determines lp/no filt)
	
	add a,h			;4
	ld h,a			;4
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ld a,(hl)		;7	;timing			
	
	jp (hl)			;4
				;192*2


	org 256*(HIGH($)) + #b0
core0hs
	dw outlo		;12__
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4	
	ld a,(bc)		;7
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	
	exx			;4	;rs'
	ld e,a			;4	;temporarily hold x[i]
	sub d			;4
	add a,0			;7
	sra a			;8
	sra a			;8	;y[i] = 0.25*(y[i-1]+x[i]-x[i-1])
	ld e,d			;4	;preserve x[i]
	exx			;4	;rs
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	jr _x			;12
_x	nop
	
	jp (hl)			;4	;jump to next core
				;384

;*******************************************************************************
	org 256*(1+(HIGH($)))			;volume 1, 16t
core1
	dw outhi		;12__
	nop			;4
	dw outlo		;12_16
	
	pop de			;10	;base freq 1
	add ix,de		;15
	pop de			;10	;duty/vol ch1
	ld a,ixh		;8
	cp d			;4	;duty
	sbc a,a			;4
	and e			;4	;volume
	
	ld h,a			;4	;preserve v.ch1

	pop de			;10	;base freq 2
	add iy,de		;15
	pop de			;10
	ld a,iyh		;8
	cp d			;4
	sbc a,a			;4
	and e			;4
	
	add a,h			;4
	
	exx			;4
	rra			;4	;pre-shift buffer to make sure it's <=4
	ld (de),a		;7	;save in verb buffer
	inc e			;4
	rla			;4
	add a,(hl)		;7	;add reverb buffer
	exx			;4
	
	dec a			;4
	sra a			;8
	;-------------------	;192
	
	dw outhi		;12__
	nop			;4
	dw outlo		;12_16
	
	pop hl			;10	;filter amount, dw 0 or dw #2fcb
	ld (_shift2),hl		;16
	
	exx			;4

_shift2
	dw 0			;8	;
	inc a			;4	;y[i] = y[i-1] + alpha*(x[i]-y[i])		

	
	inc l			;4
	
	exx			;4
	
	ld hl,-12		;10	;reset sp
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;jump base (determines lp/no filt)
	
	add a,h			;4
	ld h,a			;4
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	
	ld a,(hl)		;7	;timing
	ld a,(hl)		;7	;timing
	ld a,(hl)		;7	;timing
	ld a,(hl)		;7	;timing
	ld a,(hl)		;7	;timing
	ds 2			;8

	jp (hl)			;4
				;192
				
	org 256*(HIGH($))+#50			;volume 1, 16t
core1n
	dw outhi		;12__
	nop			;4
	dw outlo		;12_16
	
	pop de			;10	;base freq 1
	add ix,de		;15
	pop de			;10	;duty/vol ch1
	ld a,ixh		;8
	cp d			;4	;duty
	sbc a,a			;4
	and e			;4	;volume
	
	ld h,a			;4	;preserve v.ch1

	pop de			;10	;base freq 2
	add iy,de		;15
	pop de			;10
	ld a,iyh		;8
	rlca			;4
	ld iyh,a		;8
	cp d			;4
	sbc a,a			;4
	and e			;4
	
	add a,h			;4
	
	exx			;4
	rra			;4	;pre-shift buffer to make sure it's <=4
	ld (de),a		;7	;save in verb buffer
	inc e			;4
	rla			;4
	add a,(hl)		;7	;add reverb buffer
	exx			;4
	
	;-------------------	;192
	
	dw outhi		;12__
	dec a			;4
	dw outlo		;12_16
	
	sra a			;8
	
	pop hl			;10	;filter amount, dw 0 or dw #2fcb
	ld (_shift2),hl		;16
	
	exx			;4

_shift2
	dw 0			;8	;
	inc a			;4	;y[i] = y[i-1] + alpha*(x[i]-y[i])		

	
	inc l			;4
	
	exx			;4
	
	ld hl,-12		;10	;reset sp
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;jump base (determines lp/no filt)
	
	add a,h			;4
	ld h,a			;4
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	
	ld a,(hl)		;7	;timing
	ld a,(hl)		;7	;timing
	ld a,(hl)		;7	;timing
	ld a,(hl)		;7	;timing
	ld a,(hl)		;7	;timing

	jp (hl)			;4
				;192

	org 256*(HIGH($)) + #b0
core1hs
	dw outhi		;12__
	nop			;4
	dw outlo		;12__16
	
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	exx			;4	;rs
	
	ld r,a			;9	;timing
	;------------------	;192
				
	dw outhi		;12
	nop			;4
	dw outlo		;12
	
	exx			;4	;rs'
	
	ld a,(bc)		;7
	
	exx			;4	;rs
	add a,l			;4	;add sample values
	exx			;4	;rs'
	
	ld e,a			;4	;temporarily hold x[i]
	
	sub d			;4
	add a,1			;7
	sra a			;8
	sra a			;8	;y[i] = 0.25*(y[i-1]+x[i]-x[i-1])
	
	ld e,d			;4	;preserve x[i]
	exx			;4	;rs
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	ld a,(hl)		;7	;timing
	jr _x			;12
_x	jr _y			;12
_y	jp (hl)			;4	;jump to next core
				;192
	
	
				
;*******************************************************************************
	org 256*(1+(HIGH($)))			;volume 2, 32t
core2
	dw outhi		;12__
	pop de			;10	;base freq 1
	jp _x			;10
_x	dw outlo		;12__32
		
	add ix,de		;15
	pop de			;10	;duty/vol ch1
	ld a,ixh		;8
	cp d			;4	;duty
	sbc a,a			;4
	and e			;4	;volume
	
	ld h,a			;4	;preserve v.ch1

	pop de			;10	;base freq 2
	add iy,de		;15
	pop de			;10
	ld a,iyh		;8
	cp d			;4
	sbc a,a			;4
	and e			;4
	
	add a,h			;4
	exx			;4
	rra			;4
	ld (de),a		;7
	rla			;4
	add a,(hl)		;7	;add reverb buffer
	exx			;4
	
	pop hl			;10	;filter amount, dw 0 or dw #2fcb
	;-------------------	;192
	
	dw outhi		;12__
	ret c			;5	;timing, carry reset from prev. add a,h
	sub 2			;7
	sra a			;8
	dw outlo		;12_32
	
	ld (_shift2),hl		;16
	ld hl,-12		;10	;value for resetting sp	

_shift2
	dw 0			;8	;
	add a,2			;7	;y[i] = y[i-1] + alpha*(x[i]-y[i])		

	exx			;4
	
	inc e			;4
	
	inc l			;4
	
	exx			;4
	
	
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;jump base (determines lp/no filt)
	
	add a,h			;4
	ld h,a			;4
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	
	ld a,(hl)		;7	;timing
	ld a,(hl)		;7	;timing
	ds 4			;16
	jp (hl)			;4
				;192
				
				
	org 256*(HIGH($))+#50			;volume 2, 32t
core2n
	dw outhi		;12__
	pop de			;10	;base freq 1
	jp _x			;10
_x	dw outlo		;12__32
		
	add ix,de		;15
	pop de			;10	;duty/vol ch1
	ld a,ixh		;8
	cp d			;4	;duty
	sbc a,a			;4
	and e			;4	;volume
	
	ld h,a			;4	;preserve v.ch1

	pop de			;10	;base freq 2
	add iy,de		;15
	pop de			;10
	ld a,iyh		;8
	rlca			;4
	ld iyh,a		;8
	cp d			;4
	sbc a,a			;4
	and e			;4
	
	add a,h			;4
	ret c			;5	;timing
	exx			;4
	rra			;4
	ld (de),a		;7
	rla			;4
	
	exx			;4
	
	;-------------------	;192
	
	dw outhi		;12__
	
	exx			;4
	add a,(hl)		;7	;add reverb buffer
	ret c			;5	;timing
	exx			;4
	dw outlo		;12_32 +10
	
	sub 2			;7
	sra a			;8
	
	pop hl			;10	;filter amount, dw 0 or dw #2fcb
	ld (_shift2),hl		;16

_shift2
	dw 0			;8	;
	add a,2			;7	;y[i] = y[i-1] + alpha*(x[i]-y[i])		

	exx			;4
	inc e			;4
	inc l			;4
	exx			;4
	
	ld hl,-12		;10	;value for resetting sp	
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;jump base (determines lp/no filt)
	
	add a,h			;4
	ld h,a			;4
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	
	ret c			;5	;timing

	jp (hl)			;4
				;192


	org 256*(HIGH($)) + #b0
core2hs
	dw outhi		;12__
	inc de			;6	;timing
	nop			;4
	pop de			;10	;fetch ch1.basefreq
	dw outlo		;12__32
	
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	
	exx			;4	;rs
		
	ld a,(hl)		;7	;timing
	;------------------	;192
				
	dw outhi		;12__
	jr _x			;12	;timing
_x	ds 2			;8
	dw outlo		;12__32
	
	exx			;4	;rs'
	ld c,h			;4
	ld a,(bc)		;7
	
	exx			;4	;rs
	add a,l			;4	;add sample values
	exx			;4	;rs'
	
	ld e,a			;4	;temporarily hold x[i]
	
	sub d			;4
	add a,2			;7
	sra a			;8
	sra a			;8	;y[i] = 0.25*(y[i-1]+x[i]-x[i-1])
	
	ld e,d			;4	;preserve x[i]
	exx			;4	;rs
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	ld a,(hl)		;7
	nop			;4
	jp (hl)			;4	;jump to next core
				;192
	
	
				
;*******************************************************************************
	org 256*(1+(HIGH($)))			;volume 3, 48t
core3
	dw outhi		;12__
	pop de			;10	;base freq 1
	add ix,de		;15
	ld a,(hl)		;7	;timing
	nop			;4
	dw outlo		;12__48
	
	pop de			;10	;duty/vol ch1
	ld a,ixh		;8
	cp d			;4	;duty
	sbc a,a			;4
	and e			;4	;volume
	
	ld h,a			;4	;preserve v.ch1

	pop de			;10	;base freq 2
	add iy,de		;15
	pop de			;10
	ld a,iyh		;8
	cp d			;4
	sbc a,a			;4
	and e			;4
	
	add a,h			;4
	
	exx			;4
	rra			;4
	ld (de),a		;7
	rla			;4
	add a,(hl)		;7	;add reverb buffer
	exx			;4
	
	ld r,a			;9	;timing
	;-------------------	;192
	
	dw outhi		;12__
	
	ret c			;5	;timing
	sub 3			;7
	sra a			;8
	
	exx			;4
	inc e			;4	
	inc l			;4	
	exx			;4

	dw outlo		;12_48
	
	pop hl			;10	;filter amount, dw 0 or dw #2fcb
	ld (_shift2),hl		;16
	
_shift2
	dw 0			;8
	add a,3			;7	;y[i] = y[i-1] + alpha*(x[i]-y[i])
	
	ld hl,-12		;10	;value for resetting sp
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;jump base (determines lp/no filt)
	
	add a,h			;4
	ld h,a			;4
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	
	ds 5			;20
	jp (hl)			;4
				;192


	org 256*(HIGH($))+#50			;volume 3, 48t
core3n
	dw outhi		;12__
	pop de			;10	;base freq 1
	add ix,de		;15
	ld a,(hl)		;7	;timing
	nop			;4
	dw outlo		;12__48
	
	pop de			;10	;duty/vol ch1
	ld a,ixh		;8
	cp d			;4	;duty
	sbc a,a			;4
	and e			;4	;volume
	
	ld h,a			;4	;preserve v.ch1

	pop de			;10	;base freq 2
	add iy,de		;15
	pop de			;10
	ld a,iyh		;8
	rlca			;4
	ld iyh,a		;8
	cp d			;4
	sbc a,a			;4
	and e			;4
	
	add a,h			;4
	
	exx			;4
	rra			;4
	ld (de),a		;7
	rla			;4
	exx			;4
	nop			;4	
	;-------------------	;192
	
	dw outhi		;12__
	
	exx			;4
	add a,(hl)		;7	;add reverb buffer
	inc e			;4	
	inc l			;4
	exx			;4
	
	sub 3			;7
	
	inc hl			;6	;timing
	dw outlo		;12_48
	
	pop hl			;10	;filter amount, dw 0 or dw #2fcb
	ld (_shift2),hl		;16
	
	sra a			;8
_shift2
	dw 0			;8
	add a,3			;7	;y[i] = y[i-1] + alpha*(x[i]-y[i])
	
	ld hl,-12		;10	;value for resetting sp
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;jump base (determines lp/no filt)
	
	add a,h			;4
	ld h,a			;4
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	
	jr _x			;12
_x	jp (hl)			;4
				;192


	org 256*(HIGH($)) + #b0
core3hs
	dw outhi		;12__
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	ld a,(hl)		;7	;timing
	nop			;4
	dw outlo		;12__48
	
	inc de			;6	;timing
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	
	exx			;4	;rs

	;------------------	;192
				
	dw outhi		;12__
	
	exx			;4	;rs'
	ld c,h			;4
	ld a,(bc)		;7
	ld a,(bc)		;7	;timing
	inc bc			;6	;timing
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	dw outlo		;12__48
	
	exx			;4	;rs'
	ld e,a			;4	;temporarily hold x[i]
	
	sub d			;4
	add a,3			;7
	sra a			;8
	sra a			;8	;y[i] = 0.25*(y[i-1]+x[i]-x[i-1])
	
	ld e,d			;4	;preserve x[i]
	exx			;4	;rs
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	ld a,(hl)		;7	;timing
	ld a,(hl)		;7	;timing
	nop			;4
	jp (hl)			;4	;jump to next core
				;192
	
;*******************************************************************************
	org 256*(1+(HIGH($)))			;volume 4, 64t
core4
	dw outhi		;12__
	pop de			;10	;base freq 1
	add ix,de		;15
	pop de			;10	;duty/vol ch1
	ld a,ixh		;8
	ld r,a			;9	;timing
	dw outlo		;12__64
	
	cp d			;4	;duty
	sbc a,a			;4
	and e			;4	;volume
	
	ld h,a			;4	;preserve v.ch1

	pop de			;10	;base freq 2
	add iy,de		;15
	pop de			;10
	ld a,iyh		;8
	cp d			;4
	sbc a,a			;4
	and e			;4
	
	add a,h			;4
	exx			;4
	rra			;4
	ld (de),a		;7
	rla			;4
	add a,(hl)		;7	;add reverb buffer
	exx			;4
	sub 4			;7
	
	nop			;4
	;-------------------	;192
	
	dw outhi		;12__
	sra a			;8
	
	pop hl			;10	;filter amount, dw 0 or dw #2fcb
	ld (_shift2),hl		;16
		
_shift2
	dw 0			;8
	
	jp _y			;10
_y	dw outlo		;12_64

	add a,4			;7	;y[i] = y[i-1] + alpha*(x[i]-y[i])
	
	exx			;4
	inc e			;4	
	inc l			;4
	exx			;4	
			
	ld hl,-12		;10	;value for resetting sp
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;jump base (determines lp/no filt)
	
	add a,h			;4
	ld h,a			;4
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	
	ld a,(hl)		;7
	ld a,(hl)		;7
	ds 2			;8
	jp (hl)			;4
				;192
				
	org 256*(HIGH($))+#50			;volume 4, 64t
core4n
	dw outhi		;12__
	pop de			;10	;base freq 1
	add ix,de		;15
	pop de			;10	;duty/vol ch1
	ld a,ixh		;8
	ld r,a			;9	;timing
	dw outlo		;12__64
	
	cp d			;4	;duty
	sbc a,a			;4
	and e			;4	;volume
	
	ld h,a			;4	;preserve v.ch1

	inc de			;6	;timing
	pop de			;10	;base freq 2
	add iy,de		;15
	pop de			;10
	ld a,iyh		;8
	rlca			;4
	ld iyh,a		;8
	cp d			;4
	sbc a,a			;4
	and e			;4
	
	add a,h			;4
	exx			;4
	rra			;4
	ld (de),a		;7
	rla			;4	
	exx			;4
	
	;-------------------	;192
	
	dw outhi		;12__
	exx			;4
	add a,(hl)		;7	;add reverb buffer
	exx			;4
	
	pop hl			;10	;filter amount, dw 0 or dw #2fcb
	ld (_shift2),hl		;16

	
	sub 4			;7
	nop			;4
	
	dw outlo		;12_64
	
	sra a			;8
		
_shift2
	dw 0			;8
	add a,4			;7	;y[i] = y[i-1] + alpha*(x[i]-y[i])
	
	exx			;4
	inc e			;4	
	inc l			;4
	exx			;4	
			
	ld hl,-12		;10	;value for resetting sp
	add hl,sp		;11
	ld sp,hl		;6
	
	inc hl			;6	;timing
	pop hl			;10	;jump base (determines lp/no filt)
	
	add a,h			;4
	ld h,a			;4
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4

	jp (hl)			;4
				;192 +16

				
	org 256*(HIGH($)) + #b0
core4hs
	dw outhi		;12__
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	
	ld r,a			;9	;timing
	dw outlo		;12__64
		
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	
	exx			;4	;rs
	nop			;4
	;------------------	;192
				
	dw outhi		;12__
	
	exx			;4	;rs'	
	ld a,(bc)		;7
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	
	exx			;4	;rs'
	ld e,a			;4	;temporarily hold x[i]
	sub d			;4
	add a,4			;7
	exx			;4	;rs
	
	ld hl,-14		;10	;reset stack
	dw outlo		;12__64
	
	exx			;4	;rs'
	
	sra a			;8
	sra a			;8	;y[i] = 0.25*(y[i-1]+x[i]-x[i-1])
	
	ld e,d			;4	;preserve x[i]
	exx			;4	;rs
	
	
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	ld a,(hl)		;7	;timing
	jr _x			;12	;timing
_x	ds 2			;8
	jp (hl)			;4	;jump to next core
				;192

;*******************************************************************************
	org 256*(1+(HIGH($)))			;volume 5, 80t
core5
	dw outhi		;12__
	pop de			;10	;base freq 1
	add ix,de		;15
	pop de			;10	;duty/vol ch1
	ld a,ixh		;8
	cp d			;4	;duty
	sbc a,a			;4
	and e			;4	;volume	
	ld h,a			;4	;preserve v.ch1
	
	ld r,a			;9	;timing
	dw outlo		;12__80

	pop de			;10	;base freq 2
	add iy,de		;15
	pop de			;10
	ld a,iyh		;8
	cp d			;4
	sbc a,a			;4
	and e			;4
	
	add a,h			;4
	exx			;4
	rra			;4
	ld (de),a		;7
	rla			;4
	add a,(hl)		;7	;add reverb buffer
	exx			;4
	
	sub 5			;7
	
	nop			;4
	;-------------------	;192
	
	dw outhi		;12__
	pop hl			;10	;filter amount, dw 0 or dw #2fcb
	ld (_shift2),hl		;16

	sra a			;8	
_shift2
	dw 0			;8
		
	exx			;4
	inc e			;4
	inc l			;4
	exx			;4
	
	ld hl,-12		;10	;value for resetting sp					
	dw outlo		;12_80
	
	add a,5			;7	;y[i] = y[i-1] + alpha*(x[i]-y[i])
		
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;jump base (determines lp/no filt)
	
	add a,h			;4
	ld h,a			;4
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	
	jr _x			;12
_x	jr _y			;12
_y	ds 2			;8
	jp (hl)			;4
				;192
				
	org 256*(HIGH($))+#50			;volume 5, 80t
core5n
	dw outhi		;12__
	pop de			;10	;base freq 1
	add ix,de		;15
	pop de			;10	;duty/vol ch1
	ld a,ixh		;8
	cp d			;4	;duty
	sbc a,a			;4
	and e			;4	;volume	
	ld h,a			;4	;preserve v.ch1
	
	ld r,a			;9	;timing
	dw outlo		;12__80

	pop de			;10	;base freq 2
	add iy,de		;15
	pop de			;10
	ld a,iyh		;8
	rlca			;4
	ld iyh,a		;8
	cp d			;4
	sbc a,a			;4
	and e			;4
	
	add a,h			;4
	
	pop hl			;10	;filter amount, dw 0 or dw #2fcb
	exx			;4
	rra			;4
	ld (de),a		;7
	exx			;4
	
	;-------------------	;192 -19
	
	dw outhi		;12__
	
	ld (_shift2),hl		;16
	
	exx			;4
	rla			;4
	add a,(hl)		;7	;add reverb buffer
	inc e			;4
	inc l			;4
	exx			;4
	
	sub 5			;7	
	sra a			;8	

	ld hl,-12		;10	;value for resetting sp					
	dw outlo		;12_80

_shift2
	dw 0			;8	
	add a,5			;7	;y[i] = y[i-1] + alpha*(x[i]-y[i])
		
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;jump base (determines lp/no filt)
	
	add a,h			;4
	ld h,a			;4
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	
	jr _x			;12
_x	jr _y			;12
_y	jp (hl)			;4
				;192


	org 256*(HIGH($)) + #b0
core5hs
	dw outhi		;12__
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	nop			;4
	dw outlo		;12__80
		
	
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	
	exx			;4	;rs
	ld r,a			;9	;timing
	;------------------	;192
				
	dw outhi		;12__
	
	exx			;4	;rs'	
	ld a,(bc)		;7
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	
	exx			;4	;rs'
	ld e,a			;4	;temporarily hold x[i]
	sub d			;4
	add a,5			;7
	sra a			;8
	sra a			;8	;y[i] = 0.25*(y[i-1]+x[i]-x[i-1])
	exx			;4	;rs
	
	ld hl,-14		;10	;reset stack
	dw outlo		;12__80
	
	exx			;4	;rs'
	ld e,d			;4	;preserve x[i]
	exx			;4	;rs
	
	
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	ld a,(hl)		;7	;timing
	jr _x			;12	;timing
_x	ds 2			;8
	jp (hl)			;4	;jump to next core
				;192
				
;*******************************************************************************
	org 256*(1+(HIGH($)))			;volume 6, 96t
core6
	dw outhi		;12__
	pop de			;10	;base freq 1
	add ix,de		;15
	pop de			;10	;duty/vol ch1
	ld a,ixh		;8
	cp d			;4	;duty
	sbc a,a			;4
	and e			;4	;volume	
	ld h,a			;4	;preserve v.ch1
	
	pop de			;10	;base freq 2
	add iy,de		;15

	dw outlo		;12__96
	
	pop de			;10
	ld a,iyh		;8
	cp d			;4
	sbc a,a			;4
	and e			;4
	
	add a,h			;4
	exx			;4
	rra			;4
	ld (de),a		;7
	rla			;4
	add a,(hl)		;7	;add reverb buffer
	ret c			;5	;timing
	exx			;4
	
	sub 6			;7
	
	sra a			;8
	;-------------------	;192
	
	dw outhi		;12__
	pop hl			;10	;filter amount, dw 0 or dw #2fcb
	ld (_shift2),hl		;16
_shift2
	dw 0			;8
	add a,6			;7	;y[i] = y[i-1] + alpha*(x[i]-y[i])
	
	exx			;4
	inc e			;4
	inc l			;4	
	exx			;4
	
	ld hl,-12		;10	;value for resetting sp
	add hl,sp		;11
	ld sp,hl		;6
						
	dw outlo		;12_96
		
	pop hl			;10	;jump base (determines lp/no filt)
	
	add a,h			;4
	ld h,a			;4
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	
	jr _x			;12
_x	jr _y			;12
_y	jr _z			;12
_z	nop			;4
	
	jp (hl)			;4
				;192
				
	org 256*(HIGH($))+#50			;volume 6, 96t
core6n
	dw outhi		;12__
	pop de			;10	;base freq 1
	add ix,de		;15
	pop de			;10	;duty/vol ch1
	ld a,ixh		;8
	cp d			;4	;duty
	sbc a,a			;4
	and e			;4	;volume	
	ld h,a			;4	;preserve v.ch1
	
	pop de			;10	;base freq 2
	add iy,de		;15

	dw outlo		;12__96
	
	pop de			;10
	ld a,iyh		;8
	rlca			;4
	ld iyh,a		;8
	cp d			;4
	sbc a,a			;4
	and e			;4
	
	add a,h			;4
	exx			;4
	rra			;4
	ld (de),a		;7
	rla			;4
	add a,(hl)		;7	;add reverb buffer
	inc e			;4
	inc l			;4
	exx			;4
	
	;-------------------	;192
	
	dw outhi		;12__
	pop hl			;10	;filter amount, dw 0 or dw #2fcb
	ld (_shift2),hl		;16
	
	sub 6			;7
	sra a			;8
_shift2
	dw 0			;8
	add a,6			;7	;y[i] = y[i-1] + alpha*(x[i]-y[i])
	
	ld h,(hl)		;7	;timing
	ld hl,-12		;10	;value for resetting sp
	add hl,sp		;11
					
	dw outlo		;12_96
	
	ld sp,hl		;6	
	pop hl			;10	;jump base (determines lp/no filt)
	
	add a,h			;4
	ld h,a			;4
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	
	jr _x			;12
_x	jr _y			;12
_y	jp _z			;10
_z	jp (hl)			;4
				;192


	org 256*(HIGH($)) + #b0
core6hs
	dw outhi		;12__
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	
	pop de			;10	;same as above for ch2
	add iy,de		;15

	ld r,a			;9	;timing
	dw outlo		;12__96
	
	ld l,a			;4	;preserve value	

	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	
	exx			;4	;rs
	nop			;4
	;------------------	;192
				
	dw outhi		;12__
	
	exx			;4	;rs'	
	ld a,(bc)		;7
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	
	exx			;4	;rs'
	ld e,a			;4	;temporarily hold x[i]
	sub d			;4
	add a,6			;7
	sra a			;8
	sra a			;8	;y[i] = 0.25*(y[i-1]+x[i]-x[i-1])
	ld e,d			;4	;preserve x[i]
	exx			;4	;rs
	
	ld hl,-14		;10	;reset stack
	
	jr _x			;12	;timing
_x	dw outlo		;12__96	
	
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	ld a,(hl)		;7	;timing
	jr _y			;12
_y	nop			;4
	jp (hl)			;4	;jump to next core
				;192
				
;*******************************************************************************
	org 256*(1+(HIGH($)))			;volume 7, 112t
core7
	dw outhi		;12__
	pop de			;10	;base freq 1
	add ix,de		;15
	pop de			;10	;duty/vol ch1
	ld a,ixh		;8
	cp d			;4	;duty
	sbc a,a			;4
	and e			;4	;volume	
	ld h,a			;4	;preserve v.ch1
	
	pop de			;10	;base freq 2
	add iy,de		;15
	ld a,iyh		;8
	ds 2			;8
	
	dw outlo		;12__112
	
	pop de			;10
	
	cp d			;4
	sbc a,a			;4
	and e			;4
	
	add a,h			;4
	exx			;4
	rra			;4
	ld (de),a		;7
	rla			;4
	add a,(hl)		;7	;add reverb buffer
	ret c			;5	;timing
	exx			;4
	
	sub 7			;7

	;-------------------	;192
	
	dw outhi		;12__
	pop hl			;10	;filter amount, dw 0 or dw #2fcb
	ld (_shift2),hl		;16
	
	sra a			;8
_shift2
	dw 0			;8
	add a,7			;7	;y[i] = y[i-1] + alpha*(x[i]-y[i])
	
	exx			;4
	inc e			;4
	inc l			;4	
	exx			;4
	
	ld hl,-12		;10	;value for resetting sp	
	add hl,sp		;11
	ld sp,hl		;6
	
	ds 2			;8			
	dw outlo		;12_112

	pop hl			;10	;jump base (determines lp/no filt)
	
	add a,h			;4
	ld h,a			;4
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	
	jr _x			;12
_x	jr _y			;12	
_y	jp (hl)			;4
				;192
				
				
	org 256*(HIGH($))+#50			;volume 7, 112t
core7n
	dw outhi		;12__
	pop de			;10	;base freq 1
	add ix,de		;15
	pop de			;10	;duty/vol ch1
	ld a,ixh		;8
	cp d			;4	;duty
	sbc a,a			;4
	and e			;4	;volume	
	ld h,a			;4	;preserve v.ch1
	
	pop de			;10	;base freq 2
	add iy,de		;15
	ld a,iyh		;8
	rlca			;4
	nop			;4
	
	dw outlo		;12__112
	
	ld iyh,a		;8
	pop de			;10
	
	cp d			;4
	sbc a,a			;4
	and e			;4
	
	add a,h			;4
	exx			;4
	rra			;4
	ld (de),a		;7
	rla			;4
	add a,(hl)		;7	;add reverb buffer
	exx			;4
	
	nop			;4
	;-------------------	;192
	
	dw outhi		;12__
	
	pop hl			;10	;filter amount, dw 0 or dw #2fcb
	ld (_shift2),hl		;16
	
	sub 7			;7
	sra a			;8
_shift2
	dw 0			;8
	add a,7			;7	;y[i] = y[i-1] + alpha*(x[i]-y[i])
	
	exx			;4
	inc e			;4
	inc l			;4	
	exx			;4
	
	ld h,(hl)		;7	;timing
	ld hl,-12		;10	;value for resetting sp	
	add hl,sp		;11
				
	dw outlo		;12_112

	ld sp,hl		;6
	pop hl			;10	;jump base (determines lp/no filt)
	
	add a,h			;4
	ld h,a			;4
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	
	ld a,(hl)		;7	;timing
	ld a,(hl)		;7	;timing
	nop			;4
	jp (hl)			;4
				;192

romNoise0
	exx
romNoise1
	ld b,7
romNoise
	ld a,(hl)		;7
	and #10			;7
	out (#fe),a		;11
	inc hl			;6
	djnz romNoise		;13/8 (303)
	
	ex (sp),hl		;19
	ex (sp),hl		;19
	ld a,(hl)		;7
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimerRN	;10
	ex af,af'		;4
	jr romNoise1		;12
				;382... -2, but there's no more bytes here
					

	org 256*(HIGH($)) + #b0
core7hs
	dw outhi		;12__
	ld a,(hl)		;7	;timing
	
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8

	dw outlo		;12__112
	
	ld l,a			;4	;preserve value	

	ld a,(de)		;7
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	
	inc bc			;6	;timing
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	
	exx			;4	;rs
	;------------------	;192 -2
				
	dw outhi		;12__
	
	exx			;4	;rs'	
	ld a,(bc)		;7
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	
	exx			;4	;rs'
	ld e,a			;4	;temporarily hold x[i]
	sub d			;4
	add a,7			;7
	sra a			;8
	sra a			;8	;y[i] = 0.25*(y[i-1]+x[i]-x[i-1])
	ld e,d			;4	;preserve x[i]
	exx			;4	;rs
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	ld h,(hl)		;7	;timing
	nop			;4
	dw outlo		;12__112
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	jr _y			;12
_y	jr _z			;12
_z	jp (hl)			;4	;jump to next core
				;192
				
;*******************************************************************************
	org 256*(1+(HIGH($)))			;volume 8, 128t
core8
	dw outhi		;12__
	pop de			;10	;base freq 1
	add ix,de		;15
	pop de			;10	;duty/vol ch1
	ld a,ixh		;8
	cp d			;4	;duty
	sbc a,a			;4
	and e			;4	;volume	
	ld h,a			;4	;preserve v.ch1
	
	pop de			;10	;base freq 2
	add iy,de		;15
	ld a,iyh		;8
	pop de			;10
	
	cp d			;4
	
	jp _x			;10	;timing
_x	dw outlo		;12__128
	
	sbc a,a			;4
	and e			;4
	
	add a,h			;4
	exx			;4
	rra			;4
	ld (de),a		;7
	rla			;4
	add a,(hl)		;7	;add reverb buffer
	exx			;4
	
	jp _y			;10
_y	;-------------------	;192
	
	dw outhi		;12__
	
	pop hl			;10	;filter amount, dw 0 or dw #2fcb
	ld (_shift2),hl		;16
	
	sub 8			;7
	sra a			;8
_shift2
	dw 0			;8
	add a,8			;7	;y[i] = y[i-1] + alpha*(x[i]-y[i])
	
	exx			;4
	inc e			;4
	inc l			;4	
	exx			;4
	
	ld hl,-12		;10	;value for resetting sp	
	add hl,sp		;11
	ld sp,hl		;6
	
	ld h,(hl)		;7	;timing
	jp _z			;10			
_z	dw outlo		;12_128

	pop hl			;10	;jump base (determines lp/no filt)
	
	add a,h			;4
	ld h,a			;4
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	
	ds 2			;8
	jp (hl)			;4
				;192 .


	org 256*(HIGH($))+#50			;volume 8, 128t
core8n
	dw outhi		;12__
	pop de			;10	;base freq 1
	add ix,de		;15
	pop de			;10	;duty/vol ch1
	ld a,ixh		;8
	cp d			;4	;duty
	sbc a,a			;4
	and e			;4	;volume	
	ld h,a			;4	;preserve v.ch1
	
	pop de			;10	;base freq 2
	add iy,de		;15
	ld a,iyh		;8
	rlca			;4
	inc de			;6	;timing
	pop de			;10
	cp d			;4
	dw outlo		;12__128
		
	ld iyh,a		;8
	
	sbc a,a			;4
	and e			;4
	
	add a,h			;4
	exx			;4
	rra			;4
	ld (de),a		;7
	rla			;4
	exx			;4
	ld a,r			;9
	
	;-------------------	;192
	
	dw outhi		;12__
	
	exx			;4
	add a,(hl)		;7
	exx			;4
	
	pop hl			;10	;filter amount, dw 0 or dw #2fcb
	ld (_shift2),hl		;16
	
	sub 8			;7
	sra a			;8
_shift2
	dw 0			;8
	add a,8			;7	;y[i] = y[i-1] + alpha*(x[i]-y[i])
	

	
	ld hl,-12		;10	;value for resetting sp	
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;jump base (determines lp/no filt)
	add a,h			;4
	ld h,a			;4
	
	dw outlo		;12_128

	exx			;4
	inc e			;4
	inc l			;4	
	exx			;4
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	
	jp _z			;10
_z	jp (hl)			;4
				;192 .


updateTimerRN
	ex af,af'		;4
	ld a,i			;9
	dec a			;4
	jp z,readNextRow	;10
	ld i,a			;9
	jp romNoise1		;10


	org 256*(HIGH($)) + #b0
core8hs
	dw outhi		;12__
	
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	nop			;4
	dw outlo		;12__128
		
	exx			;4	;rs'
	
	inc bc			;6	;timing
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	
	ld a,(hl)		;7	;timing
	exx			;4	;rs
	;------------------	;192
				
	dw outhi		;12__
	
	exx			;4	;rs'
	ld c,h			;4	
	ld a,(bc)		;7
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	ret c			;5	;timing
	
	exx			;4	;rs'
	ld e,a			;4	;temporarily hold x[i]
	sub d			;4
	add a,8			;7
	sra a			;8
	sra a			;8	;y[i] = 0.25*(y[i-1]+x[i]-x[i-1])
	ld e,d			;4	;preserve x[i]
	exx			;4	;rs
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4

	dw outlo		;12__128
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	jr _y			;12
_y	ld a,(hl)		;7	;timing
	ld a,(hl)		;7	;timing
	jp (hl)			;4	;jump to next core
				;192
			
;*******************************************************************************
	org 256*(1+(HIGH($)))			;volume 9, 144t
core9
	dw outhi		;12__
	pop de			;10	;base freq 1
	add ix,de		;15
	pop de			;10	;duty/vol ch1
	ld a,ixh		;8
	cp d			;4	;duty
	sbc a,a			;4
	and e			;4	;volume	
	ld h,a			;4	;preserve v.ch1
	
	pop de			;10	;base freq 2
	add iy,de		;15
	ld a,iyh		;8
	pop de			;10
	
	cp d			;4
	sbc a,a			;4
	and e			;4
	
	add a,h			;4
	
	ld h,(hl)		;7	;timing
	ld h,(hl)		;7	;timing

	dw outlo		;12__144
	
	exx			;4
	rra			;4
	ld (de),a		;7
	rla			;4
	add a,(hl)		;7	;add reverb buffer
	exx			;4
	
	inc hl			;6	;timing
	;-------------------	;192
	
	dw outhi		;12__
	pop hl			;10	;filter amount, dw 0 or dw #2fcb
	ld (_shift2),hl		;16
	
	sub 9			;7
	sra a			;8
_shift2
	dw 0			;8
	add a,9			;7	;y[i] = y[i-1] + alpha*(x[i]-y[i])
	
	exx			;4
	inc e			;4
	inc l			;4	
	exx			;4
	
	ld hl,-12		;10	;value for resetting sp	
	add hl,sp		;11
	ld sp,hl		;6
	
	ld h,(hl)		;7	;timing
	pop hl			;10	;jump base (determines lp/no filt)
	
	add a,h			;4
	ld h,a			;4
	
	ex af,af'		;4
	dec a			;4
					
	dw outlo		;12_144	+4
	
	jp z,updateTimer	;10
	ex af,af'		;4
	
	ds 2			;8
	
	jp _y			;10	;timing
_y	jp (hl)			;4
				;192


	org 256*(HIGH($))+#50			;volume 9, 144t
core9n
	dw outhi		;12__
	pop de			;10	;base freq 1
	add ix,de		;15
	pop de			;10	;duty/vol ch1
	ld a,ixh		;8
	cp d			;4	;duty
	sbc a,a			;4
	and e			;4	;volume	
	ld h,a			;4	;preserve v.ch1
	
	pop de			;10	;base freq 2
	add iy,de		;15
	ld a,iyh		;8
	rlca			;4
	ld iyh,a		;8
	pop de			;10
	
	cp d			;4
	sbc a,a			;4
	and e			;4
	
	inc hl			;6	;timing
	dw outlo		;12__144
	
	add a,h			;4
	exx			;4
	rra			;4
	ld (de),a		;7
	rla			;4
	exx			;4
	
	ld r,a			;9	;timing
		
	;-------------------	;192
	
	dw outhi		;12__
	
	exx			;4
	add a,(hl)		;7
	exx			;4
	
	pop hl			;10	;filter amount, dw 0 or dw #2fcb
	ld (_shift2),hl		;16
	
	sub 9			;7
	sra a			;8
_shift2
	dw 0			;8
	add a,9			;7	;y[i] = y[i-1] + alpha*(x[i]-y[i])
	
	exx			;4
	inc e			;4
	inc l			;4	
	exx			;4
	
	ld hl,-12		;10	;value for resetting sp	
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;jump base (determines lp/no filt)
	
	add a,h			;4
	ld h,a			;4
				
	dw outlo		;12_144
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	
	jp _y			;10	;timing
_y	jp (hl)			;4
				;192
				
				
	org 256*(HIGH($)) + #b0
core9hs
	dw outhi		;12__
	
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	
	add a,l			;4	;add sample values
	
	exx			;4	;rs'
	inc bc			;6	;timing
	pop bc			;10	;same as above for ch3
	exx			;4	;rs
	
	dw outlo		;12__144
			
	exx			;4	;rs'		
	add hl,bc		;11
	pop bc			;10	
	exx			;4	;rs
	ld c,#fe		;7	;timing
	;------------------	;192
				
	dw outhi		;12__
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	ld c,h			;4	
	ld a,(bc)		;7
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	ret c			;5	;timing
	
	exx			;4	;rs'
	ld e,a			;4	;temporarily hold x[i]
	sub d			;4
	add a,9			;7
	sra a			;8
	sra a			;8	;y[i] = 0.25*(y[i-1]+x[i]-x[i-1])
	ld e,d			;4	;preserve x[i]
	exx			;4	;rs
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	nop			;4

	dw outlo		;12__144

	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	nop			;4
	ld a,(hl)		;7	;timing
	ld a,(hl)		;7	;timing
	jp (hl)			;4	;jump to next core
				;192
				
;*******************************************************************************
	org 256*(1+(HIGH($)))			;volume 10, 160t
core10
	dw outhi		;12__
	pop de			;10	;base freq 1
	add ix,de		;15
	pop de			;10	;duty/vol ch1
	ld a,ixh		;8
	cp d			;4	;duty
	sbc a,a			;4
	and e			;4	;volume	
	ld h,a			;4	;preserve v.ch1
	
	pop de			;10	;base freq 2
	add iy,de		;15
	ld a,iyh		;8
	pop de			;10
	
	cp d			;4
	sbc a,a			;4
	and e			;4
	
	add a,h			;4
	
	ld h,(hl)		;7	;timing
	ld h,(hl)		;7	;timing
	inc hl			;6	;timing
	pop hl			;10	;filter amount, dw 0 or dw #2fcb
	dw outlo		;12__160
	
	ld (_shift2),hl		;16

	nop			;4
	;-------------------	;192
	
	dw outhi		;12__
	
	exx			;4
	rra			;4
	ld (de),a		;7
	rla			;4
	add a,(hl)		;7	;add reverb buffer
	inc e			;4
	inc l			;4
	exx			;4
	
	sub 10			;7
	sra a			;8
_shift2
	dw 0			;8
	add a,10		;7	;y[i] = y[i-1] + alpha*(x[i]-y[i])
	
	ld hl,-12		;10	;value for resetting sp	
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;jump base (determines lp/no filt)
	
	add a,h			;4
	ld h,a			;4
	
	ld r,a			;9	;timing
	nop			;4
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer0	;10
	ex af,af'		;4
					
	dw outlo		;12_160
		
	ds 4			;16
	
	jp (hl)			;4
				;192
				
	org 256*(HIGH($))+#50			;volume 10, 160t
core10n
	dw outhi		;12__
	pop de			;10	;base freq 1
	add ix,de		;15
	pop de			;10	;duty/vol ch1
	ld a,ixh		;8
	cp d			;4	;duty
	sbc a,a			;4
	and e			;4	;volume	
	ld h,a			;4	;preserve v.ch1
	
	pop de			;10	;base freq 2
	add iy,de		;15
	ld a,iyh		;8
	rlca			;4
	ld iyh,a		;8
	pop de			;10
	
	cp d			;4
	sbc a,a			;4
	and e			;4
	
	add a,h			;4
	
	ds 2			;8
	pop hl			;10	;filter amount, dw 0 or dw #2fcb
	dw outlo		;12__160
	
	ld (_shift2),hl		;16

	nop			;4
	;-------------------	;192
	
	dw outhi		;12__
	
	exx			;4
	rra			;4
	ld (de),a		;7
	rla			;4
	add a,(hl)		;7	;add reverb buffer
	inc e			;4
	inc l			;4
	exx			;4
	
	sub 10			;7
	sra a			;8
_shift2
	dw 0			;8
	add a,10		;7	;y[i] = y[i-1] + alpha*(x[i]-y[i])
	
	ld hl,-12		;10	;value for resetting sp	
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;jump base (determines lp/no filt)
	
	add a,h			;4
	ld h,a			;4
	
	ld r,a			;9	;timing
	nop			;4
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer0	;10
	ex af,af'		;4
					
	dw outlo		;12_160
		
	ds 4			;16
	
	jp (hl)			;4
				;192


	org 256*(HIGH($)) + #b0
core10hs
	dw outhi		;12__
	ld a,(hl)		;7	;timing
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	exx			;4	;rs
	
	dw outlo		;12__160
	
	jr _x			;12
_x	ds 2			;8	
	;------------------	;192
				
	dw outhi		;12__
	
	exx			;4	;rs'
	pop bc			;10
	ld c,h			;4	
	ld a,(bc)		;7
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	ret c			;5	;timing
	
	exx			;4	;rs'
	ld e,a			;4	;temporarily hold x[i]
	sub d			;4
	add a,10		;7
	sra a			;8
	sra a			;8	;y[i] = 0.25*(y[i-1]+x[i]-x[i-1])
	ld e,d			;4	;preserve x[i]
	exx			;4	;rs
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS0	;10
	ex af,af'		;4
	dw outlo		;12__160
	
	nop			;4
	jr _y			;12
_y	jp (hl)			;4	;jump to next core
				;192
				
;*******************************************************************************
	org 256*(1+(HIGH($)))			;volume 11, 176t
core11
	dw outhi		;12__
	pop de			;10	;base freq 1
	add ix,de		;15
	pop de			;10	;duty/vol ch1
	ld a,ixh		;8
	cp d			;4	;duty
	sbc a,a			;4
	and e			;4	;volume	
	ld h,a			;4	;preserve v.ch1
	
	pop de			;10	;base freq 2
	add iy,de		;15
	ld a,iyh		;8
	pop de			;10
	
	cp d			;4
	sbc a,a			;4
	and e			;4
	
	add a,h			;4
	
	ld h,(hl)		;7	;timing
	ld h,(hl)		;7	;timing
	inc hl			;6	;timing
	pop hl			;10	;filter amount, dw 0 or dw #2fcb
	ld (_shift2),hl		;16
	dw outlo		;12__176

	nop			;4
	;-------------------	;192
	
	dw outhi		;12__
	
	exx			;4
	rra			;4
	ld (de),a		;7
	rla			;4
	add a,(hl)		;7	;add reverb buffer
	inc e			;4
	inc l			;4
	exx			;4
	
	sub 10			;7
	sra a			;8
_shift2
	dw 0			;8
	add a,10		;7	;y[i] = y[i-1] + alpha*(x[i]-y[i])
	
	ld hl,-12		;10	;value for resetting sp	
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;jump base (determines lp/no filt)
	
	add a,h			;4
	ld h,a			;4
	
	ld r,a			;9	;timing
	nop			;4
	ds 4			;16
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer0	;10
	ex af,af'		;4
					
	dw outlo		;12_176

	jp (hl)			;4
				;192
				
				
	org 256*(HIGH($))+#50			;volume 11, 176t
core11n
	dw outhi		;12__
	pop de			;10	;base freq 1
	add ix,de		;15
	pop de			;10	;duty/vol ch1
	ld a,ixh		;8
	cp d			;4	;duty
	sbc a,a			;4
	and e			;4	;volume	
	ld h,a			;4	;preserve v.ch1
	
	pop de			;10	;base freq 2
	add iy,de		;15
	ld a,iyh		;8
	rlca			;4
	ld iyh,a		;8
	pop de			;10
	
	cp d			;4
	sbc a,a			;4
	and e			;4
	
	add a,h			;4
	
	ds 2			;8
	pop hl			;10	;filter amount, dw 0 or dw #2fcb
	ld (_shift2),hl		;16
	dw outlo		;12__176

	nop			;4
	;-------------------	;192
	
	dw outhi		;12__
	
	exx			;4
	rra			;4
	ld (de),a		;7
	rla			;4
	add a,(hl)		;7	;add reverb buffer
	inc e			;4
	inc l			;4
	exx			;4
	
	sub 10			;7
	sra a			;8
_shift2
	dw 0			;8
	add a,10		;7	;y[i] = y[i-1] + alpha*(x[i]-y[i])
	
	ld hl,-12		;10	;value for resetting sp	
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;jump base (determines lp/no filt)
	
	add a,h			;4
	ld h,a			;4
	
	ld r,a			;9	;timing
	nop			;4
	ds 4			;16
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer0	;10
	ex af,af'		;4
					
	dw outlo		;12_176

	jp (hl)			;4
				;192

	org 256*(HIGH($)) + #b0
core11hs
	dw outhi		;12__
	ld a,(hl)		;7	;timing
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	exx			;4	;rs
	
	jr _x			;12
_x	nop			;4
	dw outlo		;12__176
	
	nop			;4	
	;------------------	;192
				
	dw outhi		;12__
	
	exx			;4	;rs'
	pop bc			;10
	ld c,h			;4	
	ld a,(bc)		;7
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	ret c			;5	;timing
	
	exx			;4	;rs'
	ld e,a			;4	;temporarily hold x[i]
	sub d			;4
	add a,11		;7
	sra a			;8
	sra a			;8	;y[i] = 0.25*(y[i-1]+x[i]-x[i-1])
	ld e,d			;4	;preserve x[i]
	exx			;4	;rs
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS0	;10
	ex af,af'		;4
	nop			;4
	jr _y			;12
_y	
	dw outlo		;12__176
	
	jp (hl)			;4	;jump to next core
				;192
				
;*******************************************************************************
	org 256*(1+(HIGH($)))			;volume 12, 192t
core12
	dw outhi		;12__
	pop de			;10	;base freq 1
	add ix,de		;15
	pop de			;10	;duty/vol ch1
	ld a,ixh		;8
	cp d			;4	;duty
	sbc a,a			;4
	and e			;4	;volume	
	ld h,a			;4	;preserve v.ch1
	
	pop de			;10	;base freq 2
	add iy,de		;15
	ld a,iyh		;8
	pop de			;10
	
	cp d			;4
	sbc a,a			;4
	and e			;4
	
	add a,h			;4
	
	exx			;4
	rra			;4	;pre-shift buffer to make sure it's <=4
	ld (de),a		;7	;save in verb buffer
	rla			;4
	add a,(hl)		;7	;add reverb buffer
	exx			;4
	
		
	pop hl			;10	;filter amount, dw 0 or dw #2fcb
	ld (_shift2),hl		;16	
	;-------------------	
	
	
	sra a			;8
_shift2
	dw 0			;8
	
	
	exx			;4	
	inc e			;4	
	inc l			;4
	
	exx			;4
	
	ld hl,-12		;10	;value for resetting sp	
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;jump base (determines lp/no filt)
	
	add a,h			;4
	ld h,a			;4
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ld a,(hl)		;7	;timing
	ds 3			;12			
	
	jp (hl)			;4
				;192*2

	org 256*(HIGH($))+#50

core12n						;volume 0, 0t

	dw outhi		;12__
	pop de			;10	;base freq 1
	add ix,de		;15
	pop de			;10	;duty/vol ch1
	ld a,ixh		;8
	cp d			;4	;duty
	sbc a,a			;4
	and e			;4	;volume	
	ld h,a			;4	;preserve v.ch1
	
	pop de			;10	;base freq 2
	add iy,de		;15
	ld a,iyh		;8
	rlca			;4
	ld iyh,a		;8
	pop de			;10
	
	cp d			;4
	sbc a,a			;4
	and e			;4
	
	add a,h			;4
	
	exx			;4
	rra			;4	;pre-shift buffer to make sure it's <=4
	ld (de),a		;7	;save in verb buffer
	rla			;4
	add a,(hl)		;7	;add reverb buffer
	exx			;4
	
		
	pop hl			;10	;filter amount, dw 0 or dw #2fcb
	ld (_shift2),hl		;16	
	;-------------------	
	
	
	sra a			;8
_shift2
	dw 0			;8
	
	
	exx			;4	
	inc e			;4	
	inc l			;4
	
	exx			;4
	
	ld hl,-12		;10	;value for resetting sp	
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;jump base (determines lp/no filt)
	
	add a,h			;4
	ld h,a			;4
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ld a,(hl)		;7	;timing			
	
	jp (hl)			;4
				;192*2				

	org 256*(HIGH($)) + #b0
core12hs
	dw outhi		;12__
	pop de			;10	;fetch ch1.basefreq
	add ix,de		;15	;add to ch1.accu
	pop de			;10
	ld e,ixh		;8
	ld a,(de)		;7	;get sample byte
	ld l,a			;4	;preserve value
	
	pop de			;10	;same as above for ch2
	add iy,de		;15
	pop de			;10
	ld e,iyh		;8
	ld a,(de)		;7
	
	add a,l			;4	;add sample values
	ld l,a			;4	;and preserve
	
	exx			;4	;rs'
	pop bc			;10	;same as above for ch3
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4	
	ld a,(bc)		;7
	exx			;4	;rs
	
	add a,l			;4	;add sample values
	
	exx			;4	;rs'
	ld e,a			;4	;temporarily hold x[i]
	sub d			;4
	add a,12		;7
	sra a			;8
	sra a			;8	;y[i] = 0.25*(y[i-1]+x[i]-x[i-1])
	ld e,d			;4	;preserve x[i]
	exx			;4	;rs
	
	ld hl,-14		;10	;reset stack
	add hl,sp		;11
	ld sp,hl		;6
	
	pop hl			;10	;get base core address
	add a,h			;4	;calculate jump address
	ld h,a			;4
	
	ex af,af'		;4	;update timer
	dec a			;4
	jp z,updateTimerHS	;10
	ex af,af'		;4
	
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	ex (sp),hl		;19	;timing
	jr _x			;12
_x	nop
	
	jp (hl)			;4	;jump to next core
				;384
				
IF (LOW($))!=0
	org 256*(1+(HIGH($)))
ENDIF

reverbBuffer
	ds 256
reverbBufferEmpty
smp0
	ds 256
samples
	include "samples.asm"	
musicData
	include "music.asm"