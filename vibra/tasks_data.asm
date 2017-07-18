
;*******************************************************************************
task_read_seq
	ld (taskPointer_rs),sp	;20
seqPointer equ $+1
	ld sp,0			;10
	exx			;4
	inc hl			;6		;timing
	pop hl			;10
	
	ld a,ixh		;8		;load output state ch1
	out (#fe),a		;11___80
	
	ld a,h			;4
	or l			;4
IF looping = 0
	jp z,exit		;10
ELSE
	jp z,doLoop		;10
ENDIF
	ld (ptnPointer),hl	;16
	ld hl,task_read_ptn	;10
	
	ld a,0			;7		;timing
	ld a,iyh		;8		;load output state ch2
	out (#fe),a		;11___80
	
	ld (seqPointer),sp	;20
taskPointer_rs equ $+1
	ld sp,0			;10
	
	push hl			;11		;push event on task stack
	
	exx			;4
	nop			;4
	ld a,h			;4		;cheating a bit with noise output
	out (#fe),a		;11___64
	jp soundLoop		;10		;-1t, oh well


doLoop
	ld hl,mloop		;10
	ld (seqPointer),hl	;16
	
	exx			;4
	nop			;4
	ld a,iyh		;8
	out (#fe),a		;11___81 (+1)
	
	ld sp,(taskPointer_rs)	;20
	dec sp			;6		;task_read_seq is already on stack, just need to adjust pos
	dec sp			;6
	
	ld a,(noiseVolume)	;13		;load noise output state
	cp h			;4
	sbc a,a			;4
	out (#fe),a		;11___64
	jp soundLoop		;10
check
;*******************************************************************************
IF (LOW($))!=0
	org 256*(1+(HIGH($)))
ENDIF
bitCmdLookup
	db 0
	db #48					;bit 1,b
	ds 2,#50				;bit 2,b
	ds 4,#58				;bit 3,b
	ds 8,#60				;bit 4,b
	ds #10,#68				;bit 5,b
	ds #20,#70				;bit 6,b
	db #78					;bit 7,b (engine will crash if B < #48)
	
;*******************************************************************************	
task_read_ptn					;determine which channels will be reloaded, and push events to taskStack accordingly
						;btw if possible, saving sp to hl' (ld hl,0, add hl,sp : ld sp,hl) is slightly faster than via mem (27t vs 30t)
						;also, ld hl,mem_addr, ld a,(hl), ld (hl),a is faster than ld a,(mem_addr), ld (mem_addr),a (24 vs 26t)
	ld (taskPointer_rp),sp	;20
ptnPointer equ $+1
	ld sp,0			;10
	pop af			;11
	ld i,a			;9		;timer hi
	
	ld a,ixh		;8
	out (#fe),a		;11___80
	
	jr z,prepareSeqRead	;12/7
	
	ld (ptnPointer),sp	;20		;TODO unaccounted for timing
	
taskPointer_rp equ $+1
	ld sp,0			;10
	exx			;4
	
	jp m,noUpdateNoise	;10
	
	ld hl,task_read_noise	;10
	push hl			;11
	jp pe,noUpdateCh2	;10
	
	ld a,iyh		;8
	out (#fe),a		;11__81 hmmok
	
	ld hl,task_read_ch2	;10
	push hl			;11
	jp c,noUpdateCh1	;10

	ld hl,task_read_ch1	;10
	push hl			;11
	exx			;4
	
	ld a,h			;4		;fake noise output
	out (#fe),a		;11__71 hmmmm
	jp soundLoop		;10
	
		
prepareSeqRead
	ld sp,(taskPointer_rp)	;20
	exx			;4
	ld hl,task_read_seq	;10
	push hl			;11
	exx			;4
	
	ld a,iyh		;8
	out (#fe),a		;11___80
	
	ld a,0			;7		;timing
	ld a,0			;7		;timing
	ld a,0			;7		;timing
	ld a,0			;7		;timing
	nop			;4
	ld a,(noiseVolume)	;13
	cp h			;4
	sbc a,a			;4
	out (#fe),a		;11__64
	jp soundLoop		;10
	

noUpdateNoise
	jp pe,noUpdateCh2	;10
	ld hl,task_read_ch2	;10
	push hl			;11
	
	ld a,iyh		;8
	out (#fe),a		;11__81
	
	jp c,noUpdateCh1	;10
	
	ld hl,task_read_ch1	;10
	push hl			;11
	exx			;4
	ld a,(noiseVolume)	;13
	cp h			;4
	sbc a,a			;4
	out (#fe),a		;11__67
	jp soundLoop		;10

	
noUpdateCh2
	ld a,iyh		;8
	out (#fe),a		;11__81
	
	jp c,noUpdateCh1	;10
	
	ld hl,task_read_ch1	;10
	push hl			;11
	exx			;4
	ld a,(noiseVolume)	;13
	cp h			;4
	sbc a,a			;4
	out (#fe),a		;11__67
	jp soundLoop		;10	
	
	

noUpdateCh1
	ld a,r			;9	;timing
	ld a,r			;9	;timing
	exx			;4
	ld a,(noiseVolume)	;13
	cp h			;4
	sbc a,a			;4
	out (#fe),a		;11__64
	jp soundLoop		;10

;*******************************************************************************
task_read_ch1				;update ch1 data
	ld (taskPointer_c1),sp	;20
	ld sp,(ptnPointer)	;20
	pop de			;11	;fetch note divider ch1
	ld a,ixh		;8
	out (#fe),a		;11___81
	
	ld a,d			;4
	add a,a			;4
	jr c,noFxReloadCh1	;12/7	;if MSB of divider was set, skip fx
	
	pop bc			;11	;retrieve fx setting
	ld (ptnPointer),sp	;20
	
	ld a,b			;4
	add a,a			;4
	ld a,iyh		;8
	jr z,doSlideCh1		;12/7	;if (B != 0) && (B != #80) do vibrato
	
	out (#fe),a		;11___80

	ld ix,0			;14	;reset channel accu
	
taskPointer_c1 equ $+1
	ld sp,0			;10

	exx			;4
	ld hl,task_read_vib1	;10	;we can't complete vibrato setup in this round,
	push hl			;11	;so let's push another task
	exx			;4
	
	out (#fe),a		;11___64
	jp soundLoop		;10


noFxReloadCh1
	ccf			;4	;clear bit 15 of base divider
	rrca			;4
	ld d,a			;4
	
	ld a,r			;9	;timing
	ld (ptnPointer),sp	;20
	ld a,iyh		;8
	out (#fe),a		;11___80
	
	ld sp,(taskPointer_c1)	;20
	ld ix,0			;14	;reset channel accu
	
vibrInit1 equ $+1
	ld b,0			;7	;reset vibrato init value
	ld a,0			;7	;timing
	nop			;4

	ld a,h			;4	;fake noise
	out (#fe),a		;11___64	
	jp soundLoop		;10


doSlideCh1
	out (#fe),a		;11___85 cough cough
	
	ld sp,(taskPointer_c1)	;20	
	jp c,doSlideUpCh1	;10	;determine slide direction
	
	ld a,#c3		;7	;jp = slide down
	ld (fxType1),a		;13

	ld a,h			;4	
	out (#fe),a		;11___65 fake noise
	jp soundLoop		;10
	
	
doSlideUpCh1
	ld a,#da		;7	;jp c = slide up
	ld (fxType1),a		;13
	
	ld a,h			;4	
	out (#fe),a		;11___65 fake noise
	jp soundLoop		;10	

;*******************************************************************************
task_read_vib1
	ld a,#ca		;7	;jp z = vibrato
	ld (fxType1),a		;13
	
	exx			;4
	dec hl			;6	;timing
	ld hl,(ptnPointer)	;16
	
	nop			;4
	ld a,ixh		;8
	out (#fe),a		;11___80
	
	dec hl			;6
	ld a,(hl)		;7	;peek at vibrato init setting
	ld h,HIGH(bitCmdLookup)	;7	;look up bit x,b command patch
	ld l,a			;4
	
	ld (vibrInit1),a	;13	;store vibrato init setting for later
	ld a,(hl)		;7
	ld (vibrSpeed1),a	;13
	
	exx			;4
	ld a,iyh		;8
	out (#fe),a		;11___80
	
	ds 8			;32
	ld a,(noiseVolume)	;13
	cp h			;4
	sbc a,a			;4
	out (#fe),a		;11___64
	jp soundLoop		;10

;*******************************************************************************
task_read_ch2				;update ch2 data
	ld (taskPointer_c2),sp	;20
	ld sp,(ptnPointer)	;20
	exx			;4
	pop de			;11	;fetch note divider ch2
	ld a,ixh		;8
	out (#fe),a		;11___85
	
	ld a,d			;4
	add a,a			;4
	jr c,noFxReloadCh2	;12/7	;if MSB of divider was set, skip fx
	
	pop hl			;11	;retrieve fx setting
	ld (ptnPointer),sp	;20
	
	ld a,h			;4
	ld b,a			;4
	add a,a			;4
	ld a,iyh		;8
	jr z,doSlideCh2		;12/7	;if (B != 0) && (B != #80) do vibrato
	
	out (#fe),a		;11___84

	ld a,l			;4
	ld (fxDepth2),a		;13
	ld iyh,0		;11	;el cheapo accu reset
	
taskPointer_c2 equ $+1
	ld sp,0			;10

	ld hl,task_read_vib2	;10	;we can't complete vibrato setup in this round,
	push hl			;11	;so let's push another task
	exx			;4
	
	out (#fe),a		;11___74 hrrm
	jp soundLoop		;10


noFxReloadCh2
	ccf			;4	;clear bit 15 of base divider
	rrca			;4
	ld d,a			;4
	
	ld a,r			;9	;timing
	ld (ptnPointer),sp	;20
	ld a,iyh		;8
	out (#fe),a		;11___80
	
	ld sp,(taskPointer_c2)	;20
	ld iy,0			;14	;reset channel accu
	
vibrInit2 equ $+1
	ld b,0			;7	;reset vibrato init value
	ld a,0			;7	;timing
	exx			;4

	ld a,h			;4	;fake noise
	out (#fe),a		;11___64	
	jp soundLoop		;10


doSlideCh2
	out (#fe),a		;11___85 cough cough
	
	exx			;4
	ld sp,(taskPointer_c2)	;20	
	jr nc,doSlideDownCh2	;12/7	;determine slide direction
	ld a,#da		;7	;jp c = slide up
	ld (fxType2),a		;13
	
	ld a,h			;4	
	out (#fe),a		;11___66 fake noise
	jp soundLoop		;10

doSlideDownCh2	
	ld a,#c3		;7	;jp = slide down
	ld (fxType2),a		;13
	
	out (#fe),a		;11___67 fake noise (A = #c3, so will always output 0)
	jp soundLoop		;10	

;*******************************************************************************
task_read_vib2
	ld a,#ca		;7	;jp z = vibrato
	ld (fxType2),a		;13
	
	exx			;4
	dec hl			;6	;timing
	ld hl,(ptnPointer)	;16
	
	nop			;4
	ld a,ixh		;8
	out (#fe),a		;11___80
	
	dec hl			;6
	ld a,(hl)		;7	;peek at vibrato init setting
	ld h,HIGH(bitCmdLookup)	;7	;look up bit x,b command patch
	ld l,a			;4
	
	ld (vibrInit2),a	;13	;store vibrato init setting for later
	ld a,(hl)		;7
	ld (vibrSpeed2),a	;13
	
	exx			;4
	ld a,iyh		;8
	out (#fe),a		;11___80
	
	ds 8			;32
	ld a,(noiseVolume)	;13
	cp h			;4
	sbc a,a			;4
	out (#fe),a		;11___64
	jp soundLoop		;10

;*******************************************************************************
task_read_noise
	ld (taskPointer_n),sp	;20
	ld sp,(ptnPointer)	;20
	pop hl			;11
	ld a,ixh		;8
	out (#fe),a		;11___81
	
	ld (ptnPointer),sp	;20
	ld a,h			;4
	ld (noisePitch),a	;13
	
	ld a,l			;4
	ld (noiseVolume),a	;13
	
	ld a,0			;7	;timing
	ld a,iyh		;8
	out (#fe),a		;11___80
	
	ld a,0			;7	;timing
	ex af,af'		;4
	ld a,h			;4	;update prescaler
	ex af,af'		;4
taskPointer_n equ $+1
	ld sp,0			;10	
	ld hl,1			;10
	
	xor a			;4
	out (#fe),a		;11___64
	jp soundLoop		;10

;*******************************************************************************