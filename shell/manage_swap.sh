#!/bin/bash

_check_Mem () {

    FREE="/usr/bin/free"
    MEM=$($FREE | grep "Mem" | awk '{print $2}')
    MEM=$(echo -e "$MEM / 1000000" | bc)
    echo -e "$MEM"

}

_create_swap () {

    swapon -s | grep -Po "$swap_file_path "
    if [ "$?" -eq "0" ];then
        echo "Swap Space Exists."
        exit 1
    fi

    fallocate -l $swap_size $swap_file_path
    chown root:root $swap_file_path
    chmod 0600 $swap_file_path
    mkswap $swap_file_path > /dev/null
    swapon $swap_file_path > /dev/null
    swapon -s

}

_disable_swap () {

    swapon -s | grep $swap_file_path
    if [ "$?" -eq "0" ];then
        swapoff $swap_file_path
    fi

}

_delete_swap () {

    _disable_swap
    rm $swap_file_path

}

_usage () {

    clear
    echo -e "Usage:\n\t$0 [-C|-d|-D]\n\n"
    echo -e "Example:\n\t$0 -C    Create the swap size of 1/2 memory\n\t -d: Disable swap space.\n \t -D: DELETE swap space.\n"
    exit 1

}

__main__ () {
    
    memory=$(_check_Mem)
    swap_size=$(echo -e "$memory / 2 " | bc)
    swap_size=$swap_size"G"

    swap_file_path=/polydata/swapfile
    action=${1}

    if [ "$action" = "-C" ];then
        _create_swap
    elif [ "$action" = "-d" ];then
        _disable_swap
    elif [ "$action" = "-D" ];then
        _delete_swap
    else
        _usage
    fi

}

__main__  "$1"
