;nanobeep2
;tiny ZX Spectrum beeper engine
;by utz 08'2017 * www.irrlichtproject.de


	org #8000

borderMasking equ 0
fullKeyboardCheck equ 0
useDrum equ 1
loopToStart equ 1
usePatternSpeed equ 0
pwmSweep equ 1
usePrescaling equ 1
include "equates.h"	
	
;new tiny engine: 64-99 bytes
;fullKeyboardCheck +1 bytes
;borderMasking = +4/+6 bytes
;useDrum = +11 bytes
;loopToStart = +0
;variable pattern speed = +4
;pwmSweep +2
;usePrescaling +11 (down = #f, up = #7)


init
	di
	
	ld d,0
	ld c,d
	exx
	push hl
	ld (_oldSP),sp
IF fullKeyboardCheck = 0
	ld d,0
ENDIF
_initSeq
	ld bc,musicData

;*******************************************************************************	
_readSeq
	ld a,(bc)
	ld l,a
	inc bc
	ld a,(bc)
	or a
IF loopToStart = 0
	jr z,_exit
ELSE
	jr z,_initSeq
ENDIF
	inc bc
	ld h,a
	ld sp,hl

;*******************************************************************************
IF usePatternSpeed = 1
	pop af
	ld (_ptnSpeed),a
ENDIF
IF usePrescaling = 1
	pop hl
	ld a,h
	ld (_prescale1),a
	ld a,l
	ld (_prescale2),a
ENDIF
_readPtn
	in a,(#fe)
IF fullKeyboardCheck = 1
	cpl
	and #1f
	ld d,a
	jr z,_cont	
ELSE
	rra
	jr c,_cont
ENDIF
_exit	
_oldSP equ $+1
	ld sp,0
	pop hl
	exx
	ei
	ret

IF useDrum = 1
_drum
	ld h,l
	dec sp
_drumlp
	ld a,(hl)
IF borderMasking = 1
	and #10
ENDIF
	out (#fe),a
	dec l
	jr nz,_drumlp
ENDIF
_cont	
	pop hl
	ld a,l
	inc l
	jr z,_readSeq
IF useDrum = 1
	inc l
	jr z,_drum
ENDIF

	ld e,h
	exx
	ld e,a

IF usePatternSpeed = 1
_ptnSpeed equ $+1
	ld b,0
ELSE
	ld b,speed
ENDIF
;*******************************************************************************	
_soundloop
	
	ld a,h			;4	;load ch1 osc state
IF pwmSweep = 1
	add a,b
	and h
ENDIF
IF usePrescaling = 1
_prescale1
	nop
ENDIF
IF borderMasking = 1
	and #10
ENDIF
	out (#fe),a		;11
	exx			;4
	add hl,de		;11	;update ch2 osc
	ld a,h			;4
IF usePrescaling = 1
_prescale2
	nop
ENDIF
	exx			;4
	dec bc			;6
IF borderMasking = 1
	and #10
ENDIF
	add hl,de		;11	;update ch1 osc (moved here for better volume balance)
	
	out (#fe),a		;11
	ld a,b			;4
	or c			;4
	jr nz,_soundloop	;12
				;86	
	exx
	jr _readPtn

;*******************************************************************************
musicData
	include "music.asm"
