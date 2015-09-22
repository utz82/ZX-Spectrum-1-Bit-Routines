

	dw intro
	dw introb
	dw ptn00
	dw ptn01

	dw ptn02
	dw ptn02
	dw ptn03
	dw ptn02
loop	
	dw ptn04
	dw ptn04
	dw ptn05
	dw ptn06	
	dw 0

;example note/modulator frequencies

; 	dw #80, #88, #90, #98, #A1, #AB, #B5, #C0, #CB, #D7, #E4, #F2
; 	dw #100, #10F, #11F, #130, #143, #156, #16A, #180, #196, #1AF, #1C8, #1E3
; 	dw #200, #21E, #23F, #261, #285, #2AB, #2D4, #2FF, #32D, #35D, #390, #3C7
; 	dw #400, #43D, #47D, #4C2, #50A, #557, #5A8, #5FE, #65A, #6BA, #721, #78D
; 	dw #800, #87A, #8FB, #984, #A14, #AAE, #B50, #BFD, #CB3, #D74, #E41, #F1A
; 	dw #1000, #10F4, #11F6, #1307, #1429, #155C, #16A1, #17F9, #1966, #1AE9, #1C82, #1E34
; 	dw #2000, #21E7, #23EB, #260E, #2851, #2AB7, #2D41, #2FF2, #32CC, #35D1, #3905, #3C68
; 	dw #4000, #43CE, #47D6, #4C1C, #50A3, #556E, #5A83, #5FE4, #6598, #6BA3, #7209, #78D1
; 	dw #8000, #879D, #8FAD, #9838, #A145, #AADC, #B505, #BFC9, #CB30, #D745, #E412, #F1A2

;some noise frequency values:
;	dw #cd44, #0cba, #0744, #099a, #188b, #18bb, #dd55, #ed66, #c400, #b400, #0143, #c111	
	
	
	;speed+noiseflag/duty1,duty2/3,freq3,freq2,freq1,fx
	
intro
	dw #1880,#8080,#0800,#0000,#0000,fxtab2
	dw #1880,#8080,#0000,#0000,#0000,fxtab1
	dw #9880,#8080,#0800,#0000,#cd44,fxtab4
	dw #1880,#8080,#0000,#0000,#0000,fxtab1
	
	dw #1880,#8080,#0800,#0000,#0000,fxtab2
	dw #1880,#8080,#0000,#0000,#0000,fxtab1
	dw #9880,#8080,#0800,#0000,#cd44,fxtab4
	dw #1880,#8080,#0000,#0000,#0000,fxtab1
	
	dw #1880,#8080,#0800,#0000,#0000,fxtab2
	dw #1880,#8080,#0000,#0000,#0000,fxtab1
	dw #9880,#8080,#0800,#0000,#cd44,fxtab4
	dw #1880,#8080,#0000,#0000,#0000,fxtab1
	
	dw #1880,#8080,#0800,#0000,#0000,fxtab2
	dw #1880,#8080,#0000,#0000,#0000,fxtab1
	dw #9880,#8080,#0800,#0000,#cd44,fxtab4
	dw #9820,#8080,#0000,#0000,#188b,fxtab3
	db 0
	
introb
	dw #1880,#8080,#0800,#0000,#0000,fxtab2
	dw #1880,#8080,#0000,#0000,#0000,fxtab1
	dw #9880,#8080,#0800,#0000,#cd44,fxtab4
	dw #1880,#8080,#0000,#0000,#0000,fxtab1
	
	dw #1880,#8080,#0800,#0000,#0000,fxtab2
	dw #1880,#8080,#0000,#0000,#0000,fxtab1
	dw #9880,#8080,#0800,#0000,#cd44,fxtab4
	dw #1880,#8080,#0000,#0000,#0000,fxtab1
	
	dw #1880,#8080,#0800,#0000,#0000,fxtab2
	dw #1880,#8080,#0000,#0000,#0000,fxtab1
	dw #9880,#8080,#0800,#0000,#cd44,fxtab4
	dw #1880,#8080,#0000,#0000,#0000,fxtab1
	
	dw #1880,#8080,#0800,#0000,#0000,fxtab2
	dw #1880,#8080,#0000,#0000,#0000,fxtab1
	dw #9880,#8080,#0800,#0000,#cd44,fxtab4
	dw #9820,#8080,#0000,#0080,#188b,fxtab3
	db 0
	
