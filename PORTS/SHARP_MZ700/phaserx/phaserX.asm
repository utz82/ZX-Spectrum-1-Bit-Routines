;PhaserX
;by utz 09'2016 * www.irrlichtproject.de
;Sharp MZ-700 port by MooZ 03'2018 * https://blog.blockos.org/
;*******************************************************************************

;include	"equates.h"
mix_xor equ #ac00
mix_or	equ #b400
mix_and equ #a400
fsid	equ #4
fnoise	equ #80
noupd1	equ #1
noupd2	equ #40
kick	equ #1
hhat	equ #80
ptnend	equ #40
rest	equ 0

a0	 equ #e4
ais0	 equ #f1
b0	 equ #100
c1	 equ #10f
cis1	 equ #11f
d1	 equ #130
dis1	 equ #142
e1	 equ #155
f1	 equ #169
fis1	 equ #17f
g1	 equ #196
gis1	 equ #1ae
a1	 equ #1c7
ais1	 equ #1e2
b1	 equ #1ff
c2	 equ #21d
cis2	 equ #23e
d2	 equ #260
dis2	 equ #284
e2	 equ #2aa
f2	 equ #2d3
fis2	 equ #2fe
g2	 equ #32b
gis2	 equ #35b
a2	 equ #38f
ais2	 equ #3c5
b2	 equ #3fe
c3	 equ #43b
cis3	 equ #47b
d3	 equ #4bf
dis3	 equ #508
e3	 equ #554
f3	 equ #5a5
fis3	 equ #5fb
g3	 equ #656
gis3	 equ #6b7
a3	 equ #71d
ais3	 equ #789
b3	 equ #7fc
c4	 equ #876
cis4	 equ #8f6
d4	 equ #97f
dis4	 equ #a0f
e4	 equ #aa9
f4	 equ #b4b
fis4	 equ #bf7
g4	 equ #cad
gis4	 equ #d6e
a4	 equ #e3a
ais4	 equ #f13
b4	 equ #ff8
c5	 equ #10eb
cis5	 equ #11ed
d5	 equ #12fe
dis5	 equ #141f
e5	 equ #1551
f5	 equ #1696
fis5	 equ #17ed
g5	 equ #195a
gis5	 equ #1adc
a5	 equ #1c74
ais5	 equ #1e26
b5	 equ #1ff0
c6	 equ #21d7
cis6	 equ #23da
d6	 equ #25fb
dis6	 equ #283e
e6	 equ #2aa2
f6	 equ #2d2b
fis6	 equ #2fdb
g6	 equ #32b3
gis6	 equ #35b7
a6	 equ #38e9
ais6	 equ #3c4b
b6	 equ #3fe1
c7	 equ #43ad
cis7	 equ #47b3
d7	 equ #4bf7
dis7	 equ #507b
e7	 equ #5544
f7	 equ #5a56
fis7	 equ #5fb6
g7	 equ #6567
gis7	 equ #6b6e
a7	 equ #71d1


BORDER equ #14

;	org #8000
    org #1200

	di

    out (0x0e0), a
	out	(0x0e3), a

    ld hl, 0xe008 ;sound on
    ld (hl), 0x01


	exx
	push hl			;preserve HL' for return to BASIC
	ld (oldSP),sp
	ld hl,musicData
	ld (seqpntr),hl
	ld iyl,0		;remit lo

;*******************************************************************************
rdseq
seqpntr equ $+1
	ld sp,0
	xor a
	pop de			;pattern pointer to DE
	or d
	ld (seqpntr),sp
	jr nz,rdptn0

	;jp exit		;uncomment to disable looping
	ld sp,loop		;get loop point
	jr rdseq+3

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
	ld (ptnpntr),de

