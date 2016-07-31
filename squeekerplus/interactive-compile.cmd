@echo off
setlocal EnableDelayedExpansion

echo
set /p stitle="song title: "
set /p composer="composer name: "
set /p addr="compile address/Enter to use default (recommended): "

if "!addr!"=="" (set /a addr=32768)
set /a caddr=addr-1

echo 10 border 0: paper 0: ink 7: clear val "%addr%">loader.bas
echo 20 load ""code>>loader.bas
echo 30 cls: print "%stitle%": print "by %composer%">>loader.bas
echo 40 randomize usr %addr%>>loader.bas

zmakebas.exe -a 10 -o loader.tap loader.bas
xm2squeekerplus.exe
if %ERRORLEVEL% equ 0 (
	pasmo --equ origin=%addr% --alocal --tap main.asm main.tap
	del main.tap
)
del loader.tap loader.bas