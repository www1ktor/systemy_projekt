#!/bin/bash

KEYWORDS=( "SHOW" "DROP" "SELECT" "FROM" "WHERE" )

parse_query() {
	LINE=""
	i=0
	#dependancy on first query word, prevents from using dumb constructions 	eg. DROP "table_name" SELECT "something"

	for word in $QUERY; do
		if [[ ${KEYWORDS[@]} =~ ${word^^} ]]; then
			TO_PARSE[$i]=$LINE
			i=$(( $i + 1 )) 		
			
			LINE=${word^^}		
		else
			LINE="$LINE $word"
		
		fi	       
	done
	
	TO_PARSE[$i]=$LINE

	for x in "${TO_PARSE[@]}"; do
		RETURN_VAL=$($x)
		#echo $RETURN_VAL
        done

}

FROM () {
        if [[ $# -gt 1 ]]; then
                echo "Syntax error. Found more than 1 table to search in!"
                return 1
        fi

        if [[ $(ls tables | grep -w $1) == "$1" ]]; then
                TABLE_NAME=$1
		echo "cat tables/$TABLE_NAME"
                return 0

        else
                echo "Synatx error. No table named $1 found!"
                return 1
        fi


}

SELECT () {
	COLUMNS=$@
	N_O_COLUMNS=$#

	echo "$COLUMNS $N_O_COLUMNS"

	cat tables/$TABLE_NAME | head -1
}

WHERE () {
	echo $@
}

while [ true ]; do 
	echo -n "Enter query: "
	read QUERY
	
	if [ "${QUERY^^}" == "EXIT" ]; then
		break
	else
		parse_query $QUERY
	fi
	
		

done
