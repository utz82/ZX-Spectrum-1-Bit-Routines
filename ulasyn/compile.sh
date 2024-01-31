#!/bin/sh

zmakebas -a 10 -o loader.tap loader.bas
sjasmplus --lst main.asm
cat loader.tap main.tap >test.tap
rm main.tap
fuse --no-confirm-actions -m 48 -t test.tap
#fuse --no-confirm-actions --debugger-command="br 0x8000" -m 48 -t test.tap
