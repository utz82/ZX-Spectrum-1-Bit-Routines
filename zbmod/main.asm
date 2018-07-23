; ZBMOD - 3 channel mod player for ZX Spectrum Beeper
; by utz 06'2016, revised 07'2018
;
; vim: filetype=z80:

NMOS equ 1
CMOS equ 2
EMUL equ 3

IF (CPU=NMOS || CPU=EMUL)
pon equ #10fe
outhi equ #41ed     ;out (c),b
outlo equ #71ed     ;out (c),0
ELSE
pon equ #00fe
outhi equ #71ed     ;out (c),#ff
outlo equ #41ed     ;out (c),b
ENDIF


;olimit equ #80     ;debug

;BC  - output
;HL  - smp.pntr.1
;HL' - smp.pntr.2
;DE' - smp.pntr.3
;DE  - add/base ch1
;BC  - add/base ch2
;IX  - add/base ch3
;IY  - jump val
;A'/I - timer lo/hi

    ;org #8000
    org origin

init
    di
    exx
    push hl         ;preserve HL' for return to BASIC
    ld (oldSP),sp
    ld hl,musicdata
    ld (seqpntr),hl

    ld bc,pon

;******************************************************************
rdseq0
    dw outlo
rdseq
seqpntr equ $+1
    ld sp,0
    xor a
    pop hl          ;pattern pointer to DE
    or h
    ld (seqpntr),sp
    ld sp,hl
IF (CPU = 3)
    ld iy,coreE0
ELSE
    ld iy,core0
ENDIF
    jp nz,pEntryPoint
    
    ;jp exit        ;uncomment to disable looping
    
    ld sp,loop      ;get loop point - comment out when disabling looping
    jr rdseq+3
    
exit
oldSP equ $+1
    ld sp,0
    pop hl
    exx
    ei
    ret

;*******************************************************************************
updateTimer4
    dw 0
updateTimer3
    dw 0
updateTimer2
    dw 0
updateTimer1
    dw 0
updateTimer0
    dw 0
    dw outlo
updateTimer
    ex af,af'
    ld a,i
    dec a
    jr z,_rdnext
    ld i,a
    jp (iy)
_rdnext
    ld iyl,#80
    jp (iy)

smp1reset
    dw 0
smp2reset
    dw 0
smp3reset
    dw 0
smp4reset
    dw 0
maskKempston0
    db #1f
    
;*******************************************************************************
    include "reloadrs.asm"

;*******************************************************************************
IF (LOW($))!=0
    org 256*(1+(HIGH($)))
ENDIF
basec equ (HIGH($))-3

;*******************************************************************************
IF (CPU = EMUL)

coreE0
    dw outlo            ;12__
    ld a,d              ;4      update counter ch1
    add a,e             ;4
    ld d,a              ;4
    jp nc,_nos1upd      ;10

    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs1       ;10
    ld hl,(smp1reset)   ;16

_rs1                    ;(43)
    exx                 ;4
    ld a,b              ;4
    add a,c             ;4
    ld b,a              ;4
    jp nc,_nos2upd      ;10
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jr nz,_norvs2       ;12/7
    ret nz              ;5
    ld hl,(smp2reset)   ;16
    
_rs2                    ;(16)
    exx                 ;4
    
    ld a,ixh            ;8
    jr _aa              ;12
_aa jr _bb              ;12
_bb ds 2                ;8          
    ;_______________________________192
    
    dw outlo            ;12__
    exx                 ;4
    add a,ixl           ;8  
    ld ixh,a            ;8
    jr nc,_nos3upd      ;12/7
    
    inc de              ;6
    ld a,(de)           ;7
    or a                ;4
    jp nz,_norvs3       ;10
    ld de,(smp3reset)   ;20
    
_rs3                    ;(58/20)
    ld a,(de)           ;7
    add a,(hl)          ;7
    exx                 ;4
    
    add a,(hl)          ;7
    add a,basec         ;7
    ld iyh,a            ;8
    ex af,af'           ;4
    dec a               ;4
    jp z,updateTimer    ;10
    ex af,af'           ;4

    jr _cc              ;12
_cc jr _dd              ;12
_dd jr _ee              ;12
_ee jp (iy)             ;8
    ;_______________________________192
    
    
_nos1upd
    ld a,(hl)           ;7
    jr _ff
_ff jr _gg
_norvs1 equ $-1
_gg jr _rs1

_nos2upd
    ld a,r              ;9
    jr _hh
_hh jr _ii
_norvs2 equ $-1
_ii jr _rs2

_nos3upd
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    jr _norvs3+1        ;12

_norvs3 equ $-1
    nop                 ;4
    jr _rs3             ;12
    

CE0noCh2X
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    jr _aa              ;12
_aa ds 2                ;8
    jr CE0noCh2Reload   ;12 (108)

CE0noCh3X
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ret nc              ;5
    jr CE0noCh3Reload   ;12 (+4=109)
    
    
    org 256*((HIGH($)))+#80
    
_rdnext
    dw outlo            ;12__   
    in a,(c)            ;12     ;read kbd
    
    cpl                 ;4
    and #1f             ;7
    jp nz,exit          ;10
pEntryPoint 
    pop af              ;11
    jp m,rdseq          ;10
    ld (CE0hlpr),hl     ;16

    ld i,a              ;9      ;set timer
    ld h,HIGH(smptab)   ;7
    jr z,CE0noCh1X      ;12/7
    
    pop de              ;10     ;smp1/freq1
    ld l,d              ;4
    ld d,0              ;7
    ld a,(hl)           ;7      ;fetch sample reset pointer
    ld (smp1reset),a    ;13
    inc hl              ;6
    ld a,(hl)           ;7
    ld (smp1reset+1),a  ;13
    
    inc hl              ;6
    ld a,(hl)           ;7      ;fetch actual sample pointer
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    ld (CE0hlpr),hl     ;16
    
CE0noCh1Reload          ;(120)
    jp pe,CE0noCh2X     ;10
    exx                 ;4
    
    ld h,HIGH(smptab)   ;7
    pop bc              ;10
    ld l,b              ;4
    ld b,0              ;7
    ld a,(hl)           ;7
    ld (smp2reset),a    ;13     ;fetch sample reset
    inc l               ;4
    ld a,(hl)           ;7
    ld (smp2reset+1),a  ;13
    inc l               ;4
    ld a,(hl)           ;7      ;fetch sample pntr
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    exx                 ;4
    
CE0noCh2Reload          ;(108)  
    jr c,CE0noCh3X      ;12/7
    pop ix              ;14
    exx                 ;4
    ld d,HIGH(smptab)   ;7
    ld e,ixh            ;8
    ld a,(de)           ;7
    ld (smp3reset),a    ;13
    inc e               ;4
    ld a,(de)           ;7
    ld (smp3reset+1),a  ;13
    pop de              ;10     ;smp3 pointer
    exx                 ;4
    ld ixh,0            ;11
    
CE0noCh3Reload equ $-1  ;(4)    ;(109)
    inc hl              ;6      ;timing
CE0hlpr equ $+1
    ld hl,0             ;10     ;restore hl
    xor a               ;4
    ld iyl,a            ;8      ;restore core pointer
    ex af,af'           ;4
    
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ld a,(hl)           ;7
    ds 2                ;8
    jp (iy)             ;8
    ;____________________________576=3*192

CE0noCh1X               ;(12)
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    jr _aa              ;12
_aa ds 2                ;8
    jr CE0noCh1Reload   ;12 (120)


;*******************************************************************************
    org 256*(1+(HIGH($)))
coreE1
    dw outhi            ;12__
    dw outlo            ;12__12
    nop                 ;4
    
    ld a,d              ;4      update counter ch1
    add a,e             ;4
    ld d,a              ;4
    jp nc,_nos1upd      ;10
    
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs1       ;10
    
    ld hl,(smp1reset)   ;16
_rs1                    ;(43)
    exx                 ;4
    
    ld a,b              ;4
    add a,c             ;4
    ld b,a              ;4
    jp nc,_nos2upd      ;10
    
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs2       ;10
    
    ld hl,(smp2reset)   ;16

_rs2
    exx                 ;4
    
    ld a,(hl)           ;7
    ld a,(hl)           ;7          
    jr _xy              ;12
    ;_______________________________192
    
_xy dw outhi            ;12__
    dw outlo            ;12__12
    nop                 ;4
    exx                 ;4

    ld a,ixh            ;8
    add a,ixl           ;8
    ld ixh,a            ;8
    jp nc,_nos3upd      ;10
    
    inc de              ;6
    ld a,(de)           ;7
    or a                ;4
    jp nz,_norvs3       ;10
    
    ld de,(smp3reset)   ;20

_rs3                    ;(47)
    ld a,(de)           ;7 
    add a,(hl)          ;7
    exx                 ;4
    
    add a,(hl)          ;7
    add a,basec         ;7
    ld iyh,a            ;8

    ex af,af'           ;4
    dec a               ;4
    jp z,updateTimer    ;10
    ex af,af'           ;4
    
    ld a,r              ;9
    jp (iy)             ;8
    ;_______________________________192
    
    
_nos1upd
    ld a,(hl)           ;7
    jr _vv
_vv jr _tt
_norvs1 equ $-1
_tt jr _rs1
    
_nos2upd
    ld a,(hl)           ;7
    jr _aa
_aa jr _bb
_norvs2 equ $-1
_bb jr _rs2

_nos3upd
    ld a,(hl)           ;7
    ds 2                ;8
    jr _norvs3          ;12

_norvs3
    ds 2
    jr _rs3

CE1noCh1X
    ex (sp),hl          ;19     1
    ex (sp),hl          ;19 (+12=50)    1
    pop hl              ;10     1
    push hl             ;11     1
    ld a,(hl)           ;7  (78)    1
    dw outhi            ;12     2
    dw outlo            ;12 (106)   2
    nop                 ;4      1   
    jp XCE1noCh1Reload  ;10 (116)   3 (13)

CE1noCh2X
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    jr _ab              ;12
_ab jr CE1noCh2Reload   ;12 (100)
    
    org 256*((HIGH($)))+#80
    
_rdnext
    dw outhi            ;12__
    dw outlo            ;12__12
    nop                  ;4
    
    ld (CE1hlpr),hl     ;16
    
    in a,(c)            ;12     ;read kbd
    cpl                 ;4
    and #1f             ;7
    jp nz,exit          ;10 
    pop af              ;11
    jp m,rdseq          ;10

    ld i,a              ;9      ;set timer
    ld h,HIGH(smptab)   ;7      
    jr z,CE1noCh1X      ;12/7
    
    pop de              ;10     ;smp1/freq1
    ld l,d              ;4
    ld d,0              ;7
    ld a,(hl)           ;7      ;fetch sample reset pointer
    ld (smp1reset),a    ;13
    inc hl              ;6
    ld a,(hl)           ;7
    ld (smp1reset+1),a  ;13
    nop                 ;4
    ;____________________________192 (78)
    dw outhi            ;12
    dw outlo            ;12
    nop                 ;4
    inc hl              ;6
    ld a,(hl)           ;7      ;fetch actual sample pointer
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    ld (CE1hlpr),hl     ;16

CE1noCh1Reload          ;(152)
    exx                 ;4
    jp pe,CE1noCh2X     ;10
    
    ld h,HIGH(smptab)   ;7
    pop bc              ;10
    ld l,b              ;4
    ld b,0              ;7
    ld a,(hl)           ;7
    ld (smp2reset),a    ;13     ;fetch sample reset
    inc l               ;4
    ld a,(hl)           ;7
    ld (smp2reset+1),a  ;13
    inc l               ;4
    ld a,(hl)           ;7      ;fetch sample pntr
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    
CE1noCh2Reload          ;(100)
    exx                 ;4
    ;____________________________192
    
    dw outhi            ;12
    dw outlo            ;12
    nop                 ;4
    exx                 ;4
    jr c,CE1noCh3X      ;12/7
    
    ld d,HIGH(smptab)   ;7
    pop ix              ;14
    ld e,ixh            ;8
    ld a,(de)           ;7
    ld (smp3reset),a    ;13
    inc e               ;4
    ld a,(de)           ;7
    ld (smp3reset+1),a  ;13
    pop de              ;10     ;smp3 pointer
    ld ixh,0            ;11
    jr CE1noCh3Reload   ;12
CE1noCh3Reload              ;(113)
    exx                 ;4
    inc hl              ;6      ;timing
CE1hlpr equ $+1
    ld hl,0             ;10     ;restore hl
    ld a,0              ;7
    ld iyl,a            ;8
    ex af,af'           ;4
    jp (iy)             ;8
    ;____________________________192

CE1noCh3X
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ;nop            ;4          ;TODO: disabled because we're out of bytes
    ;ld a,r         ;9
    ld a,(hl)                   ;... and using this instead which gives -1t
    ld a,(hl)
    jr CE1noCh3Reload   ;12 (+12=113)

    org 256*(1+(HIGH($)))
ENDIF
;*******************************************************************************

core0                       ;volume 0 - 16t
    dw outhi            ;12__
    nop                 ;4
    dw outlo            ;12__16
    
    ld a,d              ;4      update counter ch1
    add a,e             ;4
    ld d,a              ;4
    jp nc,_nos1upd      ;10
    
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs1       ;10
    
    ld hl,(smp1reset)   ;16
_rs1                    ;(43)
    exx                 ;4
    
    ld a,b              ;4
    add a,c             ;4
    ld b,a              ;4
    jp nc,_nos2upd      ;10
    
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs2       ;10
    
    ld hl,(smp2reset)   ;16

_rs2
    exx                 ;4
    
    ld a,(hl)           ;7
    ld a,(hl)           ;7          
    jr _xy              ;12
    ;_______________________________192
    
_xy dw outhi            ;12__
    nop                 ;4
    dw outlo            ;12__16
    exx                 ;4

    ld a,ixh            ;8
    add a,ixl           ;8
    ld ixh,a            ;8
    jp nc,_nos3upd      ;10
    
    inc de              ;6
    ld a,(de)           ;7
    or a                ;4
    jp nz,_norvs3       ;10
    
    ld de,(smp3reset)   ;20

_rs3                    ;(47)
    ld a,(de)           ;7 
    add a,(hl)          ;7
    exx                 ;4
    
    add a,(hl)          ;7
    add a,basec         ;7
    ld iyh,a            ;8

    ex af,af'           ;4
    dec a               ;4
    jp z,updateTimer    ;10
    ex af,af'           ;4
    
    ld a,r              ;9
    jp (iy)             ;8
    ;_______________________________192
    
    
_nos1upd
    ld a,(hl)           ;7
    jr _vv
_vv jr _tt
_norvs1 equ $-1
_tt jr _rs1
    
_nos2upd
    ld a,(hl)           ;7
    jr _aa
_aa jr _bb
_norvs2 equ $-1
_bb jr _rs2

_nos3upd
    ld a,(hl)           ;7
    ds 2                ;8
    jr _norvs3          ;12

_norvs3
    ds 2
    jr _rs3

C0noCh1X
    ex (sp),hl          ;19     1
    ex (sp),hl          ;19 (+12=50)    1
    pop hl              ;10     1
    push hl             ;11     1
    ld a,(hl)           ;7  (78)    1
    dw outhi            ;12     2
    nop                 ;4      1
    dw outlo            ;12 (106)   2   
    jp XC0noCh1Reload   ;10 (116)   3 (13)

C0noCh2X
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    jr _ab              ;12
_ab jr C0noCh2Reload    ;12 (100)
    
    org 256*((HIGH($)))+#80
    
_rdnext
    dw outhi            ;12__
    nop                 ;4
    dw outlo            ;12__16
    
    ld (C0hlpr),hl      ;16
    
    in a,(c)            ;12     ;read kbd
    cpl                 ;4
    and #1f             ;7
    jp nz,exit          ;10
