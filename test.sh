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