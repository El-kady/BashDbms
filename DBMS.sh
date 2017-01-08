#!/bin/bash
#Moustafa Elkady <Moustafa.M.Elkady@gmail.com>

createDb(){
    clear
    echo "Database Name ?: "
    read name
    dbpath=$PWD/$name
    if [ -d $dbpath ]
    then
        firMessage "The Database Already Exists"
    else
        if mkdir $dbpath
        then
            manageDb $name
        else
            firMessage "Database creation error"
        fi
    fi
}

dropDb(){
    clear
    db=$PWD/$1;
    echo "Drop $1 Database? (y/n)"
    read confirm
    if [ $confirm = "y" ]
    then
        if [ -d $db ] && rm -r $db
        then
            firMessage "Dropped Successfully"
            break
        else
            firMessage "Dropping Error"
        fi
    fi
}

manageDb(){
    clear

    if [ $1 ]; then
        name=$1
     else
        echo "Database Name ?: "
        read name
    fi

    dbpath=$PWD/$name
    if [ -d $dbpath ]
    then
        while true
        do
            clear
            echo "Database $name Selected"
            echo "1. Manage Tables"
            echo "2. Drop Database"
            echo "3. Back"

            read -r line

            case $line in
                1) ManageDbTables $name ;;
                2) dropDb $name;;
                3) break ;;
            esac
        done

    else
        firMessage "The Database Is Not Exists"
    fi
}

createTable(){

}

ManageDbTables(){
    if [ $1 ]; then
        name=$1
     else
        echo "Database Name ?: "
        read name
    fi
    dbpath=$PWD/$name
    if [ -d $dbpath ]
    then
        while true
        do
            clear

            echo "Database $name Tables"

            echo "------"
            echo "- Table Name Test"
            echo "------"

            echo "1. Create Table"
            echo "2. Manage Tables"
            echo "3. Back"

            read -r line

            case $line in
                1) createTable $name ;;
                2)
                    echo "Enter Table Name"
                    read -r tablename
                    ManageTable $tablename
                ;;
                3) break ;;
            esac
        done

    else
        firMessage "The Database Is Not Exists"
    fi
}

firMessage(){
    clear
    echo $1
    echo "Press any key to back"
    read confirm
}

while true
do
    clear
    echo "Choose:"
    echo "1. Create A New Database"
    echo "2. Manage A Database"
    echo "6. Exit"

    read -r line

    case $line in
        1) createDb ;;
        2) manageDb ;;
        6) exit 1 ;;
        *)
            echo Choise
            echo $line
        ;;
	esac
done
