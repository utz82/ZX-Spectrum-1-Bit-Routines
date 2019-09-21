;;; sequence
    dw _ptn0
    dw _ptn0
    dw _ptn0
    dw _ptn0
    dw _ptn1
    dw _ptn1
    dw _ptn1
    dw _ptn1
    dw _ptn2
    dw _ptn2
    dw _ptn2a
    dw _ptn2a
    dw _ptn2b
    dw _ptn2b
    dw _ptn2c
    dw _ptn2d
_loop
    dw _ptn3
    dw _ptn3x
    dw _ptn3a
    dw _ptn3a
    dw _ptn3b
    dw _ptn3bx
    dw _ptn3c
    dw _ptn3cx
    dw _ptn4
    dw _ptn4x
    dw _ptn4a
    dw _ptn4a
    dw _ptn4b
    dw _ptn4bx
    dw _ptn4c
    dw _ptn4d
    dw 0
    dw _loop

_ptn0
    dw #0400,    0,  a0,  a0,    0,   0,   0,   0,    0,    0
    dw #0484,#0fc0,  a0,  a0,                               0
    dw #0484,#0fe0,  a0,  a0,                               0
    dw #0484,#0fff,  a0,  a0,                               0
    dw #1880,#0fff,  a0,   0,    0,  a0,   0,               0

    dw #0480,    0,  a1,  a1,    0,   0,   0,               0
    dw #0484,#0fc0,  a1,  a1,                               0
    dw #0484,#0fe0,  a1,  a1,                               0
    dw #0484,#0fff,  a1,  a1,                               0
    dw #1880,#0fff,  a1,   0,    0,  a1,   0,               0

    dw #0480,    0,  e1,  e1,    0,   0,   0,               0
    dw #0484,#0fc0,  e1,  e1,                               0
    dw #0484,#0fe0,  e1,  e1,                               0
    dw #0284,#0ff0,  e1,  e1,                               0

    dw #0480,    0,  f1,  f1,    0,   0,   0,               0
    dw #0484,#0fc0,  f1,  f1,                               0
    dw #0484,#0fe0,  f1,  f1,                               0
    dw #0284,#0ff0,  f1,  f1,                               0

    db #40

_ptn1
    dw #0400,    0,  a0,  a0,    0,   0,   0,  a2,#fd0e,    0
    dw #0404,#0fc0,  a0,  a0,                  c3,#fd00,    0
    dw #0404,#0fe0,  a0,  a0,                  e3,#fd00,    0
    dw #0404,#0fff,  a0,  a0,                  g3,#fd00,    0
    dw #0400,#0fff,  a0,   0,    0,  a0,   0,  a3,#fd00,    0
    dw #0405,                                  c4,#fd00,    0
    dw #0405,                                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0

    dw #0400,    0,  a1,  a1,    0,   0,   0,  e3,#fd00,    0
    dw #0404,#0fc0,  a1,  a1,                  g3,#fd00,    0
    dw #0404,#0fe0,  a1,  a1,                  a3,#fd00,    0
    dw #0404,#0fff,  a1,  a1,                  c4,#fd00,    0
    dw #0400,#0fff,  a1,   0,    0,  a1,   0,  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0
    dw #0405,                                  e3,#fd00,    0
    dw #0405,                                  g3,#fd00,    0

    dw #0400,    0,  e1,  e1,    0,   0,   0,  a3,#fd00,    0
    dw #0404,#0fc0,  e1,  e1,                  c4,#fd00,    0
    dw #0304,#0fe0,  e1,  e1,                  e4,#fd00,    0
    dw #0204,#0ff0,  e1,  e1,                  g4,#fd00,    0

    dw #0284,    0,  f1,  f1,                               0
    dw #0404,    0,  f1,  f1,                  a2,#fd00,    0
    dw #0404,#0fe0,  f1,  f1,                  c3,#fd00,    0
    dw #0404,#0ff0,  f1,  f1,                  e3,#fd00,    0

    db #40

_ptn2
    dw #0400,    0,  a0,  a0,#1000,a2*3,  a2,  a2,#fd0e,    0
    dw #0404,#0fc0,  a0,  a0,                  c3,#fd00,    0
    dw #0404,#0fe0,  a0,  a0,                  e3,#fd00,    0
    dw #0404,#0fff,  a0,  a0,                  g3,#fd00,    0
    dw #0404,#0fff,  a0,   0,                  a3,#fd00,    0
    dw #0405,                                  c4,#fd00,    0
    dw #0405,                                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0

    dw #0404,    0,  a1,  a1,                  e3,#fd00,    0
    dw #0404,#0fc0,  a1,  a1,                  g3,#fd00,    0
    dw #0404,#0fe0,  a1,  a1,                  a3,#fd00,    0
    dw #0404,#0fff,  a1,  a1,                  c4,#fd00,    0
    dw #0404,#0fff,  a1,   0,                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0
    dw #0405,                                  e3,#fd00,    0
    dw #0405,                                  g3,#fd00,    0

    dw #0404,    0,  e1,  e1,                  a3,#fd00,    0
    dw #0404,#0fc0,  e1,  e1,                  c4,#fd00,    0
    dw #0404,#0fe0,  e1,  e1,                  e4,#fd00,    0
    dw #0204,#0ff0,  e1,  e1,                  g4,#fd00,    0

    dw #0284,    0,  f1,  f1,                               0
    dw #0404,    0,  f1,  f1,                  a2,#fd00,    0
    dw #0404,#0fe0,  f1,  f1,                  c3,#fd00,    0
    dw #0404,#0ff0,  f1,  f1,                  e3,#fd00,    0

    db #40

