;******************************************************************
;* octode 2k16                                                    *
;* 8ch beeper engine by utz 05'2016                               *
;* www.irrlichtproject.de                                         *
;******************************************************************

;SP set to start of current buffer/ptn row
;(addBuffer) - add cntr 1-3
;DE  - add cntr 4
;HL  - accu 1-3, jump val
;HL' - add cntr 5
;DE' - add cntr 6
;BC/BC' - base counters
;IX - add cntr 7
;IY - add cntr 8
;A  - vol.add
;A',I - timer

NMOS EQU 1
CMOS EQU 2

OUTHI equ #41ed
OUTLO equ #71ed

IF Z80=NMOS			;values for NMOS Z80
PCTRL equ #10fe
PCTRL_B equ #10
ENDIF
IF Z80=CMOS			;values for CMOS Z80
PCTRL equ #00fe
PCTRL_B equ #00
ENDIF


	;org #8000
	org origin

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
	
	;jp exit		;uncomment to disable looping
	
	ld sp,loop		;get loop point
	jr rdseq+3

;******************************************************************
updateTimer0
	nop
	dw OUTLO
updateTimer
	ld a,i			;9
	dec a			;4
	jp z,readNextRow	;10
	ld i,a			;9
	xor a			;4
	ex af,af'		;4
	jp (hl)			;4
				;44 TODO: adjust timings!
				
updateTimerX
	ld a,i			;9
	dec a			;4
	jp z,readNextRow	;10
	ld i,a			;9
	xor a			;4
	ex af,af'		;4
	ld a,(hl)		;7	;timing
	dw OUTLO		;12
	xor a			;4
	nop			;4
	jp (hl)			;4
				
addBuffer
	ds 6

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
	ld (patpntr),hl
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

	ld de,0			;clear add counters 1-4
	ld sp,addBuffer+6
	push de
	push de
	push de

patpntr equ $+1			;fetch pointer to pattern data
	ld sp,0

	pop af
	jr z,rdseq
	
	ld i,a			;timer
	
	jr c,drumNoise
	jp pe,drumKick
	jp m,drumSnare
drumRet
		
	pop hl			;fetch row buffer addr
	
	ld (patpntr),sp
	
	ld sp,hl		;row buffer addr -> SP
	
	xor a			;timer lo
	exx
	ld h,a			;clear add counters 5-8
	ld l,a
	ld d,a
	ld e,a
	ld ix,0
	ld iy,0
	exx
	
	ex af,af'
	xor a
	ld bc,PCTRL
	jp core0


drumNoise	
	ld hl,#35d1	;10
drumX
	ex de,hl	;4		;DE = 0, so now HL = 0
	pop bc		;10		;duty in C, B = 0
	
