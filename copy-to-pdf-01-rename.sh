#!/bin/bash

function loop_read(){
	echo "$1" \
	| while read line
	do
		eval $2 $line
	done
}

function convert_folder(){
	echo -n "$1:"
	echo "$1" | cut -d' ' -f1 | sed -En 's/^([0-9]*)-([0-9]*)([ab])$/\1 \2 \3/p'
}

function convert_file(){
	convert_file__folder_name=$(echo $1 | cut -d':' -f1)
	convert_file__side=$(echo $1 | cut -d':' -f2 | cut -d' ' -f3) 
	
    page_number=$(echo $@ | cut -d':' -f2 | cut -d' ' -f2)
    [ "$convert_file__side" == "a" ] && \
        page_number=$(expr $page_number - 1)

    echo $page_number
	ls -1 $convert_file__folder_name \
    | sort -n $( [ "$convert_file__side" == "a" ] && echo "-r" )\
    | while read line
    do
        echo page_number=$page_number
	    copy_to_output $convert_file__folder_name/$line $(rename $page_number jpg)
        page_number=$(expr $page_number - 2)
    done
}

function rename(){
	printf "page-%05d.%s\n" $1 $2
}

copy_to_output(){
	cp $1 release/$2
}

ls -1 \
| while read line
do
    str=$(convert_folder "$line")
    echo $str
    convert_file "$str"
done
    
