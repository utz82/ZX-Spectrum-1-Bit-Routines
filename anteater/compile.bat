
perl xm2ant.pl
pasmo --alocal --tap main.asm main.tap
copy /b /y loader.tap+main.tap anteat.tap > nul
del main.tap