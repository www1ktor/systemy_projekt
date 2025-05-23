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

touch tables/$TABLE_NAME

DATA_TYPES=""
COLUMN_NAMES=""

while [ true ]; do 
	echo -n "Do you want to insert column? [Y/N]: "	
	read choice 

	if [ "$choice" = "n" ] || [ "$choice" = "N" ]; then 
		break
	fi
	
	if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then 
		clear

		echo "T:      TEXT eg. NQL"
		echo "I:  INTEGER eg. 2025"
		echo "F:  FLOAT eg. 3.1415"
		echo "B: BOOL [TRUE/FALSE]"
		echo "H:      TIME [HH:MM]"
		echo "D: DATE [DD-MM-YYYY]"
		
		while [ true ]; do 
			echo -n "Enter data type [T/I/F/B/H/D]: "
			read TYPE
			DATA_TYPE="${TYPE^^}"

			case "$DATA_TYPE" in
				"T") DATA_TYPE="TEXT" 
				        break ;;
			     	"I") DATA_TYPE="INTEGER"
					break ;;
				"F") DATA_TYPE="FLOAT"
					break ;;
				"B") DATA_TYPE="BOOL"
					break ;;
				"H") DATA_TYPE="TIME"
					break ;;
				"D") DATA_TYPE="DATE"
					break ;;
				*) echo "Wrong data type!" ;;
			esac
			
		done

		DATA_TYPES="$DATA_TYPES $DATA_TYPE;"
		echo "$DATA_TYPES"
		while [ true ]; do 
			echo -n "Enter column name: "
			read NAME

			COLUMN_NAME="${NAME#[$'\r\t\n']}"

			if [ "$COLUMN_NAME" = "" ]; then 
				echo "Column's name is empty!"
			fi

			COLUMN_NAME="${COLUMN_NAME#[$'\r\t\n']}"

			break

		done

		COLUMNS_NAMES="$COLUMNS_NAMES $COLUMN_NAME;"
		echo "$COLUMNS_NAMES"
	else
		echo "There's no option like: $choice"
	fi
done

echo $DATA_TYPES>>tables/$TABLE_NAME
echo $COLUMNS_NAMES>>tables/$TABLE_NAME

declare -i ID=1

while [ true ]; do
	echo -n "Do you want to insert values? [Y/N]: "
	read choice 

        if [ "$choice" = "n" ] || [ "$choice" = "N" ]; then
                break
        fi

        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
		echo "$ID"
        	ID=$(($ID + 1 ))	

	else
		echo "There's no option like: $choice"
	fi
done
