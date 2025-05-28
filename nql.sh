#!/bin/bash 

KEYWORDS=( "SHOW" "DROP" "SELECT" "FROM" "WHERE" )

parse_query() {
	LINE=""
	i=0

	for word in $QUERY; do	
		if [[ ${KEYWORDS[@]} =~ ${word^^} ]]; then
			TO_PARSE[$i]=$LINE
			i=$(( $i + 1 )) 		
	
			LINE=${word^^}		
		else
			if [[ $i -eq 0 ]]; then
				return 1
			fi
			
			LINE="$LINE $word"
		
		fi	       
	done
	
	TO_PARSE[$i]=$LINE
	PROMPT=""
	CHECK=1

	for FUNCTION in "${TO_PARSE[@]}"; do
		RETURN_VAL=$($FUNCTION)
		
		if [[ $? == 1 ]]; then 
			CHECK=0		
			echo $RETURN_VAL
			break
		fi

		#echo "$RETURN_VAL"
		if [[ "$RETURN_VAL" != "" ]]; then
			PROMPT="$PROMPT$RETURN_VAL"	
			TEMP_FUNCTION=($FUNCTION)
			echo $TEMP_FUNCTION
			if [[ "${TEMP_FUNCTION[0]}" != "FROM" ]] && [[ "${TEMP_FUNCTION[0]}" != "WHERE" ]]; then
				PROMPT="$PROMPT | "
			fi

			$FUNCTION
		fi
        done
	
	PROMPT=("$PROMPT csvlook -I 2>/dev/null")
	
	if [[ $CHECK -eq 1 ]]; then
		clear
		echo "$QUERY"	
		eval $PROMPT
	fi
		
	echo "$PROMPT"
	
}

FROM () {
        if [[ $# -gt 1 ]]; then
                echo "Syntax error. Found more than 1 table to search in!"
                return 1
        fi

        if [[ $(ls tables | grep -w $1) == "$1" ]]; then
                TABLE_NAME=$1
		echo "cat tables/$TABLE_NAME | awk -F ';' "
		return 0

        else
                echo "Syntax error. No table named $1 found!"
                return 1
        fi
}

SELECT () {
	COLUMNS=($@)
	N_O_COLUMNS=$#

	if [[ $N_O_COLUMNS -eq 0 ]]; then
		echo "Syntax error. No columns found!"
		return 1
	fi
	
	if [[ "$@" == "\"*\"" ]] && [[ $N_O_COLUMNS -eq 1 ]]; then
		echo "{print}'"
		return 0
	fi

	TABLE_COLUMNS=($(cat tables/$TABLE_NAME | head -1 | sed 's/;/ /g'))	       
	COLUMNS_INDEXES=()

	for IS_COLUMN in "${COLUMNS[@]}"; do
		#echo $IS_COLUMN
		
		INDEX=-1
		i=1
		for TABLE_COLUMN in "${TABLE_COLUMNS[@]}"; do
			#echo $TABLE_COLUMN

			if [[ "\"$TABLE_COLUMN\"" == "$IS_COLUMN" ]]; then
				COLUMNS_INDEXES+=('$'$i)
				INDEX=$i
			fi

			i=$(( $i + 1 ))
		done

		if [[ $INDEX -eq -1 ]]; then 
			echo "Syntax error! No column named $IS_COLUMN found in $TABLE_NAME"
			return 1
		fi
	done

	SEL_TEMP="{print"

	for COLUMN_INDEX in "${COLUMNS_INDEXES[@]}"; do
		SEL_TEMP="$SEL_TEMP $COLUMN_INDEX\";\""

	done
	
	SEL_TEMP="${SEL_TEMP::-3}"
	SEL_TEMP="$SEL_TEMP}'"
	echo $SEL_TEMP
	return 0

}

WHERE () {
	#echo $@
	#echo $#
	local ARGS=($@)
	WHR_TEMP="'\$1==\"ID\""

	for arg in "${ARGS[@]}"; do
		if [[ "${arg^^}" != "OR" ]] && [[ "${arg^^}" != "AND" ]]; then
			eval $arg
			
			local COL_NAME="${arg%%=*}"
			local COL_VALUE=""${!COL_NAME}""

			#echo "$COL_NAME $COL_VALUE"
		        
			TABLE_COLUMNS=($(cat tables/$TABLE_NAME | head -1 | sed 's/;/ /g'))
			INDEX=-1
                	i=1

                	for TABLE_COLUMN in "${TABLE_COLUMNS[@]}"; do
                        	#echo $TABLE_COLUMN

                        	if [[ "\"$TABLE_COLUMN\"" == "\"$COL_NAME\"" ]]; then
					WHR_TEMP="$WHR_TEMP || \$$i==\"$COL_VALUE\""
                                	INDEX=$i
					break
                        	fi

                        	i=$(( $i + 1 ))
                	done

                	if [[ $INDEX -eq -1 ]]; then
                        	echo "Syntax error! No column named $COL_NAME found in $TABLE_NAME"
                        	return 1
                	fi
	
		elif [[ "${arg^^}" == "OR" ]]; then 
			WHR_TEMP="$WHR_TEMP || "	
		
		elif [[ "${arg^^}" == "AND" ]]; then
			WHR_TEMP="$WHR_TEMP' | awk -F ';' "
		fi
	done
	
	echo $WHR_TEMP
	
}

while [ true ]; do 
	#clear
	QUERY=""
	echo -n "Enter query: "
	read QUERY
	
	if [ "${QUERY^^}" == "EXIT" ]; then
		break
	else
		parse_query $QUERY
	fi
	
		

done
