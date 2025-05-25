#!/bin/bash

i=0

while [ true ]; do
       	read temp	
	
	if [ "$temp" = "" ]; then
		break
	fi
	
	arr[i]=$temp
	i=$(( $i + 1 ))
done

for i in "${arr[@]}"; do
	echo "$i"
done
