
	dw ptn0
	dw ptn0
	dw ptn0
	dw ptn0
mloop
	dw ptn1
	dw ptn1
	dw ptn1
	dw ptn2
	dw ptn3
	dw ptn3
	dw ptn3
	dw ptn2a
	dw ptn2
	dw ptn2
	dw ptn4
	dw ptn4
	dw ptn3
	dw ptn3
	dw ptn3
	dw ptn3a
	dw ptn1
	dw ptn1
	dw ptn1
	dw ptn2
	dw ptn3
	dw ptn3
	dw ptn3
	dw ptn2a
	dw ptn2
	dw ptn2
	dw ptn4
	dw ptn4
	dw ptn3
	dw ptn3
	dw ptn3
	dw ptn3a
	dw interlude1
	dw interlude1a
	dw 0
	
	;speed+flags, (z = end, c = skip update ch1, pe = skip update ch2, m = skip update ch3)
	;[prescale1A*256+flags, [phaseOffset1,] mixMethod1*256+preScale1B, freqDiv1,] (z = enable duty mod, c = reset phase)
	;[mixMethod2*256+flags, [phaseOffset2, dutySweepAdd*256,] preScale2B*256+preScale2A, freqDiv2,] (z = enable duty mod, c = reset phase)
	;[postScale3+slideAmount, slideDirectionFlag+freqDiv3 (bit 15)]
	
interlude1
	dw #c000,	phaseReset, 0, mNone, rest,					phaseReset|dutyModOn|mOr, #100, #2000, 0, g3,	#2, c3
	dw #4000,	phaseReset, 0, mNone, rest,					phaseReset|dutyModOn|mOr, #100, #2000, 0, dis3,	1, a0
	dw #c000|noUpd3,	phaseReset, 0, mNone, rest,				phaseReset|dutyModOn|mOr, #100, #2000, 0, fis3
	dw #2000,	phaseReset, 0, mNone, rest,					phaseReset|dutyModOn|mOr, #100, #2000, 0, dis3,	0, rest
	dw #2000,	phaseReset, 0, mNone, rest,					phaseReset|dutyModOn|mOr, #100, #2000, 0, d3,	0, rest
	dw #8000,	phaseReset, 0, mNone, rest,					phaseReset|dutyModOn|mOr, #100, #2000, 0, dis3,	0, rest
	dw #8000,	phaseReset, 0, mNone, rest,					phaseReset|dutyModOn|mOr, #100, #2000, 0, c3,	0, rest
	dw #8000,	phaseReset, 0, mNone, rest,					phaseReset|dutyModOn|mOr, #100, #2000, 0, fis3,	0, rest
	dw #8000,	phaseReset, 0, mNone, rest,					dutyModOn|mOr, #2000, 0, fis3,			0, rest
	dw endPtn
	
interlude1a
	dw #c000,	phaseReset|dutyModOn|dMod*256, #100, mOr, c1,			phaseReset|dutyModOn|mOr, #100, #2000, 0, g3,	0, rest
	dw #4000|noUpd1,								phaseReset|dutyModOn|mOr, #100, #2000, 0, dis3,	0, rest
	dw #c000,	phaseReset|dutyModOn|dMod*256, #100, scaleDown|mXor, fis1,	phaseReset|dutyModOn|mOr, #100, #2000, 0, fis3,	0, rest
	dw #2000|noUpd1,								phaseReset|dutyModOn|mOr, #100, #2000, 0, dis3,	0, rest
	dw #2000|noUpd1,								phaseReset|dutyModOn|mOr, #100, #2000, 0, d3,	0, rest
	dw #8000,	phaseReset|dutyModOn|dMod*256, #100, scaleDown|mXor, c1,	phaseReset|dutyModOn|mOr, #100, #2000, 0, dis3,	0, rest
	dw #8000|noUpd1,								phaseReset|dutyModOn|mOr, #100, #2000, 0, c3,	0, rest
	dw #8000,	phaseReset|dutyModOn|dMod*256, #100, scaleDown|mXor, fis1,	phaseReset|dutyModOn|mOr, #100, #2000, 0, fis3,	0, rest
	dw #8000|noUpd1,								dutyModOn|mOr, #2000, 0, fis3,			0, rest
	dw endPtn	
	