ptn00
	dw #1880,#8080,#0800,#0000,#0000,fxtab2
	dw #1880,#8080,#0000,#0080,#0200,fxtab1
	dw #9880,#8080,#0800,#0000,#cd44,fxtab4
	dw #1880,#8080,#0000,#0080,#0200,fxtab1
	
	dw #1880,#8080,#0800,#0000,#0000,fxtab2
	dw #1880,#8080,#0000,#0080,#0200,fxtab1
	dw #9880,#8080,#0800,#0000,#cd44,fxtab4
	dw #1880,#8080,#0000,#0080,#0200,fxtab1
	
	dw #1880,#8080,#0800,#0000,#0000,fxtab2
	dw #1880,#8080,#0000,#0080,#0200,fxtab1
	dw #9880,#8080,#0800,#0000,#cd44,fxtab4
	dw #1880,#8080,#0000,#0080,#0200,fxtab1
	
	dw #1880,#8080,#0800,#0000,#0000,fxtab2
	dw #1880,#8080,#0000,#0080,#0200,fxtab1
	dw #9880,#8080,#0800,#0000,#cd44,fxtab4
	dw #9820,#8080,#0000,#0080,#188b,fxtab3
	db 0
	
ptn01
	dw #1880,#8080,#0800,#0000,#0000,fxtab2
	dw #1880,#8080,#0000,#0080,#0200,fxtab1
	dw #9880,#8080,#0800,#0000,#cd44,fxtab4
	dw #1880,#8080,#0000,#0080,#0200,fxtab1
	
	dw #1880,#8080,#0800,#0000,#0000,fxtab2
	dw #1880,#8080,#0000,#0080,#0200,fxtab1
	dw #9880,#8080,#0800,#0000,#cd44,fxtab4
	dw #1880,#8080,#0000,#0080,#0200,fxtab1

	dw #1880,#8080,#0000,#0400,#0000,fxtab5
	dw #1880,#4080,#0000,#0400,#0000,fxtab5
	dw #1880,#2080,#0000,#0400,#0000,fxtab5
	dw #1880,#1080,#0000,#0400,#0000,fxtab5
	
	dw #1880,#0880,#0000,#0400,#0000,fxtab5
	dw #1880,#1080,#0000,#0400,#0000,fxtab5
	dw #1880,#2080,#0000,#0400,#0000,fxtab5
	dw #1880,#4080,#0000,#0400,#0000,fxtab5
	db 0
	
ptn02
	dw #1880,#8080,#0800,#0400,#0000,fxtab6
	dw #1880,#4080,#0080,#0400,#0000,fxtab5
	dw #9880,#2080,#0800,#0000,#cd44,fxtab7
	dw #1880,#1080,#0080,#0400,#0000,fxtab5
	
	dw #1880,#0880,#0800,#0400,#0000,fxtab6
	dw #1880,#1080,#0080,#0400,#0000,fxtab5
	dw #9880,#2080,#0800,#0000,#cd44,fxtab7
	dw #1880,#4080,#0080,#0400,#0000,fxtab5
	
	dw #1880,#8080,#0800,#0400,#0000,fxtab6
	dw #1880,#4080,#0080,#0400,#0000,fxtab5
	dw #9880,#2080,#0800,#0000,#cd44,fxtab7
	dw #1880,#1080,#0080,#0400,#0000,fxtab5
	
	dw #1880,#0880,#0800,#0400,#0000,fxtab6
	dw #1880,#1080,#0080,#0400,#0000,fxtab5
	dw #9880,#2080,#0800,#0000,#cd44,fxtab7
	dw #9820,#4080,#0080,#0400,#188b,fxtab8
	db 0
	

ptn03
	dw #1880,#8080,#0800,#0557,#0000,fxtab6
	dw #1880,#4080,#00ab,#0557,#0000,fxtab5
	dw #9880,#2080,#0800,#0557,#cd44,fxtab7
	dw #1880,#1080,#00ab,#0557,#0000,fxtab15
	
	dw #1880,#0880,#0800,#0557,#0000,fxtab16
	dw #1880,#1080,#00ab,#0557,#0000,fxtab15
	dw #9880,#2080,#0800,#0557,#cd44,fxtab17
	dw #1880,#4080,#00ab,#0557,#0000,fxtab15
	
	dw #1880,#8080,#0800,#0557,#0000,fxtab16
	dw #1880,#4080,#00ab,#0557,#0000,fxtab15
	dw #9880,#2080,#0800,#0557,#cd44,fxtab17
	dw #1880,#1080,#00ab,#0557,#0000,fxtab15
	
	dw #1880,#0880,#0800,#0557,#0000,fxtab16
	dw #1880,#1080,#00ab,#0557,#0000,fxtab15
	dw #9880,#2080,#0800,#0557,#cd44,fxtab17
	dw #9820,#4080,#00ab,#0557,#188b,fxtab18
	db 0


