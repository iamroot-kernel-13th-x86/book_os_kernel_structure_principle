#!/bin/bash

rm os.img
for i in "$@" 
do
    echo "compile and append to os.img :  $i"
    filename="${i%.*}"
    nasm -f bin -o ${filename}.bin $i
    cat ${filename}.bin >> os.img
    rm  ${filename}.bin
done

qemu-system-x86_64 -s -S -fda os.img &
gdb
