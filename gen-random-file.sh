#!/bin/bash

# Create a fix size and random content file
function f_new_file() {
	dd if=/dev/urandom of="$1" bs=1K count="$2" > /dev/null 2>&1
}


# Random name

arr_name_char=({0..9} {a..z} {A..Z} - _)
function f_new_name() {
	local char_n=${#arr_name_char[@]}
	local new_name=''
	while [ ${#new_name} -le 8 ] 
	do
		local random_char=${arr_name_char[$expr($RANDOM % $char_n)]}
		local new_name="$new_name$random_char"
	done
	echo ${new_name}.random
}

for i in $(seq $1)
do
	f_new_file "$(f_new_name)" "$2"
done
