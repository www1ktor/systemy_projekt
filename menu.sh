#!/bin/bash

clear

if [ "$(ls | grep -w "tables")" = "" ]; then
	mkdir tables
fi

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

while [ true ]; do
	echo -n "choose option [1-5]: "
	read choice

	case "$choice" in
		"1") ./create_table.sh
			exit 0 ;;
		"2") ./load_table.sh
			exit 0 ;;
		"3") ./nql.sh
			exit 0 ;;
		"4") cat docs.txt
			exit 0 ;;
		"5") exit 0 ;;

		*) echo "nope"
	esac
done

exit 0	


