#!/bin/sh

./xm2quattropic.pl
#zmakebas -a 10 -o loader.tap loader.bas
pasmo --alocal --tap main.asm main.tap
cat loader.tap main.tap > test.tap
rm main.tap
fuse-sdl --no-confirm-actions -m 48 -t test.tap
