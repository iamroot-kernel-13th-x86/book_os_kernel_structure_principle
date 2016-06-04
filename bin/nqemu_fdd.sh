#!/bin/bash

FILES=""
rm os.img
for i in "$@" 
do
    echo "compile and append to os.img :  $i"
    filename="${i%.*}"
    nasm -f bin -o ${filename}.bin $i
    FILES="$FILES $filename.bin"
    echo "${filename}"
    echo "${FILES}"
#    cat ${filename}.bin >> os.img
#    rm  ${filename}.bin
done

echo ">>>  $FILES"
cat $FILES > os.img

qemu-system-x86_64 -fda os.img
