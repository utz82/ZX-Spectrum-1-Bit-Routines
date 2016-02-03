
	org 256*(1+(HIGH($)))		;align to 256b page
	
smp0					;silence
	ds 256,0

;**********************************************************
;add your samples here
	
smp1
	include "samples/tri-v4.asm"
smp1a
	include "samples/tri-v2.asm"	
smp2
	include "samples/sq50-v4.asm"
smp3
	include "samples/sq50-v3.asm"
smp4
	include "samples/sq50-v2.asm"
smp5
	include "samples/sq50-v1.asm"
smp6
	include "samples/sq25-v4.asm"
smp7
	include "samples/sq25-v3.asm"
smp8
	include "samples/sq25-v2.asm"
smp9
	include "samples/sq25-v1.asm"
smp10
	include "samples/kick-v4.asm"
smp11
	include "samples/kick-v3.asm"
smp12
	include "samples/kick-v2.asm"
smp13
	include "samples/kick-v1.asm"
smp14
	include "samples/whitenoise-v4.asm"
smp15
	include "samples/whitenoise-v3.asm"
smp16
	include "samples/whitenoise-v2.asm"
smp17
	include "samples/whitenoise-v1.asm"
smp18
	include "samples/softkick-v4.asm"
smp19
	include "samples/softkick-v3.asm"
smp20
	include "samples/softkick-v2.asm"
smp21
	include "samples/softkick-v1.asm"
smp22
	include "samples/phat1-v4.asm"	
smp23
	include "samples/phat1-v3.asm"
smp24
	include "samples/phat1-v2.asm"
smp25
	include "samples/phat2-v4.asm"
smp26
	include "samples/phat3-v3.asm"
smp27
	include "samples/phat4-v4.asm"
smp28
	include "samples/phat4-v2.asm"
smp29
	include "samples/saw-v4.asm"