
	dw ptn00
loop
	dw ptn01
	dw ptn01
	dw ptn02
	dw ptn03
	dw 0
	
	
	;speed+flags, freq.ch1, smp.ch1, freq.ch2, smp.ch2
	
ptn00
	dw #0800,#0400,smp1,#0000,smp0,fxtab0
	dw #0800,#04c2,smp1,#0000,smp0,fxtab0
	dw #0800,#0721,smp1,#0000,smp0,fxtab0
	dw #0800,#05fe,smp1,#0000,smp0,fxtab0
	
	dw #0800,#0800,smp1,#0000,smp0,fxtab0
	dw #0800,#0984,smp1,#0000,smp0,fxtab0
	dw #0800,#0e41,smp1,#0000,smp0,fxtab0
	dw #0800,#0bfd,smp1,#0000,smp0,fxtab0
	
	dw #0800,#1000,smp1,#0000,smp0,fxtab0
	dw #0800,#1307,smp1,#0000,smp0,fxtab0
	dw #0800,#1c82,smp1,#0000,smp0,fxtab0
	dw #0800,#17f9,smp1,#0000,smp0,fxtab0
	
	dw #0800,#2000,smp1,#0000,smp0,fxtab0
	dw #0800,#260e,smp1,#0000,smp0,fxtab0
	dw #0800,#3905,smp1,#0000,smp0,fxtab0
	dw #0800,#2ff2,smp1,#0000,smp0,fxtab0

	db #40

ptn01
	dw #0800,#0040,smp10,#0400,smp1,fxtab0
	dw #0800,#0040,smp11,#04c2,smp1,fxtab0
	dw #0800,#0040,smp12,#0721,smp1,fxtab0
	dw #0800,#0040,smp13,#05fe,smp1,fxtab0
	
	dw #0800,#2000,smp2,#0111,smp14,fxtab4
	dw #0800,#2000,smp3,#0111,smp15,fxtab4
	dw #0800,#2000,smp4,#0111,smp16,fxtab4
	dw #0800,#2000,smp5,#0111,smp17,fxtab4
	
	dw #0800,#0040,smp10,#1000,smp1,fxtab0
	dw #0800,#0040,smp11,#1307,smp1,fxtab0
	dw #0800,#0040,smp12,#1c82,smp1,fxtab0
	dw #0800,#0040,smp13,#17f9,smp1,fxtab0
	
	dw #0800,#2000,smp6,#0111,smp14,fxtab4
	dw #0800,#2000,smp7,#0111,smp15,fxtab4
	dw #0800,#2000,smp8,#0111,smp16,fxtab4
	dw #0800,#2000,smp9,#0111,smp17,fxtab4

	dw #40
	
ptn02
	dw #0800,#0400,smp23,#0040,smp18,fxtab0
	dw #0800,#0040,smp18,#0400,smp23,fxtab0
	dw #0800,#0040,smp19,#0400,smp23,fxtab0
	dw #0800,#0040,smp20,#0400,smp23,fxtab0
	
	dw #1000,#1000,smp5,#0000,smp0,fxtab2
	dw #0800,#2000,smp2,#0000,smp0,fxtab4
	dw #0800,#1000,smp3,#0000,smp0,fxtab5
	
	dw #0800,#0400,smp23,#0040,smp18,fxtab0
	dw #0800,#0040,smp18,#0400,smp23,fxtab0
	dw #0800,#0040,smp19,#0400,smp23,fxtab0
	dw #0800,#0040,smp20,#0400,smp23,fxtab0
	
	dw #0800,#078d,smp25,#0000,smp0,fxtab0
	dw #0800,#0800,smp25,#0000,smp0,fxtab0
	dw #0800,#08fb,smp25,#0000,smp0,fxtab0
	dw #0800,#0984,smp25,#0000,smp0,fxtab0

	
	dw #0800,#0400,smp23,#0040,smp18,fxtab0
	dw #0800,#0040,smp18,#0400,smp23,fxtab0
	dw #0800,#0040,smp19,#0400,smp23,fxtab0
	dw #0800,#0040,smp20,#0400,smp23,fxtab0
	
	dw #1000,#1000,smp5,#0000,smp0,fxtab2
	dw #0800,#2000,smp2,#0000,smp0,fxtab4
	dw #0800,#1000,smp3,#0000,smp0,fxtab5
	
	dw #0800,#0800,smp23,#0040,smp10,fxtab0
	dw #0800,#0040,smp10,#0800,smp23,fxtab0
	dw #0800,#0040,smp11,#0800,smp23,fxtab0
	dw #0800,#0040,smp12,#0800,smp23,fxtab0
	
	dw #0800,#08fb,smp25,#078d,smp25,fxtab0
	dw #0800,#0984,smp25,#0800,smp25,fxtab0
	dw #0800,#0aae,smp25,#08fb,smp25,fxtab0
	dw #0800,#0bfd,smp25,#0984,smp25,fxtab0
	
	dw #40
	
ptn03	
	dw #0800,#0400,smp25,#0100,smp18,fxtab0
	dw #0800,#0800,smp25,#0100,smp19,fxtab0
	dw #0800,#1000,smp25,#0100,smp20,fxtab0
	dw #0800,#0800,smp25,#0000,smp0,fxtab0
	
	dw #0800,#0400,smp26,#0080,smp18,fxtab0
	dw #0800,#0800,smp26,#0080,smp19,fxtab0
	dw #0800,#1000,smp26,#0080,smp20,fxtab0
	dw #0800,#0800,smp26,#0000,smp0,fxtab0
	
	dw #0800,#0400,smp27,#0040,smp18,fxtab0
	dw #0800,#0800,smp27,#0040,smp19,fxtab0
	dw #0800,#1000,smp27,#0040,smp20,fxtab0
	dw #0800,#0800,smp27,#0000,smp0,fxtab0
	
	dw #0800,#1000,smp9,#0000,smp0,fxtab0
	dw #0800,#2000,smp9,#0000,smp0,fxtab0
	dw #0800,#4000,smp9,#0000,smp0,fxtab0
	dw #0800,#2000,smp9,#0000,smp0,fxtab0
	
	db #40
	

fxtab0
	dw tExecStop

fxtab4
	dw tf1,#260e
	dw tf1,#2ff2
	dw tf1,#2000
	dw tf1,#260e
	dw tf1,#2ff2	
	dw tf1f2s2,#2000,#0000
	db HIGH(smp0)
	dw tExecLoop,fxtab4

fxtab5
	dw tf1,#1307
	dw tf1,#17f9
	dw tf1,#1000
	dw tExecLoop,fxtab5

fxtab2
	dw tf1s1,#1307
	db HIGH(smp5)
	dw tf1s1,#17F9
	db HIGH(smp5)
	dw tf1s1,#1000
	db HIGH(smp5)
	dw tf1s1,#1307
	db HIGH(smp4)
	dw tf1s1,#17F9
	db HIGH(smp4)
	dw tf1s1,#1000
	db HIGH(smp4)
	dw tf1s1,#1307
	db HIGH(smp3)
	dw tf1s1,#17F9
	db HIGH(smp3)
	dw tf1s1,#1000
	db HIGH(smp3)
	dw tf1s1,#1307
	db HIGH(smp3)
	dw tf1s1,#17F9
	db HIGH(smp2)
	dw tf1s1,#1000
	db HIGH(smp2)
	dw tf1s1,#1307
	db HIGH(smp2)
	dw tf1s1,#17F9
	db HIGH(smp2)
	dw tf1s1,#1000
	db HIGH(smp5)
	dw tExecLoop,fxtab2
