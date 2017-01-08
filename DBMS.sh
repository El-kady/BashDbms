#!/bin/bash

createDb(){
    clear
    echo "Database Name ?: "
    read name
    dbpath=$PWD/$name
    if [ -d $dbpath ]
    then
        echo "The Database Already Exists"
    else
        mkdir $dbpath
        echo "Database `$name` Created"
    fi
}

echo "Choose:"
echo "1. Create A New Database"
echo "6. Exit"

while read -r line
do
    case $line in
        1) createDb ;;
        2) echo 2 ;;
        6) exit 1 ;;
        *)
            echo Choise
            echo $line
        ;;
	esac
done
