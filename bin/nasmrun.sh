#!/bin/bash

FILES=""
mkdir -p build
rm os.img
for i in "$@" 
do
    filename="${i%.*}"
    nasm -f bin -o ./build/${filename}.bin $i
    FILES="$FILES ./build/$filename.bin"
done

cat $FILES > ./build/os.img
ndisasm -b 16 ./build/os.img > ./build/os_disasm.txt

qemu-system-x86_64 -curses -fda ./build/os.img
