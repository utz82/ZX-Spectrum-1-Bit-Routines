;BM-1 aka BeepModular-1, a ZX Spectrum beeper engine
;by utz 02'2017

USETABLES equ 1
USEDRUMS equ 1
USELOOP equ 1

	include "equates.h"
	include "patches.h"
	

	org #8000
	
engine_init
	di
	exx

	push hl				;preserve HL' for return to BASIC
	ld (oldSP),sp
	ld hl,musicData
	ld (seqpntr),hl

;*******************************************************************************
rdseq
seqpntr equ $+1
	ld sp,0
	xor a
	pop bc				;pattern pointer to DE
	or b
	ld (seqpntr),sp
	jr nz,rdptn0

IF USELOOP = 1	
	ld sp,mloop			;get loop point
	jr rdseq+3
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
rdptn0
	ld (ptnpntr),bc
readPtn

IF USETABLES = 1
	ld (fxTablePtr),sp
ENDIF

	in a,(#fe)			;read kbd
	cpl
	and #1f
	jr nz,exit


ptnpntr equ $+1
	ld sp,0	


	pop af				;ctrl0+drum_param (see example music.asm for data format details)
	jr z,rdseq

IF USEDRUMS = 1	
	jp pe,drum1
	jp m,drum2
ENDIF
	
drumRet
	ld (timerLo),a
	jr c,skipAllUpdates
	
	exx
	
	pop af				;ctrl1+patch1_7
	jr c,skipUpdateCh1
	jr z,skipPatchUpdateCh1
		
	ld (patch1_7),a
	
	pop hl				;patch_ptr
	
	jp pe,skipPatchUpdate1_6

	ld de,patch1_1
	ld bc,6
	ldir
	
skipPatchUpdate1_6
	jp m,skipPatchUpdate8_11
	
	ld de,patch1_8
	ld bc,4
	ldir
	
skipPatchUpdate8_11	
skipPatchUpdateCh1
	pop de				;note_div_ch1
	rlc d				;if bit 7 of D is set, parameter follows
	jr nc,skipParamUpdateCh1

	ccf				;clear bit 7 of D on the following rotate
	pop ix				;generic_param1

skipParamUpdateCh1
	rr d
	ld hl,0				;reset ch1_accu

skipUpdateCh1
	exx


	pop af				;ctrl2+patch2_7
	jr c,skipUpdateCh2
	jr z,skipPatchUpdateCh2
		
	ld (patch2_7),a
	
	pop hl				;patch_ptr
	
	jp pe,skipPatchUpdate2_1_6

	ld de,patch2_1
	ld bc,6
	ldir
	
skipPatchUpdate2_1_6
	jp m,skipPatchUpdate2_8_11
	
	ld de,patch2_8
	ld bc,4
	ldir
	
skipPatchUpdate2_8_11	
skipPatchUpdateCh2
	pop de				;note_div_ch2
	rlc d				;check if parameter follows
	jr nc,skipParamUpdateCh2

	ccf
	pop iy				;generic_param2

skipParamUpdateCh2
	rr d
	ld hl,0				;reset ch2_accu

skipUpdateCh2
skipAllUpdates

	pop af

IF USETABLES = 1
	jr z,skipTblPtrUpdate

	pop bc
	ld (fxTablePtr),bc

skipTblPtrUpdate	
	ld (ptnpntr),sp
	
fxTablePtr equ $+1
	ld sp,0
ENDIF

	exx	
timerLo equ $+2
	ld bc,#00fe			;port|timer lo

	exx

	ld c,#fe			;port
	ld b,a				;timer hi
;*******************************************************************************
	exx
playNote
	add hl,de	;11		;ch1_accu += note_div_ch1
	ld a,h		;4		;without further modifications, this
					;will output a 50:50 square wave
patch1_1
	nop		;4
patch1_2
	nop		;4
patch1_3
	nop		;4
patch1_4
	nop		;4	
patch1_5
	nop		;4
patch1_6
	nop		;4
	
	out (c),a	;12__64		;ch1 volume 1
patch1_7
	nop		;4
	out (c),a	;12__16		;ch1 volume 2
patch1_8
	nop		;4
patch1_9
	nop		;4
patch1_10
	nop		;4
patch1_11
	nop		;4
	
	nop		;4
	out (c),a	;12__32		;ch1 volume 4
	
	
	exx		;4
	
	add hl,de	;11		;ch2_accu += note_div_ch2
	ld a,h		;4

patch2_1
	nop		;4
patch2_2
	nop		;4
patch2_3
	nop		;4
patch2_4
	nop		;4
patch2_5
	nop		;4
patch2_6
	nop		;4
		
	jp _skip	;10
_skip			
	out (#fe),a	;11__64		;ch2 volume 1
patch2_7
	nop		;4
	out (c),a	;12__16		;ch2 volume 2
patch2_8
	nop		;4
patch2_9
	nop		;4
patch2_10
	nop		;4
patch2_11
	nop		;4
	
	exx		;4
	out (c),a	;12__32		;ch2 volume 4	

	djnz playNote	;13
			;224

;*******************************************************************************
IF USETABLES = 1			
tblNext					;run fx table
	pop af				;tbl_ctrl0
	jr z,stopTableExec
	jr c,stopTableExec+1
	jp m,tableJump
	ret pe				;exec tbl code

tblStdUpdate	
	pop af				;tbl_ctrl1
	
	jr z,noTblDiv1
	
	pop de
noTblDiv1	
	jr c,noTblParam1
	
	pop ix
noTblParam1	
	jp m,noTblDiv2
	exx
	pop de
	exx
noTblDiv2	
	jp pe,noTblParam2
	
	pop iy
	
noTblParam2	
noTableExec
ENDIF		
	exx
	djnz playNote-1
	
	jp readPtn


IF USETABLES = 1	
stopTableExec
	dec sp
	dec sp
	exx
	djnz playNote-1
	jp readPtn
	
tableJump
	ld a,h
	ld c,l
	pop hl
	ld sp,hl
	ld h,a
	ld l,c
	ld c,#fe
	jp tblNext
ENDIF	
	

;*******************************************************************************
IF USEDRUMS = 1
drum1						;kick
	ld (deRest),de
	ld (hlRest),hl

	ld d,a					;A = start_pitch<<1
	ld e,0
	ld h,e
	ld l,e
	
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
	
	ex af,af'	
	ld a,#34				;correct speed offset

drumEnd
hlRest equ $+1
	ld hl,0
	
	jp drumRet		
	

	
drum2						;noise
	ld (hlRest),hl
	
	ld b,a
	ex af,af'
	
	ld a,b
	ld hl,1					;#1 (snare) <- 1011 -> #1237 (hat)
	rlca
	jr c,setVol
	ld hl,#1237

setVol
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
	ex af,af'
	ld a,#21		;correct speed offset
	
	jr drumEnd
ENDIF
	
	
;*******************************************************************************	
musicData
	include "music.asm"
