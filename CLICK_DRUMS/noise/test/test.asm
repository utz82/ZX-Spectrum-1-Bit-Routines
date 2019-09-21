;;; test code

    org #8000

    di

    ld hl,#4001                 ; pitch|length<<8
    push hl
    ld hl,#3000                 ; volume<<8
    push hl

    jp noise_init

DRUM_RETURN_ADDRESS
    ei
    ret

drum_player
    include "../noise.asm"