IF (CPU != EMUL)
pEntryPoint
ENDIF   
    pop af              ;11
    jp m,rdseq          ;10

    ld i,a              ;9      ;set timer
    ld h,HIGH(smptab)   ;7      
    jr z,C0noCh1X       ;12/7
    
    pop de              ;10     ;smp1/freq1
    ld l,d              ;4
    ld d,0              ;7
    ld a,(hl)           ;7      ;fetch sample reset pointer
    ld (smp1reset),a    ;13
    inc hl              ;6
    ld a,(hl)           ;7
    ld (smp1reset+1),a  ;13
    nop                 ;4
    ;____________________________192 (78)
    dw outhi            ;12
    nop                 ;4
    dw outlo            ;12
    inc hl              ;6
    ld a,(hl)           ;7      ;fetch actual sample pointer
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    ld (C0hlpr),hl      ;16

C0noCh1Reload           ;(152)
    exx                 ;4
    jp pe,C0noCh2X      ;10
    
    ld h,HIGH(smptab)   ;7
    pop bc              ;10
    ld l,b              ;4
    ld b,0              ;7
    ld a,(hl)           ;7
    ld (smp2reset),a    ;13     ;fetch sample reset
    inc l               ;4
    ld a,(hl)           ;7
    ld (smp2reset+1),a  ;13
    inc l               ;4
    ld a,(hl)           ;7      ;fetch sample pntr
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    
C0noCh2Reload           ;(100)
    exx                 ;4
    ;____________________________192
    
    dw outhi            ;12
    nop                 ;4
    dw outlo            ;12
    exx                 ;4
    jr c,C0noCh3X       ;12/7
    
    ld d,HIGH(smptab)   ;7
    pop ix              ;14
    ld e,ixh            ;8
    ld a,(de)           ;7
    ld (smp3reset),a    ;13
    inc e               ;4
    ld a,(de)           ;7
    ld (smp3reset+1),a  ;13
    pop de              ;10     ;smp3 pointer
    ld ixh,0            ;11
    jr C0noCh3Reload    ;12
C0noCh3Reload           ;(113)
    exx                 ;4
    inc hl              ;6      ;timing
C0hlpr equ $+1
    ld hl,0             ;10     ;restore hl
    ld a,0              ;7
    ld iyl,a            ;8      ;restore core pointer
    ex af,af'           ;4
    jp (iy)             ;8
    ;____________________________192

C0noCh3X
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    nop                 ;4
    ld a,r              ;9
    jr C0noCh3Reload    ;12 (+12=113)
    
;*******************************************************************************
                        ;volume 1 - 24t
IF ((LOW($)) != 0)
    org 256*(1+(HIGH($)))
ENDIF
core1
    dw outhi            ;12__
    nop                 ;4
    ld a,d              ;4      update counter ch1
    add a,e             ;4
    dw outlo            ;12__24
    
    ld d,a              ;4
    jp nc,_nos1upd      ;10
    
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs1       ;10
    
    ld hl,(smp1reset)   ;16
_rs1                    ;(43)
    exx                 ;4
    
    ld a,b              ;4
    add a,c             ;4
    ld b,a              ;4
    jp nc,_nos2upd      ;10
    
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs2       ;10
    
    ld hl,(smp2reset)   ;16

_rs2
    exx                 ;4
    
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    jr _zz              ;12
    ;_______________________________192
    
_zz dw outhi            ;12__
    nop                 ;4
    ld a,ixh            ;8
    dw outlo            ;12__24
    exx                 ;4

    add a,ixl           ;8
    ld ixh,a            ;8
    jp nc,_nos3upd      ;10
    
    inc de              ;6
    ld a,(de)           ;7
    or a                ;4
    jp nz,_norvs3       ;10
    
    ld de,(smp3reset)   ;20

_rs3                    ;(47)
    ld a,(de)           ;7
    add a,(hl)          ;7
    exx                 ;4
    
    add a,(hl)          ;7
    add a,basec         ;7
    ld iyh,a            ;8

    ex af,af'           ;4
    dec a               ;4
    jp z,updateTimer    ;10
    ex af,af'           ;4
    
    ld a,r              ;9
    jp (iy)             ;8
    ;_______________________________192
    
    
_nos1upd
    ld a,(hl)           ;7
    jr _aa
_aa jr _bb
_norvs1 equ $-1
_bb jr _rs1
_nos2upd
    ld a,(hl)           ;7
    jr _cc
_cc jr _dd
_norvs2 equ $-1
_dd jr _rs2
_nos3upd
    ld a,(hl)           ;7
    ds 2                ;8
    jr _norvs3          ;12

_norvs3
    ds 2
    jr _rs3

C1noCh1X
    ex (sp),hl          ;19     1
    ex (sp),hl          ;19 (+12=50)    1
    jp XC1noCh1Reload   ;10 (116)   3 (13)

C1noCh2X
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    jr _ab              ;12
_ab jr C1noCh2Reload    ;12 (100)
    
    org 256*((HIGH($)))+#80
    
_rdnext
    dw outhi            ;12__   
    in a,(c)            ;12     ;read kbd
    dw outlo            ;12__24
    
    nop                 ;4
    ld (C1hlpr),hl      ;16
    
    cpl                 ;4
    and #1f             ;7
    jp nz,exit          ;10
    
    pop af              ;11
    jp m,rdseq          ;10

    ld i,a              ;9      ;set timer
    ld h,HIGH(smptab)   ;7      
    jr z,C1noCh1X       ;12/7
    
    pop de              ;10     ;smp1/freq1
    ld l,d              ;4
    ld d,0              ;7
    ld a,(hl)           ;7      ;fetch sample reset pointer
    ld (smp1reset),a    ;13
    inc hl              ;6
    ld a,(hl)           ;7
    ld (smp1reset+1),a  ;13
    nop                 ;4
    ;____________________________192 (78)
    dw outhi            ;12__
    inc hl              ;6
    ld a,(hl)           ;7      ;fetch actual sample pointer
    dw outlo            ;12__25..naja
    nop                 ;4
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    ld (C1hlpr),hl      ;16

C1noCh1Reload           ;(152)
    exx                 ;4
    jp pe,C1noCh2X      ;10
    
    ld h,HIGH(smptab)   ;7
    pop bc              ;10
    ld l,b              ;4
    ld b,0              ;7
    ld a,(hl)           ;7
    ld (smp2reset),a    ;13     ;fetch sample reset
    inc l               ;4
    ld a,(hl)           ;7
    ld (smp2reset+1),a  ;13
    inc l               ;4
    ld a,(hl)           ;7      ;fetch sample pntr
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    
C1noCh2Reload           ;(100)
    exx                 ;4
    ;____________________________192
    
    dw outhi            ;12__
    jr c,C1noCh3X       ;12/7
    ret c               ;5
    dw outlo            ;12__24
    exx                 ;4
    
    ld d,HIGH(smptab)   ;7
    pop ix              ;14
    ld e,ixh            ;8
    ld a,(de)           ;7
    ld (smp3reset),a    ;13
    inc e               ;4
    ld a,(de)           ;7
    ld (smp3reset+1),a  ;13
    pop de              ;10     ;smp3 pointer
    ld ixh,0            ;11

C1noCh3Reload           ;(110)
    exx                 ;4
    ld a,(hl)           ;7      ;timing
    ld a,(hl)           ;7      ;timing
    dec hl              ;6      ;timing
C1hlpr equ $+1
    ld hl,0             ;10     ;restore hl
    xor a               ;4
    ld iyl,a            ;8
    ex af,af'           ;4
    jp (iy)             ;8
    ;____________________________192

C1noCh3X
    dw outlo            ;12__24
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    dec hl              ;6
    exx                 ;4
    jr C1noCh3Reload    ;12 (+12=113)
    

;*******************************************************************************
                        ;volume 2 - 32t
IF ((LOW($)) != 0)
    org 256*(1+(HIGH($)))
ENDIF
core2
    dw outhi            ;12__
    ds 2                ;8
    ld a,d              ;4      update counter ch1
    add a,e             ;4
    ld d,a              ;4
    dw outlo            ;12__32

    jp nc,_nos1upd      ;10
    
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs1       ;10
    
    ld hl,(smp1reset)   ;16
_rs1                    ;(43)
    exx                 ;4
    
    ld a,b              ;4
    add a,c             ;4
    ld b,a              ;4
    jp nc,_nos2upd      ;10
    
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs2       ;10
    
    ld hl,(smp2reset)   ;16

_rs2
    exx                 ;4
    
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    ds 2                ;8
    ;_______________________________192
    
    dw outhi            ;12__
    nop                 ;4
    ld a,ixh            ;8
    add a,ixl           ;8
    dw outlo            ;12__32
    exx                 ;4

    ld ixh,a            ;8
    jp nc,_nos3upd      ;10
    
    inc de              ;6
    ld a,(de)           ;7
    or a                ;4
    jp nz,_norvs3       ;10
    
    ld de,(smp3reset)   ;20

_rs3                    ;(47)
    ld a,(de)           ;7
    add a,(hl)          ;7 
    exx                 ;4

    add a,(hl)          ;7    
    add a,basec         ;7
    ld iyh,a            ;8

    ex af,af'           ;4
    dec a               ;4
    jp z,updateTimer    ;10
    ex af,af'           ;4
    
    ld a,r              ;9
    jp (iy)             ;8
    ;_______________________________192
    
    
_nos1upd
    ld a,(hl)           ;7
    jr _aa
_aa jr _bb
_norvs1 equ $-1
_bb jr _rs1
_nos2upd
    ld a,(hl)           ;7
    jr _cc
_cc jr _dd
_norvs2 equ $-1
_dd jr _rs2
_nos3upd
    ld a,(hl)           ;7
    ds 2                ;8
    jr _norvs3          ;12

_norvs3
    ds 2
    jr _rs3
    
C2noCh1X
    ex (sp),hl          ;19     1
    ex (sp),hl          ;19 (+12=50)    1
    jp XC2noCh1Reload   ;10 (116)   3 (13)

C2noCh3X
    ds 2                ;8
    dw outlo            ;12__32
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    exx                 ;4
    nop                 ;4
    jr C2noCh3Reload    ;12 (+12+4=130)
    
    org 256*((HIGH($)))+#80
    
_rdnext
    dw outhi            ;12__   
    nop                 ;4
    ld (C2hlpr),hl      ;16     
    dw outlo            ;12__32
    
    in a,(c)            ;12     ;read kbd
    cpl                 ;4
    and #1f             ;7
    jp nz,exit          ;10
    
    pop af              ;11
    jp m,rdseq          ;10

    ld i,a              ;9      ;set timer
    ld h,HIGH(smptab)   ;7      
    jr z,C2noCh1X       ;12/7
    
    pop de              ;10     ;smp1/freq1
    ld l,d              ;4
    ld d,0              ;7
    ld a,(hl)           ;7      ;fetch sample reset pointer
    ld (smp1reset),a    ;13
    inc hl              ;6
    ld a,(hl)           ;7
    ld (smp1reset+1),a  ;13
    nop                 ;4
    ;____________________________192 (78)
    dw outhi            ;12__
    inc hl              ;6
    ld a,(hl)           ;7      ;fetch actual sample pointer
    inc hl              ;6
    dw outlo            ;12__31..naja
    nop                 ;4
    ld h,(hl)           ;7
    ld l,a              ;4
    ld (C2hlpr),hl      ;16

C2noCh1Reload           ;(152)
    exx                 ;4
    jp pe,C2noCh2X      ;10
    
    ld h,HIGH(smptab)   ;7
    pop bc              ;10
    ld l,b              ;4
    ld b,0              ;7
    ld a,(hl)           ;7
    ld (smp2reset),a    ;13     ;fetch sample reset
    inc l               ;4
    ld a,(hl)           ;7
    ld (smp2reset+1),a  ;13
    inc l               ;4
    ld a,(hl)           ;7      ;fetch sample pntr
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    
C2noCh2Reload               ;(100)
    exx                 ;4
    ;____________________________192
    
    dw outhi            ;12__
    jr c,C2noCh3X       ;12/7
    dec hl              ;6      ;timing
    ld a,(hl)           ;7      ;timing
    dw outlo            ;12__32
    exx                 ;4
    
    ld d,HIGH(smptab)   ;7
    pop ix              ;14
    ld e,ixh            ;8
    ld a,(de)           ;7
    ld (smp3reset),a    ;13
    inc e               ;4
    ld a,(de)           ;7
    ld (smp3reset+1),a  ;13
    pop de              ;10     ;smp3 pointer
    ld ixh,0            ;11

C2noCh3Reload equ $-1           ;(130)
    exx                 ;4
    dec hl              ;6      ;timing
    dec hl              ;6
C2hlpr equ $+1
    ld hl,0             ;10     ;restore hl
    xor a               ;4
    ld iyl,a            ;8
    ex af,af'           ;4
    jp (iy)             ;8
    ;____________________________192

C2noCh2X
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    jr _ab              ;12
_ab jr C2noCh2Reload    ;12 (100)   

;*******************************************************************************
                        ;volume 3 - 40t
    org 256*(1+(HIGH($)))
core3
    dw outhi            ;12__
    jr _tt              ;12
_tt nop                 ;4
    ld a,d              ;4      update counter ch1
    add a,e             ;4
    ld d,a              ;4
    dw outlo            ;12__40

    jp nc,_nos1upd      ;10
    
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs1       ;10
    
    ld hl,(smp1reset)   ;16
_rs1                    ;(43)
    exx                 ;4
    
    ld a,b              ;4
    add a,c             ;4
    ld b,a              ;4
    jp nc,_nos2upd      ;10
    
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs2       ;10
    
    ld hl,(smp2reset)   ;16

_rs2
    exx                 ;4
    
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    ;_______________________________192
    
    dw outhi            ;12__
    nop                 ;4
    ld a,ixh            ;8
    add a,ixl           ;8
    ld ixh,a            ;8
    dw outlo            ;12__40
    exx                 ;4

    jp nc,_nos3upd      ;10
    
    inc de              ;6
    ld a,(de)           ;7
    or a                ;4
    jp nz,_norvs3       ;10
    
    ld de,(smp3reset)   ;20

_rs3                    ;(47)
    ld a,(de)           ;7
    add a,(hl)          ;7
    exx                 ;4
    
    add a,(hl)          ;7
    add a,basec         ;7
    ld iyh,a            ;8

    ex af,af'           ;4
    dec a               ;4
    jp z,updateTimer    ;10
    ex af,af'           ;4
    
    ld a,r              ;9
    jp (iy)             ;8
    ;_______________________________192
    
    
_nos1upd
    ld a,(hl)           ;7
    jr _aa
_aa jr _bb
_norvs1 equ $-1
_bb jr _rs1
_nos2upd
    ld a,(hl)           ;7
    jr _cc
_cc jr _dd
_norvs2 equ $-1
_dd jr _rs2
_nos3upd
    ld a,(hl)           ;7
    ds 2                ;8
    jr _norvs3          ;12

_norvs3
    ds 2
    jr _rs3
    
C3noCh1X
    ex (sp),hl          ;19     1
    ex (sp),hl          ;19 (+12=50)    1
    jp XC3noCh1Reload   ;10 (116)   3 (13)

C3noCh3X
    jr _ab              ;12
_ab nop                 ;4
    dw outlo            ;12__40
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    exx                 ;4
    nop                 ;4
    jr C3noCh3Reload    ;12 (+12=136)
    
    org 256*((HIGH($)))+#80
    
_rdnext
    dw outhi            ;12__   
    in a,(c)            ;12     ;read kbd
    ld (C3hlpr),hl      ;16     
    dw outlo            ;12__40
    
    nop                 ;4
    cpl                 ;4
    and #1f             ;7
    jp nz,exit          ;10
    
    pop af              ;11
    jp m,rdseq          ;10

    ld i,a              ;9      ;set timer
    ld h,HIGH(smptab)   ;7      
    jr z,C3noCh1X       ;12/7
    
    pop de              ;10     ;smp1/freq1
    ld l,d              ;4
    ld d,0              ;7
    ld a,(hl)           ;7      ;fetch sample reset pointer
    ld (smp1reset),a    ;13
    inc hl              ;6
    ld a,(hl)           ;7
    ld (smp1reset+1),a  ;13
    nop                 ;4
    ;____________________________192 (78)
    dw outhi            ;12__
    inc hl              ;6
    ld a,(hl)           ;7      ;fetch actual sample pointer
    inc hl              ;6
    ld h,(hl)           ;7
    dw outlo            ;12__38..eech
    nop                 ;4
    ld l,a              ;4
    ld (C3hlpr),hl      ;16

