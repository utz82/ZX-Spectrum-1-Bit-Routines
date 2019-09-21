#!/bin/sh

zmakebas -a 10 -o loader.tap loader.bas
pasmo -d --alocal --tap test.asm main.tap test.lst
cat loader.tap main.tap > test.tap
rm main.tap
fuse --no-confirm-actions -m 48 -t test.tap