_ptn2a
    dw #0400,    0,  a0,  a0,#1000,g2*3,  g2,  a2,#fd0e,    0
    dw #0404,#0fc0,  a0,  a0,                  c3,#fd00,    0
    dw #0404,#0fe0,  a0,  a0,                  e3,#fd00,    0
    dw #0404,#0fff,  a0,  a0,                  g3,#fd00,    0
    dw #0404,#0fff,  a0,   0,                  a3,#fd00,    0
    dw #0405,                                  c4,#fd00,    0
    dw #0405,                                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0

    dw #0404,    0,  a1,  a1,                  e3,#fd00,    0
    dw #0404,#0fc0,  a1,  a1,                  g3,#fd00,    0
    dw #0404,#0fe0,  a1,  a1,                  a3,#fd00,    0
    dw #0404,#0fff,  a1,  a1,                  c4,#fd00,    0
    dw #0404,#0fff,  a1,   0,                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0
    dw #0405,                                  e3,#fd00,    0
    dw #0405,                                  g3,#fd00,    0

    dw #0404,    0,  e1,  e1,                  a3,#fd00,    0
    dw #0404,#0fc0,  e1,  e1,                  c4,#fd00,    0
    dw #0404,#0fe0,  e1,  e1,                  e4,#fd00,    0
    dw #0204,#0ff0,  e1,  e1,                  g4,#fd00,    0

    dw #0284,    0,  f1,  f1,                               0
    dw #0404,    0,  f1,  f1,                  a2,#fd00,    0
    dw #0404,#0fe0,  f1,  f1,                  c3,#fd00,    0
    dw #0404,#0ff0,  f1,  f1,                  e3,#fd00,    0

    db #40

_ptn2b
    dw #0400,    0,  a0,  a0,#1000,f2*3,  f2,  a2,#fd0e,    0
    dw #0404,#0fc0,  a0,  a0,                  c3,#fd00,    0
    dw #0404,#0fe0,  a0,  a0,                  e3,#fd00,    0
    dw #0404,#0fff,  a0,  a0,                  g3,#fd00,    0
    dw #0404,#0fff,  a0,   0,                  a3,#fd00,    0
    dw #0405,                                  c4,#fd00,    0
    dw #0405,                                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0

    dw #0404,    0,  a1,  a1,                  e3,#fd00,    0
    dw #0404,#0fc0,  a1,  a1,                  g3,#fd00,    0
    dw #0404,#0fe0,  a1,  a1,                  a3,#fd00,    0
    dw #0404,#0fff,  a1,  a1,                  c4,#fd00,    0
    dw #0404,#0fff,  a1,   0,                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0
    dw #0405,                                  e3,#fd00,    0
    dw #0405,                                  g3,#fd00,    0

    dw #0404,    0,  e1,  e1,                  a3,#fd00,    0
    dw #0404,#0fc0,  e1,  e1,                  c4,#fd00,    0
    dw #0404,#0fe0,  e1,  e1,                  e4,#fd00,    0
    dw #0204,#0ff0,  e1,  e1,                  g4,#fd00,    0

    dw #0284,    0,  f1,  f1,                               0
    dw #0404,    0,  f1,  f1,                  a2,#fd00,    0
    dw #0404,#0fe0,  f1,  f1,                  c3,#fd00,    0
    dw #0404,#0ff0,  f1,  f1,                  e3,#fd00,    0

    db #40