ptn0
	dw #800,	phaseReset|dutyModOn|dMod*256, #100, scaleDown|mXor, c1,	phaseReset|mXor|dutyModOn, 0, 0, 0, rest,	#20|scaleDown*256, a3
	dw #800|noUpd1|noUpd2,												0, rest
	dw #800,	dutyModOn|dMod*256, scaleDown|mXor, c2,				mXor, 0, rest,			0, rest
	dw #800|noUpd1|noUpd2,												0, rest
	
	dw #400|noUpd2|noUpd3,	phaseReset|#cb*256, #100, #2|mNone, #235
	dw #c00,	phaseReset|dutyModOn|dMod*256, #100, scaleDown|mXor, c1,	phaseReset|mXor, 0, 0, rest,	0, rest
	dw #800,	dutyModOn|dMod*256, mXor, c2,					mXor, 0, rest,			#20|scaleDown*256, a3
	dw #800|noUpd1|noUpd2,												0, rest

	dw endPtn
	
ptn1
	dw #400,	phaseReset|dutyModOn|dMod*256, #100, scaleDown|mXor, c1,	phaseReset|mOr|dutyModOn, #100, 0, scaleDown, c4,	#20|scaleDown*256, a3
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, g4
	dw #400|noUpd1,									mOr, scaleDown, c4,			0, rest
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, g4
	dw #400,	dutyModOn|dMod*256, scaleDown|mXor, c2,				mOr, scaleDown, c4,			0, rest
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, g4
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, c4
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, g4
	
	dw #400,	phaseReset|#cb*256, #100, #2|mNone, #235,			phaseReset|mOr, #100, scaleDown, c4,	#20|scaleDown*256, a3
	dw #400|noUpd3,	phaseReset|dutyModOn|dMod*256, #100, scaleDown|mXor, c1,	mOr, scaleDown, g4
	dw #400|noUpd1,									mOr, scaleDown, c4,			0, rest
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, g4
	dw #400,	dutyModOn|dMod*256, scaleDown|mXor, c2,				mOr, scaleDown, c4,			0, rest
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, g4
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, c4
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, g4

	dw endPtn
	
ptn2
	dw #400,	phaseReset|dutyModOn|dMod*256, #100, scaleDown|mXor, c1,	phaseReset|mOr, #100, scaleDown, c4,	#20|scaleDown*256, a3
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, dis4
	dw #400|noUpd1,									mOr, scaleDown, c4,			0, rest
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, dis4
	dw #400,	dutyModOn|dMod*256, scaleDown|mXor, c2,				mOr, scaleDown, c4,			0, rest
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, dis4
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, c4
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, dis4
	
	dw #400,	phaseReset|#cb*256, #100, #2|mNone, #235,			phaseReset|mOr, #100, scaleDown, c4,	#20|scaleDown*256, a3
	dw #400|noUpd3,	phaseReset|dutyModOn|dMod*256, #100, scaleDown|mXor, c1,	mOr, scaleDown, dis4
	dw #400|noUpd1,									mOr, scaleDown, c4,			0, rest
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, dis4
	dw #400,	dutyModOn|dMod*256, scaleDown|mXor, c2,				mOr, scaleDown, c4,			0, rest
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, dis4
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, c4
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, dis4

	dw endPtn
	
ptn2a
	dw #400,	phaseReset|dutyModOn|dMod*256, #100, scaleDown|mXor, c1,	phaseReset|mOr, #100, scaleDown, c4,	#20|scaleDown*256, a3
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, dis4
	dw #400|noUpd1,									mOr, scaleDown, c4,			0, rest
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, dis4
	dw #400,	dutyModOn|dMod*256, scaleDown|mXor, c2,				mOr, scaleDown, c4,			0, rest
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, dis4
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, c4
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, dis4
	
	dw #400,	phaseReset|#cb*256, #100, #2|mNone, #235,			phaseReset|mOr, #100, scaleDown, c4,	#20|scaleDown*256, a3
	dw #400|noUpd3,	phaseReset|dutyModOn|dMod*256, #100, scaleDown|mXor, c1,	mOr, scaleDown, d4
	dw #400|noUpd1,									mOr, scaleDown, c4,			0, rest
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, d4
	dw #400,	dutyModOn|dMod*256, scaleDown|mXor, c2,				mOr, scaleDown, c4,			0, rest
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, d4
	dw #400,	phaseReset|#cb*256, #100, #2|mNone, #235,			phaseReset|mOr, #100, scaleDown, c4,	0, rest
	dw #400|noUpd3,	phaseReset|dutyModOn|dMod*256, #100, scaleDown|mXor, c2,	mOr, scaleDown, d4

	dw endPtn
	
