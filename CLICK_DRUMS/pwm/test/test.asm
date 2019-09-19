;;; test code

    org #8000

    di

    ld hl,test_sample
    push hl
    ld hl,#f020
    push hl
    jp pwm_init

DRUM_RETURN_ADDRESS
    ei
    ret

drum_player
    include "../drum.asm"

test_sample
    include "kick1.asm"
    ;; include "noise.asm"