_ptn2c
    dw #0400,    0,  a0,  a0,#1000,e2*3,  e2,  a2,#fd0e,    0
    dw #0404,#0fc0,  a0,  a0,                  c3,#fd00,    0
    dw #0404,#0fe0,  a0,  a0,                  e3,#fd00,    0
    dw #0404,#0fff,  a0,  a0,                  g3,#fd00,    0
    dw #0404,#0fff,  a0,   0,                  a3,#fd00,    0
    dw #0405,                                  c4,#fd00,    0
    dw #0405,                                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0

    dw #0404,    0,  a1,  a1,                  e3,#fd00,    0
    dw #0404,#0fc0,  a1,  a1,                  g3,#fd00,    0
    dw #0404,#0fe0,  a1,  a1,                  a3,#fd00,    0
    dw #0404,#0fff,  a1,  a1,                  c4,#fd00,    0
    dw #0404,#0fff,  a1,   0,                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0
    dw #0405,                                  e3,#fd00,    0
    dw #0405,                                  g3,#fd00,    0

    dw #0404,    0,  e1,  e1,                  a3,#fd00,    0
    dw #0404,#0fc0,  e1,  e1,                  c4,#fd00,    0
    dw #0404,#0fe0,  e1,  e1,                  e4,#fd00,    0
    dw #0204,#0ff0,  e1,  e1,                  g4,#fd00,    0

    dw #0284,    0,  f1,  f1,                               0
    dw #0404,    0,  f1,  f1,                  a2,#fd00,    0
    dw #0404,#0fe0,  f1,  f1,                  c3,#fd00,    0
    dw #0404,#0ff0,  f1,  f1,                  e3,#fd00,    0

    db #40

_ptn2d
    dw #0400,    0,  a0,  a0,#1000,e2*3,  e2,  a2,#fd0e,    0
    dw #0404,#0fc0,  a0,  a0,                  c3,#fd00,    0
    dw #0404,#0fe0,  a0,  a0,                  e3,#fd00,    0
    dw #0404,#0fff,  a0,  a0,                  g3,#fd00,    0
    dw #0404,#0fff,  a0,   0,                  a3,#fd00,    0
    dw #0405,                                  c4,#fd00,    0
    dw #0405,                                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0

    dw #0404,    0,  a1,  a1,                  e3,#fd00,    0
    dw #0404,#0fc0,  a1,  a1,                  g3,#fd00,    0
    dw #0404,#0fe0,  a1,  a1,                  a3,#fd00,    0
    dw #0404,#0fff,  a1,  a1,                  c4,#fd00,    0
    dw #0404,#0fff,  a1,   0,                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0
    dw #0405,                                  e3,#fd00,    0
    dw #0405,                                  g3,#fd00,    0

    dw #0404,    0,  e1,  e1,                  a3,#fd00,    0
    dw #0404,#0fc0,  e1,  e1,                  c4,#fd00,#1001,kick
    dw #0404,#0fe0,  e1,  e1,                  e4,#fd00,#2001,kick
    dw #0204,#0ff0,  e1,  e1,                  g4,#fd00,#3001,kick

    dw #0284,    0,  f1,  f1,                               0
    dw #0404,    0,  f1,  f1,                  a2,#fd00,#4001,kick
    dw #0404,#0fe0,  f1,  f1,                  c3,#fd00,#5001,kick
    dw #0404,#0ff0,  f1,  f1,                  e3,#fd00,#6001,kick

    db #40

_ptn3
    dw #0400,    0,  a0,  a0,#1000,a2*3-1,  a2,  a2,#fd0e,#7002,kick
    dw #0404,#0fc0,  a0,  a0,                  c3,#fd00,    0
    dw #0404,#0fe0,  a0,  a0,                  e3,#fd00,    0
    dw #0404,#0fff,  a0,  a0,                  g3,#fd00,    0
    dw #0404,#0fff,  a0,   0,                  a3,#fd00,    0
    dw #0405,                                  c4,#fd00,    0
    dw #0405,                                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,#4002,noise
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0

    dw #0404,    0,  a1,  a1,                  e3,#fd00,#7002,kick
    dw #0404,#0fc0,  a1,  a1,                  g3,#fd00,    0
    dw #0404,#0fe0,  a1,  a1,                  a3,#fd00,    0
    dw #0404,#0fff,  a1,  a1,                  c4,#fd00,    0
    dw #0404,#0fff,  a1,   0,                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,#7002,kick
    dw #0405,                                  e3,#fd00,    0
    dw #0405,                                  g3,#fd00,    0

    dw #0404,    0,  e1,  e1,                  a3,#fd00,#4002,noise
    dw #0404,#0fc0,  e1,  e1,                  c4,#fd00,    0
    dw #0404,#0fe0,  e1,  e1,                  e4,#fd00,    0
    dw #0204,#0ff0,  e1,  e1,                  g4,#fd00,    0

    dw #0284,    0,  f1,  f1,                               0
    dw #0404,    0,  f1,  f1,                  a2,#fd00,    0
    dw #0404,#0fe0,  f1,  f1,                  c3,#fd00,    0
    dw #0404,#0ff0,  f1,  f1,                  e3,#fd00,    0

    db #40

