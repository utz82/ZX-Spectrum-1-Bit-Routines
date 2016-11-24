

	dw ptn2
	dw ptn2a
	dw ptn2b
	dw ptn2c
	dw ptn3
	dw ptn3
	dw ptn3
	dw ptn3
	dw ptn3a
	dw ptn3a
	dw ptn3b
	dw ptn3b
	dw ptn3
	dw ptn3
	dw ptn3
	dw ptn3
	dw ptn3a
	dw ptn3a
	dw ptn3b
	dw ptn3c
mLoop
	dw ptn4
	dw ptn4x
	dw ptn4a
	dw ptn4aa
	dw ptn4b
	dw ptn4bx
	dw ptn4c
	dw ptn4cx
	dw ptn4
	dw ptn4x
	dw ptn4a
	dw ptn4aa
	dw ptn4b
	dw ptn4bx
	dw ptn4c
	dw ptn4cxa
; mLoop
	dw ptn5x
	dw ptn5ax
	dw ptn5bx
	dw ptn5cx
	dw ptn5d
	dw ptn5e
	dw ptn5f
	dw ptn5g
	dw ptn5
	dw ptn5a
	dw ptn5b
	dw ptn5c
	dw ptn5d
	dw ptn5e
	dw ptn5f
	dw ptn5g
	dw ptn6
	dw ptn6a
	dw ptn6b
	dw ptn6c
	dw ptn6d
	dw ptn6e
	dw ptn6f
	dw ptn6g
	dw ptn7
	dw ptn7a
	dw ptn7b
	dw ptn7c
	dw ptn7d
	dw ptn7e
	dw ptn7f
	dw ptn7g
	dw 0


ptn5	dw #800, wave20|c3, rest, rest
	dw kick|#500
	dw #884, wave20|c4
	db 0
	dw #884, wave20|c5
	db 0
	dw #884, wave20|c4
	db 0
	db #40
	
ptn5a	dw #800, wave21|c3, rest, rest
	dw kick|#500
	dw #884, wave21|c4
	db 0
	dw #884, wave21|c5
	db 0
	dw #884, wave21|c4
	db 0
	db #40

ptn5b	dw #800, wave22|c3, rest, rest
	dw kick|#500
	dw #884, wave22|c4
	db 0
	dw #884, wave22|c5
	db 0
	dw #884, wave22|c4
	db 0
	db #40
	
ptn5c	dw #800, wave23|c3, rest, rest
	dw kick|#500
	dw #884, wave23|c4
	db 0
	dw #884, wave23|c5
	db 0
	dw #884, wave23|c4
	db 0
	db #40
	
ptn5x	dw #800, wave20|c3, wave1|c1, rest
	dw kick|#500
	dw #884, wave20|c4
	db 0
	dw #884, wave20|c5
	db 0
	dw #884, wave20|c4
	db 0
	db #40
	
ptn5ax	dw #800, wave21|c3, wave2|c1, rest
	dw kick|#500
	dw #884, wave21|c4
	db 0
	dw #884, wave21|c5
	db 0
	dw #884, wave21|c4
	db 0
	db #40

ptn5bx	dw #800, wave22|c3, wave5|c1, rest
	dw kick|#500
	dw #884, wave22|c4
	db 0
	dw #884, wave22|c5
	db 0
	dw #884, wave22|c4
	db 0
	db #40
	
ptn5cx	dw #800, wave23|c3, wave6|c1, rest
	dw kick|#500
	dw #884, wave23|c4
	db 0
	dw #884, wave23|c5
	db 0
	dw #884, wave23|c4
	db 0
	db #40
	
ptn5d	dw #800, wave24|c2, rest, rest
	dw kick|#500
	dw #884, wave24|c3
	db 0
	dw #884, wave24|c4
	db 0
	dw #884, wave24|c3
	db 0
	db #40
	
ptn5e	dw #800, wave25|c2, rest, rest
	dw kick|#500
	dw #884, wave25|c3
	db 0
	dw #884, wave25|c4
	db 0
	dw #884, wave25|c2
	db 0
	db #40
	
ptn5f	dw #800, wave26|c3, rest, rest
	dw kick|#500
	dw #884, wave26|c4
	db 0
	dw #884, wave26|c5
	db 0
	dw #884, wave26|c4
	db 0
	db #40
	
