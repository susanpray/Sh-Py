#!/bin/bash

#/usr/sbin/dmidecode |grep UUID|awk '{print $2}'

if [ -f "/etc/sys.serial.txt" ]
then
    awk -F= '{print $2}' /etc/sys.serial.txt
else
    serial=$(ifconfig -a | grep HWaddr | head -n 1|sha256sum)"polydata777"; 
    uuidst=$(echo $serial|sha256sum | awk '{print $1}' | cut -c 1-32| tr '[:lower:]' '[:upper:]')
    
    echo $uuidst
fi


