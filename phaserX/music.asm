
	dw ptn1
	dw ptn1
loop
	dw ptn2
	dw ptn2
	dw ptn2
	dw ptn2a
	dw ptn3
	dw ptn3
	dw ptn2
	dw ptn2a
	dw ptn4
	dw ptn3
	dw ptn2
	dw ptn2a
	dw ptn5a
	dw ptn5
	dw ptn5
	dw ptn6
	dw ptn5
	dw ptn5
	dw ptn5
	dw ptn7
	dw ptn5a
	dw ptn5
	dw ptn5
	dw ptn6
	dw ptn5a
	dw ptn5
	dw ptn5a
	dw ptn8
	dw 0
	
	;speed+drums, method+flags, [dutymod/duty1, freq1], [dutymod2a/b, duty2a/b, freq2a, freq2b, phase2b]

ptn1
	dw #1000|kick,mix_xor|fsid,	#0080,c2,	0,0,rest,rest,0
	dw #0800,mix_xor|fsid|noupd2,	#0080,rest
	dw #0800,mix_xor|fsid|noupd2,	#0080,dis2
	dw #0800,mix_xor|fsid|noupd2,	#0080,e2
	dw #0800,mix_xor|fsid|noupd2,	#0080,f2
	
	dw #1000|hhat,mix_xor|fsid,	#0080,c2,	0,0,rest,rest,0
	dw #0800,mix_xor|fsid|noupd2,	#0080,rest
	dw #0800,mix_xor|fsid|noupd2,	#0080,dis2
	dw #0800,mix_xor|fsid|noupd2,	#0080,e2
	dw #0800,mix_xor|fsid|noupd2,	#0080,f2
	
	db ptnend

ptn2
	dw #1000|kick,mix_and|fsid,		#0080,c2,	#00c0,#4010,c3,c2+8,#4000
	dw #0800|kick,mix_and|fsid|noupd2,	#0080,rest
	dw #0800|hhat,mix_and|fsid,		#0080,dis2,	#00c0,#4010,dis3,dis2+8,#4000
	dw #0800,mix_and|fsid,			#0080,e2,	#00c0,#4010,e3,e2+8,#4000
	dw #0800|hhat,mix_and|fsid,		#0080,f2,	#00c0,#4010,f3,f2+8,#4000
	
	dw #1000|kick,mix_and|fsid,		#0080,c2,	#00c0,#4010,c3,c2+8,#4000
	dw #0800|kick,mix_and|fsid|noupd2,	#0080,rest
	dw #0800|hhat,mix_and|fsid,		#0080,dis2,	#00c0,#4010,dis3,dis2+8,#4000
	dw #0800,mix_and|fsid,			#0080,e2,	#00c0,#4010,e3,e2+8,#4000
	dw #0800|hhat,mix_and|fsid,		#0080,f2,	#00c0,#4010,f3,f2+8,#4000
	
	db ptnend
	
ptn2a
	dw #1000|kick,mix_and|fsid,		#0080,c2,	#00c0,#4010,c3,c2+8,#4000
	dw #0800|kick,mix_and|fsid|noupd2,	#0080,rest
	dw #0800|hhat,mix_and|fsid,		#0080,dis2,	#00c0,#4010,dis3,dis2+8,#4000
	dw #0800,mix_and|fsid,			#0080,e2,	#00c0,#4010,e3,e2+8,#4000
	dw #0800|hhat,mix_and|fsid,		#0080,f2,	#00c0,#4010,f3,f2+8,#4000
	
	dw #1000|kick,mix_and|fsid,		#0080,c2,	#00c0,#4010,c3,c2+8,#4000
	dw #0800|kick,mix_and|fsid|noupd2,	#0080,rest
	dw #0800|hhat,mix_and|fsid,		#0080,dis2,	#00c0,#4010,dis3,dis2+8,#4000
	dw #0800|hhat,mix_and|fsid,		#0080,e2,	#00c0,#4010,e3,e2+8,#4000
	dw #0800|hhat,mix_and|fsid,		#0080,f2,	#00c0,#4010,f3,f2+8,#4000
	
	db ptnend
	
