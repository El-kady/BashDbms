#!/bin/bash
#Moustafa Elkady <Moustafa.M.Elkady@gmail.com>

createDb(){
    clear
    echo "Database Name ?: "
    read name
    validateString $name
    dbpath=$PWD/databases/$name
    if [ -d $dbpath ]
    then
        firMessage "The Database Already Exists"
    else
        if mkdir -p $dbpath
        then
            manageDb $name
        else
            firMessage "Database creation error"
        fi
    fi
}

dropDb(){
    clear
    db=$PWD/databases/$1;
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

    dbpath=$PWD/databases/$name
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

    dbname=$1

    echo "Table Name :"
    read tableName
    validateString $tableName

    tableDataPath="$PWD/databases/$dbname/$tableName.data"
    tableMetaPath="$PWD/databases/$dbname/$tableName.meta"

    if [ -f $tableDataPath ]
    then
        firMessage "Table $tableName Already Exists in $dbname"
        break
    else
        if touch $tableDataPath && touch $tableMetaPath
        then
            manageTable $dbname $tableName
        fi
    fi
}

dropTable(){
    clear
    dbName=$1;
    tableName=$2

    tableDataPath="$PWD/databases/$dbName/$tableName.data"
    tableMetaPath="$PWD/databases/$dbName/$tableName.meta"

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

createField(){
    clear

    db=$1
    table=$2
    tableData="$PWD/databases/$db/$table.data"
    tableMeta="$PWD/databases/$db/$table.meta"

    echo "Enter Field Name :"
    read -r name
    validateString $name

    if [ -f $tableMeta ]
    then
        if cat $tableMeta | grep $name
        then
            firMessage "Field already exists"
        else
                fieldData=$name
                echo "Enter Field Type (number/string) :"
                read -r type

                if [ $type = "number" -o  $type = "string" ]
                then
                    fieldData+=":$type"
                else
                    firMessage "Not supported datatype"
                fi

                if ! cat $tableMeta | grep "primary"
                then
                    echo "Set as primary key? (y/n) :"
                    read confirm

                    if [ $confirm = "y" ]
                    then
                        fieldData+=":primary"
                    fi
                fi

                echo $fieldData >> $tableMeta

        fi
    else
        firMessage "Table $table does no exists in $db"
        break
    fi
}

dropField(){

    db=$1
    table=$2
    tableData="$PWD/databases/$db/$table.data"
    tableMeta="$PWD/databases/$db/$table.meta"

    echo "Enter Field Name :"
    read -r name

    if [ -f $tableMeta ]
    then
        if cat $tableMeta | grep $name
        then
            clear
            echo "Drop $name from $table? (y/n)"
            read confirm

            if [ $confirm = "y" ]
            then
                echo $(sed '/'$name'/d' $tableMeta) > $tableMeta
            fi

        else
            firMessage "Field does not exist"
        fi
    else
        firMessage "Table $table does no exists in $db"
        break
    fi
}

ManageDbTableStructure(){
    clear

    db=$1
    table=$2
    tableData="$PWD/databases/$db/$table.data"
    tableMeta="$PWD/databases/$db/$table.meta"

    if [ -f $tableData ]
    then
        while true
        do
            clear
            echo "$table Structure:"

            echo "------"
                i=1
                for field in `awk -F: '{print $0}' ${tableMeta}`
                do

                    fieldName=$(echo $field | cut -d: -f1)
                    fieldType=$(echo $field | cut -d: -f2)
                    isPrimary=$(echo $field | cut -d: -f3)

                    fieldData="- $i $fieldName [$fieldType]"

                    if [ $isPrimary ]
                    then
                        fieldData+=" Primary Key"
                    fi

                    echo $fieldData

                    ((i=i+1))

                done

            echo "------"

            echo "1. Create A Field"
            echo "2. Drop A Field"
            echo "3. Back"

            read -r line

            case $line in
                1) createField $db $table ;;
                2) dropField $db $table ;;
                3) break ;;
            esac
        done

    else
        firMessage "Table Does Not Exists"
    fi
}

