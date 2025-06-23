#!/bin/bash

clear

if [ "$(ls | grep -w "tables")" = "" ]; then
	mkdir tables
fi

LOGO () {
	echo "-------------------------"
	echo "- #    #   ###    #     -"
	echo "- ##   #  #   #   #     -"
	echo "- # #  #  #   #   #     -"
	echo "- #  # #   ###    #     -"
	echo "- #   ##     ###  ##### -"
	echo "-                       -"
	echo "-  NANO QUERY LANGUAGE  -"
	echo "-------------------------"

	echo "    1. CREATE   TABLE    "
	echo "    2. LOAD     TABLE    "
	echo "    3. START QUERYING    "
	echo "    4. DOCUMENTATNION    "
	echo "    5. EXIT   PROGRAM    "
}
while [ true ]; do
	clear
	LOGO
	
	echo -n "choose option [1-5]: "
	read choice
	

	clear

	case "$choice" in
		"1") ./create_table.sh  ;;
		"2") ./load_table.sh  ;;
		"3") ./nql.sh ;;
		"4") cat docs.txt ;;
		"5") exit 0 ;;

		*) echo "Syntax error! No option $choice found in menu. Try again!"
	esac
done

exit 0	
