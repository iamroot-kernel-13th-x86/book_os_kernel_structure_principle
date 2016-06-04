#!/bin/bash

FILES=""
rm os.img
for i in "$@" 
do
    filename="${i%.*}"
    nasm -f bin -o ${filename}.bin $i
    FILES="$FILES $filename.bin"
done

cat $FILES > os.img

qemu-system-x86_64 -curses -fda os.img
