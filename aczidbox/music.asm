    ;; seq


    dw ptn0
    dw ptn0s
    dw ptn0
    dw ptn0s
    dw ptn1
    dw ptn1s
    dw ptn1
    dw ptn1s
    dw ptn2
    dw ptn2s
    dw ptn2
    dw ptn2s
    dw ptn3
    dw ptn3s
    dw ptn3
    dw ptn3s
loop_ptr
    dw ptn0a
    dw ptn00s
    dw ptn00
    dw ptn00s
    dw ptn1
    dw ptn1s
    dw ptn1
    dw ptn1s
    dw ptn2
    dw ptn2s
    dw ptn2
    dw ptn2s
    dw ptn3
    dw ptn3s
    dw ptn3
    dw ptn3s

    dw ptn0b
    dw ptn00s
    dw ptn00
    dw ptn00s
    dw ptn1
    dw ptn1s
    dw ptn1
    dw ptn1s
    dw ptn2b
    dw ptn2s
    dw ptn2
    dw ptn2s
    dw ptn3
    dw ptn3s
    dw ptn3
    dw ptn3b

    dw 0
    dw loop_ptr

kick1
    dw #140, #1013, LINEAR_DECAY

kick2
    dw #7003, kick2_data
kick2_data
    include "kick1.asm"

sd1
    dw #3002, sd1_data
sd1_data
    include "noise.asm"

sn1
    dw #3030,#201


ptn0
    dw #805, kick1, #4000, #10, c3, 0-#80, #000, #00, #00
    dw #380, #40, c4, 0-#200
    dw #180, #00, #000, #000
    dw #380, #40, c4, 0-#200
    dw #180, #00, #000, #000
    db #40

ptn0s
    dw #884, sd1, #8000, #10, c3, 0-#80, #000, #00, #00
    dw #380, #40, c4, 0-#200
    dw #180, #00, #000, #000
    dw #380, #40, c4, 0-#200
    dw #180, #00, #000, #000
    db #40


ptn00
    dw #805, kick1, #c080, #10, c3, 0-#80
    dw #380, #40, c4, 0-#200
    dw #180, #00, #000, #000
    dw #380, #40, c4, 0-#200
    dw #180, #00, #000, #000
    db #40

ptn00s
    dw #804, sn1, #8080, #10, c3, 0-#80
    dw #380, #40, c4, 0-#200
    dw #180, #00, #000, #000
    dw #380, #40, c4, 0-#200
    dw #180, #00, #000, #000
    db #40


ptn1
    dw #805, kick1, #c080, #10, c3, 0-#80
    dw #380, #40, c4, 0-#240
    dw #180, #00, #000, #000
    dw #380, #40, c4, 0-#240
    dw #180, #00, #000, #000
    db #40

ptn1s
    dw #804, sn1, #8080, #10, c3, 0-#80
    dw #380, #40, c4, 0-#240
    dw #180, #00, #000, #000
    dw #380, #40, c4, 0-#240
    dw #180, #00, #000, #000
    db #40


ptn2
    dw #805, kick1, #c080, #10, c3, 0-#80
    dw #380, #40, c4, 0-#280
    dw #180, #00, #000, #0000
    dw #380, #40, c4, 0-#280
    dw #180, #00, #000, #000
    db #40

ptn2s
    dw #804, sn1, #8080, #10, c3, 0-#80
    dw #380, #40, c4, 0-#280
    dw #180, #00, #000, #0000
    dw #380, #40, c4, 0-#280
    dw #180, #00, #000, #000
    db #40


ptn3
    dw #805, kick1, #c080, #10, c3, 0-#80
    dw #380, #40, c4, 0-#300
    dw #180, #00, #000, #000
    dw #380, #40, c4, 0-#300
    dw #180, #00, #000, #000
    db #40

ptn3s
    dw #804, sn1, #8080, #10, c3, 0-#80
    dw #380, #40, c4, 0-#300
    dw #180, #00, #000, #000
    dw #380, #40, c4, 0-#300
    dw #180, #00, #000, #000
    db #40

ptn0a
    dw #805, kick1, #c000, #10, c3, 0-#80, #10, c4, #41
    dw #380, #40, c4, 0-#200
    dw #180, #00, #000, #000
    dw #380, #40, c4, 0-#200
    dw #180, #00, #000, #000
    db #40

ptn0b
    dw #805, kick1, #c000, #10, c3, 0-#80, #10, ais4, #7e
    dw #380, #40, c4, 0-#200
    dw #180, #00, #000, #000
    dw #380, #40, c4, 0-#200
    dw #180, #00, #000, #000
    db #40

ptn2b
    dw #805, kick1, #c000, #10, c3, 0-#80, #10, g4, #61
    dw #380, #40, c4, 0-#280
    dw #180, #00, #000, #000
    dw #380, #40, c4, 0-#280
    dw #180, #00, #000, #000
    db #40

ptn3b
    dw #804, sn1, #8000, #10, c3, 0-#80, #10, f4, #58
    dw #304, sn1, #8080, #40, c4, 0-#280
    dw #180, #00, #000, #000
    dw #380, #40, c4, 0-#280
    dw #180, #00, #000, #000
    db #40
