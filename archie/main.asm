;;; square wave fft applied as 3x sine approximation

LOOPING equ 1

    org #8000

    include "equates.asm"


player_init
    di
    exx
    push hl
    push iy
    ld iy,0
    ld (_oldSP),sp
    ld sp,music_data
    jr _skip_sp_read


_read_sequence
_sequence_pointer equ $+1
    ld sp,0
_skip_sp_read
    pop hl
    ld a,h
    or l
IF LOOPING = 1
    jr nz,_set_sp
    pop hl
    ld sp,hl
    jr _skip_sp_read
ELSE
    jp _exit_player
ENDIF

_set_sp
    ld (_sequence_pointer),sp
    ld (_pattern_pointer),hl


_read_pattern
    in a,(#fe)
    cpl
    and #1f
    jp nz,_exit_player

    ld (_phase_ch2a),sp

_pattern_pointer equ $+1
    ld sp,0
    pop af                      ; F = ctrl bits, A = step length
    jr z,_read_sequence


    jr c,_no_update_ch1

    pop de                      ; DE = phase offset ch1a
    pop hl
    ld (_fdiv_ch1a),hl
    pop hl
    ld (_fdiv_ch1),hl
    ld bc,0                     ; phase ch1

_no_update_ch1
    jp pe,_no_update_ch2

    pop hl
    ld (_phase_ch2a),hl
    pop hl
    ld (_fdiv_ch2a),hl
    exx
    pop bc                      ; BC' = fdiv_ch2
    ld ix,0                     ; phase ch2
    exx

_no_update_ch2
    jp m,_no_update_ch3
    exx
    pop de                      ; fdiv_ch3
    pop hl                      ; sweep_enable << 8 | duty ch3
    ex af,af'
    ld a,h
    ld (_duty_sweep_ch3_enable),a
    ld a,l
    or a
    jr z,_no_duty_reset
    ld iyl,a

_no_duty_reset
    ex af,af'
    ld hl,0
    exx

_no_update_ch3
    ex af,af'

    pop hl                      ;       fetch click drum
    ld a,l
    or a
    jp z,_drum_return

    push hl
    srl a                       ;       row length correction
    jr nc,_no_half_row

    ld iyh,#80

_no_half_row
    neg
    ld l,a
    ex af,af'
    add a,l
    ex af,af'

    jp pwm_init

_drum_return
    ld (_pattern_pointer),sp

_phase_ch2a equ $+1
    ld sp,0


_play_note
_fdiv_ch1a equ $+1
    ld hl,0                     ; 10

    out (#fe),a                 ; 11 __ 62 v2

    add hl,bc                   ; 11
    ld b,h                      ; 4
    ld c,l                      ; 4
    ld a,b                      ; 4

_fdiv_ch1 equ $+1
    ld hl,0                     ; 10

    out (#fe),a                 ; 11__ 44 v3

    add hl,de                   ; 11
    ld a,h                      ; 4
    out (#fe),a                 ; 11__ 26 v1a

    ex de,hl                    ; 4

_fdiv_ch2a equ $+1
    ld hl,0                     ; 10
    add hl,sp                   ; 11
    ld sp,hl                    ; 6
    ld a,h                      ; 4

    exx                         ; 4
    add ix,bc                   ; 15            fdiv_ch2

    out (#fe),a                 ; 11__ 65 v1

    ld a,ixh                    ; 8
    out (#fe),a                 ; 11__ 19 v2a

    add hl,de                   ; 11            fdiv_ch3
    ld a,h                      ; 4
    add a,iyl                   ; 8             duty -> could theoretically be replaced with noise
    or h                        ; 4

    exx                         ; 4
    dec iyh                     ; 8
    jp nz,_play_note            ; 10 --- 224


    ex af,af'
    dec a
    jp z,_read_pattern

_duty_sweep_ch3_enable          ;               #fd to enable, 0 to disable
    nop                         ;               #fd, inc l = inc iyl
    inc l                       ;               inc l by itself does nothing
    ex af,af'
    jp _play_note


_exit_player
_oldSP equ $+1
    ld sp,0
    pop iy
    pop hl
    exx
    ei
    ret

DRUM_RETURN_ADDRESS equ _drum_return
drums
    include "drum.asm"

music_data
    include music.asm
