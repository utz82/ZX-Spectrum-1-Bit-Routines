
IF (CPU = EMUL)

XCE1noCh1Reload			;(116)
	ld a,(hl)		;7
	ld a,(hl)		;7
	jr _zz			;12
_zz	jp CE1noCh1Reload	;10 (152)

ENDIF


XC0noCh1Reload			;(116)
	ld a,(hl)		;7
	ld a,(hl)		;7
	jr _zz			;12
_zz	jp C0noCh1Reload	;10 (152)

XC1noCh1Reload			;60
	ld a,(hl)		;7
	ld a,(hl)		;7
	nop			;4 (78)
	dw outhi		;12
	jr _ab			;12
_ab	dw outlo		;12 (114)

	pop hl			;10
	push hl			;11
	ld a,(hl)		;7
	jp C1noCh1Reload	;10 (152)
	
XC2noCh1Reload			;60
	ld a,(hl)		;7
	ld a,(hl)		;7
	nop			;4 (78)
	dw outhi		;12
	ds 2			;8
	jr _ab			;12
_ab	dw outlo		;12 (114)

	ds 2			;8
	jr _ac			;12
_ac	jp C2noCh1Reload	;10 (152)

XC3noCh1Reload			;60
	ld a,(hl)		;7
	ld a,(hl)		;7
	nop			;4 (78)
	dw outhi		;12__
	nop			;4
	jr _ab			;12
_ab	jr _bc			;12
_bc	dw outlo		;12__40 (114)
	
	jr _ac			;12
_ac	jp C3noCh1Reload	;10 (152)

XC4noCh1Reload			;(22)
	ex (sp),hl		;19
	ex (sp),hl		;19
	ld a,(hl)		;7
	ld a,(hl)		;7
	nop			;4 (78)
	dw outhi		;12__
	jr _ab			;12
_ab	jr _bc			;12
_bc	jr _ac			;12
_ac	dw outlo		;12__48 (114)
	
	nop			;4
	jp C4noCh1Reload	;10 (152)

XC5noCh1Reload			;(22)
	ex (sp),hl		;19
	ex (sp),hl		;19
	ld a,(hl)		;7
	ld a,(hl)		;7
	nop			;4 (78)
	dw outhi		;12
	
	jr _ab			;12
_ab	jr _bc			;12
_bc	jr _ac			;12
_ac	jp C5noCh1Reload	;10 (136)

XC5noCh3Reload
	ld a,(hl)		;7
	ld a,(hl)		;7
	ds 2			;8
	dw outlo		;12__56
	ex (sp),hl		;19
	ex (sp),hl		;19
	pop af			;10
	push af			;11
	ld a,(hl)		;7
	nop			;4
	jp C5noCh3Reload	;10 (+12+10+4=140)
	
XC6noCh1Reload			;(22)
	ex (sp),hl		;19
	ex (sp),hl		;19
	ld a,(hl)		;7
	ld a,(hl)		;7 (74)
	dw outhi		;12
	
	jr _ab			;12
_ab	jr _bc			;12
_bc	jr _ac			;12
_ac	jp C6noCh1Reload	;10 (132)

XC6noCh3Reload
	ld a,(hl)		;7
	ld a,(hl)		;7
	nop			;4
	jp _aa			;12
_aa	dw outlo		;12__64
	ex (sp),hl		;19
	ex (sp),hl		;19
	ret nc			;5
	ret nc			;5
	ld a,(hl)		;7
	jp C6noCh3Reload	;10 (+12+10+4=133)


XC7noCh1Reload			;(22)
	ex (sp),hl		;19
	ex (sp),hl		;19
	ld a,(hl)		;7
	ld a,(hl)		;7 (74)
	dw outhi		;12
	
	jr _ab			;12
_ab	jr _bc			;12
_bc	jr _ac			;12
_ac	jp C7noCh1Reload	;10 (132)

XC7noCh2Reload			;(98)
	jr _aa			;12
_aa	jp C7noCh2Reload	;10 (120)

XC7noCh3Reload			;(22)
	ld a,(hl)		;7
	ld a,(hl)		;7
	jr _aa			;12
_aa	jr _bb			;12
_bb	dw outlo		;12__72
	ex (sp),hl		;19
	ex (sp),hl		;19
	ld a,(hl)		;7
	ld a,(hl)		;7
	jp C7noCh3Reload	;10 (134)


XC8noCh1Reload			;(22)
	ex (sp),hl		;19
	ex (sp),hl		;19
	ld a,(hl)		;7
	ld a,(hl)		;7 (74)
	dw outhi		;12
	
	jr _ab			;12
_ab	jr _bc			;12
_bc	jr _ac			;12
_ac	jp C8noCh1Reload	;10 (132)

XC8noCh2Reload			;(106)
	nop			;4
	jp C8noCh2Reload	;10 (120)

