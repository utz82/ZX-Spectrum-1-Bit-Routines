#!/bin/sh

./xm2nanobeep.pl -u
zmakebas -a 10 -o loader.tap loader.bas
pasmo -d --alocal --tap main-ultra.asm main.tap
cat loader.tap main.tap > test.tap
rm main.tap
fuse-sdl --no-confirm-actions -m 48 -t test.tap
