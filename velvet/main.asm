;;; VELVET
;;; by utz/irrlicht project 09'2019 * irrlichtproject.de

;;; A pulse-frequency modulating sound engine for the ZX Spectrum beeper with
;;; support for Crushed Additive Random Noise, a type of velvet noise first
;;; described by Kurt James Werner in
;;; http://dafx2019.bcu.ac.uk/papers/DAFx2019_paper_53.pdf

LOOPING equ 1

    include "equates.asm"

    org #8000

init_player
    di
    exx
    push hl
    push iy
    ld (_oldSP),sp
    ld sp,music_data
    ld bc,0
    jr _skip_sequence_pointer_update


_read_sequence
_sequence_pointer equ $+1
    ld sp,0
_skip_sequence_pointer_update
    pop hl
    ld a,h
    or l
IF LOOPING = 1
    jr nz,_continue
ELSE
    jp z,_exit_player
ENDIF
    pop hl                      ; fetch loop pointer
    ld sp,hl
    jr _skip_sequence_pointer_update

_continue
    ld (_sequence_pointer),sp
    ld (_pattern_pointer),hl


_read_pattern
    in a,(#fe)
    cpl
    and #1f
    jp nz,_exit_player

_pattern_pointer equ $+1
    ld sp,0
    pop af                      ; F = control bits, A = step length counter high
    jr z,_read_sequence

    jr c,_no_noise_update

    pop hl                      ; noise envelope pointer
    ld (_noise_env_ptr),hl

_no_noise_update
    jp pe,_no_ch1_update

    pop hl
    ld (_ch1_env_ptr),hl
    pop hl
    ld (_fdiv_ch1),hl
    ;; exx
    ;; pop bc                      ; BC' = channel 1 frequency divider
    ;; exx

_no_ch1_update
    jp m,_no_ch2_update

    pop hl
    ld (_ch2_env_ptr),hl
    pop hl                      ; store channel 2 frequency divider in mem
    ld (_fdiv_ch2),hl

_no_ch2_update
    pop af                      ; row length now in A
    jr z,_no_ch3_update

    pop hl
    ld (_ch3_env_ptr),hl
    pop hl
    ld (_fdiv_ch3),hl

_no_ch3_update
    jp m,kick_drum

_drum_return
    dec b                       ; adjust row length to account for loader delay
    dec b
    ld (_pattern_pointer),sp
    ld sp,0                     ; reset PRNG state
    jp _no_timer_update


_update_env
    ex af,af'                   ; update step length counter hi
    dec a
    jr z,_read_pattern

_no_timer_update
    ex af,af'

_noise_env_ptr equ $+1
    ld hl,0
    ld a,(hl)
    or a
    ;; ld (_noise_density),a
    ld c,a
    jr z,_no_noise_env_update

    inc hl
    ld (_noise_env_ptr),hl

_no_noise_env_update
_ch1_env_ptr equ $+1
    ld hl,0
    ld a,(hl)
    or a
    ld (_vol_ch1),a
    jr z,_no_ch1_env_update
    inc hl
    ld (_ch1_env_ptr),hl

_no_ch1_env_update
_ch2_env_ptr equ $+1
    ld hl,0
    ld a,(hl)
    or a
    ld (_vol_ch2),a
    jr z,_no_ch2_env_update
    inc hl
    ld (_ch2_env_ptr),hl

_no_ch2_env_update
_ch3_env_ptr equ $+1
    ld hl,0
    ld a,(hl)
    or a
    ld (_vol_ch3),a
    jr z,_play_note
    inc hl
    ld (_ch3_env_ptr),hl


_play_note
    ld a,e                      ; 4     update next pulse counter
    add a,c                     ; 4
    ld e,a                      ; 4
    jr nc,_wait                 ; 12/7  if counter hasn't expired, do nothing

    ld hl,#2175                 ; 10
    add hl,sp                   ; 11    and calculate next random number
    rlc h                       ; 8
    ld e,h                      ; 4
    ld sp,hl                    ; 6
    exx                         ; 4
    inc c                       ; 4 -- 54    raise output level

_wait_ret
_fdiv_ch1 equ $+1
    ld de,0                     ; 10
    add iy,de                   ; 15
    sbc a,a                     ; 4
_vol_ch1 equ $+1
    and 2                       ; 7
    add a,c                     ; 4
    ld c,a                      ; 4
_fdiv_ch2 equ $+1
    ld de,0                     ; 10
    add hl,de                   ; 11
    sbc a,a                     ; 4
_vol_ch2 equ $+1
    and 2                       ; 7
    add a,c                     ; 4
    ld c,a                      ; 4
_fdiv_ch3 equ $+1
    ld de,0                     ; 10
    add ix,de                   ; 15
    sbc a,a                     ; 4
_vol_ch3 equ $+1
    and 2                       ; 7
    add a,c                     ; 4
    jr z,_no_outp               ; 12/7

    dec a                       ; 4     if output level > 0, decrement it
    ld c,a                      ; 4
    ld a,#10                    ; 7     and switch beeper on
    out (#fe),a                 ; 11
    exx                         ; 4
    djnz _play_note             ; 13 -- 50 --- 240
    jp _update_env

_no_outp                        ; +12   if output level = 0
    ret nz                      ;  5    timing
    ret nz                      ;  5    timing
    out (#fe),a                 ; 11    switch beeper off
    exx                         ; 4
    djnz _play_note             ; 13 -- 47
    jp _update_env

_wait                           ; +12
    exx                         ; 4
    ds 7                        ; 28
    jp _wait_ret                ; 10 -- 54

_exit_player
_oldSP equ $+1
    ld sp,0
    pop iy
    pop hl
    exx
    ei
    ret

DRUM_RETURN_ADDRESS equ _drum_return
kick_drum
    include "kick.asm"

music_data
    include "music.asm"
