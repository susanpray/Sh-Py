#!/bin/bash

uptimesec=$(cat /proc/uptime | awk -F'.' '{print $1}')

convertsecs2dhms() {
 ((d=${1}/(60*60*24)))
 ((h=(${1}%(60*60*24))/(60*60)))
 ((m=(${1}%(60*60))/60))
 ((s=${1}%60))
 printf "%02d天%02d小时%02d分%02d秒\n" $d $h $m $s
 # PRETTY OUTPUT: uncomment below printf and comment out above printf if you want prettier output
 # printf "%02dd %02dh %02dm %02ds\n" $d $h $m $s
}

convertsecs2dhms $uptimesec
