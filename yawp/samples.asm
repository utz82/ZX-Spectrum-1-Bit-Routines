	ds 256,0			;00 silence
	instr0 equ samples/256	;silence
	include "samples/0d-kick-v66.smp"
	instr13 equ 1+samples/256
	include "samples/02-noise.smp"
	instr2 equ 2+samples/256
	include "samples/03-sine.smp"
	instr3 equ 3+samples/256
	include "samples/0c-phat.smp"
	instr12 equ 4+samples/256
	include "samples/05-saw.smp"
	instr5 equ 5+samples/256
	include "samples/0a-sq25-v66.smp"
	instr10 equ 6+samples/256