ptn3
	dw #1000|kick,mix_and|fsid,		#0080,f2,	#00c0,#4010,f3,f2+8,#4000
	dw #0800|kick,mix_and|fsid|noupd2,	#0080,rest
	dw #0800|hhat,mix_and|fsid,		#0080,gis2,	#00c0,#4010,gis3,gis2+8,#4000
	dw #0800,mix_and|fsid,			#0080,ais2,	#00c0,#4010,ais3,ais2+8,#4000
	dw #0800|hhat,mix_and|fsid,		#0080,b2,	#00c0,#4010,b3,b2+8,#4000
	
	dw #1000|kick,mix_and|fsid,		#0080,f2,	#00c0,#4010,f3,f2+8,#4000
	dw #0800|kick,mix_and|fsid|noupd2,	#0080,rest
	dw #0800|hhat,mix_and|fsid,		#0080,gis2,	#00c0,#4010,gis3,gis2+8,#4000
	dw #0800,mix_and|fsid,			#0080,ais2,	#00c0,#4010,ais3,ais2+8,#4000
	dw #0800|hhat,mix_and|fsid,		#0080,b2,	#00c0,#4010,b3,b2+8,#4000
	
	db ptnend
	
ptn4
	dw #1000|kick,mix_and|fsid,		#0080,g2,	#00c0,#4010,g3,g2+8,#4000
	dw #0800|kick,mix_and|fsid|noupd2,	#0080,rest
	dw #0800|hhat,mix_and|fsid,		#0080,b2,	#00c0,#4010,b3,b2+8,#4000
	dw #0800,mix_and|fsid,			#0080,c3,	#00c0,#4010,c4,c3+8,#4000
	dw #0800|hhat,mix_and|fsid,		#0080,d3,	#00c0,#4010,d4,d3+8,#4000
	
	dw #1000|kick,mix_and|fsid,		#0080,g2,	#00c0,#4010,g3,g2+8,#4000
	dw #0800|kick,mix_and|fsid|noupd2,	#0080,rest
	dw #0800|hhat,mix_and|fsid,		#0080,b2,	#00c0,#4010,b3,b2+8,#4000
	dw #0800,mix_and|fsid,			#0080,c3,	#00c0,#4010,c4,c3+8,#4000
	dw #0800|hhat,mix_and|fsid,		#0080,d3,	#00c0,#4010,d4,d3+8,#4000
	
	db ptnend

ptn5
	dw #1000|kick,mix_and,			0,rest,		#00c0,#4010,c3,c2+8,#4000
	dw #0800|kick,mix_and|noupd1|noupd2
	dw #1000|hhat,mix_and|noupd1|noupd2
	dw #0800|hhat,mix_and|noupd1|noupd2
	
	db ptnend
	
ptn5a
	dw #0800|kick,mix_and|fnoise,		#0040,#2174,	#00c0,#4010,c3,c2+8,#4000
	dw #0800,mix_and|fnoise|noupd2,		#0020,#2174
	dw #0800|kick,mix_and|fnoise|noupd2,	#0010,#2174
	dw #0400|hhat,mix_and|fnoise|noupd2,	#0008,#2174
	dw #0c00,mix_and|noupd2,		0,rest
	dw #0800|hhat,mix_and|noupd1|noupd2
	
	db ptnend
	
ptn6
	dw #1000|kick,mix_and,			0,rest,		#00c0,#4010,c3,c2+8,#4000
	dw #0800|kick,mix_and|noupd1,				#00c0,#4010,dis3,dis2+8,#4000
	dw #1000|hhat,mix_and|noupd1|noupd2
	dw #0800|hhat,mix_and|noupd1|noupd2
	
	db ptnend
	
ptn7
	dw #1000|kick,mix_and,			0,rest,		#00c0,#4010,c3,c2+8,#4000
	dw #0800|kick,mix_and|noupd1,				#00c0,#4010,g3,g2+8,#4000
	dw #0800|hhat,mix_and|noupd1|noupd2
	dw #0800|hhat,mix_and|noupd1|noupd2
	dw #0800|hhat,mix_and|noupd1|noupd2
	
	db ptnend
	
ptn8
	dw #0800|kick,mix_and|fnoise,		#0040,#2174,	#00c0,#4010,c3,c2+8,#4000
	dw #0800,mix_and|fnoise|noupd2,		#0020,#2174
	dw #0800|kick,mix_xor|fnoise,		#0010,#2174,	#00c0,#4010,b3,b3+8,#4000
	dw #0800|hhat,mix_xor|fnoise|noupd2,	#0040,#2174
	dw #0800|hhat,mix_xor|fnoise|noupd2,	#0020,#2174
	dw #0400|hhat,mix_xor|fnoise|noupd2,	#0040,#2174
	dw #0400|hhat,mix_xor|fnoise|noupd2,	#0020,#2174
	
	db ptnend
	
