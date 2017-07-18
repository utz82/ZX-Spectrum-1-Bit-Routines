;VIBRA
;ZX beeper engine by utz 07'2017
;*******************************************************************************

	org #8000

looping equ 1
	include "equates.h"
	
	di
	
;ix,de,bc	accu,base,mod ch1
;iy,de',bc'	accu,base,mod ch2/#fe
;hl		accu/seed noise
;hl'		stack mod
;sp		task stack/data pointer
;a'		prescaler noise
;i		timer hi

	exx
	push hl
	push iy
	ld (oldSP),sp
	
	ld hl,musicData
	ld (seqPointer),hl
	ld sp,stk_idle
	ld ix,0
	ld iy,0
	ld de,0
	ld bc,#fe
	exx
	xor a
	ld h,a
	ld l,a
	ld d,a
	ld e,a
	ld (timerLo),a
	ld (vibrInit1),a
	ld (vibrInit2),a
	ld a,#10
	ld i,a
	jp task_read_seq

;*******************************************************************************
soundLoop
	add ix,de		;15		;update counter ch1
	ld a,ixh		;8		;load output state ch1
	
	exx			;4
	jp nc,skip1		;10
	
	ld hl,task_update_fx1	;10		;push update event on taskStack on counter overflow
	push hl			;11

ret1	
	out (c),a		;12___80	;output ch1
	
	ld hl,timerLo		;10		;update timer lo-byte
	dec (hl)		;11
	jr nz,skip3		;12/7

	inc hl			;6		;= ld hl,task_update_timer
	push hl			;11		;push update event on taskStack if timer lo-byte = 0

ret3	
	add iy,de		;15		;update counter ch2
	ld a,iyh		;8		;load output state ch2
	out (c),a		;11___80	;output ch2
	jr nc,skip2		;12/7
	
	ld hl,task_update_fx2	;10		;push update event on taskStack on counter overflow
	push hl			;11
						
ret2	
	inc hl			;6		;timing
	exx			;4		
noiseVolume equ $+1
	ld a,#0			;7		;load output state noise channel	TODO: if we do ld a,(noiseVolume), we don't need timing adjust and can
						;						save 6t elsewhere
	cp h			;4
	sbc a,a			;4
	out (#fe),a		;11___64
	
	ret			;11		;fetch next task from taskStack
				;224

skip1						;timing adjustments
	nop
	ld l,0
	jp ret1
skip2
	nop
	jr ret2
skip3
	jr ret3

;*******************************************************************************
taskStack
	ds 30
stk_idle
	dw task_idle
;*******************************************************************************
exit
oldSP equ $+1
	ld sp,0
	pop iy
	pop hl
	exx
	ei
	ret	

;*******************************************************************************	

	include "tasks_soundgen.asm"
	include "tasks_data.asm"

;*******************************************************************************
musicData
	include "music.asm"
	