_ptn3x
    dw #0400,    0,  a0,  a0,#1000,a2*3-1,  a2,  a2,#fd0e,#7002,kick
    dw #0404,#0fc0,  a0,  a0,                  c3,#fd00,    0
    dw #0404,#0fe0,  a0,  a0,                  e3,#fd00,    0
    dw #0404,#0fff,  a0,  a0,                  g3,#fd00,    0
    dw #0404,#0fff,  a0,   0,                  a3,#fd00,    0
    dw #0405,                                  c4,#fd00,    0
    dw #0405,                                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,#4002,noise
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0

    dw #0404,    0,  a1,  a1,                  e3,#fd00,#7002,kick
    dw #0404,#0fc0,  a1,  a1,                  g3,#fd00,    0
    dw #0404,#0fe0,  a1,  a1,                  a3,#fd00,    0
    dw #0404,#0fff,  a1,  a1,                  c4,#fd00,    0
    dw #0404,#0fff,  a1,   0,                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,#7002,kick
    dw #0405,                                  e3,#fd00,    0
    dw #0405,                                  g3,#fd00,    0

    dw #0404,    0,  e1,  e1,                  a3,#fd00,#4002,noise
    dw #0404,#0fc0,  e1,  e1,                  c4,#fd00,    0
    dw #0404,#0fe0,  e1,  e1,                  e4,#fd00,    0
    dw #0204,#0ff0,  e1,  e1,                  g4,#fd00,    0

    dw #0284,    0,  f1,  f1,                           #3002,noise
    dw #0404,    0,  f1,  f1,                  a2,#fd00,    0
    dw #0404,#0fe0,  f1,  f1,                  c3,#fd00,    0
    dw #0404,#0ff0,  f1,  f1,                  e3,#fd00,    0

    db #40

_ptn3a
    dw #0400,    0,  a0,  a0,#1000,g2*3-1,  g2,  a2,#fd0e,#7002,kick
    dw #0404,#0fc0,  a0,  a0,                  c3,#fd00,    0
    dw #0404,#0fe0,  a0,  a0,                  e3,#fd00,    0
    dw #0404,#0fff,  a0,  a0,                  g3,#fd00,    0
    dw #0404,#0fff,  a0,   0,                  a3,#fd00,    0
    dw #0405,                                  c4,#fd00,    0
    dw #0405,                                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,#4002,noise
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0

    dw #0404,    0,  a1,  a1,                  e3,#fd00,#7002,kick
    dw #0404,#0fc0,  a1,  a1,                  g3,#fd00,    0
    dw #0404,#0fe0,  a1,  a1,                  a3,#fd00,    0
    dw #0404,#0fff,  a1,  a1,                  c4,#fd00,    0
    dw #0404,#0fff,  a1,   0,                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,#7002,kick
    dw #0405,                                  e3,#fd00,    0
    dw #0405,                                  g3,#fd00,    0

    dw #0404,    0,  e1,  e1,                  a3,#fd00,#4002,noise
    dw #0404,#0fc0,  e1,  e1,                  c4,#fd00,    0
    dw #0404,#0fe0,  e1,  e1,                  e4,#fd00,    0
    dw #0204,#0ff0,  e1,  e1,                  g4,#fd00,    0

    dw #0284,    0,  f1,  f1,                               0
    dw #0404,    0,  f1,  f1,                  a2,#fd00,    0
    dw #0404,#0fe0,  f1,  f1,                  c3,#fd00,    0
    dw #0404,#0ff0,  f1,  f1,                  e3,#fd00,    0

    db #40

_ptn3ax
    dw #0400,    0,  a0,  a0,#1000,g2*3-1,  g2,  a2,#fd0e,#7002,kick
    dw #0404,#0fc0,  a0,  a0,                  c3,#fd00,    0
    dw #0404,#0fe0,  a0,  a0,                  e3,#fd00,    0
    dw #0404,#0fff,  a0,  a0,                  g3,#fd00,    0
    dw #0404,#0fff,  a0,   0,                  a3,#fd00,    0
    dw #0405,                                  c4,#fd00,    0
    dw #0405,                                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,#4002,noise
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0

    dw #0404,    0,  a1,  a1,                  e3,#fd00,#7002,kick
    dw #0404,#0fc0,  a1,  a1,                  g3,#fd00,    0
    dw #0404,#0fe0,  a1,  a1,                  a3,#fd00,    0
    dw #0404,#0fff,  a1,  a1,                  c4,#fd00,    0
    dw #0404,#0fff,  a1,   0,                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,#7002,kick
    dw #0405,                                  e3,#fd00,    0
    dw #0405,                                  g3,#fd00,    0

    dw #0404,    0,  e1,  e1,                  a3,#fd00,#4002,noise
    dw #0404,#0fc0,  e1,  e1,                  c4,#fd00,    0
    dw #0404,#0fe0,  e1,  e1,                  e4,#fd00,    0
    dw #0204,#0ff0,  e1,  e1,                  g4,#fd00,    0

    dw #0284,    0,  f1,  f1,                           #3002,noise
    dw #0404,    0,  f1,  f1,                  a2,#fd00,    0
    dw #0404,#0fe0,  f1,  f1,                  c3,#fd00,    0
    dw #0404,#0ff0,  f1,  f1,                  e3,#fd00,    0

    db #40

