; STRINGKS ZX Spectrum beeper engine
; by utz 11'2018 * www.irrlichtproject.de

; vim: filetype=z80:

; register usage:
; HL    ringbuf ptr A
; D     freq counter A
; E     temp hold output value
; B     #f0 - mask
; C     #fe - port
; HL'   ringbuf ptr B (or H' = pwm volume, L' = pwm counter)
; D'    freq counter B (or DE' = pwm sample pointer)
; IX    pointer to current core B
; IY    pointer to current core A
; BC'   timer (B' = timer lo, C' = timer hi)


    org #8000

init_player
    di
    ld b,#f0                        ; used to mask lower nibble in outval
    ld c,#fe                        ; port #fe
    exx                             ; -> regset 2
    push hl
    push iy
    ld b,0
    ld (old_sp),sp
    ld hl,music_data
    ld (seq_ptr),hl

;******************************************************************************
read_sequence
seq_ptr equ $+1
    ld sp,0
_read_loop
    pop hl
    ld a,h
    or l
    ;jr z,exit_player               ; uncomment to disable looping
    jr nz,_done
    pop hl
    ld sp,hl
    jr _read_loop
_done
    ld (seq_ptr),sp
    ld sp,hl
    ld a,#1f                        ; disable overdrive
    ld (overdrive_toggle),a
    ld (overdrive_toggle_pwm),a
    jp read_pattern0

exit_player
old_sp equ $+1
    ld sp,0
    pop iy
    pop hl
    exx
    ei
    ret

