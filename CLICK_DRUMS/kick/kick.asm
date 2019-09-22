;;; KICK DRUM SYNTHESIZER
;;; by utz 09'2019 * irrlichtproject.de

;;; USAGE: 1) Define DRUM_RETURN_ADDRESS
;;;        2) Prepare stack
;;;           SP+0 - decay mode (NO_DECAY, LINEAR_DECAY/_X2, EXPONENTIAL_DECAY)
;;;           SP+2 - sweep speed (bit mask, more bits ~ faster speed)
;;;           SP+3 - initial pitch (higher value ~ higher pitch)
;;;           SP+4 - volume ((1..7)<<4)
;;;           SP+5 - length
;;;        3) JP kick_drum_init
;;;
;;; TIMING: ca. (length * 112 * 256 + (length - 1) * 24) cycles
;;;
;;; REGISTER USAGE: F/F' destroyed, SP += 6


NO_DECAY equ #5faf              ; xor a; ld e,a
LINEAR_DECAY equ #1d00          ; nop; dec e
LINEAR_DECAY_X2 equ #1d1d       ; dec e; dec e
EXPONENTIAL_DECAY equ #3bcb     ; srl e

kick_drum_init
    ld (_oldHL),hl              ; 16
    ld (_oldDE),de              ; 20
    ld (_oldBC),bc              ; 20
    ld (_oldA),a                ; 13
    ex af,af'                   ;  4
    ld (_oldAshadow),a          ; 13

    pop bc                      ; 10    volume|length<<8
    ld a,b                      ;  4
    ex af,af'                   ;  4
    pop de                      ; 10    sweep_speed|initial_pitch<<8
    pop hl                      ; 10
    ld (_end_mode),hl           ; 16
    xor a                       ;  4
    ld h,a                      ;  4
    ld l,a                      ;  4
    ld b,#fe                    ;  7    adjust timer lo
    ex af,af'                   ;  4 -- init 163

    ex af,af'
_play_kick
    out (#fe),a                 ; 11__29
    add hl,de                   ; 11
    jr nc,_wait                 ; 12/7

    rlc e                       ;  8
    jr nc,_no_sweep_update      ; 12/7
    srl d                       ;  8 -- 30

    ld a,h                      ;  4
    rlca                        ;  4
    sbc a,a                     ;  4
    and c                       ;  4
    out (#fe),a                 ; 11__68
    rrca                        ;  4
    out (#fe),a                 ; 11__15
    rrca                        ;  4
    dec b                       ;  4
    jp nz,_play_kick            ; 10 --- 112

    ex af,af'
    dec a
    jr nz,_play_kick - 1
    jr _exit

_wait                           ;+12
    ld a,d                      ;  4
    or a                        ;  4
    jr z,_play_kick_end0        ; 12/7

_no_sweep_update
    nop                         ;  4
    ld a,h                      ;  4
    rlca                        ;  4
    sbc a,a                     ;  4
    and c                       ;  4
    out (#fe),a                 ; 11
    rrca                        ;  4
    out (#fe),a                 ; 11
    rrca                        ;  4
    djnz _play_kick             ; 13 --- 112

    ex af,af'
    dec a
    jr nz,_play_kick - 1
    jr _exit


_play_kick_end0
    ld e,#80
    jp _wait_return_end

    ex af,af'
_play_kick_end
    out (#fe),a                 ; 11__29
    add hl,de                   ; 11
    jr nc,_wait_end             ; 12/7

_end_mode
    ds 2                        ;  8
    ld a,0                      ;  7    timing
    ds 2                        ;  8 -- 30

_wait_return_end
    ld a,h                      ;  4
    rlca                        ;  4
    sbc a,a                     ;  4
    and c                       ;  4
    out (#fe),a                 ; 11__68
    rrca                        ;  4
    out (#fe),a                 ; 11__15
    rrca                        ;  4
    dec b                       ;  4
    jp nz,_play_kick_end        ; 10

    ex af,af'
    dec a
    jr nz,_play_kick_end - 1

_exit
_oldHL equ $+1
    ld hl,0                     ; 10
_oldDE equ $+1
    ld de,0                     ; 10
_oldBC equ $+1
    ld bc,0                     ; 10
_oldAshadow equ $+1
    ld a,0                      ;  7
    ex af,af'                   ;  4
_oldA equ $+1
    ld a,0                      ;  7
    jp DRUM_RETURN_ADDRESS      ; 10 -- exit 58, init+exit 221

_wait_end                       ;+12
    ds 2                        ;  8
    jp _wait_return_end         ; 10 -- 30
