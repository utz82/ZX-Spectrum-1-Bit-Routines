    ;; sequence
    dw .p00
    dw .p01
.loop
    dw .p02
    dw 0
    dw .loop

.p00
    dw #4005,#c1,c1,#80ff,t_lp_cutoff1,#c1,c1+1,#80ff,t_lp_cutoff1
    dw #4005,#c1,c0,#2001,t_lp_cutoff1,#c1,0,0,t_filter_off
    dw #4005,#c1,c0,#2001,t_lp_cutoff3,#c1,0,0,t_filter_off
    db #40

.p01
    dw #0401,#c1,c1,#2001,t_lp_cutoff1
    dw #0401,#80,t_lp_cutoff1dot5
    dw #0401,#80,t_lp_cutoff2
    dw #0401,#80,t_lp_cutoff3
    dw #0301,#80,t_lp_cutoff4
    dw #0201,#80,t_lp_cutoff5
    dw #0101,#80,t_filter_off
    dw #0201,#80,t_lp_cutoff5
    dw #0301,#80,t_lp_cutoff4
    dw #0401,#80,t_lp_cutoff3
    dw #0401,#80,t_lp_cutoff2
    dw #0401,#80,t_lp_cutoff1dot5
    dw #0401,#80,t_lp_cutoff1

    dw #0401,#c1,c2,#2001,t_lp_cutoff1
    dw #0401,#80,t_lp_cutoff1dot5
    dw #0401,#80,t_lp_cutoff2
    dw #0401,#80,t_lp_cutoff3
    dw #0301,#80,t_lp_cutoff4
    dw #0201,#80,t_lp_cutoff5
    dw #0101,#80,t_filter_off
    dw #0201,#80,t_lp_cutoff5
    dw #0301,#80,t_lp_cutoff4
    dw #0401,#80,t_lp_cutoff3
    dw #0401,#80,t_lp_cutoff2
    dw #0401,#80,t_lp_cutoff1dot5
    dw #0401,#80,t_lp_cutoff1

    db #40

.p02
    dw #1085,.kick,#280,#ff51,#c1,c1,#2001,t_lp_cutoff1,#c1,g2,#4001,t_filter_off
    dw #1005,#c1,c2,#2001,t_lp_cutoff1,#80,t_lp_cutoff5
    dw #1005,#c1,c3,#2001,t_lp_cutoff1,#80,t_lp_cutoff4
    dw #1085,.kick,#280,#5501,#c1,c2,#2001,t_lp_cutoff1,#80,t_lp_cutoff3

    dw #1085,.kick,#280,#5551,#c1,c1,#2001,t_lp_cutoff1dot5,#c1,g2,#4001,t_lp_cutoff2
    dw #1081,.kick,#280,#5511,#c1,c2,#2001,t_lp_cutoff1dot5
    dw #1085,.nois,#280,#ff50,#c1,c3,#2001,t_lp_cutoff1dot5,#c1,g2,#4001,t_lp_cutoff1dot5
    dw #1001,#c1,c2,#2001,t_lp_cutoff1dot5

    dw #1005,#c1,c1,#2001,t_lp_cutoff2,#c1,g2,#4001,t_lp_cutoff1
    dw #1001,#c1,c2,#2001,t_lp_cutoff2
    dw #1001,#c1,c3,#2001,t_lp_cutoff2
    dw #1001,#c1,c2,#2001,t_lp_cutoff2

    dw #1001,#c1,c1,#2001,t_lp_cutoff3
    dw #1001,#c1,c2,#2001,t_lp_cutoff3
    dw #1085,.kick,#280,#ff51,#c1,c3,#2001,t_lp_cutoff3,#c1,f2,#4001,t_lp_cutoff1
    dw #1001,#c1,c2,#2001,t_lp_cutoff3

    dw #1085,.kick,#280,#ff51,#c1,c1,#2001,t_lp_cutoff4,#c1,c0,#4001,t_lp_cutoff1
    dw #1001,#c1,c2,#2001,t_lp_cutoff4
    dw #1001,#c1,c3,#2001,t_lp_cutoff4
    dw #0881,.kick,#120,#5550,#c1,c2,#2001,t_lp_cutoff4
    dw #0880,.kick,#120,#5550

    dw #1081,.kick,#280,#ff51,#c1,c1,#2001,t_lp_cutoff5
    dw #1081,.kick,#280,#ff11,#c1,c2,#2001,t_lp_cutoff5
    dw #1001,#c1,c3,#2001,t_lp_cutoff5
    dw #1001,#c1,c2,#2001,t_lp_cutoff5

    dw #1001,#c1,c1,#2001,t_filter_off
    dw #1001,#c1,c2,#2001,t_filter_off
    dw #1001,#c1,c3,#2001,t_filter_off
    dw #1001,#c1,c2,#2001,t_filter_off


    dw #1005,#c1,c1,#2001,t_hp_cutoff1,#c1,dis1,#4001,t_lp_cutoff1
    dw #1001,#c1,c2,#2001,t_hp_cutoff1
    dw #1001,#c1,c3,#2001,t_hp_cutoff1
    dw #1001,#c1,c2,#2001,t_hp_cutoff1

    dw #1001,#c1,c1,#2001,t_hp_cutoff2
    dw #1001,#c1,c2,#2001,t_hp_cutoff2
    dw #1001,#c1,c3,#2001,t_hp_cutoff2
    dw #1001,#c1,c2,#2001,t_hp_cutoff2

    dw #1001,#c1,c1,#2001,t_hp_cutoff3
    dw #1001,#c1,c2,#2001,t_hp_cutoff3
    dw #1005,#c1,c3,#2001,t_hp_cutoff3,#c1,d1,#4001,t_lp_cutoff1
    dw #1001,#c1,c2,#2001,t_hp_cutoff3

    dw #1001,#c1,c1,#2001,t_hp_cutoff4
    dw #1001,#c1,c2,#2001,t_hp_cutoff4
    dw #1001,#c1,c3,#2001,t_hp_cutoff4
    dw #1001,#c1,c2,#2001,t_hp_cutoff4

    dw #1001,#c1,c1,#2001,t_hp_cutoff5
    dw #1001,#c1,c2,#2001,t_hp_cutoff5
    dw #1001,#c1,c3,#2001,t_hp_cutoff5
    dw #1001,#c1,c2,#2001,t_hp_cutoff5

    db #40

