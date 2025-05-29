#!/bin/bash 

clear

KEYWORDS=( "SHOW" "DROP" "SELECT" "FROM" "WHERE" "ORDER BY" "LIMIT" )

parse_query() {
	if [[ $# -eq 0 ]]; then
		return 0
	fi
	
	local LINE=""
	local CNTR=0
	i=-1

	for word in $QUERY; do	
		if [[ ${KEYWORDS[@]} =~ ${word^^} ]]; then
			if [[ "${word^^}" == "FROM" ]] || [[ "${word^^}" == "WHERE" ]]; then
				CNTR=$(( $CNTR + 1 ))
			fi	
		
			if [[ $i -ge 0 ]]; then		
				TO_PARSE[$i]=$LINE 	
			fi
			
			LINE=${word^^}
			i=$(( $i + 1 ))		
		else
			if [[ $i -eq -1 ]]; then
				return 1
			fi
			
			LINE="$LINE $word"
		fi	       
	done
	
	TO_PARSE[$i]=$LINE
	local SELECT="${TO_PARSE[0]}"

	for (( x=0; x<$CNTR; ++x )); do
		TO_PARSE[$x]=${TO_PARSE[$(( $x+1 ))]}
	done	
	
	TO_PARSE[$CNTR]=$SELECT	

	PROMPT=""
	CHECK=1

	for FUNCTION in "${TO_PARSE[@]}"; do
		RETURN_VAL=$($FUNCTION)
		#echo "$FUNCTION"	
		if [[ $? == 1 ]]; then 
			CHECK=0		
			echo "$RETURN_VAL"
			break
		fi
		#echo "$RETURN_VAL"
		if [[ "$RETURN_VAL" != "" ]]; then
			PROMPT="$PROMPT$RETURN_VAL"	
			TEMP_FUNCTION=($FUNCTION)
			#echo $TEMP_FUNCTION
			if [[ "${TEMP_FUNCTION[0]}" != "FROM" ]] && [[ "${TEMP_FUNCTION[0]}" != "WHERE" ]]; then
				PROMPT="$PROMPT | "
			fi

			$FUNCTION
		fi
        done
	
	PROMPT=("$PROMPT csvlook -I 2>/dev/null")
	
	if [[ $CHECK -eq 1 ]]; then
		#clear
		echo "$PROMPT"
		echo "$QUERY"	
		eval $PROMPT
	fi
}

FROM () {
        if [[ $# -gt 1 ]]; then
                clear
		echo "Syntax error. Found more than 1 table to search in!"
                return 1
	elif [[ $# -eq 0 ]]; then       
       		clear
		echo "Syntax error. No table given in FROM clause!"
		return 1
	fi

        if [[ $(ls tables | grep -w $1) == "$1" ]]; then
                TABLE_NAME=$1
		echo "cat tables/$TABLE_NAME | awk -F ';' '"
		return 0

        else
                clear
		echo "Syntax error. No table named $1 found in FROM clause!"
                return 1
        fi
}

SELECT () {
	local COLUMNS=($@)
	local N_O_COLUMNS=$#

	if [[ $N_O_COLUMNS -eq 0 ]]; then
		clear
		echo "Syntax error. No columns found in SELECT clause!"
		return 1
	fi
	
	if [[ "$@" == "\"*\"" ]] && [[ $N_O_COLUMNS -eq 1 ]]; then
		echo "{print}'"
		return 0
	fi

	TABLE_COLUMNS=($(cat tables/$TABLE_NAME | head -1 | sed 's/;/ /g'))	       
	local COLUMNS_INDEXES=()

	for IS_COLUMN in "${COLUMNS[@]}"; do
		local INDEX=-1
		local i=1
		
		for TABLE_COLUMN in "${TABLE_COLUMNS[@]}"; do
			if [[ "\"$TABLE_COLUMN\"" == "$IS_COLUMN" ]]; then
				COLUMNS_INDEXES+=('$'$i)
				INDEX=$i
			fi

			i=$(( $i + 1 ))
		done

		if [[ $INDEX -eq -1 ]]; then 
			clear

			if [[ "$TABLE_NAME" != "" ]]; then
				echo "Syntax error! No column named $IS_COLUMN found in $TABLE_NAME"
			else
				echo "Syntax error! Unexpected error."
			fi

			return 1
		fi
	done

	local SEL_TEMP=" {print"

	for COLUMN_INDEX in "${COLUMNS_INDEXES[@]}"; do
		SEL_TEMP="$SEL_TEMP $COLUMN_INDEX \";\""
	done
	
	SEL_TEMP="${SEL_TEMP::-3}}'"
	echo $SEL_TEMP
	
	#czyszczenie zmiennych
	COLUMNS=""
	N_O_COLUMNS=0
	COLUMNS_INDEXES=()
	TABLE_COLUMNS=()
	SEL_TEMP=""

	return 0
}

WHERE () {
	if [[ $# -eq 0 ]]; then
                clear
                echo "Syntax error. No conditions given in WHERE clause!"
                return 1
        fi

	local ARGS=($@)
	WHR_TEMP="\$1==\"ID\" ||"

	for arg in "${ARGS[@]}"; do
		if [[ "${arg^^}" != "OR" ]] && [[ "${arg^^}" != "AND" ]]; then
			local PARSED_CONDITION=$(echo "$arg" | sed -E 's/(<=|>=|==|!=|=|<|>)/ \1 /')
			read COL_NAME OPERATOR COL_VALUE <<< "$PARSED_CONDITION"
			
			if [[ "$OPERATOR" == "=" ]]; then
				OPERATOR="=="
			fi

			TABLE_COLUMNS=($(cat tables/$TABLE_NAME | head -1 | sed 's/;/ /g'))
			INDEX=-1
                	i=1

                	for TABLE_COLUMN in "${TABLE_COLUMNS[@]}"; do
                        	if [[ "\"$TABLE_COLUMN\"" == "\"$COL_NAME\"" ]]; then
					WHR_TEMP="$WHR_TEMP \$$i$OPERATOR\"$COL_VALUE\" "
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
			WHR_TEMP="$WHR_TEMP|| "	
		
		elif [[ "${arg^^}" == "AND" ]]; then
			WHR_TEMP="$WHR_TEMP' | awk -F ';' '\$1==\"ID\" ||"
		fi
	done
	
	echo $WHR_TEMP
	
}

LIMIT () {
	if [[ $# -eq 0 ]] || [[ $# -gt 1 ]]; then
		clear
		echo "Syntax error! LIMIT clause expect 1 argument, $# given."
	elif [[ $1 =~ ^[0-9]+$ ]]; then
		echo "head -$(($1 + 1))"
		return 0	
	else
		clear
		echo "Syntax error! LIMIT clause expect integer argument."
	fi
}

ORDER_BY () {
	

}

while [ true ]; do 
	echo -n "Enter query: "
	read QUERY
	
	clear

	if [ "${QUERY^^}" == "EXIT" ]; then
		break
	else
		parse_query $QUERY
	fi
	
done