C3noCh1Reload           ;(152)
    exx                 ;4
    jp pe,C3noCh2X      ;10
    
    ld h,HIGH(smptab)   ;7
    pop bc              ;10
    ld l,b              ;4
    ld b,0              ;7
    ld a,(hl)           ;7
    ld (smp2reset),a    ;13     ;fetch sample reset
    inc l               ;4
    ld a,(hl)           ;7
    ld (smp2reset+1),a  ;13
    inc l               ;4
    ld a,(hl)           ;7      ;fetch sample pntr
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    
C3noCh2Reload           ;(100)
    exx                 ;4
    ;____________________________192
    
    dw outhi            ;12__
    jr c,C3noCh3X       ;12/7
    dec hl              ;6      ;timing
    exx                 ;4
    ld d,HIGH(smptab)   ;7
    exx                 ;4
    dw outlo            ;12__40
    exx                 ;4
    
    pop ix              ;14
    ld e,ixh            ;8
    ld a,(de)           ;7
    ld (smp3reset),a    ;13
    inc e               ;4
    ld a,(de)           ;7
    ld (smp3reset+1),a  ;13
    pop de              ;10     ;smp3 pointer
    ret c               ;5
    ld ixh,0            ;11

C3noCh3Reload               ;(136)
    exx                 ;4
    dec hl              ;6      ;timing
C3hlpr equ $+1
    ld hl,0             ;10     ;restore hl
    xor a               ;4
    ld iyl,a            ;8
    ex af,af'           ;4
    jp (iy)             ;8
    ;____________________________192

C3noCh2X
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    jr _ab              ;12
_ab jr C3noCh2Reload    ;12 (100)   

;*******************************************************************************
                        ;volume 4 - 48t
    org 256*(1+(HIGH($)))
core4
    dw outhi            ;12__
    ds 2                ;8
    ld a,d              ;4      update counter ch1
    add a,e             ;4
    ld d,a              ;4
    jp nc,_nos1upd      ;10
    
    inc hl              ;6
    dw outlo            ;12__48
    
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs1       ;10
    
    ld hl,(smp1reset)   ;16
_rs1                    ;(55)
    exx                 ;4
    
    ld a,b              ;4
    add a,c             ;4
    ld b,a              ;4
    jp nc,_nos2upd      ;10
    
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs2       ;10
    
    ld hl,(smp2reset)   ;16

_rs2
    exx                 ;4
    
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    ds 2                ;8
    ;_______________________________192
    
    dw outhi            ;12__
    ld a,ixh            ;8
    add a,ixl           ;8
    ld ixh,a            ;8
    jr nc,_nos3upd      ;12/7
    ret nc              ;5
    dw outlo            ;12__48
    exx                 ;4

    inc de              ;6
    ld a,(de)           ;7
    or a                ;4
    jp nz,_norvs3       ;10
    
    ld de,(smp3reset)   ;20

_rs3                    ;(63)
    ld a,(de)           ;7
    add a,(hl)          ;7
    exx                 ;4
    
    add a,(hl)          ;7
    add a,basec         ;7
    ld iyh,a            ;8

    ex af,af'           ;4
    dec a               ;4
    jp z,updateTimer    ;10
    ex af,af'           ;4
    
    ld a,(hl)           ;7
    nop                 ;4
    jp (iy)             ;8
    ;_______________________________192
    
    
_nos1upd
    inc hl              ;6
    dw outlo            ;12__48
    dec hl              ;6 
    ld a,(hl)           ;7
    jr _norvs1+1        ;12..43+12=55
_nos2upd
    ld a,(hl)           ;7
    jr _aa
_aa jr _bb
_norvs2 equ $-1
_bb jr _rs2

_nos3upd
    dw outlo            ;12__48
    ld a,(hl)           ;7
    exx                 ;4
    jr _cc
_cc jr _dd
_norvs3 equ $-1
_dd nop
    jr _rs3

_norvs1
    nop                 ;4
    jr _rs1             ;12

C4noCh1X
    jp XC4noCh1Reload   ;10 (116)

C4noCh3X
    jr _ab              ;12
_ab jr _ac              ;12
_ac dw outlo            ;12__48
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    jr C4noCh3Reload    ;12 (+12+4=140)
    
    org 256*((HIGH($)))+#80
    
_rdnext
    dw outhi            ;12__   
    in a,(c)            ;12     ;read kbd
    nop                 ;4
    cpl                 ;4
    ld (C4hlpr),hl      ;16     
    dw outlo            ;12__48
    
    and #1f             ;7
    jp nz,exit          ;10
    
    pop af              ;11
    jp m,rdseq          ;10

    ld i,a              ;9      ;set timer
    ld h,HIGH(smptab)   ;7      
    jr z,C4noCh1X       ;12/7
    
    pop de              ;10     ;smp1/freq1
    ld l,d              ;4
    ld d,0              ;7
    ld a,(hl)           ;7      ;fetch sample reset pointer
    ld (smp1reset),a    ;13
    inc hl              ;6
    ld a,(hl)           ;7
    ld (smp1reset+1),a  ;13
    nop                 ;4
    ;____________________________192 (78)
    dw outhi            ;12__
    inc hl              ;6
    ld a,(hl)           ;7      ;fetch actual sample pointer
    inc hl              ;6
    ld h,(hl)           ;7
    nop                 ;4
    ld l,a              ;4
    dw outlo            ;12__46..eech
    ld (C4hlpr),hl      ;16

C4noCh1Reload           ;(152)
    exx                 ;4
    jp pe,C4noCh2X      ;10
    
    ld h,HIGH(smptab)   ;7
    pop bc              ;10
    ld l,b              ;4
    ld b,0              ;7
    ld a,(hl)           ;7
    ld (smp2reset),a    ;13     ;fetch sample reset
    inc l               ;4
    ld a,(hl)           ;7
    ld (smp2reset+1),a  ;13
    inc l               ;4
    ld a,(hl)           ;7      ;fetch sample pntr
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    
C4noCh2Reload           ;(100)
    exx                 ;4
    ;____________________________192
    
    dw outhi            ;12__
    jr c,C4noCh3X       ;12/7
    pop ix              ;14
    exx                 ;4
    ld d,HIGH(smptab)   ;7
    exx                 ;4
    dw outlo            ;12__48
    dec hl              ;6      ;timing
    exx                 ;4
    
    ld e,ixh            ;8
    ld a,(de)           ;7
    ld (smp3reset),a    ;13
    inc e               ;4
    ld a,(de)           ;7
    ld (smp3reset+1),a  ;13
    pop de              ;10     ;smp3 pointer
    ret c               ;5
    exx                 ;4
    ld ixh,0            ;11
    
C4noCh3Reload equ $-1   ;(140)
    dec hl              ;6      ;timing
C4hlpr equ $+1
    ld hl,0             ;10     ;restore hl
    xor a               ;4
    ld iyl,a            ;8
    ex af,af'           ;4
    jp (iy)             ;8
    ;____________________________192

C4noCh2X
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    jr _ab              ;12
_ab jr C4noCh2Reload    ;12 (100)   

;*******************************************************************************
                        ;volume 5 - 56t
    org 256*(1+(HIGH($)))
core5
    dw outhi            ;12__
    ld a,d              ;4      update counter ch1
    add a,e             ;4
    ld d,a              ;4
    jp nc,_nos1upd      ;10
    ret nc              ;5
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    dw outlo            ;12__56
        
    jp nz,_norvs1       ;10
    
    ld hl,(smp1reset)   ;16
_rs1                    ;(60)
    exx                 ;4
    
    ld a,b              ;4
    add a,c             ;4
    ld b,a              ;4
    jp nc,_nos2upd      ;10
    
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs2       ;10
    
    ld hl,(smp2reset)   ;16

_rs2
    exx                 ;4
    
    ld a,r              ;9  
    ld a,ixh            ;8
    add a,ixl           ;8
    ;_______________________________192 - 188?
    
    dw outhi            ;12__   
    ld ixh,a            ;8
    jp nc,_nos3upd      ;10
    ret nc              ;5
    exx                 ;4
    inc de              ;6
    ld a,(de)           ;7
    exx                 ;4  (26)
    dw outlo            ;12__56
    
    exx                 ;4
    or a                ;4
    jp nz,_norvs3       ;10
    
    ld de,(smp3reset)   ;20

_rs3                    ;(76)
    ld a,(de)           ;7
    add a,(hl)          ;7
    exx                 ;4
    
    add a,(hl)          ;7
    add a,basec         ;7
    ld iyh,a            ;8

    ex af,af'           ;4
    dec a               ;4
    jp z,updateTimer    ;10
    ex af,af'           ;4

    jr _zz              ;12
_zz nop                 ;4
    jp (iy)             ;8
    ;_______________________________192
    
    
_nos1upd
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    ds 2                ;8
    dw outlo            ;12__56
    jp _norvs1          ;10+16=60
_nos2upd
    ld a,(hl)           ;7
    jr _aa
_aa jr _bb
_norvs2 equ $-1
_bb jr _rs2
_nos3upd
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    jr _xx              ;12
_xx dw outlo            ;12__56
    exx                 ;4
    nop                 ;4
    jp _norvs3          ;10+20=76

_norvs1
    nop                 ;4
    jr _rs1             ;12
_norvs3
    ds 2
    jr _rs3


C5noCh1X
    jp XC5noCh1Reload   ;10 (116)

C5noCh3X
    jp XC5noCh3Reload   ;10
    
    org 256*((HIGH($)))+#80
    
_rdnext
    dw outhi            ;12__   
    in a,(c)            ;12     ;read kbd
    
    cpl                 ;4
    and #1f             ;7
    jp nz,exit          ;10
    
    pop af              ;11     
    dw outlo            ;12__56
    
    jp m,rdseq          ;10
    nop                 ;4
    ld (C5hlpr),hl      ;16

    ld i,a              ;9      ;set timer
    ld h,HIGH(smptab)   ;7      
    jr z,C5noCh1X       ;12/7
    
    pop de              ;10     ;smp1/freq1
    ld l,d              ;4
    ld d,0              ;7
    ld a,(hl)           ;7      ;fetch sample reset pointer
    ld (smp1reset),a    ;13
    inc hl              ;6
    ld a,(hl)           ;7
    ld (smp1reset+1),a  ;13
    nop                 ;4
    ;____________________________192 (78)
    dw outhi            ;12__
    inc hl              ;6
    ld a,(hl)           ;7      ;fetch actual sample pointer
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    ld (C5hlpr),hl      ;16
    
C5noCh1Reload           ;(136)
    dw outlo            ;12__58..eech   
    nop                 ;4
    exx                 ;4
    jp pe,C5noCh2X      ;10
    
    ld h,HIGH(smptab)   ;7
    pop bc              ;10
    ld l,b              ;4
    ld b,0              ;7
    ld a,(hl)           ;7
    ld (smp2reset),a    ;13     ;fetch sample reset
    inc l               ;4
    ld a,(hl)           ;7
    ld (smp2reset+1),a  ;13
    inc l               ;4
    ld a,(hl)           ;7      ;fetch sample pntr
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    
C5noCh2Reload           ;(100)
    exx                 ;4
    ;____________________________192
    
    dw outhi            ;12__
    jr c,C5noCh3X       ;12/7
    pop ix              ;14
    exx                 ;4
    ld d,HIGH(smptab)   ;7
    ld e,ixh            ;8
    exx                 ;4
    dw outlo            ;12__56
    dec hl              ;6      ;timing
    exx                 ;4
    
    ld a,(de)           ;7
    ld (smp3reset),a    ;13
    inc e               ;4
    ld a,(de)           ;7
    ld (smp3reset+1),a  ;13
    pop de              ;10     ;smp3 pointer
    ret c               ;5
    exx                 ;4
    ld ixh,0            ;11
    
C5noCh3Reload equ $-1           ;(140)
    dec hl              ;6      ;timing
C5hlpr equ $+1
    ld hl,0             ;10     ;restore hl
    xor a               ;4
    ld iyl,a            ;8
    ex af,af'           ;4
    jp (iy)             ;8
    ;____________________________192

C5noCh2X
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    jr _ab              ;12
_ab jr C5noCh2Reload    ;12 (100)   

;*******************************************************************************
                        ;volume 6 - 64t
    org 256*(1+(HIGH($)))
core6
    dw outhi            ;12__
    ld a,d              ;4      update counter ch1
    add a,e             ;4
    ld d,a              ;4
    ds 2                ;8
    jp nc,_nos1upd      ;10
    ret nc              ;5
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    dw outlo            ;12__64
        
    jp nz,_norvs1       ;10
    
    ld hl,(smp1reset)   ;16
_rs1                    ;(60)
    exx                 ;4
    
    ld a,b              ;4
    add a,c             ;4
    ld b,a              ;4
    jp nc,_nos2upd      ;10
    
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs2       ;10
    
    ld hl,(smp2reset)   ;16

_rs2
    exx                 ;4
    
    ld a,r              ;9  
    ld a,ixh            ;8  
    ;_______________________________192
    
    dw outhi            ;12__
    add a,ixl           ;8  
    ld ixh,a            ;8
    jp nc,_nos3upd      ;10
    ret nc              ;5
    exx                 ;4
    inc de              ;6
    ld a,(de)           ;7
    exx                 ;4
    dw outlo            ;12__64
    
    exx                 ;4
    or a                ;4
    jp nz,_norvs3       ;10
    
    ld de,(smp3reset)   ;20

_rs3                    ;(76)
    ld a,(de)           ;7
    add a,(hl)          ;7 
    exx                 ;4
    
    add a,(hl)          ;7
    add a,basec         ;7
    ld iyh,a            ;8

    ex af,af'           ;4
    dec a               ;4
    jp z,updateTimer    ;10
    ex af,af'           ;4

    ds 2                ;8
    jp (iy)             ;8
    ;_______________________________192
    
    
_nos1upd
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    ds 2                ;8
    dw outlo            ;12__64
    jp _norvs1          ;10+16=60
_nos2upd
    ld a,(hl)           ;7
    jr _aa
_aa jr _bb
_norvs2 equ $-1
_bb jr _rs2
_nos3upd
    ret c               ;5      ;timing
    pop af              ;10     ;timing
    push af             ;11     ;timing
_xx dw outlo            ;12__64
    exx                 ;4
    nop                 ;4
    jp _norvs3          ;10+20=76

_norvs1
    nop                 ;4
    jr _rs1             ;12

_norvs3
    ds 2
    jr _rs3


C6noCh1X
    jp XC6noCh1Reload   ;10 (116)

C6noCh3X
    jp XC6noCh3Reload   ;10
    
    org 256*((HIGH($)))+#80
    
_rdnext
    dw outhi            ;12__   
    in a,(c)            ;12     ;read kbd
    
    cpl                 ;4
    and #1f             ;7
    jp nz,exit          ;10
    
    pop af              ;11
    ds 2                ;8      
    dw outlo            ;12__64
    
    jp m,rdseq          ;10
    ld (C6hlpr),hl      ;16

    ld i,a              ;9      ;set timer
    ld h,HIGH(smptab)   ;7      
    jr z,C6noCh1X       ;12/7
    
    pop de              ;10     ;smp1/freq1
    ld l,d              ;4
    ld d,0              ;7
    ld a,(hl)           ;7      ;fetch sample reset pointer
    ld (smp1reset),a    ;13
    inc hl              ;6
    ld a,(hl)           ;7
    ld (smp1reset+1),a  ;13
    ;____________________________192 (74)
    dw outhi            ;12__
    inc hl              ;6
    ld a,(hl)           ;7      ;fetch actual sample pointer
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    ld (C6hlpr),hl      ;16
    
