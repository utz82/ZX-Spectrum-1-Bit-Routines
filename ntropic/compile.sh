#!/bin/sh

./xm2ntropic.pl
zmakebas -a 10 -o loader.tap loader.bas
pasmo -d --alocal --tap ntropic.asm main.tap
cat loader.tap main.tap >ntropic.tap
rm loader.tap main.tap