.kick
    db #01,#02,#04,#08,#10,#20,#40,#40,#80,#80,#80,#ff,#ff,#ff,#ff,0
.nois
    db 10, 2, 9, 7, 8, 9, 2, 5, 4, 11, 9, 10, 8, 4, 2, 10, 7, 1, 1, 8, 9, 3, 8, 7, 12, 8, 7, 1, 3, 1, 2, 9, 2, 5, 10, 8, 9, 6, 8, 5, 3, 3, 8, 2, 4, 10, 1, 6, 5, 3, 6, 12, 11, 8, 11, 2, 2, 10, 5, 3, 3, 4, 3, 6, 6, 8, 11, 1, 7, 3, 2, 6, 7, 10, 2, 1, 8, 8, 8, 10, 9, 12, 4, 12, 9, 5
    db 7, 7, 3, 1, 3, 12, 7, 3, 3, 2, 10, 12, 2, 10, 2, 8, 2, 1, 4, 9, 12, 10, 5, 8, 8, 8, 2, 11, 4, 7, 10, 7, 12, 1, 6, 9, 5, 10, 10, 1, 9, 1, 6, 6, 8, 1, 7, 9, 9, 2, 3, 8, 8, 11, 9, 8, 11, 8, 4, 10, 1, 5, 5, 8, 6, 7, 4, 10, 5, 8, 12, 2, 12, 11, 1, 12, 10, 11, 3, 8, 2
    db 5, 7, 4, 1, 7, 12, 7, 10, 12, 6, 7, 12, 1, 1, 4, 7, 4, 1, 6, 5, 10, 9, 12, 7, 2, 4, 11, 12, 12, 11, 7, 3, 12, 11, 1, 3, 7, 12, 9, 11, 4, 6, 12, 11, 8, 2, 3, 12, 4, 6, 5, 11, 11, 1, 2, 11, 1, 6, 4, 4, 10, 5, 7, 2, 12, 5, 4, 12, 7, 7, 1, 6, 1, 3, 10, 5, 1, 8, 2, 2, 11, 10, 10, 5, 8, 8, 8, 10, 3
