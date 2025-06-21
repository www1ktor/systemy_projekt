#!/bin/bash

ID_LIST=($(cat tables/test | sed 's/^ID.*//;/^$/d' | awk -F ';' '{print $1}'))

for (( x = 0; x < 5; ++x )); do
	CURR_ID=0

	for (( i = 1; i <= ${#ID_LIST[@]}; ++i )); do
		if [[ $(echo ${ID_LIST[@]} | grep -w "$i") ]]; then
			continue
		else
			CURR_ID=$i
			ID_LIST+=("$CURR_ID")
			break
		fi

	done
					
	if [[ $CURR_ID -eq 0 ]]; then 
		CURR_ID=$(( ${#ID_LIST[@]} + 1 ))
		ID_LIST+=("$CURR_ID")
	fi

	echo $CURR_ID 
	echo ${ID_LIST[@]}
done