C6noCh1Reload           ;(132)
    nop                 ;4
    dw outlo            ;12__62..eech   
    exx                 ;4
    jp pe,C6noCh2X      ;10
    
    ld h,HIGH(smptab)   ;7
    pop bc              ;10
    ld l,b              ;4
    ld b,0              ;7
    ld a,(hl)           ;7
    ld (smp2reset),a    ;13     ;fetch sample reset
    inc l               ;4
    ld a,(hl)           ;7
    ld (smp2reset+1),a  ;13
    inc l               ;4
    ld a,(hl)           ;7      ;fetch sample pntr
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    
C6noCh2Reload           ;(100)
    exx                 ;4
    ;____________________________192
    
    dw outhi            ;12__
    jr c,C6noCh3X       ;12/7
    pop ix              ;14
    exx                 ;4
    ld d,HIGH(smptab)   ;7
    ld e,ixh            ;8
    exx                 ;4
    ds 2                ;8
    dw outlo            ;12__64
    exx                 ;4
    
    ld a,(de)           ;7
    ld (smp3reset),a    ;13
    inc e               ;4
    ld a,(de)           ;7
    ld (smp3reset+1),a  ;13
    pop de              ;10     ;smp3 pointer
    exx                 ;4
    ld ixh,0            ;11
    
C6noCh3Reload equ $-1           ;(133)
    dec hl              ;6      ;timing
C6hlpr equ $+1
    ld hl,0             ;10     ;restore hl
    ld a,0              ;7
    ld iyl,a            ;8
    ex af,af'           ;4
    jp (iy)             ;8
    ;____________________________192

C6noCh2X
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    jr _ab              ;12
_ab jr C6noCh2Reload    ;12 (100)   

;*******************************************************************************
                        ;volume 7 - 72t
IF ((LOW($)) != 0)
    org 256*(1+(HIGH($)))
ENDIF
core7
    dw outhi            ;12__
    ld a,d              ;4      update counter ch1
    add a,e             ;4
    ld d,a              ;4
    nop                 ;4
    jr _vv              ;12
_vv jp nc,_nos1upd      ;10
    ret nc              ;5
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    dw outlo            ;12__72
        
    jp nz,_norvs1       ;10
    
    ld hl,(smp1reset)   ;16
_rs1                    ;(60)
    exx                 ;4
    
    ld a,b              ;4
    add a,c             ;4
    ld b,a              ;4
    jp nc,_nos2upd      ;10
    
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs2       ;10
    
    ld hl,(smp2reset)   ;16

_rs2
    exx                 ;4
    
    ld a,r              ;9          
    ;_______________________________192
    
    dw outhi            ;12__
    ld a,ixh            ;8
    add a,ixl           ;8  
    ld ixh,a            ;8
    jp nc,_nos3upd      ;10
    ret nc              ;5
    exx                 ;4
    inc de              ;6
    ld a,(de)           ;7
    exx                 ;4
    dw outlo            ;12__72

    exx                 ;4
    or a                ;4
    jp nz,_norvs3       ;10
    
    ld de,(smp3reset)   ;20

_rs3                    ;(76)
    ld a,(de)           ;7
    add a,(hl)          ;7
    exx                 ;4
    
    add a,(hl)          ;7
    add a,basec         ;7
    ld iyh,a            ;8

    ex af,af'           ;4
    dec a               ;4
    jp z,updateTimer    ;10
    ex af,af'           ;4

    jp (iy)             ;8
    ;_______________________________192
    
    
_nos1upd
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    ds 2                ;8
    dw outlo            ;12__72
    jp _norvs1          ;10+16=60
_nos2upd
    ld a,(hl)           ;7
    jr _aa              ;12
_aa jr _bb              ;12
_norvs2 equ $-1         ;(4)
_bb jr _rs2             ;12

_nos3upd
    ret c               ;5
    pop af              ;10
    push af             ;11
_xx dw outlo            ;12__72
    exx                 ;4
    nop                 ;4
    jp _norvs3          ;10+20=76

_norvs1
    nop                 ;4
    jr _rs1             ;12
    
_norvs3
    ds 2
_nox    jr _rs3


C7noCh2X
    dw outlo            ;12__72
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    jp XC7noCh2Reload   ;10 (98)

    
    org 256*((HIGH($)))+#80
    
_rdnext
    dw outhi            ;12__   
    in a,(c)            ;12     ;read kbd
    
    cpl                 ;4
    and #1f             ;7
    jp nz,exit          ;10
    
    pop af              ;11
    ld (C7hlpr),hl      ;16     
    dw outlo            ;12__72
    
    jp m,rdseq          ;10
    ds 2                ;8

    ld i,a              ;9      ;set timer
    ld h,HIGH(smptab)   ;7      
    jr z,C7noCh1X       ;12/7
    
    pop de              ;10     ;smp1/freq1
    ld l,d              ;4
    ld d,0              ;7
    ld a,(hl)           ;7      ;fetch sample reset pointer
    ld (smp1reset),a    ;13
    inc hl              ;6
    ld a,(hl)           ;7
    ld (smp1reset+1),a  ;13
    ;____________________________192 (74)
    dw outhi            ;12__
    inc hl              ;6
    ld a,(hl)           ;7      ;fetch actual sample pointer
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    ld (C7hlpr),hl      ;16
    
C7noCh1Reload           ;(132)
    nop                 ;4
    jp pe,C7noCh2X      ;10
    dw outlo            ;12__72 
    exx                 ;4
    
    ld h,HIGH(smptab)   ;7
    pop bc              ;10
    ld l,b              ;4
    ld b,0              ;7
    ld a,(hl)           ;7
    ld (smp2reset),a    ;13     ;fetch sample reset
    inc l               ;4
    ld a,(hl)           ;7
    ld (smp2reset+1),a  ;13
    inc l               ;4
    ld a,(hl)           ;7      ;fetch sample pntr
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    exx                 ;4
    
C7noCh2Reload           ;(120)
    ;____________________________192
    
    dw outhi            ;12__
    jr c,C7noCh3X       ;12/7
    ret c               ;5
    pop ix              ;14
    exx                 ;4
    ld d,HIGH(smptab)   ;7
    ld e,ixh            ;8
    ld a,(de)           ;7
    inc e               ;4
    exx                 ;4
    dw outlo            ;12__72
    exx                 ;4
    
    ld (smp3reset),a    ;13
    
    ld a,(de)           ;7
    ld (smp3reset+1),a  ;13
    pop de              ;10     ;smp3 pointer
    exx                 ;4
    ld ixh,0            ;11
    
C7noCh3Reload ;equ $-1          ;(134)
    inc hl              ;6      ;timing
    dec hl              ;6      ;timing
C7hlpr equ $+1
    ld hl,0             ;10     ;restore hl
    xor a               ;4
    ld iyl,a            ;8
    ex af,af'           ;4
    jp (iy)             ;8
    ;____________________________192

C7noCh1X
    jp XC7noCh1Reload   ;10 (116)

C7noCh3X
    jp XC7noCh3Reload   ;10
    
;*******************************************************************************
                        ;volume 8 - 80t
    org 256*(1+(HIGH($)))
core8
    dw outhi            ;12__
    ld a,d              ;4      update counter ch1
    add a,e             ;4
    ld d,a              ;4
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    jp nc,_nos1upd      ;10
    ret nc              ;5
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs1       ;10
    dw outlo            ;12__80
    
    ld hl,(smp1reset)   ;16
_rs1                    ;(60)
    exx                 ;4
    
    ld a,b              ;4
    add a,c             ;4
    ld b,a              ;4
    jp nc,_nos2upd      ;10
    
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs2       ;10
    ret nz              ;5
    
    ld hl,(smp2reset)   ;16

_rs2
    exx                 ;4
    inc sp              ;6          
    ;_______________________________192
    
    dw outhi            ;12__
    ld a,ixh            ;8
    add a,ixl           ;8  
    ld ixh,a            ;8
    jr nc,_nos3upd      ;12/7
    exx                 ;4
    inc de              ;6
    ld a,(de)           ;7
    or a                ;4
    jr nz,_norvs3       ;12/7
    ret nz              ;5  (40)
    exx                 ;4  
    dw outlo            ;12__80
    exx                 ;4  
    
    ld de,(smp3reset)   ;20

_rs3                    ;(80/40)
    ld a,(de)           ;7
    add a,(hl)          ;7
    exx                 ;4
    
    add a,(hl)          ;7
    add a,basec         ;7
    ld iyh,a            ;8

    dec sp              ;6
    ex af,af'           ;4
    dec a               ;4
    jp z,updateTimer    ;10
    ex af,af'           ;4

    jp (iy)             ;8
    ;_______________________________192
    
    
_nos1upd
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    ds 2                ;8
    jp _norvs1          ;10..32
_nos2upd
    ld a,(hl)           ;7
    ds 2                ;8
    jr _norvs2          ;12
_nos3upd
    exx                 ;4
    jr _zz              ;12
_zz jr _norvs3          ;12

_norvs1
    dw outlo            ;12__80
    nop                 ;4
    jr _rs1             ;12
_norvs2
    ld a,r
    jr _rs2
_norvs3
    exx                 ;4
    dw outlo            ;12
    exx                 ;4
    ds 2                ;8
    jr _rs3             ;12 (40)


C8noCh2X
    jr _aa              ;12
_aa dw outlo            ;12__80
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    jp XC8noCh2Reload   ;10 (106)

    
    org 256*((HIGH($)))+#80
    
_rdnext
    dw outhi            ;12__   
    in a,(c)            ;12     ;read kbd
    
    cpl                 ;4
    and #1f             ;7
    jp nz,exit          ;10
    
    pop af              ;11
    ld (C8hlpr),hl      ;16
    ds 2                ;8      
    dw outlo            ;12__80
    
    jp m,rdseq          ;10
    
    ld i,a              ;9      ;set timer
    ld h,HIGH(smptab)   ;7      
    jr z,C8noCh1X       ;12/7
    
    pop de              ;10     ;smp1/freq1
    ld l,d              ;4
    ld d,0              ;7
    ld a,(hl)           ;7      ;fetch sample reset pointer
    ld (smp1reset),a    ;13
    inc hl              ;6
    ld a,(hl)           ;7
    ld (smp1reset+1),a  ;13
    ;____________________________192 (74)
    dw outhi            ;12__
    inc hl              ;6
    ld a,(hl)           ;7      ;fetch actual sample pointer
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    ld (C8hlpr),hl      ;16
    
C8noCh1Reload           ;(132)
    jp pe,C8noCh2X      ;10
    nop                 ;4
    dw outlo            ;12__72 ...meep TODO but how?
    exx                 ;4
    
    ld h,HIGH(smptab)   ;7
    pop bc              ;10
    ld l,b              ;4
    ld b,0              ;7
    ld a,(hl)           ;7
    ld (smp2reset),a    ;13     ;fetch sample reset
    inc l               ;4
    ld a,(hl)           ;7
    ld (smp2reset+1),a  ;13
    inc l               ;4
    ld a,(hl)           ;7      ;fetch sample pntr
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    exx                 ;4
    
C8noCh2Reload             ;(120)  
    ;____________________________192
    
    dw outhi            ;12__
    jr c,C8noCh3X       ;12/7
    pop ix              ;14
    exx                 ;4
    ld d,HIGH(smptab)   ;7
    ld e,ixh            ;8
    ld a,(de)           ;7
    ld (smp3reset),a    ;13
    nop                 ;4
    exx                 ;4
    dw outlo            ;12__80
    exx                 ;4
    
    nop                 ;4  
    inc e               ;4
    ld a,(de)           ;7
    ld (smp3reset+1),a  ;13
    pop de              ;10     ;smp3 pointer
    exx                 ;4
    ld ixh,0            ;11
    
C8noCh3Reload equ $-1               ;(137)
    dec hl              ;6      ;timing
C8hlpr equ $+1
    ld hl,0             ;10     ;restore hl
    ld a,0              ;7
    ld iyl,a            ;8
    ex af,af'           ;4
    jp (iy)             ;8
    ;____________________________192

C8noCh1X
    jp XC8noCh1Reload   ;10 (116)

C8noCh3X
    jp XC8noCh3Reload   ;10



;*******************************************************************************
                        ;volume 9 - 88t
    org 256*(1+(HIGH($)))
core9
    dw outhi            ;12__
    ld a,d              ;4      update counter ch1
    add a,e             ;4
    ld d,a              ;4
    jp nc,_nos1upd      ;10

    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs1       ;10
    ld hl,(smp1reset)   ;16

_rs1                    ;(43)
    ld a,(hl)           ;7
    nop                 ;4
    dw outlo            ;12__88                 
    exx                 ;4
    
    ld a,b              ;4
    add a,c             ;4
    ld b,a              ;4
    jr nc,_nos2upd      ;12/7
    
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs2       ;10
    
    ld hl,(smp2reset)   ;16

_rs2                    ;(50)
    exx                 ;4
    inc sp              ;6
    ld a,ixh            ;8
    add a,ixl           ;8          
    ;_______________________________192
    
    dw outhi            ;12__   
    ld ixh,a            ;8
    jr nc,_nos3upd      ;12/7
    exx                 ;4
    inc de              ;6
    ld a,(de)           ;7
    or a                ;4
    jp nz,_norvs3       ;10
    ld de,(smp3reset)   ;20
    
_rs3                    ;(58/20)
    exx                 ;4

    dec sp              ;6  
    dw outlo            ;12__88
    exx                 ;4  

    ld a,(de)           ;7
    add a,(hl)          ;7
    exx                 ;4
    
    add a,(hl)          ;7
    add a,basec         ;7
    ld iyh,a            ;8

    ex af,af'           ;4
    dec a               ;4
    jp z,updateTimer    ;10
    ex af,af'           ;4
    
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    nop                 ;4
    jp (iy)             ;8
    ;_______________________________192
    
    
_nos1upd
    ld a,(hl)           ;7
    jr _aa
_aa jr _bb
_norvs1 equ $-1
_bb jr _rs1
_nos2upd
    jr _zz              ;12
_zz jp _norvs2          ;10
_nos3upd
    exx                 ;4
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    jr _norvs3+1        ;12 (+16=58)

_norvs2
    nop                 ;4
    jr _rs2             ;12 (50)
_norvs3
    ds 2                ;8
    jr _rs3             ;12


C9noCh2X
    jr _aa              ;12
_aa nop                 ;4
    dw outlo            ;12__88
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    nop                 ;4
    jr C9noCh2Reload    ;12 (120)

    
    org 256*((HIGH($)))+#80
    
_rdnext
    dw outhi            ;12__   
    in a,(c)            ;12     ;read kbd
    
    cpl                 ;4
    and #1f             ;7
    jp nz,exit          ;10
    
    pop af              ;11
    ld (C9hlpr),hl      ;16

    ld i,a              ;9      ;set timer
    ld h,HIGH(smptab)   ;7      
    dw outlo            ;12__88
    
    jp m,rdseq          ;10
    ds 2                ;8
            
    jr z,C9noCh1X       ;12/7
    
    pop de              ;10     ;smp1/freq1
    ld l,d              ;4
    ld d,0              ;7
    ld a,(hl)           ;7      ;fetch sample reset pointer
    ld (smp1reset),a    ;13
    inc hl              ;6
    ld a,(hl)           ;7
    ld (smp1reset+1),a  ;13
    ;____________________________192 (74)
    dw outhi            ;12__
    inc hl              ;6
    ld a,(hl)           ;7      ;fetch actual sample pointer
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    ld (C9hlpr),hl      ;16
    
C9noCh1Reload           ;(132)
    nop                 ;4
    jp pe,C9noCh2X      ;10
    dw outlo            ;12__72 ...meep TODO but how?
    exx                 ;4
    
    ld h,HIGH(smptab)   ;7
    pop bc              ;10
    ld l,b              ;4
    ld b,0              ;7
    ld a,(hl)           ;7
    ld (smp2reset),a    ;13     ;fetch sample reset
    inc l               ;4
    ld a,(hl)           ;7
    ld (smp2reset+1),a  ;13
    inc l               ;4
    ld a,(hl)           ;7      ;fetch sample pntr
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    exx                 ;4
    
