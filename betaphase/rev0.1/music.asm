

include "equates.h"	;note name equates, can be omitted

	dw ptn0
	dw ptn1
	dw ptn1
	dw ptn2
	dw ptn1a
	dw ptn1a
	dw ptn1a
	dw ptn3
mloop	
	dw ptn4
	dw ptn4a
	dw ptn4b
	dw ptn5
	dw ptn4b
	dw ptn4a
	dw ptn4
	dw ptn6
	
	dw ptn4
	dw ptn4a
	dw ptn4b
	dw ptn5
	dw ptn4b
	dw ptn4a
	dw ptn4
	dw ptn6
	
	dw ptn7
	dw ptn7a
	dw ptn7b
	dw ptn8
	dw ptn7b
	dw ptn7a
	dw ptn7
	dw ptn9
	
	dw ptn4
	dw ptn4a
	dw ptn4b
	dw ptn5
	dw ptn4b
	dw ptn4a
	dw ptn4
	dw ptn6a
	dw 0
	
	;speed+flags, (z = end, c = skip update ch1, pe = skip update ch2, m = skip update ch3
	;[prescale1+flags, [phaseOffset1,] mixMethod1+postScale1, freqDiv1,] (z = enable duty mod, c = reset phase)
	;[prescale2+flags, [phaseOffset2,] mixMethod2+postScale2, freqDiv2,] (c = reset phase)
	;[postScale3+slideAmount, slideDirection+freqDiv3 (bit 15)]
	
ptn0
	dw #c00,	phaseReset|dutyModOn, #100, mXor, c1,	phaseReset, 0, mXor, rest,			#18|scaleDown, a3
	dw #c00|noUpd1|noUpd2,											0, rest
	dw #c00|noUpd2,	0, mXor, c2,										#18|scaleDown, a3
	dw #c00|noUpd1|noUpd2,											0, rest
	dw endPtn

ptn1	
	dw #c00|noUpd2,	0, mXor, c1,										#18|scaleDown, a3
	dw #c00|noUpd1|noUpd2,											0, rest
	dw #c00|noUpd2,	0, mXor, c2,										#18|scaleDown, a3
	dw #c00|noUpd1|noUpd2,											0, rest
	db endPtn
	
ptn1a	
	dw #c00|noUpd2,	0, scaleDown|mAnd, c2,									#18|scaleDown, a3
	dw #c00|noUpd1|noUpd2,											0, rest
	dw #c00|noUpd2,	0, scaleDown|mAnd, c3,									#18|scaleDown, a3
	dw #c00|noUpd1|noUpd2,											0, rest
	db endPtn
	
ptn2	
	dw #c00|noUpd2,	0, mXor, c1,										#18|scaleDown, a3
	dw #c00|noUpd1|noUpd2,											0, rest
	dw #c00|noUpd2,	0, mXor, dis2,										#18|scaleDown, a3
	dw #c00|noUpd1|noUpd2,											0, rest
	db endPtn

ptn3	
	dw #c00|noUpd2,	scaleDown, scaleDown|mAnd, c2,								#18|scaleDown, a3
	dw #c00|noUpd1|noUpd2,											0, rest
	dw #c00|noUpd2,	scaleDown, scaleDown|mAnd, ais2,							#18|scaleDown, a3
	dw #c00|noUpd1|noUpd2,											0, rest
	db endPtn
	
ptn4	
	dw #600,	scaleUp, scaleDown|mAnd, c2,	phaseReset, #100, mXor, c3,				#18|scaleDown, a3
	dw #600|noUpd1|noUpd3,				0, mXor, d3
	dw #600|noUpd1,					0, mXor, dis3,						0, rest
	dw #600|noUpd1|noUpd3,				0, mXor, f3
	dw #600,	scaleUp, scaleDown|mAnd, c3,	0, mXor, c3,						#18|scaleDown, a3
	dw #600|noUpd1|noUpd3,				0, mXor, d3
	dw #600|noUpd1,					0, mXor, dis3,						0, rest
	dw #600|noUpd1|noUpd3,				0, mXor, f3
	db endPtn

ptn4a	
	dw #600,	scaleUp, scaleDown|mAnd, c2,	phaseReset, #200, mXor, c3,				#18|scaleDown, a3
	dw #600|noUpd1|noUpd3,				0, mXor, d3
	dw #600|noUpd1,					0, mXor, dis3,						0, rest
	dw #600|noUpd1|noUpd3,				0, mXor, f3
	dw #600,	scaleUp, scaleDown|mAnd, c3,	0, mXor, c3,						#18|scaleDown, a3
	dw #600|noUpd1|noUpd3,				0, mXor, d3
	dw #600|noUpd1,					0, mXor, dis3,						0, rest
	dw #600|noUpd1|noUpd3,				0, mXor, f3
	db endPtn
	
ptn4b	
	dw #600,	scaleUp, scaleDown|mAnd, c2,	phaseReset, #400, mXor, c3,				#18|scaleDown, a3
	dw #600|noUpd1|noUpd3,				0, mXor, d3
	dw #600|noUpd1,					0, mXor, dis3,						0, rest
	dw #600|noUpd1|noUpd3,				0, mXor, f3
	dw #600,	scaleUp, scaleDown|mAnd, c3,	0, mXor, c3,						#18|scaleDown, a3
	dw #600|noUpd1|noUpd3,				0, mXor, d3
	dw #600|noUpd1,					0, mXor, dis3,						0, rest
	dw #600|noUpd1|noUpd3,				0, mXor, f3
	db endPtn
	
ptn5	
	dw #600,	scaleUp, scaleDown|mAnd, c2,	phaseReset, #600, mXor, c3,				#18|scaleDown, a3
	dw #600|noUpd1|noUpd3,				0, mXor, d3
	dw #600|noUpd1,					0, mXor, dis3,						0, rest
	dw #600|noUpd1|noUpd3,				0, mXor, f3
	dw #600,	scaleUp, scaleDown|mAnd, dis3,	0, mXor, c3,						#18|scaleDown, a3
	dw #600|noUpd1|noUpd3,				0, mXor, d3
	dw #600|noUpd1,					0, mXor, dis3,						0, rest
	dw #600|noUpd1|noUpd3,				0, mXor, f3
	db endPtn
	
ptn6	
	dw #600,	scaleUp, scaleDown|mAnd, c2,	phaseReset, #80, mXor, c3,				#18|scaleDown, a3
	dw #600|noUpd1|noUpd3,				0, mXor, d3
	dw #600|noUpd1,					0, mXor, dis3,						0, rest
	dw #600|noUpd1|noUpd3,				0, mXor, f3
	dw #600,	scaleUp, scaleDown|mAnd, ais2,	0, mXor, c3,						#18|scaleDown, a3
	dw #600|noUpd1|noUpd3,				0, mXor, d3
	dw #600|noUpd1,					0, mXor, dis3,						#18|scaleDown, a3
	dw #600|noUpd1|noUpd3,				0, mXor, f3
	db endPtn
	
ptn6a
	dw #3000,	scaleUp, scaleDown|mAnd, rest,	phaseReset, #200, mXor, rest,				#2|scaleDown, c2|slideUp
	db endPtn
	

ptn7	
	dw #600,	scaleUp, scaleDown|mAnd, f2,	phaseReset, #100, mXor, f3,				#18|scaleDown, a3
	dw #600|noUpd1|noUpd3,				0, mXor, g3
	dw #600|noUpd1,					0, mXor, gis3,						0, rest
	dw #600|noUpd1|noUpd3,				0, mXor, ais3
	dw #600,	scaleUp, scaleDown|mAnd, f3,	0, mXor, f3,						#18|scaleDown, a3
	dw #600|noUpd1|noUpd3,				0, mXor, g3
	dw #600|noUpd1,					0, mXor, gis3,						0, rest
	dw #600|noUpd1|noUpd3,				0, mXor, ais3
	db endPtn
	
ptn7a	
	dw #600,	scaleUp, scaleDown|mAnd, f2,	phaseReset, #200, mXor, f3,				#18|scaleDown, a3
	dw #600|noUpd1|noUpd3,				0, mXor, g3
	dw #600|noUpd1,					0, mXor, gis3,						0, rest
	dw #600|noUpd1|noUpd3,				0, mXor, ais3
	dw #600,	scaleUp, scaleDown|mAnd, f3,	0, mXor, f3,						#18|scaleDown, a3
	dw #600|noUpd1|noUpd3,				0, mXor, g3
	dw #600|noUpd1,					0, mXor, gis3,						0, rest
	dw #600|noUpd1|noUpd3,				0, mXor, ais3
	db endPtn
	
ptn7b	
	dw #600,	scaleUp, scaleDown|mAnd, f2,	phaseReset, #400, mXor, f3,				#18|scaleDown, a3
	dw #600|noUpd1|noUpd3,				0, mXor, g3
	dw #600|noUpd1,					0, mXor, gis3,						0, rest
	dw #600|noUpd1|noUpd3,				0, mXor, ais3
	dw #600,	scaleUp, scaleDown|mAnd, f3,	0, mXor, f3,						#18|scaleDown, a3
	dw #600|noUpd1|noUpd3,				0, mXor, g3
	dw #600|noUpd1,					0, mXor, gis3,						0, rest
	dw #600|noUpd1|noUpd3,				0, mXor, ais3
	db endPtn
	
ptn8	
	dw #600,	scaleUp, scaleDown|mAnd, f2,	phaseReset, #600, mXor, f3,				#18|scaleDown, a3
	dw #600|noUpd1|noUpd3,				0, mXor, g3
	dw #600|noUpd1,					0, mXor, gis3,						0, rest
	dw #600|noUpd1|noUpd3,				0, mXor, ais3
	dw #600,	scaleUp, scaleDown|mAnd, gis3,	0, mXor, f3,						#18|scaleDown, a3
	dw #600|noUpd1|noUpd3,				0, mXor, g3
	dw #600|noUpd1,					0, mXor, gis3,						0, rest
	dw #600|noUpd1|noUpd3,				0, mXor, ais3
	db endPtn
	
ptn9	
	dw #600,	scaleUp, scaleDown|mAnd, f2,	scaleDown|phaseReset, #80, scaleUp|mXor, f4,		#18|scaleDown, a3
	dw #600|noUpd1|noUpd3,				scaleDown, scaleUp|mXor, g4
	dw #600|noUpd1,					scaleDown, scaleUp|mXor, gis4,				0, rest
	dw #600|noUpd1|noUpd3,				scaleDown, scaleUp|mXor, ais4
	dw #600,	scaleUp, scaleDown|mAnd, dis3,	scaleDown, scaleUp|mXor, f4,				#18|scaleDown, a3
	dw #600|noUpd1|noUpd3,				scaleDown, scaleUp|mXor, g4
	dw #600|noUpd1,					scaleDown, scaleUp|mXor, gis4,				#18|scaleDown, a3
	dw #600|noUpd1,					scaleDown, scaleUp|mXor, ais4,				#18|scaleDown, a3
	db endPtn
	
