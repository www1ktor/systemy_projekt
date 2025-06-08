#!/bin/bash

i=0

COL_VALUE="sample*2"
TRY_PARSE=$(echo "$COL_VALUE" | grep -oE "\+|\-|\*|\/" | wc -l)

if [[ $TRY_PARSE -eq 1 ]]; then
	PARSED_OPERATION=$(echo "$COL_VALUE" | sed -E 's/(\+\-\*\/)/ \1 /')
	read A B C <<< "$PARSED_OPERATION"
else
	echo "huj!"
fi

echo $A $B $C
