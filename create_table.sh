#!/bin/bash

clear

echo "Welcome in table creator."

while [ true ]; do
	echo -n "Enter name of table: "
	read NAME

	TABLE_NAME="${NAME#[$'\r\t\n']}"

	if [ "$TABLE_NAME" = "" ]; then 
		echo "Table's name is empty!"
	fi

	if [ "$(ls tables | grep -w "$TABLE_NAME")" != "" ]; then
		echo "Found a table named the same."
	else 
		break
	fi
	
done

echo "table: $TABLE_NAME"

DATA_TYPES=""
COLUMNS_NAMES="ID"
i=0

while [ true ]; do 
	echo -n "Do you want to insert column? [Y/N]: "	
	read choice 

	if [ "$choice" = "n" ] || [ "$choice" = "N" ]; then 
		break
	fi
	
	if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then 
		clear
		
		echo "table: $TABLE_NAME"
		echo
	
		while [ true ]; do 
			echo -n "Enter column name: "
			read NAME

			COLUMN_NAME="${NAME#[$'\r\t\n']}"

			if [ "$COLUMN_NAME" = "" ]; then 
				echo "Syntax error! Column's name is empty."
			elif [[ $(echo "$COLUMN_NAME" | grep " " | wc -l) -gt 0 ]]; then
				echo "Syntax error! Column's name cannot cointain space."
			elif [[ $(echo ${ATTRIBS_COLLECTION[@]} | grep -w "$COLUMN_NAME" | wc -l) -gt 0 ]]; then
				echo "Syntax error! Column's named $COLUMN_NAME already exists."
		       	else
				COLUMN_NAME="${COLUMN_NAME#[$'\r\t\n']}"
				ATTRIBS_COLLECTION[$i]=$COLUMN_NAME
				i=$(( $i + 1 ))
				break
			fi

		done

		COLUMNS_NAMES="$COLUMNS_NAMES;$COLUMN_NAME"
		echo "$COLUMNS_NAMES"
	else
		echo "Syntax error! There's no option like: $choice."
	fi
done

ID=1

if [ "$COLUMNS_NAMES" != "" ]; then
        touch tables/$TABLE_NAME
	
	echo ${COLUMNS_NAMES}>>tables/$TABLE_NAME

	while [ true ]; do
		echo -n "Do you want to insert values? [Y/N]: "
		read choice 

		if [ "$choice" = "n" ] || [ "$choice" = "N" ]; then
	                break
	        fi
	
	        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
			clear

			csvlook -I tables/$TABLE_NAME
			
			ROW="$ID"
        		ID=$(($ID + 1 ))

			for n in  "${ATTRIBS_COLLECTION[@]}"; do
				echo -n "$n: "
				read ATTRIB
				ATTRIB=${ATTRIB#[$'\r\t\n']}

				if [ "$ATTRIB" == "" ]; then
					ATTRIB="NULL"
				fi

				ROW="$ROW;$ATTRIB"

               		done
			
			echo ${ROW}>>tables/$TABLE_NAME
	
		else
			echo "Syntax error! There's no option like: $choice."
		fi
	done
fi
