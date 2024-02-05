;;; ulasyn - 2ch beeper engine with lp/hp filters
;;; by utz 01'2024 * irrlichtproject.de

    device zxspectrum48
    org #8000

    ;; filter table generators
    macro LP cutoff, volume
.start
    dup 14
    if (($ - .start) >> 1) > volume
        if ($ & 1) == 0 && ((($ - .start) >> 1) - cutoff) < volume
                db ((($ - .start) >> 1) - cutoff)
        else
                db volume
        endif
    else
        if abs ((($ - .start) >> 1) - (($ & 1) * volume)) > cutoff
                db (($ - .start) >> 1) - cutoff + (2 * cutoff * ($ & 1))
        else
                db ($ & 1) * volume
        endif
    endif
    edup
    endm

;; .start
;;     dup 14
;;     if abs ((($ - .start) >> 1) - (($ & 1) * volume)) > cutoff
;;         db (($ - .start) >> 1) - cutoff + (2 * cutoff * ($ & 1))
;;     else
;;         db ($ & 1) * volume
;;     endif
;;     edup
;;     endm

    macro HP cutoff, volume
.start
    dup 14
    if abs ((($ - .start) >> 1) - (($ & 1) * volume)) > cutoff
        ;; normalize signal by + cutoff - 1 in both cases
        if ($ & 1) == 1
                db abs ((($ - .start) >> 1) + cutoff - volume) + cutoff - 1
        else
                db (($ - .start) >> 1) - 1 ;; - cutoff
        endif
    else
        db 0
    endif
    edup
    endm


    include "note_names.h"