_dlp	
	add hl,de	;11
	ld a,h		;4
	cp c		;4
	sbc a,a		;4
	and #10		;7
	out (#fe),a	;11
	rlc h		;8
	djnz _dlp	;13/8 - 62*256 = 15872
	
	ld d,b		;4	;reset DE
	ld e,b		;4
	ld a,#d6	;7	;adjust row length
	ex af,af'	;4
	jp drumRet	;10
			;15933/15943 ~ 41,5 sound loop iterations

drumKick
	ld hl,1
	jr drumX

drumSnare
	ld hl,5
	jr drumX

;*********************************************************************************************
IF (LOW($))!=0
	org 256*(1+(HIGH($)))
ENDIF

core0						;volume 0, 0t
basec equ HIGH($)

	dw OUTLO		;12__		;switch sound on

	ld hl,(addBuffer)	;16		;get ch1 accu
	pop bc			;10		;get ch1 base freq
	add hl,bc		;11		;add them up
	ld (addBuffer),hl	;16		;store ch1 accu
	rl h			;8		;rotate bit 7 into volume accu
	rla			;4
	
	ld hl,(addBuffer+2)	;16		;as above, for ch2
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+2),hl	;16
	rl h			;8
	adc a,0			;7
	
	ld hl,(addBuffer+4)	;16		;as above for ch3
	
	ld c,#fe		;7
	ds 3			;12
	
	ret c			;5		;timing, branch never taken
	ld b,PCTRL_B		;7		;B = #10
	;------------------	;--192
	
	dw OUTLO		;12__		;sound on
	
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+4),hl	;16
	rl h			;8
	adc a,0			;7

	ex de,hl		;4		;DE is ch4 accu
	pop bc			;10		;add base freq as usual
	add hl,bc		;11
	ex de,hl		;4
	ld b,d			;4		;get bit 7 of ch4 accu without modifying the accu itself
	rl b			;8
	adc a,0			;7
	
	exx			;4

	pop bc			;10		;get base freq ch5
	add hl,bc		;11		;HL' is ch5 accu
	ld b,h			;4
	rl b			;8
		
	ld r,a			;9		;timing
	ld bc,PCTRL		;10
	dw OUTLO		;12__168

	adc a,0			;7
	ret c			;5		;timing
	;-----------------	;--192
	
	dw OUTLO		;12__
	
	ex de,hl		;4		;DE' is accu ch6
	pop bc			;10
	add hl,bc		;11
	ld b,h			;4
	rl b			;8
	adc a,0			;7
	ex de,hl		;4
	
	pop bc			;10
	add ix,bc		;15		;IX is accu ch7
	ld b,ixh		;8
	rl b			;8
	adc a,0			;7
	ret c			;5		;timing
	
	pop bc			;10	
	add iy,bc		;15		;IY is accu ch8	
	ld b,iyh		;8
	rl b			;8
	
	exx			;4
	ld bc,PCTRL		;10
	dw OUTLO		;12__168
	
	ex af,af'		;4
	dec a			;4
	ex af,af'		;4
	;-----------------	;--192
	
	dw OUTLO		;12__
	
	adc a,0			;7

	ld hl,-16		;10		;point SP to beginning of pattern row again
	add hl,sp		;11
	ld sp,hl		;6
	add a,basec		;7		;calculate which core to use for next frame
	ld h,a			;4		;and put the value in HL
	xor a			;4		;also reset volume accu
	ld l,a			;4
	
	ex (sp),hl		;19		;timing
	ex (sp),hl		;19		;timing
	
	ex af,af'		;4		;check if timer has expired
	dec a			;4
	jp z,updateTimer	;10		;and update if necessary
	ret z			;5		;timing
	ex af,af'		;4
	
	ex (sp),hl		;19		;timing
	ex (sp),hl		;19		;timing

	dw OUTLO		;12__168
		
	ds 2			;8		;timing
	jp (hl)			;4		;jump to next frame
	;-----------------	;--192


;*********************************************************************************************
	org 256*(1+(HIGH($)))
core1						;vol 1 - 24t

	dw OUTHI		;12__		;switch sound on
	ex af,af'		;4		;update timer
	dec a			;4
	ex af,af'		;4
	dw OUTLO		;12__24		;switch sound off

	ld hl,(addBuffer)	;16		;get ch1 accu
	pop bc			;10		;get ch1 base freq
	add hl,bc		;11		;add them up
	ld (addBuffer),hl	;16		;store ch1 accu
	rl h			;8		;rotate bit 7 into volume accu
	rla			;4
	
	ld hl,(addBuffer+2)	;16		;as above, for ch2
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+2),hl	;16
	rl h			;8
	adc a,0			;7
	
	ret c			;5		;timing, branch never taken
	ds 2			;8
	
	ld bc,PCTRL		;10		;BC = #10fe
	;------------------	;--192
	
	dw OUTHI		;12__		;sound on
	ex af,af'		;4		;update timer again (for better speed control)
	dec a			;4
	ex af,af'		;4
	dw OUTLO		;12__24
	
	ld hl,(addBuffer+4)	;16		;as above for ch3
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+4),hl	;16
	rl h			;8
	adc a,0			;7

	ex de,hl		;4		;DE is ch4 accu
	pop bc			;10		;add base freq as usual
	add hl,bc		;11
	ex de,hl		;4
	ld b,d			;4		;get bit 7 of ch4 accu without modifying the accu itself
	rl b			;8
	adc a,0			;7
	
	ret c			;5		;timing, branch never taken
	
	exx			;4
	pop bc			;10		;get base freq ch5
	add hl,bc		;11		;HL' is ch5 accu
	
	ld bc,PCTRL		;10
	;-----------------	;--192
	
	dw OUTHI		;12__
	ld b,h			;4
	rl b			;8
	dw OUTLO		;12__24
	
	adc a,0			;7
	
	ex de,hl		;4		;DE' is accu ch6
	pop bc			;10
	add hl,bc		;11
	ld b,h			;4
	rl b			;8
	adc a,0			;7
	
	ex de,hl		;4
	pop bc			;10
	add ix,bc		;15		;IX is accu ch7
	ld b,ixh		;8
	rl b			;8
	adc a,0			;7
	
	pop bc			;10
	add iy,bc		;15		;IY is accu ch8
	
	exx			;4
	ld bc,PCTRL		;10
	ld bc,PCTRL		;10		;timing
	nop			;4
	;-----------------	;--192
	
	dw OUTHI		;12__
	ds 3			;12
	dw OUTLO		;12__24
	
	exx			;4
	ld b,iyh		;8
	rl b			;8
	adc a,0			;7
	
	exx			;4
	ld hl,-16		;10		;point SP to beginning of pattern row again
	add hl,sp		;11
	ld sp,hl		;6
	
	add a,basec		;7		;calculate which core to use for next frame
	ld h,a			;4		;and put the value in HL
	
	ld a,(hl)		;7		;timing
	ld a,(hl)		;7		;timing
	ld a,(hl)		;7		;timing
	nop			;4		;timing
	
	xor a			;4		;also reset volume accu
	ld l,a			;4
	
	ex af,af'		;4		;check if timer has expired
	jp z,updateTimer	;10		;and update if necessary
	ex af,af'		;4
	
	ds 8			;32		;timing (to match updateTimer length)
	
	jp (hl)			;4		;jump to next frame
	;-----------------	;--192
	
	
