#!/bin/bash 

clear

KEYWORDS=( "SHOW" "DROP" "SELECT" "FROM" "WHERE" "ORDER_BY" "LIMIT" "DELETE" "UPDATE" "SET" "INSERT_INTO" "VALUES")

PARSE_QUERY () {
	if [[ $# -eq 0 ]]; then
		return 0
	fi
	
	local LINE=""
	local CNTR=0
	IS_OPERATOR_TO_REVERSE="F" 
	IS_UPDATE_CLAUSE="F"
	SHORTER_UPDATE_CLAUSE="F"
	i=-1
	
	TO_PARSE=()

	for WORD in $QUERY; do	
		if [[ $(echo ${KEYWORDS[@]} | fgrep -w ${WORD^^}) ]]; then
			if [[ "${WORD^^}" == "FROM" ]] || [[ "${WORD^^}" == "WHERE" ]]; then
				CNTR=$(( $CNTR + 1 ))
				
				if [[ "$IS_UPDATE_CLAUSE" == "T" ]]; then
					SHORTER_UPDATE_CLAUSE="T"
				fi
			fi
			
			if [[ "${WORD^^}" == "DELETE" ]]; then
				IS_OPERATOR_TO_REVERSE="T"
			fi
			
			if [[ "${WORD^^}" == "SET" ]]; then
				IS_UPDATE_CLAUSE="T"
			fi
		
			if [[ $i -ge 0 ]]; then		
				TO_PARSE[$i]=$LINE 	
			fi
			
			LINE=${WORD^^}
			i=$(( $i + 1 ))		
		else
			if [[ $i -eq -1 ]]; then
				return 1
			fi
			
			LINE="$LINE $WORD"
		fi	       
	done
	
	TO_PARSE[$i]=$LINE
	
	local INDEX_TO_MOVE=0
	local START=0
	local STOP=$CNTR
		
	if [[ "$IS_UPDATE_CLAUSE" == "T" ]]; then
		START=$(( $START + 1 ))
		STOP=$(( $STOP + 1 ))
		INDEX_TO_MOVE=$(( $INDEX_TO_MOVE + 1 ))
	fi
	
	local TO_MOVE="${TO_PARSE[$INDEX_TO_MOVE]}"
	
	for (( x=$START; x<$STOP; ++x )); do
		TO_PARSE[$x]=${TO_PARSE[$(( $x+1 ))]}
	done	
	
	TO_PARSE[$STOP]=$TO_MOVE	

	PROMPT=""
	CHECK=1

	for FUNCTION in "${TO_PARSE[@]}"; do
		RETURN_VAL=$($FUNCTION)
		echo "$FUNCTION"	
		if [[ $? == 1 ]]; then 
			CHECK=0		
			echo "$RETURN_VAL"
			return 0
		fi
		echo "$RETURN_VAL"
		if [[ "$RETURN_VAL" != "" ]]; then
			PROMPT="$PROMPT$RETURN_VAL"	
			TEMP_FUNCTION=($FUNCTION)
			echo $TEMP_FUNCTION
			if [[ "${TEMP_FUNCTION[0]}" != "FROM" ]] && [[ "${TEMP_FUNCTION[0]}" != "WHERE" ]] && [[ "${TEMP_FUNCTION[0]}" != "UPDATE" ]]; then
				PROMPT="$PROMPT | "
			fi

			$FUNCTION
		fi
        done
	
	if [[ $CHECK -eq 1 ]]; then
		clear
		echo "$PROMPT"
		echo "$QUERY"
		PROMPT=("$PROMPT csvlook -I 2>/dev/null")
		eval $PROMPT 
	fi
	
	return 0
}

DOES_COLUMN_EXISTS () { 
	local TABLE_NAME=$1
	local COLUMN_NAME=$2
	
	local TABLE_COLUMNS=($(cat tables/$TABLE_NAME | head -1 | sed 's/;/ /g'))
	
	for D_C_E_TABLE_COLUMN in "${TABLE_COLUMNS[@]}"; do
	       	if [[ "\"$D_C_E_TABLE_COLUMN\"" == "$COLUMN_NAME" ]] || [[ "$D_C_E_TABLE_COLUMN" == "$COLUMN_NAME" ]]; then
			return 0
		fi
	done

	return 1
}

RETURN_COLUMN_INDEX () {
	local TABLE_NAME=$1
        local COLUMN_NAME=$2

        local TABLE_COLUMNS=($(cat tables/$TABLE_NAME | head -1 | sed 's/;/ /g'))

	local INDEX=1

	for R_C_I_TABLE_COLUMN in "${TABLE_COLUMNS[@]}"; do
		if [[ "\"$R_C_I_TABLE_COLUMN\"" == "$COLUMN_NAME" ]] || [[ "$R_C_I_TABLE_COLUMN" == "$COLUMN_NAME" ]]; then
			return $INDEX
		fi
		
		INDEX=$(( $INDEX + 1 ))
	done
	
	return 0
}

REVERSE_OPERATOR () {
	local OPERATOR=$1
	
	case $OPERATOR in
		"==")
			echo "!=" ;;
		"!=")
			echo "==" ;;
		">")
			echo "<=" ;;
		">=")
			echo "<" ;;
		"<")
			echo ">=" ;;
		"<=")
			echo ">" ;;
	esac
	
	return 0
}