_ptn3b
    dw #0400,    0,  a0,  a0,#1000,f2*3-1,  f2,  a2,#fd0e,#7002,kick
    dw #0404,#0fc0,  a0,  a0,                  c3,#fd00,    0
    dw #0404,#0fe0,  a0,  a0,                  e3,#fd00,    0
    dw #0404,#0fff,  a0,  a0,                  g3,#fd00,    0
    dw #0404,#0fff,  a0,   0,                  a3,#fd00,    0
    dw #0405,                                  c4,#fd00,    0
    dw #0405,                                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,#4002,noise
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0

    dw #0404,    0,  a1,  a1,                  e3,#fd00,#7002,kick
    dw #0404,#0fc0,  a1,  a1,                  g3,#fd00,    0
    dw #0404,#0fe0,  a1,  a1,                  a3,#fd00,    0
    dw #0404,#0fff,  a1,  a1,                  c4,#fd00,    0
    dw #0404,#0fff,  a1,   0,                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,#7002,kick
    dw #0405,                                  e3,#fd00,    0
    dw #0405,                                  g3,#fd00,    0

    dw #0404,    0,  e1,  e1,                  a3,#fd00,#4002,noise
    dw #0404,#0fc0,  e1,  e1,                  c4,#fd00,    0
    dw #0404,#0fe0,  e1,  e1,                  e4,#fd00,    0
    dw #0204,#0ff0,  e1,  e1,                  g4,#fd00,    0

    dw #0284,    0,  f1,  f1,                               0
    dw #0404,    0,  f1,  f1,                  a2,#fd00,    0
    dw #0404,#0fe0,  f1,  f1,                  c3,#fd00,    0
    dw #0404,#0ff0,  f1,  f1,                  e3,#fd00,    0

    db #40

_ptn3bx
    dw #0400,    0,  a0,  a0,#1000,f2*3-1,  f2,  a2,#fd0e,#7002,kick
    dw #0404,#0fc0,  a0,  a0,                  c3,#fd00,    0
    dw #0404,#0fe0,  a0,  a0,                  e3,#fd00,    0
    dw #0404,#0fff,  a0,  a0,                  g3,#fd00,    0
    dw #0404,#0fff,  a0,   0,                  a3,#fd00,    0
    dw #0405,                                  c4,#fd00,    0
    dw #0405,                                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,#4002,noise
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0

    dw #0404,    0,  a1,  a1,                  e3,#fd00,#7002,kick
    dw #0404,#0fc0,  a1,  a1,                  g3,#fd00,    0
    dw #0404,#0fe0,  a1,  a1,                  a3,#fd00,    0
    dw #0404,#0fff,  a1,  a1,                  c4,#fd00,    0
    dw #0404,#0fff,  a1,   0,                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,#7002,kick
    dw #0405,                                  e3,#fd00,    0
    dw #0405,                                  g3,#fd00,    0

    dw #0404,    0,  e1,  e1,                  a3,#fd00,#4002,noise
    dw #0404,#0fc0,  e1,  e1,                  c4,#fd00,    0
    dw #0404,#0fe0,  e1,  e1,                  e4,#fd00,    0
    dw #0204,#0ff0,  e1,  e1,                  g4,#fd00,    0

    dw #0284,    0,  f1,  f1,                           #3002,noise
    dw #0404,    0,  f1,  f1,                  a2,#fd00,    0
    dw #0404,#0fe0,  f1,  f1,                  c3,#fd00,    0
    dw #0404,#0ff0,  f1,  f1,                  e3,#fd00,    0

    db #40

_ptn3c
    dw #0400,    0,  a0,  a0,#1000,e2*3-1,  e2,  a2,#fd0e,#7002,kick
    dw #0404,#0fc0,  a0,  a0,                  c3,#fd00,    0
    dw #0404,#0fe0,  a0,  a0,                  e3,#fd00,    0
    dw #0404,#0fff,  a0,  a0,                  g3,#fd00,    0
    dw #0404,#0fff,  a0,   0,                  a3,#fd00,    0
    dw #0405,                                  c4,#fd00,    0
    dw #0405,                                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,#4002,noise
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0

    dw #0404,    0,  a1,  a1,                  e3,#fd00,#7002,kick
    dw #0404,#0fc0,  a1,  a1,                  g3,#fd00,    0
    dw #0404,#0fe0,  a1,  a1,                  a3,#fd00,    0
    dw #0404,#0fff,  a1,  a1,                  c4,#fd00,    0
    dw #0404,#0fff,  a1,   0,                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,#7002,kick
    dw #0405,                                  e3,#fd00,    0
    dw #0405,                                  g3,#fd00,    0

    dw #0404,    0,  e1,  e1,                  a3,#fd00,#4002,noise
    dw #0404,#0fc0,  e1,  e1,                  c4,#fd00,    0
    dw #0404,#0fe0,  e1,  e1,                  e4,#fd00,    0
    dw #0204,#0ff0,  e1,  e1,                  g4,#fd00,    0

    dw #0284,    0,  f1,  f1,                               0
    dw #0404,    0,  f1,  f1,                  a2,#fd00,    0
    dw #0404,#0fe0,  f1,  f1,                  c3,#fd00,    0
    dw #0404,#0ff0,  f1,  f1,                  e3,#fd00,    0

    db #40

