; vim: filetype=z80:

    include "notes.inc"

; sequence
sequence_loop
    dw pattern1
    dw pattern1a
    dw pattern2
    dw pattern2
    dw pattern1
    dw pattern1a
    dw pattern2
    dw pattern2
    dw pattern0
    dw pattern0
    dw pattern3
    dw 0
    dw sequence_loop

pattern3
    dw #6000,chB_ks_saw,a1,chA_ks_saw,a1
    dw #6000,chB_mute,chA_mute
    db #40

pattern1
    dw #0200,chB_pwm,pwm_kick,#ff00,chA_ks_noise,#ff00,c3
    dw #0a80,chB_ks_noise,#af00,c1
    dw #0c01,chA_ks_noise,#ff00,c2
    dw #0c00,chB_ks_noise,#af00,c1,chA_ks_noise,#ff00,g2
    dw #0c01,chA_ks_noise,#ff00,c2
    dw #0c00,chB_ks_noise,#af00,c1,chA_ks_noise,#ff00,f2
    dw #0c01,chA_ks_noise,#ff00,c2
    dw #0c00,chB_ks_noise,#af00,c1,chA_ks_noise,#ff00,g2
    dw #0c01,chA_ks_noise,#ff00,c2
    dw #0c00,chB_ks_noise,#af00,c1,chA_ks_noise,#ff00,c3
    dw #0c01,chA_ks_noise,#ff00,c2
    dw #0c00,chB_ks_noise,#af00,c1,chA_ks_noise,#ff00,g2
    dw #0c01,chA_ks_noise,#ff00,c2
    dw #0c00,chB_ks_noise,#af00,c1,chA_ks_noise,#ff00,f2
    dw #0c01,chA_ks_noise,#ff00,c2
    dw #0200,chB_pwm,pwm_kick,#ff00,chA_ks_noise,#ff00,g2
    dw #0a80,chB_ks_noise,#af00,c1
    dw #0c01,chA_ks_noise,#ff00,c2
    db #40

pattern1a
    dw #0200,chB_pwm,pwm_noise,#ff00,chA_ks_noise,#ff00,c3
    dw #0a80,chB_ks_noise,#af00,c1
    dw #0c01,chA_ks_noise,#ff00,c2
    dw #0c00,chB_ks_noise,#af00,c1,chA_ks_noise,#ff00,g2
    dw #0c01,chA_ks_noise,#ff00,c2
    dw #0c00,chB_ks_noise,#af00,c1,chA_ks_noise,#ff00,f2
    dw #0c01,chA_ks_noise,#ff00,c2
    dw #0c00,chB_ks_noise,#af00,c1,chA_ks_noise,#ff00,g2
    dw #0c01,chA_ks_noise,#ff00,c2
    dw #0c00,chB_ks_noise,#af00,c1,chA_ks_noise,#ff00,c3
    dw #0c01,chA_ks_noise,#ff00,c2
    dw #0c00,chB_ks_noise,#af00,c1,chA_ks_noise,#ff00,g2
    dw #0c01,chA_ks_noise,#ff00,c2
    dw #0c00,chB_ks_noise,#af00,c1,chA_ks_noise,#ff00,f2
    dw #0c01,chA_ks_noise,#ff00,c2
    dw #0200,chB_pwm,pwm_noise,#ff00,chA_ks_noise,#ff00,g2
    dw #0a80,chB_ks_noise,#af00,c1
    dw #0280,chB_pwm,pwm_noise,#ff00
    dw #0a80,chB_ks_noise,#af00,c2
    db #40

pattern2
    dw #0200,chB_pwm,pwm_kick,#ff00,chA_ks_noise,#ff00,c3
    dw #0a80,chB_ks_noise,#af00,a1
    dw #0c01,chA_ks_noise,#ff00,c2
    dw #0c00,chB_ks_noise,#af00,a1,chA_ks_noise,#ff00,g2
    dw #0c01,chA_ks_noise,#ff00,c2
    dw #0c00,chB_ks_noise,#af00,a1,chA_ks_noise,#ff00,e2
    dw #0c01,chA_ks_noise,#ff00,c2
    dw #0c00,chB_ks_noise,#af00,a1,chA_ks_noise,#ff00,g2
    dw #0c01,chA_ks_noise,#ff00,c2
    dw #0c00,chB_ks_noise,#af00,a1,chA_ks_noise,#ff00,c3
    dw #0c01,chA_ks_noise,#ff00,c2
    dw #0c00,chB_ks_noise,#af00,a1,chA_ks_noise,#ff00,g2
    dw #0c01,chA_ks_noise,#ff00,c2
    dw #0c00,chB_ks_noise,#af00,a1,chA_ks_noise,#ff00,e2
    dw #0c01,chA_ks_noise,#ff00,c2
    dw #0c00,chB_ks_noise,#af00,a1,chA_ks_noise,#ff00,g2
    dw #0c01,chA_ks_noise,#ff00,c2
    db #40

