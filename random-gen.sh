#!/bin/bash

# Create a fix size and random content file
function f_new_file() {
	dd if=/dev/urandom of="$1" bs=1K count="$2" > /dev/null 2>&1
}


# Random name

arr_name_char=({0..9} {a..z} {A..Z} - _)
function f_new_name() {
	local char_n=${#arr_name_char[@]}
	local new_name='t'
	while [ ${#new_name} -le 8 ] 
	do
		local random_char=${arr_name_char[$expr($RANDOM % $char_n)]}
		local new_name="$new_name$random_char"
	done
	echo $new_name
}


# create folders

function f_new_folders() {
	local folder_name
	for i in $(seq $1)
	do
		folder_name=$(f_new_name)
		mkdir -- "$folder_name"
		echo -n "$folder_name "
	done
}

arr_file_size=({1..9}{0,00,000,0000}{,,} {1,2,3}00000)
#arr_file_size=({1..9}{0,00,000})
file_size_n=${#arr_file_size[@]}
function f_random_size() {
	echo ${arr_file_size[$(($RANDOM % $file_size_n))]}
}

function f_new_files() {
	for i in $(seq $1)
	do
		f_new_file "$2/$(f_new_name)" "$(f_random_size)"
	done
}


function f_new_tree_by_level() {
	local level=$1
	local folder_name
	local _pwd
	for folder_name in $(f_new_folders 10)
	do
		_pwd=$(pwd)
		cd -- "$folder_name"	
		if [ $level -eq 1 ]
		then
			f_new_files $2 $(pwd) &
		else
			f_new_tree_by_level $(($level - 1)) $2
		fi
		cd "$_pwd"
	done
}	

# Test Function

#. ${0/\/*/\/}test.sh



# Main 
f_new_tree_by_level $1 $2