_ptn3cx
    dw #0400,    0,  a0,  a0,#1000,e2*3-1,  e2,  a2,#fd0e,#7002,kick
    dw #0404,#0fc0,  a0,  a0,                  c3,#fd00,    0
    dw #0404,#0fe0,  a0,  a0,                  e3,#fd00,    0
    dw #0404,#0fff,  a0,  a0,                  g3,#fd00,    0
    dw #0404,#0fff,  a0,   0,                  a3,#fd00,    0
    dw #0405,                                  c4,#fd00,    0
    dw #0405,                                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,#4002,noise
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0

    dw #0404,    0,  a1,  a1,                  e3,#fd00,#7002,kick
    dw #0404,#0fc0,  a1,  a1,                  g3,#fd00,    0
    dw #0404,#0fe0,  a1,  a1,                  a3,#fd00,    0
    dw #0404,#0fff,  a1,  a1,                  c4,#fd00,    0
    dw #0404,#0fff,  a1,   0,                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,#7002,kick
    dw #0405,                                  e3,#fd00,    0
    dw #0405,                                  g3,#fd00,    0

    dw #0404,    0,  e1,  e1,                  a3,#fd00,#4002,noise
    dw #0404,#0fc0,  e1,  e1,                  c4,#fd00,    0
    dw #0404,#0fe0,  e1,  e1,                  e4,#fd00,    0
    dw #0204,#0ff0,  e1,  e1,                  g4,#fd00,    0

    dw #0284,    0,  f1,  f1,                           #4002,noise
    dw #0404,    0,  f1,  f1,                  a2,#fd00,    0
    dw #0404,#0fe0,  f1,  f1,                  c3,#fd00,#4002,noise
    dw #0404,#0ff0,  f1,  f1,                  e3,#fd00,    0

    db #40

_ptn4
    dw #0400,    0,  a0,  a0,#1000,a2*3,  a2-1,a2,#fd0e,#7002,kick
    dw #0404,#0fc0,  a0,  a0,                  c3,#fd00,    0
    dw #0404,#0fe0,  a0,  a0,                  e3,#fd00,    0
    dw #0404,#0fff,  a0,  a0,                  g3,#fd00,    0
    dw #0404,#0fff,  a0,   0,                  a3,#fd00,    0
    dw #0405,                                  c4,#fd00,    0
    dw #0405,                                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,#4002,noise
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0

    dw #0404,    0,  a1,  a1,                  e3,#fd00,#7002,kick
    dw #0404,#0fc0,  a1,  a1,                  g3,#fd00,    0
    dw #0404,#0fe0,  a1,  a1,                  a3,#fd00,    0
    dw #0404,#0fff,  a1,  a1,                  c4,#fd00,    0
    dw #0404,#0fff,  a1,   0,                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,#7002,kick
    dw #0405,                                  e3,#fd00,    0
    dw #0405,                                  g3,#fd00,    0

    dw #0404,    0,  e1,  e1,                  a3,#fd00,#4002,noise
    dw #0404,#0fc0,  e1,  e1,                  c4,#fd00,    0
    dw #0404,#0fe0,  e1,  e1,                  e4,#fd00,    0
    dw #0204,#0ff0,  e1,  e1,                  g4,#fd00,    0

    dw #0284,    0,  f1,  f1,                               0
    dw #0404,    0,  f1,  f1,                  a2,#fd00,    0
    dw #0404,#0fe0,  f1,  f1,                  c3,#fd00,    0
    dw #0404,#0ff0,  f1,  f1,                  e3,#fd00,    0

    db #40

_ptn4x
    dw #0400,    0,  a0,  a0,#1000,a2*3,  a2-1,a2,#fd0e,#7002,kick
    dw #0404,#0fc0,  a0,  a0,                  c3,#fd00,    0
    dw #0404,#0fe0,  a0,  a0,                  e3,#fd00,    0
    dw #0404,#0fff,  a0,  a0,                  g3,#fd00,    0
    dw #0404,#0fff,  a0,   0,                  a3,#fd00,    0
    dw #0405,                                  c4,#fd00,    0
    dw #0405,                                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,#4002,noise
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0

    dw #0404,    0,  a1,  a1,                  e3,#fd00,#7002,kick
    dw #0404,#0fc0,  a1,  a1,                  g3,#fd00,    0
    dw #0404,#0fe0,  a1,  a1,                  a3,#fd00,    0
    dw #0404,#0fff,  a1,  a1,                  c4,#fd00,    0
    dw #0404,#0fff,  a1,   0,                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,#7002,kick
    dw #0405,                                  e3,#fd00,    0
    dw #0405,                                  g3,#fd00,    0

    dw #0404,    0,  e1,  e1,                  a3,#fd00,#4002,noise
    dw #0404,#0fc0,  e1,  e1,                  c4,#fd00,    0
    dw #0404,#0fe0,  e1,  e1,                  e4,#fd00,    0
    dw #0204,#0ff0,  e1,  e1,                  g4,#fd00,    0

    dw #0284,    0,  f1,  f1,                           #3002,noise
    dw #0404,    0,  f1,  f1,                  a2,#fd00,    0
    dw #0404,#0fe0,  f1,  f1,                  c3,#fd00,    0
    dw #0404,#0ff0,  f1,  f1,                  e3,#fd00,    0

    db #40