ptn3
	dw #400,	phaseReset|dutyModOn|dMod*256, #100, scaleDown|mXor, c1,	phaseReset|mOr, #100, scaleDown, c4,	#20|scaleDown*256, a3
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, fis4
	dw #400|noUpd1,									mOr, scaleDown, c4,			0, rest
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, fis4
	dw #400,	dutyModOn|dMod*256, scaleDown|mXor, c2,				mOr, scaleDown, c4,			0, rest
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, fis4
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, c4
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, fis4
	
	dw #400,	phaseReset|#cb*256, #100, #2|mNone, #235,			phaseReset|mOr, #100, scaleDown, c4,	#20|scaleDown*256, a3
	dw #400|noUpd3,	phaseReset|dutyModOn|dMod*256, #100, scaleDown|mXor, c1,	mOr, scaleDown, fis4
	dw #400|noUpd1,									mOr, scaleDown, c4,			0, rest
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, fis4
	dw #400,	dutyModOn|dMod*256, scaleDown|mXor, c2,				mOr, scaleDown, c4,			0, rest
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, fis4
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, c4
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, fis4

	dw endPtn
	
ptn3a
	dw #400,	phaseReset|dutyModOn|dMod*256, #100, scaleDown|mXor, c1,	phaseReset|mOr, #100, scaleDown, c4,	#20|scaleDown*256, a3
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, fis4
	dw #400|noUpd1,									mOr, scaleDown, c4,			0, rest
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, fis4
	dw #400,	dutyModOn|dMod*256, scaleDown|mXor, c2,				mOr, scaleDown, c4,			0, rest
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, fis4
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, c4
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, fis4
	
	dw #400,	phaseReset|#cb*256, #100, #2|mNone, #235,			phaseReset|mOr, #100, scaleDown, c4,	#20|scaleDown*256, a3
	dw #400|noUpd3,	phaseReset|dutyModOn|dMod*256, #100, scaleDown|mXor, c1,	mOr, scaleDown, fis4
	dw #400|noUpd1,									mOr, scaleDown, c4,			#20|scaleDown*256, a3
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, fis4
	dw #400,	dutyModOn|dMod*256, scaleDown|mXor, c2,				mOr, scaleDown, c4,			#20|scaleDown*256, a3
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, fis4
	dw #400|noUpd1,									mOr, scaleDown, c4,			#20|scaleDown*256, a3
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, fis4

	dw endPtn
	
ptn4
	dw #400,	phaseReset|dutyModOn|dMod*256, #100, scaleDown|mXor, c1,	phaseReset|mOr, #100, scaleDown, g3,	#20|scaleDown*256, a3
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, c4
	dw #400|noUpd1,									mOr, scaleDown, g3,			0, rest
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, c4
	dw #400,	dutyModOn|dMod*256, scaleDown|mXor, c2,				mOr, scaleDown, g3,			0, rest
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, c4
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, g3
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, c4
	
	dw #400,	phaseReset|#cb*256, #100, #2|mNone, #235,			phaseReset|mOr, #100, scaleDown, g3,	#20|scaleDown*256, a3
	dw #400|noUpd3,	phaseReset|dutyModOn|dMod*256, #100, scaleDown|mXor, c1,	mOr, scaleDown, c4
	dw #400|noUpd1,									mOr, scaleDown, g3,			0, rest
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, c4
	dw #400,	dutyModOn|dMod*256, scaleDown|mXor, c2,				mOr, scaleDown, g3,			0, rest
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, c4
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, g3
	dw #400|noUpd1|noUpd3,								mOr, scaleDown, c4

	dw endPtn
	