;******************************************************************************
read_pattern
    in a,(#fe)
    cpl
    and #1f
    jr nz,exit_player
ptn_ptr equ $+1
    ld sp,0
read_pattern0
    pop af
    jr z,read_sequence              ; z = pattern end
    ld c,a                          ; set timer hi
    jp po,_no_overdrive_toggle
    ex af,af'                       ; toggle overdrive on/off
    ld a,(overdrive_toggle)
    xor #1f
    ld (overdrive_toggle),a
    ld (overdrive_toggle_pwm),a
    ex af,af'
_no_overdrive_toggle
    ret nc                          ; load actual channel B data unless ctrl
                                    ; byte has bit 0 set

chB_update_done
    ld h,HIGH(ringbufB)
    exx                             ; -> regset 1
    ret p                           ; load actual channel A data unless ctrl
                                    ; byte has bit 7 set

chA_update_done
    ld h,HIGH(ringbufA)
    xor a
    ld (ptn_ptr),sp
    jp (iy)

chA_mute
    ld iy,coreA_mute
    jp chA_update_done

chB_mute
    ld ix,coreB_mute
    jp chB_update_done

chA_ks_noise
    ld iy,coreA_make_rom_transient
    pop af
    ld (transientA_rom_vol),a
    pop hl
    ld d,l
    ld a,h
    ld (transientA_src_page),a
    jp chA_update_done

chB_ks_noise
    ld ix,coreB_make_rom_transient
    pop hl
    ld a,h
    ld (transientB_rom_vol),a
    pop hl
    ld d,l
    ld a,h
    ld (transientB_src_page),a
    jp chB_update_done

chA_ks_rect
    ld iy,coreA_make_rect_transient
    pop af
    ld (rect_transientA_vol),a
    pop hl
    ld d,l
    ld a,h
    ld (rect_transientA_comp),a
    jp chA_update_done

chB_ks_rect
    ld ix,coreB_make_rect_transient
    pop hl
    ld a,h
    ld (rect_transientB_vol),a
    pop hl
    ld d,l
    ld a,h
    ld (rect_transientB_comp),a
    jp chB_update_done

chA_ks_saw
    ld iy,coreA_make_saw_transient
    pop hl
    ld d,l
    jp chA_update_done

chB_ks_saw
    ld ix,coreB_make_saw_transient
    pop hl
    ld d,l
    jp chB_update_done

chA_rect
    ld iy,coreA_normal_rect
    pop af
    ld (vol_A_rect),a
    pop hl
    ld d,l
    ld a,h
    ld (duty_A_rect),a
    jp chA_update_done
    
chB_pwm
    ld ix,coreB_pwm0
    pop de
    pop hl
    ld a,h
    ld (B_pwm_volume),a
    ld a,(de)
    ld l,a
    jp chB_update_done

   
;******************************************************************************
coreA_make_saw_transient
    ld e,a                  ;4
    exx                     ;4
    ld a,b                  ;4
    exx                     ;4
    ld (hl),a               ;7
    ld (hl),a               ;7          ; timing
    jp _next                ;10         ; timing
_next
    dec l                   ;4 (44)

    out (c),e               ;12_64

    jr z,_transient_done
    jp (ix)

_transient_done
    ld l,d
    ld iy,coreA_ks
    jp (ix)


coreB_make_saw_transient
    exx                     ;4          ; -> regset 2
    ld a,b                  ;4
    ld (hl),a               ;7
    dec l                   ;4
    jr z,_transient_done    ;7
    dec b                   ;4          ; update timer lo

    exx                     ;4          ; -> regset 1
    ds 2                    ;8
    jp _next                ;10         ; timing
_next
    jp do_normal_out        ;10 (62)

_transient_done
    ld l,d
    dec b
    ld ix,coreB_ks
    exx
    jp do_normal_out
;******************************************************************************
coreA_make_rect_transient               ; create a rect wave in ringbuffer A
    ld e,a                  ;4          ; preserve outval8 in B
rect_transientA_comp equ $+1
    ld a,0                  ;7          ; load duty comparator
    cp l                    ;4          ; compare against freq counter
    sbc a,a                 ;4
rect_transientA_vol equ $+1
    and #ff                 ;7
    dec l                   ;4          ; update buffer ptr
    ld (hl),a               ;7          ; timing
    ld (hl),a               ;7 (44)     ; write to ringbuf

    out (c),e               ;12_64      ; outval8 -> port

    jr z,_transient_done    ;7
    jp (ix)                 ;8          ; jump to chB core

_transient_done
    ld l,d
    ld iy,coreA_ks
    jp (ix)


coreB_make_rect_transient               ; create a rect wave in ringbuffer B
    exx                     ;4          ; -> regset 2
    dec b                   ;4          ; update timer lo, no need to check
                                        ; timer hi as it will never expire here
rect_transientB_comp equ $+1
    ld a,0                  ;7
    cp l                    ;4
    sbc a,a                 ;4
rect_transientB_vol equ $+1
    and #ff                 ;7
    dec l                   ;4
    ld (hl),a               ;7
    jr z,_transient_done    ;7
    exx                     ;4          ; -> regset 1
    jp do_normal_out        ;10 (62)

_transient_done
    ld l,d
    ld ix,coreB_ks
    exx                                 ; -> regset 1
    jp do_normal_out

;******************************************************************************
coreA_normal_rect
    ld e,a                  ;4
duty_A_rect equ $+1
    ld a,0                  ;7
    cp l                    ;4
    sbc a,a                 ;4
vol_A_rect equ $+1
    and #ff                 ;7
    dec l                   ;4
    ld (hl),a               ;7
    ld (hl),a               ;7          ; timing

    out (c),e               ;12_64

    jr z,_reset_ptr         ;7
    jp (ix)                 ;8

_reset_ptr
    ld l,d
    jp (ix)

;******************************************************************************
coreA_make_rom_transient                ; copy rom/ram bytes to ringbuffer A
    ld e,a                  ;4
transientA_src_page equ $+1
    ld h,0                  ;7
    ld a,(hl)               ;7
    ld h,HIGH(ringbufA)     ;7
transientA_rom_vol equ $+1
    and 0                   ;7
    ld (hl),a               ;7
    dec l                   ;4 (43)     ; should be 44 but oh well

    out (c),e               ;12_63      ; oops
    
    jr z,_transient_done    ;7
    jp (ix)                 ;8

_transient_done
    ld l,d
    ld iy,coreA_ks
    jp (ix)


coreB_make_rom_transient
    exx                     ;4          ; -> regset 2
    dec b                   ;4          ; no need to check timer hi-byte here
transientB_src_page equ $+1
    ld h,0                  ;7
    ld a,(hl)               ;7
    ld h,HIGH(ringbufB)     ;7
transientB_rom_vol equ $+1
    and 0                   ;7
    ld (hl),a               ;7
    dec l                   ;4
    jr nz,_transient_done   ;12
    ld l,d
    ld ix,coreB_ks

_transient_done
    exx                     ;4          ; -> regset 1

    add a,(hl)              ;7
    rra                     ;4
    and b                   ;4
    ld e,a                  ;4
    rrca                    ;4 (86)     ; should be 85 but oh well

    out (c),e               ;12_113     ; oops
    and b                   ;4
    out (c),a               ;12_16
    rrca                    ;4
    and b                   ;4
    ld e,a                  ;4
    rrca                    ;4
    and b                   ;4
    out (c),e               ;12_32
    jp (iy)                 ;8


;******************************************************************************
coreA_mute
    ld e,a                  ;4
    xor a                   ;4
    jr _n1                  ;12         ; timing
_n1 jr _n2                  ;12         ; timing
_n2 jr _n3                  ;12 (44)    ; timing
_n3
    out (c),e               ;12_64
    ld (hl),a               ;7
    jp (ix)                 ;8

coreB_mute
    exx                     ;4          ; -> regset 2
    djnz _t_update_done     ;13
    jp _timer_update
_t_update_done
    exx                     ;4          ; -> regset 1
    ld a,0                  ;7          ; timing
    ld a,0                  ;7          ; timing
    ld a,0                  ;7          ; timing
    jp _next                ;10         ; timing
_next
    jp do_normal_out        ;10 (62)

_timer_update
    dec c
    jp nz,_t_update_done
    jp read_pattern

;******************************************************************************
coreA_ks                            ; karplus-strong core channel A
    ld e,a                  ;4      ; preserve outval8 in B
    ld a,(hl)               ;7      ; load byte from ringbuffer
    dec l                   ;4      ; update ringbuffer pointer
    jr nz,_ptr_update_done  ;12
    ld l,d
_ptr_update_done
    add a,(hl)              ;7      ; perform simple low-pass
    rra                     ;4
    inc sp                  ;6 (44) ;timing

    out (c),e               ;12_64  ; outval8 -> port

    ld (hl),a               ;7      ; write updated sample byte to ringbuffer
    jp (ix)                 ;8      ; jump to channel B core

coreB_ks                            ;karplus-strong core channel B
    exx                     ;4      ; -> regset 2
    djnz Bks_t_update_done  ;13     ; do timer update
    jp Bks_timer_update
Bks_t_update_done
    ld a,(hl)               ;7      ; load byte from ringbuf
    dec l                   ;4      ; update ringbuf ptr
    jr nz,_ptr_update_done  ;12
    ld l,d
_ptr_update_done
    add a,(hl)              ;7      ; perform simple low-pass
    rra                     ;4
    ld (hl),a               ;7      ; write updated sample byte to ringbuf
    exx                     ;4 (62) ; -> regset 1

do_normal_out
    add a,(hl)              ;7      ; vol = (vol_chA + vol_chB)/2
overdrive_toggle
    rra                     ;4      ; replaced with nop to enable overdrive
    and b                   ;4      ; mask bits 3..0
    ld e,a                  ;4      ; preserve outval1 in B
    rrca                    ;4 (85)

    out (c),e               ;12_112 ; outval1 -> port
    and b                   ;4
    out (c),a               ;12_16  ; outval2 -> port
    rrca                    ;4
    and b                   ;4
    ld e,a                  ;4      ; preserve outval4 in B
    rrca                    ;4
    and b                   ;4      ; A now holds outval8
    out (c),e               ;12_32  ; outval4 -> port
    jp (iy)                 ;8      ; jump to channel A core

Bks_timer_update
    dec c
    jp nz,Bks_t_update_done
    jp read_pattern

;******************************************************************************
coreB_pwm0
    ld a,(B_pwm_volume)
    exx
    ld h,a
    ld ix,coreB_pwm
    dec b
    jp Bp_t_update_done
    
coreB_pwm                           ; in: DE' = sample ptr, L' = first sample
                                    ;     H' = volume
    exx                     ;4      ; -> regset 2
    djnz Bp_t_update_done   ;13
    jp Bp_timer_update
Bp_t_update_done
    dec l                   ;4
    jr nz,Bp_no_next_smp    ;12/7
    inc de                  ;6
    ld a,(de)               ;7
    or a                    ;4
    jr z,B_pwm_done         ;12/7
    ld l,a                  ;4
    ld a,h                  ;4
B_pwm_volume equ $+1
    xor #ff                 ;7
    ld h,a                  ;4
Bp_update_done
    exx                     ;4 (75) should be 62    ; -> regset 1

    add a,(hl)              ;7      ; vol = (vol_chA + vol_chB)/2
overdrive_toggle_pwm
    rra                     ;4      ; replaced with nop to enable overdrive
    and b                   ;4      ; mask bits 3..0
    ld e,a                  ;4      ; preserve outval1 in B
    rrca                    ;4 (85)

    out (c),e               ;12_112 ; outval1 -> port
    and b                   ;4
    out (c),a               ;12_16  ; outval2 -> port
    rrca                    ;4
    and b                   ;4
    ld e,a                  ;4      ; preserve outval4 in B
    rrca                    ;4
    and b                   ;4      ; A now holds outval8
    out (c),e               ;12_32  ; outval4 -> port
    jp (iy)                 ;8      ; jump to channel A core


Bp_no_next_smp              ;+33
    ld a,r                  ;9      ; timing
    ld a,h                  ;4
    jr Bp_update_done       ;12 (+4=62)

B_pwm_done
    ld ix,coreB_mute
    jr Bp_update_done

Bp_timer_update
    dec c
    jp nz,Bp_t_update_done
    jp read_pattern

;******************************************************************************
IF (LOW($))!=0
    org 256*(1+(HIGH($)))
ENDIF

ringbufA
    ds 256
ringbufB
    ds 256

;******************************************************************************
music_data
    include "music.asm"