;*********************************************************************************************
	org 256*(1+(HIGH($)))
core2						;vol 2 - 48t

	dw OUTHI		;12__		;switch sound on
	ex af,af'		;4		;update timer
	dec a			;4
	ex af,af'		;4
	ld hl,(addBuffer)	;16		;get ch1 accu
	ds 2			;8		;timing
	dw OUTLO		;12__48		;switch sound off

	pop bc			;10		;get ch1 base freq
	add hl,bc		;11		;add them up
	ld (addBuffer),hl	;16		;store ch1 accu
	rl h			;8		;rotate bit 7 into volume accu
	rla			;4
	
	ld hl,(addBuffer+2)	;16		;as above, for ch2
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+2),hl	;16
	rl h			;8
	adc a,0			;7
	
	ret c			;5		;timing, branch never taken
	
	ld bc,PCTRL		;10		;BC = #10fe
	;------------------	;--192
	
	dw OUTHI		;12__		;sound on
	ex af,af'		;4		;update timer again (for better speed control)
	dec a			;4
	ex af,af'		;4
	ld hl,(addBuffer+4)	;16		;as above for ch3
	ds 2			;8
	dw OUTLO		;12__48
	
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+4),hl	;16
	rl h			;8
	adc a,0			;7

	ex de,hl		;4		;DE is ch4 accu
	pop bc			;10		;add base freq as usual
	add hl,bc		;11
	ex de,hl		;4
	ld b,d			;4		;get bit 7 of ch4 accu without modifying the accu itself
	rl b			;8
	adc a,0			;7
	
	nop			;4		;timing	
	exx			;4
	pop bc			;10		;get base freq ch5
	exx			;4
	
	ld bc,PCTRL		;10
	;-----------------	;--192
	
	dw OUTHI		;12__
	exx			;4
	add hl,bc		;11		;HL' is ch5 accu
	ld b,h			;4
	ld r,a			;9		;timing
	nop			;4
	exx			;4
	dw OUTLO		;12__48
	
	exx			;4
	rl b			;8
	adc a,0			;7
	
	ex de,hl		;4		;DE' is accu ch6
	pop bc			;10
	add hl,bc		;11
	ld b,h			;4
	rl b			;8
	adc a,0			;7
	
	ex de,hl		;4
	pop bc			;10
	add ix,bc		;15		;IX is accu ch7
	ld b,ixh		;8
	rl b			;8
	
	exx			;4
	ld bc,PCTRL		;10
	ld bc,PCTRL		;10		;timing
	;-----------------	;--192
	
	dw OUTHI		;12__
	exx			;4
	
	adc a,0			;7
	ld b,(hl)		;7		;timing
	nop			;4
	pop bc			;10
	
	exx			;4
	dw OUTLO		;12__48
	exx			;4
		
	add iy,bc		;15		;IY is accu ch8
	ld b,iyh		;8
	rl b			;8
	adc a,0			;7
	
	exx			;4
	ld hl,-16		;10		;point SP to beginning of pattern row again
	add hl,sp		;11
	ld sp,hl		;6
	
	add a,basec		;7		;calculate which core to use for next frame
	ld h,a			;4		;and put the value in HL
	
	xor a			;4		;also reset volume accu
	ld l,a			;4
	
	ex af,af'		;4		;check if timer has expired
	jp z,updateTimer	;10		;and update if necessary
	ex af,af'		;4
	
	ld a,(hl)		;7		;timing
	ld a,(hl)		;7		;timing
	xor a			;4
	
	jp (hl)			;4		;jump to next frame
	;-----------------	;--192
	
	
