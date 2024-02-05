;;; PhaserF - Phaser-type ZX Spectrum beeper engine with filters
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

MIX_XOR = #ac00
MIX_AND = #a400
MIX_OR = #b400
MIX_CH2_XOR = #aa
MIX_CH2_AND = #a2
MIX_CH2_OR = #b2

MIX_MODE_CH2 = MIX_CH2_OR

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

    ;; ATTN: don't trash B reg
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

    ld i,a
    jp m,play_drum

.from_drum
    jr nc,.no_ch1_update

    ex af,af'
    pop af                      ; phase reset/flags

    jr nz,1F
    pop hl                      ; freq ch1 osc1
    ld (row_buffer),hl
1
    jr nc,1F
    pop hl                      ; freq ch2 osc2
    ld (row_buffer+2),hl
1
    jp po,1F
    pop hl                      ; mix mode
    ld (row_buffer+4),hl
1
    jp p,1F
    pop hl                      ; filter table ptr
    ld (row_buffer+6),hl
1
    or a
    jr z,1F
    dec a                       ; phase
    ld ixh,a
    ld d,a
    xor a
    ld ixl,a
    ld e,a
1
    ex af,af'

.no_ch1_update
    jp po,.no_ch2_update

    pop af                      ; phase reset/flags

    jr nz,1F
    pop hl                      ; freq ch2 osc1
    ld (row_buffer+8),hl
1
    jr nc,1F
    pop hl                      ; freq ch2 osc2
    ld (row_buffer+10),hl
1
    jp po,1F
    pop hl                      ; duties
    ld (row_buffer+12),hl
1
    jp p,1F
    pop hl                      ; filter table ptr
    ld (row_buffer+14),hl
1
    or a
    jr z,.no_ch2_update
    dec a
    jp z,set_mix_mode_ch2
.set_ch2_phase
    exx
    ld iyh,a                    ; phase
    ld h,a
    xor a
    ld iyl,a
    ld l,a
    exx

.no_ch2_update
    ld (.pattern_ptr),sp

.old_hl = $+1
    ld hl,vol0

    xor a                       ; set clock lsb
    ex af,af'

    jp (hl)


play_drum
    ld (render_drum.old_ix),ix
    ld (render_drum.old_de),de
    ex af,af'
    ld a,b
    ld (render_drum.old_b),a
    pop de                      ; drum length (16-bit)
    ld h,d                      ; drum plays 3x faster than main
    ld l,e
    add hl,hl
    add hl,de
    xor a                       ; adjust remaining row length
    sub e
    ld (render_drum.len_lsb),a
    or a
    jr z,1F
    inc d
1
    ld a,i
    sub d
    ld i,a
    ex de,hl
    ld ixl,e
    ld ixh,d

    pop hl                      ; drum ptr
    ld c,(hl)
    inc hl
    pop de                      ; pitch mask<<8|vol? - vol mask leaves every even bit empty for +3 compat
    ld a,e
    jp render_drum


    display "drum end ", $


    ;; one render core for each volume level
    ;; TODO 2x filter resolution by doing half-steps through only filtering one flank?
    align 256
vol0
    out (c),b                   ;12  c = #fe, b = prev_vol_ch1, bit 4 never set!
    jp .from_vol12              ;10  this delay is needed so vol12 can jump here
.from_vol12
    ex af,af'                   ; 4
    dec a                       ; 4
    jr z,.update_clock          ; 7

    ex af,af'                   ; 4
.ret
    ld sp,row_buffer            ;10

    ex de,hl                    ; 4

    pop de                      ;10
    add hl,de                   ;11  update ch1 osc1
    pop de                      ;10
    add ix,de                   ;15  update ch1 osc2

    pop af                      ;10
    ld (.mix_mode1),a           ;13

    ld a,h                      ; 4  mix osc outputs
.mix_mode1 = $+1
    xor ixh                     ; 8
    rla                         ; 4  move bit 7 into carry
    ld a,b                      ; 4
    rla                         ; 4  lookup prev_vol * 2 | (channel_state & 1)

    pop de                      ;10  filter table base ptr
    or e                        ; 4  apply offset
    ld e,a                      ; 4
    ld a,(de)                   ; 7  look up next volume
    ld b,a                      ; 4  store as prev_vol

    ex de,hl                    ; 4

    exx                         ; 4  channel 2: squeeker

    pop de                      ;10
    add hl,de                   ;11
    pop de                      ;10
    add iy,de                   ;15

    pop de                      ;10  duties
    ld a,h                      ; 4
    add a,d                     ; 4
    sbc a,a                     ; 4
    ld d,a                      ; 4
    ld a,iyh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4