XC8noCh3Reload			;(22)
	ex (sp),hl		;19
	ex (sp),hl		;19
	ds 2			;8
	dw outlo		;12__80
	ex (sp),hl		;19
	ex (sp),hl		;19
	ret nc			;5
	jp C8noCh3Reload	;10 (+4=137)


XC9noCh1Reload			;(22)
	ex (sp),hl		;19
	ex (sp),hl		;19
	ld a,(hl)		;7
	ld a,(hl)		;7 (74)
	dw outhi		;12
	
	jr _ab			;12
_ab	jr _bc			;12
_bc	jr _ac			;12
_ac	jp C9noCh1Reload	;10 (132)

XC9noCh3Reload			;(22)
	ex (sp),hl		;19
	ex (sp),hl		;19
	nop			;4
	jr _aa			;12
_aa	dw outlo		;12__88
	nop			;4
	pop af			;10
	push af			;11
	jp _cc			;10
_cc	jp C9noCh3Reload	;10 (+4=137)


XC10noCh1Reload			;(22)
	ex (sp),hl		;19
	ex (sp),hl		;19
	ld a,(hl)		;7
	ld a,(hl)		;7 (74)
	dw outhi		;12
	
	jr _ab			;12
_ab	jr _bc			;12
_bc	jr _ac			;12
_ac	jp C10noCh1Reload	;10 (132)

XC10noCh3Reload			;(22)
	ex (sp),hl		;19
	ex (sp),hl		;19
	jr _aa			;12
_aa	jr _bb			;12
_bb	dw outlo		;12__96
	pop af			;10
	push af			;11
	jp _cc			;10
_cc	jp C10noCh3Reload	;10 (137)


XC11noCh1Reload			;(22)
	ex (sp),hl		;19
	ex (sp),hl		;19
	ld a,(hl)		;7
	ld a,(hl)		;7 (74)
	dw outhi		;12
	
	jr _ab			;12
_ab	jr _bc			;12
_bc	jr _ac			;12
_ac	jp C11noCh1Reload	;10 (132)

XC11noCh3Reload			;(22)
	ex (sp),hl		;19
	ex (sp),hl		;19
	jr _aa			;12
_aa	jr _bb			;12
_bb	ds 2			;8
	dw outlo		;12__104
	ld a,(hl)		;7
	ld a,(hl)		;7
	ret nc			;5
	jp C11noCh3Reload	;10 (+4=137)


XC12noCh1Reload			;(43)
	ex (sp),hl		;19
	ex (sp),hl		;19
	ds 2			;8
	jr _aa			;12 (101)
_aa	dw outhi		;12
	
	jr _ab			;12
_ab	jr _bc			;12
_bc	jr _ac			;12
_ac	jp C12noCh1Reload	;10 (159)

XC12noCh2Reload			;(__101/41)
	ld a,(hl)		;7
	nop			;4
	dw outlo		;12__121 TODO: should be 112
	ex (sp),hl		;19
	ex (sp),hl		;19
	ds 2			;8
	jp C12noCh2Reload	;10 (120)

XC12noCh3Reload			;(22)
	ex (sp),hl		;19
	ex (sp),hl		;19
	nop			;4
	jr _aa			;12
_aa	jr _bb			;12
_bb	jr _cc			;12
_cc	dw outlo		;12__112
	jp _dd			;10
_dd	jp C12noCh3Reload	;10 (+4=137)


XC13noCh1Reload			;(43)
	ex (sp),hl		;19
	ex (sp),hl		;19
	jr _aa			;12 (101)
_aa	dw outhi		;12
	
	jr _ab			;12
_ab	jr _bc			;12
_bc	jr _ac			;12
_ac	jp C13noCh1Reload	;10 (159)

XC13noCh2Reload			;(__101/41)
	ld a,(hl)		;7
	dw outlo		;12__120
	ex (sp),hl		;19
	ex (sp),hl		;19
	jr _aa			;12
_aa	jp C13noCh2Reload	;10 (120)

XC13noCh3Reload			;(22)
	ex (sp),hl		;19
	ex (sp),hl		;19
	ex (sp),hl		;19
	ex (sp),hl		;19
	ds 2			;8
	jp C13noCh3Reload	;10 (116)


XC14noCh1Reload			;(29)
	ds 2			;8     (37)
	dw outlo		;12__128
	ex (sp),hl		;19
	ex (sp),hl		;19
	ld a,(hl)		;7
	ld a,(hl)		;7 (101)
	dw outhi		;12
	
	jr _ab			;12
_ab	jr _bc			;12
_bc	jr _ac			;12
_ac	jp C14noCh1Reload	;10 (159)

XC14noCh2Reload			;(__101/41)
	ld a,(hl)		;7
	dw outlo		;12__128
	ld a,(hl)		;7
	ld a,(hl)		;7
	ld a,(hl)		;7
	ret po			;5
	jr _aa			;12
_aa	jr _bb			;12
_bb	jp C14noCh2Reload	;10 (120)

XC14noCh3Reload			;(22)
	ex (sp),hl		;19
	ex (sp),hl		;19
	ex (sp),hl		;19
	ex (sp),hl		;19
	ds 2			;8
	jp C14noCh3Reload	;10 (116)


