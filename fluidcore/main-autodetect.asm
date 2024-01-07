;fluidcore
;4 channel wavetable player for the zx spectrum beeper
;by utz 03'2016

	pon equ #18fe
	poff equ 0
	seta equ #af		;xor a

	;org #8060
	org origin	;org address is defined externally by compile script

init
	ei			;detect kempston
	halt
	in a,(#1f)
	inc a
	jr nz,_skip
	ld (maskKempston),a
_skip
	call detectMOS
	call c,patchCMOS
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
        ld de,0
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
        or a
	jr z,rdseq

        dec sp
        dec sp
        pop af

	ld i,a

        ld (_oldHL),hl

        jr nc,_no_ch1_update

        pop hl
        ld (buffer),hl
        pop hl
        dec sp
        ld a,l
        ld (buffer+3),a
        ld hl,0
        ld (_oldHL),hl

_no_ch1_update
        jr nz,_no_ch2_update

        pop hl
        ld (buffer+4),hl
        pop hl
        dec sp
        ld a,l
        ld (buffer+7),a
        ld de,0

_no_ch2_update
        jp po,_no_ch3_update

        pop hl
        ld (buffer+8),hl
        pop hl
        dec sp
        ld a,l
        ld (buffer+11),a
        exx
        ld hl,0
        exx

_no_ch3_update
        jp p,_no_ch4_update
        pop hl
        ld (buffer+12),hl
        pop hl
        ld a,l
        dec sp
        ld (buffer+15),a
        exx
        ld de,0
        exx

_no_ch4_update
	ld (patpntr),sp
_oldHL equ $+1
        ld hl,0

	ex af,af'
	ld a,#fe		;set timer lo-byte
	ex af,af'

	jp pEntry
        ;; jp (ix)

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
patch1 equ $+2
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
patch2 equ $+2
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
patch3 equ $+2
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
patch4 equ $+2
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
patch5 equ $+2
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
patch6 equ $+2
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
patch7 equ $+2
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
patch8 equ $+2
	ld bc,pon		;10
	ds 4			;16
	cp maxc			;7
	jp nc,overdrive		;10
	jp (ix)			;8
				;152

;************************************************************************************************
detectMOS
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

	scf			; on NMOS processors it should be 0, on CMOS - #FF
	ret nz
	ccf
	ret

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
patch9 equ $+2
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
patch10 equ $+2
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
patch11 equ $+2
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
patch12 equ $+2
	ld bc,pon		;10
	ds 4			;16
	cp maxc			;10
	jp nc,overdrive		;7
	jp (ix)			;8
				;152
;************************************************************************************************
patchCMOS
	xor a
	ld (patch1),a
	ld (patch2),a
	ld (patch3),a
	ld (patch4),a
	ld (patch5),a
	ld (patch6),a
	ld (patch7),a
	ld (patch8),a
	ld (patch9),a
	ld (patch10),a
	ld (patch11),a
	ld (patch12),a
	ld (patch13),a
	ld (patch14),a
	ld (patch15),a
	ld (patch16),a
	ld (patch17),a
	ld (patch18),a
	ld (patch19),a
	ld (patch20),a
	ld (patch21),a
	ld (patch22),a
	ld (patch23),a
	ld (patch24),a
	ld (patch25),a
	ld (patch26),a
	ld (patch27),a
	ld (patch28),a
	ld (patch29),a
	ld (patch30),a
	ld (patch31),a
	ld (patch32),a
	ld (patch33),a
	ld (patch34),a
	ld (patch35),a
	ld (patch36),a
	ld (patch37),a
	ld (patch38),a
	ld (patch39),a
	ld (patch40),a
	ld (patch41),a
	ld (patch42),a
	jp patchCMOS2


;************************************************************************************************
core3	;org 256*(1+(HIGH($)))			;volume  3 ... 24 t-states
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
patch13 equ $+2
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
patch14 equ $+2
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
patch15 equ $+2
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
patch16 equ $+2
	ld bc,pon		;10
	ds 2			;8
	cp maxc			;7
	jp nc,overdrive		;10
	jp (ix)			;8
				;152

;************************************************************************************************
patchCMOS2
	ld (patch43),a
	ld (patch44),a
	ld (patch45),a
	ld (patch46),a
	ld (patch47),a
	ld (patch48),a
	ld (patch49),a
	ld (patch50),a
	ld (patch51),a
	ld (patch52),a
	ld (patch53),a
	ld (patch54),a
	ld (patch55),a
	ld (patch56),a
	ld (patch57),a
	ld (patch58),a
	ld (patch59),a
	ld (patch60),a
	ld (patch61),a
	ld (patch62),a
	ld (patch63),a
	ld (patch64),a
	ld (patch65),a
	ld (patch66),a
	ld (patch67),a
	ld (patch68),a
	ld (patch69),a
	ld (patch70),a
	ld (patch71),a
	ld (patch72),a
	;; ld (patch78),a
	;; ld (patch78+1),a

	ld a,#18
	ld (patch73),a

	ld a,#79		;ld a,c
	ld (patch74),a
	ld (patch75),a
	ld (patch76),a
	ld (patch77),a

	;; ld a,#d3		;out (#fe),a
	;; ld (patch79),a
	;; ld a,#fe
	;; ld (patch79+1),a
	ret

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
patch17 equ $+2
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
patch18 equ $+2
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
patch19 equ $+2
	ld bc,pon		;10
	ds 8			;32	;12x nop
				;152

_frame4
	out (c),b		;12___
	ex de,hl		;4
	pop bc			;10
patch73 equ $+1
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
patch20 equ $+2
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
patch21 equ $+2
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
patch22 equ $+2
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
patch23 equ $+2
	ld bc,pon		;10
	ds 6			;24
				;152

_frame4
	out (c),b		;12___
patch74
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
patch24 equ $+2
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
patch25 equ $+2
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
patch26 equ $+2
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
patch27 equ $+2
	ld bc,pon		;10
	ds 4			;16	;12x nop
				;152

_frame4
	out (c),b		;12___
patch75
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
patch28 equ $+2
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
patch29 equ $+2
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
patch30 equ $+2
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
patch31 equ $+2
	ld bc,pon		;10
	ds 2			;8	;12x nop
				;152

_frame4
	out (c),b		;12___
patch76
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
patch32 equ $+2
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
patch33 equ $+2
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
patch34 equ $+2
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
patch35 equ $+2
	ld bc,pon		;10
				;152

_frame4
	out (c),b		;12___
patch77
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
patch36 equ $+2
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
patch37 equ $+2
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
patch38 equ $+2
	ld bc,pon		;10
				;152

_frame3
	out (c),b		;12
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
patch39 equ $+2
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
patch40 equ $+2
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
patch41 equ $+2
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
patch42 equ $+2
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
patch43 equ $+2
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
patch44 equ $+2
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
patch45 equ $+2
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
patch46 equ $+2
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
patch47 equ $+2
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
patch48 equ $+2
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
patch49 equ $+2
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
patch50 equ $+2
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
patch51 equ $+2
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
patch52 equ $+2
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
patch53 equ $+2
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
patch54 equ $+2
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
patch55 equ $+2
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
patch56 equ $+2
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
patch57 equ $+2
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
patch58 equ $+2
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
patch59 equ $+2
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
patch60 equ $+2
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
patch61 equ $+2
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
patch62 equ $+2
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
patch63 equ $+2
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
patch64 equ $+2
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
patch65 equ $+2
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
patch66 equ $+2
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
patch67 equ $+2
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
patch68 equ $+2
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
patch69 equ $+2
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
patch70 equ $+2
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
patch71 equ $+2
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
patch72 equ $+2
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
