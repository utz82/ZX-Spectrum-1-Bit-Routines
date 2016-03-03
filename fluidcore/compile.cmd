@echo off
setlocal EnableDelayedExpansion

set "param1=%1"
set "param2=%2"
set "param3=%3"
set "param4=%4"
set "param5=%5"
set "param6=%6"

rem handle command line options
if not defined param1 goto usedefault
if "!param1!"=="-t" (set stitle=%param2:"=%)
if "!param1!"=="-c" (set composer=%param2:"=%)
if "!param1!"=="-a" (set /a addr=param2)
if not defined param3 goto usedefault
if "!param3!"=="-c" (set composer=%param4:"=%)
if "!param3!"=="-a" (set /a addr=param4)
if not defined param5 goto usedefault
if "!param5!"=="-a" (set /a addr=param6)

:usedefault
rem set compile address to default if none was given
if "!addr!"=="" (set /a addr=32864)
set /a caddr=addr-1

rem generate loader.bas
echo 10 border 0: paper 0: ink 7: clear val "%caddr%">loader.bas
echo 20 load ""code>>loader.bas
if defined stitle goto titleset
if defined composer goto composerset
goto build

:titleset
if defined composer goto allset
echo 30 cls: print "%stitle%">>loader.bas
goto build

:composerset
echo 30 cls: print "a tune by %composer%">>loader.bas
goto build

:allset
echo 30 cls: print "%stitle%": print "by %composer%">>loader.bas

:build
echo 40 randomize usr %addr%>>loader.bas

rem convert music.xm + loader.tap, assemble, and generate test.tap
xm2fluid.exe
zmakebas.exe -a 10 -o loader.tap loader.bas
pasmo --equ origin=%addr% --equ Z80=1 --alocal --tap main.asm main.tap
copy /b /y loader.tap+main.tap test-nmos.tap > nul
pasmo --equ origin=%addr% --equ Z80=2 --alocal --tap main.asm main.tap
copy /b /y loader.tap+main.tap test-cmos.tap > nul
del main.tap
