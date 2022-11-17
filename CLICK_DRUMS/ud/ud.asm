;;; UD - ULTIMATE DRUM SYNTHESIZER
;;; by utz 01'2021 * irrlichtproject.de
;;;
;;; USAGE: 1) Define DRUM_RETURN_ADDRESS
;;;        2) Put pointer to drum instrument definition on top of stack
;;;        3) JP ud_init
;;;
;;; DRUM INSTRUMENT DEFINITION
;;;
;;; offset | function
;;; -------|---------
;;; 0      | volume kick¹
;;; 1      | volume noise¹
;;; 2      | kick sweep speed (lower = faster sweep, 0 interpreted as 256)
;;; 3      | kick initial pitch (higher value = higher pitch)
;;; 4      | noise freq divider (lower = higher pitch, 0 interpreted as 256)
;;; 5      | length lo (0 interpreted as 256)
;;; 6      | length hi
;;;
;;; ¹ [0..0xf] << 8, combined kick+noise volume shall not exceed 255
;;;
;;; TIMING: 488t + (length * 224t) + ((length/256) * 14t)
;;;
;;; REGISTER USAGE: SP += 2


    ;; ixl - noise freq divider
    ;; b' - noise freq counter
    ;; hl' - prng state
    ;; de' - prng seed
    ;; b - timer lo
    ;; c - temp/#fe
    ;; d - kick freq counter
    ;; e - kick freq divider
    ;; l - kick freq sweep speed counter
    ;; h - timer hi


ud_init
    ld (_old_sp),sp             ; 20
    ld sp,_temp_stack_end       ; 10
    push ix                     ; 15
    push hl                     ; 11
    push de                     ; 11
    push bc                     ; 11
    exx                         ; 4
    push hl                     ; 11
    push de                     ; 11
    push bc                     ; 11
    push af                     ; 11
    ex af,af'                   ; 4
    push af                     ; 11

_old_sp equ $+1
    ld sp,0                     ; 10

    pop hl                      ; 10
    ld (_old_sp2),sp            ; 20

    ld sp,hl                    ; 6
    pop hl                      ; 10

    ld a,l                      ; 4
    ld (_kick_vol),a            ; 13
    ld a,h                      ; 4
    ld (_noise_vol),a           ; 13
    pop hl                      ; 10
    ld a,l                      ; 4
    ld (_kick_sweep_speed),a    ; 13
    ld e,h                      ; 4
    ld d,0                      ; 7

    exx                         ; 4
    pop ix                      ; 15
    ld b,ixl                    ; 8
    ld hl,0                     ; 10
    ld de,#2157                 ; 10
    exx                         ; 4
    pop bc                      ; 10
    ld b,ixh                    ; 8
    ld h,c                      ; 4 -- 342

_play_drum
    exx                         ; 4
    djnz _no_noise_update       ; 8       update noise freq counter

    ld b,ixl                    ; 8       reset noise freq counter
    add hl,de                   ; 11      generate next random value
    rlc h                       ; 8 (35)

_wait_return1
    ld a,h                      ; 4       calculate frame volume
    exx                         ; 4

_noise_vol equ $+1
    and 0                       ; 7
    ld c,a                      ; 4

    ld a,d                      ; 4
    add a,a                     ; 4
    sbc a,a                     ; 4
_kick_vol equ $+1
    and 0                       ; 7

    add a,c                     ; 4
    ld c,#fe                    ; 7

    out (#fe),a                 ; 11__112
    rrca                        ; 4
    out (c),a                   ; 12__16

    ex af,af'                   ; 4
    ld a,d                      ; 4       update kick freq counter
    add a,e                     ; 4
    ex af,af'                   ; 4

    rrca                        ; 4
    out (c),a                   ; 12__32

    ex af,af'                   ; 4
    ld d,a                      ; 4
    sbc a,a                     ; 4
    add a,l                     ; 4       update kick sweep freq counter
    jp nz,_no_sweep_update      ; 10
    nop                         ; 4
_kick_sweep_speed equ $+1
    ld l,0                      ; 7       reset sweep freq counter
    srl e                       ; 8 (29)  sweep kick freq counter

_wait_return2
    ex af,af'                   ; 4

    rrca                        ; 4
    out (#fe),a                 ; 11__64
    djnz _play_drum             ; 13


    dec h                       ; 4
    jp nz,_play_drum            ; 10

    ld sp,_temp_stack           ; 10
    pop af                      ; 10
    ex af,af'                   ; 4
    pop af                      ; 10
    pop bc                      ; 10
    pop de                      ; 10
    pop hl                      ; 10
    exx                         ; 4
    pop bc                      ; 10
    pop de                      ; 10
    pop hl                      ; 10
    pop ix                      ; 14

_old_sp2 equ $+1
    ld sp,0                     ; 10

    jp DRUM_RETURN_ADDRESS      ; 10 -- 146 + 342 = 488t, ca. 2 frames overhead


_no_noise_update                ;+13
    ds 3                        ; 12
    jp _wait_return1            ; 10 (35)

_no_sweep_update                ;+10
    ret z                       ; 5      timing
    ld l,a                      ; 4
    jp _wait_return2            ; 10 (29)

_temp_stack
    ds 18
_temp_stack_end