SELECT () {
	local COLUMNS=($@)
	local N_O_COLUMNS=$#

	if [[ $N_O_COLUMNS -eq 0 ]]; then
		clear
		echo "Syntax error! No columns found in SELECT clause!"
		return 1
	fi
	
	if [[ "$@" == "\"*\"" ]] && [[ $N_O_COLUMNS -eq 1 ]]; then
		echo "{print}'"
		return 0
	fi
	       
	local COLUMNS_INDEXES=()

	for TABLE_COLUMN in "${COLUMNS[@]}"; do
		DOES_COLUMN_EXISTS $TABLE_NAME $TABLE_COLUMN
		if [[ $? -eq 0 ]]; then
			RETURN_COLUMN_INDEX $TABLE_NAME $TABLE_COLUMN
			COLUMNS_INDEXES+=('$'$?)
		else
        		clear

                	if [[ "$TABLE_NAME" != "" ]]; then
				echo "Syntax error! No column named $TABLE_COLUMN found in $TABLE_NAME"
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

FROM () {
        if [[ $# -gt 1 ]]; then
                clear
		echo "Syntax error! Found more than 1 table to search in!"
                return 1
	elif [[ $# -eq 0 ]]; then       
       		clear
		echo "Syntax error! No table given in FROM clause!"
		return 1
	fi

        if [[ $(ls tables | grep -w $1) == "$1" ]]; then
                TABLE_NAME=$1
		echo "cat tables/$TABLE_NAME | awk -F ';' '"
		return 0

        else
                clear
		echo "Syntax error! No table named $1 found in FROM clause!"
                return 1
        fi
        
        return 0
}

WHERE () {
	if [[ $# -eq 0 ]]; then
                clear
                echo "Syntax error! No conditions given in WHERE clause!"
                return 1
        elif [[ $# -eq 1 ]]; then
		local PARSED_CONDITION=$(echo "$1" | sed -E 's/(<=|>=|==|!=|=|<|>)/ \1 /')
		read COL_NAME OPERATOR COL_VALUE <<< "$PARSED_CONDITION"
			
		if [[ "$OPERATOR" == "=" ]]; then
			OPERATOR="=="
		fi
			
		if [[ "$IS_OPERATOR_TO_REVERSE" == "T" ]]; then 
			OPERATOR=$(REVERSE_OPERATOR $OPERATOR)
		fi
                	
		DOES_COLUMN_EXISTS $TABLE_NAME $COL_NAME
        		
		if [[ $? -eq 0 ]]; then
        		if [[ "$IS_UPDATE_CLAUSE" == "T" ]]; then
        			RETURN_COLUMN_INDEX $TABLE_NAME $COL_NAME
        			echo "\$1!=\"ID\" && \$$?$OPERATOR$COL_VALUE "
        		else
        			RETURN_COLUMN_INDEX $TABLE_NAME $COL_NAME
        			echo "\$1==\"ID\" || \$$?$OPERATOR$COL_VALUE "
        		fi
        		
        		return 0
		else
                	clear
               		echo "Syntax error! No column named $COL_NAME found in $TABLE_NAME"
                       	return 1
        	fi
	fi
        
        local ARGS=($@)
	local OR_CONDITIONS=()
	local AND_CONDITIONS=()
	local PREVIOUS_OPERATOR=""
	local PREVIOUS_CONDITION=""
	
	for arg in "${ARGS[@]}"; do
		if [[ "${arg^^}" == "OR" ]]; then
			OR_CONDITIONS+=($PREVIOUS_CONDITION)
			local PREVIOUS_OPERATOR=$arg
		elif [[ "${arg^^}" == "AND" ]]; then
			AND_CONDITIONS+=($PREVIOUS_CONDITION)
			local PREVIOUS_OPERATOR=$arg
		else
			local PREVIOUS_CONDITION=$arg
		fi
	done
	
	if [[ "${PREVIOUS_OPERATOR^^}" == "OR" ]]; then
		OR_CONDITIONS+=($PREVIOUS_CONDITION)
	elif [[ "${PREVIOUS_OPERATOR^^}" == "AND" ]]; then
		AND_CONDITIONS+=($PREVIOUS_CONDITION)
	else
		clear
		echo "Syntax error! Wrong condition syntax in WHERE clause."
		return 1
	fi
	
	if [[ "$IS_UPDATE_CLAUSE" == "T" ]]; then
		WHR_TEMP="\$1!=\"ID\" ||"
	else
		WHR_TEMP="\$1==\"ID\" ||"
	fi

	
	if [[ ${#OR_CONDITIONS[@]} -gt 0 ]]; then
		WHR_TEMP="$WHR_TEMP ("
		
		for arg in "${OR_CONDITIONS[@]}"; do
			local PARSED_CONDITION=$(echo "$arg" | sed -E 's/(<=|>=|==|!=|=|<|>)/ \1 /')
			read COL_NAME OPERATOR COL_VALUE <<< "$PARSED_CONDITION"
			
			if [[ "$OPERATOR" == "=" ]]; then
				OPERATOR="=="
			fi
			
			if [[ "$IS_OPERATOR_TO_REVERSE" == "T" ]]; then 
				OPERATOR=$(REVERSE_OPERATOR $OPERATOR)
			fi
                	
			DOES_COLUMN_EXISTS $TABLE_NAME $COL_NAME
                		
			if [[ $? -eq 0 ]]; then
                        	RETURN_COLUMN_INDEX $TABLE_NAME $COL_NAME
				WHR_TEMP="$WHR_TEMP\$$?$OPERATOR$COL_VALUE || "
			else
                        	#clear
                       		echo "Syntax error! No column named $COL_NAME found in $TABLE_NAME"
                               	return 1
                	fi
                done
		
		WHR_TEMP="${WHR_TEMP::-4})"
		
		if [[ ${#AND_CONDITIONS[@]} -gt 0 ]]; then
			WHR_TEMP="$WHR_TEMP && "
		fi
	fi
	
	if [[ ${#AND_CONDITIONS[@]} -gt 0 ]]; then		
		for arg in "${AND_CONDITIONS[@]}"; do
			local PARSED_CONDITION=$(echo "$arg" | sed -E 's/(<=|>=|==|!=|=|<|>)/ \1 /')
			read COL_NAME OPERATOR COL_VALUE <<< "$PARSED_CONDITION"
			
			if [[ "$OPERATOR" == "=" ]]; then
				OPERATOR="=="
			fi
			
			if [[ "$IS_OPERATOR_TO_REVERSE" == "T" ]]; then 
				OPERATOR=$(REVERSE_OPERATOR $OPERATOR)
			fi
                	
			DOES_COLUMN_EXISTS $TABLE_NAME $COL_NAME
                		
			if [[ $? -eq 0 ]]; then
                        	RETURN_COLUMN_INDEX $TABLE_NAME $COL_NAME
				WHR_TEMP="$WHR_TEMP\$$?$OPERATOR$COL_VALUE && "
			else
				#clear
                       		echo "Syntax error! No column named $COL_NAME found in $TABLE_NAME"
                               	return 1
                	fi
		
		done
		
		WHR_TEMP="${WHR_TEMP::-3}"
	fi
	
	echo $WHR_TEMP
	
	return 0
}

ORDER_BY () {
	if [[ $# -eq 0 ]] || [[ $(( $# % 2 )) -eq 1  ]] ; then
		clear
		
		if [[ $# -eq 0 ]]; then
			echo "Syntax error! No argument given to ORDER_BY clause"
		else
			echo "Syntax error! In ORDER_BY clause"
		fi

		return 1
	fi

	local ORDER_BY_TEMP=($@)
	local ORB_TEMP=""

	for (( i = $# - 2; i >= 0; i -= 2 )); do
		DOES_COLUMN_EXISTS $TABLE_NAME ${ORDER_BY_TEMP[$i]}		
		if [[ $? -eq 0 ]]; then
			RETURN_COLUMN_INDEX $TABLE_NAME ${ORDER_BY_TEMP[$i]}
			ORB_TEMP="$ORB_TEMP csvsort -c $?"

			if [[ "${ORDER_BY_TEMP[$(( $i + 1 ))]^^}" == "DESC" ]]; then
				ORB_TEMP="$ORB_TEMP -r"
			fi
			
			if [[ $i -ge 2 ]]; then
				ORB_TEMP="$ORB_TEMP | "
			fi
		else
			clear
			echo "Syntax error! No column named ${ORDER_BY_TEMP[$i]} found in ORDER_BY clause."
			return 1
		fi
		
	done	
	
	echo "$ORB_TEMP"
	
	return 0
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

DELETE () {
	echo " {print}' > tables/$TABLE_NAME"
}

UPDATE () {
        if [[ $# -gt 1 ]]; then
                clear
		echo "Syntax error! Found more than 1 table to update in!"
                return 1
	elif [[ $# -eq 0 ]]; then       
       		clear
		echo "Syntax error! No table given in UPDATE clause!"
		return 1
	fi

        if [[ $(ls tables | grep -w $1) == "$1" ]]; then
                TABLE_NAME=$1
		if [[ "$SHORTER_UPDATE_CLAUSE" == "T" ]]; then
			echo "cat tables/$TABLE_NAME | awk -F ';' 'BEGIN {OFS=\";\"}"	
		else
			echo "cat tables/$TABLE_NAME | awk -F ';' 'BEGIN {OFS=\";\"} \$1!=\"ID\" && \$1=\$1 "
		fi
			
		return 0

        else
                clear
		echo "Syntax error! No table named $1 found in UPDATE clause!"
                return 1
        fi
        
        return 0
}

SET () {
	if [[ $# -eq 0 ]]; then
		clear
		echo "Syntax error! No values to set!"
	fi
	
	local ARGS=($@)
	SET_TEMP="{"
	for arg in "${ARGS[@]}"; do 
		local PARSED_CONDITION=$(echo "$arg" | sed -E 's/(=)/ \1 /')
		read COL_NAME OPERATOR COL_VALUE <<< "$PARSED_CONDITION"
		
		if [[ "$OPERATOR" != "=" ]] || [[ "$OPERATOR" == "" ]]; then
			clear
			echo "Syntax error. Wrong operator used in SET clause."
			return 1
		fi
		
		DOES_COLUMN_EXISTS $TABLE_NAME $COL_NAME
        	
		if [[ $? -eq 0 ]]; then
                        TRY_PARSE=$(echo "$COL_VALUE" | grep -oE "\+|\-|\*|\/" | wc -l)

                        if [[ $TRY_PARSE -eq 1 ]]; then
        			local PARSED_OPERATION=$(echo "$COL_VALUE" | sed -E 's|([+*/-])| \1 |g')
        			read LEFT_VALUE NESTED_OPERATOR RIGHT_VALUE <<< "$PARSED_OPERATION"
            			
        			DOES_COLUMN_EXISTS $TABLE_NAME $LEFT_VALUE
        			
        			if [[ $? -eq 0 ]]; then
        				RETURN_COLUMN_INDEX $TABLE_NAME $LEFT_VALUE
        				COL_VALUE="\$$?$NESTED_OPERATOR$RIGHT_VALUE"
        			else
        				DOES_COLUMN_EXISTS $TABLE_NAME $RIGHT_VALUE
      		  			
        				if [[ $? -eq 0 ]]; then
        					RETURN_COLUMN_INDEX $TABLE_NAME $RIGHT_VALUE
        					COL_VALUE="\$$?$NESTED_OPERATOR$LEFT_VALUE"
        				else 
        					COL_VALUE="$LEFT_VALUE$NESTED_OPERATOR$RIGHT_VALUE"
        				fi
        			fi
			elif [[ $? -gt 1 ]]; then
        			clear
        			echo "Syntax error! SET clause expect only 1 arithmetic operator."
        			return 1
        		fi

                        RETURN_COLUMN_INDEX $TABLE_NAME $COL_NAME
                	SET_TEMP="$SET_TEMP{\$$?$OPERATOR$COL_VALUE} "
		else
                        clear
                       	echo "Syntax error! No column named $COL_NAME found in $TABLE_NAME"
                        return 1
                fi
	
	done
	
	SET_TEMP="$SET_TEMP} {print}'"
	echo "$SET_TEMP"
	
	return 0
}

INSERT_INTO () { 
	if [[ $# -eq 0 ]]; then
		clear
		echo "Syntax error! No arguments given to INSERT INTO clause."
		return 1
	fi
	
	
	if [[ $(ls tables | grep -w $1) == "$1" ]]; then
                TABLE_NAME=$1
        else 
        	clear
        	echo "Syntax error! No table named $1 found in INSERT INTO clause."
        	return 1
        fi
	
	COLUMN_INDEXES=()
	
	if [[ $# -eq 1 ]]; then
		N_O_COLS=$(cat tables/$TABLE_NAME | head -1 | grep -oE ";" | wc -l)
		echo "INSERT INTO eq 0 $N_O_COLS"
		for (( i = 2; i <= $(( N_O_COLS + 1 )); ++i )); do
			COLUMN_INDEXES+=($i)
		done
		
		return 0
	fi
	
	INSERT_INTO_ARGS=($@)
	N_O_COLS=$(( $# - 1 ))
	
	echo "INSERT INTO gt 0 $N_O_COLS"
	for (( i = 1; i < $#; ++i )); do
		echo "${INSERT_INTO_ARGS[$i]} $i"
		
		DOES_COLUMN_EXISTS $TABLE_NAME ${INSERT_INTO_ARGS[$i]}
		
		if [[ $? -eq 0 ]]; then
			RETURN_COLUMN_INDEX $TABLE_NAME ${INSERT_INTO_ARGS[$i]}
			COLUMN_INDEXES+=($?)
		else
			clear
			echo "Syntax error! No column named ${INSERT_INTO_ARGS[$i]} found in $TABLE_NAME table."
			return 1
		fi
		
	done
	
	return 0
}

VALUES () {
	if [[ $# -eq 0 ]]; then
		clear
		echo "Syntax error! No arguments given to INSERT INTO clause."
		return 1
	fi
	
	VALUES_ARGS="$*"
	TEMP_VALUES=()
	COLUMN_INDEXES=$COLUMN_INDEXES
	N_O_COLUMNS=$N_O_COLS
	IS_WORD_BEING_PROCESSED="F"
	LINE=""
	LINES=()
	#DOUBLE_CHECK_VALUES_CLAUSE=$DOUBLE_CHECK_VALUES_CLAUSE

	for (( i = 0; i < ${#VALUES_ARGS}; ++i )); do
		CHAR=${VALUES_ARGS:i:1}
		
		if [[ "$CHAR" == "(" ]]; then
			continue
		elif [[ "$CHAR" == ")" ]]; then
			if [[ "$IS_WORD_BEING_PROCESSED" == "F" ]]; then
				TEMP_VALUES+=("|")
			fi
		elif [[ "$CHAR" == "\"" ]]; then
			if [[ "$IS_WORD_BEING_PROCESSED" == "T" ]]; then
				IS_WORD_BEING_PROCESSED="F"
				TEMP_VALUES+=("$WORD")
			else
				IS_WORD_BEING_PROCESSED="T"
				WORD=""
			
			fi
		else
			WORD="$WORD$CHAR"
		fi
	done
	
	CNTR=0
	
	for INITIALLY_PARSED in "${TEMP_VALUES[@]}"; do 
		if [[ "$INITIALLY_PARSED" == "|" ]]; then
			if [[ $CNTR -eq $N_O_COLUMNS ]]; then
				PARSED=()
				
				for (( i = 0; i < N_O_COLUMNS; ++i )); do
					INDEX=${COLUMN_INDEXES[$i]}
					PARSED[$INDEX]=${PREPARSED_LINE[$i]}
				done
				
				ID_LIST=$(cat tables/$TABLE_NAME | awk -F ';' '{print $1}')
				IFS=$'\n' SORTED_ID_LIST=($(sort -n <<< "${ID_LIST[*]}"))
				
				CURR_ID=1
				
				for (( i = 1; i <= ${#ID_LIST}; ++i )); do
					if [[ $(echo ${ID_LIST[@]} | grep -w "$i") ]]; then
						continue
					else
						CURR_ID=$i
						ID_LIST+=($CURR_ID)
						break
					fi
				done
				
				LINE="$CURR_ID"
				TABLE_WIDTH=$(cat tables/$TABLE_NAME | head -1 | grep -oE ";" | wc -l)

				for (( i = 2; i <= $(( $TABLE_WIDTH + 1 )); ++i)); do
					if [[ $(echo ${COLUMN_INDEXES[@]} | grep -w "$i") ]]; then
						LINE="$LINE;${PARSED[$i]}"
					else
						LINE="$LINE;"
					fi
				done
				
				LINES+=("$LINE")
				PREPARSED_LINE=()
				CNTR=0
			else
				clear
				echo "Syntax error! $CNTR arguments passed, $N_O_COLUMNS expected in VALUES clause."
				return 1
			fi
		else
			PREPARSED_LINE+=("$INITIALLY_PARSED")
			local CNTR=$(( $CNTR + 1 ))
		fi
	done	
		
	for line in "${LINES[@]}"; do
		echo $line >> tables/$TABLE_NAME
	done
	
	return 0
} 

while [ true ]; do 
	QUERY=""
	echo -n "Enter query: "
	read QUERY
	
	clear

	if [ "${QUERY^^}" == "EXIT" ]; then
		break
	else
		clear
		PARSE_QUERY $QUERY
	fi
	
done
