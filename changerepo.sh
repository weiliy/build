#!/bin/bash

new_repo=$1
git remote add temp $new_repo
git push temp --all 

git remote -v
read -p "Do you want to continue?(y/n)" ans
if [ "$ans" == "y" ]
then
    git remote remove origin
    git remote rename temp origin
fi