;*********************************************************************************************
	org 256*(1+(HIGH($)))
core3						;vol 3 - 72t

	dw OUTHI		;12__		;switch sound on

	ld hl,(addBuffer)	;16		;get ch1 accu
	pop bc			;10		;get ch1 base freq
	add hl,bc		;11		;add them up
	ld (addBuffer),hl	;16		;store ch1 accu
	ld c,#fe		;7

	dw OUTLO		;12__72		;switch sound off

	rl h			;8		;rotate bit 7 into volume accu
	rla			;4
	
	ld hl,(addBuffer+2)	;16		;as above, for ch2
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+2),hl	;16
	rl h			;8
	adc a,0			;7
	
	ex af,af'		;4		;update timer
	dec a			;4
	ex af,af'		;4
	inc bc			;6		;timing 
	
	ld bc,PCTRL		;10		;BC = #10fe
	;------------------	;--192
	
	dw OUTHI		;12__		;sound on

	ld hl,(addBuffer+4)	;16		;as above for ch3
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+4),hl	;16
	
	ld c,#fe		;7
	dw OUTLO		;12__72
	
	rl h			;8
	adc a,0			;7

	ex de,hl		;4		;DE is ch4 accu
	pop bc			;10		;add base freq as usual
	add hl,bc		;11
	ex de,hl		;4
	ld b,d			;4		;get bit 7 of ch4 accu without modifying the accu itself
	rl b			;8
	adc a,0			;7
	
	exx			;4
	pop bc			;10		;get base freq ch5
	add hl,bc		;11		;HL' is ch5 accu
	exx			;4
	
	inc bc			;6		;timing
	ld bc,PCTRL		;10
	;-----------------	;--192
	
	dw OUTHI		;12__
	exx			;4
	
	ld b,h			;4
	rl b			;8
	adc a,0			;7
	ex de,hl		;4		;DE' is accu ch6
	pop bc			;10
	add hl,bc		;11
	ld b,h			;4
	nop			;4
	
	exx			;4
	dw OUTLO		;12__72
	exx			;4
	
	rl b			;8
	adc a,0			;7
	
	ex de,hl		;4
	pop bc			;10
	add ix,bc		;15		;IX is accu ch7
	ld b,ixh		;8
	rl b			;8
	adc a,0			;7
	
	pop bc			;10
	
	exx			;4
	ld b,(hl)		;7		;timing
	inc bc			;6		;timing
	ld bc,PCTRL		;10
	;-----------------	;--192
	
	dw OUTHI		;12__
	exx			;4
	
	add iy,bc		;15		;IY is accu ch8
	ld b,iyh		;8
	rl b			;8
	adc a,0			;7
	
	nop			;4
	
	exx			;4
	ld hl,-16		;10		;point SP to beginning of pattern row again
	dw OUTLO		;12__72

	add hl,sp		;11
	ld sp,hl		;6
	
	add a,basec		;7		;calculate which core to use for next frame
	ld h,a			;4		;and put the value in HL
	
	ld a,(hl)		;7		;timing
	ld a,(hl)		;7		;timing
	
	xor a			;4		;also reset volume accu
	ld l,a			;4
	
	ex af,af'		;4		;check if timer has expired
	dec a			;4
	jp z,updateTimer	;10		;and update if necessary
	ex af,af'		;4
	
	ds 8			;32		;timing (to match updateTimer length)
	
	jp (hl)			;4		;jump to next frame
	;-----------------	;--192
	
	
