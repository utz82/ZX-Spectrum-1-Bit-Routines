;fluidcore
;4 channel wavetable player for the zx spectrum beeper
;by utz 03'2016

NMOS EQU 1
CMOS EQU 2

IF Z80=NMOS			;values for NMOS Z80
	pon equ #18fe
	poff equ 0
	seta equ #af		;xor a
ENDIF
IF Z80=CMOS			;values for CMOS Z80
	pon equ #00fe
	poff equ #18
	seta equ #79		;ld c,a
ENDIF

	;org #8065
	org origin	;org address is defined externally by compile script

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
	ld hl,musicdata
	ld (seqpntr),hl
	ld ixl,0

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
	
	ld sp,loop		;get loop point - comment out when disabling looping
	jr rdseq+3
	
exit
oldSP equ $+1
	ld sp,0
	pop hl
	exx
	ei
	ret

;************************************************************************************************
updateTimer
	db #ed,#71
updateTimerND
	ld a,i
	dec a
	jr z,rdptn
	ld i,a
	ld a,#ff
	ex af,af'
	jp (ix)
	
updateTimerOD
	ld a,i
	dec a
	jr z,rdptn
	ld i,a
	ld a,#ff
	ex af,af'
	jp core16

;************************************************************************************************
rdptn0
	ld (patpntr),de	
