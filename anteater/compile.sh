#!/bin/sh

./xm2ant.pl
zmakebas -a 10 -o loader.tap loader.bas
pasmo -d --alocal --tap main.asm main.tap
cat loader.tap main.tap >anteat.tap
rm loader.tap main.tap
#fuse-sdl --no-confirm-actions -m 48 -t anteat.tap