;*********************************************************************************************
	org 256*(1+(HIGH($)))
core4						;vol 4 - 96t

	dw OUTHI		;12__		;switch sound on

	ld hl,(addBuffer)	;16		;get ch1 accu
	pop bc			;10		;get ch1 base freq
	add hl,bc		;11		;add them up
	ld (addBuffer),hl	;16		;store ch1 accu

	rl h			;8		;rotate bit 7 into volume accu
	ld hl,(addBuffer+2)	;16		;as above, for ch2

	ld c,#fe		;7
	dw OUTLO		;12__96		;switch sound off

	rla			;4
		
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+2),hl	;16
	rl h			;8
	adc a,0			;7
	
	ex af,af'		;4		;update timer
	dec a			;4
	ex af,af'		;4
	inc bc			;6		;timing 
	
	ld bc,PCTRL		;10		;BC = #10fe
	;------------------	;--192
	
	dw OUTHI		;12__		;sound on

	ld hl,(addBuffer+4)	;16		;as above for ch3
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+4),hl	;16
	rl h			;8
	adc a,0			;7
	ret c			;5		;timing

	ex de,hl		;4		;DE is ch4 accu
	
	ld c,#fe		;7
	dw OUTLO		;12__96
		
	pop bc			;10		;add base freq as usual
	add hl,bc		;11
	ex de,hl		;4
	ld b,d			;4		;get bit 7 of ch4 accu without modifying the accu itself
	rl b			;8
	adc a,0			;7
	
	exx			;4
	pop bc			;10		;get base freq ch5
	
	exx			;4	
	inc bc			;6		;timing
	inc bc			;6		;timing
	ld bc,PCTRL		;10
	;-----------------	;--192
	
	dw OUTHI		;12__
	exx			;4
	
	add hl,bc		;11		;HL' is ch5 accu
	ld b,h			;4
	rl b			;8
	adc a,0			;7
	ex de,hl		;4		;DE' is accu ch6
	pop bc			;10
	add hl,bc		;11
	ld b,h			;4
	rl b			;8
	ld r,a			;9
	
	exx			;4
	dw OUTLO		;12__96
	exx			;4
	
	adc a,0			;7
	
	ex de,hl		;4
	pop bc			;10
	add ix,bc		;15		;IX is accu ch7
	ld b,ixh		;8
	rl b			;8
	nop			;4
	
	pop bc			;10
	
	exx			;4
	ld bc,PCTRL		;10
	;-----------------	;--192
	
	dw OUTHI		;12__
	exx			;4
	
	adc a,0			;7
	
	add iy,bc		;15		;IY is accu ch8
	ld b,iyh		;8
	rl b			;8
	adc a,0			;7

	exx			;4
	ld hl,-16		;10		;point SP to beginning of pattern row again
	add hl,sp		;11
	ld sp,hl		;6
	nop			;4
	
	dw OUTLO		;12__96

	add a,basec		;7		;calculate which core to use for next frame
	ld h,a			;4		;and put the value in HL
	
	ld a,(hl)		;7		;timing
	
	xor a			;4		;also reset volume accu
	ld l,a			;4
	
	ex af,af'		;4		;check if timer has expired
	dec a			;4
	jp z,updateTimer	;10		;and update if necessary
	ex af,af'		;4
	
	ds 8			;32		;timing (to match updateTimer length)
	
	jp (hl)			;4		;jump to next frame
	;-----------------	;--192
	
;*********************************************************************************************
	org 256*(1+(HIGH($)))
