
perl xm2rawp.pl
pasmo --alocal --tap main.asm main.tap
copy /b /y loader.tap+main.tap rawp.tap > nul
del main.tap