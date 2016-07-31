#!/bin/bash

ECHO="/bin/echo -e"
RM="/bin/rm -rvf"


_warningmsg () {

    clear

    msg="CAUTION:\n\nThe system will Uninstall \n\nAll data will be deleted !!\n"

    warning="$msg"

    $ECHO  "\033[33m############################################\033[0m"
    $ECHO  "\n\033[31m$warning\033[0m\n"
    $ECHO  "\033[33m############################################\033[0m"

    $ECHO  "\n\033[36mPress any key to Continue or Ctrl + c to Quit !\033[0m\n..."
    read

    clear

}

_delete_polyhawk_dir () {

    polyhawk_home=/polyhawk

    echo -e "Cleaning Polyhawk Directory..."
    
    ls -- /polyhawk/3rdparty/ | grep -v "apache-activemq" | xargs $RM
    
    for Dirname in $(ls -- $polyhawk_home)
    do
        if [[ $(echo $Dirname | grep -Po "^3rdparty$|^third$|^pythonlib$|^java$" ) ]];then
            continue
        else
            $RM $polyhawk_home/$Dirname
        fi
    done

}

_delete_polydata_dir () {

    polydata_home=/polydata

    echo -e "Cleaning Polydata Directory..."
    
    $RM $polydata_home/pid/*
    
    for Dirname in $(ls -- $polydata_home)
    do
        if [[ $(echo $Dirname | grep -Po "^upgrade$|^pid$|^mysql$|^log$|^image$|^tmp$") ]];then
            continue
        else
            $RM $polydata_home/$Dirname 
        fi
    done

}

_cleanlog () {

    #delete all log
    $ECHO " Cleaning Log File ..."
    $ECHO " ----------------------------------------------------------------------------------------"
    for log in $(find /polydata -name "*.log*")
    do
        Cur_time=$(date "+%Y/%m/%d %H:%M:%S.%3N")
        $RM $log
        $ECHO  "$Cur_time    Delete [\033[32m$log\033[0m] Success!"
    done
    $ECHO " ----------------------------------------------------------------------------------------"

}

_drop_db () {

    $ECHO "Drop Database ..."
    mysql -uroot -ppolydata -e "DROP DATABASE garuda" > /dev/null 2>&1
    $RM /polydata/mysql/garuda > /dev/null 2>&1
    
    service mysql restart

}

__main__ () {

    forceUninst=$1

    if [ ! "$forceUninst" = "-f" ];then
        _warningmsg
    fi

    clear
    crontab -r
    _delete_polyhawk_dir
    _delete_polydata_dir
    _cleanlog
    _drop_db

}

__main__ "$1"