ptn5g	dw #800, wave27|c3, rest, rest
	dw kick|#500
	dw #884, wave27|c4
	db 0
	dw #884, wave27|c5
	db 0
	dw #884, wave27|c4
	db 0
	db #40

ptn6	dw #800, wave20|a2, rest, rest
	dw kick|#500
	dw #884, wave20|a3
	db 0
	dw #884, wave20|a4
	db 0
	dw #884, wave20|a3
	db 0
	db #40
	
ptn6a	dw #800, wave21|a2, rest, rest
	dw kick|#500
	dw #884, wave21|a3
	db 0
	dw #884, wave21|a4
	db 0
	dw #884, wave21|a3
	db 0
	db #40

ptn6b	dw #800, wave22|a2, rest, rest
	dw kick|#500
	dw #884, wave22|a3
	db 0
	dw #884, wave22|a4
	db 0
	dw #884, wave22|a3
	db 0
	db #40
	
ptn6c	dw #800, wave23|a2, rest, rest
	dw kick|#500
	dw #884, wave23|a3
	db 0
	dw #884, wave23|a4
	db 0
	dw #884, wave23|a3
	db 0
	db #40
	
ptn6d	dw #800, wave24|a1, rest, rest
	dw kick|#500
	dw #884, wave24|a2
	db 0
	dw #884, wave24|a3
	db 0
	dw #884, wave24|a2
	db 0
	db #40
	
ptn6e	dw #800, wave25|a1, rest, rest
	dw kick|#500
	dw #884, wave25|a2
	db 0
	dw #884, wave25|a3
	db 0
	dw #884, wave25|a2
	db 0
	db #40
	
ptn6f	dw #800, wave26|a2, rest, rest
	dw kick|#500
	dw #884, wave26|a3
	db 0
	dw #884, wave26|a4
	db 0
	dw #884, wave26|a3
	db 0
	db #40
	
ptn6g	dw #800, wave27|a2, rest, rest
	dw kick|#500
	dw #884, wave27|a3
	db 0
	dw #884, wave27|a4
	db 0
	dw #884, wave27|a3
	db 0
	db #40	


ptn7	dw #800, wave20|ais2, wave5|g3, wave5|ais3
	dw kick|#500
	dw #884, wave20|ais3
	db 0
	dw #884, wave20|ais4
	db 0
	dw #884, wave20|ais3
	db 0
	db #40
	
ptn7a	dw #800, wave21|ais2, wave5|g3, wave5|ais3
	dw kick|#500
	dw #884, wave21|ais3
	db 0
	dw #884, wave21|ais4
	db 0
	dw #884, wave21|ais3
	db 0
	db #40

ptn7b	dw #800, wave22|ais2, wave5|g3, wave5|ais3
	dw kick|#500
	dw #884, wave22|ais3
	db 0
	dw #884, wave22|ais4
	db 0
	dw #884, wave22|ais3
	db 0
	db #40
	
ptn7c	dw #800, wave23|ais2, wave5|g3, wave5|ais3
	dw kick|#500
	dw #884, wave23|ais3
	db 0
	dw #884, wave23|ais4
	db 0
	dw #884, wave23|ais3
	db 0
	db #40
	
ptn7d	dw #800, wave24|ais1, wave5|f3, wave5|ais3
	dw kick|#500
	dw #884, wave24|ais2
	db 0
	dw #884, wave24|ais3
	db 0
	dw #884, wave24|ais2
	db 0
	db #40
	
ptn7e	dw #800, wave25|ais1, wave5|f3, wave5|ais3
	dw kick|#500
	dw #884, wave25|ais2
	db 0
	dw #884, wave25|ais3
	db 0
	dw #884, wave25|ais2
	db 0
	db #40
	
ptn7f	dw #800, wave26|ais2, wave5|f3, wave5|ais3
	dw kick|#500
	dw #884, wave26|ais3
	db 0
	dw #884, wave26|ais4
	db 0
	dw #884, wave26|ais3
	db 0
	db #40
	
ptn7g	dw #800, wave27|ais2, wave6|f3, wave16|ais4
	dw kick|#500
	dw #804, wave27|ais3, wave15|ais4
	db 0
	dw #804, wave27|ais4, wave14|ais4
	db 0
	dw #804, wave27|ais3, wave13|ais4
	db 0
	db #40	


