;;; sequence
    dw _ptn0
    dw _ptn0
    dw _ptn1
    dw _ptn2
_loop
    dw _ptn3
    dw _ptn3a
    dw _ptn4
    dw _ptn5
    dw _ptn3
    dw _ptn3a
    dw _ptn4
    dw _ptn5a
    dw 0
    dw _loop

;;; patterns
;;; byte 0: step length << 8 | control bits
;;; byte 1: noise envelope pointer
;;; byte 2: frequency divider ch1
;;; byte 3: frequency divider ch2
;;; control bits enabled:
;;; 0: skip noise envelope
;;; 2: skip ch1
;;; 6: end of pattern marker
;;; 7: skip ch2 update
;;; control bits 2
;;; 0: adjust row length for half-speed
;;; 2: noise drum
;;; 6: skip ch3 update
;;; 7: kick drum, params follow

_ptn0
    dw #0000,_noise_env,_tone_env1,c1,_tone_env2,dis2,#1781,_noise_env0,0,#0370,#1f0f,EXPONENTIAL_DECAY
    dw #0081,_tone_env1,c2,#1840
    dw #0081,_tone_env1,c3,#1840
    dw #0081,_tone_env1,c2,#0640
    dw #0085,#03c1,#0110,#1f0f,EXPONENTIAL_DECAY
    dw #0085,#03c1,#0120,#1f0f,EXPONENTIAL_DECAY
    dw #0085,#03c1,#0130,#1f0f,EXPONENTIAL_DECAY
    dw #0085,#03c1,#0140,#1f0f,EXPONENTIAL_DECAY
    dw #0085,#03c1,#0150,#1f0f,EXPONENTIAL_DECAY
    dw #0085,#03c1,#0160,#1f0f,EXPONENTIAL_DECAY
    db #40

_ptn1
    dw #0000,_noise_env,_tone_env1,f1,_tone_env2,gis2,#17c1,#0370,#1f0f,EXPONENTIAL_DECAY
    dw #0080,_noise_env0,_tone_env1,f2,#1840
    dw #0080,_noise_env,_tone_env1,f3,#1840
    dw #0080,_noise_env0,_tone_env1,f2,#1840
    db #0040

_ptn2
    dw #0000,_noise_env,_tone_env1,dis1,_tone_env2,g2,#17c1,#0370,#1f0f,EXPONENTIAL_DECAY
    dw #0080,_noise_env0,_tone_env1,dis2,#1840
    dw #0080,_noise_env,_tone_env1,dis3,#1840
    dw #0080,_noise_env0,_tone_env1,dis2,#1840
    db #0040

_ptn3
    dw #0000,_noise_env,_tone_env1,c1,_tone_env2,dis2,#0b81,_tone_env3,c3,#0370,#1f0f,EXPONENTIAL_DECAY
    dw #0085,#0c00,_tone_env3,dis3
    dw #0081,_tone_env1,c2,#0c00,_tone_env3,f3
    dw #0085,#0c00,_tone_env3,g3
    dw #0081,_tone_env1,c3,#0c00,_tone_env3,ais3
    dw #0085,#0c00,_tone_env3,g3
    dw #0080,_noise_env0,_tone_env1,c2,#0c00,_tone_env3,f3
    dw #0085,#0c00,_tone_env3,dis3
    db #0040

_ptn3a
    dw #0000,_noise_env,_tone_env1,c1,_tone_env2,dis2,#0b81,_tone_env3,c3,#0370,#1f0f,EXPONENTIAL_DECAY
    dw #0085,#0c00,_tone_env3,dis3
    dw #0080,_noise_env0,_tone_env1,c2,#0c00,_tone_env3,f3
    dw #0085,#0c00,_tone_env3,g3
    dw #0081,_tone_env1,c3,#0c00,_tone_env3,ais3
    dw #0085,#0c00,_tone_env3,c4
    dw #0080,_noise_env,_tone_env1,c2,#0b80,_tone_env3,dis4,#0250,#1f0f,EXPONENTIAL_DECAY
    dw #0085,#0b80,_tone_env3,f4,#0250,#1f0f,EXPONENTIAL_DECAY
    db #0040