init_player
    ei                          ; detect kempston
    halt
    in a,(#1f)
    inc a
    jr nz,1F
    ld (read_pattern.mask_kempston),a
1
    di
    ld bc,#fe
    exx
    ld bc,#fe
    push iy
    push hl
    ld (exit_player.old_sp),sp
    ld iyl,0
    ld hl,vol0
    ld (read_pattern.old_hl),hl
    ld hl,music_data
    ld (read_sequence.sequence_ptr),hl

read_sequence
.sequence_ptr = $+1
    ld sp,0
    pop hl
    ld a,h
    or l
    jr nz,1F

    pop hl                      ; read loop point
    ld sp,hl
    pop hl
1
    ld (.sequence_ptr),sp
    ld sp,hl
    jp read_pattern.from_seq

read_pattern0
    out (c),b                   ; switch beeper off when vol <= 6
read_pattern
    ld (.old_hl),hl             ; preserve current volume core jump address

    in a,(#1f)                  ; read joystick
.mask_kempston = $+1
    and #1f
    ld h,a
    in a,(#fe)                  ; read kbd
    cpl
    or h
    and #1f
    jp nz,exit_player

.pattern_ptr = $+1
    ld sp,0
.from_seq
    pop af
    jr z,read_sequence

    ld iyh,a
    jp m,play_drum

.from_drum
    jr nc,.no_ch1_update

    ex af,af'
    pop af                      ; reserved/flags

    jr nz,1F
    pop hl                      ; freq ch1
    ld ix,0                     ; reset phase
    ld (row_buffer),hl
1
    jr nc,1F
    pop hl                      ; duty/sweep speed ch1
    ld (row_buffer+2),hl
1
    jp p,1F
    pop hl                      ; filter table ptr
    ld (row_buffer+4),hl
1
    ex af,af'

.no_ch1_update
    jp po,.no_ch2_update

    pop af                      ; noise_enable/flags
    ld (noise_enable),a

    jr nz,1F
    pop hl                      ; freq ch2
    ld (row_buffer+6),hl
    exx
    ld hl,0                     ; reset phase
    exx
1
    jr nc,1F
    pop hl                      ; duty/sweep speed ch2
    ld (row_buffer+8),hl
1
    jp p,1F
    pop hl                      ; filter table ptr
    ld (row_buffer+10),hl
1
.no_ch2_update
    ld (.pattern_ptr),sp

.old_hl = $+1
    ld hl,vol0
    jp (hl)


play_drum
    ex af,af'
    ld a,b
    ld (.old_b),a
    pop de                      ; drum ptr
    pop hl                      ; drum length (16-bit)
    xor a                       ; adjust remaining row length
    sub l
    ld iyl,a
    jr z,1F

    scf
1
    ld a,iyh
    sbc a,h
    ld iyh,a

    add hl,hl                   ; pwm renders twice as fast as main, so double length counter
    ex de,hl
    ld c,(hl)
    inc hl
    exx
    pop de                      ; pitch mask<<8|vol? - vol mask leaves every even bit empty for +3 compat
    ld a,e
    exx

.render_drum
    out (#fe),a                 ;11--104
    ld b,a                      ; 4  store volume
    rrca                        ; 4
    rrca                        ; 4
    or a                        ; 4  timing
    ret c                       ; 5  timing
    out (#fe),a                 ;11--32
    rrca                        ; 4
    rrca                        ; 4
    exx                         ; 4
    rrc d                       ; 8  apply pitch mask
    exx                         ; 4
    jp nc,.wait0                ;10

    cp (hl)                     ; 7  timing
    dec c                       ; 4  update pwm length counter
    out (#fe),a                 ;11--56

    jr nz,.wait1                ; 7*

    ld a,(hl)                   ; 7* load next pwm sample
    or a                        ; 4*
    jr z,.wait2                 ; 7' if 0, end of sample reached

    inc hl                      ; 6' point to following pwm sample
    ld c,a                      ; 4'
    ld a,b                      ; 4' flip phase
    exx                         ; 4'
    xor e                       ; 4'
    exx                         ; 4'
    ld b,a                      ; 4'

.stop
    ds 2                        ; 8  timing
    dec de                      ; 6
    ld a,d                      ; 4
    or e                        ; 4
    ld a,b                      ; 4  restore volume
    jr nz,.render_drum          ;12--192

.drum_end
.old_b = $+1
    ld b,0
    ld c,#fe
    ex af,af'
    jp read_pattern.from_drum

.wait0
    cp (hl)                     ; 7
    nop                         ; 4
    out (#fe),a                 ;11--56
    jr .wait1                   ;12

.wait1                          ;
    ds 2                        ; 8
    jp 1F                       ;10
1
.wait2                          ;(12)
    nop                         ; 4
    xor a                       ; 4
    ret c                       ; 5
    jr .stop                    ;12__37


    display "drum end ", $


    ;; one render core for each volume level

    align 256
vol0
    out (c),b                   ;12  c = #fe, b = prev_vol_ch1, bit 4 never set!
    jp .from_vol12              ;10  this delay is needed so vol12 can jump here
.from_vol12
    dec iyl                     ; 8
    jr z,.update_clock          ; 7
.ret
    ld sp,row_buffer            ;10
    pop de                      ;10  channel 1 freq
    add ix,de                   ;15  update ch1 oscillator

    pop de                      ;10  duty<<8 | sweep_speed
    sbc a,a                     ; 4  when osc update overflowed,
    and e                       ; 4
    add a,d                     ; 4  duty_ch1 = duty_ch1 + sweep_speed
    ld (duty_ch1),a             ;13

    add a,ixh                   ; 8  now actually apply duty
    ld a,b                      ; 4
    rla                         ; 4  A = prev_vol_ch1<<1 | channel_state&1

    pop de                      ;10  filter table base ptr
    or e                        ; 4  apply offset
    ld e,a                      ; 4
    ld a,(de)                   ; 7  look up next volume
    ld b,a                      ; 4  store as prev_vol

    exx                         ; 4  channel 2

    pop de                      ;10  freq
    add hl,de                   ;11

    pop de                      ;10  duty/sweep
    sbc a,a                     ; 4
    and e                       ; 4
    add a,d                     ; 4
    ld (duty_ch2),a             ;13

    add a,h                     ; 4
    ld a,b                      ; 4
    rla                         ; 4

    pop de                      ;10  filter tab
    or e                        ; 4
    ld e,a                      ; 4
    ld a,(de)                   ; 7
    ld b,a                      ; 4

    ld a,(noise_enable)         ;13  normally 0 | #ff, but could be any value
    and h                       ; 4  cheapo prng, disabled by noise_enable == 0
    rlca                        ; 4
    xor h                       ; 4
    ld h,a                      ; 4

    ld a,b                      ; 4  sum up channel volumes

    exx                         ; 4

    add a,b                     ; 4
    add a,high vol0             ; 7
    ld h,a                      ; 4

    ex (sp),hl                  ;19  timing
    ex (sp),hl                  ;19  timing
    inc (hl)                    ;11  timing
    dec (hl)                    ;11  timing
    ld a,(hl)                   ; 7  timing
    ds 2                        ; 8  timing
    jp (hl)                     ; 4--384

.update_clock
    dec iyh
    jp z,read_pattern
    jp .ret


noise_enable
    db 0
row_buffer
duty_ch1 = $+3
duty_ch2 = $+9
    ds 12


    align 16
t_filter_off_vol1
    dup 7
    db 0
    db 1
    edup

    align 16
t_filter_off_vol2
    dup 7
    db 0
    db 2
    edup

    align 16
t_filter_off_vol3
    dup 7
    db 0
    db 3
    edup

    align 16
t_filter_off_vol4
    dup 7
    db 0
    db 4
    edup

    align 16
t_filter_off_vol5
    dup 7
    db 0
    db 5
    edup

    align 16
t_filter_off_vol6
    dup 7
    db 0
    db 6
    edup

    align 8
t_lp_cutoff1_vol2
    LP 1,2

    align 8
t_lp_cutoff1_vol3
    LP 1,3

    align 8
t_lp_cutoff1_vol4
    LP 1,4

    align 8
t_lp_cutoff1_vol5
    LP 1,5

    display "vol 0 end: ",$

    align 256
vol1
    out (c),c                   ;12  c = #fe
    nop                         ; 4*
    out (c),b                   ;12**16   b = prev_vol_ch1, bit 4 never set!

    dec iyl                     ; 8  update clock lsb
    jr z,.update_clock          ; 7
.ret
    ld sp,row_buffer            ;10
    pop de                      ;10  channel 1 freq
    add ix,de                   ;15  update ch1 oscillator

    pop de                      ;10  duty<<8 | sweep_speed
    sbc a,a                     ; 4  when osc update overflowed,
    and e                       ; 4
    add a,d                     ; 4  duty_ch1 = duty_ch1 + sweep_speed
    ld (duty_ch1),a             ;13

    add a,ixh                   ; 8  now actually apply duty
    ld a,b                      ; 4
    rla                         ; 4  A = prev_vol_ch1<<1 | channel_state&1

    pop de                      ;10  filter table base ptr
    or e                        ; 4  apply offset
    ld e,a                      ; 4
    ld a,(de)                   ; 7  look up next volume
    ld b,a                      ; 4  store as prev_vol

    dec (hl)                    ;11  timing
    inc (hl)                    ;11  timing
    jr 1F                       ;12--192
1
    out (c),c                   ;12

    exx                         ; 4* channel 2

    out (c),b                   ;12**16

    pop de                      ;10  freq
    add hl,de                   ;11

    pop de                      ;10  duty/sweep
    sbc a,a                     ; 4
    and e                       ; 4
    add a,d                     ; 4
    ld (duty_ch2),a             ;13

    add a,h                     ; 4
    ld a,b                      ; 4
    rla                         ; 4

    pop de                      ;10  filter tab
    or e                        ; 4
    ld e,a                      ; 4
    ld a,(de)                   ; 7
    ld b,a                      ; 4

    ld a,(noise_enable)         ;13
    and h                       ; 4  cheapo prng, disabled by noise_enable == 0
    rlca                        ; 4
    xor h                       ; 4
    ld h,a                      ; 4

    ld a,b                      ; 4

    exx                         ; 4

    add a,b                     ; 4
    add a,high vol0             ; 7
    ld h,a                      ; 4

    ld a,(hl)                   ; 7  timing
    nop                         ; 4
    jp (hl)                     ; 4--192

.update_clock
    dec iyh                     ; update clock msb
    jp z,read_pattern0
    jp .ret


    align 16
t_lp_cutoff1_vol6
    LP 1,6

    align 8
t_lp_cutoff2_vol2
    LP 3,2

    align 8
t_lp_cutoff2_vol3
    LP 3,3

    align 8
t_lp_cutoff2_vol4
    LP 3,4

    align 8
t_lp_cutoff2_vol5
    LP 3,5

    align 8
t_lp_cutoff2_vol6
    LP 3,6

    align 8
t_lp_cutoff3_vol2
    LP 3,2

    align 8
t_lp_cutoff3_vol3
    LP 3,3

    align 8
t_lp_cutoff3_vol4
    LP 3,4


    display "vol 1 end: ",$

    align 256
vol2
    out (c),c                   ;12  c = #fe
    dec iyl                     ; 8*
    jr nz,1F                    ;12*

    dec iyh
    jp z,read_pattern0

1
    out (c),b                   ;12**32

    ld sp,row_buffer            ;10
    pop de                      ;10  channel 1 freq
    add ix,de                   ;15  update ch1 oscillator

    pop de                      ;10  duty<<8 | sweep_speed
    sbc a,a                     ; 4  when osc update overflowed,
    and e                       ; 4
    add a,d                     ; 4  duty_ch1 = duty_ch1 + sweep_speed
    ld (duty_ch1),a             ;13

    add a,ixh                   ; 8  now actually apply duty
    ld a,b                      ; 4
    rla                         ; 4  A = prev_vol_ch1<<1 | channel_state&1

    pop de                      ;10  filter table base ptr
    or e                        ; 4  apply offset
    ld e,a                      ; 4
    ld a,(de)                   ; 7  look up next volume
    ld b,a                      ; 4  store as prev_vol

    exx                         ; 4

    pop de                      ;10  freq  channel 2
    add hl,de                   ;11
    sbc a,a                     ; 4
    nop                         ; 4--192

    out (c),c                   ;12
    inc de                      ; 6* timing
    pop de                      ;10* duty/sweep
    and e                       ; 4*
    out (c),b                   ;12**32

    add a,d                     ; 4
    ld (duty_ch2),a             ;13

    add a,h                     ; 4
    ld a,b                      ; 4
    rla                         ; 4

    pop de                      ;10  filter tab
    or e                        ; 4
    ld e,a                      ; 4
    ld a,(de)                   ; 7
    ld b,a                      ; 4

    ld a,(noise_enable)         ;13
    and h                       ; 4  cheapo prng, disabled by noise_enable == 0
    rlca                        ; 4
    xor h                       ; 4
    ld h,a                      ; 4

    ld a,b                      ; 4

    exx                         ; 4

    add a,b                     ; 4
    add a,high vol0             ; 7
    ld h,a                      ; 4

    inc (hl)                    ;11  timing
    dec (hl)                    ;11  timing
    jr 1F                       ;12  timing
1
    jp (hl)                     ; 4--192


exit_player
.old_sp = $+1
    ld sp,0
    pop hl
    pop iy
    exx
    ei
    ret

    align 16
t_lp_cutoff3_vol5
    LP 3,5

    align 8
t_lp_cutoff3_vol6
    LP 3,6

    align 8
t_lp_cutoff4_vol2
    LP 4,2

    align 8
t_lp_cutoff4_vol3
    LP 4,3

    align 8
t_lp_cutoff4_vol4
    LP 4,4

    align 8
t_lp_cutoff4_vol5
    LP 4,5

    align 8
t_lp_cutoff4_vol6
    LP 4,6

    align 16
t_lp_cutoff5_vol2
    LP 5,2

    align 16
t_lp_cutoff5_vol3
    LP 5,3

    align 16
t_lp_cutoff5_vol4
    LP 5,4

    display "vol 2 end: ",$


    align 256
vol3
    out (c),c                   ;12  c = #fe
    dec iyl                     ; 8*
    jr nz,1F                    ;12*

    dec iyh
    jp z,read_pattern0
1
    ld sp,row_buffer            ;10*
    dec de                      ; 6* timing
    out (c),b                   ;12**48

    pop de                      ;10  channel 1 freq
    add ix,de                   ;15  update ch1 oscillator

    pop de                      ;10  duty<<8 | sweep_speed
    sbc a,a                     ; 4  when osc update overflowed,
    and e                       ; 4
    add a,d                     ; 4  duty_ch1 = duty_ch1 + sweep_speed
    ld (duty_ch1),a             ;13

    add a,ixh                   ; 8  now actually apply duty
    ld a,b                      ; 4
    rla                         ; 4  A = prev_vol_ch1<<1 | channel_state&1

    pop de                      ;10  filter table base ptr
    or e                        ; 4  apply offset
    ld e,a                      ; 4
    ld a,(de)                   ; 7  look up next volume
    ld b,a                      ; 4  store as prev_vol

    exx                         ; 4

    xor a                       ; 4  timing
    ret nz                      ; 5
    nop                         ; 4
    pop de                      ;10--192  freq  channel 2


    out (c),c                   ;12

    add hl,de                   ;11*
    ld a,0                      ; 7* timing
    sbc a,a                     ; 4*
    pop de                      ;10* duty/sweep
    and e                       ; 4*
    out (c),b                   ;12**48

    add a,d                     ; 4
    ld (duty_ch2),a             ;13

    add a,h                     ; 4
    ld a,b                      ; 4
    rla                         ; 4

    pop de                      ;10  filter tab
    or e                        ; 4
    ld e,a                      ; 4
    ld a,(de)                   ; 7
    ld b,a                      ; 4

    ld a,(noise_enable)         ;13
    and h                       ; 4  cheapo prng, disabled by noise_enable == 0
    rlca                        ; 4
    xor h                       ; 4
    ld h,a                      ; 4

    ld a,b                      ; 4

    exx                         ; 4

    add a,b                     ; 4
    add a,high vol0             ; 7
    ld h,a                      ; 4

    ld a,(hl)                   ; 7  timing
    ld a,(hl)                   ; 7  timing
    nop                         ; 4
    jp (hl)                     ; 4--192


    align 16
t_lp_cutoff5_vol5
    LP 5,5

    align 16
t_lp_cutoff5_vol6
    LP 5,6

    ;; dot5 filters do +2 on rising edge, -1 on falling edge
    align 8
t_lp_cutoff1dot5_vol2
    db 0                        ; 0->0
    db 2                        ; 0->6
    db 0                        ; 1->0
    db 2                        ; 1->6
    db 1                        ; 2->0
    db 2                        ; 2->6
    db 2                        ; 3->0
    db 2                        ; 3->6
    db 2                        ; 4->0
    db 2                        ; 4->6
    db 2                        ; 5->0
    db 2                        ; 5->6
    db 2                        ; 6->0
    db 2                        ; 6->6

    align 8
t_lp_cutoff1dot5_vol3
    db 0                        ; 0->0
    db 2                        ; 0->6
    db 0                        ; 1->0
    db 3                        ; 1->6
    db 1                        ; 2->0
    db 3                        ; 2->6
    db 2                        ; 3->0
    db 3                        ; 3->6
    db 3                        ; 4->0
    db 3                        ; 4->6
    db 3                        ; 5->0
    db 3                        ; 5->6
    db 3                        ; 6->0
    db 3                        ; 6->6

    align 8
t_lp_cutoff1dot5_vol4
    db 0                        ; 0->0
    db 2                        ; 0->6
    db 0                        ; 1->0
    db 3                        ; 1->6
    db 1                        ; 2->0
    db 4                        ; 2->6
    db 2                        ; 3->0
    db 4                        ; 3->6
    db 3                        ; 4->0
    db 4                        ; 4->6
    db 4                        ; 5->0
    db 4                        ; 5->6
    db 4                        ; 6->0
    db 4                        ; 6->6

    align 8
t_lp_cutoff1dot5_vol5
    db 0                        ; 0->0
    db 2                        ; 0->6
    db 0                        ; 1->0
    db 3                        ; 1->6
    db 1                        ; 2->0
    db 4                        ; 2->6
    db 2                        ; 3->0
    db 5                        ; 3->6
    db 3                        ; 4->0
    db 5                        ; 4->6
    db 4                        ; 5->0
    db 5                        ; 5->6
    db 5                        ; 6->0
    db 5                        ; 6->6

    align 8
t_lp_cutoff1dot5_vol6
    db 0                        ; 0->0
    db 2                        ; 0->6
    db 0                        ; 1->0
    db 3                        ; 1->6
    db 1                        ; 2->0
    db 4                        ; 2->6
    db 2                        ; 3->0
    db 5                        ; 3->6
    db 3                        ; 4->0
    db 6                        ; 4->6
    db 4                        ; 5->0
    db 6                        ; 5->6
    db 5                        ; 6->0
    db 6                        ; 6->6

    ;; db 0                        ; 0->0
    ;; db 1                        ; 0->6
    ;; db 0                        ; 1->0
    ;; db 2                        ; 1->6
    ;; db 1                        ; 2->0
    ;; db 5                        ; 2->6
    ;; db 2                        ; 3->0
    ;; db 6                        ; 3->6
    ;; db 3                        ; 4->0
    ;; db 6                        ; 4->6
    ;; db 4                        ; 5->0
    ;; db 6                        ; 5->6
    ;; db 5                        ; 6->0
    ;; db 6                        ; 6->6

    align 16
t_hp_cutoff1_vol2
    HP 1,2

    align 16
t_hp_cutoff1_vol3
    HP 1,3

    align 16
t_hp_cutoff1_vol4
    HP 1,4

    align 16
t_hp_cutoff1_vol5
    HP 1,5

    display "vol 3 end: ",$


    align 256
vol4
    out (c),c                   ;12  c = #fe
    dec iyl                     ; 8*
    jr nz,1F                    ;12*

    dec iyh
    jp z,read_pattern0
1
    ld sp,row_buffer            ;10*
    pop de                      ;10* channel 1 freq
    jr 1F                       ;12* timing
1
    out (c),b                   ;12**64

    add ix,de                   ;15  update ch1 oscillator

    pop de                      ;10  duty<<8 | sweep_speed
    sbc a,a                     ; 4  when osc update overflowed,
    and e                       ; 4
    add a,d                     ; 4  duty_ch1 = duty_ch1 + sweep_speed
    ld (duty_ch1),a             ;13

    add a,ixh                   ; 8  now actually apply duty
    ld a,b                      ; 4
    rla                         ; 4  A = prev_vol_ch1<<1 | channel_state&1

    pop de                      ;10  filter table base ptr
    or e                        ; 4  apply offset
    ld e,a                      ; 4
    ld a,(de)                   ; 7  look up next volume
    ld b,a                      ; 4  store as prev_vol

    ld a,(hl)                   ; 7  timing
    exx                         ; 4

    pop de                      ;10--192  freq  channel 2


    out (c),c                   ;12

    add hl,de                   ;11*
    sbc a,a                     ; 4*
    dec de                      ; 6* timing
    pop de                      ;10* duty/sweep
    and e                       ; 4*
    add a,d                     ; 4*
    ld (duty_ch2),a             ;13*
    out (c),b                   ;12**64

    add a,h                     ; 4
    ld a,b                      ; 4
    rla                         ; 4

    pop de                      ;10  filter tab
    or e                        ; 4
    ld e,a                      ; 4
    ld a,(de)                   ; 7
    ld b,a                      ; 4

    ld a,(noise_enable)         ;13
    and h                       ; 4  cheapo prng, disabled by noise_enable == 0
    rlca                        ; 4
    xor h                       ; 4
    ld h,a                      ; 4

    ld a,b                      ; 4

    exx                         ; 4

    add a,b                     ; 4
    add a,high vol0             ; 7
    ld h,a                      ; 4

    ld a,(hl)                   ; 7  timing
    jr 1F                       ;12  timing
1
    jp (hl)                     ; 4--192



    align 16
t_hp_cutoff1_vol6
    HP 1,6

    align 16
t_hp_cutoff2_vol3
    HP 2,3

    align 16
t_hp_cutoff2_vol4
    HP 2,4

    align 16
t_hp_cutoff2_vol5
    HP 2,5

    align 16
t_hp_cutoff2_vol6
    HP 2,6

    align 16
t_hp_cutoff3_vol4
    HP 3,4

    align 16
t_hp_cutoff3_vol5
    HP 3,5

    align 16
t_hp_cutoff3_vol6
    HP 3,6

    align 16
t_hp_cutoff4_vol5
    HP 4,5

    align 16
t_hp_cutoff4_vol6
    HP 4,6

    align 16
t_hp_cutoff5_vol6
    HP 5,6

    display "vol 4 end: ",$


    align 256
vol5
    out (c),c                   ;12  c = #fe
    dec iyl                     ; 8*
    jr z,.update_clock          ; 7*
.ret
    ld sp,row_buffer            ;10*
    pop de                      ;10* channel 1 freq
    add ix,de                   ;15  update ch1 oscillator
    pop de                      ;10  duty<<8 | sweep_speed
    sbc a,a                     ; 4  when osc update overflowed,
    and e                       ; 4
    out (c),b                   ;12**80

    add a,d                     ; 4  duty_ch1 = duty_ch1 + sweep_speed
    ld (duty_ch1),a             ;13

    add a,ixh                   ; 8  now actually apply duty
    ld a,b                      ; 4
    rla                         ; 4  A = prev_vol_ch1<<1 | channel_state&1

    pop de                      ;10  filter table base ptr
    or e                        ; 4  apply offset
    ld e,a                      ; 4
    ld a,(de)                   ; 7  look up next volume
    ld b,a                      ; 4  store as prev_vol

    exx                         ; 4

    pop de                      ;10  freq  channel 2
    xor a                       ; 4  timing
    ret nz                      ; 5  timing
    add hl,de                   ;11
    sbc a,a                     ; 4--192


    out (c),c                   ;12

    pop de                      ;10* duty/sweep
    and e                       ; 4*
    add a,d                     ; 4*
    ld (duty_ch2),a             ;13*

    add a,h                     ; 4*
    ld a,b                      ; 4*
    rla                         ; 4*

    pop de                      ;10* filter tab
    or e                        ; 4*
    ld e,a                      ; 4*
    ld a,(de)                   ; 7*

    out (c),b                   ;12**80

    ld b,a                      ; 4

    ld a,(noise_enable)         ;13
    and h                       ; 4  cheapo prng, disabled by noise_enable == 0
    rlca                        ; 4
    xor h                       ; 4
    ld h,a                      ; 4

    ld a,b                      ; 4

    exx                         ; 4

    add a,b                     ; 4
    add a,high vol0             ; 7
    ld h,a                      ; 4

    cpi                         ;16  timing
    cpd                         ;16  timing
    inc c                       ; 4  timing
    inc c                       ; 4  timing
    jp (hl)                     ; 4--192

.update_clock
    dec iyh                     ; update clock msb
    jp z,read_pattern0
    jp .ret


    ;; display "vol 5 end: ",$



    align 256
vol6
    out (c),c                   ;12  c = #fe
    dec iyl                     ; 8*
    jr z,.update_clock          ; 7*

.ret
    ld sp,row_buffer            ;10*
    pop de                      ;10* channel 1 freq
    add ix,de                   ;15* update ch1 oscillator
    pop de                      ;10* duty<<8 | sweep_speed
    sbc a,a                     ; 4* when osc update overflowed,
    and e                       ; 4*
    add a,d                     ; 4* duty_ch1 = duty_ch1 + sweep_speed
    jr 1F                       ;12* timing
1
    out (c),b                   ;12**96

    ld (duty_ch1),a             ;13

    add a,ixh                   ; 8  now actually apply duty
    ld a,b                      ; 4
    rla                         ; 4  A = prev_vol_ch1<<1 | channel_state&1

    pop de                      ;10  filter table base ptr
    or e                        ; 4  apply offset
    ld e,a                      ; 4
    ld a,(de)                   ; 7  look up next volume
    ld b,a                      ; 4  store as prev_vol

    exx                         ; 4
    jr 1F                       ;12
1
    pop de                      ;10--192  freq  channel 2


    out (c),c                   ;12

    add hl,de                   ;11*
    sbc a,a                     ; 4*

    pop de                      ;10* duty/sweep
    and e                       ; 4*
    add a,d                     ; 4*
    ld (duty_ch2),a             ;13*

    add a,h                     ; 4*
    ld a,b                      ; 4*
    rla                         ; 4*

    pop de                      ;10* filter tab
    or e                        ; 4*
    ld e,a                      ; 4*

    ds 2                        ; 8*
    out (c),b                   ;12**96

    ld a,(de)                   ; 7
    ld b,a                      ; 4

    ld a,(noise_enable)         ;13
    and h                       ; 4  cheapo prng, disabled by noise_enable == 0
    rlca                        ; 4
    xor h                       ; 4
    ld h,a                      ; 4

    ld a,b                      ; 4

    exx                         ; 4

    add a,b                     ; 4
    add a,high vol0             ; 7
    ld h,a                      ; 4

    dec de                      ; 6  timing
    ld a,(hl)                   ; 7  timing
    nop                         ; 4
    jp (hl)                     ; 4--192


.update_clock
    dec iyh                     ; update clock msb
    jp z,read_pattern0
    jp .ret



    align 256
vol7
    out (c),c                   ;12  c = #fe
    dec iyl                     ; 8*
    jr z,.update_clock          ; 7*

.ret
    ld sp,row_buffer            ;10*
    pop de                      ;10* channel 1 freq
    add ix,de                   ;15* update ch1 oscillator
    pop de                      ;10* duty<<8 | sweep_speed
    sbc a,a                     ; 4* when osc update overflowed,
    and e                       ; 4*
    add a,d                     ; 4* duty_ch1 = duty_ch1 + sweep_speed
    ld (duty_ch1),a             ;13*

    cp (hl)                     ; 7* timing
    add a,ixh                   ; 8* now actually apply duty
    out (c),b                   ;12**112

    ld a,b                      ; 4
    rla                         ; 4  A = prev_vol_ch1<<1 | channel_state&1

    pop de                      ;10  filter table base ptr
    or e                        ; 4  apply offset
    ld e,a                      ; 4
    ld a,(de)                   ; 7  look up next volume
    ld b,a                      ; 4  store as prev_vol

    exx                         ; 4
    inc de                      ; 6  timing
    pop de                      ;10  freq  channel 2
    add hl,de                   ;11--192

    out (c),c                   ;12

    sbc a,a                     ; 4*
    pop de                      ;10* duty/sweep
    and e                       ; 4*
    add a,d                     ; 4*
    ld (duty_ch2),a             ;13*

    add a,h                     ; 4*
    ld a,b                      ; 4*
    rla                         ; 4*

    pop de                      ;10* filter tab
    or e                        ; 4*
    ld e,a                      ; 4*
    ld a,(de)                   ; 7*
    ld a,(de)                   ; 7* timing
    ld b,a                      ; 4*
    ld a,(noise_enable)         ;13
    and h                       ; 4  cheapo prng, disabled by noise_enable == 0
    out (c),b                   ;12**112

    rlca                        ; 4
    xor h                       ; 4
    ld h,a                      ; 4

    ld a,b                      ; 4

    exx                         ; 4

    add a,b                     ; 4
    add a,high vol0             ; 7
    ld h,a                      ; 4

    or (hl)                     ; 7  timing
    inc (hl)                    ;11  timing
    dec (hl)                    ;11  timing
    jp (hl)                     ; 4--192


.update_clock
    dec iyh                     ; update clock msb
    jp z,read_pattern
    jp .ret



    align 256
vol8
    out (c),c                   ;12  c = #fe
    dec iyl                     ; 8*
    jr z,.update_clock          ; 7*

.ret
    ld sp,row_buffer            ;10*
    pop de                      ;10* channel 1 freq
    add ix,de                   ;15* update ch1 oscillator
    pop de                      ;10* duty<<8 | sweep_speed
    sbc a,a                     ; 4* when osc update overflowed,
    and e                       ; 4*
    ret c                       ; 5* timing
    add a,d                     ; 4* duty_ch1 = duty_ch1 + sweep_speed
    ld (duty_ch1),a             ;13*

    add a,ixh                   ; 8* now actually apply duty
    ld a,b                      ; 4*
    rla                         ; 4* A = prev_vol_ch1<<1 | channel_state&1

    pop de                      ;10* filter table base ptr
    out (c),b                   ;12**128

    or e                        ; 4  apply offset
    ld e,a                      ; 4
    ld a,(de)                   ; 7  look up next volume
    ld b,a                      ; 4  store as prev_vol

    exx                         ; 4
    pop de                      ;10  freq  channel 2
    add hl,de                   ;11
    sbc a,a                     ; 4
    nop                         ; 4--192


    out (c),c                   ;12

    pop de                      ;10* duty/sweep
    and e                       ; 4*
    add a,d                     ; 4*
    ld (duty_ch2),a             ;13*

    add a,h                     ; 4*
    ld a,b                      ; 4*
    rla                         ; 4*

    pop de                      ;10* filter tab
    or e                        ; 4*
    ld e,a                      ; 4*
    ld a,(de)                   ; 7*
    ld b,a                      ; 4*

    ld a,(noise_enable)         ;13*
    and h                       ; 4* cheapo prng, disabled by noise_enable == 0
    rlca                        ; 4*
    xor h                       ; 4*
    ld h,a                      ; 4*
    ld a,b                      ; 4*

    exx                         ; 4*

    cp (hl)                     ; 7* timing
    out (c),b                   ;12**128

    add a,b                     ; 4
    add a,high vol0             ; 7
    ld h,a                      ; 4

    inc (hl)                    ;11  timing
    dec (hl)                    ;11  timing
    ld a,(hl)                   ; 7  timing
    nop                         ; 4
    jp (hl)                     ; 4--192

.update_clock
    dec iyh                     ; update clock msb
    jp z,read_pattern
    jp .ret



    align 256
vol9
    out (c),c                   ;12  c = #fe
    dec iyl                     ; 8*
    jr z,.update_clock          ; 7*

.ret
    ld sp,row_buffer            ;10*
    pop de                      ;10* channel 1 freq
    add ix,de                   ;15* update ch1 oscillator
    pop de                      ;10* duty<<8 | sweep_speed
    sbc a,a                     ; 4* when osc update overflowed,
    and e                       ; 4*
    add a,d                     ; 4* duty_ch1 = duty_ch1 + sweep_speed
    ld (duty_ch1),a             ;13*

    add a,ixh                   ; 8* now actually apply duty
    ld a,b                      ; 4*
    rla                         ; 4* A = prev_vol_ch1<<1 | channel_state&1

    inc de                      ; 6  timing
    pop de                      ;10* filter table base ptr
    or e                        ; 4  apply offset
    ld e,a                      ; 4
    ld a,(de)                   ; 7  look up next volume

    out (c),b                   ;12**144

    ld b,a                      ; 4  store as prev_vol

    exx                         ; 4
    pop de                      ;10  freq  channel 2

    ld a,0                      ; 7  timing
    ld a,0                      ; 7  timing
    nop                         ; 4--192 189

    out (c),c                   ;12

    add hl,de                   ;11*
    sbc a,a                     ; 4*
    pop de                      ;10* duty/sweep
    and e                       ; 4*
    add a,d                     ; 4*
    ld (duty_ch2),a             ;13*

    add a,h                     ; 4*
    ld a,b                      ; 4*
    rla                         ; 4*

    pop de                      ;10* filter tab
    or e                        ; 4*
    ld e,a                      ; 4*
    ld a,(de)                   ; 7*
    ld b,a                      ; 4*

    ld a,(noise_enable)         ;13*
    and h                       ; 4* cheapo prng, disabled by noise_enable == 0
    rlca                        ; 4*
    xor h                       ; 4*
    ld h,a                      ; 4*
    ld a,b                      ; 4*

    exx                         ; 4*

    add a,b                     ; 4*
    nop                         ; 4*
    out (c),b                   ;12**144

    add a,high vol0             ; 7
    ld h,a                      ; 4

    ld a,(hl)                   ; 7  timing
    ld a,(hl)                   ; 7  timing
    ld a,(hl)                   ; 7  timing
    jp (hl)                     ; 4--192

.update_clock
    dec iyh                     ; update clock msb
    jp z,read_pattern
    jp .ret



    align 256
vol10
    out (c),c                   ;12  c = #fe
    dec iyl                     ; 8*
    jr z,.update_clock          ; 7*

.ret
    ld sp,row_buffer            ;10*
    pop de                      ;10* channel 1 freq
    add ix,de                   ;15* update ch1 oscillator
    pop de                      ;10* duty<<8 | sweep_speed
    sbc a,a                     ; 4* when osc update overflowed,
    and e                       ; 4*
    add a,d                     ; 4* duty_ch1 = duty_ch1 + sweep_speed
    ld (duty_ch1),a             ;13*

    add a,ixh                   ; 8* now actually apply duty
    ld a,b                      ; 4*
    rla                         ; 4* A = prev_vol_ch1<<1 | channel_state&1

    pop de                      ;10* filter table base ptr
    or e                        ; 4* apply offset
    ld e,a                      ; 4*
    ld a,(de)                   ; 7* look up next volume
    ld b,a                      ; 4* store as prev_vol

    exx                         ; 4*

    pop de                      ;10* freq  channel 2
    nop                         ; 4*
    out (c),b                   ;12**160

    xor a                       ; 4  timing
    ret c                       ; 5  timing
    add hl,de                   ;11--192


    out (c),c                   ;12

    sbc a,a                     ; 4*
    pop de                      ;10* duty/sweep
    and e                       ; 4*
    add a,d                     ; 4*
    ld (duty_ch2),a             ;13*

    add a,h                     ; 4*
    ld a,b                      ; 4*
    rla                         ; 4*

    pop de                      ;10* filter tab
    or e                        ; 4*
    ld e,a                      ; 4*
    ld a,(de)                   ; 7*
    ld b,a                      ; 4*

    ld a,(noise_enable)         ;13*
    and h                       ; 4* cheapo prng, disabled by noise_enable == 0
    rlca                        ; 4*
    xor h                       ; 4*
    ld h,a                      ; 4*
    ld a,b                      ; 4*

    exx                         ; 4*

    add a,b                     ; 4*
    add a,high vol0             ; 7*
    ld h,a                      ; 4*
    ds 5                        ;20*
    out (c),b                   ;12**160

    ds 4                        ;16
    jp (hl)                     ; 4--192

.update_clock
    dec iyh                     ; update clock msb
    jp z,read_pattern
    jp .ret



    align 256
vol11
    out (c),c                   ;12  c = #fe
    dec iyl                     ; 8*
    jr z,.update_clock          ; 7*

.ret
    ld sp,row_buffer            ;10*
    pop de                      ;10* channel 1 freq
    add ix,de                   ;15* update ch1 oscillator
    pop de                      ;10* duty<<8 | sweep_speed
    sbc a,a                     ; 4* when osc update overflowed,
    and e                       ; 4*
    add a,d                     ; 4* duty_ch1 = duty_ch1 + sweep_speed
    ld (duty_ch1),a             ;13*

    add a,ixh                   ; 8* now actually apply duty
    ld a,b                      ; 4*
    rla                         ; 4* A = prev_vol_ch1<<1 | channel_state&1

    pop de                      ;10* filter table base ptr
    or e                        ; 4* apply offset
    ld e,a                      ; 4*
    ld a,(de)                   ; 7* look up next volume
    ld b,a                      ; 4* store as prev_vol

    exx                         ; 4*

    xor a                       ; 4* timing
    ret c                       ; 5* timing

    pop de                      ;10* freq  channel 2
    add hl,de                   ;11*

    out (c),b                   ;12**176

    sbc a,a                     ; 4--192

    out (c),c                   ;12

    pop de                      ;10* duty/sweep
    and e                       ; 4*
    add a,d                     ; 4*
    ld (duty_ch2),a             ;13*

    add a,h                     ; 4*
    ld a,b                      ; 4*
    rla                         ; 4*

    pop de                      ;10* filter tab
    or e                        ; 4*
    ld e,a                      ; 4*
    ld a,(de)                   ; 7*
    ld b,a                      ; 4*

    ld a,(noise_enable)         ;13*
    and h                       ; 4* cheapo prng, disabled by noise_enable == 0
    rlca                        ; 4*
    xor h                       ; 4*
    ld h,a                      ; 4*
    ld a,b                      ; 4*

    exx                         ; 4*

    add a,b                     ; 4*
    add a,high vol0             ; 7*
    ld h,a                      ; 4*
    ds 10                       ;40*
    out (c),b                   ;12**176

    jp (hl)                     ; 4--192


.update_clock
    dec iyh                     ; update clock msb
    jp z,read_pattern
    jp .ret


    align 256
vol12
    out (c),c                   ;12  c = #fe, b = prev_vol_ch1, bit 4 never set!
    jp vol0.from_vol12          ;10


    display "Player size: ",$-init_player

music_data
    include "music.asm"

end
    display "Total size: ",end-init_player
    savetap "main.tap",CODE,"main",init_player,end-init_player