.mix_mode2
    db MIX_MODE_CH2             ; 4  or/xor/and d
    rla                         ; 4
    ld a,b                      ; 4  calculate lookup as above
    rla                         ; 4
    pop de                      ;10  filter tab
    or e                        ; 4
    ld e,a                      ; 4
    ld a,(de)                   ; 7
    ld b,a                      ; 4
    exx                         ; 4

    add a,b                     ; 4
    add a,high vol0             ; 7
    ld h,a                      ; 4
    ld l,0                      ; 7  reset jump ptr lsb!

    inc (hl)                    ;11  timing
    dec (hl)                    ;11  timing
    ld a,(hl)                   ; 7  timing
    ld a,(hl)                   ; 7  timing
    jp (hl)                     ; 4--384

.update_clock
    ex af,af'
    ld a,i
    dec a
    jp z,read_pattern
    ld i,a
    jp .ret



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

    align 16
t_lp_cutoff1_vol2
    LP 1,2

    align 16
t_lp_cutoff1_vol3
    LP 1,3

    align 16
t_lp_cutoff1_vol4
    LP 1,4

    align 16
t_lp_cutoff1_vol5
    LP 1,5

    display "vol 0 end: ",$


    align 256
vol1
    out (c),c                   ;12  c = #fe, b = prev_vol_ch1, bit 4 never set!
    ex af,af'                   ; 4*
    out (c),b                   ;12**16
    dec a                       ; 4
    jr z,.update_clock          ; 7

    ex af,af'                   ; 4
.ret
    ld sp,row_buffer            ;10
    ex de,hl                    ; 4

    pop de                      ;10
    add hl,de                   ;11  update ch1 osc1
    pop de                      ;10
    add ix,de                   ;15  update ch1 osc2

    pop af                      ;10
    ld (.mix_mode1),a           ;13

    ld a,h                      ; 4  mix osc outputs
.mix_mode1 = $+1
    xor ixh                     ; 8
    rla                         ; 4  move bit 7 into carry
    ld a,b                      ; 4  lookup prev_vol * 2 | (channel_state & 1)
    rla                         ; 4

    pop de                      ;10  filter table base ptr
    or e                        ; 4  apply offset
    ld e,a                      ; 4
    ld a,(de)                   ; 7  look up next volume
    ld b,a                      ; 4  store as prev_vol
    xor a                       ; 4  timing
    ret c                       ; 5  timing
    ex de,hl                    ; 4--192


    out (c),c                   ;12
    exx                         ; 4  channel 2: squeeker
    out (c),b                   ;12

    pop de                      ;10
    add hl,de                   ;11
    pop de                      ;10
    add iy,de                   ;15

    pop de                      ;10  duties
    ld a,h                      ; 4
    add a,d                     ; 4
    sbc a,a                     ; 4
    ld d,a                      ; 4
    ld a,iyh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4
.mix_mode2
    db MIX_MODE_CH2             ; 4
    rla                         ; 4
    ld a,b                      ; 4 calculate lookup as above
    rla                         ; 4

    pop de                      ;10  filter tab
    or e                        ; 4
    ld e,a                      ; 4
    ld a,(de)                   ; 7
    ld b,a                      ; 4

    exx                         ; 4

    add a,b                     ; 4
    add a,high vol0             ; 7
    ld h,a                      ; 4
    xor a                       ; 4
    ld l,a                      ; 4

    jp (hl)                     ; 4--192

.update_clock
    ex af,af'
    ld a,i
    dec a
    jp z,read_pattern
    ld i,a
    jp .ret


row_buffer
    ds 16


    align 16
t_lp_cutoff1_vol6
    LP 1,6

    align 8
t_lp_cutoff2_vol2
    LP 2,2

    align 8
t_lp_cutoff2_vol3
    LP 2,3

    align 8
t_lp_cutoff2_vol4
    LP 2,4

    align 8
t_lp_cutoff2_vol5
    LP 2,5

    align 8
t_lp_cutoff2_vol6
    LP 2,6

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
    out (c),c                   ;12  c = #fe, b = prev_vol_ch1, bit 4 never set!
    ex af,af'                   ; 4*
    dec a                       ; 4*
    jr nz,1F                    ;12*

    ex af,af'
    ld a,i
    dec a
    jp z,read_pattern0
    ld i,a
    out (c),b
    jp 2F
1
    out (c),b                   ;12**32

    ex af,af'                   ; 4