_ptn4
    dw #0000,_noise_env,_tone_env1,f1,_tone_env2,gis2,#0b81,_tone_env3,f3,#0370,#1f0f,EXPONENTIAL_DECAY
    dw #0085,#0c00,_tone_env3,gis3
    dw #0081,_tone_env1,f2,#0c00,_tone_env3,ais3
    dw #0085,#0c00,_tone_env3,c4
    dw #0081,_tone_env1,f3,#0c00,_tone_env3,dis4
    dw #0085,#0c00,_tone_env3,c4
    dw #0080,_noise_env0,_tone_env1,f2,#0c00,_tone_env3,ais3
    dw #0085,#0c00,_tone_env3,gis3
    db #0040

_ptn5
    dw #0000,_noise_env,_tone_env1,dis1,_tone_env2,g2,#0b81,_tone_env3,dis3,#0370,#1f0f,EXPONENTIAL_DECAY
    dw #0085,#0c00,_tone_env3,f3
    dw #0080,_noise_env0,_tone_env1,dis2,#0c00,_tone_env3,g3
    dw #0085,#0c00,_tone_env3,ais3
    dw #0080,_noise_env,_tone_env1,dis3,#0c00,_tone_env3,dis4
    dw #0085,#0c00,_tone_env3,ais3
    dw #0080,_noise_env0,_tone_env1,dis2,#0b80,_tone_env3,g3,#0250,#1f0f,EXPONENTIAL_DECAY
    dw #0085,#0b80,_tone_env3,f3,#0250,#1f0f,EXPONENTIAL_DECAY
    db #0040

_ptn5a
    dw #0000,_noise_env,_tone_env1,dis2,_tone_env2,g3,#0b81,_tone_env3,dis4,#0370,#1f0f,EXPONENTIAL_DECAY
    dw #0085,#0c00,_tone_env3,f4
    dw #0080,_noise_env0,_tone_env1,dis3,#0c00,_tone_env3,g4
    dw #0085,#0c00,_tone_env3,ais4
    dw #0080,_noise_env,_tone_env1,dis4,#0c00,_tone_env3,dis5
    dw #0085,#0c00,_tone_env3,ais4
    dw #0080,_noise_env0,_tone_env1,dis3,#0600,_tone_env3,g4
    dw #0085,#03c1,#0110,#1f0f,EXPONENTIAL_DECAY
    dw #0085,#03c1,#0120,#1f0f,EXPONENTIAL_DECAY
    dw #0085,#0381,_tone_env3,f4,#0130,#1f0f,EXPONENTIAL_DECAY
    dw #0085,#03c1,#0140,#1f0f,EXPONENTIAL_DECAY
    dw #0085,#03c1,#0150,#1f0f,EXPONENTIAL_DECAY
    dw #0085,#03c1,#0160,#1f0f,EXPONENTIAL_DECAY
    db #0040


;;; envelopes
_noise_env
    db #20,#20,#20,#20
    db #10,#10,#10,#10
    db 8,8,8,8,8,8,8,8,8,8
    db 4,4,4,4,4,4,4,4,4,4,4
    db 2,2,2,2,2,2,2,2,2,2,2,2,2,2
    db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
_noise_env0
    db 0

_tone_env1
    db 8,8,6,6,4,4,4,4
    db 3,3,3,3,2,2,2,2
    db 2,2,2,2,2,2,2,2
    db 2,2,2,1,1,1,1,1,1,0

_tone_env2
    db 1,1,1,1,1,1,1,1,1,1,1,1,1,1
    db 2,2,2,2,2,2,2,2,2,2,2,2,2,2
    db 3,3,3,3,3,3,3,3,3,3,3,3,3,3
    db 4,4,4,4,4,4,4,4,4,4,4,4,4,4
    db 3,3,3,3,3,3,3,3,3,3,3,3,3,3
    db 2,2,2,2,2,2,2,2,2,2,2,2,2,2
    db 1,1,1,1,1,1,1,1,1,1,1,1,1,1
    db 0

_tone_env3
    db 4,4,3,3,2,2,2,2
    db 1,1,1,1,1,1,1,1,0
