
perl xm2octodepwm.pl
pasmo --alocal --tap main.asm main.tap
copy /b /y loader.tap+main.tap test.tap > nul
del main.tap