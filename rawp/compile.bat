
perl xm2rawp.pl
zmakebas.exe -a 10 -o loader.tap loader.bas
pasmo --alocal --tap main.asm main.tap
copy /b /y loader.tap+main.tap rawp.tap > nul
del main.tap