core5						;vol 5 - 120t

	dw OUTHI		;12__		;switch sound on

	ld hl,(addBuffer)	;16		;get ch1 accu
	pop bc			;10		;get ch1 base freq
	add hl,bc		;11		;add them up
	ld (addBuffer),hl	;16		;store ch1 accu
	rl h			;8		;rotate bit 7 into volume accu
	rla			;4
	
	ld hl,(addBuffer+2)	;16		;as above, for ch2

	ds 5			;20

	ld c,#fe		;7
	dw OUTLO		;12__120	;switch sound off

	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+2),hl	;16
	
	ld r,a			;9		;timing
	nop			;4
	
	ld bc,PCTRL		;10		;BC = #10fe
	;------------------	;--192
	
	dw OUTHI		;12__		;sound on

	rl h			;8
	adc a,0			;7
	
	ld hl,(addBuffer+4)	;16		;as above for ch3
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+4),hl	;16
	rl h			;8
	adc a,0			;7

	ex de,hl		;4		;DE is ch4 accu
	
	ld b,(hl)		;7		;timing
	ld b,(hl)		;7		;timing
	ld c,#fe		;7
	dw OUTLO		;12__120
		
	pop bc			;10		;add base freq as usual
	add hl,bc		;11
	ex de,hl		;4
	ld b,d			;4		;get bit 7 of ch4 accu without modifying the accu itself
	rl b			;8
	adc a,0			;7
	
	inc bc			;6		;timing
	ld bc,PCTRL		;10
	;-----------------	;--192
	
	dw OUTHI		;12__
	exx			;4
		
	pop bc			;10		;get base freq ch5
	add hl,bc		;11		;HL' is ch5 accu
	ld b,h			;4
	rl b			;8
	adc a,0			;7
	ex de,hl		;4		;DE' is accu ch6
	pop bc			;10
	add hl,bc		;11
	ld b,h			;4
	rl b			;8
	adc a,0			;7
	
	inc bc			;6		;timing
	pop bc			;10
	exx			;4
	dw OUTLO		;12__120
	exx			;4
	
	ex de,hl		;4
	
	add ix,bc		;15		;IX is accu ch7
	ld b,ixh		;8
	rl b			;8
	adc a,0			;7
	
	pop bc			;10
	
	exx			;4
	;-----------------	;--192
	
	dw OUTHI		;12__
	exx			;4
		
	add iy,bc		;15		;IY is accu ch8
	ld b,iyh		;8
	rl b			;8
	adc a,0			;7
	
	exx			;4

	ld hl,-16		;10		;point SP to beginning of pattern row again
	add hl,sp		;11
	ld sp,hl		;6
	add a,basec		;7		;calculate which core to use for next frame
	ld h,a			;4		;and put the value in HL
	xor a			;4		;also reset volume accu
	ld l,a			;4
	
	ex af,af'		;4		;check if timer has expired
	dec a			;4
	dec a			;4
	nop			;4
	
	
	dw OUTLO		;12__120
	
	ld bc,PCTRL		;10		;not necessary, just for timing
		
	jp z,updateTimer	;10		;and update if necessary
	ex af,af'		;4
	
	ds 8			;32		;timing (to match updateTimer length)
	
	jp (hl)			;4		;jump to next frame
	;-----------------	;--192
		

;*********************************************************************************************
	org 256*(1+(HIGH($)))
