;;; Pulsatilla - Combined Squeeker/Pulse-Interleaving engine for ZX beeper
;;; by utz 11'2022 * irrlichtproject.de
;;;
;;; This code uses sjasmplus syntax, see https://github.com/z00m128/sjasmplus
;;; for details.


    device zxspectrum48
    org #8000

    include "note_names.h"

pulsatilla_init
    di
    exx
    push hl
    push iy
    ld (.old_sp),sp
    ld sp,music_data
    ld b,0                      ;       timer lo
    jr .read_sequence+10

.read_sequence_loop
    pop hl
    ld sp,hl
    jr .read_sequence+10

.read_sequence
    ld (.phase_ch1),hl
    ld (.note_ch2),sp
.seq_ptr = $+1
    ld sp,0
    pop hl
    ld a,h
    or l
    jr z,.read_sequence_loop    ;       replace with jp z,.exit to disable loop
    ld (.seq_ptr),sp
    ld sp,hl

.read_step
    pop af
    jp c,ud_init
.drum_return
    jr nz,.skip_ch1

    ex af,af'
    pop af
    dec sp
    jr nz,.skip_ch1_duty
    ld (.duty_ch1),a
    inc sp
.skip_ch1_duty
    jr nc,.skip_ch1_note
    pop de
.skip_ch1_note
    jp po,.skip_ch1_phase
    pop hl
    ld (.phase_ch1),hl
.skip_ch1_phase
    ld a,7                      ;       cb 07 = rlc a
    jp p,.set_ch1_noise
    ld a,4                      ;       cb 04 = rlc h
.set_ch1_noise
    ld (.noise_enable),a
    ex af,af'

.skip_ch1
    jp p,.skip_ch2

    ex af,af'
    pop af
    dec sp
    jr nz,.skip_ch2_duty
    ld (.duty_ch2),a
    inc sp
.skip_ch2_duty
    jr nc,.skip_ch2_note
    pop hl
    ld (.note_ch2),hl
.skip_ch2_note
    jp po,.skip_ch2_phase
    pop ix
.skip_ch2_phase
    ld a,#b1                    ;       or c
    jp p,.set_ch12_mix
    ld a,#a9                    ;       xor c
.set_ch12_mix
    ld (.mix12),a
    ex af,af'

.skip_ch2
    exx
    jp po,.skip_ch3

    ex af,af'
    pop af
    dec sp
    jr nz,.skip_ch3_duty
    ld (.duty_ch3),a
    inc sp
.skip_ch3_duty
    jr nc,.skip_ch3_note
    pop de
.skip_ch3_note
    jp po,.skip_ch3_phase
    pop hl
.skip_ch3_phase
    ex af,af'

.skip_ch3
    or a
    rra                         ;       bit 0 of A is ctrl bit for ch4
    jr nc,.skip_ch4

    ex af,af'
    pop af
    dec sp
    jr nz,.skip_ch4_duty
    ld (.duty_ch4),a
    inc sp
.skip_ch4_duty
    jr nc,.skip_ch4_note
    pop bc
.skip_ch4_note
    jp po,.skip_ch4_phase
    ld iy,0
.skip_ch4_phase
    ld a,0
    jp p,.set_pwm_sweep
    ld a,#9f
.set_pwm_sweep
    ld (.duty_sweep_enable),a
    ex af,af'

.skip_ch4
    exx
    or a
    rra
    rr b                        ;       reduce step length by 1/2 if bit was set
    ld i,a                      ;       timer hi

.phase_ch1 = $+1
    ld hl,0
.note_ch2 = $+1
    ld sp,0