insertRow(){
    clear

    db=$1
    table=$2
    tableData="$PWD/databases/$db/$table.data"
    tableMeta="$PWD/databases/$db/$table.meta"

    if [ -f $tableData ]
    then
        record=""
        cols=$(awk -F: '{print $0}' $tableMeta)
        colsNum=$(cat $tableMeta | wc -l)

        i=0
        for col in $cols
        do
            colName=$(echo $col | cut -d':' -f 1)
            colType=$(echo $col | cut -d':' -f 2)
            isPrimary=$(echo $col | cut -d: -f3)

            echo "$colName: "
            read value

            if [ $colType = "number" ]
            then
                validateNumber $value "break"
            elif [ $colType = "string" ]
            then
                validateString $value "break"
            fi

            #use just [ ] because if it will be null if no primary field
            if [ $isPrimary ]
            then
                #get column index to get all column values to check if it is unique or not
                ((primaryIndex=$i+1))
                #using -v to assign value in awk context, to get list of all values of unique conlumn
                if awk -v x=$primaryIndex -F: '{print $x}' $tableData | grep -w $value
                then
                    firMessage "$colName must be unique"
                    break
                fi
            fi

            record+=$value:
            ((i=$i+1))
        done

        if [ $i -eq $colsNum ]
        then
            echo $record >> $tableData
        fi

    else
        firMessage "Table Does Not Exists"
    fi
}


browseRows(){
    clear

    db=$1
    table=$2
    column=$3

    tableData="$PWD/databases/$db/$table.data"
    tableMeta="$PWD/databases/$db/$table.meta"

    columnsNames=$(awk -F: '{print $1}' $tableMeta)

    if [ -f $tableData ]
    then
        # -v columns passes the bash variable $columnsNames to awk.
        awk -v columns="$columnsNames" -F: 'BEGIN{split(columns, a, " ")} {for (i in a) { printf "%s : %s \n", toupper(a[i]),$i;} printf  "---------\n";}' $tableData

        echo "Press any key to go back"
        read
    else
        firMessage "Table Does Not Exists"
    fi
}

searchRows(){
    db=$1
    table=$2
    tableData="$PWD/databases/$db/$table.data"
    tableMeta="$PWD/databases/$db/$table.meta"

    if [ -f $tableData ]
    then
        columnsNames=$(awk -F: '{print $1}' $tableMeta)
        question="Search using ("
            i=0
            for col in $columnsNames
            do
                if [ $i -gt 0 ]
                then
                    question+="/"
                fi
                question+="$col"
                ((i=$i+1))
            done
        question+=") ?"
        echo $question;

        read searchCol

        if [[ $(awk -F: '{print $1}' $tableMeta | grep -w $searchCol) ]]
        then
            i=1
            columnIndex=0
            for col in $columnsNames
            do

                if [ $col = $searchCol ]
                then
                    columnIndex=$i
                fi
                ((i=$i+1))
            done

            echo "Search for ?"
            read searchQuery

            clear
            awk -v columns="$columnsNames" -v columnIndex="$columnIndex" -v query="$searchQuery" -F: '
            BEGIN{split(columns, a, " ")}
            {
                if ($columnIndex == query){
                    for (i in a) {
                        printf "%s : %s \n", toupper(a[i]),$i;
                    }
                    printf  "---------\n";
                }
            }
            ' $tableData

            echo "Press any key to go back"
            read
        else
            firMessage "Column Does Not Exists"
        fi
    else
        firMessage "Table Does Not Exists"
    fi
}

deleteRows(){
    db=$1
    table=$2
    tableData="$PWD/databases/$db/$table.data"
    tableDataTmp="$PWD/databases/$db/$table.tmp"
    tableMeta="$PWD/databases/$db/$table.meta"

    if [ -f $tableData ]
    then
        columnsNames=$(awk -F: '{print $1}' $tableMeta)
        question="Delete using ("
            i=0
            for col in $columnsNames
            do
                if [ $i -gt 0 ]
                then
                    question+="/"
                fi
                question+="$col"
                ((i=$i+1))
            done
        question+=") ?"
        echo $question;

        read deleteCol

        if [[ $(awk -F: '{print $1}' $tableMeta | grep -w $deleteCol) ]]
        then
            i=1
            columnIndex=0
            for col in $columnsNames
            do

                if [ $col = $deleteCol ]
                then
                    columnIndex=$i
                fi
                ((i=$i+1))
            done

            echo "Delete from $table where $deleteCol equals ?"
            read deleteQuery

            clear
            awk -v columns="$columnsNames" -v columnIndex="$columnIndex" -v query="$deleteQuery" -F: '
            BEGIN{split(columns, a, " ")}
            {
                if ($columnIndex != query){
                    printf "%s\n",$0;
                }
            }
            ' $tableData > $tableDataTmp && mv $tableDataTmp $tableData

            firMessage "Data has been deleted"
        else
            firMessage "Column Does Not Exists"
        fi
    else
        firMessage "Table Does Not Exists"
    fi
}

