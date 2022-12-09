;;; Pindsvin - Combined Squeeker/Pin Pulse engine for ZX Spectrum beeper
;;; by utz 11-12'2022 * irrlichtproject.de

    device zxspectrum48
    org #8000

    include "note_names.h"

pindsvin_init
    di
    exx
    push hl
    push iy
    ld (.old_sp),sp
    ld sp,music_data
    ld b,0
    jr .read_sequence0

.read_sequence_loop
    pop hl
    ld sp,hl
    jr .read_sequence0

.read_sequence
    exx
    ld (.phase_ch1),hl
.seq_ptr = $+1
    ld sp,0
.read_sequence0
    pop hl
    ld a,h
    or l
    jr z,.read_sequence_loop    ;       replace with jr z,.exit to disable loop
    ld (.seq_ptr),sp
    ld sp,hl

.read_step
    pop af
    ld l,a                      ;       row length msb*2
    ex af,af'                   ;       adjust row length
    xor a
    ld a,l
    rra
    ld i,a
    exx
    rr b
    exx
    ex af,af'
    jp m,pwm_init

.drum_return
    jr nc,.skip_ch3
    pop hl
    ld a,l
    ld (.vol_ch3),a
    dec sp
    pop hl
    ld (.fdiv_buf+4),hl

.skip_ch3
    jr nz,.skip_ch4
    pop hl
    ld a,l
    ld (.vol_ch4),a
    dec sp
    pop hl
    ld (.fdiv_buf+6),hl

.skip_ch4
    jp po,.skip_ch5
    pop hl
    ld a,l
    ld (.vol_ch5),a
    dec sp
    pop hl
    ld (.fdiv_buf+8),hl

.skip_ch5
    pop af
    dec sp
    jr nc,.skip_mix_mode
    ld (.mix12),a
    inc sp

.skip_mix_mode
    jr nz,.skip_ch1
    pop hl
    ld a,l
    ld (.duty_ch1),a
    dec sp
    pop hl
    ld (.fdiv_buf),hl

.skip_ch1
    jp po,.skip_ch2
    pop hl
    ld a,l
    ld (.duty_ch2),a
    dec sp
    pop hl
    ld (.fdiv_buf+2),hl

.skip_ch2
    jp p,.skip_phase12

    pop hl
    pop de
    jp .play_note+4

.skip_phase12
.phase_ch1 = $+1
    ld hl,0
    db #fa                      ;       jp m (never taken)

