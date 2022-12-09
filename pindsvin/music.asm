    ;; sequence

    dw .in00
    dw .in00a
    dw .in01
    dw .in01a
    dw .in02
    dw .in02a
    dw .in03
    dw .in03a
.loop
    dw .p00
    dw .p01
    dw .p00a
    dw .p01
    dw .p00a
    dw .p01
    dw .p00b
    dw .p01
    dw .p02
    dw .p01
    dw .p00a
    dw .p01
    dw .p00a
    dw .p01
    dw .p00b
    dw .p01
    dw .p03
    dw .p01
    dw .p00a
    dw .p01
    dw .p00a
    dw .p01
    dw .p00b
    dw .p01
    dw .p04
    dw .p01
    dw .p00a
    dw .p01
    dw .p00a
    dw .p01
    dw .p00b
    dw .p01
    dw 0
    dw .loop

.p00
    dw #3cc5,#f004,.d00: db 2: dw g2: db 2: dw ais2: db 2: dw c3
    dw #a9c5: db #10: dw c1: db #10: dw c1+1, 0, 0
.p00a
    dw #3c80,#f004,.d00
    db 0
.p00b
    dw #3c84,#f004,.d00: db 2: dw g3
    db 0
.p01
    dw #3c80,#f004,.d01
    db 0
.p02
    dw #3cc4,#f004,.d00: db 2: dw f2: db 2: dw ais2
    db 0
.p03
    dw #3cc4,#f004,.d00: db 2: dw ais2: db 2: dw c3
    dw #b145: db #10: dw ais0: db #10: dw ais0+1
.p04
    dw #3cc4,#f004,.d00: db 2: dw f2: db 2: dw ais2
    dw #b141: db #10: dw g1

.in00
    dw #0845: db 0: dw 0: db 0: dw 0: db 2: dw g2
    dw #b1c5: db 0: dw 0: db 0: dw 0,0,0

.in00a
    dw #1804: db 1: dw g2
    db 0

.in01
    dw #0840: db 2: dw ais2
    db 0

.in01a
    dw #1840: db 1: dw ais2
    db 0

.in02
    dw #0801: db 2: dw c3
    db 0

.in02a
    dw #1801: db 1: dw c3
    db 0

.in03
    dw #0804: db 2: dw g3
    db 0

.in03a
    dw #1804: db 1: dw g3
    db 0

.d00
    include "kick1.asm"
.d01
    include "hh1.asm"