rdptn
	in a,(#1f)		;read joystick
maskKempston equ $+1
	and #1f
	ld d,a
	in a,(#fe)		;read kbd
	cpl
	or d
	and #1f
	jp nz,exit

patpntr equ $+1			;fetch pointer to pattern data
	ld sp,0

	pop af
	jr z,rdseq
	
	ld i,a
	
	pop hl			;10	;freq.ch1
	ld (buffer),hl		;16
	pop hl			;10	;freq.ch2
	ld (buffer+4),hl	;16
	pop de			;10	;sample.ch1/2
	ld a,d			;4
	ld (buffer+3),a		;13
	ld a,e			;4
	ld (buffer+7),a		;13	
	pop hl			;10	;freq.ch3
	ld (buffer+8),hl	;16
	pop hl			;10	;freq.ch4
	ld (buffer+12),hl	;20
	pop de			;10	;sample.ch3/4
	ld a,d			;4
	ld (buffer+11),a	;13
	ld a,e			;4
	ld (buffer+15),a	;13
	ld (patpntr),sp		;20
				;212
				
	xor a
IF Z80=NMOS
	out (#fe),a
ENDIF
	ld h,a
	ld l,a
	ld d,a
	ld e,a

	exx
	ld h,a
	ld l,a
	ld d,a
	ld e,a
		
	ex af,af'
	ld a,#fe		;set timer lo-byte
IF Z80=CMOS
	out (#fe),a
ENDIF
	ex af,af'
	
	;ld bc,pon
	jp pEntry
	;jp core0
	
;************************************************************************************************	
core0						;volume 0
IF (LOW($))!=0
	org 256*(1+(HIGH($)))
ENDIF
basec equ HIGH($)

_frame1
	db #ed,#71		;12___12
	ex af,af'		;4
	dec a			;4
	jp z,updateTimerND	;10
	ex af,af'		;4
pEntry	
	ld sp,buffer		;10
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyh,a		;8
	ld bc,pon		;10
	ds 9			;48		;9x nop
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	db #ed,#71		;12___12
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyl,a		;8
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ds 17			;68		;14x nop
				;152
	
_frame3
	db #ed,#71		;12___12
	nop			;4	
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ld bc,pon		;10
	ds 15			;60	;12x nop
				;152

_frame4
	db #ed,#71		;12___12
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4
	add a,iyh		;8
	
	exx			;4
	
	add a,basec		;7
	ld ixh,a		;8
	
	ld bc,pon		;10
	ds 7			;28
	cp maxc			;7
	jp nc,overdrive		;10
	jp (ix)			;8
				;152

;************************************************************************************************
buffer
	ds 16					;4x base freq, 4x base sample pointer	

;************************************************************************************************
core1	org 256*(1+(HIGH($)))				;volume 1 ... 12 t-states
_frame1
	out (c),b		;12___
	db #ed,#71		;12___12
	ex af,af'		;4
	dec a			;4
	jp z,updateTimerND	;10
	ex af,af'		;4
	
	ld sp,buffer		;10
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyh,a		;8
	ld bc,pon		;10
	ds 6			;36		;9x nop
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	out (c),b		;12
	db #ed,#71		;12___12
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyl,a		;8
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ds 14			;56		;14x nop
				;152
	
_frame3
	out (c),b		;12
	db #ed,#71		;12___12
	nop			;4	
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ld bc,pon		;10
	ds 12			;48	;12x nop
				;152

_frame4
	out (c),b		;12___
	db #ed,#71		;12___12
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4
	add a,iyh		;8
	
	exx			;4
	
	add a,basec		;7
	ld ixh,a		;8
	
	ld bc,pon		;10
	ds 4			;16
	cp maxc			;7
	jp nc,overdrive		;10
	jp (ix)			;8
				;152

;************************************************************************************************					
core2	org 256*(1+(HIGH($)))				;volume 2 ... 16 t-states
_frame1
	out (c),b		;12___
	ex af,af'		;4
	db #ed,#71		;12___16
	
	dec a			;4
	jp z,updateTimerND	;10
	ex af,af'		;4
	
	ld sp,buffer		;10
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyh,a		;8
	ld bc,pon		;10
	ds 6			;36		;9x nop
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	out (c),b		;12
	ex de,hl		;4
	db #ed,#71		;12___16
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyl,a		;8
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ds 14			;56		;14x nop
				;152
	
_frame3
	out (c),b		;12
	nop			;4
	db #ed,#71		;12___16	
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ld bc,pon		;10
	ds 12			;48	;12x nop
				;152

_frame4
	out (c),b		;12___
	ex de,hl		;4
	db #ed,#71		;12___16
	
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4
	add a,iyh		;8
	
	exx			;4
	
	add a,basec		;7
	ld ixh,a		;8
	
	ld bc,pon		;10
	ds 4			;16
	cp maxc			;10
	jp nc,overdrive		;7
	jp (ix)			;8
				;152

	
;************************************************************************************************	
core3	org 256*(1+(HIGH($)))			;volume  3 ... 24 t-states
_frame1
	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	nop			;4
	db #ed,#71		;12___24
	
	jp z,updateTimerND	;10
	ex af,af'		;4
	
	ld sp,buffer		;10
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyh,a		;8
	ld bc,pon		;10
	ds 5			;32
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	out (c),b		;12
	ex de,hl		;4
	ds 2			;8
	db #ed,#71		;12___24
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyl,a		;8
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ds 12			;48		;14x nop
				;152

_frame3
	out (c),b		;12
	nop			;4
	nop			;4
	nop			;4
	db #ed,#71		;12___24	
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ld bc,pon		;10
	ds 10			;40	;10x nop
				;152

_frame4
	out (c),b		;12___
	ex de,hl		;4
	nop			;4
	nop			;4
	db #ed,#71		;12___24
	
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4
	add a,iyh		;8
	
	exx			;4
	
	add a,basec		;7
	ld ixh,a		;8
	
	ld bc,pon		;10
	ds 2			;8
	cp maxc			;7
	jp nc,overdrive		;10
	jp (ix)			;8
				;152

;************************************************************************************************
core4	org 256*(1+(HIGH($)))			;volume  4 ... 32 t-states
_frame1
	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	ds 3			;12
	db #ed,#71		;12___32
	
	jp z,updateTimerND	;10
	ex af,af'		;4
	
	ld sp,buffer		;10
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyh,a		;8
	ld bc,pon		;10
	ds 3			;24
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	out (c),b		;12
	ex de,hl		;4
	ds 4			;16
	db #ed,#71		;12___32
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyl,a		;8
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ds 10			;40
				;152

_frame3
	out (c),b		;12
	nop			;4
	nop			;4
	nop			;4
	nop			;4
	nop			;4
	db #ed,#71		;12___32	
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ld bc,pon		;10
	ds 8			;32	;12x nop
				;152

_frame4
	out (c),b		;12___
	ex de,hl		;4
	pop bc			;10
	ld a,poff		;7
	out (#fe),a		;11___32
	
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4
	add a,iyh		;8
	
	exx			;4

	add a,basec		;7
	ld ixh,a		;8
	
	ld bc,pon		;10
	ld bc,pon		;10	;timing
	cp maxc			;7
	jp nc,overdrive		;10
	jp (ix)			;8
				;152

;************************************************************************************************
core5	org 256*(1+(HIGH($)))			;volume  5 ... 40 t-states
_frame1
	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ld sp,buffer		;10
	db #ed,#71		;12___40
	
	ex af,af'		;4	
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyh,a		;8
	ld bc,pon		;10
	ds 6			;36
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	out (c),b		;12
	ex de,hl		;4
	ds 6			;24
	db #ed,#71		;12___40
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyl,a		;8
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ds 8			;32
				;152

_frame3
	out (c),b		;12
	ds 7			;28
	db #ed,#71		;12___40	
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ld bc,pon		;10
	ds 6			;24
				;152

_frame4
	out (c),b		;12___
	;xor a			;4
	db seta
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	out (#fe),a		;11___40
	
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4
	add a,iyh		;8
	
	exx			;4

	add a,basec		;7
	ld ixh,a		;8
	
	ld bc,pon		;10
	ld (#0000),a		;13	;timing
	cp maxc			;7
	jp nc,overdrive		;10
	jp (ix)			;8
				;152

;************************************************************************************************
core6	org 256*(1+(HIGH($)))			;volume  6 ... 48 t-states
_frame1
	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	ld sp,buffer		;10
	nop			;4
	db #ed,#71		;12___48
		
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyh,a		;8
	ld bc,pon		;10
	ds 5			;32
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	out (c),b		;12
	ex de,hl		;4
	ds 8			;32
	db #ed,#71		;12___48
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyl,a		;8
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ds 6			;24
				;152

_frame3
	out (c),b		;12
	ds 9			;36
	db #ed,#71		;12___48	
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ld bc,pon		;10
	ds 4			;16	;12x nop
				;152

_frame4
	out (c),b		;12___
	;xor a			;4
	db seta
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	ds 2			;8
	out (#fe),a		;11___48
	
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4
	add a,iyh		;8
	
	exx			;4

	add a,basec		;7
	ld ixh,a		;8
	
	ld bc,pon		;10
	ret z			;5	;timing - safe while using reasonable values (total vol <#7f)
	cp maxc			;7
	jp nc,overdrive		;10
	jp (ix)			;8
				;152

;************************************************************************************************
core7	org 256*(1+(HIGH($)))			;volume  7 ... 56 t-states
_frame1
	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	ld sp,buffer		;10
	ds 3			;12
	db #ed,#71		;12___56
		
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyh,a		;8
	ld bc,pon		;10
	ds 3			;24
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	out (c),b		;12
	ex de,hl		;4
	ds 10			;40
	db #ed,#71		;12___56
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyl,a		;8
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ds 4			;16
				;152

_frame3
	out (c),b		;12
	ds 11			;44
	db #ed,#71		;12___56	
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ld bc,pon		;10
	ds 2			;8	;12x nop
				;152

_frame4
	out (c),b		;12___
	;xor a			;4
	db seta
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	dec bc			;6	;timing
	pop bc			;10
	out (#fe),a		;11___56

	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4
	add a,iyh		;8
	
	exx			;4

	add a,basec		;7
	ld ixh,a		;8
	
	ld bc,pon		;10
	
	cp maxc			;7
	jp nc,overdrive0	;10
	ld a,0			;7	;timing
	jp (ix)			;8
				;152

;************************************************************************************************
core8	org 256*(1+(HIGH($)))			;volume  8 ... 64 t-states
_frame1
	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	ld sp,buffer		;10
	ds 5			;20
	db #ed,#71		;12___64
		
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyh,a		;8
	ld bc,pon		;10
	nop			;16
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	out (c),b		;12
	ex de,hl		;4
	ds 12			;48
	db #ed,#71		;12___64
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyl,a		;8
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ds 2			;8
				;152

_frame3
	out (c),b		;12
	ds 13			;52
	db #ed,#71		;12___64	
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ld bc,pon		;10
				;152

_frame4
	out (c),b		;12___
	;xor a			;4
	db seta
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	dec bc			;6	;timing
	pop bc			;10
	ld c,h			;4
	ex de,hl		;4
	out (#fe),a		;11___64

	ld a,(bc)		;7
	add a,iyh		;8
	
	exx			;4

	add a,basec		;7
	ld ixh,a		;8
	
	ld bc,pon		;10
	cp maxc			;7
	jp nc,overdrive0	;10
	ld a,0			;7
	jp (ix)			;8
				;152

;************************************************************************************************
core9	org 256*(1+(HIGH($)))			;volume  9 ... 72 t-states
_frame1
	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	ld sp,buffer		;10
	ds 4			;28
	ex af,af'
	dec a
	ex af,af'
	db #ed,#71		;12___72
		
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyh,a		;8
	ld bc,pon		;10
	ds 2			;8
				;152

_frame2
	out (c),b		;12
	ex de,hl		;4
	ds 14			;56
	db #ed,#71		;12___72
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyl,a		;8
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
				;152

_frame3
	out (c),b		;12
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	add a,iyh		;8
	db #ed,#71		;12___72
	
	add a,iyl		;8
	ld iyh,a		;8
	ds 13			;52
				;152

_frame4
	out (c),b		;12___
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,basec		;7
	ld c,#fe		;7
	db #ed,#71		;12___72
	
	ex de,hl		;4
	add a,iyh		;8
	
	exx			;4
	
	ld ixh,a		;8
	
	ld bc,pon		;10
	ld r,a			;9
	cp maxc			;7
	jp nc,overdrive		;10
	jp (ix)			;8
				;152

;************************************************************************************************
core10	org 256*(1+(HIGH($)))			;volume 10 ... 80 t-states
_frame1
	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	ld sp,buffer		;10
	ds 6			;36
	ex af,af'
	dec a
	ex af,af'
	db #ed,#71		;12___80
		
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyh,a		;8
	ld bc,pon		;10
				;152

_frame2
	out (c),b		;12
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4	
	exx			;4
	nop			;4
	ld bc,pon		;10
	db #ed,#71		;12___80
	
	ld iyl,a		;8
	ds 13			;52
				;152

_frame3
	out (c),b		;12
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	add a,iyh		;8
	add a,iyl		;8
	db #ed,#71		;12___80
	
	ld iyh,a		;8
	ds 13			;52
				;152

_frame4
	out (c),b		;12___
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,basec		;7
	ex de,hl		;4
	exx			;4
	ld c,#fe		;7
	db #ed,#71		;12___80
	
	add a,iyh		;8
	
	ld ixh,a		;8
	
	ld bc,pon		;10	;ld b,#18 will be enough
	ld r,a			;9
	cp maxc			;7
	jp nc,overdrive		;10
	jp (ix)			;8
				;152

;************************************************************************************************
core11	org 256*(1+(HIGH($)))			;volume 11 ... 88 t-states
_frame1
	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	ld sp,buffer		;10
	pop bc			;10		;base freq 1
	add hl,bc		;11
	ld c,#fe		;7
	nop			;16
	ex af,af'
	dec a
	ex af,af'
	db #ed,#71		;12___88
		
	pop bc			;10
	ld c,h			;4
	ld (#0000),a		;13		;timing
	ld a,(bc)		;7
	ld iyh,a		;8
	ld bc,pon		;10
				;152


_frame2
	out (c),b		;12
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4	
	exx			;4
	nop			;4
	ld bc,pon		;10
	ld iyl,a		;8
	db #ed,#71		;12___88
	ds 13			;52
				;152

_frame3
	out (c),b		;12
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	db #ed,#71		;12___88
	ds 13			;52
				;152

_frame4
	out (c),b		;12___
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,basec		;7
	add a,iyh		;8
	ex de,hl		;4
	exx			;4
	ld c,#fe		;7
	db #ed,#71		;12___88
	
	ld ixh,a		;8
	
	ld bc,pon		;10
	ld r,a			;9
	cp maxc			;7
	jp nc,overdrive		;10
	jp (ix)			;8
				;152

;************************************************************************************************
core12	org 256*(1+(HIGH($)))			;volume 12 ... 96 t-states
_frame1
	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	ld sp,buffer		;10
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	db #ed,#71		;12___96
		
	ld iyh,a		;8
	ds 6			;36
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	out (c),b		;12
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ld iyl,a		;8
	ds 3			;12
	db #ed,#71		;12___96
	ds 11			;44
				;152

_frame3
	out (c),b		;12
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ds 2			;8
	db #ed,#71		;12___96
	ds 11			;44
				;152

_frame4
	out (c),b		;12___
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	ex de,hl		;4
	add a,basec		;7
	ld ixh,a		;8
	exx			;4
	ld c,#fe		;7
	db #ed,#71		;12___96
	
	ld bc,pon		;10	;ld b,#18 will do
	ld r,a			;9
	cp maxc			;7
	jp nc,overdrive		;10
	jp (ix)			;8
				;152

;************************************************************************************************
core13	org 256*(1+(HIGH($)))			;volume 13 ... 104 t-states
_frame1
	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	ld sp,buffer		;10
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	ld iyh,a		;8
	db #ed,#71		;12___104

	ds 6			;36
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	out (c),b		;12
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ld iyl,a		;8
	ds 5			;20
	db #ed,#71		;12___104
	ds 9			;36
				;152

_frame3
	out (c),b		;12
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ds 4			;16
	db #ed,#71		;12___104
	ds 9			;36
				;152

_frame4
	out (c),b		;12___
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	ex de,hl		;4
	add a,basec		;7
	ld ixh,a		;8
	exx			;4
	ld bc,pon		;10
	ret z			;5	;timing - Z is never set when using reasonable values (total vol <#7f)
	db #ed,#71		;12___104
	
	nop			;4
	cp maxc			;7
	jp nc,overdrive0	;10
	ld a,0			;7
	jp (ix)			;8
				;152
				
;************************************************************************************************
core14	org 256*(1+(HIGH($)))			;volume 14 ... 112 t-states
_frame1
	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	ld sp,buffer		;10
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	ld iyh,a		;8
	ds 2			;8
	db #ed,#71		;12___112

	ds 4			;28
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	out (c),b		;12
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ld iyl,a		;8
	ds 7			;28
	db #ed,#71		;12___112
	ds 7			;28
				;152

_frame3
	out (c),b		;12
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ds 6			;24
	db #ed,#71		;12___112
	ds 7			;28
				;152

_frame4
	out (c),b		;12___
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	ex de,hl		;4
	add a,basec		;7
	ld ixh,a		;8
	exx			;4
	dec bc			;6	;timing
	ld bc,pon		;10
	cp maxc			;7
	db #ed,#71		;12___112
	ld bc,pon		;10
	jp nc,overdrive		;10
	jp (ix)			;8
				;152

;************************************************************************************************
core15	org 256*(1+(HIGH($)))			;volume 15 ... 120 t-states
_frame1
	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	ld sp,buffer		;10
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	ld iyh,a		;8
	ds 4			;16
	db #ed,#71		;12___120

	ds 2			;20
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	out (c),b		;12
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ld iyl,a		;8
	ds 9			;36
	db #ed,#71		;12___120
	ds 5			;20
				;152

_frame3
	out (c),b		;12
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ds 8			;32
	db #ed,#71		;12___120
	ds 5			;20
				;152

_frame4
	out (c),b		;12___
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	ex de,hl		;4
	add a,basec		;7
	ld ixh,a		;8
	exx			;4
	nop			;4
	ld bc,pon		;10
	cp maxc			;7
	jp nc,overdrivey	;10
	db #ed,#71		;12___120
	ds 3			;12
	jp (ix)			;8
				;152

;************************************************************************************************
core16	org 256*(1+(HIGH($)))			;volume 16 ... 128 t-states
_frame1
	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	ld sp,buffer		;10
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	ld iyh,a		;8
	ds 6			;24
	db #ed,#71		;12___128

	;ds 3			;12
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	out (c),b		;12
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ld iyl,a		;8
	ds 11			;44
	db #ed,#71		;12___128
	ds 3			;12
				;152

_frame3
	out (c),b		;12
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ds 10			;40
	db #ed,#71		;12___128
	ds 3			;12
				;152

_frame4
	out (c),b		;12___
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	ex de,hl		;4
	add a,basec		;7
	ld ixh,a		;8
	exx			;4
	ld bc,pon		;7
	cp maxc			;7
	ld a,0			;7
	nop			;4
	nop			;4
	jp nc,overdrivex	;10
	db #ed,#71		;12___128
	nop			;4
	jp (ix)			;8
				;152

;************************************************************************************************
	;org #90f8			;handling frames with overdriven volume
	org (256*(1+(HIGH($))) - 12)
overdrivey
	db #ed,#71
	jr overdrive
overdrivex	
	db #ed,#71
	jr core17
overdrive0
	ld a,0
overdrive
	nop
	nop

core17	;org 256*(1+(HIGH($)))			;volume 17 ... 152 t-states
maxc equ (1 + (HIGH($)))
_frame1
	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	jp z,updateTimerOD	;10
	ex af,af'		;4
	ld sp,buffer		;10
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	ld iyh,a		;8
	ds 9			;48
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	out (c),b		;12
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ld iyl,a		;8
	ds 17			;68
				;152

_frame3
	out (c),b		;12
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ds 16			;64
				;152

_frame4
	out (c),b		;12___
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	ex de,hl		;4
	add a,basec		;7
	ld ixh,a		;8
	exx			;4
	ld bc,pon		;7
	ds 6			;24
	cp maxc			;7
	ld a,0			;7
	jp nc,overdrive		;10
	jp (ix)			;8
				;152


samples
	include "samples.asm"
	
musicdata
	include "music.asm"