_ptn4a
    dw #0400,    0,  a0,  a0,#1000,g2*3,  g2-1,a2,#fd0e,#7002,kick
    dw #0404,#0fc0,  a0,  a0,                  c3,#fd00,    0
    dw #0404,#0fe0,  a0,  a0,                  e3,#fd00,    0
    dw #0404,#0fff,  a0,  a0,                  g3,#fd00,    0
    dw #0404,#0fff,  a0,   0,                  a3,#fd00,    0
    dw #0405,                                  c4,#fd00,    0
    dw #0405,                                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,#4002,noise
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0

    dw #0404,    0,  a1,  a1,                  e3,#fd00,#7002,kick
    dw #0404,#0fc0,  a1,  a1,                  g3,#fd00,    0
    dw #0404,#0fe0,  a1,  a1,                  a3,#fd00,    0
    dw #0404,#0fff,  a1,  a1,                  c4,#fd00,    0
    dw #0404,#0fff,  a1,   0,                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,#7002,kick
    dw #0405,                                  e3,#fd00,    0
    dw #0405,                                  g3,#fd00,    0

    dw #0404,    0,  e1,  e1,                  a3,#fd00,#4002,noise
    dw #0404,#0fc0,  e1,  e1,                  c4,#fd00,    0
    dw #0404,#0fe0,  e1,  e1,                  e4,#fd00,    0
    dw #0204,#0ff0,  e1,  e1,                  g4,#fd00,    0

    dw #0284,    0,  f1,  f1,                               0
    dw #0404,    0,  f1,  f1,                  a2,#fd00,    0
    dw #0404,#0fe0,  f1,  f1,                  c3,#fd00,    0
    dw #0404,#0ff0,  f1,  f1,                  e3,#fd00,    0

    db #40

_ptn4b
    dw #0400,    0,  a0,  a0,#1000,f3*3+1,  f2-1,a2,#fd0e,#7002,kick
    dw #0404,#0fc0,  a0,  a0,                  c3,#fd00,    0
    dw #0404,#0fe0,  a0,  a0,                  e3,#fd00,    0
    dw #0404,#0fff,  a0,  a0,                  g3,#fd00,    0
    dw #0404,#0fff,  a0,   0,                  a3,#fd00,    0
    dw #0405,                                  c4,#fd00,    0
    dw #0405,                                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,#4002,noise
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0

    dw #0404,    0,  a1,  a1,                  e3,#fd00,#7002,kick
    dw #0404,#0fc0,  a1,  a1,                  g3,#fd00,    0
    dw #0404,#0fe0,  a1,  a1,                  a3,#fd00,    0
    dw #0404,#0fff,  a1,  a1,                  c4,#fd00,    0
    dw #0404,#0fff,  a1,   0,                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,#7002,kick
    dw #0405,                                  e3,#fd00,    0
    dw #0405,                                  g3,#fd00,    0

    dw #0404,    0,  e1,  e1,                  a3,#fd00,#4002,noise
    dw #0404,#0fc0,  e1,  e1,                  c4,#fd00,    0
    dw #0404,#0fe0,  e1,  e1,                  e4,#fd00,    0
    dw #0204,#0ff0,  e1,  e1,                  g4,#fd00,    0

    dw #0284,    0,  f1,  f1,                               0
    dw #0404,    0,  f1,  f1,                  a2,#fd00,    0
    dw #0404,#0fe0,  f1,  f1,                  c3,#fd00,    0
    dw #0404,#0ff0,  f1,  f1,                  e3,#fd00,    0

    db #40

