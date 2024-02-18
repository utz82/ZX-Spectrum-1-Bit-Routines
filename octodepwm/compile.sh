#!/bin/sh

./xm2octodepwm.pl
zmakebas -a 10 -o loader.tap loader.bas
pasmo --alocal --tap main.asm main.tap #main.lst
#pasmo -d --alocal main.asm main.bin
cat loader.tap main.tap >test.tap
rm loader.tap main.tap
fuse --no-confirm-actions -m 48 -t test.tap