C9noCh2Reload           ;(120)  
    ;____________________________192
    
    dw outhi            ;12__
    jr c,C9noCh3X       ;12/7
    pop ix              ;14
    exx                 ;4
    ld d,HIGH(smptab)   ;7
    ld e,ixh            ;8
    ld a,(de)           ;7
    ld (smp3reset),a    ;13
    inc e               ;4
    ds 2                ;8
    exx                 ;4
    dw outlo            ;12__88
    exx                 ;4

    ld a,(de)           ;7
    ld (smp3reset+1),a  ;13
    pop de              ;10     ;smp3 pointer
    exx                 ;4
    ld ixh,0            ;11
    
C9noCh3Reload equ $-1           ;(137)
    dec hl              ;6      ;timing
C9hlpr equ $+1
    ld hl,0             ;10     ;restore hl
    ld a,0              ;7
    ld iyl,a            ;8
    ex af,af'           ;4
    jp (iy)             ;8
    ;____________________________192

C9noCh1X
    jp XC9noCh1Reload   ;10 (116)

C9noCh3X
    jp XC9noCh3Reload   ;10



;*******************************************************************************
                        ;volume 10 - 96t
    org 256*(1+(HIGH($)))
core10
    dw outhi            ;12__
    ld a,d              ;4      update counter ch1
    add a,e             ;4
    ld d,a              ;4
    jp nc,_nos1upd      ;10

    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs1       ;10
    ld hl,(smp1reset)   ;16

_rs1                    ;(43)
    ld a,(hl)           ;7
    exx                 ;4
    ld a,b              ;4
    exx                 ;4
    dw outlo            ;12__96                 
    exx                 ;4
    
    add a,c             ;4
    ld b,a              ;4
    jr nc,_nos2upd      ;12/7
    
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs2       ;10
    
    ld hl,(smp2reset)   ;16

_rs2                    ;(50)
    exx                 ;4
    nop                 ;4
    inc sp              ;6
    ld a,ixh            ;8          
    ;_______________________________192
    
    dw outhi            ;12__
    add a,ixl           ;8  
    ld ixh,a            ;8
    jr nc,_nos3upd      ;12/7
    exx                 ;4
    inc de              ;6
    ld a,(de)           ;7
    or a                ;4
    jp nz,_norvs3       ;10
    ld de,(smp3reset)   ;20
    
_rs3                    ;(58/20)
    exx                 ;4
    dec sp              ;6  
    dw outlo            ;12__96
    exx                 ;4  

    ld a,(de)           ;7
    add a,(hl)          ;7
    
    exx                 ;4
    
    add a,(hl)          ;7
    add a,basec         ;7
    ld iyh,a            ;8

    ex af,af'           ;4
    dec a               ;4
    jp z,updateTimer    ;10
    ex af,af'           ;4
    
    jp _xy              ;10
_xy jp (iy)             ;8
    ;_______________________________192
    
    
_nos1upd
    ld a,(hl)           ;7
    jr _aa
_aa jr _bb
_norvs1 equ $-1
_bb jr _rs1

_nos2upd
    jr _zz              ;12
_zz jp _norvs2          ;10

_nos3upd
    exx                 ;4
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    jr _norvs3+1        ;12

_norvs2
    nop                 ;4
    jr _rs2             ;12 (50)
_norvs3
    ds 2                ;8
    jr _rs3             ;12


C10noCh2X
    jr _bb              ;12
_bb jr _cc              ;12
_cc dw outlo            ;12__96
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    ld a,(0)            ;13
    jr C10noCh2Reload   ;12 (120)

    
    org 256*((HIGH($)))+#80
    
_rdnext
    dw outhi            ;12__   
    in a,(c)            ;12     ;read kbd
    
    cpl                 ;4
    and #1f             ;7
    jp nz,exit          ;10
    
    pop af              ;11
    ld (C10hlpr),hl     ;16

    ld i,a              ;9      ;set timer
    ld h,HIGH(smptab)   ;7
    ds 2                ;8      
    dw outlo            ;12__96
    
    jp m,rdseq          ;10
    
            
    jr z,C10noCh1X      ;12/7
    
    pop de              ;10     ;smp1/freq1
    ld l,d              ;4
    ld d,0              ;7
    ld a,(hl)           ;7      ;fetch sample reset pointer
    ld (smp1reset),a    ;13
    inc hl              ;6
    ld a,(hl)           ;7
    ld (smp1reset+1),a  ;13
    ;____________________________192 (74)
    dw outhi            ;12__
    inc hl              ;6
    ld a,(hl)           ;7      ;fetch actual sample pointer
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    ld (C10hlpr),hl     ;16
    
C10noCh1Reload          ;(132)
    nop                 ;4
    jp pe,C10noCh2X     ;10
    dw outlo            ;12__72 ...meep TODO but how?
    exx                 ;4
    
    ld h,HIGH(smptab)   ;7
    pop bc              ;10
    ld l,b              ;4
    ld b,0              ;7
    ld a,(hl)           ;7
    ld (smp2reset),a    ;13     ;fetch sample reset
    inc l               ;4
    ld a,(hl)           ;7
    ld (smp2reset+1),a  ;13
    inc l               ;4
    ld a,(hl)           ;7      ;fetch sample pntr
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    exx                 ;4
    
C10noCh2Reload              ;(120)  
    ;____________________________192
    
    dw outhi            ;12__
    jr c,C10noCh3X      ;12/7
    pop ix              ;14
    exx                 ;4
    ld d,HIGH(smptab)   ;7
    ld e,ixh            ;8
    ld a,(de)           ;7
    ld (smp3reset),a    ;13
    inc e               ;4
    ld a,(de)           ;7
    ds 2                ;8
    exx                 ;4
    dw outlo            ;12__95...mhmmm
    exx                 ;4
    
    ld (smp3reset+1),a  ;13
    pop de              ;10     ;smp3 pointer
    exx                 ;4
    ld ixh,0            ;11
    
C10noCh3Reload              ;(137)
    dec hl              ;6      ;timing
C10hlpr equ $+1
    ld hl,0             ;10     ;restore hl
    ld a,0              ;7
    ld iyl,a            ;8
    ex af,af'           ;4
    jp (iy)             ;8
    ;____________________________192

C10noCh1X
    jp XC10noCh1Reload  ;10 (116)

C10noCh3X
    jp XC10noCh3Reload  ;10


;*******************************************************************************
                        ;volume 11 - 104t
    org 256*(1+(HIGH($)))
core11
    dw outhi            ;12__
    ld a,d              ;4      update counter ch1
    add a,e             ;4
    ld d,a              ;4
    jp nc,_nos1upd      ;10

    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs1       ;10
    ld hl,(smp1reset)   ;16

_rs1                    ;(43)
    ld a,(hl)           ;7
    exx                 ;4
    ld a,b              ;4
    add a,c             ;4
    ld b,a              ;4
    exx                 ;4
    dw outlo            ;12__104                    
    exx                 ;4
    
    jr nc,_nos2upd      ;12/7
    
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs2       ;10
    
    ld hl,(smp2reset)   ;16

_rs2                    ;(50)
    exx                 ;4
    jp _xy              ;10
_xy ld a,ixh            ;8          
    ;_______________________________192
    
    dw outhi            ;12__
    exx                 ;4
    add a,ixl           ;8  
    ld ixh,a            ;8
    jr nc,_nos3upd      ;12/7
    
    inc de              ;6
    ld a,(de)           ;7
    or a                ;4
    jp nz,_norvs3       ;10
    ld de,(smp3reset)   ;20
    
_rs3                    ;(58/20)
    ld a,(de)           ;7
    add a,(hl)          ;7
    exx                 ;4
    dw outlo            ;12__104
    
    add a,(hl)          ;7
    
    add a,basec         ;7
    ld iyh,a            ;8

    ex af,af'           ;4
    dec a               ;4
    jp z,updateTimer    ;10
    ex af,af'           ;4
    
    jr _tt              ;12
_tt jr _vv              ;12
_vv jp (iy)             ;8
    ;_______________________________192 !196 through _nos3upd
    
    
_nos1upd
    ld a,(hl)           ;7
    jr _aa              ;12
_aa jr _bb              ;12
_norvs1 equ $-1         ;(4)
_bb jr _rs1             ;12
_nos2upd
    jr _zz              ;12
_zz jp _norvs2          ;10
_nos3upd
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    jr _norvs3+1        ;12

_norvs2
    nop                 ;4
    jr _rs2             ;12 (50)
_norvs3
    ds 2                ;8
    jr _rs3             ;12


C11noCh2X
    jr _aa              ;12
_aa jr _bb              ;12
_bb ds 2                ;8
    dw outlo            ;12__104
    nop                 ;4
    jr C11noCh2Reload   ;12 (120)

    
    org 256*((HIGH($)))+#80
    
_rdnext
    dw outhi            ;12__   
    in a,(c)            ;12     ;read kbd
    
    cpl                 ;4
    and #1f             ;7
    jp nz,exit          ;10
    
    pop af              ;11
    jp m,rdseq0         ;10
    ld (C11hlpr),hl     ;16

    ld i,a              ;9      ;set timer
    ld h,HIGH(smptab)   ;7
    ds 2                ;8      
    dw outlo            ;12__106..hrrrmmm   
            
    jr z,C11noCh1X      ;12/7
    
    pop de              ;10     ;smp1/freq1
    ld l,d              ;4
    ld d,0              ;7
    ld a,(hl)           ;7      ;fetch sample reset pointer
    ld (smp1reset),a    ;13
    inc hl              ;6
    ld a,(hl)           ;7
    ld (smp1reset+1),a  ;13
    ;____________________________192 (74)
    dw outhi            ;12__
    inc hl              ;6
    ld a,(hl)           ;7      ;fetch actual sample pointer
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    ld (C11hlpr),hl     ;16
    
C11noCh1Reload          ;(132)
    nop                 ;4
    jp pe,C11noCh2X     ;10
    dw outlo            ;12__72 ...meep TODO but how?
    exx                 ;4
    
    ld h,HIGH(smptab)   ;7
    pop bc              ;10
    ld l,b              ;4
    ld b,0              ;7
    ld a,(hl)           ;7
    ld (smp2reset),a    ;13     ;fetch sample reset
    inc l               ;4
    ld a,(hl)           ;7
    ld (smp2reset+1),a  ;13
    inc l               ;4
    ld a,(hl)           ;7      ;fetch sample pntr
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    exx                 ;4
    
C11noCh2Reload              ;(120)  
    ;____________________________192
    
    dw outhi            ;12__
    jr c,C11noCh3X      ;12/7
    pop ix              ;14
    exx                 ;4
    ld d,HIGH(smptab)   ;7
    ld e,ixh            ;8
    ld a,(de)           ;7
    ld (smp3reset),a    ;13
    inc e               ;4
    ld a,(de)           ;7
    ld (smp3reset+1),a  ;13
    nop                 ;4
    exx                 ;4
    dw outlo            ;12__104
    exx                 ;4
    
    nop                 ;4
    pop de              ;10     ;smp3 pointer
    exx                 ;4
    ld ixh,0            ;11
    
C11noCh3Reload equ $-1  ;(137)
    dec hl              ;6      ;timing
C11hlpr equ $+1
    ld hl,0             ;10     ;restore hl
    ld a,0              ;7
    ld iyl,a            ;8
    ex af,af'           ;4
    jp (iy)             ;8
    ;____________________________192

C11noCh1X
    jp XC11noCh1Reload  ;10 (116)

C11noCh3X
    jp XC11noCh3Reload  ;10


;*******************************************************************************
                        ;volume 12 - 112t
    org 256*(1+(HIGH($)))
core12
    dw outhi            ;12__
    ld a,d              ;4      update counter ch1
    add a,e             ;4
    ld d,a              ;4
    jp nc,_nos1upd      ;10

    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs1       ;10
    ld hl,(smp1reset)   ;16

_rs1                    ;(43)
    exx                 ;4
    ld a,b              ;4
    add a,c             ;4
    ld b,a              ;4
    exx                 ;4
    jp nc,_nos2upd      ;10
    ret nc              ;5
    dw outlo            ;12__112                    
    exx                 ;4
    
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs2       ;10
    
    ld hl,(smp2reset)   ;16
    
_rs2                    ;(64)
    exx                 ;4
    ld a,r              ;9
    ld a,ixh            ;8          
    ;_______________________________192
    
    dw outhi            ;12__
    exx                 ;4
    add a,ixl           ;8  
    ld ixh,a            ;8
    jr nc,_nos3upd      ;12/7
    
    inc de              ;6
    ld a,(de)           ;7
    or a                ;4
    jp nz,_norvs3       ;10
    ld de,(smp3reset)   ;20
    
_rs3                    ;(58/20)
    ld a,(de)           ;7
    add a,(hl)          ;7
    exx                 ;4
    ds 2                ;8
    dw outlo            ;12__112
    
    add a,(hl)          ;7
    
    add a,basec         ;7
    ld iyh,a            ;8

    ex af,af'           ;4
    dec a               ;4
    jp z,updateTimer    ;10
    ex af,af'           ;4

    nop                 ;4
    jr _zz              ;12
_zz jp (iy)             ;8
    ;_______________________________192
    
    
_nos1upd
    ld a,(hl)           ;7
    jr _aa              ;12
_aa jr _bb              ;12
_norvs1 equ $-1         ;(4)
_bb jr _rs1             ;12
_nos2upd
    ret c               ;5
    dw outlo            ;12__112
    exx                 ;4
    ld a,(hl)           ;7
    jr _cc              ;12
_cc jr _dd              ;12
_norvs2 equ $-1         ;(4)
_dd jr _rs2             ;12 (64)
_nos3upd
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    jr _norvs3+1        ;12
_norvs3 equ $-1         ;(4)
    nop                 ;4
    jr _rs3             ;12


C12noCh2X               ;(__60)
    jr _aa              ;12
_aa jr _bb              ;12
_bb ld a,(hl)           ;7
    jp XC12noCh2Reload  ;10

C12noCh1X               ;(12)
    ret nz              ;5
    nop                 ;4
    dw outlo            ;12__112
    jp XC12noCh1Reload  ;10
    
    org 256*((HIGH($)))+#80
    
_rdnext
    dw outhi            ;12__   
    in a,(c)            ;12     ;read kbd
    
    cpl                 ;4
    and #1f             ;7
    jp nz,exit          ;10
    
    pop af              ;11
    jp m,rdseq0         ;10
    ld (C12hlpr),hl     ;16

    ld i,a              ;9      ;set timer
    jr z,C12noCh1X      ;12/7       
    pop de              ;10     ;smp1/freq1
    ld l,d              ;4       (21)           
    dw outlo            ;12__112    

    ld h,HIGH(smptab)   ;7
    ld d,0              ;7
    ld a,(hl)           ;7      ;fetch sample reset pointer
    ld (smp1reset),a    ;13
    inc hl              ;6
    ld a,(hl)           ;7
    ld (smp1reset+1),a  ;13
    ds 2                ;8
    ;____________________________192 (101)
    dw outhi            ;12__
    inc hl              ;6
    ld a,(hl)           ;7      ;fetch actual sample pointer
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    ld (C12hlpr),hl     ;16
    
C12noCh1Reload          ;(159)
    nop                 ;4
    jp pe,C12noCh2X     ;10
    dw outlo            ;12__72 ...meep TODO but how?
    exx                 ;4
    
    ld h,HIGH(smptab)   ;7
    pop bc              ;10
    ld l,b              ;4
    ld b,0              ;7
    ld a,(hl)           ;7
    ld (smp2reset),a    ;13     ;fetch sample reset
    inc l               ;4
    ld a,(hl)           ;7
    ld (smp2reset+1),a  ;13
    inc l               ;4
    ld a,(hl)           ;7      ;fetch sample pntr
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    exx                 ;4
    
C12noCh2Reload          ;(120)  
    ;____________________________192
    
    dw outhi            ;12__
    jr c,C12noCh3X      ;12/7
    pop ix              ;14
    exx                 ;4
    ld d,HIGH(smptab)   ;7
    ld e,ixh            ;8
    ld a,(de)           ;7
    ld (smp3reset),a    ;13
    inc e               ;4
    ld a,(de)           ;7
    ld a,(de)           ;7      ;timing
    pop de              ;10     ;smp3 pointer
    exx                 ;4
    ds 2                ;8
    dw outlo            ;12__112
    
    ld (smp3reset+1),a  ;13
    ld ixh,0            ;11
    