core6						;vol 6 - 144t

	dw OUTHI		;12__		;switch sound on

	ld hl,(addBuffer)	;16		;get ch1 accu
	pop bc			;10		;get ch1 base freq
	add hl,bc		;11		;add them up
	ld (addBuffer),hl	;16		;store ch1 accu
	rl h			;8		;rotate bit 7 into volume accu
	rla			;4
	
	ld hl,(addBuffer+2)	;16		;as above, for ch2
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+2),hl	;16
	
	ld c,(hl)		;7		;timing
	ld c,#fe		;7
	dw OUTLO		;12__144	;switch sound off
	
	rl h			;8
	adc a,0			;7
	
	ld b,(hl)		;7		;timing
	nop			;4		
	ld bc,PCTRL		;10		;BC = #10fe
	;------------------	;--192
	
	dw OUTHI		;12__		;sound on
	
	ld hl,(addBuffer+4)	;16		;as above for ch3
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+4),hl	;16
	rl h			;8
	adc a,0			;7

	ex de,hl		;4		;DE is ch4 accu
	pop bc			;10		;add base freq as usual
	add hl,bc		;11
	ex de,hl		;4
	ld b,d			;4		;get bit 7 of ch4 accu without modifying the accu itself
	rl b			;8
	adc a,0			;7
	
	ld r,a			;9		;timing
	ld c,#fe		;7
	dw OUTLO		;12__144
		
	
	ld b,(hl)		;7		;timing	
	ld b,(hl)		;7		;timing
	ds 3			;12

	ld bc,PCTRL		;10
	;-----------------	;--192
	
	dw OUTHI		;12__
	exx			;4
		
	pop bc			;10		;get base freq ch5
	add hl,bc		;11		;HL' is ch5 accu
	ld b,h			;4
	rl b			;8
	adc a,0			;7
	ex de,hl		;4		;DE' is accu ch6
	pop bc			;10
	add hl,bc		;11
	ld b,h			;4
	rl b			;8
	adc a,0			;7
	ex de,hl		;4
	
	pop bc			;10
	add ix,bc		;15		;IX is accu ch7
	
	ld b,(hl)		;7		;timing
	nop			;4
	
	exx			;4
	dw OUTLO		;12__144
	exx			;4
	
	ld b,ixh		;8
	rl b			;8
	adc a,0			;7
	
	ret c			;5		;timing
	
	exx			;4
	;-----------------	;--192
	
	dw OUTHI		;12__
	exx			;4
	
	pop bc			;10	
	add iy,bc		;15		;IY is accu ch8
	ld b,iyh		;8
	rl b			;8
	adc a,0			;7

	exx			;4
	
	ld hl,-16		;10		;point SP to beginning of pattern row again
	add hl,sp		;11
	ld sp,hl		;6
	add a,basec		;7		;calculate which core to use for next frame
	ld h,a			;4		;and put the value in HL
	xor a			;4		;also reset volume accu
	ld l,a			;4
	
	ex af,af'		;4		;check if timer has expired
	dec a			;4
	dec a			;4
	nop			;4
	jp z,updateTimer0	;10		;and update if necessary
	ex af,af'		;4
	
	dw OUTLO		;12__144
		
	ds 8			;32		;timing (to match updateTimer length)
	
	jp (hl)			;4		;jump to next frame
	;-----------------	;--192


;*********************************************************************************************
	org 256*(1+(HIGH($)))
core7						;vol 7 - 168t

	dw OUTHI		;12__		;switch sound on

	ld hl,(addBuffer)	;16		;get ch1 accu
	pop bc			;10		;get ch1 base freq
	add hl,bc		;11		;add them up
	ld (addBuffer),hl	;16		;store ch1 accu
	rl h			;8		;rotate bit 7 into volume accu
	rla			;4
	
	ld hl,(addBuffer+2)	;16		;as above, for ch2
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+2),hl	;16
	rl h			;8
	adc a,0			;7
	
	ld hl,(addBuffer+4)	;16		;as above for ch3
	
	ld c,#fe		;7
	dw OUTLO		;12__168	;switch sound off
	
	ret c			;5		;timing, branch never taken
	ld b,PCTRL_B		;7		;B = #10
	;------------------	;--192
	
	dw OUTHI		;12__		;sound on
	
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+4),hl	;16
	rl h			;8
	adc a,0			;7

	ex de,hl		;4		;DE is ch4 accu
	pop bc			;10		;add base freq as usual
	add hl,bc		;11
	ex de,hl		;4
	ld b,d			;4		;get bit 7 of ch4 accu without modifying the accu itself
	rl b			;8
	adc a,0			;7
	
	exx			;4

	pop bc			;10		;get base freq ch5
	add hl,bc		;11		;HL' is ch5 accu
	ld b,h			;4
	rl b			;8
		
	ld r,a			;9		;timing
	ld bc,PCTRL		;10
	dw OUTLO		;12__168

	adc a,0			;7
	ret c			;5		;timing
	;-----------------	;--192
	
	dw OUTHI		;12__
	
	ex de,hl		;4		;DE' is accu ch6
	pop bc			;10
	add hl,bc		;11
	ld b,h			;4
	rl b			;8
	adc a,0			;7
	ex de,hl		;4
	
	pop bc			;10
	add ix,bc		;15		;IX is accu ch7
	ld b,ixh		;8
	rl b			;8
	adc a,0			;7
	ret c			;5		;timing
	
	pop bc			;10	
	add iy,bc		;15		;IY is accu ch8	
	ld b,iyh		;8
	rl b			;8
	
	exx			;4
	ld bc,PCTRL		;10
	dw OUTLO		;12__168
	
	ex af,af'		;4
	dec a			;4
	ex af,af'		;4
	;-----------------	;--192
	
	dw OUTHI		;12__
	
	adc a,0			;7

	ld hl,-16		;10		;point SP to beginning of pattern row again
	add hl,sp		;11
	ld sp,hl		;6
	add a,basec		;7		;calculate which core to use for next frame
	ld h,a			;4		;and put the value in HL
	xor a			;4		;also reset volume accu
	ld l,a			;4
	
	ex (sp),hl		;19		;timing
	ex (sp),hl		;19		;timing
	
	ex af,af'		;4		;check if timer has expired
	dec a			;4
	jp z,updateTimerX	;10		;and update if necessary
	ret z			;5		;timing
	ex af,af'		;4
	
	ex (sp),hl		;19		;timing
	ex (sp),hl		;19		;timing
				;    (47)
	dw OUTLO		;12__168
		
	ds 2			;8		;timing
	jp (hl)			;4		;jump to next frame
	;-----------------	;--192

		
