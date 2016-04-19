
perl xm2nanobeep.pl -u
pasmo --alocal --tap main-ultra.asm main.tap
copy /b /y loader.tap+main.tap test.tap > nul
del main.tap