readPtn
;	in a,(#fe)		;read kbd
;	cpl
;	and #1f
;	jr nz,exit


ptnpntr equ $+1
	ld sp,0

	pop af			;speed + drums
	jr z,rdseq

	jp c,drum1
	jp m,drum2

	ex af,af'      ;'
drumret

	pop af			;flags + mix_method (xor = #ac, or = #b4, and = a4)
	ld (mixMethod),a

	jr c,noUpdateCh1

	exx

	ld a,#9f		;sbc a,a
	jp pe,setSid

	ld a,#97		;sub a,a

setSid
	ld (sid),a

	ld hl,#04cb		;rlc h
	jp m,setNoise

	ld hl,#0

setNoise
	ld (noise),hl

	pop bc			;dutymod/duty 1
	ld a,b
	ld (dutymod1),a

	pop de			;freq1
	ld hl,0			;reset ch1 accu

	exx

noUpdateCh1
	jr z,noUpdateCh2

	pop hl			;dutymod 2a/b
	ld a,h
	ld (dutymod2a),a
	ld a,l
	ld (dutymod2b),a

	pop bc			;duty 2a/b

	pop de			;freq 2a
	pop hl			;freq 2b
	ld (freq2b),hl

	pop ix			;phase 2b
	ld hl,0			;reset ch2a accu


noUpdateCh2
	ld (ptnpntr),sp
freq2b equ $+1
	ld sp,0


;*******************************************************************************
playNote
	exx			;4

	add hl,de		;11
sid
	sbc a,a			;4	;replace with sub a for no sid
	ld b,a			;4	;temp
	add a,c			;4	;c = duty
	ld c,a			;4

	ld a,b			;4
dutymod1 equ $+1
	and #0			;7
	xor c			;4
	ld c,a			;4

	cp h			;4
	sbc a,a			;4

noise
	ds 2			;8	;replace with rlc h for noise
	exx             ;4

	add hl,de		;11

	and #08
    or  #20
    ld  (0xe007), a
;	out (#fe),a		;11___104

	sbc a,a			;4
dutymod2a equ $+1
	and #0			;7
	xor b			;4
	ld b,a			;4
	cp h			;4
	sbc a,a			;4
	ld iyh,a		;8

	add ix,sp		;15
	sbc a,a			;4
dutymod2b equ $+1
	and #0			;7
	xor c			;4
	ld c,a			;4
	cp ixh			;8
	sbc a,a			;4

mixMethod equ $+1
	and iyh			;8

	dec iyl			;8
	jr nz,skipTimerHi	;12

	ex af,af'
	dec a
	jp z,readPtn
	ex af,af'

skipTimerHi
    and #08
    or  #20
    ld  (0xe007), a
;	out (#fe),a		;11___120

	jr playNote		;12
				;224


;*******************************************************************************
drum2
	ld (restoreHL),hl
	ld (restoreBC),bc
	ex af,af'
	ld hl,hat1
	ld b,hat1end-hat1
	jr drentry
drum1
	ld (restoreHL),hl
	ld (restoreBC),bc
	ex af,af'
	ld hl,kick1		;10
	ld b,kick1end-kick1	;7
drentry
	ld a, 0x20		;4
_s2
	xor 0x8  		;7
	ld c,(hl)		;7
	inc hl			;6
_s1
    ld  (0xe007), a
;	out (#fe),a		;11
	dec c			;4
	jr nz,_s1		;12/7

	djnz _s2		;13/8
	ld iyl,#11		;7	;correct tempo
restoreHL equ $+1
	ld hl,0
restoreBC equ $+1
	ld bc,0
	jp drumret		;10

kick1					;27*16*4 + 27*32*4 + 27*64*4 + 27*128*4 + 27*256*4 = 53568, + 20*33 = 53568 -> -239 loops -> AF' = #11
	ds 4,#10
	ds 4,#20
	ds 4,#40
	ds 4,#80
	ds 4,0
kick1end

hat1
	db 16,3,12,6,9,20,4,8,2,14,9,17,5,8,12,4,7,16,13,22,5,3,16,3,12,6,9,20,4,8,2,14,9,17,5,8,12,4,7,16,13,22,5,3
	db 12,8,1,24,6,7,4,9,18,12,8,3,11,7,5,8,3,17,9,15,22,6,5,8,11,13,4,8,12,9,2,4,7,8,12,6,7,4,19,22,1,9,6,27,4,3,11
	db 5,8,14,2,11,13,5,9,2,17,10,3,7,19,4,3,8,2,9,11,4,17,6,4,9,14,2,22,8,4,19,2,3,5,11,1,16,20,4,7
	db 8,9,4,12,2,8,14,3,7,7,13,9,15,1,8,4,17,3,22,4,8,11,4,21,9,6,12,4,3,8,7,17,5,9,2,11,17,4,9,3,2
	db 22,4,7,3,8,9,4,11,8,5,9,2,6,2,8,8,3,11,5,3,9,6,7,4,8
hat1end

musicData
;	include "music.asm"
;sequence

	dw mdb_Patterns_pattern00
	dw mdb_Patterns_blk0
	dw mdb_Patterns_blk24
	dw mdb_Patterns_blk1
	dw mdb_Patterns_blk2
	dw mdb_Patterns_blk4
	dw mdb_Patterns_blk6
	dw mdb_Patterns_blk23
	dw mdb_Patterns_blk3
	dw mdb_Patterns_blk5
	dw mdb_Patterns_blk7
	dw mdb_Patterns_blk8
	dw mdb_Patterns_blk9
	dw mdb_Patterns_blk10
loop
	dw mdb_Patterns_blk11
	dw mdb_Patterns_blk12
	dw mdb_Patterns_blk11
	dw mdb_Patterns_blk13
	dw mdb_Patterns_blk14
	dw mdb_Patterns_blk15
	dw mdb_Patterns_blk18
	dw mdb_Patterns_blk19
	dw mdb_Patterns_blk20
	dw mdb_Patterns_blk20
	dw mdb_Patterns_blk20
	dw mdb_Patterns_blk21
	dw mdb_Patterns_blk22
	dw 0


mdb_Patterns_pattern00

	dw $800, $ac04, $80, b3, 0, $8080, 0, 0, 0
	dw $800, $ac44, $80, a3
	dw $800, $ac44, $80, g3
	dw $800, $ac44, $80, a3
	dw $800, $ac44, $80, g3
	dw $800, $ac44, $80, d3
	db $40



mdb_Patterns_blk0

	dw $401, $ac04, $4010, e2, $4010, $1080, e1, e1+1, 0
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac44, $4010, rest
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $401, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac80, $4040, gis4, $4010, $1080, e2, e1+1, $400
	dw $400, $acc0, $4020, gis4
	dw $400, $acc0, $4010, gis4
	dw $400, $acc1
	dw $400, $acc0, $4008, gis4
	dw $400, $ac40, $4008, rest
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac04, $4010, e2, $4010, $1080, e1, e1+1, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac44, $4010, rest
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $401, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac04, $4010, g2, $4010, $1080, g1, g1+1, $400
	dw $400, $ac45
	dw $400, $ac04, $4010, e2, $4010, $1080, e1, e1+1, $400
	dw $400, $ac45
	dw $401, $ac04, $4010, g2, $4010, $1080, g1, g1+1, $400
	dw $400, $ac45
	dw $480, $ac04, $4010, b2, $4010, $1080, b1, b1+1, $400
	dw $400, $ac45
	dw $400, $ac04, $4010, a2, $4010, $1080, a1, a1+1, $400
	dw $400, $ac45
	dw $401, $ac04, $4010, g2, $4010, $1080, g1, g1+1, $400
	dw $400, $ac45
	db $40



mdb_Patterns_blk24

	dw $401, $ac04, $4010, e2, $4010, $1080, e1, e1+1, 0
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac44, $4010, rest
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $401, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac80, $4040, gis4, $4010, $1080, e2, e1+1, $400
	dw $400, $acc0, $4020, gis4
	dw $400, $acc0, $4010, gis4
	dw $400, $acc1
	dw $400, $acc0, $4008, gis4
	dw $400, $ac40, $4008, rest
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac04, $4010, e2, $4010, $1080, e1, e1+1, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac44, $4010, rest
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $401, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac04, $4010, g2, $4010, $1080, g1, g1+1, $400
	dw $400, $ac45
	dw $400, $ac04, $4010, e2, $4010, $1080, e1, e1+1, $400
	dw $400, $ac45
	dw $401, $ac04, $4010, g2, $4010, $1080, g1, g1+1, $400
	dw $400, $ac45
	dw $480, $ac04, $4010, b2, $4010, $1080, b1, b1+1, $400
	dw $400, $ac45
	dw $480, $ac04, $4010, a2, $4010, $1080, a1, a1+1, $400
	dw $400, $ac45
	dw $480, $ac04, $4010, g2, $4010, $1080, g1, g1+1, $400
	dw $400, $ac45
	db $40



mdb_Patterns_blk1

	dw $401, $ac04, $4080, a2, $4010, $1080, a1, a1+1, 0
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac44, $4080, rest
	dw $400, $ac04, $4080, a1, $4010, $1080, a1, a1+1, $400
	dw $400, $ac04, $4080, rest, $4010, $1080, rest, a1+1, $400
	dw $400, $ac04, $4080, a1, $4010, $1080, a1, a1+1, $400
	dw $400, $ac04, $4080, rest, $4010, $1080, rest, a1+1, $400
	dw $401, $ac04, $4080, a1, $4010, $1080, a1, a1+1, $400
	dw $401, $ac04, $4080, rest, $4010, $1080, rest, a1+1, $400
	dw $401, $ac80, $40, gis4, $4010, $1080, a1, a1+1, $400
	dw $400, $acc0, $20, gis4
	dw $400, $acc0, $10, gis4
	dw $400, $acc1
	dw $400, $acc0, $8, gis4
	dw $400, $ac40, $8, rest
	dw $400, $ac04, $4010, a1, $4010, $1080, a1, a1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, a1+1, $400
	dw $400, $ac04, $4010, a1, $4010, $1080, a1, a1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, a1+1, $400
	dw $401, $ac04, $4010, a1, $4010, $1080, a1, a1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, a1+1, $400
	dw $401, $ac04, $4010, a2, $4010, $1080, a1, a1+1, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac44, $4010, rest
	dw $400, $ac04, $4010, a1, $4010, $1080, a1, a1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, a1+1, $400
	dw $400, $ac04, $4010, a1, $4010, $1080, a1, a1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, a1+1, $400
	dw $401, $ac04, $4010, a1, $4010, $1080, a1, a1+1, $400
	dw $401, $ac04, $4010, rest, $4010, $1080, rest, a1+1, $400
	dw $401, $ac04, $4010, a2, $4010, $1080, a1, a1+1, $400
	dw $400, $ac45
	dw $400, $ac04, $4010, g2, $4010, $1080, g1, g1+1, $400
	dw $400, $ac45
	dw $401, $ac04, $4010, a2, $4010, $1080, a1, a1+1, $400
	dw $400, $ac45
	dw $480, $ac04, $4010, b2, $4010, $1080, b1, b1+1, $400
	dw $400, $ac45
	dw $400, $ac04, $4010, a2, $4010, $1080, a1, a1+1, $400
	dw $400, $ac45
	dw $401, $ac04, $4010, g2, $4010, $1080, g1, g1+1, $400
	dw $400, $ac45
	db $40



mdb_Patterns_blk2

	dw $401, $ac04, $4080, a2, $4010, $1080, a1, a1+1, 0
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac44, $4080, rest
	dw $400, $ac04, $4080, a1, $4010, $1080, a1, a1+1, $400
	dw $400, $ac04, $4080, rest, $4010, $1080, rest, a1+1, $400
	dw $400, $ac04, $4080, a1, $4010, $1080, a1, a1+1, $400
	dw $400, $ac04, $4080, rest, $4010, $1080, rest, a1+1, $400
	dw $401, $ac04, $4080, a1, $4010, $1080, a1, a1+1, $400
	dw $401, $ac04, $4080, rest, $4010, $1080, rest, a1+1, $400
	dw $401, $ac80, $4040, gis4, $4010, $1080, a1, a1+1, $400
	dw $400, $acc0, $4020, gis4
	dw $400, $acc0, $4010, gis4
	dw $400, $acc1
	dw $400, $acc0, $4008, gis4
	dw $400, $ac40, $4008, rest
	dw $400, $ac04, $4010, a1, $4010, $1080, a1, a1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, a1+1, $400
	dw $400, $ac04, $4010, a1, $4010, $1080, a1, a1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, a1+1, $400
	dw $401, $ac04, $4010, a1, $4010, $1080, a1, a1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, a1+1, $400
	dw $401, $ac04, $4010, b2, $4010, $1080, b1, b1+1, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac44, $4010, rest
	dw $400, $ac04, $4010, b1, $4010, $1080, b1, b1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, b1+1, $400
	dw $400, $ac04, $4010, b1, $4010, $1080, b1, b1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, b1+1, $400
	dw $401, $ac04, $4010, b1, $4010, $1080, b1, b1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, b1+1, $400
	dw $401, $ac04, $4010, b2, $4010, $1080, b1, b1+1, $400
	dw $401, $ac45
	dw $401, $ac04, $4010, a2, $4010, $1080, a1, a1+1, $400
	dw $401, $ac45
	dw $401, $ac04, $4010, g2, $4010, $1080, g1, g1+1, $400
	dw $401, $ac45
	dw $401, $ac04, $4010, b2, $4010, $1080, b1, b1+1, $400
	dw $401, $ac45
	dw $401, $ac04, $4010, a2, $4010, $1080, a1, a1+1, $400
	dw $401, $ac45
	dw $401, $ac04, $4010, g2, $4010, $1080, g1, g1+1, $400
	dw $401, $ac45
	db $40



mdb_Patterns_blk4

	dw $401, $ac04, $8040, e1, $2040, $1010, b4, b3+1, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $480, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac04, $8040, e1, $2040, $1010, e4, e3+1, $400
	dw $400, $ac45
	dw $401, $ac04, $8040, e1, $2040, $1010, a4, a3+1, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $400, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $400, $ac05, $2040, $1010, fis4, fis3+1, $400
	dw $400, $ac45
	dw $401, $ac05, $2040, $1010, g4, g3+1, $400
	dw $400, $ac45
	dw $401, $ac84, $8040, gis4, $2040, $1010, a4, a3+1, $400
	dw $400, $acc4, $8020, gis4
	dw $401, $ac04, $8040, e1, $2040, $1010, g4, g3+1, $400
	dw $400, $ac45
	dw $401, $ac05, $2040, $1010, fis4, fis3+1, $400
	dw $400, $ac45
	db $40



mdb_Patterns_blk6

	dw $401, $ac04, $8040, e1, $2040, $1010, g4, g3+2, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $400, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac04, $8040, e1, $2040, $1010, fis4, fis3+2, $400
	dw $401, $ac45
	dw $401, $ac04, $8040, e1, $2040, $1010, e4, e3+2, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac45
	dw $400, $ac45
	dw $401, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $400, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, g1
	dw $400, $ac45
	dw $401, $b404, $8040, fis3, $2040, $c0f0, e2, fis3, $400
	dw $400, $b445
	dw $401, $b404, $8040, g3, $2040, $c0f0, g2, g3, $400
	dw $400, $b445
	dw $401, $b480, $8040, gis4, $2040, $c0f0, b2, b3, $400
	dw $400, $b4c0, $8020, gis4
	dw $401, $b404, $8040, g3, $2040, $c0f0, a2, g3, $400
	dw $401, $b445
	dw $401, $b404, $8040, fis3, $2040, $c0f0, g2, fis3, $400
	dw $400, $b445
	db $40



mdb_Patterns_blk23

	dw $401, $ac04, $8040, e1, $2040, $1010, b4, b3+1, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $480, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac04, $8040, e1, $2040, $1010, e4, e3+1, $400
	dw $400, $ac45
	dw $401, $ac04, $8040, e1, $2040, $1010, a4, a3+1, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $400, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $400, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $400, $ac05, $2040, $1010, fis4, fis3+1, $400
	dw $400, $ac45
	dw $401, $ac05, $2040, $1010, g4, g3+1, $400
	dw $400, $ac45
	dw $401, $ac84, $8040, gis4, $2040, $1010, a4, a3+1, $400
	dw $400, $acc4, $8020, gis4
	dw $401, $ac04, $8040, e1, $2040, $1010, g4, g3+1, $400
	dw $401, $ac45
	dw $401, $ac05, $2040, $1010, fis4, fis3+1, $400
	dw $400, $ac45
	db $40



mdb_Patterns_blk3

	dw $401, $ac04, $8020, e1, $2040, $1010, g4, g3+2, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8020, gis4
	dw $400, $acc0, $8020, gis4
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac45
	dw $400, $ac45
	dw $401, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $400, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, g1
	dw $400, $ac45
	dw $401, $b404, $8040, fis3, $2040, $c0f0, e2, fis3, $400
	dw $400, $b445
	dw $401, $b404, $8040, g3, $2040, $c0f0, g2, g3, $400
	dw $400, $b445
	dw $401, $b480, $8040, gis4, $2040, $c0f0, b2, b3, $400
	dw $401, $b4c0, $8020, gis4
	dw $401, $b404, $8040, g3, $2040, $c0f0, a2, g3, $400
	dw $400, $b445
	dw $401, $b404, $8040, fis3, $2040, $c0f0, g2, fis3, $400
	dw $400, $b445
	db $40



mdb_Patterns_blk5

	dw $401, $ac04, $8040, a1, $2040, $1010, c5, c4+1, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $480, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $401, $ac44, $8040, a1
	dw $400, $ac45
	dw $401, $ac04, $8040, a1, $2040, $1010, b4, b3+1, $400
	dw $400, $ac45
	dw $401, $ac04, $8040, a1, $2040, $1010, a4, a3+2, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $401, $ac44, $8040, a1
	dw $400, $ac45
	dw $401, $ac44, $8040, a1
	dw $400, $ac45
	dw $401, $ac44, $8040, a1
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $400, $ac44, $8040, a1
	dw $400, $ac45
	dw $401, $ac44, $8040, a1
	dw $401, $ac45
	dw $401, $ac44, $8040, a1
	dw $400, $ac45
	dw $400, $ac05, $2040, $1010, fis4, fis3+1, $400
	dw $400, $ac45
	dw $401, $ac05, $2040, $1010, g4, g3+1, $400
	dw $400, $ac45
	dw $401, $ac84, $8040, gis4, $2040, $1010, a4, a3+1, $400
	dw $400, $acc4, $8020, gis4
	dw $401, $ac04, $8040, a1, $2040, $1010, g4, g3+1, $400
	dw $400, $ac45
	dw $401, $ac05, $2040, $1010, fis4, fis3+1, $400
	dw $400, $ac45
	db $40



mdb_Patterns_blk7

	dw $401, $ac04, $8040, a1, $2040, $1010, c5, c4+1, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $400, $ac44, $8040, a1
	dw $400, $ac45
	dw $401, $ac44, $8040, a1
	dw $401, $ac45
	dw $401, $ac44, $8040, a1
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $401, $ac44, $8040, a1
	dw $400, $ac45
	dw $401, $ac45
	dw $400, $ac45
	dw $401, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $400, $ac44, $8040, a1
	dw $400, $ac45
	dw $401, $ac44, $8040, a1
	dw $400, $ac45
	dw $401, $ac04, $8040, g1, $2040, $1010, e5, e4, $400
	dw $400, $ac45
	dw $401, $ac04, $8040, fis3, $2040, $1010, d5, d4, $400
	dw $400, $ac45
	dw $401, $ac04, $8040, g3, $2040, $1010, c5, c4, $400
	dw $400, $ac45
	dw $401, $ac80, $8040, gis4, $2040, $1010, d5, d4, $400
	dw $400, $acc0, $8020, gis4
	dw $401, $ac04, $8040, g3, $2040, $1010, c5, c4, $400
	dw $401, $ac45
	dw $401, $ac04, $8040, fis3, $2040, $1010, d4, d3, $400
	dw $400, $ac45
	db $40



mdb_Patterns_blk8

	dw $401, $ac04, $8040, e1, $2040, $1010, b4, b3+1, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $480, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac04, $8040, e1, $2040, $1010, a4, a3+1, $400
	dw $400, $ac45
	dw $401, $ac04, $8040, e1, $2040, $1010, g4, g3+2, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $480, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $400, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $400, $ac05, $2040, $1010, fis4, fis3+1, $400
	dw $400, $ac45
	dw $401, $ac05, $2040, $1010, g4, g3+1, $400
	dw $400, $ac45
	dw $401, $ac84, $8040, gis4, $2040, $1010, a4, a3+1, $400
	dw $400, $acc4, $8020, gis4
	dw $401, $ac04, $8040, e1, $2040, $1010, g4, g3+1, $400
	dw $400, $ac45
	dw $401, $ac05, $2040, $1010, fis4, fis3+1, $400
	dw $400, $ac45
	db $40



mdb_Patterns_blk9

	dw $401, $ac04, $8040, e1, $2040, $1010, b4, b3+1, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $400, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $401, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac45
	dw $400, $ac45
	dw $401, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $400, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac04, $8040, g1, $2040, $1010, e5, e4, $400
	dw $400, $ac45
	dw $401, $ac04, $8040, fis3, $2040, $1010, d5, d4, $400
	dw $400, $ac45
	dw $401, $ac04, $8040, g3, $2040, $1010, c5, c4, $400
	dw $400, $ac45
	dw $401, $ac80, $8040, gis4, $2040, $1010, d5, d4, $400
	dw $400, $acc0, $8020, gis4
	dw $401, $ac04, $8040, g3, $2040, $1010, c5, c4, $400
	dw $401, $ac45
	dw $401, $ac04, $8040, fis3, $2040, $1010, d4, d3, $400
	dw $400, $ac45
	db $40



mdb_Patterns_blk10

	dw $401, $a480, $60, gis4, $400, $808, e3, e3+1, 0
	dw $400, $a4c0, $40, gis4
	dw $400, $a4c0, $20, gis4
	dw $400, $a4c0, $10, gis4
	dw $400, $a4c1
	dw $400, $a4c0, $8, gis4
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c0, $4, gis4
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a481, $400, $808, b3, b3+1, 0
	dw $400, $a4c0, $2, gis4
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c0, $1, gis4
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c0, $1, rest
	dw $400, $a4c1
	dw $400, $a481, $400, $808, ais3, ais3+1, 0
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a481, $400, $808, fis3, fis3+1, 0
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	db $40



mdb_Patterns_blk11

	dw $401, $a404, $8020, e1, $4040, $1008, e4, e3+1, 0
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $400, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a404, $8020, b1, $4040, $1008, b4, b3+1, 0
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $400, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a404, $8020, ais1, $4040, $1008, ais4, ais3+1, 0
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $400, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a404, $8020, fis1, $4040, $1008, fis4, fis3+1, 0
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $400, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	db $40



mdb_Patterns_blk12

	dw $401, $a404, $8020, g1, $4040, $1008, g4, g3+1, 0
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a405, $4040, $1008, fis4, fis3+1, 0
	dw $400, $a445
	dw $401, $a405, $4040, $1008, g4, g3+1, 0
	dw $400, $a445
	dw $401, $a405, $4040, $1008, a4, a3+1, 0
	dw $401, $a445
	dw $401, $a405, $4040, $1008, g4, g3+1, 0
	dw $400, $a445
	dw $401, $a405, $4040, $1008, fis4, fis3+1, 0
	dw $400, $a445
	db $40



mdb_Patterns_blk13

	dw $401, $a404, $8020, g1, $4040, $1008, b4, g3+1, 0
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a405, $4040, $1008, a4, fis3+1, 0
	dw $400, $a445
	dw $401, $a405, $4040, $1008, b4, g3+1, 0
	dw $400, $a445
	dw $401, $a405, $4040, $1008, c5, a3+1, 0
	dw $400, $a445
	dw $401, $a405, $4040, $1008, b4, g3+1, 0
	dw $401, $a445
	dw $401, $a405, $4040, $1008, a4, fis3+1, 0
	dw $400, $a445
	db $40



mdb_Patterns_blk14

	dw $401, $a404, $8020, e1, $4040, $1008, g4, e4+1, 0
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $400, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a404, $8020, b1, $4040, $1008, b4, g4+1, 0
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $400, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a404, $8020, ais1, $4040, $1008, ais4, fis4+1, 0
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $400, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a404, $8020, fis1, $4040, $1008, fis4, dis4+1, 0
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $400, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	db $40



mdb_Patterns_blk15

	dw $401, $a404, $8020, g1, $4040, $1008, g4, e4+1, 0
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a405, $4040, $1008, a4, fis3+1, 0
	dw $400, $a445
	dw $401, $a405, $4040, $1008, b4, g3+1, 0
	dw $400, $a445
	dw $401, $a405, $4040, $1008, c5, a3+1, 0
	dw $401, $a445
	dw $401, $a405, $4040, $1008, b4, g3+1, 0
	dw $400, $a445
	dw $401, $a405, $4040, $1008, a4, fis3+1, 0
	dw $400, $a445
	db $40



mdb_Patterns_blk18

	dw $401, $a404, $8020, e1, $4040, $1008, e5, e3+1, 0
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $400, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a404, $8020, b1, $4040, $1008, b5, b3+1, 0
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $400, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a404, $8020, ais1, $4040, $1008, ais5, ais3+1, 0
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $400, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a404, $8020, fis1, $4040, $1008, fis5, fis3+1, 0
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $400, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	db $40



mdb_Patterns_blk19

	dw $401, $a404, $8020, g1, $4040, $1008, g5, b3+1, 0
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a405, $4040, $1008, fis5, fis3+1, 0
	dw $400, $a445
	dw $401, $a405, $4040, $1008, g5, g3+1, 0
	dw $400, $a445
	dw $401, $a405, $4040, $1008, a5, a3+1, 0
	dw $401, $a445
	dw $401, $a404, $8020, fis1, $4040, $1008, g5, g3+1, 0
	dw $400, $a445
	dw $401, $a404, $8020, f1, $4040, $1008, fis5, fis3+1, 0
	dw $400, $a445
	db $40



mdb_Patterns_blk20

	dw $401, $ac04, $4010, e2, $4010, $1080, e3, e1+1, 0
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac44, $4010, rest
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $401, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac80, $4040, gis4, $4010, $1080, e2, e1+1, $400
	dw $400, $acc0, $4020, gis4
	dw $400, $acc0, $4010, gis4
	dw $400, $acc1
	dw $400, $acc0, $4008, gis4
	dw $400, $ac40, $4008, rest
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	db $40



mdb_Patterns_blk21

	dw $401, $ac04, $4010, e2, $4010, $1080, e3, e1+1, 0
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac44, $4010, rest
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $401, $ac44, $4010, rest
	dw $401, $a404, $4010, b1, $4040, $1008, b5, b3+1, $400
	dw $400, $a445
	dw $400, $a404, $4010, a1, $4040, $1008, a5, a3+1, $400
	dw $400, $a445
	dw $400, $a404, $4010, g1, $4040, $1008, g5, g3+1, $400
	dw $400, $a445
	dw $400, $a404, $4010, a1, $4040, $1008, a5, a3+1, $400
	dw $400, $a445
	dw $400, $a404, $4010, g1, $4040, $1008, g5, g3+1, $400
	dw $400, $a445
	dw $400, $a404, $4010, d1, $4040, $1008, d5, d3+1, $400
	dw $400, $a445
	db $40



mdb_Patterns_blk22

	dw $401, $ac04, $4010, e1, $4010, $1080, e1, e1+1, 0
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac04, $4010, rest, $4010, $1080, e1, rest, 0
	dw $400, $ac05, $4010, $1080, rest, rest, 0
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $ac45
	dw $401, $ac45
	dw $401, $a4c0, $60, gis4
	dw $400, $a4c0, $40, gis4
	dw $400, $a4c0, $20, gis4
	dw $400, $a4c1
	dw $400, $a4c0, $10, gis4
	dw $400, $a4c1
	dw $400, $a4c0, $8, gis4
	dw $400, $a4c0, $4, gis4
	dw $400, $a4c0, $2, gis4
	dw $400, $a4c0, $1, gis4
	dw $400, $a4c0, $1, rest
	dw $400, $a4c1
	db $40
