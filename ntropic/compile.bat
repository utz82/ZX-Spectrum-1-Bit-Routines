
perl xm2ntropic.pl
zmakebas.exe -a 10 -o loader.tap loader.bas
pasmo --alocal --tap ntropic.asm main.tap
copy /b /y loader.tap+main.tap ntropic.tap > nul
del main.tap
