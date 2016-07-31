#!/usr/bin/env bash

if [ -z $1 ]
then
    echo "  Please specify the new hostname"
    exit
fi 

NEW_HOSTNAME=$1
echo $NEW_HOSTNAME > /proc/sys/kernel/hostname
echo $NEW_HOSTNAME > /etc/hostname

sed -i 's/127.0.1.1.*/127.0.1.1\t'"$NEW_HOSTNAME"'/g' /etc/hosts

service hostname start

