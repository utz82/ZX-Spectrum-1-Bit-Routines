#!/bin/sh

./xm2ntropic.pl
pasmo -d --alocal --tap ntropic.asm main.tap
cat loader.tap main.tap > ntropic.tap
rm main.tap