C12noCh3Reload equ $-1  ;(4)    ;(136)
    dec hl              ;6      ;timing
C12hlpr equ $+1
    ld hl,0             ;10     ;restore hl
    xor a               ;4
    ld iyl,a            ;8
    ex af,af'           ;4
    nop                 ;4
    jp (iy)             ;8
    ;____________________________192

C12noCh3X
    jp XC12noCh3Reload  ;10

;*******************************************************************************
                        ;volume 13 - 120t
    org 256*(1+(HIGH($)))
core13
    dw outhi            ;12__
    ld a,d              ;4      update counter ch1
    add a,e             ;4
    ld d,a              ;4
    jp nc,_nos1upd      ;10

    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs1       ;10
    ld hl,(smp1reset)   ;16

_rs1                    ;(43)
    exx                 ;4
    ld a,b              ;4
    add a,c             ;4
    ld b,a              ;4
    jp nc,_nos2upd      ;10
    inc hl              ;6
    ld a,(hl)           ;7
    exx                 ;4
    dw outlo            ;12__120 (17)
    exx                 ;4

    or a                ;4
    jp nz,_norvs2       ;10

    ld hl,(smp2reset)   ;16

_rs2                    ;(63)
    exx                 ;4
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    ld a,ixh            ;8
    ;_______________________________192
    
    dw outhi            ;12__
    exx                 ;4
    add a,ixl           ;8  
    ld ixh,a            ;8
    jr nc,_nos3upd      ;12/7
    
    inc de              ;6
    ld a,(de)           ;7
    or a                ;4
    jp nz,_norvs3       ;10
    ld de,(smp3reset)   ;20
    
_rs3                    ;(58/20)
    ld a,(de)           ;7
    add a,(hl)          ;7
    exx                 ;4
    nop                 ;4
    jr _zz              ;12
_zz dw outlo            ;12__120
    
    add a,(hl)          ;7
    
    add a,basec         ;7
    ld iyh,a            ;8

    ex af,af'           ;4
    dec a               ;4
    jp z,updateTimer    ;10
    ex af,af'           ;4
    
    ds 2                ;8
    jp (iy)             ;8
    ;_______________________________192
    
    
_nos1upd
    ld a,(hl)           ;7
    jr _aa
_aa jr _bb
_norvs1 equ $-1
_bb jr _rs1
_nos2upd
    ld a,(0)            ;13
    exx                 ;4
    dw outlo            ;12__120
    exx                 ;4
    nop                 ;4
    jp _norvs2          ;10 (+16=63)
_nos3upd
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    jr _norvs3+1        ;12
_norvs3 equ $-1
    nop                 ;4
    jr _rs3             ;12

_norvs2
    nop                 ;4
    jr _rs2             ;12
    
    

C13noCh2X               ;(__60)
    jr _aa              ;12
_aa jr _bb              ;12
_bb ld a,(hl)           ;7
    jp XC13noCh2Reload  ;10

C13noCh1X               ;(12)
    ret nz              ;5
    jr _aa              ;12
_aa dw outlo            ;12__120
    jp XC13noCh1Reload  ;10
    
    org 256*((HIGH($)))+#80
    
_rdnext
    dw outhi            ;12__   
    in a,(c)            ;12     ;read kbd
    
    cpl                 ;4
    and #1f             ;7
    jp nz,exit          ;10
    
    pop af              ;11
    jp m,rdseq0         ;10
    ld (C13hlpr),hl     ;16

    ld i,a              ;9      ;set timer
    jr z,C13noCh1X      ;12/7       
    pop de              ;10     ;smp1/freq1
    ld l,d              ;4       (21)
    ds 2                ;8          
    dw outlo            ;12__120    

    ld h,HIGH(smptab)   ;7
    ld d,0              ;7
    ld a,(hl)           ;7      ;fetch sample reset pointer
    ld (smp1reset),a    ;13
    inc hl              ;6
    ld a,(hl)           ;7
    ld (smp1reset+1),a  ;13
    ;____________________________192 (101)
    dw outhi            ;12__
    inc hl              ;6
    ld a,(hl)           ;7      ;fetch actual sample pointer
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    ld (C13hlpr),hl     ;16
    
C13noCh1Reload          ;(159)
    nop                 ;4
    jp pe,C13noCh2X     ;10
    dw outlo            ;12__72 ...meep TODO but how?
    exx                 ;4
    
    ld h,HIGH(smptab)   ;7
    pop bc              ;10
    ld l,b              ;4
    ld b,0              ;7
    ld a,(hl)           ;7
    ld (smp2reset),a    ;13     ;fetch sample reset
    inc l               ;4
    ld a,(hl)           ;7
    ld (smp2reset+1),a  ;13
    inc l               ;4
    ld a,(hl)           ;7      ;fetch sample pntr
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    exx                 ;4
    
C13noCh2Reload          ;(120)  
    ;____________________________192
    
    dw outhi            ;12__
    jr c,C13noCh3X      ;12/7
    pop ix              ;14
    exx                 ;4
    ld d,HIGH(smptab)   ;7
    ld e,ixh            ;8
    ld a,(de)           ;7
    ld (smp3reset),a    ;13
    inc e               ;4
    ld a,(de)           ;7
    ld a,(de)           ;7      ;timing
    pop de              ;10     ;smp3 pointer
    exx                 ;4
    ld ixh,0            ;11
    ret c               ;5
    dw outlo            ;12__120
    
    ld (smp3reset+1),a  ;13
    
C13noCh3Reload              ;(133)
    dec hl              ;6      ;timing
C13hlpr equ $+1
    ld hl,0             ;10     ;restore hl
    xor a               ;4
    ld iyl,a            ;8
    ex af,af'           ;4
    ld a,(hl)           ;7      ;timing
    jp (iy)             ;8
    ;____________________________192

C13noCh3X
    jp XC13noCh3Reload  ;10


;*******************************************************************************
                        ;volume 14 - 128t
    org 256*(1+(HIGH($)))
core14
    dw outhi            ;12__
    ld a,d              ;4      update counter ch1
    add a,e             ;4
    ld d,a              ;4
    jp nc,_nos1upd      ;10

    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs1       ;10
    ld hl,(smp1reset)   ;16

_rs1                    ;(43)
    exx                 ;4
    ld a,b              ;4
    add a,c             ;4
    ld b,a              ;4
    jp nc,_nos2upd      ;10
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    nop                 ;4
    exx                 ;4
    dw outlo            ;12__128 (25)                   
    exx                 ;4
    
    jp nz,_norvs2       ;10
    
    ld hl,(smp2reset)   ;16
    
_rs2                    ;(67)
    exx                 ;4
    jp _xy              ;10
_xy ld a,ixh            ;8          
    ;_______________________________192
    
    dw outhi            ;12__
    exx                 ;4
    add a,ixl           ;8  
    ld ixh,a            ;8
    jr nc,_nos3upd      ;12/7
    
    inc de              ;6
    ld a,(de)           ;7
    or a                ;4
    jp nz,_norvs3       ;10
    ld de,(smp3reset)   ;20
    
_rs3                    ;(58/20)
    ld a,(de)           ;7
    add a,(hl)          ;7
    exx                 ;4
    jr _tt
_tt jr _vv
_vv dw outlo            ;12__128
    
    add a,(hl)          ;7
    
    add a,basec         ;7
    ld iyh,a            ;8

    ex af,af'           ;4
    dec a               ;4
    jp z,updateTimer    ;10
    ex af,af'           ;4

    jp (iy)             ;8
    ;_______________________________192
    
    
_nos1upd
    ld a,(hl)           ;7
    jr _aa
_aa jr _bb
_norvs1 equ $-1
_bb jr _rs1 
_nos2upd
    pop af              
    push af
    exx                 ;4
    dw outlo            ;12__128
    exx                 ;4
    jp _norvs2          ;10 (+16=67)
_nos3upd
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    jr _norvs3+1        ;12
_norvs3 equ $-1         ;(4)
    nop                 ;4
    jr _rs3             ;12

_norvs2
    nop                 ;4
    jr _rs2             ;12

    
    
C14noCh2X               ;(__60)
    jr _aa              ;12
_aa jr _bb              ;12
_bb ld a,(hl)           ;7
    jp XC14noCh2Reload  ;10

C14noCh1X               ;(12)
    ld a,(hl)           ;7
    jp XC14noCh1Reload  ;10
    
    org 256*((HIGH($)))+#80
    
_rdnext
    dw outhi            ;12__   
    in a,(c)            ;12     ;read kbd
    
    cpl                 ;4
    and #1f             ;7
    jp nz,exit          ;10
    
    pop af              ;11
    jp m,rdseq0         ;10
    ld (C14hlpr),hl     ;16

    ld i,a              ;9      ;set timer
    jr z,C14noCh1X      ;12/7       
    pop de              ;10     ;smp1/freq1
    ld l,d              ;4       (21)
    ds 2                ;8
    ld h,HIGH(smptab)   ;7          
    dw outlo            ;12__127 naja   

    ld d,0              ;7
    ld a,(hl)           ;7      ;fetch sample reset pointer
    ld (smp1reset),a    ;13
    inc hl              ;6
    ld a,(hl)           ;7
    ld (smp1reset+1),a  ;13
    ;____________________________192 (101)
    dw outhi            ;12__
    inc hl              ;6
    ld a,(hl)           ;7      ;fetch actual sample pointer
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    ld (C14hlpr),hl     ;16
    
C14noCh1Reload          ;(159)
    nop                 ;4
    jp pe,C14noCh2X     ;10
    dw outlo            ;12__72 ...meep TODO but how?
    exx                 ;4
    
    ld h,HIGH(smptab)   ;7
    pop bc              ;10
    ld l,b              ;4
    ld b,0              ;7
    ld a,(hl)           ;7
    ld (smp2reset),a    ;13     ;fetch sample reset
    inc l               ;4
    ld a,(hl)           ;7
    ld (smp2reset+1),a  ;13
    inc l               ;4
    ld a,(hl)           ;7      ;fetch sample pntr
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    exx                 ;4
    
C14noCh2Reload              ;(120)  
    ;____________________________192
    
    dw outhi            ;12__
    jr c,C14noCh3X      ;12/7
    pop ix              ;14
    exx                 ;4
    ld d,HIGH(smptab)   ;7
    ld e,ixh            ;8
    ld a,(de)           ;7
    ld (smp3reset),a    ;13
    inc e               ;4
    ld a,(de)           ;7
    ld a,(de)           ;7      ;timing
    pop de              ;10     ;smp3 pointer
    exx                 ;4
    ld ixh,0            ;11
    ld (smp3reset+1),a  ;13
    
C14noCh3Reload          ;(116)  
    dw outlo            ;12__128
    
    dec hl              ;6      ;timing
C14hlpr equ $+1
    ld hl,0             ;10     ;restore hl
    xor a               ;4
    ld iyl,a            ;8
    ex af,af'           ;4
    jr _aa              ;12     ;timing
_aa jp (iy)             ;8
    ;____________________________192

C14noCh3X
    jp XC14noCh3Reload  ;10


;*******************************************************************************
                        ;volume 15 - 136t
    org 256*(1+(HIGH($)))
core15
    dw outhi            ;12__
    ld a,d              ;4      update counter ch1
    add a,e             ;4
    ld d,a              ;4
    jp nc,_nos1upd      ;10

    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs1       ;10
    ld hl,(smp1reset)   ;16

_rs1                    ;(43)
    exx                 ;4
    ld a,b              ;4
    add a,c             ;4
    ld b,a              ;4
    jp nc,_nos2upd      ;10
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jr nz,_norvs2       ;12/7
    ret nz              ;5
    exx                 ;4
    dw outlo            ;12__136 (33)                   
    exx                 ;4
        
    ld hl,(smp2reset)   ;16
    
_rs2                    ;(65)
    exx                 ;4
    jr _zz              ;12
_zz ld a,ixh            ;8          
    ;_______________________________192
    
    dw outhi            ;12__
    exx                 ;4
    add a,ixl           ;8  
    ld ixh,a            ;8
    jr nc,_nos3upd      ;12/7
    
    inc de              ;6
    ld a,(de)           ;7
    or a                ;4
    jp nz,_norvs3       ;10
    ld de,(smp3reset)   ;20
    
_rs3                    ;(58/20)
    ld a,(de)           ;7
    add a,(hl)          ;7
    exx                 ;4
    
    add a,(hl)          ;7
    add a,basec         ;7
    ld iyh,a            ;8
    jp _xy              ;10
_xy dw outlo            ;12__136
    
    ex af,af'           ;4
    dec a               ;4
    jp z,updateTimer    ;10
    ex af,af'           ;4

    ld a,(hl)           ;7
    ld a,(hl)           ;7
    jp (iy)             ;8
    ;_______________________________192
    
    
_nos1upd
    ld a,(hl)           ;7
    jr _aa
_aa jr _bb
_norvs1 equ $-1
_bb jr _rs1
_nos2upd
    ld a,r              ;9
    ds 2                ;8
    jr _norvs2          ;12 (24+12+16 = 52)
_nos3upd
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    jr _norvs3+1        ;12
_norvs3 equ $-1         ;(4)
    nop                 ;4
    jr _rs3             ;12

_norvs2
    exx                 ;4
    dw outlo            ;12__136                    
    exx                 ;4
    nop                 ;4
    jr _rs2             ;12


C15noCh2X               ;(__60)
    jr _aa              ;12
_aa jr _bb              ;12
_bb ld a,(hl)           ;7
    jp XC15noCh2Reload  ;10

C15noCh1X               ;(12)
    ld a,(hl)           ;7
    jp XC15noCh1Reload  ;10
    
    org 256*((HIGH($)))+#80
    
_rdnext
    dw outhi            ;12__   
    in a,(c)            ;12     ;read kbd
    
    cpl                 ;4
    and #1f             ;7
    jp nz,exit          ;10
    
    pop af              ;11
    jp m,rdseq0         ;10
    ld (C15hlpr),hl     ;16

    ld i,a              ;9      ;set timer
    jr z,C15noCh1X      ;12/7       
    pop de              ;10     ;smp1/freq1
    ld l,d              ;4       (21)
    ds 2                ;8
    ld h,HIGH(smptab)   ;7
    ld d,0              ;7  (43)        
    dw outlo            ;12__134 naja   
    
    ld a,(hl)           ;7      ;fetch sample reset pointer
    ld (smp1reset),a    ;13
    inc hl              ;6
    ld a,(hl)           ;7
    ld (smp1reset+1),a  ;13
    ;____________________________192 (101)
    dw outhi            ;12__
    inc hl              ;6
    ld a,(hl)           ;7      ;fetch actual sample pointer
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    ld (C15hlpr),hl     ;16
    
C15noCh1Reload          ;(159)
    nop                 ;4
    jp pe,C15noCh2X     ;10
    dw outlo            ;12__72 ...meep TODO but how?
    exx                 ;4
    
    ld h,HIGH(smptab)   ;7
    pop bc              ;10
    ld l,b              ;4
    ld b,0              ;7
    ld a,(hl)           ;7
    ld (smp2reset),a    ;13     ;fetch sample reset
    inc l               ;4
    ld a,(hl)           ;7
    ld (smp2reset+1),a  ;13
    inc l               ;4
    ld a,(hl)           ;7      ;fetch sample pntr
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    exx                 ;4
    
C15noCh2Reload          ;(120)  
    ;____________________________192
    
    dw outhi            ;12__
    jr c,C15noCh3X      ;12/7
    pop ix              ;14
    exx                 ;4
    ld d,HIGH(smptab)   ;7
    ld e,ixh            ;8
    ld a,(de)           ;7
    ld (smp3reset),a    ;13
    inc e               ;4
    ld a,(de)           ;7
    ld a,(de)           ;7      ;timing
    pop de              ;10     ;smp3 pointer
    exx                 ;4
    ld ixh,0            ;11
    ld (smp3reset+1),a  ;13
    
