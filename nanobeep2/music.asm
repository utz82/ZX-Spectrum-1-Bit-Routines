speed equ #f	

	dw ptn0
	dw ptn0
	dw ptn0
	dw ptn0
	dw ptn1
	dw ptn1
	dw ptn1
	dw ptn1
	dw ptn2
	dw ptn2
	dw ptn2
	dw ptn2
	dw ptn3
	dw ptn3
	dw ptn3
	dw ptn3
	dw ptn3
	dw ptn3
	dw ptn3
	dw ptn3a
	dw ptn1
	dw ptn1
	dw ptn1
	dw ptn1
	dw ptn2
	dw ptn2
	dw ptn2
	dw ptn2a
	dw ptn4
	dw ptn4
	dw ptn4
	dw ptn4
	dw ptn4
	dw ptn4
	dw ptn4
	dw ptn4a
	dw ptn5
	dw ptn5
	dw ptn5
	dw ptn5
	dw ptn6
	dw ptn6
	dw ptn6
	dw ptn7
	dw ptn6
	dw ptn6
	dw ptn6
	dw ptn6
	dw ptn6
	dw ptn6
	dw ptn6
	dw ptn6a
	dw ptn1
	dw ptn1
	dw ptn1
	dw ptn1
	dw ptn3
	dw ptn3
	dw ptn3
	dw ptn8
	dw ptn3
	dw ptn3
	dw ptn3
	dw ptn3
	dw 0
	
ptn0
	dw #0f00
	db hhat, c2, rest
	db c3, rest
	db c4, rest
	db c3, rest
	db ptnEnd

ptn1
	dw #0f00
	db hhat, c2, dis4
	db c3, dis4
	db c4, dis4
	db c3, dis4
	db ptnEnd
	
ptn2
	dw #0f00
	db hhat, c2, f4
	db c3, f4
	db c4, f4
	db c3, f4
	db ptnEnd
	
ptn2a
	dw #0f00
	db hhat, c2, f4
	db c3, f4
	db c4, dis4
	db c3, f4
	db ptnEnd
	
ptn3
	dw #0f00
	db hhat, c2, c4
	db c3, c4
	db c4, c4
	db c3, c4
	db ptnEnd
	
ptn3a
	dw #0f00
	db hhat, c2, c4
	db hhat, c3, c4
	db hhat, c4, rest
	db hhat, c3, rest
	db ptnEnd
	
ptn4
	dw #0f00
	db hhat, c2, g4
	db c3, g4
	db c4, g4
	db c3, g4
	db ptnEnd
	
ptn4a
	dw #0f00
	db hhat, c2, g4
	db hhat, c3, g4
	db hhat, c4, rest
	db hhat, c3, rest
	db ptnEnd

ptn5
	dw #0f00
	db hhat, gis1, dis4
	db gis2, dis4
	db gis3, dis4
	db gis2, dis4
	db ptnEnd	

ptn6
	dw #0f00
	db hhat, gis1, c4
	db gis2, c4
	db gis3, c4
	db gis2, c4
	db ptnEnd
	
ptn6a
	dw #0f00
	db hhat,g1, c4
	db g2, c4
	db g3, rest
	db g2, rest
	db ptnEnd
	
ptn7
	dw #0f00
	db hhat, gis1, c4
	db gis2, c4
	db gis3, ais3
	db gis2, ais3
	db ptnEnd

ptn8
	dw #0f00
	db hhat, c2, c4
	db c3, c4
	db c4, ais3
	db c3, ais3
	db ptnEnd
