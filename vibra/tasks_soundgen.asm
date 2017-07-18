
;*******************************************************************************
task_idle					;update noise and idle

	ex af,af'		;4'		;update noise pitch prescaler
noisePitch equ $+1
	add a,#0		;7
	jr nc,skip4		;12/7
	
	ex af,af'		;4

	add hl,hl		;11		;update noise generator
	sbc a,a			;4
	xor l			;4
	ld l,a			;4 (34)
	
ret4
	ret c			;5		;timing
	ld a,ixh		;8		;load output state ch1
	out (#fe),a		;11__80		;output ch1
	
	exx			;4
	dec sp			;6		;correct stack offset
	dec sp			;6

	ld a,0			;7		;timing
	ld a,0			;7		;timing
	ld a,0			;7		;timing
	ds 6			;24

	ld a,iyh		;8		;load output state ch2
	out (#fe),a		;11__80		;output state ch2
	
	exx			;4
	ld a,(noiseVolume)	;13		;load output state noise
	cp h			;4
	sbc a,a			;4
	ds 7			;28
	out (#fe),a		;11__64		;output noise state
	jp soundLoop		;10

skip4						;timing adjustment
	ex af,af'		;4'		;swap back to AF
	nop			;4
	xor a			;4		;clear carry for following timing adjustment
	jp ret4			;10 (34)


;*******************************************************************************
timerLo	db 0					;timer lo-byte

task_update_timer				;update timer hi-byte
	xor a			;4
	ret c			;5		;timing
	in a,(#fe)		;11		;read kbd
	cpl			;4
	and #1f			;7
	jp nz,exit		;10
	
	ret nz			;5		;timing
	exx			;4
	ld a,ixh		;8
	out (#fe),a		;11___80
	
 	ld a,i			;9		;I = timer hi-byte
 	dec a			;4
 	ld i,a			;9
	jp nz,skip5		;10
	
	ld hl,task_read_ptn	;10
	push hl			;11
	
ret5	
	ds 2			;8
	ld a,iyh		;8
	out (#fe),a		;11___80
	
	ld a,0			;7		;timing
	ld a,0			;7		;timing
	ld a,0			;7		;timing
	ld a,0			;7		;timing
	exx			;4
	ld a,(noiseVolume)	;13
	cp h			;4
	sbc a,a			;4
	out (#fe),a		;11___64
	jp soundLoop		;10

skip5
	ld a,r			;9		;timing
	jr ret5			;12


;*******************************************************************************	
task_update_fx1					;update vibrate/slide fx ch1
						;see task_update_fx2 for detailed comments
						
	ld a,0			;7		;timing
	ld a,0			;7		;timing
	ld a,0			;7		;timing
	ds 2			;8
	xor a			;4		;timing + clear carry
	ret c			;5		;timing
	ld a,ixh		;8	
vibrDir1
	inc b			;4		;vibrato initial direction
vibrSpeed1 equ $+1
	bit 2,b			;8		;vibrato speed, (see above, bit 3 -> ld b,4 | bit 2 -> ld b,2...)
	
	out (#fe),a		;11___80
	
	ld a,e			;4
fxType1
	jp z,slideDown1		;10		;jp z = vibrato = #ca, jp = slide down = #c3, jp c = slide up = #da (fx off: C = 0)
	
	add a,c			;4		;DE += C
	ld e,a			;4
	adc a,d			;4
	sub e			;4
	ld d,a			;4 
	
	ds 3			;12
retv1
	ds 2			;8
	ld a,0			;7		;timing
	ld a,iyh		;8
	out (#fe),a		;11___80
	
	ld a,(noiseVolume)	;13
	cp h			;4
	sbc a,a			;4
	ds 8			;32
	out (#fe),a		;11___64
	jp soundLoop		;10


slideDown1
	sub c			;4		;DE -= C
	ld e,a			;4
	sbc a,a			;4    
	add a,d			;4            
	ld d,a			;4
	jr retv1		;12 


;*******************************************************************************	
task_update_fx2					;update vibrate/slide fx ch2
	exx			;4
	ld a,0			;7		;timing
	ld a,0			;7		;timing
	ld a,0			;7		;timing
	nop			;4
	xor a			;4		;timing + clear carry
	ret c			;5		;timing
	ld a,ixh		;8		;load output state ch2
vibrDir2
	inc b			;4		;initial vibrato direction
vibrSpeed2 equ $+1
	bit 2,b			;8		;bit n = vibrato speed (lower is faster)
						;B must be initialized with (2^n)/2 (so bit 3 -> ld b,4 | bit 2 -> ld b,2...)	
	out (#fe),a		;11___80	;output state ch1
	
	ld a,e			;4
fxDepth2 equ $+1
	ld c,1			;7		;modification amount
fxType2	
	jp z,slideDown2		;10		;jp z = vibrato, jp = slide down, jp c = slide up (carry is always cleared at this point)
						;fx off: C = 0
	add a,c			;4		;base divider ch2 += modification amount (DE += C)
	ld e,a			;4
	adc a,d			;4
	sub e			;4
	ld d,a			;4 
	
	ds 3			;12
retv2
	nop			;4
	exx			;4
	ld a,iyh		;8		;load output state ch2
	out (#fe),a		;11___80	;output ch2
	
	ds 2			;8
	ld a,r			;9		;timing
	exx			;4
	ld c,#fe		;7		;restore C'=#fe (needed by main sound loop)
	exx			;4
	
	ld a,(noiseVolume)	;13		;load output state noise
	cp h			;4
	sbc a,a			;4
	out (#fe),a		;11___64	;output noise state
	jp soundLoop		;10


slideDown2
	sub c			;4		;DE -= C
	ld e,a			;4
	sbc a,a			;4    
	add a,d			;4            
	ld d,a			;4
	jr retv2		;12 

;*******************************************************************************

		