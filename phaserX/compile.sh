#!/bin/sh

zmakebas -a 10 -o loader.tap loader.bas
pasmo -d --alocal --tap main.asm main.tap main.lst
#pasmo -d --alocal main.asm main.bin
cat loader.tap main.tap > test.tap
rm main.tap
fuse-sdl --no-confirm-actions -m 48 -t test.tap