ptn04
	dw #1880,#8080,#0800,#0400,#0800,fxtab6
	dw #1880,#4080,#0080,#0400,#0800,fxtab5
	dw #9880,#2080,#0800,#0000,#cd44,fxtab7
	dw #1880,#1080,#0080,#0400,#0800,fxtab5
	
	dw #1880,#0880,#0800,#0400,#0000,fxtab6
	dw #1880,#1080,#0080,#0400,#0000,fxtab5
	dw #9880,#2080,#0800,#0000,#cd44,fxtab7
	dw #1880,#4080,#0080,#0400,#0800,fxtab5
	
	dw #1880,#8080,#0800,#0400,#0aae,fxtab6
	dw #1880,#4080,#0080,#0400,#0000,fxtab5
	dw #9880,#2080,#0800,#0000,#cd44,fxtab7
	dw #1880,#1080,#0080,#0400,#0984,fxtab5
	
	dw #1880,#0880,#0800,#0400,#08fb,fxtab6
	dw #1880,#1080,#0080,#0400,#0984,fxtab5
	dw #9880,#2080,#0800,#0000,#cd44,fxtab7
	dw #9820,#4080,#0080,#0400,#188b,fxtab8
	db 0
	

ptn05
	dw #1880,#8080,#0800,#0557,#0aae,fxtab6
	dw #1880,#4080,#00ab,#0557,#0aae,fxtab5
	dw #9880,#2080,#0800,#0aae,#cd44,fxtab7
	dw #1880,#1080,#00ab,#0557,#0000,fxtab15
	
	dw #1880,#0880,#0800,#0557,#0000,fxtab16
	dw #1880,#1080,#00ab,#0557,#0000,fxtab15
	dw #9880,#2080,#0800,#0557,#cd44,fxtab17
	dw #1880,#4080,#00ab,#0557,#0984,fxtab15
	
	dw #1880,#8080,#0800,#0557,#0b50,fxtab16
	dw #1880,#4080,#00ab,#0557,#0000,fxtab15
	dw #9880,#2080,#0800,#0557,#cd44,fxtab17
	dw #1880,#1080,#00ab,#0557,#0b50,fxtab15
	
	dw #1880,#0880,#0800,#0557,#0aae,fxtab16
	dw #1880,#1080,#00ab,#0557,#0984,fxtab15
	dw #9880,#2080,#0800,#0557,#cd44,fxtab17
	dw #9820,#4080,#00ab,#0557,#188b,fxtab18
	db 0

ptn06
	dw #1880,#8080,#0800,#0400,#0800,fxtab6
	dw #1880,#4080,#0080,#0400,#0800,fxtab5
	dw #9880,#2080,#0800,#0000,#cd44,fxtab7
	dw #1880,#1080,#0080,#0400,#0000,fxtab5
	
	dw #1880,#0880,#0800,#0400,#0000,fxtab6
	dw #1880,#1080,#0080,#0400,#0000,fxtab5
	dw #9880,#2080,#0800,#0000,#cd44,fxtab7
	dw #1880,#4080,#0080,#0400,#0000,fxtab5
	
	dw #1880,#8080,#0800,#0400,#0000,fxtab6
	dw #1880,#4080,#0080,#0400,#0000,fxtab5
	dw #9880,#2080,#0800,#0000,#cd44,fxtab7
	dw #1880,#1080,#0080,#0400,#0000,fxtab5
	
	dw #1880,#0880,#0800,#0400,#0000,fxtab6
	dw #1880,#1080,#0080,#0400,#0000,fxtab5
	dw #9880,#2080,#0800,#0000,#cd44,fxtab7
	dw #9820,#4080,#0080,#0400,#188b,fxtab8
	db 0


fxtab15
	dw fxNone
	dw fxNone
	dw fxNone
	dw fxSetFCh2,#65A
	dw fxNone
	dw fxNone
	dw fxNone
	dw fxSetFCh2,#800
	dw fxNone
	dw fxNone
	dw fxNone
fx15lp
	dw fxSetFCh2,#984
	dw fxNone
	dw fxNone
	dw fxNone
fx15lp2
	dw fxSetFCh2,#557
	dw fxJump,fxtab15+2



fxtab5
	dw fxNone
	dw fxNone
	dw fxNone
	dw fxSetFCh2,#4C2
	dw fxNone
	dw fxNone
	dw fxNone
	dw fxSetFCh2,#5FE
	dw fxNone
	dw fxNone
	dw fxNone
