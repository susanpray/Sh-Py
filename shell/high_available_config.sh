#!/bin/bash

. /etc/profile

_show_config () {

    priority=$(cat /etc/keepalived/keepalived.conf | grep "priority" | grep -Po "\d+")
    virtual_ip=$(cat /etc/keepalived/keepalived.conf | grep "virtual_ipaddress" -A 1 | grep -Po "\d+.\d+.\d+.\d+/\d+")

    if [ "$priority" -ge "100" ];then
        priority=1
    elif [ "$priority" -lt "100" ];then
        priority=2
    fi

    echo -e "$priority"
    echo -e "$virtual_ip"
}

_write_config () {

    priority=$1
    virtual_ip=$2
    
    if [ "$priority" = "" -o "$virtual_ip" = "" ];then
        echo -e "Lack Some Parameters."
        exit 1
    else
        if [ "$priority" -eq "1" ];then
            priority=100
        elif [ "$priority" -eq "2" ];then
            priority=50
        fi
        sed -i "s/priority.*/priority $priority/g" /etc/keepalived/keepalived.conf
        sed -i "s|.*\/.*|        $virtual_ip|g" /etc/keepalived/keepalived.conf
    fi

}

__main__ (){

    tag=$1
    PRI=$2
    vIP=$3

    case $tag in
        "-s")
            _show_config
            ;;
        "-m")
            _write_config "$PRI" "$vIP"
            _show_config
            ;;
        *)
            echo -e "Unknow Parameters."
            exit 1
        ;;
    esac
}

__main__ "$1" "$2" "$3"
