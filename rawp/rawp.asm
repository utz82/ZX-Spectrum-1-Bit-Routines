
	org #9000
	
wavpl
		di
		push ix
		push iy

		ld hl,_orderList
		ld (_orderPntr),hl
_init
		ld iy,_play2
		call _readOrder
		push af
		ld e,(hl)
		inc hl
		ld d,(hl)
		ex de,hl
		ld (_orderPntr),hl
		pop af
		jr z,_init			;loop if no key pressed - comment out if you don't want loop
		pop iy
		pop ix
		ld hl,#2758			;restore hl' for return to BASIC
		exx
		ei
		ret	

;**************************************************************************************************
_readOrder
		ld hl,(_orderPntr)		;get order pointer
		ld e,(hl)			;read pnt pointer
		inc hl
		ld d,(hl)
		inc hl
		ld (_orderPntr),hl
		ld a,d				;if pointer = #0000, end of song reached
		or e
		ret z
		ld (_ptnPntr),de
		
;**************************************************************************************************
		
_readPtn
		in a,(#fe)
		cpl
		and #1f
		ret nz
		
		ld (_slidech2),a		;reset fx
		ld (_slidech1),a
		ld ixl,a			;reset low byte of timer		

		ld hl,(_ptnPntr)
		ld a,(hl)			;drum/end
		cp #ff				;exit if #ff found
		jr z,_readOrder
		
		ld a,(hl)			;set speed
		and %11111110
		ld ixh,a
		inc ixh				;timing correction because counter stops at #00ff
		
		ld a,(hl)
		rra
		call c,_drums
		
		inc hl
		ld a,(hl)			;sample ch1
		
		bit 7,a
		jr z,_rdskip1
		ld a,#14			;inc d
		ld (_slidech1),a
		ld a,(hl)
		bit 6,a
		jr z,_rdskip0
		ld a,#15
		ld (_slidech1),a
_rdskip0
		ld a,(hl)
		and %00111111
		
_rdskip1		
		inc hl
		ld b,(hl)			;pitch ch1
		ld d,b				;backup
		
		push hl
		ld hl,_smp0		
		add a,h
		ld h,a				;point hl to sample ch1
		ld e,h				;backup upper nibble
		
		ld c,#fe			;port
		
			exx
			pop hl
			inc hl
			ld a,(hl)			;sample ch2

			bit 7,a
			jr z,_rdskip3
			ld a,#14			;inc d
			ld (_slidech2),a
			ld a,(hl)
			bit 6,a
			jr z,_rdskip2
			ld a,#15
			ld (_slidech2),a
_rdskip2
			ld a,(hl)
			and %00111111
		
_rdskip3			

			inc hl
			ld b,(hl)			;pitch ch2
			ld d,b				;backup
			inc hl				;point to next row
		
			ld (_ptnPntr),hl		;preserve pattern pointer
			ld hl,_smp0
			add a,h
			ld h,a				;point hl' to sample ch2
			ld e,h				;backup upper nibble
			
			ld c,#fe			;port		

;**************************************************************************************************
;B - pitch counter ch1
;D - backup pitch counter
;E - backup sample pointer upper nibble
;HL - sample pointer ch1
;B' - pitch counter ch2
;D' - backup pitch counter
;E' - backup sample pointer upper nibble
;HL' - sample pointer ch2
;C,C' = #fe
;free: AF', IX, I, R


_play
			outi		;16
			inc b		;4
			ld h,e		;4
			outi		;16
			inc b		;4
_slidech2
			nop		;4		;inc d = #14
			outi		;16
			inc b		;4

			xor a		;4
			outi		;16
			jp nz,_play2	;10
			out (#fe),a	;11
			ld b,d		;4	;restore pitch counter, sample counter moves automatically
			ld a,0		;7	;waste time
			ld h,e		;4	;waste time

		exx		;4
		ld h,e		;4
		outi		;16
		inc b		;4
		ld h,e		;4	;restore upper nibble of sample pointer
		outi		;16
		inc b		;4
_slidech1
		nop		;4
		outi		;16
		inc b		;4
		nop		;4
		xor a		;4
		outi		;16
		jp nz,_wait2	;10
		out (#fe),a	;11
		ld b,d		;4	;restore pitch counter
		ld a,0		;7	;waste time
		ld h,e		;4
		;nop
_playend
			exx		;4
		
			dec ix		;10	;decrement speed counter
			ld a,ixh	;8
			or a		;4
			jp nz,_play	;10
				;288
		exx
		jp _readPtn

;**************************************************************************************************
_play2
			out (#fe),a	;11
			ld a,l		;4	;reset sample pointer
			sub 4		;7
			ld l,a		;4

			ld h,e		;4	;restore upper nibble of sample pointer
		exx		;4
		ld h,e		;4
		outi		;16
		inc b		;4	;cheating a bit
		nop		;4
		outi		;16
		inc b		;4
		ld h,e		;4
		outi		;16
		inc b		;4

		xor a		;4
		outi		;16
		jp nz,_wait2	;10
		out (#fe),a	;11
		ld b,d		;4	;restore pitch counter
		ld a,0		;7	;waste time
		ld h,e		;4
		
			exx		;4
		
			dec ix		;10	;decrement speed counter
			ld a,ixh	;8
			or a		;4
			jp nz,_play	;10
				;288
		exx		
		jp _readPtn

;**************************************************************************************************
_wait2
		out (#fe),a	;11
		ld a,l		;4	;reset sample pointer
		sub 4		;7
		ld l,a		;4
		
			exx		;4

			dec ix		;10	;decrement speed counter
			ld a,ixh	;8
			or a		;4
			jp nz,_play	;10

		exx
		jp _readPtn
		
;**************************************************************************************************
_drums
		push hl			;preserve data pointer
		push bc			;preserve timer
		push de		
		ld hl,#3000		;setup ROM pointer - change val for different drum sounds
		ld de,#0d0e		;loopldiloop
		ld b,72
	
_dlp3		ld a,(hl)		;read byte from ROM
		and #10
		out (#fe),a		;output whatever

		dec hl			;decrement ROM pointer
		dec bc			;decrement timer
		
		push ix
		pop ix
		push ix
		pop ix
		
		xor a
		out (#fe),a		;output whatever


_dlp4		dec d
		jr nz,_dlp4
		
		ld d,e
		inc e
		djnz _dlp3
_drumret	
		pop de
		pop bc			;restore timer
		pop hl
		dec ixh			;adjust timing
		ret

;**************************************************************************************************

_orderPntr
		dw 0
_ptnPntr
		dw 0
_sampleData
		include "sampledata.asm"
_musicData
		include "music.asm"