.play_sound
    add hl,de                   ;11
    out (#fe),a                 ;11_56 ch3

.noise_enable = $+1
    rlc a                       ; 8     #04 (rlc h) = enable, #07 = disable
    ld a,h                      ; 4
.duty_ch1 = $+1
    add a,0                     ; 7
    sbc a,a                     ; 4
    ld c,a                      ; 4

    add ix,sp                   ;15
    ld a,ixh                    ; 8
.duty_ch2 = $+1
    add a,0                     ; 7
    sbc a,a                     ; 4
.mix12
    or c                        ; 4     #b1 (or c) = squeek, #a9 (xor c) = phase

    nop                         ; 4
    out (#fe),a                 ;11__80 ch4

    exx                         ; 4
    add hl,de                   ;11
.duty_ch3 = $+1
    ld a,0                      ; 7
    add a,h                     ; 4
    sbc a,a                     ; 4
    ex af,af'                   ; 4

    add iy,bc                   ;15
.duty_sweep_enable
    sbc a,a                     ; 4     #9f (sbc a,a) = enable, #00 = disable
.duty_ch4 = $+1
    add a,0                     ; 7
    ld (.duty_ch4),a            ;13

    ex af,af'                   ; 4
    out (#fe),a                 ;11__88 ch1+2
    ex af,af                    ; 4

    add a,iyh                   ; 8
    sbc a,a                     ; 4

    exx                         ; 4
    dec b                       ; 4
    jp nz,.play_sound           ;10..224

    in a,(#fe)
    cpl
    and #1f
    jr nz,.exit

    ld a,i                      ;       TODO cannot smash A here, still needed
    dec a
    ld i,a
    jr nz,.play_sound+1         ;
    jp .read_sequence

.exit
.old_sp = $+1
    ld sp,0
    pop iy
    pop hl
    exx
    ei
    ret

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
    ld (.old_sp),sp             ; 20
    ld sp,.temp_stack_end       ; 10
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

.old_sp = $+1
    ld sp,0                     ; 10

    pop hl                      ; 10
    ld (.old_sp2),sp            ; 20

    ld sp,hl                    ; 6
    pop hl                      ; 10

    ld a,l                      ; 4
    ld (.kick_vol),a            ; 13
    ld a,h                      ; 4
    ld (.noise_vol),a           ; 13
    pop hl                      ; 10
    ld a,l                      ; 4
    ld (.kick_sweep_speed),a    ; 13
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

.play_drum
    exx                         ; 4
    djnz .no_noise_update       ; 8       update noise freq counter

    ld b,ixl                    ; 8       reset noise freq counter
    add hl,de                   ; 11      generate next random value
    rlc h                       ; 8 (35)

.wait_return1
    ld a,h                      ; 4       calculate frame volume
    exx                         ; 4

.noise_vol = $+1
    and 0                       ; 7
    ld c,a                      ; 4

    ld a,d                      ; 4
    add a,a                     ; 4
    sbc a,a                     ; 4
.kick_vol = $+1
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
    jp nz,.no_sweep_update      ; 10
    nop                         ; 4
.kick_sweep_speed = $+1
    ld l,0                      ; 7       reset sweep freq counter
    srl e                       ; 8 (29)  sweep kick freq counter

.wait_return2
    ex af,af'                   ; 4

    rrca                        ; 4
    out (#fe),a                 ; 11__64
    djnz .play_drum             ; 13


    dec h                       ; 4
    jp nz,.play_drum            ; 10

    ld sp,.temp_stack           ; 10
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

.old_sp2 equ $+1
    ld sp,0                     ; 10

    jp pulsatilla_init.drum_return    ; 10 -- 146 + 342 = 488t, ca. 2 frames overhead


.no_noise_update                ;+13
    ds 3                        ; 12
    jp .wait_return1            ; 10 (35)

.no_sweep_update                ;+10
    ret z                       ; 5      timing
    ld l,a                      ; 4
    jp .wait_return2            ; 10 (29)

.temp_stack
    ds 18
.temp_stack_end

    display $-pulsatilla_init

music_data
    include "music.asm"

end
    savetap "main.tap",CODE,"main",pulsatilla_init,end-pulsatilla_init