ptn4
	dw #800, wave2|c3, wave8|dis3, wave21|c3
	dw kick|#500
	dw #884, wave2|c2
	db 0
	dw #804, wave2|c4, wave21|c4
	dw hhat|#1000
	dw #884, wave2|c2
	db 0
	dw #804, wave30|f3, wave21|c3
	dw kick|#500
	dw #884, wave2|c2
	db 0
	dw #804, wave2|g3, wave21|c4
	dw hhat|#1000
	dw #884, wave2|c2
	db 0
	db #40
	
ptn4x
	dw #804, wave2|c3, wave21|c3
	dw kick|#500
	dw #884, wave2|c2
	db 0
	dw #804, wave2|c4, wave21|c4
	dw hhat|#1000
	dw #884, wave2|c2
	db 0
	dw #804, wave30|f3, wave21|c3
	dw kick|#500
	dw #884, wave2|c2
	db 0
	dw #804, wave2|g3, wave21|c4
	dw hhat|#1000
	dw #884, wave2|c2
	db 0
	db #40


ptn4a
	dw #800, wave2|c3, wave8|f3, wave21|c3
	dw kick|#500
	dw #884, wave2|c2
	db 0
	dw #804, wave2|c4, wave21|c4
	dw hhat|#1000
	dw #884, wave2|c2
	db 0
	dw #804, wave30|f3, wave21|c3
	dw kick|#500
	dw #884, wave2|c2
	db 0
	dw #804, wave2|g3, wave21|c4
	dw hhat|#1000
	dw #884, wave2|c2
	db 0
	db #40
	
ptn4aa
	dw #804, wave2|c3, wave21|c3
	dw kick|#500
	dw #884, wave2|c2
	db 0
	dw #804, wave2|c4, wave21|c4
	dw hhat|#1000
	dw #884, wave2|c2
	db 0
	dw #804, wave30|f3, wave21|c3
	dw kick|#500
	dw #884, wave2|c2
	db 0
	dw #804, wave2|g3, wave21|c4
	dw hhat|#1000
	dw #884, wave2|c2
	dw hhat|#1000
	db #40
	
ptn4b
	dw #800, wave2|c3, wave8|g3, wave21|a2
	dw kick|#500
	dw #884, wave2|c2
	db 0
	dw #804, wave2|c4, wave21|a3
	dw hhat|#1000
	dw #884, wave2|c2
	db 0
	dw #804, wave30|f3, wave21|a2
	dw kick|#500
	dw #884, wave2|c2
	db 0
	dw #804, wave2|g3, wave21|a3
	dw hhat|#1000
	dw #884, wave2|c2
	db 0
	db #40
	
ptn4bx
	dw #804, wave2|c3, wave21|a2
	dw kick|#500
	dw #884, wave2|c2
	db 0
	dw #804, wave2|c4, wave21|a3
	dw hhat|#1000
	dw #884, wave2|c2
	db 0
	dw #804, wave30|f3, wave21|a2
	dw kick|#500
	dw #884, wave2|c2
	db 0
	dw #804, wave2|g3, wave21|a3
	dw hhat|#1000
	dw #884, wave2|c2
	db 0
	db #40
	
ptn4c
	dw #800, wave2|c3, wave8|f3, wave21|ais2
	dw kick|#500
	dw #884, wave2|c2
	db 0
	dw #804, wave2|c4, wave21|ais3
	dw hhat|#1000
	dw #884, wave2|c2
	db 0
	dw #804, wave30|f3, wave21|ais2
	dw kick|#500
	dw #884, wave2|c2
	db 0
	dw #804, wave2|g3, wave21|ais3
	dw hhat|#1000
	dw #884, wave2|c2
	db 0
	db #40
	
ptn4cx
	dw #804, wave2|c3, wave21|ais2
	dw kick|#500
	dw #884, wave2|c2
	db 0
	dw #804, wave2|c4, wave21|ais3
	dw hhat|#1000
	dw #884, wave2|c2
	db 0
	dw #804, wave30|f3, wave21|ais2
	dw kick|#500
	dw #884, wave2|c2
	dw kick|#500
	dw #804, wave2|g3, wave21|ais3
	dw kick|#500
	dw #884, wave2|c2
	dw kick|#500
	db #40
	
