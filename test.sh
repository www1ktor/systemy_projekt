#!/bin/bash

ID_LIST=$(cat tables/sample | awk -F ';' '{print $1}')
ID_LIST=(123 4 234 44 2399 43 111 3)

IFS=$'\n' SORTED=($(sort -n <<< "${ID_LIST[*]}"))

echo "${SORTED[@]}"
