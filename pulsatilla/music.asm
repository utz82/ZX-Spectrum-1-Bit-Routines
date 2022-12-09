    ;; sequence

    dw .p0a
    dw .p09
    dw .p0b
    dw .p09
    dw .p07
    dw .p09
    dw .p08
    dw .p09
.seq_loop
    dw .p00
    dw .p01
    dw .p02
    dw .p03
    dw .p04
    dw .p01
    dw .p02
    dw .p03
    dw .p00
    dw .p01
    dw .p02
    dw .p03
    dw .p04
    dw .p01
    dw .p02
    dw .p03
    dw .p00
    dw .p01
    dw .p02
    dw .p03
    dw .p04
    dw .p01
    dw .p02
    dw .p03
    dw .p00
    dw .p01
    dw .p02
    dw .p03
    dw .p04
    dw .p01
    dw .p02
    dw .p03
    dw .p05
    dw .p01
    dw .p02
    dw .p03
    dw .p04
    dw .p01
    dw .p02
    dw .p03
    dw .p05
    dw .p01
    dw .p02
    dw .p03
    dw .p04
    dw .p01
    dw .p02
    dw .p03
    dw .p06
    dw .p01
    dw .p02
    dw .p03
    dw .p04
    dw .p01
    dw .p02
    dw .p03
    dw .p06
    dw .p01
    dw .p02
    dw .p03
    dw .p04
    dw .p01
    dw .p02
    dw .p03
    dw 0
    dw .seq_loop

    ;; ct0/t  dptr ct1/d1 note1 phase1 ct2/d2 note2 phase2 ct3/d3 note3 phase3 ct4/d4 note4 phase4
.p00
    dw #3bc5, .d00, #8045,   c2, #0000, #8045, dis3, #0000, #8045,   c3, #0000, #80c5,   c1, #0000
.p01
    dw #40c4,       #4040,              #4040:               db 1: dw dis3
.p02
    dw #3cc5, .d01, #2040,              #2040:               db 1: dw g3
.p03
    dw #40c4,       #1040,              #1040:               db 1: dw ais3
.p04
    dw #3ac5, .d00, #8044,       #0000, #8045, c3+2, #0000:  db 1: dw c3
.p05
    dw #3bc5, .d00, #8044,       #0000, #8045, c3+2, #0000:  db 1: dw c3:      db #81: dw f1
.p06
    dw #3bc5, .d00, #8044,       #0000, #8045, c3+2, #0000:  db 1: dw c3:      db #81: dw dis1
.p07
    dw #80c0,       #8045,   c2, #0000, #8045, dis3, #0000
.p08
    dw #8080,                           #8041,   f3
.p09
    dw #8000
.p0a
    dw #81c4,       #8045, c2+1, #0000, #80c5, c1+1, #0000, #8045, rest, #0000, #8045, rest, #0000
.p0b
    dw #80c0:        db 1:dw c2:       db #81: dw c3+1

.d00
    db #f0,#10,#02,#20,#00,#80,#01
.d01
    db #70,#80,#02,#20,#02,#00,#01
