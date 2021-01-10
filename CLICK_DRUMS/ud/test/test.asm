;;; test code

    org #8000


    di
init
    ld sp,td
    ld b,1+((td_end-td)/2)

DRUM_RETURN_ADDRESS
    dec b
    jr z,init
    jr wait
endwait

    jp ud_init


drum1
    db #f0,#00,#01,#40,#00,#00,#03

drum3
    db #b0,#40,#01,#40,#04,#00,#03

drum2
    db #00,#f0,#00,#00,#01,#00,#03

drum3a
    db #60,#90,#04,#40,#04,#00,#03

drum3b
    db #40,#70,#04,#40,#04,#00,#03

drum3c
    db #20,#50,#04,#40,#04,#00,#03

drum3d
    db #10,#30,#04,#40,#04,#00,#03


wait
    ld de,0
_lp
    dec de
    ld a,d
    or e
    jr nz,_lp
    jr endwait

drum_player
    include "../ud.asm"


td
    dw drum1
    dw drum3
    dw drum2
    dw drum3
    dw drum3a
    dw drum3b
    dw drum3c
    dw drum3d
td_end
