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
                1) manageDbTables $name ;;
                2) dropDb $name;;
                3) break ;;
            esac
        done

    else
        firMessage "Database does not exists"
    fi
}

createTable(){
    clear
    echo "Table Name :"
    read name
    dbname=$1

    tableDataPath="$PWD/$dbname/$name.data"
    tableMetaPath="$PWD/$dbname/$name.meta"

    if [ -f $tableDataPath ]
    then
        firMessage "Table $name Already Exists in $dbname"
        break
    else
        if touch $tableDataPath && touch $tableMetaPath
        then
            manageTable $dbname $name
        fi
    fi
}

dropTable(){
    clear
    dbName=$1;
    tableName=$2

    tableDataPath="$PWD/$dbName/$tableName.data"
    tableMetaPath="$PWD/$dbName/$tableName.meta"

    echo "Drop $tableName from $dbName? (y/n)"
    read confirm

    if [ $confirm = "y" ]
    then
        if [ -f $tableDataPath -a  -f $tableMetaPath ] && rm $tableDataPath && rm $tableMetaPath
        then
            firMessage "Dropped Successfully"
            break
        else
            firMessage "Dropping Error"
        fi
    fi
}

manageTable(){
    clear
    db=$1
    table=$2
    tableData="$PWD/$db/$table.data"
    if [ -f $tableData ]
    then
        while true
        do
            clear
            echo "Table $table Selected"
            echo "1. Manage Data"
            echo "2. Manage Structure"
            echo "3. Drop Table"
            echo "4. Back"

            read -r line

            case $line in
                1) ManageDbTables $name ;;
                3) dropTable $db $table;;
                4) break ;;
            esac
        done

    else
        firMessage "Table Does Not Exists"
    fi
}

manageDbTables(){
    if [ $1 ]; then
        dbName=$1
     else
        echo "Database Name ?: "
        read dbName
    fi
    dbpath=$PWD/$dbName
    if [ -d $dbpath ]
    then
        while true
        do
            clear

            echo "Database $dbName Tables"

            echo "------"
                for table in `find $dbpath/ -name "*.data" -printf "%f\n" | cut -d. -f1`
                do
                    echo "- $table"
                done
            echo "------"

            echo "1. Create A New"
            echo "2. Manage A Table"
            echo "3. Back"

            read -r line

            case $line in
                1) createTable $dbName ;;
                2)
                    echo "Enter Table Name"
                    read -r tableName
                    manageTable $dbName $tableName
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