pattern0
    dw #0200,chB_pwm,pwm_kick,#ff00,chA_ks_rect,#ff00,a2+((a2/2)<<8)
    dw #1080,chB_ks_rect,#af00,a1+((a1/2)<<8)
    dw #0680,chB_ks_rect,#af00,e1+((e1/2)<<8)
    dw #1280,chB_ks_rect,#af00,a1+((a1/4)<<8)
    dw #0680,chB_ks_rect,#af00,e1+((e1/2)<<8)
    dw #1280,chB_ks_rect,#af00,a1+((a1/4)<<8)
    dw #0280,chB_pwm,pwm_kick,#ff00
    dw #0480,chB_ks_rect,#af00,e1+((e1/4)<<8)
    dw #0200,chB_pwm,pwm_noise,#ff00,chA_ks_rect,#af00,e3+((e3/2)<<8)
    dw #1080,chB_ks_rect,#af00,a1+((a1/2)<<8)
    dw #0680,chB_ks_rect,#af00,e1+((e1/4)<<8)

    dw #0200,chB_pwm,pwm_kick,#ff00,chA_ks_rect,#ff00,dis3+((dis3/2)<<8)
    dw #1080,chB_ks_rect,#af00,a1+((a1/2)<<8)
    dw #0680,chB_ks_rect,#af00,e1+((e1/2)<<8)
    dw #1080,chB_ks_rect,#af00,a1+((a1/4)<<8)
    dw #0680,chB_ks_rect,#af00,e1+((e1/2)<<8)
    dw #0280,chB_pwm,pwm_kick,#ff00
    dw #1080,chB_ks_rect,#af00,a1+((a1/4)<<8)
    dw #0680,chB_ks_rect,#af00,e1+((e1/4)<<8)
    dw #0200,chB_pwm,pwm_noise,#ff00,chA_ks_rect,#af00,b2+((b2/2)<<8)
    dw #1080,chB_ks_rect,#af00,a1+((a1/2)<<8)
    dw #0680,chB_ks_rect,#af00,e1+((e1/4)<<8)

    dw #0200,chB_pwm,pwm_kick,#ff00,chA_ks_rect,#ff00,c3+((c3/2)<<8)
    dw #1080,chB_ks_rect,#af00,c2+((c2/16)<<8)
    dw #0680,chB_ks_rect,#af00,c1+((c1/16)<<8)
    dw #0280,chB_pwm,pwm_kick,#ff00
    dw #1080,chB_ks_rect,#af00,c2+((c2/16)<<8)
    dw #0680,chB_ks_rect,#af00,c1+((c1/16)<<8)
    dw #0280,chB_pwm,pwm_noise,#ff00
    dw #1080,chB_ks_rect,#af00,c2+((c2/8)<<8)
    dw #0680,chB_ks_rect,#af00,c1+((c1/8)<<8)
    dw #0280,chB_pwm,pwm_kick,#ff00
    dw #1080,chB_ks_rect,#af00,c2+((c2/8)<<8)
    dw #0680,chB_ks_rect,#af00,c1+((c1/8)<<8)
    
    dw #0280,chB_pwm,pwm_kick,#ff00
    dw #1080,chB_ks_rect,#af00,c2+((c2/4)<<8)
    dw #0680,chB_ks_rect,#af00,c1+((c1/4)<<8)
    dw #0280,chB_pwm,pwm_kick,#ff00
    dw #1080,chB_ks_rect,#af00,c2+((c2/4)<<8)
    dw #0680,chB_ks_rect,#af00,c1+((c1/4)<<8)
    dw #0200,chB_pwm,pwm_noise,#ff00,chA_ks_rect,#af00,ais2+((ais2/2)<<8)
    dw #1080,chB_ks_rect,#af00,c2+((c2/16)<<8)
    dw #0680,chB_ks_rect,#af00,c1+((c1/2)<<8)
    dw #0280,chB_pwm,pwm_kick,#ff00
    dw #1080,chB_ks_rect,#af00,c2+((c2/2)<<8)
    dw #0680,chB_ks_rect,#af00,c1+((c1/2)<<8)
    db #40

pwm_noise
    db 2,18,3,4,9,1,22,10,3,4,7,2,21,8,17,10,3,2,8,1,9,3,14,8,7,11,23,4
    db 7,1,4,11,6,2,8,13,2,11,7,18,4,9,5,2,3,11,0
pwm_kick
    db 8,8,8,8,8,8
    db #10,#10,#10,#10,#10,#10
    db #20,#20,#20,#20,#20,#20
    db #40,#40,#40,#40,#40,#40
    db #80,#80,#80,#80
    db #ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff
    db 0
