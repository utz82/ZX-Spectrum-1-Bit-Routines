
perl xm2nanobeep.pl
pasmo --alocal --tap main-light.asm main.tap
copy /b /y loader.tap+main.tap test.tap > nul
del main.tap