XC15noCh1Reload			;(29)
	jr _aa			;12
_aa	nop			;4
	dw outlo		;12__136
	ld a,(hl)		;7
	ld a,(hl)		;7
	ld a,(hl)		;7
	ld a,(hl)		;7
	ld a,(hl)		;7
	ret nz			;5
	nop			;4
	dw outhi		;12
	
	jr _ab			;12
_ab	jr _bc			;12
_bc	jr _ac			;12
_ac	jp C15noCh1Reload	;10 (159)

XC15noCh2Reload			;(__101/41)
	ld a,(hl)		;7
	jr _aa			;12
_aa	nop			;4
	dw outlo		;12__136
	ld a,(hl)		;7
	ld a,(hl)		;7
	ds 2			;8
	jr _bb			;12
_bb	jp C15noCh2Reload	;10 (120)

XC15noCh3Reload			;(22)
	ex (sp),hl		;19
	ex (sp),hl		;19
	ex (sp),hl		;19
	ex (sp),hl		;19
	ds 2			;8
	jp C15noCh3Reload	;10 (116)


XC16noCh1Reload			;(29)
	jr _aa			;12
_aa	jr _bb			;12
_bb	dw outlo		;12__144
	ld a,(hl)		;7
	ld a,(hl)		;7
	ld a,(hl)		;7
	ld a,(hl)		;7
	ds 2			;8
	dw outhi		;12
	
	jr _ab			;12
_ab	jr _bc			;12
_bc	jr _ac			;12
_ac	jp C16noCh1Reload	;10 (159)

XC16noCh2Reload			;(__101/41)
	ld a,(hl)		;7
	jr _aa			;12
_aa	jr _ab			;12
_ab	dw outlo		;12__144
	ld a,(hl)		;7
	ld a,(hl)		;7	
	jr _bb			;12
_bb	jp C16noCh2Reload	;10 (120)

XC16noCh3Reload			;(22)
	ex (sp),hl		;19
	ex (sp),hl		;19
	ex (sp),hl		;19
	ex (sp),hl		;19
	ds 2			;8
	jp C16noCh3Reload	;10 (116)


XC17noCh1Reload			;(29)
	jr _aa			;12
_aa	jr _bb			;12
_bb	ds 2			;8
	dw outlo		;12__152
	ld a,(hl)		;7
	ld a,(hl)		;7
	ld a,(hl)		;7
	ld a,(hl)		;7	
	dw outhi		;12
	
	jr _ab			;12
_ab	jr _bc			;12
_bc	jr _ac			;12
_ac	jp C17noCh1Reload	;10 (159)

XC17noCh2Reload			;(__101/41)
	ld a,(hl)		;7
	jr _aa			;12
_aa	jr _ab			;12
_ab	ds 2			;8
	dw outlo		;12__152
	ld a,(hl)		;7
	ld a,(hl)		;7	
	nop			;4
	jp C17noCh2Reload	;10 (120)


XC18noCh1Reload			;(29)
	jr _aa			;12
_aa	jr _bb			;12
_bb	jr _cc			;12
_cc	nop			;4
	dw outlo		;12__160
	jr _dd			;12
_dd	ds 2			;8
	dw outhi		;12
	
	jr _ab			;12
_ab	jr _bc			;12
_bc	jr _ac			;12
_ac	jp C18noCh1Reload	;10 (159)

XC18noCh2Reload			;(__101/41)
	ld a,(hl)		;7
	jr _aa			;12
_aa	jr _ab			;12
_ab	jr _ac			;12
_ac	nop			;4
	dw outlo		;12__160
	jp _ad			;10
_ad	jp C18noCh2Reload	;10 (120)


XC19noCh1Reload			;(29)
	jr _aa			;12
_aa	jr _bb			;12
_bb	jr _cc			;12
_cc	jr _cd			;12
_cd	dw outlo		;12__168
	jr _dd			;12
_dd	dw outhi		;12
	
	jr _ab			;12
_ab	jr _bc			;12
_bc	jr _ac			;12
_ac	jp C19noCh1Reload	;10 (159)

XC19noCh2Reload			;(__101/41)
	ld a,(hl)		;7
	jr _aa			;12
_aa	jr _ab			;12
_ab	jr _ac			;12
_ac	nop			;4
	jp _ad			;10
_ad	dw outlo		;12__170 hmmm
	jp C19noCh2Reload	;10 (120)


IF (CPU != EMUL)

XC20noCh1Reload			;(29)
	jr _aa			;12
_aa	jr _bb			;12
_bb	jr _cc			;12
_cc	jr _cd			;12
_cd	ds 2			;8
	dw outlo		;12__176
	nop			;4
	dw outhi		;12
	
	jr _ab			;12
_ab	jr _bc			;12
_bc	jr _ac			;12
_ac	jp C20noCh1Reload	;10 (159)

ENDIF