updateRows(){
    db=$1
    table=$2
    tableData="$PWD/databases/$db/$table.data"
    tableDataTmp="$PWD/databases/$db/$table.tmp"
    tableMeta="$PWD/databases/$db/$table.meta"

    if [ -f $tableData ]
    then
        columnsNames=$(awk -F: '{print $1}' $tableMeta)
        question="Update rows using ("
            i=0
            for col in $columnsNames
            do
                if [ $i -gt 0 ]
                then
                    question+="/"
                fi
                question+="$col"
                ((i=$i+1))
            done
        question+=") ?"
        echo $question;

        read updateCol

        if [[ $(awk -F: '{print $1}' $tableMeta | grep -w $updateCol) ]]
        then
            i=1
            columnIndex=0
            for col in $columnsNames
            do

                if [ $col = $updateCol ]
                then
                    columnIndex=$i
                fi
                ((i=$i+1))
            done

            echo "Update from $table where $updateCol equals ?"
            read updateQuery

            record=""
            cols=$(awk -F: '{print $0}' $tableMeta)
            colsNum=$(cat $tableMeta | wc -l)

            i=0
            for col in $cols
            do
                colName=$(echo $col | cut -d':' -f 1)
                colType=$(echo $col | cut -d':' -f 2)
                isPrimary=$(echo $col | cut -d: -f3)

                if [ ! $isPrimary ]
                then
                    echo "New Value for $colName: "
                    read value

                    if [ $colType = "number" ]
                    then
                        validateNumber $value "break"
                    elif [ $colType = "string" ]
                    then
                        validateString $value "break"
                    fi
                    record+=$value:
                fi
                ((i=$i+1))
            done

            if [ $i -eq $colsNum ]
            then

                awk -v columns="$columnsNames" -v columnIndex="$columnIndex" -v query="$updateQuery" -v newRow="$record" -F: '
                BEGIN{split(columns, a, " ")}
                {
                    if ($columnIndex == query){
                        printf "%s:%s\n",$1,newRow;
                    }else{
                        printf "%s\n",$0;
                    }
                }
                ' $tableData > $tableDataTmp && mv $tableDataTmp $tableData

                firMessage "Data has been updated"

            fi
        else
            firMessage "Column Does Not Exists"
        fi
    else
        firMessage "Table Does Not Exists"
    fi
}

ManageDbTableData(){
    clear

    db=$1
    table=$2
    tableData="$PWD/databases/$db/$table.data"
    tableMeta="$PWD/databases/$db/$table.meta"

    if [ -f $tableData ]
    then
        while true
        do
            clear
            echo "$table Data:"

            recordsCount=$(cat $tableData | wc -l)
            echo "Total Rows: $recordsCount"

            echo "1. Display All"
            echo "2. Search"
            echo "3. Insert A Row"
            echo "4. Delete A Row"
            echo "5. Update A Row"
            echo "6. Back"

            read -r line

            case $line in
                1) browseRows $db $table ;;
                2) searchRows $db $table ;;
                3) insertRow $db $table ;;
                4) deleteRows $db $table ;;
                5) updateRows $db $table;;
                6) break ;;
            esac
        done

    else
        firMessage "Table Does Not Exists"
    fi
}

manageTable(){
    clear
    db=$1
    table=$2
    tableData="$PWD/databases/$db/$table.data"
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
                1) ManageDbTableData $db $table ;;
                2) ManageDbTableStructure $db $table ;;
                3) dropTable $db $table ;;
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
    dbpath=$PWD/databases/$dbName
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
    echo "Press any key to go back"
    read confirm
}

validateNumber(){
    clear
    if [[ ! $1 =~ ^-?[0-9]+$ ]]
    then
        firMessage "Please Enter A Valid Number"
        if [ $2 = "break" ]
        then
            break
        else
            continue
        fi
    fi
}

validateString(){
    clear
    if [[ ! $1 =~ ^-?[a-zA-Z0-9]+$ ]]
    then
        firMessage "Please Enter A Valid String a-zA-Z0-9"
        if [ $2 = "break" ]
        then
            break
        else
            continue
        fi
    fi
}

while true
do
    clear
    echo "Database:"

    echo "------"
        for database in `ls databases`
        do
            echo "- $database"
        done
    echo "------"

    echo "1. Create A New Database"
    echo "2. Manage A Database"
    echo "6. Exit"

    read -r line

    case $line in
        1) createDb ;;
        2)
            echo "Enter Database Name: "
            read name
            manageDb $name
        ;;
        6) exit 1 ;;
        *)
            echo Choise
            echo $line
        ;;
	esac
done
