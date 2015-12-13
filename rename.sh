#!/bin/bash

prefix=$1
start=$2
step=$3
for old_name in `ls`
do
		new_name=`printf "%s-%05d.jpg" $prefix $start`
		mv $old_name $new_name
		((start = $start $step))
done
		
