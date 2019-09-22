;;; test code

    org #8000

    di

    ld hl,LINEAR_DECAY_X2
    push hl
    ld hl,#1f0f                 ; sweep_speed|initial_pitch<<8
    push hl
    ld hl,#4070                 ; volume|length<<8
    push hl

    jp kick_drum_init

DRUM_RETURN_ADDRESS
    ei
    ret

drum_player
    include "../kick.asm"