2
    ld sp,row_buffer            ;10
    ex de,hl                    ; 4

    pop de                      ;10
    add hl,de                   ;11  update ch1 osc1
    pop de                      ;10
    add ix,de                   ;15  update ch1 osc2

    pop af                      ;10
    ld (.mix_mode1),a           ;13

    ld a,h                      ; 4  mix osc outputs
.mix_mode1 = $+1
    xor ixh                     ; 8
    rla                         ; 4  move bit 7 into carry
    ld a,b                      ; 4  lookup prev_vol * 2 | (channel_state & 1)
    rla                         ; 4

    pop de                      ;10  filter table base ptr
    or e                        ; 4  apply offset
    ld e,a                      ; 4
    ld a,(de)                   ; 7  look up next volume
    ld b,a                      ; 4  store as prev_vol

    ex de,hl                    ; 4
    exx                         ; 4--192   channel 2: squeeker


    out (c),c                   ;12
    pop de                      ;10*
    add hl,de                   ;11*
    out (#fe),a                 ;11**32 A is still <8 here

    pop de                      ;10
    add iy,de                   ;15

    pop de                      ;10  duties
    ld a,h                      ; 4
    add a,d                     ; 4
    sbc a,a                     ; 4
    ld d,a                      ; 4
    ld a,iyh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4
.mix_mode2
    db MIX_MODE_CH2             ; 4
    rla                         ; 4
    ld a,b                      ; 4 calculate lookup as above
    rla                         ; 4

    inc de                      ; 6  timing
    pop de                      ;10  filter tab
    or e                        ; 4
    ld e,a                      ; 4
    ld a,(de)                   ; 7
    ld b,a                      ; 4

    exx                         ; 4

    add a,b                     ; 4
    add a,high vol0             ; 7
    ld h,a                      ; 4
    ld l,0                      ; 7

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

    align 16
t_lp_cutoff3_vol6
    LP 3,6

    align 16
t_lp_cutoff4_vol2
    LP 4,2

    align 16
t_lp_cutoff4_vol3
    LP 4,3

    align 16
t_lp_cutoff4_vol4
    LP 4,4

    align 16
t_lp_cutoff4_vol5
    LP 4,5

    align 16
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
    out (c),c                   ;12  c = #fe, b = prev_vol_ch1, bit 4 never set!
    ex af,af'                   ; 4*
    dec a                       ; 4*
    jr z,.update_clock          ; 7*

    ex af,af'                   ; 4
.ret
    ld sp,row_buffer            ;10
    ex de,hl                    ; 4
    xor a                       ; 4
    out (#fe),a                 ;11**48

    pop de                      ;10
    add hl,de                   ;11  update ch1 osc1
    pop de                      ;10
    add ix,de                   ;15  update ch1 osc2

    pop af                      ;10
    ld (.mix_mode1),a           ;13

    ld a,h                      ; 4  mix osc outputs
.mix_mode1 = $+1
    xor ixh                     ; 8
    rla                         ; 4  move bit 7 into carry
    ld a,b                      ; 4  lookup prev_vol * 2 | (channel_state & 1)
    rla                         ; 4

    pop de                      ;10  filter table base ptr
    or e                        ; 4  apply offset
    ld e,a                      ; 4
    ex de,hl                    ; 4
    ld b,(hl)                   ; 7  look up next volume
    exx                         ; 4  channel 2: squeeker
    dec de                      ; 6--192  timing


    out (c),c                   ;12
    ret c                       ; 5* timing
    pop de                      ;10*
    add hl,de                   ;11*
    pop de                      ;10*
    out (c),b                   ;12**48

    add iy,de                   ;15

    pop de                      ;10  duties
    ld a,h                      ; 4
    add a,d                     ; 4
    sbc a,a                     ; 4
    ld d,a                      ; 4
    ld a,iyh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4
.mix_mode2
    db MIX_MODE_CH2             ; 4
    rla                         ; 4
    ld a,b                      ; 4 calculate lookup as above
    rla                         ; 4

    pop de                      ;10  filter tab
    or e                        ; 4
    ld e,a                      ; 4
    ld a,(de)                   ; 7
    ld b,a                      ; 4

    exx                         ; 4

    add a,b                     ; 4
    add a,high vol0             ; 7
    ld h,a                      ; 4
    ld l,0                      ; 7  reset jump ptr lsb!
    jp (hl)                     ; 4--192

.update_clock
    ex af,af'
    ld a,i
    dec a
    jp z,read_pattern0
    ld i,a
    jp .ret

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

    align 16
t_hp_cutoff1_vol2
    HP 1,2

    align 16
t_hp_cutoff1_vol3
    HP 1,3

    align 16
t_hp_cutoff1_vol4
    HP 1,4

    display "vol 3 end: ",$



    align 256
vol4
    out (c),c                   ;12  c = #fe, b = prev_vol_ch1, bit 4 never set!
    ld sp,row_buffer            ;10*
    ex de,hl                    ; 4*
    pop de                      ;10*
    add hl,de                   ;11* update ch1 osc1
    pop de                      ;10*
    ld a,0                      ; 7* timing
    out (c),b                   ;12**64

    add ix,de                   ;15  update ch1 osc2

    pop af                      ;10
    ld (.mix_mode1),a           ;13

    ld a,h                      ; 4  mix osc outputs
.mix_mode1 = $+1
    xor ixh                     ; 8
    rla                         ; 4  move bit 7 into carry
    ld a,b                      ; 4  lookup prev_vol * 2 | (channel_state & 1)
    rla                         ; 4

    pop de                      ;10  filter table base ptr
    or e                        ; 4  apply offset
    ld e,a                      ; 4
    ex de,hl                    ; 4
    ld b,(hl)                   ; 7  look up next volume
    exx                         ; 4
    pop de                      ;10
    add hl,de                   ;11--192  channel 2: squeeker


    out (c),c                   ;12
    pop de                      ;10*
    add iy,de                   ;15*

    ex af,af'                   ; 4*
    dec a                       ; 4*
    jr z,.update_clock          ; 7*

    ex af,af'                   ; 4*
.ret
    ld a,iyh                    ; 8*
    out (c),b                   ;12**64

    pop de                      ;10  duties
    add a,e                     ; 4
    sbc a,a                     ; 4
    ld e,a                      ; 4
    ld a,h                      ; 4
    add a,d                     ; 4
    sbc a,a                     ; 4
.mix_mode2
    or e                        ; 4
    rla                         ; 4
    ld a,b                      ; 4  calculate lookup as above
    rla                         ; 4

    pop de                      ;10  filter tab
    or e                        ; 4
    ld e,a                      ; 4
    ld a,(de)                   ; 7
    ld b,a                      ; 4

    exx                         ; 4

    add a,b                     ; 4
    add a,high vol0             ; 7
    ld h,a                      ; 4
    ld l,0                      ; 7  reset jump ptr lsb!
    ld a,(hl)                   ; 7  timing
    jp (hl)                     ; 4--192

.update_clock
    ex af,af'
    ld a,i
    dec a
    exx
    ld hl,vol4
    jp z,read_pattern0
    exx
    ld i,a
    jp .ret


    align 16
t_hp_cutoff1_vol5
    HP 1,5

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

    display "vol 4 end: ",$


    align 256
vol5
    out (c),c                   ;12  c = #fe, b = prev_vol_ch1, bit 4 never set!
    ex af,af'                   ; 4*
    dec a                       ; 4*
    jr z,.update_clock          ; 7*

    ex af,af'                   ; 4*
.ret
    ld sp,row_buffer            ;10*
    ex de,hl                    ; 4*
    pop de                      ;10*
    add hl,de                   ;11* update ch1 osc1
    pop de                      ;10*
    nop                         ; 4*
    out (c),b                   ;12**80

    add ix,de                   ;15  update ch1 osc2

    pop af                      ;10
    ld (.mix_mode1),a           ;13

    ld a,h                      ; 4  mix osc outputs
.mix_mode1 = $+1
    xor ixh                     ; 8
    rla                         ; 4  move bit 7 into carry
    ld a,b                      ; 4  lookup prev_vol * 2 | (channel_state & 1)
    rla                         ; 4

    pop de                      ;10  filter table base ptr
    or e                        ; 4  apply offset
    ret c                       ; 5  timing
    ld e,a                      ; 4
    ld a,(de)                   ; 7  look up next volume
    ld b,a                      ; 4  store as prev_vol
    ex de,hl                    ; 4--192


    out (c),c                   ;12

    exx                         ; 4* channel 2: squeeker

    pop de                      ;10*
    add hl,de                   ;11*
    pop de                      ;10*
    add iy,de                   ;15*

    pop de                      ;10* duties
    ld a,h                      ; 4*
    add a,d                     ; 4*

    out (c),b                   ;12**80

    sbc a,a                     ; 4
    ld d,a                      ; 4
    ld a,iyh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4
.mix_mode2
    db MIX_MODE_CH2             ; 4
    rla                         ; 4
    ld a,b                      ; 4 calculate lookup as above
    rla                         ; 4

    pop de                      ;10  filter tab
    or e                        ; 4
    ld e,a                      ; 4
    ld a,(de)                   ; 7
    ld b,a                      ; 4

    exx                         ; 4

    add a,b                     ; 4
    add a,high vol0             ; 7
    ld h,a                      ; 4

    xor a                       ; 4
    ld l,a                      ; 4  reset jump ptr lsb!
    jp (hl)                     ; 4--192

.update_clock
    ex af,af'
    ld a,i
    dec a
    jp z,read_pattern0
    ld i,a
    jp .ret


    align 16
t_hp_cutoff4_vol6
    HP 4,6

    align 16
t_hp_cutoff5_vol6
    HP 5,6

    display "vol 5 end: ",$



    align 256
vol6
    out (c),c                   ;12  c = #fe, b = prev_vol_ch1, bit 4 never set!
    ex af,af'                   ; 4*
    dec a                       ; 4*
    jr z,.update_clock          ; 7*
    ret z                       ; 5* timing
    ex af,af'                   ; 4*
.ret
    ld sp,row_buffer            ;10*
    ex de,hl                    ; 4*
    pop de                      ;10*
    add hl,de                   ;11* update ch1 osc1
    pop de                      ;10*
    add ix,de                   ;15  update ch1 osc2
    out (c),b                   ;12**96

    pop af                      ;10
    ld (.mix_mode1),a           ;13

    ld a,h                      ; 4  mix osc outputs
.mix_mode1 = $+1
    xor ixh                     ; 8
    rla                         ; 4  move bit 7 into carry
    ld a,b                      ; 4  lookup prev_vol * 2 | (channel_state & 1)
    rla                         ; 4

    pop de                      ;10  filter table base ptr
    or e                        ; 4  apply offset
    ld e,a                      ; 4
    ld a,(de)                   ; 7  look up next volume
    ld b,a                      ; 4  store as prev_vol
    ex de,hl                    ; 4
    exx                         ; 4--192 channel 2: squeeker

    out (c),c                   ;12

    pop de                      ;10*
    add hl,de                   ;11*
    pop de                      ;10*
    add iy,de                   ;15*

    pop de                      ;10* duties
    ld a,h                      ; 4*
    add a,d                     ; 4*
    sbc a,a                     ; 4*
    ld d,a                      ; 4*
    ld a,iyh                    ; 8*
    add a,e                     ; 4*
    out (c),b                   ;12**96

    sbc a,a                     ; 4
.mix_mode2
    db MIX_MODE_CH2             ; 4
    rla                         ; 4
    ld a,b                      ; 4 calculate lookup as above
    rla                         ; 4

    pop de                      ;10  filter tab
    or e                        ; 4
    ret c                       ; 5  timing
    ld e,a                      ; 4
    ld a,(de)                   ; 7
    ld b,a                      ; 4

    exx                         ; 4

    add a,b                     ; 4
    add a,high vol0             ; 7
    ld h,a                      ; 4
    ld l,0                      ; 7  reset jump ptr lsb!

    jp (hl)                     ; 4--192

.update_clock
    ex af,af'
    ld a,i
    dec a
    jp z,read_pattern0
    ld i,a
    jp .ret


    align 256
vol7
    out (c),c                   ;12  c = #fe, b = prev_vol_ch1, bit 4 never set!
    ex af,af'                   ; 4*
    dec a                       ; 4*
    jr z,.update_clock          ; 7*

    ex af,af'                   ; 4*
.ret
    ld sp,row_buffer            ;10*
    ex de,hl                    ; 4*
    pop de                      ;10*
    add hl,de                   ;11* update ch1 osc1
    pop de                      ;10*
    pop af                      ;10*
    ld (.mix_mode1),a           ;13*
    or a                        ; 4* timing
    ret c                       ; 5* timing
    ld a,h                      ; 4* mix osc outputs
    out (c),b                   ;12**112

    add ix,de                   ;15  update ch1 osc2
.mix_mode1 = $+1
    xor ixh                     ; 8
    rla                         ; 4  move bit 7 into carry
    ld a,b                      ; 4  lookup prev_vol * 2 | (channel_state & 1)
    rla                         ; 4

    pop de                      ;10  filter table base ptr
    or e                        ; 4  apply offset
    ld e,a                      ; 4
    ld a,(de)                   ; 7  look up next volume
    ld b,a                      ; 4  store as prev_vol
    ex de,hl                    ; 4--192

    out (c),c                   ;12

    exx                         ; 4  channel 2: squeeker

    pop de                      ;10*
    add hl,de                   ;11*
    pop de                      ;10*
    add iy,de                   ;15*

    pop de                      ;10* duties
    ld a,h                      ; 4*
    add a,d                     ; 4*
    sbc a,a                     ; 4*
    ld d,a                      ; 4*
    ld a,iyh                    ; 8*
    add a,e                     ; 4*
    sbc a,a                     ; 4*
.mix_mode2
    db MIX_MODE_CH2             ; 4*
    rla                         ; 4*
    out (c),b                   ;12**112

    ld a,b                      ; 4 calculate lookup as above
    rla                         ; 4

    pop de                      ;10  filter tab
    or e                        ; 4
    ld e,a                      ; 4
    ld a,(de)                   ; 7
    ld b,a                      ; 4

    exx                         ; 4

    add a,b                     ; 4
    add a,high vol0             ; 7
    ld h,a                      ; 4
    xor a                       ; 4
    ld l,a                      ; 4  reset jump ptr lsb!

    jp (hl)                     ; 4--192

.update_clock
    ex af,af'
    ld a,i
    dec a
    jp z,read_pattern
    ld i,a
    jp .ret



    align 256
vol8
    out (c),c                   ;12  c = #fe, b = prev_vol_ch1, bit 4 never set!
    ex af,af'                   ; 4*
    dec a                       ; 4*
    jr z,.update_clock          ; 7*

    ex af,af'                   ; 4*
.ret
    ld sp,row_buffer            ;10*
    ex de,hl                    ; 4*
    pop de                      ;10*
    add hl,de                   ;11* update ch1 osc1
    pop de                      ;10*
    add ix,de                   ;15* update ch1 osc2
    pop af                      ;10*
    ld (.mix_mode1),a           ;13*
    ld a,h                      ; 4* mix osc outputs
    inc de                      ; 6* timing
    nop                         ; 4*
    out (c),b                   ;12**128

.mix_mode1 = $+1
    xor ixh                     ; 8
    rla                         ; 4  move bit 7 into carry
    ld a,b                      ; 4  lookup prev_vol * 2 | (channel_state & 1)
    rla                         ; 4

    pop de                      ;10  filter table base ptr
    or e                        ; 4  apply offset
    ld e,a                      ; 4
    ld a,(de)                   ; 7  look up next volume
    ld e,0                      ; 7--192  reset jump ptr lsb!


    out (c),c                   ;12

    ld b,a                      ; 4* store as prev_vol
    ex de,hl                    ; 4*
    exx                         ; 4* channel 2: squeeker

    pop de                      ;10*
    add hl,de                   ;11*
    pop de                      ;10*
    add iy,de                   ;15*

    pop de                      ;10* duties
    ld a,h                      ; 4*
    add a,d                     ; 4*
    sbc a,a                     ; 4*
    ld d,a                      ; 4*
    ld a,iyh                    ; 8*
    add a,e                     ; 4*
    sbc a,a                     ; 4*
.mix_mode2
    db MIX_MODE_CH2             ; 4*
    rla                         ; 4*
    ld a,b                      ; 4* calculate lookup as above
    rla                         ; 4*
    out (c),b                   ;12**128

    pop de                      ;10  filter tab
    or e                        ; 4
    ld e,a                      ; 4
    ld a,(de)                   ; 7
    ld b,a                      ; 4

    exx                         ; 4

    add a,b                     ; 4
    add a,high vol0             ; 7
    ld h,a                      ; 4

    jp (hl)                     ; 4--192

.update_clock
    ex af,af'
    ld a,i
    dec a
    jp z,read_pattern
    ld i,a
    jp .ret



    align 256
vol9
    out (c),c                   ;12  c = #fe, b = prev_vol_ch1, bit 4 never set!
    ex af,af'                   ; 4*
    dec a                       ; 4*
    jr z,.update_clock          ; 7*

    ex af,af'                   ; 4*
.ret
    ld sp,row_buffer            ;10*
    ex de,hl                    ; 4*
    pop de                      ;10*
    add hl,de                   ;11* update ch1 osc1
    pop de                      ;10*
    add ix,de                   ;15* update ch1 osc2
    pop af                      ;10*
    ld (.mix_mode1),a           ;13*
    ld a,h                      ; 4* mix osc outputs
.mix_mode1 = $+1
    xor ixh                     ; 8*
    rla                         ; 4* move bit 7 into carry
    ld a,b                      ; 4*
    pop de                      ;10* filter table base ptr
    out (c),b                   ;12**144

    rla                         ; 4  lookup prev_vol * 2 | (channel_state & 1)
    or e                        ; 4  apply offset
    ret c                       ; 5  timing
    ld e,a                      ; 4
    ld a,(de)                   ; 7  look up next volume
    ld b,a                      ; 4  store as prev_vol
    ex de,hl                    ; 4
    exx                         ; 4--192  channel 2: squeeker

    out (c),c                   ;12

    pop de                      ;10*
    add hl,de                   ;11*
    pop de                      ;10*
    add iy,de                   ;15*

    pop de                      ;10* duties
    ld a,h                      ; 4*
    add a,d                     ; 4*
    sbc a,a                     ; 4*
    ld d,a                      ; 4*
    ld a,iyh                    ; 8*
    add a,e                     ; 4*
    sbc a,a                     ; 4*
.mix_mode2
    db MIX_MODE_CH2             ; 4*
    rla                         ; 4*
    ld a,b                      ; 4* calculate lookup as above
    rla                         ; 4*
    pop de                      ;10* filter tab
    or e                        ; 4*
    ld e,a                      ; 4*
    ld a,(de)                   ; 7*
    ld b,a                      ; 4*
    out (#fe),a                 ;11**144

    inc de                      ; 6  timing
    exx                         ; 4

    add a,b                     ; 4
    add a,high vol0             ; 7
    ld h,a                      ; 4
    ld l,0                      ; 7  reset jump ptr lsb!

    jp (hl)                     ; 4--192

.update_clock
    ex af,af'
    ld a,i
    dec a
    jp z,read_pattern
    ld i,a
    jp .ret



    align 256
vol10
    out (c),c                   ;12  c = #fe, b = prev_vol_ch1, bit 4 never set!
    ex af,af'                   ; 4*
    dec a                       ; 4*
    jr z,.update_clock          ; 7*

    ex af,af'                   ; 4*
.ret
    ld sp,row_buffer            ;10*
    ex de,hl                    ; 4*
    pop de                      ;10*
    add hl,de                   ;11* update ch1 osc1
    pop de                      ;10*
    add ix,de                   ;15* update ch1 osc2
    pop af                      ;10*
    ld (.mix_mode1),a           ;13*
    ld a,h                      ; 4* mix osc outputs
.mix_mode1 = $+1
    xor ixh                     ; 8*
    rla                         ; 4* move bit 7 into carry
    ld a,b                      ; 4*
    rla                         ; 4* lookup prev_vol * 2 | (channel_state & 1)
    pop de                      ;10* filter table base ptr
    or e                        ; 4* apply offset
    ld e,a                      ; 4*
    ex de,hl                    ; 4*
    out (c),b                   ;12**160

    ret c                       ; 5  timing
    ld a,(hl)                   ; 7  look up next volume
    ld b,a                      ; 4  store as prev_vol

    exx                         ; 4-192 channel 2: squeeker

    out (c),c                   ;12

    pop de                      ;10*
    add hl,de                   ;11*
    pop de                      ;10*
    add iy,de                   ;15*

    pop de                      ;10* duties
    ld a,h                      ; 4*
    add a,d                     ; 4*
    sbc a,a                     ; 4*
    ld d,a                      ; 4*
    ld a,iyh                    ; 8*
    add a,e                     ; 4*
    sbc a,a                     ; 4*
.mix_mode2
    db MIX_MODE_CH2             ; 4*
    rla                         ; 4*
    ld a,b                      ; 4* calculate lookup as above
    rla                         ; 4*
    pop de                      ;10* filter tab
    or e                        ; 4*
    ld e,a                      ; 4*
    ld a,(de)                   ; 7*
    ld b,a                      ; 4*
    exx                         ; 4*

    add a,b                     ; 4*
    add a,high vol0             ; 7*
    out (c),b                   ;12**160

    ld h,a                      ; 4
    ld l,0                      ; 7  reset jump ptr lsb!
    ret c                       ; 5  timing

    jp (hl)                     ; 4--192

.update_clock
    ex af,af'
    ld a,i
    dec a
    jp z,read_pattern
    ld i,a
    jp .ret



    align 256
vol11
    out (c),c                   ;12  c = #fe, b = prev_vol_ch1, bit 4 never set!
    ex af,af'                   ; 4*
    dec a                       ; 4*
    jr z,.update_clock          ; 7*

    ex af,af'                   ; 4*
.ret
    ld sp,row_buffer            ;10*
    ex de,hl                    ; 4*
    pop de                      ;10*
    add hl,de                   ;11* update ch1 osc1
    pop de                      ;10*
    add ix,de                   ;15* update ch1 osc2
    pop af                      ;10*
    ld (.mix_mode1),a           ;13*
    ld a,h                      ; 4* mix osc outputs
.mix_mode1 = $+1
    xor ixh                     ; 8*
    rla                         ; 4* move bit 7 into carry
    ld a,b                      ; 4*
    rla                         ; 4* lookup prev_vol * 2 | (channel_state & 1)
    pop de                      ;10* filter table base ptr
    or e                        ; 4* apply offset
    ld e,a                      ; 4*
    ret c                       ; 5* timing
    ld a,(de)                   ; 7* look up next volume
    ld b,a                      ; 4* store as prev_vol
    ex de,hl                    ; 4
    out (c),b                   ;12**176

    exx                         ; 4--192  channel 2: squeeker

    out (c),c                   ;12

    pop de                      ;10*
    add hl,de                   ;11*
    pop de                      ;10*
    add iy,de                   ;15*

    pop de                      ;10* duties
    ld a,h                      ; 4*
    add a,d                     ; 4*
    sbc a,a                     ; 4*
    ld d,a                      ; 4*
    ld a,iyh                    ; 8*
    add a,e                     ; 4*
    sbc a,a                     ; 4*
.mix_mode2
    db MIX_MODE_CH2             ; 4*
    rla                         ; 4*
    ld a,b                      ; 4* calculate lookup as above
    rla                         ; 4*
    pop de                      ;10* filter tab
    or e                        ; 4*
    ld e,a                      ; 4*
    ld a,(de)                   ; 7*
    ld b,a                      ; 4*
    exx                         ; 4*

    add a,b                     ; 4*
    add a,high vol0             ; 7*
    ld h,a                      ; 4*
    ld l,0                      ; 7* reset jump ptr lsb!
    ret c                       ; 5* timing
    out (c),b                   ;12**176

    jp (hl)                     ; 4--192

.update_clock
    ex af,af'
    ld a,i
    dec a
    jp z,read_pattern
    ld i,a
    jp .ret


render_drum
    out (#fe),a                 ;11--48

    rrc d                       ; 8  apply pitch mask
    jp nc,.wait0                ;10

    dec c                       ; 4  update pwm length counter
    jr nz,.wait1                ; 7*

    ld a,(hl)                   ; 7* load next pwm sample
    or a                        ; 4*
    jr z,.wait2                 ; 7' if 0, end of sample reached

    inc hl                      ; 6' point to following pwm sample
    ld c,a                      ; 4'
    ld a,b                      ; 4' flip phase
    xor e                       ; 4'
    ld b,a                      ; 4''29

.stop
    out (#fe),a                 ;11**80
    or 0                        ; 7  timing
    nop                         ; 4
    rrca                        ; 4
    rrca                        ; 4
    dec ixl                     ; 8
    jp nz,render_drum           ;10--128
.ret
    dec ixh
    jp nz,render_drum

.drum_end
.old_de = $+1
    ld de,0
.old_ix = $+2
    ld ix,0
.old_b = $+2
    ld bc,#00fe
.len_lsb = $+1
    ld a,0
    ex af,af'
    jp read_pattern.from_drum

.wait0                          ;
    cp (hl)                     ; 7
    cp (hl)                     ; 7
    ds 2                        ; 8
    jr .wait2                   ;12
.wait1                          ;(12)
    ds 2                        ; 8
    jp .wait2                   ;10
.wait2                          ;(12)
    ld (0),a                    ;13  timing
    ld a,b                      ; 4  restore volume/phase
    out (#fe),a                 ;11**80
    or 0                        ; 7  timing
    nop                         ; 4
    rrca                        ; 4
    rrca                        ; 4
    dec ixl                     ; 8
    jp nz,render_drum           ;10--128
    jp .ret

set_mix_mode_ch2
    pop hl
    ld a,l
    ld (vol0.mix_mode2),a
    ld (vol1.mix_mode2),a
    ld (vol2.mix_mode2),a
    ld (vol3.mix_mode2),a
    ld (vol5.mix_mode2),a
    ld (vol6.mix_mode2),a
    ld (vol7.mix_mode2),a
    ld (vol8.mix_mode2),a
    ld (vol9.mix_mode2),a
    ld (vol10.mix_mode2),a
    ld (vol11.mix_mode2),a
    inc a
    ld (vol4.mix_mode2),a       ; volume 4 uses x/or/and e instead of d
    ld a,h                      ; phase
    jp read_pattern.set_ch2_phase

    display "vol11 end: ", $

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
