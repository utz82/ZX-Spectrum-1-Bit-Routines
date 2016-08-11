#!/bin/sh

#handle command line options
if [ "$1" = "-t" ]
	then title=$2
	elif [ "$1" = "-a" ]
		then addr="$2"
	elif [ "$1" = "-c" ]
		then composer="$2"
fi

if [ "$3" = "-c" ]
	then composer="$4"
	elif [ "$3" = "-a" ]
		then addr="$4"
fi

if [ "$5" = "-a" ]
	then addr="$6"
fi

#set compile address to default if none was given
if [ -z $addr ] 
	then addr="32768"
fi
caddr=$(($addr - 1))

#generate loader.bas
echo "10 border 0: paper 0: ink 7: clear val \"$caddr\"" > loader.bas
echo "20 load \"\"code" >> loader.bas
if [ -n "$title" -a -n "$composer" ] 
	then echo "30 cls: print \"$title\": print \"by $composer\"" >> loader.bas
fi
if [ -n "$title" -a -z "$composer" ] 
	then echo "30 cls: print \"$title\"" >> loader.bas
fi
if [ -z "$title" -a -n "$composer" ] 
	then echo "30 cls: print \"a tune by $composer\"" >> loader.bas
fi
echo "40 randomize usr $addr" >> loader.bas

#convert music.xm + loader.tap, assemble, and generate test.tap
zmakebas -a 10 -o loader.tap loader.bas
#./xm2squeekerplus
if [ $? = 0 ]
then
	pasmo --equ origin=$addr --alocal --tap main.asm main.tap main.lst
	cat loader.tap main.tap > test.tap
	rm main.tap
	fuse-sdl --no-confirm-actions -m 128 -t test.tap
fi
rm loader.tap loader.bas