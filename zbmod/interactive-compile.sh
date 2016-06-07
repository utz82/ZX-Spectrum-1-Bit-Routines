#!/bin/sh

echo
read -p "song title: " title
read -p "composer name: " composer
read -p "compile address/Enter to use default (recommended!): " addr

if [ -z $addr ] 
	then addr="32768"
fi
caddr=$(($addr - 1))

echo "10 border 0: paper 0: ink 7: clear val \"$caddr\"" > loader.bas
echo "20 load \"\"code" >> loader.bas
echo "30 cls: print \"$title\": print \"by $composer\"" >> loader.bas
echo "40 randomize usr $addr" >> loader.bas

./zmakebas -a 10 -o loader.tap loader.bas
./xm2zbmod
if [ $? = 0 ]
then
	pasmo --equ origin=$addr --equ CPU=1 --alocal --tap main.asm main.tap
	if [ $? = 0 ]
	then
		cat loader.tap main.tap > test-nmos.tap
		pasmo --equ origin=$addr --equ CPU=2 --alocal --tap main.asm main.tap
		cat loader.tap main.tap > test-cmos.tap
		pasmo --equ origin=$addr --equ CPU=3 --alocal --tap main.asm main.tap
		cat loader.tap main.tap > test-emul.tap
		rm main.tap
		fuse-sdl --no-confirm-actions -m 48 -t test-emul.tap
	fi
fi
rm loader.tap loader.bas