ptn4cxa
	dw #804, wave2|c3, wave21|ais2
	dw kick|#500
	dw #884, wave2|c2
	db 0
	dw #804, wave2|c4, wave21|ais3
	dw hhat|#1000
	dw #884, wave2|c2
	db 0
	dw #404, wave30|f3, wave21|ais2
	dw kick|#500
	dw #484, wave2|f3
	db 0
	dw #484, wave30|f3
	dw kick|#500
	dw #484, wave2|c2
	db 0
	dw #404, wave30|f3, wave21|ais3
	dw kick|#500
	dw #484, wave2|g3
	db 0
	dw #484, wave30|f3
	dw kick|#500
	dw #484, wave2|c2
	db 0
	db #40

ptn3
	dw #800, wave2|c3, rest, wave10|c1
	db 0
	dw #884, wave2|c2
	db 0
	dw #884, wave2|c4
	db 0
	dw #884, wave2|c2
	db 0
	dw #884, wave2|f3
	db 0
	dw #884, wave2|c2
	db 0
	dw #884, wave2|g3
	db 0
	dw #884, wave2|c2
	db 0
	db #40
	
ptn3a
	dw #800, wave2|c3, rest, wave10|a0
	db 0
	dw #884, wave2|c2
	db 0
	dw #884, wave2|c4
	db 0
	dw #884, wave2|c2
	db 0
	dw #884, wave2|f3
	db 0
	dw #884, wave2|c2
	db 0
	dw #884, wave2|g3
	db 0
	dw #884, wave2|c2
	db 0
	db #40
	
ptn3b
	dw #800, wave2|c3, rest, wave10|ais0
	db 0
	dw #884, wave2|c2
	db 0
	dw #884, wave2|c4
	db 0
	dw #884, wave2|c2
	db 0
	dw #884, wave2|f3
	db 0
	dw #884, wave2|c2
	db 0
	dw #884, wave2|g3
	db 0
	dw #884, wave2|c2
	db 0
	db #40
	
ptn3c
	dw #800, wave2|c3, rest, wave10|ais0
	db 0
	dw #884, wave2|c2
	db 0
	dw #884, wave2|c4
	db 0
	dw #884, wave2|c2
	db 0
	dw #884, wave2|f3
	dw hhat|#0800
	dw #884, wave2|c2
	dw hhat|#1000
	dw #884, wave2|g3
	dw hhat|#1800
	dw #884, wave2|c2
	dw hhat|#2000
	db #40


ptn2
	dw #800, wave6|c3, rest, rest
	db 0
	dw #884, wave6|c2
	db 0
	dw #884, wave6|c4
	db 0
	dw #884, wave6|c2
	db 0
	dw #884, wave6|f3
	db 0
	dw #884, wave6|c2
	db 0
	dw #884, wave6|g3
	db 0
	dw #884, wave6|c2
	db 0
	db #40
	
ptn2a
	dw #800, wave5|c3, rest, rest
	db 0
	dw #884, wave5|c2
	db 0
	dw #884, wave5|c4
	db 0
	dw #884, wave5|c2
	db 0
	dw #884, wave5|f3
	db 0
	dw #884, wave5|c2
	db 0
	dw #884, wave5|g3
	db 0
	dw #884, wave5|c2
	db 0
	db #40

ptn2b
	dw #800, wave4|c3, rest, rest
	db 0
	dw #884, wave4|c2
	db 0
	dw #884, wave4|c4
	db 0
	dw #884, wave4|c2
	db 0
	dw #884, wave4|f3
	db 0
	dw #884, wave4|c2
	db 0
	dw #884, wave4|g3
	db 0
	dw #884, wave4|c2
	db 0
	db #40
	
ptn2c
	dw #800, wave3|c3, rest, rest
	db 0
	dw #884, wave3|c2
	db 0
	dw #884, wave3|c4
	db 0
	dw #884, wave3|c2
	db 0
	dw #884, wave3|f3
	db 0
	dw #884, wave3|c2
	db 0
	dw #884, wave3|g3
	db 0
	dw #884, wave3|c2
	db 0
	db #40