.play_note
    exx                         ; 4
    or c                        ; 4
    out (#fe),a                 ;11

    ld sp,.fdiv_buf             ;10
    pop bc                      ;10
    add hl,bc                   ;11     TODO noise mode?
    ld a,h                      ; 4
.duty_ch1 = $+1
    add a,0                     ; 7
    sbc a,a                     ; 4
    ex af,af'                   ; 4
    ex de,hl                    ; 4
    pop bc                      ;10
    add hl,bc                   ;11
    ex de,hl                    ; 4
    ld a,d                      ; 4
.duty_ch2 = $+1
    add a,0                     ; 7
    sbc a,a                     ; 4
    ld c,a                      ; 4
    ex af,af'                   ; 4
.mix12
    or c                        ; 4     #b1 (or c) = squeek, #a9 (xor c) = phase
    ld c,a                      ; 4

    exx                         ; 4
    pop de                      ;10
    add hl,de                   ;11
    sbc a,a                     ; 4
.vol_ch3 = $+1
    and 0                       ; 7
    add a,c                     ; 4
    ld c,a                      ; 4

    pop de                      ;10
    add ix,de                   ;15
    sbc a,a                     ; 4
.vol_ch4 = $+1
    and 0                       ; 7
    add a,c                     ; 4
    ld c,a                      ; 4

    pop de                      ;10
    add iy,de                   ;15
    sbc a,a                     ; 4
.vol_ch5 = $+1
    and 0                       ; 7
    add a,c                     ; 4
    jr z,.no_pfm_pulse          ; 7/12
    ld c,a                      ; 4
    dec c                       ; 4
    ld a,#ff                    ; 7
.skipret
    djnz .play_note             ;13..292

    ex af,af'
    in a,(#fe)
    cpl
    and #1f
    jr nz,.exit

    ld a,i
    dec a
    jp z,.read_sequence
    ld i,a
    ex af,af'

    jp .play_note

.no_pfm_pulse
    jp .skipret                 ;10

.exit
.old_sp = $+1
    ld sp,0
    pop iy
    pop hl
    exx
    ei
    ret

.fdiv_buf
    ds 10


;;; Pulse Width Modulated Drums
;;; A reusable click drum system for ZX Spectrum beeper engines
;;; by utz/irrlicht project 09'2019 * irrlichtproject.de
;;; Adjusted for Pindsvin Engine
;;;
;;; Usage: In the calling code, define the symbol DRUM_RETURN_ADDRESS and set
;;;        it to the address that the player should return to.
;;;        To play a drum, 'JP pwm_init' with length as 1st byte, volume as 2nd
;;;        byte, and pointer to PWM data as second word on stack. Interrupts
;;;        should be disabled. Volume must be (0x10..0xf0) & 0xf0
;;;
;;;        Timing offset must be corrected manually. Execution takes
;;;        (146 * length * 256 + 5 * (length - 1) - 32) cycles.
;;;
;;;        The routine preserves all registers except F and SP.
;;;
;;;        PWM data should use a sample rate of 23973 Hz. The end of a sample
;;;        must be marked with a 0-byte.


pwm_init
    ld (.old_HL),hl             ; 16
    ld (.old_BC),bc             ; 20
    ld (.old_DE),de             ; 20
    ex af,af'

    pop de                      ; 10    volume/length
    pop hl                      ; 10    pwm data pointer

    ld a,d                      ; 4
    ld (.volume_restore),a      ; 13
    ld c,#fe                    ; 7

    ld d,(hl)                   ; 7
    xor a                       ; 4
    ld b,#fe                    ; 7     timer lo, skip 2 loops to adjust time
                                ; init 131

.play_drum0
    nop                         ; 4
.play_drum
    ds 2
    out (#fe),a                 ; 11__32

    rlca                        ; 4
    rlca                        ; 4
    dec d                       ; 4
    jr nz,.wait                 ; 12/7

.volume_restore = $+1         ;       load next sample byte
    xor 0                       ; 7
    inc hl                      ; 6
    ld d,(hl)                   ; 7
    ld d,(hl)                   ; 7     timing
    ld d,(hl)                   ; 7     timing

.wait_ret
    jr 1F
1
    jp 1F
1
    out (#fe),a                 ; 11__64

    rrca                        ; 4
    nop
    out (c),a                   ; 12__16
    rrca                        ; 4

    djnz .play_drum0            ; 13 --- 112     update length counter lo-byte

    dec e                       ; 4
    jp nz,.play_drum            ; 10


.drum_exit
    ex af,af'
.old_HL = $+1
    ld hl,0                     ; 10
.old_BC = $+1
    ld bc,0                     ; 10
.old_DE = $+1
    ld de,0                     ; 10

.exit_drum
    jp pindsvin_init.drum_return    ; 10 -- exit 61, init+exit 192


.wait                           ;+12
    inc d                       ; 4     check for sample end
    jr z,.disable_drum          ; 12
    dec d                       ; 4
    ds 2                        ; 8
    jr .wait_ret                ; 12 -- 52


.wait_for_drum_end
    ds 2                        ; 8
    ex (sp),hl                  ; 19
    ex (sp),hl                  ; 19
    ex (sp),hl                  ; 19
    ex (sp),hl                  ; 19

.disable_drum
    xor a                       ; 4
    out (#fe),a                 ; 11
    djnz .wait_for_drum_end     ; 13

    dec e
    jp nz,.wait_for_drum_end+1

    jr .drum_exit


    display $-pindsvin_init


music_data
    include "music.asm"

end
    savetap "main.tap",CODE,"main",pindsvin_init,end-pindsvin_init
