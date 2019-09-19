;;; Pulse Width Modulated Drums
;;; A reusable click drum system for ZX Spectrum beeper engines
;;; by utz/irrlicht project 09'2019 * irrlichtproject.de
;;;
;;; Usage: In the calling code, define the symbol DRUM_RETURN_ADDRESS and set
;;;        it to the address that the player should return to.
;;;        To play a drum, 'JP pwm_init' with length as 1st byte, volume as 2nd
;;;        byte, and pointer to PWM data as second word on stack. Interrupts
;;;        should be disabled. Volume must be (0x10..0xf0) & 0xf0
;;;
;;;        Timing offset must be corrected manually. Execution takes
;;;        (112 * length * 256 + 5 * (length - 1) - 32) cycles.
;;;
;;;        The routine preserves all registers except F and SP.
;;;
;;;        PWM data should use a sample rate of 31250 Hz. The end of a sample
;;;        must be marked with a 0-byte.


pwm_init
    ld (_old_HL),hl             ; 16
    ld (_old_BC),bc             ; 20
    ld (_old_DE),de             ; 20
    ld (_old_A),a               ; 13

    pop de                      ; 10    volume/length
    pop hl                      ; 10    pwm data pointer

    ld a,d                      ; 4
    ld (_volume_restore),a      ; 13
    ld c,#fe                    ; 7

    ld d,(hl)                   ; 7
    xor a                       ; 4
    ld b,#fe                    ; 7     timer lo, skip 2 loops to adjust time
                                ; init 131

_play_drum0
    nop                         ; 4
_play_drum
    out (#fe),a                 ; 11__32

    rlca                        ; 4
    rlca                        ; 4
    dec d                       ; 4
    jr nz,_wait                 ; 12/7

_volume_restore equ $+1         ;       load next sample byte
    xor 0                       ; 7
    inc hl                      ; 6
    ld d,(hl)                   ; 7
    ld d,(hl)                   ; 7     timing
    ld d,(hl)                   ; 7     timing

_wait_ret
    out (#fe),a                 ; 11__64

    rrca                        ; 4
    out (c),a                   ; 12__16
    rrca                        ; 4

    djnz _play_drum0            ; 13 --- 112     update length counter lo-byte

    dec e                       ; 4
    jp nz,_play_drum            ; 10


_drum_exit
_old_A equ $+1
    ld a,0                      ; 7
_old_HL equ $+1
    ld hl,0                     ; 10
_old_BC equ $+1
    ld bc,0                     ; 10
_old_DE equ $+1
    ld de,0                     ; 10

_exit_drum
    jp DRUM_RETURN_ADDRESS      ; 10 -- exit 61, init+exit 192


_wait                           ;+12
    inc d                       ; 4     check for sample end
    jr z,_disable_drum          ; 12
    dec d                       ; 4
    ds 2                        ; 8
    jr _wait_ret                ; 12 -- 52


_wait_for_drum_end
    ds 2                        ; 8
    ex (sp),hl                  ; 19
    ex (sp),hl                  ; 19
    ex (sp),hl                  ; 19
    ex (sp),hl                  ; 19

_disable_drum
    xor a                       ; 4
    out (#fe),a                 ; 11
    djnz _wait_for_drum_end     ; 13

    dec e
    jp nz,_wait_for_drum_end+1

    jp DRUM_RETURN_ADDRESS