fx5lp
	dw fxSetFCh2,#721
	dw fxNone
	dw fxNone
	dw fxNone
fx5lp2
	dw fxSetFCh2,#400
	dw fxJump,fxtab5+2

fxtab16
	dw fxSetFCh3,#400
	dw fxSetFCh3,#200
	dw fxSetFCh3,#100
	dw fxSetFCh23,#65a,#c0
	dw fxSetFCh3,#80
	dw fxNone
	dw fxSetFCh3,#40
	dw fxSetFCh2,#800
	dw fxNone
	dw fxCutCh3
	dw fxJump,fx15lp



fxtab6
	dw fxSetFCh3,#400
	dw fxSetFCh3,#200
	dw fxSetFCh3,#100
	dw fxSetFCh23,#4C2,#c0
	dw fxSetFCh3,#80
	dw fxNone
	dw fxSetFCh3,#40
	dw fxSetFCh2,#5FE
	dw fxNone
	dw fxCutCh3
	dw fxJump,fx5lp

fxtab17
	dw fxSetFCh3,#400
	dw fxSetFCh3,#200
	dw fxSetFCh3,#100
	dw fxSetFCh23,#65a,#c0
	dw fxSetFCh3,#80
	dw fxSetDCh1,#4000
	dw fxSetFCh3,#40
	dw fxSetFCh2,#800
	dw fxSetDCh1,#2000
	dw fxCutCh3
	dw fxSetDCh1,#1000
	dw fxSetFCh2,#984
	dw fxSetDCh1,#0800
	dw fxStopNoise
	dw fxJump,fx15lp2


fxtab7
	dw fxSetFCh3,#400
	dw fxSetFCh3,#200
	dw fxSetFCh3,#100
	dw fxSetFCh23,#4c2,#c0
	dw fxSetFCh3,#80
	dw fxSetDCh1,#4000
	dw fxSetFCh3,#40
	dw fxSetFCh2,#5FE
	dw fxSetDCh1,#2000
	dw fxCutCh3
	dw fxSetDCh1,#1000
	dw fxSetFCh2,#721
	dw fxSetDCh1,#0800
	dw fxStopNoise
	dw fxJump,fx5lp2

fxtab18
	dw fxSetFCh3,#400
	dw fxSetFCh3,#200
	dw fxSetFCh3,#100
	dw fxSetFCh23,#65a,#c0
	dw fxSetFCh3,#80
	dw fxStopNoise
	dw fxSetFCh3,#40
	dw fxSetFCh2,#800
	dw fxNone
	dw fxCutCh3
	dw fxStartNoiseSetFCh1,#188b
	dw fxSetFCh2,#984
	dw fxNone
	dw fxStopNoise
	dw fxJump,fx15lp2

fxtab8
	dw fxSetFCh3,#400
	dw fxSetFCh3,#200
	dw fxSetFCh3,#100
	dw fxSetFCh23,#4c2,#c0
	dw fxSetFCh3,#80
	dw fxStopNoise
	dw fxSetFCh3,#40
	dw fxSetFCh2,#5FE
	dw fxNone
	dw fxCutCh3
	dw fxStartNoiseSetFCh1,#188b
	dw fxSetFCh2,#721
	dw fxNone
	dw fxStopNoise
	dw fxJump,fx5lp2


fxtab4
	dw fxSetFCh3,#400
	dw fxSetFCh3,#200
	dw fxSetFCh3,#100
	dw fxSetFCh3,#c0
	dw fxSetFCh3,#80
	dw fxSetDCh1,#4000
	dw fxSetFCh3,#40
	dw fxNone
	dw fxSetDCh1,#2000
	dw fxCutCh3
	dw fxSetDCh1,#1000
	dw fxNone
	dw fxNone
	dw fxSetDCh1,#0800
	dw fxStopNoise
	dw fxStop


fxtab3
	dw fxNone
	dw fxNone
	dw fxNone
	dw fxNone
	dw fxNone
	dw fxStopNoise
	dw fxNone
	dw fxNone
	dw fxNone
	dw fxNone
	dw fxNone
	dw fxStartNoiseSetFCh1,#188b
	dw fxJump,fxtab3+2
	
	
fxtab1
	dw fxStop
	
fxtab2	;drum
	;dw fxSetFCh2,#800
	dw fxSetFCh3,#400
	dw fxSetFCh3,#200
	dw fxSetFCh3,#100
	dw fxSetFCh3,#c0
	dw fxSetFCh3,#80
	dw fxNone
	dw fxSetFCh3,#40
	dw fxNone
	dw fxNone
	dw fxCutCh3
	dw fxStop