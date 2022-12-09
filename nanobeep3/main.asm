;;; nanobeep3 - 54 byte beeper engine for ZX Spectrum
;;; by utz 11'2022 * irrlichtproject.de

    device zxspectrum48
    org #8000

    include "note_names.h"

nanobeep3_init
    di
    ld hl,music_data.pend-1
    ld bc,1
    exx
    push hl
    ld (.old_sp),sp
    ld sp,music_data

    jr .read_sequence

.read_keys
    in a,(#fe)
    rra
    jr nc,.exit

.play
    exx                         ; 4
    ld a,(hl)                   ; 7
    add a,e                     ; 4
    ld e,a                      ; 4
    adc a,d                     ; 4
    sub e                       ; 4
    ld d,a                      ; 4
    out (#fe),a                 ;11

    dec bc                      ; 6
    ld a,b                      ; 4
    or c                        ; 4
    jr nz,.play                 ;12..68

.read_pattern
    inc hl                      ; read next pattern byte (length)
    ld b,(hl)                   ; if it's #ff, end of pattern is reached
    inc hl                      ; point to note byte
    inc b
    jr nz,.read_keys

.read_sequence
    pop hl
    inc h
    jr nz,.read_pattern+1

.exit
.old_sp = $+1
    ld sp,0
    pop hl
    exx
    ei
    ret

    display $-nanobeep3_init

music_data
    include "music.asm"

end
    savetap "main.tap",CODE,"main",nanobeep3_init,end-nanobeep3_init
