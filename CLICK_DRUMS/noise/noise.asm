;;; zx beeper noise generator click drum
;;; by utz 09'2019 * irrlichtproject.de
;;; based on el cheapo PRNG with improvements by Shiru
;;;
;;; USAGE: 1) Define DRUM_RETURN_ADDRESS
;;;        2) Set up the stack: SP+0 - 0, SP+1 - volume ((1..7)<<4)
;;;                             SP+2 - pitch (1..0xff, 1 is highest)
;;;                             SP+4 - length
;;;        3) JP noise_init
;;;
;;; TIMING: length * 112 + (length - 1) * 13 + 8 cycles
;;;
;;; REGISTER USAGE: F destroyed, SP += 4

noise_init
    ld (_oldHL),hl              ; 16
    ld (_oldDE),de              ; 20
    ld (_oldBC),bc              ; 20
    ld (_oldIX),ix              ; 20
    ld (_oldA),a                ; 13

    pop af                      ; 10    volume
    ld (_volume),a              ; 13
    pop bc                      ; 10    pitch|length<<8
    ld ixl,c                    ;  8
    ld de,#2157                 ; 10    initial PRNG seed
    xor a                       ;  4
    ld h,a                      ;  4
    ld l,a                      ;  4
    ld ixh,#fe                  ; 11 -- init: 163   adjust timer lo

_loop
    out (#fe),a                 ; 11__33
    dec c                       ;  4
    jr nz,_no_update            ; 12/7

    ld c,ixl                    ;  8    restore pitch
    add hl,de                   ; 11    el cheapo PRNG
    rlc h                       ;  8
    inc d                       ;  4 -- 48

_wait_return
    ld a,h                      ;  4
_volume equ $+1
    and #30                     ;  7
    out (#fe),a                 ; 11__64
    rrca                        ;  4
    out (#fe),a                 ; 11__15
    rrca                        ;  4
    dec ixh                     ;  4
    jp nz,_loop                 ; 10 --- 112

    djnz _loop

_oldHL equ $+1
    ld hl,0                     ; 10
_oldDE equ $+1
    ld de,0                     ; 10
_oldBC equ $+1
    ld bc,0                     ; 10
_oldIX equ $+2
    ld ix,0                     ; 10
_oldA equ $+1
    ld a,0                      ;  7
    jp DRUM_RETURN_ADDRESS      ; 14 -- exit 61, init+exit 224

_no_update                      ;+12
    ds 6                        ; 24
    jr _wait_return             ; 12 -- 48
