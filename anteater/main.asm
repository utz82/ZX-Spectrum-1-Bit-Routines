;AntEater - ZX Spectrum beeper engine
;by utz 08'2014

		org #8000
		
init
		di
		ld hl,musicdata
		ld (OrderPntr),hl
		call readOrder
		jr z,init
		xor a
		out (#fe),a
		ld hl,#2758			;restore alternative HL to default value
		exx
		ei
		ret

;**************************************************************************************************		
readOrder
		ld hl,(OrderPntr)		;get order pointer
		ld e,(hl)			;read pnt pointer
		inc hl
		ld d,(hl)
		inc hl
		ld (OrderPntr),hl
		ld a,d				;if pattern pointer = #0000, end of song reached
		or e
		ret z
		ld (PtnPntr),de

;**************************************************************************************************		
readPtn
		in a,(#fe)
		cpl
		and #1f
		ret nz
		
		ld a,#10
		ld (switch1),a
		ld (switch2),a
		
		ld hl,(PtnPntr)
		ld a,(hl)			;check for pattern end		
		cp #ff
		jr z,readOrder

		ld a,(hl)
		and %11111100			;mask lowest 2 bits
		ld b,a				;speed
		ld c,b
		
		ld a,(hl)
		and %00000011
		or a				;if !=0, we have drum
		call nz,drums
		

		
drdata		
		inc hl
		xor a
		ld d,(hl)			;counter ch2
		ld e,d
		push hl
		ld h,#10			;output mask ch2
		or d
		jr nz,rdskip1		
		ld h,a				;mute if note byte = 0
rdskip1
		ld l,h				;swap mask
		exx
		pop hl
		inc hl
		ld b,(hl)			;counter A
		or b
		jr nz,rdskip2
		ld (switch1),a
		ld (switch2),a
rdskip2
		ld c,b				;backup counter A/B
		ld d,b				;counter B
		inc hl
		ld (PtnPntr),hl
		ld hl,#1000			;output mask ch1
		exx

;**************************************************************************************************		
play
		ld a,h			;4	;load output mask ch2
		
		exx			;4
		dec b			;4	;dec counter A
		out (#fe),a		;11	;output ch2
		jr nz,wait1		;12/7
		ld a,h			;4	;flip output mask and restore counter
switch1 equ $+1					;mute switch
		xor #10			;7
		ld h,a			;4
		ld b,c			;4
skip1
		dec d			;4	;dec counter B
		ld a,l			;4	;load output mask ch1
		jr nz,wait2		;12/7
		ld d,c			;4	;restore counter
switch2 equ $+1					;mute switch
		xor #10			;7	;swap output mask
		ld l,a			;4
		
		rra			;4	;increment counter to create pwm effect if output mask = #10
		rra			;4
		rra			;4
		rra			;4
		add a,d			;4
		ld d,a			;4
		
skip2
		ld a,l			;4
		and h			;4	;combine output masks
		out (#fe),a		;11	;output ch1
		
		exx			;4
		dec d			;4	;decrement counter ch1
		jp nz,wait3		;10
		ld d,e			;4	;restore counter
		ld a,h			;4	;swap output mask
		xor l			;4
		ld h,a			;4
		
skip3		
		dec bc			;6	;decrement speed counter
		ld a,b			;4
		or c			;4
		nop			;4	;take care of IO contention
		jp nz,play		;10
					;184
		jr readPtn

;**************************************************************************************************

wait1
		nop			;4
		jp skip1		;10

wait2
		sla (hl)		;15
		sla (hl)		;15
		nop			;4
		jr skip2		;12
					;46
		
		;ld (hl),b		;7	;why on earth I can't read the keyboard here
		;in a,(#fe)		;11	;is a mystery to me.
		;cpl			;4
		;and #1f		;7
		;ret nz			;11/5
		;jr skip2		;12
					

wait3
		nop			;4
		jr skip3		;12

;**************************************************************************************************
drums
		push hl

		dec a
		ld hl,switch2
		ld d,#fd
		jr z,drum2
		dec a
		ld d,#bf
		ld hl,drdata+7
		jr z,drumloop3
		
drum1
		ld hl,drdata
		
		ld a,c			;timing correction
		sub #c2
		ld c,a
		jr nc,tskip1
		dec b
tskip1
		push bc
		ld b,12
drum1a
		ld a,#10
		out (#fe),a
		ld a,(hl)
drumloop1
		dec a
		jr nz,drumloop1
		out (#fe),a
		ld a,(hl)
drumloop2
		dec a
		jr nz,drumloop2	
		inc hl
		djnz drum1a
		jr drumret

drum2
		dec b			;timing correction
		ld a,#d9
		ld (switch3),a		;modify end marker value
drumloop3
		ld a,c			;timing correction
		sub d
		jr nc,tskip2
		dec b
tskip2
		push bc
drumloop30
		ld a,#10
		out (#fe),a
switch3 equ $+1
		ld a,6
		ld b,(hl)
		xor b
		jr z,drumret
dl3a
		push hl
		pop hl
		djnz dl3a
		xor a
		out (#fe),a
		ld b,(hl)
dl3b
		push hl
		pop hl
		djnz dl3b
		inc hl
		jr drumloop30
		ld a,6
		ld (switch3),a

drumret
		pop bc
		
		pop hl
		ret
		
;**************************************************************************************************
OrderPntr
		dw 0
		
PtnPntr
		dw 0

musicdata
		include "music.asm"