C15noCh3Reload          ;(116)
    xor a               ;4
    ex af,af'           ;4  
    dw outlo            ;12__136
    
    ld iyl,0            ;11
    adc hl,bc           ;11     ;timing
C15hlpr equ $+1
    ld hl,0             ;10     ;restore hl
    jp (iy)             ;8
    ;____________________________192

C15noCh3X
    jp XC15noCh3Reload  ;10



;*******************************************************************************
                        ;volume 16 - 144t
    org 256*(1+(HIGH($)))
core16
    dw outhi            ;12__
    ld a,d              ;4      update counter ch1
    add a,e             ;4
    ld d,a              ;4
    jp nc,_nos1upd      ;10

    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs1       ;10
    ld hl,(smp1reset)   ;16

_rs1                    ;(43)
    exx                 ;4
    ld a,b              ;4
    add a,c             ;4
    ld b,a              ;4
    jp nc,_nos2upd      ;10
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jr nz,_norvs2       ;12/7
    ret nz              ;5
    exx                 ;4
    ds 2                ;8
    dw outlo            ;12__144                    
    exx                 ;4
        
    ld hl,(smp2reset)   ;16
    
_rs2                    ;(73)
    exx                 ;4
    nop                 ;4
    ld a,ixh            ;8          
    ;_______________________________192
    
    dw outhi            ;12__
    exx                 ;4
    add a,ixl           ;8  
    ld ixh,a            ;8
    jr nc,_nos3upd      ;12/7
    
    inc de              ;6
    ld a,(de)           ;7
    or a                ;4
    jp nz,_norvs3       ;10
    ld de,(smp3reset)   ;20
    
_rs3                    ;(58/20)
    ld a,(de)           ;7
    add a,(hl)          ;7
    exx                 ;4
    
    add a,(hl)          ;7
    add a,basec         ;7
    ld iyh,a            ;8
    jp _xy              ;10
_xy ex af,af'           ;4
    dec a               ;4
    dw outlo            ;12__144
    
    jp z,updateTimer    ;10
    ex af,af'           ;4

    ld a,(hl)           ;7
    ld a,(hl)           ;7
    jp (iy)             ;8
    ;_______________________________192
    
    
_nos1upd
    ld a,(hl)           ;7
    jr _aa
_aa jr _bb
_norvs1 equ $-1
_bb jr _rs1
_nos2upd
    ret c               ;5      ;timing
    jr _cc              ;12
_cc jr _norvs2          ;12 (24+12+16 = 52)
_nos3upd
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    jr _norvs3+1        ;12
_norvs3 equ $-1
    nop                 ;4
    jr _rs3             ;12

_norvs2
    exx                 ;4
    ds 2                ;8
    dw outlo            ;12__144                    
    exx                 ;4
    nop                 ;4
    jr _rs2             ;12


C16noCh2X               ;(__60)
    jr _aa              ;12
_aa jr _bb              ;12
_bb ld a,(hl)           ;7
    jp XC16noCh2Reload  ;10

C16noCh1X               ;(12)
    ld a,(hl)           ;7
    jp XC16noCh1Reload  ;10
    
    org 256*((HIGH($)))+#80
    
_rdnext
    dw outhi            ;12__   
    in a,(c)            ;12     ;read kbd
    
    cpl                 ;4
    and #1f             ;7
    jp nz,exit          ;10
    
    pop af              ;11
    jp m,rdseq0         ;10
    ld (C16hlpr),hl     ;16

    ld i,a              ;9      ;set timer
    jr z,C16noCh1X      ;12/7       
    pop de              ;10     ;smp1/freq1
    ld l,d              ;4       (21)
    ld h,HIGH(smptab)   ;7
    ld a,(hl)           ;7      ;fetch sample reset pointer
    ld (smp1reset),a    ;13
    nop                 ;4  (52, should be 53)
    dw outlo            ;12__143 naja   
    
    nop                 ;4
    ld d,0              ;7  
    inc hl              ;6
    ld a,(hl)           ;7
    ld (smp1reset+1),a  ;13
    ;____________________________192 (101)
    dw outhi            ;12__
    inc hl              ;6
    ld a,(hl)           ;7      ;fetch actual sample pointer
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    ld (C16hlpr),hl     ;16
    
C16noCh1Reload          ;(159)
    nop                 ;4
    jp pe,C16noCh2X     ;10
    dw outlo            ;12__72 ...meep TODO but how?
    exx                 ;4
    
    ld h,HIGH(smptab)   ;7
    pop bc              ;10
    ld l,b              ;4
    ld b,0              ;7
    ld a,(hl)           ;7
    ld (smp2reset),a    ;13     ;fetch sample reset
    inc l               ;4
    ld a,(hl)           ;7
    ld (smp2reset+1),a  ;13
    inc l               ;4
    ld a,(hl)           ;7      ;fetch sample pntr
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    exx                 ;4
    
C16noCh2Reload          ;(120)  
    ;____________________________192
    
    dw outhi            ;12__
    jr c,C16noCh3X      ;12/7
    pop ix              ;14
    exx                 ;4
    ld d,HIGH(smptab)   ;7
    ld e,ixh            ;8
    ld a,(de)           ;7
    ld (smp3reset),a    ;13
    inc e               ;4
    ld a,(de)           ;7
    ld a,(de)           ;7      ;timing
    pop de              ;10     ;smp3 pointer
    exx                 ;4
    ld ixh,0            ;11
    ld (smp3reset+1),a  ;13
    
C16noCh3Reload          ;(116)
    xor a               ;4
    ld iyl,a            ;8
    ex af,af'           ;4
    dw outlo            ;12__144
    
    ld a,(hl)           ;7      ;timing
    ld a,(hl)           ;7
C16hlpr equ $+1
    ld hl,0             ;10     ;restore hl
    
    nop                 ;4
    jp (iy)             ;8
    ;____________________________192

C16noCh3X
    jp XC16noCh3Reload  ;10



;*******************************************************************************
                        ;volume 17 - 152t
    org 256*(1+(HIGH($)))
core17
    dw outhi            ;12__
    ld a,d              ;4      update counter ch1
    add a,e             ;4
    ld d,a              ;4
    jp nc,_nos1upd      ;10

    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs1       ;10
    ld hl,(smp1reset)   ;16

_rs1                    ;(43)
    exx                 ;4
    ld a,b              ;4
    add a,c             ;4
    ld b,a              ;4
    jp nc,_nos2upd      ;10
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jr nz,_norvs2       ;12/7
    ret nz              ;5
    ld hl,(smp2reset)   ;16
    
_rs2                    ;(16)
    exx                 ;4
    dw outlo            ;12__152                    
    ds 2                ;8
    jr _xy              ;12
_xy ld a,ixh            ;8          
    ;_______________________________192
    
    dw outhi            ;12__
    exx                 ;4
    add a,ixl           ;8  
    ld ixh,a            ;8
    jr nc,_nos3upd      ;12/7
    
    inc de              ;6
    ld a,(de)           ;7
    or a                ;4
    jp nz,_norvs3       ;10
    ld de,(smp3reset)   ;20
    
_rs3                    ;(58/20)
    ld a,(de)           ;7
    add a,(hl)          ;7
    exx                 ;4
    
    add a,(hl)          ;7
    add a,basec         ;7
    ld iyh,a            ;8
    ex af,af'           ;4
    dec a               ;4
    jp z,updateTimer0   ;10
    ex af,af'           ;4
    nop                 ;4
    dw outlo            ;12__152
        
    ds 2                ;8
    jr _aa              ;12
_aa jp (iy)             ;8
    ;_______________________________192
    
    
_nos1upd
    ld a,(hl)           ;7
    jr _bb
_bb jr _cc
_norvs1 equ $-1
_cc jr _rs1
_nos2upd
    ld a,r              ;9
    jr _dd
_dd jr _ee
_norvs2 equ $-1
_ee jr _rs2
_nos3upd
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    jr _norvs3+1        ;12
_norvs3 equ $-1         ;(4)
    nop                 ;4
    jr _rs3             ;12


C17noCh2X               ;(__60)
    jr _aa              ;12
_aa jr _bb              ;12
_bb ld a,(hl)           ;7
    jp XC17noCh2Reload  ;10

C17noCh1X               ;(12)
    ld a,(hl)           ;7
    jp XC17noCh1Reload  ;10
    
XC17noCh3Reload         ;(22)
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ds 2                ;8
    jp C17noCh3Reload   ;10 (116)
    
    org 256*((HIGH($)))+#80
    
_rdnext
    dw outhi            ;12__   
    in a,(c)            ;12     ;read kbd
    
    cpl                 ;4
    and #1f             ;7
    jp nz,exit          ;10
    
    pop af              ;11
    jp m,rdseq0         ;10
    ld (C17hlpr),hl     ;16

    ld i,a              ;9      ;set timer
    jr z,C17noCh1X      ;12/7       
    pop de              ;10     ;smp1/freq1
    ld l,d              ;4       (21)
    ld h,HIGH(smptab)   ;7
    ld a,(hl)           ;7      ;fetch sample reset pointer
    ld (smp1reset),a    ;13
    ld d,0              ;7  
    inc hl              ;6
    dw outlo            ;12__152    
    
    ds 2                ;8
    
    ld a,(hl)           ;7
    ld (smp1reset+1),a  ;13
    ;____________________________192 (101)
    dw outhi            ;12__
    inc hl              ;6
    ld a,(hl)           ;7      ;fetch actual sample pointer
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    ld (C17hlpr),hl     ;16
    
C17noCh1Reload          ;(159)
    nop                 ;4
    jp pe,C17noCh2X     ;10
    dw outlo            ;12__72 ...meep TODO but how?
    exx                 ;4
    
    ld h,HIGH(smptab)   ;7
    pop bc              ;10
    ld l,b              ;4
    ld b,0              ;7
    ld a,(hl)           ;7
    ld (smp2reset),a    ;13     ;fetch sample reset
    inc l               ;4
    ld a,(hl)           ;7
    ld (smp2reset+1),a  ;13
    inc l               ;4
    ld a,(hl)           ;7      ;fetch sample pntr
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    exx                 ;4
    
C17noCh2Reload          ;(120)  
    ;____________________________192
    
    dw outhi            ;12__
    jr c,C17noCh3X      ;12/7
    pop ix              ;14
    exx                 ;4
    ld d,HIGH(smptab)   ;7
    ld e,ixh            ;8
    ld a,(de)           ;7
    ld (smp3reset),a    ;13
    inc e               ;4
    ld a,(de)           ;7
    ld a,(de)           ;7      ;timing
    pop de              ;10     ;smp3 pointer
    exx                 ;4
    ld ixh,0            ;11
    ld (smp3reset+1),a  ;13
    
C17noCh3Reload          ;(116)
    ld a,(hl)           ;7      ;timing
    ld a,(hl)           ;7
    xor a               ;4
    ex af,af'           ;4
    dw outlo            ;12__150 hrmmm
    
    xor a               ;4
    ld iyl,a            ;12
C17hlpr equ $+1
    ld hl,0             ;10     ;restore hl
    jp (iy)             ;8
    ;____________________________192

C17noCh3X
    jp XC17noCh3Reload  ;10



;*******************************************************************************
                        ;volume 18 - 160t
    org 256*(1+(HIGH($)))
core18
    dw outhi            ;12__
    ld a,d              ;4      update counter ch1
    add a,e             ;4
    ld d,a              ;4
    jp nc,_nos1upd      ;10

    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs1       ;10
    ld hl,(smp1reset)   ;16

_rs1                    ;(43)
    exx                 ;4
    ld a,b              ;4
    add a,c             ;4
    ld b,a              ;4
    jp nc,_nos2upd      ;10
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jr nz,_norvs2       ;12/7
    ret nz              ;5
    ld hl,(smp2reset)   ;16
    
_rs2                    ;(16)
    exx                 ;4
    ds 2                ;8
    dw outlo            ;12__160                    
    jr _xy
_xy ld a,ixh            ;8          
    ;_______________________________192
    
    dw outhi            ;12__
    exx                 ;4
    add a,ixl           ;8  
    ld ixh,a            ;8
    jr nc,_nos3upd      ;12/7
    
    inc de              ;6
    ld a,(de)           ;7
    or a                ;4
    jp nz,_norvs3       ;10
    ld de,(smp3reset)   ;20
    
_rs3                    ;(58/20)
    ld a,(de)           ;7
    add a,(hl)          ;7
    exx                 ;4
    
    add a,(hl)          ;7
    add a,basec         ;7
    ld iyh,a            ;8
    ex af,af'           ;4
    dec a               ;4
    jp z,updateTimer1   ;10
    ex af,af'           ;4
    jr _aa
_aa dw outlo            ;12__160
        
    jr _bb
_bb jp (iy)             ;8
    ;_______________________________192
    
    
_nos1upd
    ld a,(hl)           ;7
    jr _cc
_cc jr _dd
_norvs1 equ $-1
_dd jr _rs1
_nos2upd
    ld a,r              ;9
    jr _ee
_ee jr _ff
_norvs2 equ $-1
_ff jr _rs2
_nos3upd
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    jr _norvs3+1
_norvs3 equ $-1
    nop                 ;4
    jr _rs3             ;12


C18noCh2X               ;(__60)
    jr _aa              ;12
_aa jr _bb              ;12
_bb ld a,(hl)           ;7
    jp XC18noCh2Reload  ;10

C18noCh1X               ;(12)
    ld a,(hl)           ;7
    jp XC18noCh1Reload  ;10
    
XC18noCh3Reload         ;(22)
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ds 2                ;8
    jp C18noCh3Reload   ;10 (116)
    
    org 256*((HIGH($)))+#80
    
_rdnext
    dw outhi            ;12__   
    in a,(c)            ;12     ;read kbd
    
    cpl                 ;4
    and #1f             ;7
    jp nz,exit          ;10
    
    pop af              ;11
    jp m,rdseq0         ;10
    ld (C18hlpr),hl     ;16

    ld i,a              ;9      ;set timer
    jr z,C18noCh1X      ;12/7       
    pop de              ;10     ;smp1/freq1
    ld l,d              ;4       (21)
    ld h,HIGH(smptab)   ;7
    ld a,(hl)           ;7      ;fetch sample reset pointer
    ld (smp1reset),a    ;13
    ld d,0              ;7  
    inc hl              ;6
    ds 2                ;8
    dw outlo            ;12__160    
    
    ld a,(hl)           ;7
    ld (smp1reset+1),a  ;13
    ;____________________________192 (101)
    dw outhi            ;12__
    inc hl              ;6
    ld a,(hl)           ;7      ;fetch actual sample pointer
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    ld (C18hlpr),hl     ;16
    
C18noCh1Reload          ;(159)
    nop                 ;4
    jp pe,C18noCh2X     ;10
    dw outlo            ;12__72 ...meep TODO but how?
    exx                 ;4
    
    ld h,HIGH(smptab)   ;7
    pop bc              ;10
    ld l,b              ;4
    ld b,0              ;7
    ld a,(hl)           ;7
    ld (smp2reset),a    ;13     ;fetch sample reset
    inc l               ;4
    ld a,(hl)           ;7
    ld (smp2reset+1),a  ;13
    inc l               ;4
    ld a,(hl)           ;7      ;fetch sample pntr
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    exx                 ;4
    
C18noCh2Reload          ;(120)  
    ;____________________________192
    
    dw outhi            ;12__
    jr c,C18noCh3X      ;12/7
    pop ix              ;14
    exx                 ;4
    ld d,HIGH(smptab)   ;7
    ld e,ixh            ;8
    ld a,(de)           ;7
    ld (smp3reset),a    ;13
    inc e               ;4
    ld a,(de)           ;7
    ld a,(de)           ;7      ;timing
    pop de              ;10     ;smp3 pointer
    exx                 ;4
    ld ixh,0            ;11
    ld (smp3reset+1),a  ;13
    
C18noCh3Reload              ;(116)
    xor a               ;4
    ld iyl,a            ;8
    ex af,af'           ;4
    dec hl              ;6      ;timing
