;example song for bm-1 beeper engine

;************************************************************************************************************************************************
;song sequence

mloop			;sequence loop point (mandatory)
	dw ptn0		;list of patterns
	dw ptn1
	dw ptn2
	dw ptnA
	dw 0		;sequence end marker (mandatory)
	
;************************************************************************************************************************************************
;pattern data
;
;DATA FORMAT:	ctrl0/drum param|0 (Z = end, C=no updates, PV = drum1, M = drum2)
;		ctrl1/patch1_7 (Z = no patch update, PV = skip patch 1-6, S = skip patch 8-11, C = skip all)
;			[patch_ptr, div1, [(if div1&0x8000) param1]]
;		ctrl2/patch2_7 (Z = no patch update, PV = skip patch 1-6, S = skip patch 8-11, C = skip all)
;			[patch_ptr, div2, [(if div2&0x8000) param2]]
;		ctrl3/speed (Z = no tbl_ptr update)
;
;
;          dr_cfg p1_7   patch1  div1   par1    p2_7   patch2  div2   par2    speed  tbl_ptr
;          ctrl0  ctrl1                         ctrl2                         ctrl3

ptn0	;basic pattern with example patch usage
	dw #1004, #0f00, patch2, c0,		#0000, patch0, rest,	      #1000, stopfx
	dw #0000, #0040,	 c1,		#0001,			      #1040
	dw #4080, #0000, patch1, c0/2,		#0001,			      #1040
	dw #0000, #0040,	 c0,		#0001,			      #1040
	db #40											;pattern end
	
ptn1	;patch with parameter and volume table
	dw #1004, #0f00, patch4, #810f,	#2010,	#0001,			      #1000, voltab1	;#801f = #8000|c1
	dw #0000, #0040,	 c2,		#0001,			      #1040
	dw #4080, #0040,	 c1,		#0001,			      #1040
	dw #0000, #0040,	 c2,		#0001,			      #1040
	db #40
	
ptn2	;sid sound and noise test
	dw #1004, #9f00, patch3, #810f,	#2000,	#0001,			      #1000, stopfx
	dw #0000, #0040,	 c2,		#0001,			      #1040
	dw #4080, #0040,	 c1,		#0001,			      #1040
	dw #0000, #0040,	 c2,		#0004, patch5, #2174,	      #1040
	db #40											;pattern end

ptnA	;table with code execution
	dw #1004, #0000, patch0, c0/2,		#0000, patch0, rest,	      #1000, tblCodeEx
	dw #0000, #0040,	 c0,		#0001,			      #1040
	dw #4080, #0000, patch1, c0/2,		#0001,			      #1040
	dw #0000, #0040,	 c0,		#0001,			      #1040
	db #40											;pattern end
	
;************************************************************************************************************************************************
;patch data
;4, 6, or 10 bytes of code, depending on ctrl1/ctrl2
	
patch0
	reset_all		;macro supplied by patches.h

patch1
	rrca			;patchX_1
	or h			;patchX_2
	ds 8

patch2
	saw_wave

patch3
	sid_sound_ch1

patch4
	duty_vol_ch1
	
patch5
	noise

;************************************************************************************************************************************************
;fx table data
;
;tbl_flags: Z = stop tbl_exec, C= no update, S = tbl_jump, PV = execute function (addr follows)
;if no flags set or function executed that jumps to tblStdUpdate, second ctrlbyte follows: Z = skip freq_div1, C=skip generic_param1, 
;											   S = skip freq_div2, PV = skip generic_param2
;data follows in order: freq_div1, generic_param1, freq_div2, generic_param2

stopfx
	db #40
	
voltab1
	db #01				;no update on this tick
	db #01
	dw #0000, #00c4, #2020		;skip div1, set param1, skip div2, skip param2
	db #01
	db #01
	dw #0000, #00c4, #2030
	db #01
	db #01
	dw #0000, #00c4, #2040
	db #01
	db #01
	dw #0000, #00c4, #2050
	db #01
	db #01
	dw #0000, #00c4, #2060
	db #01
	db #01
	dw #0000, #00c4, #2070
	dw #0080, voltab1		;jump to beginning of table
	
tblCodeEx
	dw #0004, runtimeMod
	db #40
	
;************************************************************************************************************************************************
;functions
;
;triggered by table execution
;each function must end with "jp noTableExec" or "jp tblStdUpdate"

runtimeMod
	ld a,#07			;rlca
	ld (patch1_7),a
	jp noTableExec

;************************************************************************************************************************************************