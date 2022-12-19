;;; tftone - transition noise free Tritone implementation
;;; by utz 12'2022 * irrlichtproject.de
;;; original Tritone implementation by Shiru * shiru.untergrund.net

    device zxspectrum48
    org #8000

    include "note_names.h"

tftone_init
    di
    ld hl,0
    ld ix,0
    exx
    push hl
    push iy
    ld iy,0
    ld (.old_sp),sp
    ld hl,music_data
    xor a
    ex af,af'
    jp .read_sequence

.exit
.old_sp = $+1
    ld sp,0
    pop iy
    pop hl
    exx
    ei
    ret

.play
    exx                         ; 4
    ld sp,.note_buf             ;10
    pop bc                      ;10
    add hl,bc                   ;11
    out (#fe),a                 ;11__116
    ld a,h                      ; 4
    add a,d                     ; 4     duty ch1
    sbc a,a                     ; 4

    pop bc                      ;10
    out (#fe),a                 ;11__33
    add ix,bc                   ;15
    ld a,ixh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4

    pop bc                      ;10
    add iy,bc                   ;15
    out (#fe),a                 ;11__67
    exx                         ; 4
    ld a,iyh                    ; 8
    add a,c                     ; 4     duty ch3
    sbc a,a                     ; 4

    ex af,af'                   ; 4
    in a,(#fe)                  ;11
    cpl                         ; 4
    and #1f                     ; 7
    jr nz,.exit                 ; 7
    ex af,af'                   ; 4
    djnz .play                  ;13__216 (50)

.update_timer_hi
    exx                         ; 4
    ld sp,.note_buf             ;10
    pop bc                      ;10
    add hl,bc                   ;11
    out (#fe),a                 ;11__116
    ld a,h                      ; 4
    add a,d                     ; 4     duty ch1
    sbc a,a                     ; 4

    pop bc                      ;10
    out (#fe),a                 ;11__33
    add ix,bc                   ;15
    ld a,ixh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4

    pop bc                      ;10
    add iy,bc                   ;15
    out (#fe),a                 ;11__67
    exx                         ; 4
    ld a,iyh                    ; 8
    add a,c                     ; 4     duty ch3
    sbc a,a                     ; 4

    ex af,af'                   ; 4
    ld a,i                      ; 9
    dec a                       ; 4
    jr z,.next_row              ; 7/12

    ld i,a                      ; 9
    ex af,af'                   ; 4
    djnz .play                  ;13 (50)        adjust b by -1
    ;; z branch never taken

.skip_seq_read                  ;+16
    inc hl                      ; 6     timing
    dec hl                      ; 6     timing
    ld b,0                      ; 7     timing
    ld b,0                      ; 7     timing
    nop                         ; 4
    ex af,af'                   ; 4

    exx                         ; 4
    ld sp,.note_buf             ;10
    pop bc                      ;10
    add hl,bc                   ;11
    out (#fe),a                 ;11__116
    ld a,h                      ; 4
    add a,d                     ; 4     duty ch1
    sbc a,a                     ; 4

    pop bc                      ;10
    out (#fe),a                 ;11__33
    add ix,bc                   ;15
    ld a,ixh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4

    pop bc                      ;10
    add iy,bc                   ;15
    out (#fe),a                 ;11__67
    exx                         ; 4
    ld a,iyh                    ; 8
    add a,c                     ; 4     duty ch3
    sbc a,a                     ; 4

    ex af,af'                   ; 4
    inc sp                      ; 6     timing
    dec de                      ; 6
    nop                         ; 4

.skip_seq_reload                ;+16
    inc hl                      ; 6     timing
    dec hl                      ; 6     timing
    ld b,0                      ; 7     timing
    ld b,0                      ; 7     timing
    nop                         ; 4
    ex af,af'                   ; 4

    exx                         ; 4
    ld sp,.note_buf             ;10
    pop bc                      ;10
    add hl,bc                   ;11
    out (#fe),a                 ;11__116
    ld a,h                      ; 4
    add a,d                     ; 4     duty ch1
    sbc a,a                     ; 4

    pop bc                      ;10
    out (#fe),a                 ;11__33
    add ix,bc                   ;15
    ld a,ixh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4

    pop bc                      ;10
    add iy,bc                   ;15
    out (#fe),a                 ;11__67
    exx                         ; 4
    ld a,iyh                    ; 8
    add a,c                     ; 4     duty ch3
    sbc a,a                     ; 4

    ex af,af'                   ; 4
    ;; but from .skip_seq_reload we need to read the control byte again
    ld a,(de)                   ; 7
    inc de                      ; 6
    ld b,0                      ; 7     timing
    jr .read_ptn                ;12

.next_row                       ;+29
    ld a,(de)                   ; 7     control byte
    or a                        ; 4
    inc de                      ; 6
    ex af,af'                   ; 4 (50)

.read_ctrl_byte
    exx                         ; 4
    ld sp,.note_buf             ;10
    pop bc                      ;10
    add hl,bc                   ;11
    out (#fe),a                 ;11__116
    ld a,h                      ; 4
    add a,d                     ; 4     duty ch1
    sbc a,a                     ; 4

    pop bc                      ;10
    out (#fe),a                 ;11__33
    add ix,bc                   ;15
    ld a,ixh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4

    pop bc                      ;10
    add iy,bc                   ;15
    out (#fe),a                 ;11__67
    exx                         ; 4
    ld a,iyh                    ; 8
    add a,c                     ; 4     duty ch3
    sbc a,a                     ; 4

    ex af,af'                   ; 4
    jr nz,.skip_seq_read        ; 7
    ld e,(hl)                   ; 7     read sequence low byte
    inc hl                      ; 4
    ld d,(hl)                   ; 7     read sequence hi byte
    ld a,(hl)                   ; 7     also timing
    inc hl                      ; 6
    or a                        ; 4
    ex af,af'                   ; 4__216 (50)


    exx                         ; 4
    ld sp,.note_buf             ;10
    pop bc                      ;10
    add hl,bc                   ;11
    out (#fe),a                 ;11__116
    ld a,h                      ; 4
    add a,d                     ; 4     duty ch1
    sbc a,a                     ; 4

    pop bc                      ;10
    out (#fe),a                 ;11__33
    add ix,bc                   ;15
    ld a,ixh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4

    pop bc                      ;10
    add iy,bc                   ;15
    out (#fe),a                 ;11__67
    exx                         ; 4
    ld a,iyh                    ; 8
    add a,c                     ; 4     duty ch3
    sbc a,a                     ; 4

    ex af,af'                   ; 4
    jr nz,.skip_seq_reload      ; 7
    ld e,(hl)                   ; 7     read loop point lo byte
    inc hl                      ; 6
    ld d,(hl)                   ; 7     read loop point hi byte
    ex de,hl                    ; 4     update sequence pointer
.read_sequence
    ld e,(hl)                   ; 7     sequence lo byte
    nop                         ; 4
    ex af,af'                   ; 4__216 (50)


    exx                         ; 4
    ld sp,.note_buf             ;10
    pop bc                      ;10
    add hl,bc                   ;11
    out (#fe),a                 ;11__116
    ld a,h                      ; 4
    add a,d                     ; 4     duty ch1
    sbc a,a                     ; 4

    pop bc                      ;10
    out (#fe),a                 ;11__33
    add ix,bc                   ;15
    ld a,ixh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4

    pop bc                      ;10
    add iy,bc                   ;15
    out (#fe),a                 ;11__67
    exx                         ; 4
    ld a,iyh                    ; 8
    add a,c                     ; 4     duty ch3
    sbc a,a                     ; 4

    ex af,af'                   ; 4
    inc hl                      ; 6
    ld d,(hl)                   ; 7     sequence hi byte
    inc hl                      ; 6

    ld a,(de)                   ; 7     control byte
    inc de                      ; 6
.read_ptn
    sla a                       ; 8     set load flags (bit 7->c, bit 6->s, po)
    ex de,hl                    ; 4     hl->ptn, de->seq
    ex af,af'                   ; 4__116 (50)  TODO is 52


.read_ch3
    exx                         ; 4
    ld sp,.note_buf             ;10
    pop bc                      ;10
    add hl,bc                   ;11
    out (#fe),a                 ;11__116
    ld a,h                      ; 4
    add a,d                     ; 4     duty ch1
    sbc a,a                     ; 4

    pop bc                      ;10
    out (#fe),a                 ;11__33
    add ix,bc                   ;15
    ld a,ixh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4

    pop bc                      ;10
    add iy,bc                   ;15
    out (#fe),a                 ;11__67
    exx                         ; 4
    ld a,iyh                    ; 8
    add a,c                     ; 4     duty ch3
    sbc a,a                     ; 4

    ex af,af'                   ; 4
    jp pe,.skip_ch3             ;10
    ld c,(hl)                   ; 7     new fdiv ch3
    inc hl                      ; 6
    ld b,(hl)                   ; 7
    push bc                     ;11
    ex af,af'                   ; 4_216 (50) FIXME is 49


    exx                         ; 4
    ld sp,.note_buf             ;10
    pop bc                      ;10
    add hl,bc                   ;11
    out (#fe),a                 ;11__116
    ld a,h                      ; 4
    add a,d                     ; 4     duty ch1
    sbc a,a                     ; 4

    pop bc                      ;10
    out (#fe),a                 ;11__33
    add ix,bc                   ;15
    ld a,ixh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4

    pop bc                      ;10
    add iy,bc                   ;15
    out (#fe),a                 ;11__67
    exx                         ; 4
    ld a,iyh                    ; 8

    inc hl                      ; 6
    ld c,(hl)                   ; 7     new duty ch3
    inc hl                      ; 6

    add a,c                     ; 4     duty ch3
    sbc a,a                     ; 4

.read_ch2
    ex af,af'                   ; 4
    jp p,.skip_ch2              ;10
    ld a,(hl)                   ; 7     (fdiv lo ch2)
    inc hl                      ; 6
    ex af,af'                   ; 4__216 (50)


    exx                         ; 4
    ld sp,.note_buf             ;10
    pop bc                      ;10
    add hl,bc                   ;11
    out (#fe),a                 ;11__116
    ld a,h                      ; 4
    add a,d                     ; 4     duty ch1
    sbc a,a                     ; 4

    pop bc                      ;10
    out (#fe),a                 ;11__33
    add ix,bc                   ;15
    ld a,ixh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4

    pop bc                      ;10
    add iy,bc                   ;15
    out (#fe),a                 ;11__67
    exx                         ; 4
    ld a,iyh                    ; 8
    add a,c                     ; 4     duty ch3
    sbc a,a                     ; 4

    ex af,af'                   ; 4
    ld (.note_buf+2),a          ;13
    ld a,(hl)                   ; 4
    inc hl                      ; 6
    ld (.note_buf+3),a          ;13
    inc sp                      ; 6     timing
    ex af,af'                   ; 4__216 (50)


    exx                         ; 4
    ld sp,.note_buf             ;10
    pop bc                      ;10
    add hl,bc                   ;11
    out (#fe),a                 ;11__116
    ld a,h                      ; 4
    add a,d                     ; 4     duty ch1
    sbc a,a                     ; 4

    pop bc                      ;10
    out (#fe),a                 ;11__33
    add ix,bc                   ;15
    ld a,ixh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4

    pop bc                      ;10
    add iy,bc                   ;15
    out (#fe),a                 ;11__67
    exx                         ; 4
    ld a,iyh                    ; 8
    add a,c                     ; 4     duty ch3
    sbc a,a                     ; 4

    ex af,af'                   ; 4
    ld a,(hl)                   ; 7     duty ch2
    inc hl                      ; 6
    exx                         ; 4
    ld e,a                      ; 4
    exx                         ; 4
.read_ch1
    jp nc,.skip_ch1             ;10
    ld a,(hl)                   ; 7     fdiv lo ch1
    ex af,af'                   ; 4__216 (50)


    exx                         ; 4
    ld sp,.note_buf             ;10
    pop bc                      ;10
    add hl,bc                   ;11
    out (#fe),a                 ;11__116
    ld a,h                      ; 4
    add a,d                     ; 4     duty ch1
    sbc a,a                     ; 4

    pop bc                      ;10
    out (#fe),a                 ;11__33
    add ix,bc                   ;15
    ld a,ixh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4

    pop bc                      ;10
    add iy,bc                   ;15
    out (#fe),a                 ;11__67
    exx                         ; 4
    ld a,iyh                    ; 8
    add a,c                     ; 4     duty ch3
    sbc a,a                     ; 4

    ex af,af'                   ; 4
    ret nc                      ; 5     timing
    ret nc                      ; 5     timing
    ld (.note_buf),a            ;13
    inc hl                      ; 6
    ld a,(hl)                   ; 7     fdiv hi ch1
    inc hl                      ; 6
    ex af,af'                   ; 4__216 (50)


    exx                         ; 4
    ld sp,.note_buf             ;10
    pop bc                      ;10
    add hl,bc                   ;11
    out (#fe),a                 ;11__116
    ld a,h                      ; 4
    add a,d                     ; 4     duty ch1
    sbc a,a                     ; 4

    pop bc                      ;10
    out (#fe),a                 ;11__33
    add ix,bc                   ;15
    ld a,ixh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4

    pop bc                      ;10
    add iy,bc                   ;15
    out (#fe),a                 ;11__67
    exx                         ; 4
    ld a,iyh                    ; 8
    add a,c                     ; 4     duty ch3
    sbc a,a                     ; 4

    ex af,af'                   ; 4
    ld (.note_buf+1),a          ;13
    ld a,(hl)                   ; 7     (duty ch1)
    inc hl                      ; 6
    exx                         ; 4
    ld d,a                      ; 4
    exx                         ; 4
    nop                         ; 4
    ex af,af'                   ; 4__216 (50)


.read_length                    ;       or drum
    exx                         ; 4
    ld sp,.note_buf             ;10
    pop bc                      ;10
    add hl,bc                   ;11
    out (#fe),a                 ;11__116
    ld a,h                      ; 4
    add a,d                     ; 4     duty ch1
    sbc a,a                     ; 4

    pop bc                      ;10
    out (#fe),a                 ;11__33
    add ix,bc                   ;15
    ld a,ixh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4

    pop bc                      ;10
    add iy,bc                   ;15
    out (#fe),a                 ;11__67
    exx                         ; 4
    ld a,iyh                    ; 8
    add a,c                     ; 4     duty ch3
    sbc a,a                     ; 4

    ex af,af'                   ; 4
    ld a,(hl)                   ; 7     if z, drum, else tempo*4
    inc hl                      ; 6
    or a                        ; 4
    jp z,pwm_init               ;10
    ld b,0                      ; 7     timing
    ds 2                        ; 8
    ex af,af'                   ; 4__216 (50)


    exx                         ; 4
    ld sp,.note_buf             ;10
    pop bc                      ;10
    add hl,bc                   ;11
    out (#fe),a                 ;11__116
    ld a,h                      ; 4
    add a,d                     ; 4     duty ch1
    sbc a,a                     ; 4

    pop bc                      ;10
    out (#fe),a                 ;11__33
    add ix,bc                   ;15
    ld a,ixh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4

    pop bc                      ;10
    add iy,bc                   ;15
    out (#fe),a                 ;11__67
    exx                         ; 4
    ld a,iyh                    ; 8
    add a,c                     ; 4     duty ch3
    sbc a,a                     ; 4

    ex af,af'                   ; 4     we've done or a, so carry is reset
.drum_return
    ld b,0                      ; 7
    ld b,0                      ; 7     timing
    nop                         ; 4
    rra                         ; 4
    rr b                        ; 8
    rra                         ; 4
    rr b                        ; 8
    ex af,af'                   ; 4__216 (50)


    exx                         ; 4
    ld sp,.note_buf             ;10
    pop bc                      ;10
    add hl,bc                   ;11
    out (#fe),a                 ;11__116
    ld a,h                      ; 4
    add a,d                     ; 4     duty ch1
    sbc a,a                     ; 4

    pop bc                      ;10
    out (#fe),a                 ;11__33
    add ix,bc                   ;15
    ld a,ixh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4

    pop bc                      ;10
    add iy,bc                   ;15
    out (#fe),a                 ;11__67
    exx                         ; 4
    ld a,iyh                    ; 8
    add a,c                     ; 4     duty ch3
    sbc a,a                     ; 4

    ex af,af'                   ; 4     we've done or a, so carry is reset
    ld i,a                      ; 9
    ld a,-13                    ; 7     adjust timer lo for extra iterations
    add a,b                     ; 4
    ld b,a                      ; 4
    ex af,af'                   ; 4
    ex de,hl                    ; 4     swap back so hl->seq and de->ptn
    nop                         ; 4
    jp .play                    ;10__216 (50)


.skip_ch3
    ds 8                        ;32
    ex af,af'                   ; 4

    exx                         ; 4
    ld sp,.note_buf             ;10
    pop bc                      ;10
    add hl,bc                   ;11
    out (#fe),a                 ;11__116
    ld a,h                      ; 4
    add a,d                     ; 4     duty ch1
    sbc a,a                     ; 4

    pop bc                      ;10
    out (#fe),a                 ;11__33
    add ix,bc                   ;15
    ld a,ixh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4

    pop bc                      ;10
    add iy,bc                   ;15
    out (#fe),a                 ;11__67
    exx                         ; 4
    ld a,iyh                    ; 8
    add a,c                     ; 4     duty ch3
    sbc a,a                     ; 4

    ex (sp),hl                  ;19     timing
    ex (sp),hl                  ;19     timing
    ds 3                        ;12


    exx                         ; 4
    ld sp,.note_buf             ;10
    pop bc                      ;10
    add hl,bc                   ;11
    out (#fe),a                 ;11__116
    ld a,h                      ; 4
    add a,d                     ; 4     duty ch1
    sbc a,a                     ; 4

    pop bc                      ;10
    out (#fe),a                 ;11__33
    add ix,bc                   ;15
    ld a,ixh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4

    pop bc                      ;10
    add iy,bc                   ;15
    out (#fe),a                 ;11__67
    exx                         ; 4
    ld a,iyh                    ; 8
    add a,c                     ; 4     duty ch3
    sbc a,a                     ; 4

    ld r,a                      ; 9     timing
    jp .read_ch2                ;10

.skip_ch2
    ret m                       ; 5     timing
    ds 2                        ; 4
    ex af,af'                   ; 4

    exx                         ; 4
    ld sp,.note_buf             ;10
    pop bc                      ;10
    add hl,bc                   ;11
    out (#fe),a                 ;11__116
    ld a,h                      ; 4
    add a,d                     ; 4     duty ch1
    sbc a,a                     ; 4

    pop bc                      ;10
    out (#fe),a                 ;11__33
    add ix,bc                   ;15
    ld a,ixh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4

    pop bc                      ;10
    add iy,bc                   ;15
    out (#fe),a                 ;11__67
    exx                         ; 4
    ld a,iyh                    ; 8
    add a,c                     ; 4     duty ch3
    sbc a,a                     ; 4

    ex (sp),hl                  ;19     timing
    ex (sp),hl                  ;19     timing
    ds 3                        ;12


    exx                         ; 4
    ld sp,.note_buf             ;10
    pop bc                      ;10
    add hl,bc                   ;11
    out (#fe),a                 ;11__116
    ld a,h                      ; 4
    add a,d                     ; 4     duty ch1
    sbc a,a                     ; 4

    pop bc                      ;10
    out (#fe),a                 ;11__33
    add ix,bc                   ;15
    ld a,ixh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4

    pop bc                      ;10
    add iy,bc                   ;15
    out (#fe),a                 ;11__67
    exx                         ; 4
    ld a,iyh                    ; 8
    add a,c                     ; 4     duty ch3
    sbc a,a                     ; 4

    ex af,af'                   ; 4
    ld a,(hl)                   ; 7     timing
    ds 2                        ; 8
    jp .read_ch1                ;10

.skip_ch1
    ld a,(hl)                   ; 7     timing
    ex af,af'                   ; 4

    exx                         ; 4
    ld sp,.note_buf             ;10
    pop bc                      ;10
    add hl,bc                   ;11
    out (#fe),a                 ;11__116
    ld a,h                      ; 4
    add a,d                     ; 4     duty ch1
    sbc a,a                     ; 4

    pop bc                      ;10
    out (#fe),a                 ;11__33
    add ix,bc                   ;15
    ld a,ixh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4

    pop bc                      ;10
    add iy,bc                   ;15
    out (#fe),a                 ;11__67
    exx                         ; 4
    ld a,iyh                    ; 8
    add a,c                     ; 4     duty ch3
    sbc a,a                     ; 4

    ex (sp),hl                  ;19     timing
    ex (sp),hl                  ;19     timing
    ds 3                        ;12


    exx                         ; 4
    ld sp,.note_buf             ;10
    pop bc                      ;10
    add hl,bc                   ;11
    out (#fe),a                 ;11__116
    ld a,h                      ; 4
    add a,d                     ; 4     duty ch1
    sbc a,a                     ; 4

    pop bc                      ;10
    out (#fe),a                 ;11__33
    add ix,bc                   ;15
    ld a,ixh                    ; 8
    add a,e                     ; 4
    sbc a,a                     ; 4

    pop bc                      ;10
    add iy,bc                   ;15
    out (#fe),a                 ;11__67
    exx                         ; 4
    ld a,iyh                    ; 8
    add a,c                     ; 4     duty ch3
    sbc a,a                     ; 4

    ds 10                       ;40
    jp .read_length             ;10

.note_buf
    ds 6


pwm_init
    ld b,a                      ;       b=0 (prep timer lo)

;;; Pulse Width Modulated Drums
;;; A reusable click drum system for ZX Spectrum beeper engines
;;; by utz/irrlicht project 09'2019 * irrlichtproject.de
;;; Adjusted for tftone
;;;
;;; Usage: In the calling code, define the symbol DRUM_RETURN_ADDRESS and set
;;;        it to the address that the player should return to.
;;;        To play a drum, 'JP pwm_init' with length as 1st byte, volume as 2nd
;;;        byte, and pointer to PWM data as second word on stack. Interrupts
;;;        should be disabled. Volume must be (0x10..0xf0) & 0xf0
;;;
;;;        Timing offset must be corrected manually. Execution takes
;;;        (108 * length * 256 + 5 * (length - 1) - 32) cycles.
;;;
;;;        The routine preserves all registers except F and SP.
;;;
;;;        PWM data should use a sample rate of 32407 Hz. The end of a sample
;;;        must be marked with a 0-byte.


    ld (.old_BC),bc             ; 20
    ld (.old_DE),de             ; 20

    ld e,(hl)                   ;       drum length
    inc hl
    ld a,(hl)                   ;       volume
    ld (.volume_restore),a      ; 13

    inc hl
    ld a,(hl)                   ;       pwm data ptr lo
    inc hl
    ld c,(hl)                   ;       pwm data ptr hi
    inc hl
    ld (.old_HL),hl
    ld h,c                      ;       hl<-pwm data ptr
    ld l,a

    ld c,#fe                    ; 7

    ld d,(hl)                   ; 7
    xor a                       ; 4
    ld b,#fe                    ; 7     timer lo, skip 2 loops to adjust time
                                ; init 131

.play_drum0
    nop                         ; 4
.play_drum
    out (c),a                   ; 12__33

    rlca                        ; 4
    rlca                        ; 4
    dec d                       ; 4
    jp nz,.wait                 ; 10

    ret nz                      ; 5     timing
.volume_restore = $+1           ;       load next sample byte
    xor 0                       ; 7
    inc hl                      ; 6
    ld d,(hl)                   ; 7 (25)

.wait_ret
    out (c),a                   ; 12__59
    rrca                        ; 4
    out (c),a                   ; 12__16
    rrca                        ; 4

    djnz .play_drum0            ; 13 --- 108     update length counter lo-byte

    dec e                       ; 4
    jp nz,.play_drum            ; 10


.drum_exit
.old_HL = $+1
    ld hl,0                     ; 10
.old_BC = $+1
    ld bc,0                     ; 10
.old_DE = $+1
    ld de,0                     ; 10

.exit_drum
    ld a,(hl)
    inc hl
    jp tftone_init.drum_return  ; 10 -- exit 61, init+exit 192


.wait
    inc d                       ; 4     check for sample end
    jr z,.disable_drum          ; 7
    dec d                       ; 4
    jp .wait_ret                ; 10 -- 25


.wait_for_drum_end
    nop                         ; 4
    ex (sp),hl                  ; 19
    ex (sp),hl                  ; 19
    ex (sp),hl                  ; 19
    ex (sp),hl                  ; 19

.disable_drum
    xor a                       ; 4
    out (#fe),a                 ; 11
    djnz .wait_for_drum_end     ; 13 (108)

    dec e
    jp nz,.wait_for_drum_end+1

    jp .drum_exit


    display $-tftone_init

music_data
    include "music.asm"

end
    savetap "main.tap",CODE,"main",tftone_init,end-tftone_init
