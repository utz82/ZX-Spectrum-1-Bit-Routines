;;; Aczidbox - Phase Distortion Synthesis for ZX Spectrum beeper
;;; by utz 01'2021 * irrlichtproject.de
;;;
;;; Requires space for a 256 byte lookup table at 0xf000.

    include "note_names.asm"

ACZ_LOUDNESS equ 1
ACZ_LOOPING equ 1
ACZ_SYNTH_KICK equ 1
ACZ_SYNTH_NOISE equ 1
ACZ_PWM equ 1

    org #8000

acz_init
    ei                          ; detect kempston joystick
    halt
    in a,(#1f)
    inc a
    jr nz,_skip
    ld (mask_kempston),a
_skip

    di

    exx
    push hl
    push iy
    ld (old_sp),sp

    ld hl,transformation_table
    ld de,#f000
    ld bc,#100
    ldir
    ld bc,#f0fe

    ld sp,music_data
    jr read_seq0

read_seq_loop
    pop hl
    ld sp,hl
    jr read_seq0

read_seq
    ld (rescnt1_restore),hl
seq_ptr equ $+1
    ld sp,0
read_seq0
    pop hl
    ld a,h
    or l
IF(ACZ_LOOPING)
    jr z,read_seq_loop
ELSE
    jp z,exit_player
ENDIF
    ld (seq_ptr),sp
    ld sp,hl
rescnt1_restore equ $+1
    ld hl,0
    jr read_ptn0

exit_player
old_sp equ $+1
    ld sp,0
    pop iy
    pop hl
    exx
    ei
    ret

read_ptn
    ld a,d
    ex af,af'
    in a,(#1f)                  ; read joystick/keyboard
mask_kempston equ $+1
    and #1f
    ld d,a
    in a,(#fe)
    cpl
    or d
    and #1f
    jr nz,exit_player
    ex af,af'
    ld d,a

    ld (fdiv1_restore),sp
ptn_ptr equ $+1
    ld sp,0
read_ptn0
    pop af
    jr z,read_seq

    ld (timer_hi),a
    jp pe,play_drum

drum_ret
    jr c,_no_ch1_update

    pop hl
    ld a,l
    ld (ch1_resonance_mod),a
    pop hl
    ld (fdiv1_restore),hl
    pop de
    ld hl,0
    ld ix,0

_no_ch1_update
    jp m,_no_ch2_update
    exx
    pop hl
    ld a,l
    ld (ch2_resonance_mod),a
    pop bc
    pop de
    ld iy,0
    ld hl,0
    exx

_no_ch2_update
    ld (ptn_ptr),sp
fdiv1_restore equ $+1
    ld sp,0

    xor a
    ld b,a
    ex af,af'                   ;      a


play_note
    out (c),b                   ; 12__64
    add ix,sp                   ; 15   update base frequency counter ch1
    ccf                         ; 4    on overflow,
    sbc a,a                     ; 4    reset resonance frequency counter ch1
    and h                       ; 4
    ld h,a                      ; 4
    add hl,de                   ; 11   update resonance frequency counter ch1

    exx                         ; 4    x'
    add iy,bc                   ; 15   update base frequency counter ch2
    ccf                         ; 4    on overflow,
    sbc a,a                     ; 4    reset resonance frequency counter ch2
    and h                       ; 4
    ld h,a                      ; 4
    add hl,de                   ; 11   update resonance frequency counter ch2
    exx                         ; 4    x

    ex af,af'                   ; 4    a'  retrieve frame volume backup
    nop                         ; 4
    out (c),a                   ; 12__112
    rrca                        ; 4
    out (c),a                   ; 12__16

    ex af,af'                   ; 4    a
    ld a,ixh                    ; 8    prepare to calculate ch1 sample volume
    ex af,af'                   ; 4    a'

    rrca                        ; 4
    out (c),a                   ; 12__32

    ex af,af'                   ; 4    a
    ld b,#f0                    ; 7
    and b                       ; 4    calculate ch1 sample vol
    ld c,a                      ; 4
    ld a,h                      ; 4
    and #0f                     ; 7
    or c                        ; 4
    ld c,a                      ; 4
    ex af,af'                   ; 4   a'

    rrca                        ; 4
    and #f0                     ; 7   mask lower bits
    out (#fe),a                 ; 11__64

    ex af,af'                   ; 4   a
    ld a,(bc)                   ; 7   bc = #f000 + ((base_freq_ch1 & #0f) | (res_freq_ch1 & #f0))
    ld (_vol1),a                ; 13  store ch1 sample vol for next calculation
    ld a,iyh                    ; 8   calculate ch2 sample vol
    and b                       ; 4   and #f0
    ld c,a                      ; 4

    exx                         ; 4   x'
    ld a,h                      ; 4
    exx                         ; 4   x

    and #0f                     ; 7
    or c                        ; 4
    ld c,a                      ; 4
    ld a,(bc)                   ; 7

_vol1 equ $+1
    add a,0                     ; 7   next frame volume = ch1 sample vol + ch2 sample vol
    ld c,a                      ; 4
    ex af,af'                   ; 4   a->a'  backup frame volume
    ld a,c                      ; 4
    ld c,#fe                    ; 7

    out (c),a                   ; 12__112
    rrca                        ; 4
    out (c),a                   ; 12__16
    ds 3                        ; 12
    rrca                        ; 4
    and b                       ; 4
    out (c),a                   ; 12__32

    rrca                        ; 4
    and b                       ; 4
    ld b,a                      ; 4

timer_lo equ $+1
    ld a,0                      ; 7
    dec a                       ; 4   TODO could double update speed
    ;; dec a
    nop                         ; 4
    ld (timer_lo),a             ; 13
    jr nz,play_note             ; 12

timer_hi equ $+1                ;+47
    ld a,0                      ; 7
    dec a                       ; 4
    jp z,read_ptn               ; 10
    ld (timer_hi),a             ; 13

    ld a,e                      ; 4   ch1 resonance sweep
ch1_resonance_mod equ $+1
    add a,#10                   ; 7
    ld e,a                      ; 4
    adc a,d                     ; 4
    sub e                       ; 4
    ld d,a                      ; 4

    exx                         ; 4
    ld a,e                      ; 4   ch2 resonance sweep
ch2_resonance_mod equ $+1
    add a,#0                    ; 7
    ld e,a                      ; 4
    adc a,d                     ; 4
    sub e                       ; 4
    ld d,a                      ; 4
    exx                         ; 4

    jp play_note                ;10


play_drum
    ld (drum_old_hl),hl
    pop hl
    ld (drum_old_sp),sp
    ld sp,hl
IF(ACZ_SYNTH_KICK = 1)
    jr c,kick_drum_init
ENDIF
IF(ACZ_PWM = 1)
    jp m,pwm_init
ENDIF
IF(ACZ_SYNTH_NOISE = 1)
    jp noise_init
ENDIF

DRUM_RETURN_ADDRESS
drum_old_hl equ $+1
    ld hl,0
drum_old_sp equ $+1
    ld sp,0
    pop af
    ld (timer_lo),a
    jp drum_ret


IF(ACZ_SYNTH_KICK = 1)

;;; USAGE: 1) Define DRUM_RETURN_ADDRESS
;;;        2) Prepare stack
;;;           SP+0 - decay mode (NO_DECAY, LINEAR_DECAY/_X2, EXPONENTIAL_DECAY)
;;;           SP+2 - sweep speed (bit mask, more bits ~ faster speed)
;;;           SP+3 - initial pitch (higher value ~ higher pitch)
;;;           SP+4 - volume ((1..7)<<4)
;;;           SP+5 - length
;;;        3) JP kick_drum_init
;;;
;;; TIMING: ca. (length * 112 * 256 + (length - 1) * 24) cycles
;;;
;;; REGISTER USAGE: F/F' destroyed, SP += 6

NO_DECAY equ #5faf              ; xor a; ld e,a
LINEAR_DECAY equ #1d00          ; nop; dec e
LINEAR_DECAY_X2 equ #1d1d       ; dec e; dec e
EXPONENTIAL_DECAY equ #3bcb     ; srl e

kick_drum_init
    ld (_oldDE),de              ; 20
    ld (_oldBC),bc              ; 20
    ld (_oldA),a                ; 13
    ex af,af'                   ;  4
    ld (_oldAshadow),a          ; 13

    pop bc                      ; 10    volume|length<<8
    ld a,b                      ;  4
    ex af,af'                   ;  4
    pop de                      ; 10    sweep_speed|initial_pitch<<8
    pop hl                      ; 10
    ld (_end_mode),hl           ; 16
    xor a                       ;  4
    ld h,a                      ;  4
    ld l,a                      ;  4
    ld b,#fe                    ;  7    adjust timer lo
    ex af,af'                   ;  4 -- init 163

    ex af,af'
_play_kick
    out (#fe),a                 ; 11__29
    add hl,de                   ; 11
    jr nc,_wait                 ; 12/7

    rlc e                       ;  8
    jr nc,_no_sweep_update      ; 12/7
    srl d                       ;  8 -- 30

    ld a,h                      ;  4
    rlca                        ;  4
    sbc a,a                     ;  4
    and c                       ;  4
    out (#fe),a                 ; 11__68
    rrca                        ;  4
    out (#fe),a                 ; 11__15
    rrca                        ;  4
    dec b                       ;  4
    jp nz,_play_kick            ; 10 --- 112

    ex af,af'
    dec a
    jr nz,_play_kick - 1
    jr _exit

_wait                           ;+12
    ld a,d                      ;  4
    or a                        ;  4
    jr z,_play_kick_end0        ; 12/7

_no_sweep_update
    nop                         ;  4
    ld a,h                      ;  4
    rlca                        ;  4
    sbc a,a                     ;  4
    and c                       ;  4
    out (#fe),a                 ; 11
    rrca                        ;  4
    out (#fe),a                 ; 11
    rrca                        ;  4
    djnz _play_kick             ; 13 --- 112

    ex af,af'
    dec a
    jr nz,_play_kick - 1
    jr _exit


_play_kick_end0
    ld e,#80
    jp _wait_return_end

    ex af,af'
_play_kick_end
    out (#fe),a                 ; 11__29
    add hl,de                   ; 11
    jr nc,_wait_end             ; 12/7

_end_mode
    ds 2                        ;  8
    ld a,0                      ;  7    timing
    ds 2                        ;  8 -- 30

_wait_return_end
    ld a,h                      ;  4
    rlca                        ;  4
    sbc a,a                     ;  4
    and c                       ;  4
    out (#fe),a                 ; 11__68
    rrca                        ;  4
    out (#fe),a                 ; 11__15
    rrca                        ;  4
    dec b                       ;  4
    jp nz,_play_kick_end        ; 10

    ex af,af'
    dec a
    jr nz,_play_kick_end - 1

_exit
_oldDE equ $+1
    ld de,0                     ; 10
_oldBC equ $+1
    ld bc,0                     ; 10
_oldAshadow equ $+1
    ld a,0                      ;  7
    ex af,af'                   ;  4
_oldA equ $+1
    ld a,0                      ;  7
    jp DRUM_RETURN_ADDRESS      ; 10 -- exit 58, init+exit 221

_wait_end                       ;+12
    ds 2                        ;  8
    jp _wait_return_end         ; 10 -- 30

ENDIF


IF(ACZ_PWM = 1)
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
ENDIF


IF(ACZ_SYNTH_NOISE)

;;; USAGE: 1) Define DRUM_RETURN_ADDRESS
;;;        2) Set up the stack: SP+0 - 0, SP+1 - volume ((1..7)<<4)
;;;                             SP+2 - pitch (1..0xff, 1 is highest)
;;;                             SP+3 - length
;;;        3) JP noise_init
;;;
;;; TIMING: length * 112 + (length - 1) * 13 + 8 cycles
;;;
;;; REGISTER USAGE: F destroyed, SP += 4

noise_init
    ld (_oldDE),de              ; 20
    ld (_oldBC),bc              ; 20
    ld (_oldIX),ix              ; 20
    ld (_oldA),a                ; 13

    pop af                      ; 10    volume
    ld (_volume),a              ; 13
    pop bc                      ; 10    pitch|length<<8
    ld ixl,c                    ;  8
    ld de,#2157                 ; 10    initial PRNG seed
    xor a                       ;  4
    ld h,a                      ;  4
    ld l,a                      ;  4
    ld ixh,#fe                  ; 11 -- init: 163   adjust timer lo

_loop
    out (#fe),a                 ; 11__33
    dec c                       ;  4
    jr nz,_no_update            ; 12/7

    ld c,ixl                    ;  8    restore pitch
    add hl,de                   ; 11    el cheapo PRNG
    rlc h                       ;  8
    inc d                       ;  4 -- 48

_wait_return
    ld a,h                      ;  4
_volume equ $+1
    and #30                     ;  7
    out (#fe),a                 ; 11__64
    rrca                        ;  4
    out (#fe),a                 ; 11__15
    rrca                        ;  4
    dec ixh                     ;  4
    jp nz,_loop                 ; 10 --- 112

    djnz _loop


_oldDE equ $+1
    ld de,0                     ; 10
_oldBC equ $+1
    ld bc,0                     ; 10
_oldIX equ $+2
    ld ix,0                     ; 10
_oldA equ $+1
    ld a,0                      ;  7
    jp DRUM_RETURN_ADDRESS      ; 14 -- exit 61, init+exit 224

_no_update                      ;+12
    ds 6                        ; 24
    jr _wait_return             ; 12 -- 48

ENDIF


;;; Transformation Lookup Table
;;; The player looks up
;;; ((base_frequency_counter & 0xf0) | (resonant_frequency_divider & 0x0f))
;;; and the result is the inverse base saw wave sample value times the
;;; resonant sine wave sample, normalized to the range 0...127
;;;(string-intersperse
;;; (map (lambda (r)
;;;        (string-append
;;;         "    db "
;;;         (string-intersperse
;;;          (reverse
;;;           (map (lambda (c)
;;;        	  (number->string
;;;        	   (inexact->exact
;;;        	    (round (+ 64 (* 67 (* (/ c 16)
;;;        				  (sin (* (/ r 16)
;;;        					  (* 2 3.141592653589793))))))))))
;;;        	(iota 16)))
;;;          ",")))
;;;      (iota 16))
;;; "\n")

transformation_table
IF(ACZ_LOUDNESS = 0)
    db 0,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64
    db 88,86,85,83,82,80,78,77,75,74,72,70,69,67,66,64
    db 108,105,102,100,97,94,91,88,85,82,79,76,73,70,67,64
    db 122,118,114,110,107,103,99,95,91,87,83,79,76,72,68,64
    db 127,123,118,114,110,106,102,98,93,89,85,81,77,72,68,64
    db 122,118,114,110,107,103,99,95,91,87,83,79,76,72,68,64
    db 108,105,102,100,97,94,91,88,85,82,79,76,73,70,67,64
    db 88,86,85,83,82,80,78,77,75,74,72,70,69,67,66,64
    db 64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64
    db 40,42,43,45,46,48,50,51,53,54,56,58,59,61,62,64
    db 20,23,26,28,31,34,37,40,43,46,49,52,55,58,61,64
    db 6,10,14,18,21,25,29,33,37,41,45,49,52,56,60,64
    db 1,5,10,14,18,22,26,30,35,39,43,47,51,56,60,64
    db 6,10,14,18,21,25,29,33,37,41,45,49,52,56,60,64
    db 20,23,26,28,31,34,37,40,43,46,49,52,55,58,61,64
    db 40,42,43,45,46,48,50,51,53,54,56,58,59,61,62,64
ELSE
    db 0,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64
    db 90,88,86,85,83,81,79,78,76,74,73,71,69,67,66,64
    db 112,109,105,102,99,96,93,89,86,83,80,77,74,70,67,64
    db 126,122,118,114,110,106,101,97,93,89,85,81,76,72,68,64
    db 127,127,122,118,114,109,104,100,96,91,86,82,78,73,68,64
    db 126,122,118,114,110,106,101,97,93,89,85,81,76,72,68,64
    db 112,109,105,102,99,96,93,89,86,83,80,77,74,70,67,64
    db 90,88,86,85,83,81,79,78,76,74,73,71,69,67,66,64
    db 64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64
    db 38,40,42,43,45,47,49,50,52,54,55,57,59,61,62,64
    db 16,19,23,26,29,32,35,39,42,45,48,51,54,58,61,64
    db 2,6,10,14,18,22,27,31,35,39,43,47,52,56,60,64
    db 0,1,6,10,14,19,24,28,32,37,42,46,50,55,60,64
    db 2,6,10,14,18,22,27,31,35,39,43,47,52,56,60,64
    db 16,19,23,26,29,32,35,39,42,45,48,51,54,58,61,64
    db 38,40,42,43,45,47,49,50,52,54,55,57,59,61,62,64

    ;; unsigned version
    ;; db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    ;; db 46,43,39,36,33,30,27,24,21,18,15,12,9,6,3,0
    ;; db 84,79,73,67,62,56,51,45,39,34,28,22,17,11,6,0
    ;; db 110,103,95,88,81,73,66,59,51,44,37,29,22,15,7,0
    ;; db 119,111,103,95,87,79,71,64,56,48,40,32,24,16,8,0
    ;; db 110,103,95,88,81,73,66,59,51,44,37,29,22,15,7,0
    ;; db 84,79,73,67,62,56,51,45,39,34,28,22,17,11,6,0
    ;; db 46,43,39,36,33,30,27,24,21,18,15,12,9,6,3,0
    ;; db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    ;; db 46,43,39,36,33,30,27,24,21,18,15,12,9,6,3,0
    ;; db 84,79,73,67,62,56,51,45,39,34,28,22,17,11,6,0
    ;; db 110,103,95,88,81,73,66,59,51,44,37,29,22,15,7,0
    ;; db 119,111,103,95,87,79,71,64,56,48,40,32,24,16,8,0
    ;; db 110,103,95,88,81,73,66,59,51,44,37,29,22,15,7,0
    ;; db 84,79,73,67,62,56,51,45,39,34,28,22,17,11,6,0
    ;; db 46,43,39,36,33,30,27,24,21,18,15,12,9,6,3,0


ENDIF


music_data
    include "music.asm"