C18hlpr equ $+1
    ld hl,0             ;10     ;restore hl 
    dw outlo            ;12__160
    
    jr _aa              ;12
_aa jp (iy)             ;8
    ;____________________________192

C18noCh3X
    jp XC18noCh3Reload  ;10



;*******************************************************************************
                        ;volume 19 - 168t
    org 256*(1+(HIGH($)))
core19
    dw outhi            ;12__
    ld a,d              ;4      update counter ch1
    add a,e             ;4
    ld d,a              ;4
    jp nc,_nos1upd      ;10

    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs1       ;10
    ld hl,(smp1reset)   ;16

_rs1                    ;(43)
    exx                 ;4
    ld a,b              ;4
    add a,c             ;4
    ld b,a              ;4
    jp nc,_nos2upd      ;10
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jr nz,_norvs2       ;12/7
    ret nz              ;5
    ld hl,(smp2reset)   ;16
    
_rs2                    ;(16)
    exx                 ;4
    jr _aa              ;12
_aa nop
    dw outlo            ;12__168                    
    nop                 ;4
_xy ld a,ixh            ;8          
    ;_______________________________192
    
    dw outhi            ;12__
    exx                 ;4
    add a,ixl           ;8  
    ld ixh,a            ;8
    jr nc,_nos3upd      ;12/7
    
    inc de              ;6
    ld a,(de)           ;7
    or a                ;4
    jp nz,_norvs3       ;10
    ld de,(smp3reset)   ;20
    
_rs3                    ;(58/20)
    ld a,(de)           ;7
    add a,(hl)          ;7
    exx                 ;4
    
    add a,(hl)          ;7
    add a,basec         ;7
    ld iyh,a            ;8
    ex af,af'           ;4
    dec a               ;4
    jp z,updateTimer2   ;10
    ex af,af'           ;4
    jr _bb
_bb ds 2
    dw outlo            ;12__160
        
    nop                 ;4
    jp (iy)             ;8
    ;_______________________________192
    
    
_nos1upd
    ld a,(hl)           ;7
    jr _cc
_cc jr _dd
_norvs1 equ $-1
_dd jr _rs1

_nos2upd
    ld a,r              ;9
    jr _ee
_ee jr _ff
_norvs2 equ $-1
_ff jr _rs2
_nos3upd
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    jr _norvs3+1        ;12

_norvs3 equ $-1
    nop                 ;4
    jr _rs3             ;12


C19noCh2X               ;(__60)
    jr _aa              ;12
_aa jr _bb              ;12
_bb ld a,(hl)           ;7
    jp XC19noCh2Reload  ;10

C19noCh1X               ;(12)
    ld a,(hl)           ;7
    jp XC19noCh1Reload  ;10
    
XC19noCh3Reload         ;(22)
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ds 2                ;8
    jp C19noCh3Reload   ;10 (116)
    
    org 256*((HIGH($)))+#80
    
_rdnext
    dw outhi            ;12__   
    in a,(c)            ;12     ;read kbd
    
    cpl                 ;4
    and #1f             ;7
    jp nz,exit          ;10
    
    pop af              ;11
    jp m,rdseq0         ;10
    ld (C19hlpr),hl     ;16

    ld i,a              ;9      ;set timer
    jr z,C19noCh1X      ;12/7       
    pop de              ;10     ;smp1/freq1
    ld l,d              ;4       (21)
    ld h,HIGH(smptab)   ;7
    ld a,(hl)           ;7      ;fetch sample reset pointer
    ld (smp1reset),a    ;13
    ld d,0              ;7  
    inc hl              ;6
    ds 2                ;8
    ld a,(hl)           ;7
    dw outlo            ;12__167..naja  
    
    ld (smp1reset+1),a  ;13
    ;____________________________192 (101)
    dw outhi            ;12__
    inc hl              ;6
    ld a,(hl)           ;7      ;fetch actual sample pointer
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    ld (C19hlpr),hl     ;16
    
C19noCh1Reload          ;(159)
    nop                 ;4
    jp pe,C19noCh2X     ;10
    dw outlo            ;12__72 ...meep TODO but how?
    exx                 ;4
    
    ld h,HIGH(smptab)   ;7
    pop bc              ;10
    ld l,b              ;4
    ld b,0              ;7
    ld a,(hl)           ;7
    ld (smp2reset),a    ;13     ;fetch sample reset
    inc l               ;4
    ld a,(hl)           ;7
    ld (smp2reset+1),a  ;13
    inc l               ;4
    ld a,(hl)           ;7      ;fetch sample pntr
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    exx                 ;4
    
C19noCh2Reload          ;(120)  
    ;____________________________192
    
    dw outhi            ;12__
    jr c,C19noCh3X      ;12/7
    pop ix              ;14
    exx                 ;4
    ld d,HIGH(smptab)   ;7
    ld e,ixh            ;8
    ld a,(de)           ;7
    ld (smp3reset),a    ;13
    inc e               ;4
    ld a,(de)           ;7
    ld a,(de)           ;7      ;timing
    pop de              ;10     ;smp3 pointer
    exx                 ;4
    ld ixh,0            ;11
    ld (smp3reset+1),a  ;13
    
C19noCh3Reload          ;(116)
    xor a               ;4
    ld iyl,a
    ex af,af'           ;4
    dec hl              ;6      ;timing
C19hlpr equ $+1
    ld hl,0             ;10     ;restore hl
    ds 2                ;8  
    dw outlo            ;12__168
    
    nop                 ;4
    jp (iy)             ;8
    ;____________________________192

C19noCh3X
    jp XC19noCh3Reload  ;10



;*******************************************************************************
IF (CPU != EMUL)
                        ;volume 20 - 176/192t
    org 256*(1+(HIGH($)))
core20
    dw outhi            ;12__
    ld a,d              ;4      update counter ch1
    add a,e             ;4
    ld d,a              ;4
    jp nc,_nos1upd      ;10

    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs1       ;10
    ld hl,(smp1reset)   ;16

_rs1                    ;(43)
    exx                 ;4
    ld a,b              ;4
    add a,c             ;4
    ld b,a              ;4
    jp nc,_nos2upd      ;10
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jr nz,_norvs2       ;12/7
    ret nz              ;5
    ld hl,(smp2reset)   ;16
    
_rs2                    ;(16)
    exx                 ;4
    jr _aa              ;12
_aa nop
    ld a,ixh            ;8
    dw outlo            ;12__176                    
    nop                 ;4              
    ;_______________________________192
    
    dw outhi            ;12__
    exx                 ;4
    add a,ixl           ;8  
    ld ixh,a            ;8
    jr nc,_nos3upd      ;12/7
    
    inc de              ;6
    ld a,(de)           ;7
    or a                ;4
    jp nz,_norvs3       ;10
    ld de,(smp3reset)   ;20
    
_rs3                    ;(58/20)
    ld a,(de)           ;7
    add a,(hl)          ;7
    exx                 ;4
    
    add a,(hl)          ;7
    add a,basec         ;7
    ld iyh,a            ;8
    ex af,af'           ;4
    dec a               ;4
    jp z,updateTimer3   ;10
    ex af,af'           ;4
    jr _bb
_bb jr _cc
_cc jr _dd
_dd jp (iy)             ;8
    ;_______________________________192
    
    
_nos1upd
    ld a,(hl)           ;7
    jr _ee
_ee jr _ff
_norvs1 equ $-1
_ff jr _rs1
_nos2upd
    ld a,r              ;9
    jr _gg
_gg jr _hh
_norvs2 equ $-1
_hh jr _rs2
_nos3upd
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    jr _norvs3+1        ;12

_norvs3 equ $-1
    nop                 ;4
    jr _rs3             ;12


C20noCh2X               ;
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    jp XC20noCh2Reload  ;10

C20noCh1X               ;(12)
    ld a,(hl)           ;7
    jp XC20noCh1Reload  ;10
    
XC20noCh3Reload         ;(22)
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ds 2                ;8
    jp C20noCh3Reload   ;10 (116)

C20noCh2XX
    jr C20noCh2Reload   ;12
    
    org 256*((HIGH($)))+#80
    
_rdnext
    dw outhi            ;12__   
    in a,(c)            ;12     ;read kbd
    
    cpl                 ;4
    and #1f             ;7
    jp nz,exit          ;10
    
    pop af              ;11
    jp m,rdseq0         ;10
    ld (C20hlpr),hl     ;16

    ld i,a              ;9      ;set timer
    jr z,C20noCh1X      ;12/7       
    pop de              ;10     ;smp1/freq1
    ld l,d              ;4       (21)
    ld h,HIGH(smptab)   ;7
    ld a,(hl)           ;7      ;fetch sample reset pointer
    ld (smp1reset),a    ;13
    ld d,0              ;7  
    inc hl              ;6
    nop                 ;4
    ld a,(hl)           ;7
    ld (smp1reset+1),a  ;13
    dw outlo            ;12__176    
    nop                 ;4  
    ;____________________________192 (101)
    dw outhi            ;12__
    inc hl              ;6
    ld a,(hl)           ;7      ;fetch actual sample pointer
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    ld (C20hlpr),hl     ;16
    
C20noCh1Reload              ;(159)  
    jp pe,C20noCh2X     ;10
    exx                 ;4
    
    ld h,HIGH(smptab)   ;7
    pop bc              ;10
    ld l,b              ;4
    ld b,0              ;7
    ld a,(hl)           ;7
    ld (smp2reset),a    ;13     ;fetch sample reset
    inc l               ;4
    ld a,(hl)           ;7
    ld (smp2reset+1),a  ;13
    inc l               ;4
    ld a,(hl)           ;7      ;fetch sample pntr
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    exx                 ;4
    
C20noCh2Reload          ;(108)
    dw outlo            ;12__176
    nop                 ;4  
    ;____________________________192
    
    dw outhi            ;12__
    jr c,C20noCh3X      ;12/7
    pop ix              ;14
    exx                 ;4
    ld d,HIGH(smptab)   ;7
    ld e,ixh            ;8
    ld a,(de)           ;7
    ld (smp3reset),a    ;13
    inc e               ;4
    ld a,(de)           ;7
    ld a,(de)           ;7      ;timing
    pop de              ;10     ;smp3 pointer
    exx                 ;4
    ld ixh,0            ;11
    ld (smp3reset+1),a  ;13
    
C20noCh3Reload              ;(116)
    xor a               ;4
    ld iyl,a            ;8
    ex af,af'           ;4
    dec hl              ;6      ;timing
C20hlpr equ $+1
    ld hl,0             ;10     ;restore hl
    ds 2                ;8  
    dw outlo            ;12__168
    
    nop                 ;4
    jp (iy)             ;8
    ;____________________________192

C20noCh3X
    jp XC20noCh3Reload  ;10
XC20noCh2Reload
    jp C20noCh2XX       ;10 (120)


;*******************************************************************************
                        ;volume 21 - 192t
    org 256*(1+(HIGH($)))
core21
    dw outhi            ;12__
    ld a,d              ;4      update counter ch1
    add a,e             ;4
    ld d,a              ;4
    jp nc,_nos1upd      ;10

    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jp nz,_norvs1       ;10
    ld hl,(smp1reset)   ;16

_rs1                    ;(43)
    exx         ;4
    ld a,b          ;4
    add a,c         ;4
    ld b,a          ;4
    jp nc,_nos2upd      ;10
    inc hl              ;6
    ld a,(hl)           ;7
    or a                ;4
    jr nz,_norvs2       ;12/7
    ret nz              ;5
    ld hl,(smp2reset)   ;16
    
_rs2                    ;(16)
    exx                 ;4
    
    ld a,ixh            ;8
    jr _aa              ;12
_aa jr _bb              ;12
_bb ds 2                ;8          
    ;_______________________________192
    
    dw outhi            ;12__
    exx                 ;4
    add a,ixl           ;8  
    ld ixh,a            ;8
    jr nc,_nos3upd      ;12/7
    
    inc de              ;6
    ld a,(de)           ;7
    or a                ;4
    jp nz,_norvs3       ;10
    ld de,(smp3reset)   ;20
    
_rs3                    ;(58/20)
    ld a,(de)           ;7
    add a,(hl)          ;7
    exx                 ;4
    
    add a,(hl)          ;7
    add a,basec         ;7
    ld iyh,a            ;8
    ex af,af'           ;4
    dec a               ;4
    jp z,updateTimer    ;10
    ex af,af'           ;4

    jr _cc              ;12
_cc jr _dd              ;12
_dd jr _ee              ;12
_ee jp (iy)             ;8
    ;_______________________________192
    
    
_nos1upd
    ld a,(hl)           ;7
    jr _ff
_ff jr _gg
_norvs1 equ $-1
_gg jr _rs1

_nos2upd
    ld a,r              ;9
    jr _hh
_hh jr _ii
_norvs2 equ $-1
_ii jr _rs2

_nos3upd
    ld a,(hl)           ;7
    ld a,(hl)           ;7
    jr _norvs3+1        ;12

_norvs3 equ $-1
    nop                 ;4
    jr _rs3             ;12
    

C21noCh2X
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    jr _aa              ;12
_aa ds 2                ;8
    jr C21noCh2Reload   ;12 (108)

C21noCh3X
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ret nc              ;5
    jr C21noCh3Reload   ;12 (+4=109)
    
    
    org 256*((HIGH($)))+#80
    
_rdnext
    dw outhi            ;12__   
    in a,(c)            ;12     ;read kbd
    
    cpl                 ;4
    and #1f             ;7
    jp nz,exit          ;10
    
    pop af              ;11
    jp m,rdseq          ;10
    ld (C21hlpr),hl     ;16

    ld i,a              ;9      ;set timer
    ld h,HIGH(smptab)   ;7
    jr z,C21noCh1X      ;12/7
    
    pop de              ;10     ;smp1/freq1
    ld l,d              ;4
    ld d,0              ;7
    ld a,(hl)           ;7      ;fetch sample reset pointer
    ld (smp1reset),a    ;13
    inc hl              ;6
    ld a,(hl)           ;7
    ld (smp1reset+1),a  ;13
    
    inc hl              ;6
    ld a,(hl)           ;7      ;fetch actual sample pointer
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    ld (C21hlpr),hl     ;16
    
C21noCh1Reload          ;(120)
    jp pe,C21noCh2X     ;10
    exx                 ;4
    
    ld h,HIGH(smptab)   ;7
    pop bc              ;10
    ld l,b              ;4
    ld b,0              ;7
    ld a,(hl)           ;7
    ld (smp2reset),a    ;13     ;fetch sample reset
    inc l               ;4
    ld a,(hl)           ;7
    ld (smp2reset+1),a  ;13
    inc l               ;4
    ld a,(hl)           ;7      ;fetch sample pntr
    inc hl              ;6
    ld h,(hl)           ;7
    ld l,a              ;4
    exx                 ;4
    
C21noCh2Reload          ;(108)  
    jr c,C21noCh3X      ;12/7
    pop ix              ;14
    exx                 ;4
    ld d,HIGH(smptab)   ;7
    ld e,ixh            ;8
    ld a,(de)           ;7
    ld (smp3reset),a    ;13
    inc e               ;4
    ld a,(de)           ;7
    ld (smp3reset+1),a  ;13
    pop de              ;10     ;smp3 pointer
    exx                 ;4
    ld ixh,0            ;11
    
C21noCh3Reload equ $-1  ;(4)    ;(109)
    dec hl              ;6      ;timing
C21hlpr equ $+1
    ld hl,0             ;10     ;restore hl
    xor a               ;4
    ld iyl,a            ;8
    ex af,af'           ;4
    
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ld a,(hl)           ;7
    ds 2                ;8
    jp (iy)             ;8
    ;____________________________576=3*192

C21noCh1X               ;(12)
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    ex (sp),hl          ;19
    jr _aa              ;12
_aa ds 2                ;8
    jr C21noCh1Reload   ;12 (120)

ENDIF
;*******************************************************************************
    org 256*(1+(HIGH($)))
    
smptab
    include "sampletab.asm"
samples
    include "samples.asm"
musicdata
    include "music.asm"

IF ($ > #ffe0 || $ < #8000)
.ERROR Too much data!
ENDIF
