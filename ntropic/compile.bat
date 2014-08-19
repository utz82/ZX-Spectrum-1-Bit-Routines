
perl xm2ntropic.pl
pasmo --alocal --tap ntropic.asm main.tap
copy /b /y loader.tap+main.tap ntropic.tap > nul
del main.tap