;*********************************************************************************************
	org 256*(1+(HIGH($)))
core8						;vol 8 - 192t

	dw OUTHI		;12__		;switch sound on

	ld hl,(addBuffer)	;16		;get ch1 accu
	pop bc			;10		;get ch1 base freq
	add hl,bc		;11		;add them up
	ld (addBuffer),hl	;16		;store ch1 accu
	rl h			;8		;rotate bit 7 into volume accu
	rla			;4
	
	ld hl,(addBuffer+2)	;16		;as above, for ch2
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+2),hl	;16
	rl h			;8
	adc a,0			;7
	
	ld hl,(addBuffer+4)	;16		;as above for ch3
	
	ld c,#fe		;7
	ds 3			;12
	
	ret c			;5		;timing, branch never taken
	ld b,PCTRL_B		;7		;B = #10
	;------------------	;--192
	
	dw OUTHI		;12__		;sound on
	
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+4),hl	;16
	rl h			;8
	adc a,0			;7

	ex de,hl		;4		;DE is ch4 accu
	pop bc			;10		;add base freq as usual
	add hl,bc		;11
	ex de,hl		;4
	ld b,d			;4		;get bit 7 of ch4 accu without modifying the accu itself
	rl b			;8
	adc a,0			;7
	
	exx			;4

	pop bc			;10		;get base freq ch5
	add hl,bc		;11		;HL' is ch5 accu
	ld b,h			;4
	rl b			;8
		
	ld r,a			;9		;timing
	ld bc,PCTRL		;10
	dw OUTHI		;12__168

	adc a,0			;7
	ret c			;5		;timing
	;-----------------	;--192
	
	dw OUTHI		;12__
	
	ex de,hl		;4		;DE' is accu ch6
	pop bc			;10
	add hl,bc		;11
	ld b,h			;4
	rl b			;8
	adc a,0			;7
	ex de,hl		;4
	
	pop bc			;10
	add ix,bc		;15		;IX is accu ch7
	ld b,ixh		;8
	rl b			;8
	adc a,0			;7
	ret c			;5		;timing
	
	pop bc			;10	
	add iy,bc		;15		;IY is accu ch8	
	ld b,iyh		;8
	rl b			;8
	
	exx			;4
	ld bc,PCTRL		;10
	dw OUTHI		;12__168
	
	ex af,af'		;4
	dec a			;4
	ex af,af'		;4
	;-----------------	;--192
	
	dw OUTHI		;12__
	
	adc a,0			;7

	ld hl,-16		;10		;point SP to beginning of pattern row again
	add hl,sp		;11
	ld sp,hl		;6
	add a,basec		;7		;calculate which core to use for next frame
	ld h,a			;4		;and put the value in HL
	xor a			;4		;also reset volume accu
	ld l,a			;4
	
	ex (sp),hl		;19		;timing
	ex (sp),hl		;19		;timing
	
	ex af,af'		;4		;check if timer has expired
	dec a			;4
	jp z,updateTimer	;10		;and update if necessary
	ret z			;5		;timing
	ex af,af'		;4
	
	ex (sp),hl		;19		;timing
	ex (sp),hl		;19		;timing

	dw OUTHI		;12__168
		
	ds 2			;8		;timing
	jp (hl)			;4		;jump to next frame
	;-----------------	;--192

		
	
;*********************************************************************************************	
musicData
	include "music.asm"
	