_ptn4bx
    dw #0400,    0,  a0,  a0,#1000,f3*3+1,  f2-1,a2,#fd0e,#7002,kick
    dw #0404,#0fc0,  a0,  a0,                  c3,#fd00,    0
    dw #0404,#0fe0,  a0,  a0,                  e3,#fd00,    0
    dw #0404,#0fff,  a0,  a0,                  g3,#fd00,    0
    dw #0404,#0fff,  a0,   0,                  a3,#fd00,    0
    dw #0405,                                  c4,#fd00,    0
    dw #0405,                                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,#4002,noise
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0

    dw #0404,    0,  a1,  a1,                  e3,#fd00,#7002,kick
    dw #0404,#0fc0,  a1,  a1,                  g3,#fd00,    0
    dw #0404,#0fe0,  a1,  a1,                  a3,#fd00,    0
    dw #0404,#0fff,  a1,  a1,                  c4,#fd00,    0
    dw #0404,#0fff,  a1,   0,                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,#7002,kick
    dw #0405,                                  e3,#fd00,    0
    dw #0405,                                  g3,#fd00,    0

    dw #0404,    0,  e1,  e1,                  a3,#fd00,#4002,noise
    dw #0404,#0fc0,  e1,  e1,                  c4,#fd00,    0
    dw #0404,#0fe0,  e1,  e1,                  e4,#fd00,    0
    dw #0204,#0ff0,  e1,  e1,                  g4,#fd00,    0

    dw #0284,    0,  f1,  f1,                           #3002,noise
    dw #0404,    0,  f1,  f1,                  a2,#fd00,    0
    dw #0404,#0fe0,  f1,  f1,                  c3,#fd00,    0
    dw #0404,#0ff0,  f1,  f1,                  e3,#fd00,    0

    db #40

_ptn4c
    dw #0400,    0,  a0,  a0,#1000,e2*3,  e2-1,a2,#fd0e,#7002,kick
    dw #0404,#0fc0,  a0,  a0,                  c3,#fd00,    0
    dw #0404,#0fe0,  a0,  a0,                  e3,#fd00,    0
    dw #0404,#0fff,  a0,  a0,                  g3,#fd00,    0
    dw #0404,#0fff,  a0,   0,                  a3,#fd00,    0
    dw #0405,                                  c4,#fd00,    0
    dw #0405,                                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,#4002,noise
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0

    dw #0404,    0,  a1,  a1,                  e3,#fd00,#7002,kick
    dw #0404,#0fc0,  a1,  a1,                  g3,#fd00,    0
    dw #0404,#0fe0,  a1,  a1,                  a3,#fd00,    0
    dw #0404,#0fff,  a1,  a1,                  c4,#fd00,    0
    dw #0404,#0fff,  a1,   0,                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,#7002,kick
    dw #0405,                                  e3,#fd00,    0
    dw #0405,                                  g3,#fd00,    0

    dw #0404,    0,  e1,  e1,                  a3,#fd00,#4002,noise
    dw #0404,#0fc0,  e1,  e1,                  c4,#fd00,    0
    dw #0404,#0fe0,  e1,  e1,                  e4,#fd00,    0
    dw #0204,#0ff0,  e1,  e1,                  g4,#fd00,    0

    dw #0284,    0,  f1,  f1,                               0
    dw #0404,    0,  f1,  f1,                  a2,#fd00,    0
    dw #0404,#0fe0,  f1,  f1,                  c3,#fd00,    0
    dw #0404,#0ff0,  f1,  f1,                  e3,#fd00,    0

    db #40

_ptn4d
    dw #0400,    0,  a0,  a0,#1000,e2*3,  e2-1,a2,#fd0e,#7002,kick
    dw #0404,#0fc0,  a0,  a0,                  c3,#fd00,    0
    dw #0404,#0fe0,  a0,  a0,                  e3,#fd00,    0
    dw #0404,#0fff,  a0,  a0,                  g3,#fd00,    0
    dw #0404,#0fff,  a0,   0,                  a3,#fd00,    0
    dw #0405,                                  c4,#fd00,    0
    dw #0405,                                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,#4002,noise
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,    0

    dw #0404,    0,  a1,  a1,                  e3,#fd00,#7002,kick
    dw #0404,#0fc0,  a1,  a1,                  g3,#fd00,    0
    dw #0404,#0fe0,  a1,  a1,                  a3,#fd00,    0
    dw #0404,#0fff,  a1,  a1,                  c4,#fd00,    0
    dw #0404,#0fff,  a1,   0,                  e4,#fd00,    0
    dw #0405,                                  g4,#fd00,    0
    dw #0405,                                  a2,#fd00,    0
    dw #0405,                                  c3,#fd00,#7002,kick
    dw #0405,                                  e3,#fd00,    0
    dw #0405,                                  g3,#fd00,    0

    dw #0400,    0,  e1,  e1,#1000,c3*3,  c3,  a3,#fd00,#4002,noise
    dw #0404,#0fc0,  e1,  e1,                  c4,#fd00,    0
    dw #0404,#0fe0,  e1,  e1,                  e4,#fd00,    0
    dw #0204,#0ff0,  e1,  e1,                  g4,#fd00,    0

    dw #0284,    0,  f1,  f1,                               0
    dw #0404,    0,  f1,  f1,                  a2,#fd00,#2002,kick
    dw #0404,#0fe0,  f1,  f1,                  c3,#fd00,#4002,kick
    dw #0404,#0ff0,  f1,  f1,                  e3,#fd00,#5002,kick

    db #40



kick
    include "kick1.asm"

noise
    include "noise.asm"
