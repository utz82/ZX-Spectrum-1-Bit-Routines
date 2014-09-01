#!/bin/sh

./xm2rawp.pl
#zmakebas -a 10 -o loader.tap loader.bas
pasmo --alocal --tap rawp.asm main.tap
cat loader.tap main.tap > rawp.tap
rm main.tap
fuse-sdl --no-confirm-actions -m 48 -t rawp.tap
