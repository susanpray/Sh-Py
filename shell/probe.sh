#!/bin/bash

. /etc/profile

MKDIR="/bin/mkdir -p"
ECHO="/bin/echo -e"
CP="/bin/cp -a"
RM="/bin/rm"
TAR="/bin/tar"
ZIP="/usr/bin/zip"
TOP="/usr/bin/top"
FREE="/usr/bin/free"
TAIL="/usr/bin/tail"

interval=5

network_stat_script=/polyhawk/script/networksas_status_view.sh

store_info_path=/polydata/sys_collect
os_log=/var/log
polydata_log=/polydata/log

if [ ! -d "$store_info_path" ];then
    $MKDIR /polydata/sys_collect
fi

_collect_os_polydata_log () {

    $ECHO "Collect LOG File ..."
    date_time=$(date "+%Y-%m-%d-%H%M")
    $TAR cvzpPf $store_info_path/os_polydata_log_${date_time}.tar.gz $os_log/*.log $polydata_log/*.log $polydata_log/gui_logs/catalina.out $polydata_log/hawk_rest_logs/hawk_rest.log $polydata_log/mysql/mysql_error.log > /dev/null 2>&1

}

_collect_packet_info () {

    $ECHO "Collect Packet Work Information ..."
    date_time=$(date "+%Y-%m-%d-%H-%M")
    $ECHO "$date_time" >> $store_info_path/packet_profile_${date_time}.log
    $ECHO "======================================================================================" >> $store_info_path/packet_profile_${date_time}.log
    /polyhawk/bin/apt_show_stats profile >> $store_info_path/packet_profile_${date_time}.log
    $ECHO "======================================================================================" >> $store_info_path/packet_profile_${date_time}.log
    $ECHO "$date_time" >> $store_info_path/packet_netstats_${date_time}.log
    $ECHO "======================================================================================" >> $store_info_path/packet_netstats_${date_time}.log
    /polyhawk/bin/apt_show_stats netstats >> $store_info_path/packet_netstats_${date_time}.log
    $ECHO "======================================================================================" >> $store_info_path/packet_netstats_${date_time}.log

}

_make_log_package () {

    $ECHO "Make All Log Package ..."
    $RM $store_info_path/Mail-To-Developer_* > /dev/null 2>&1
    date_time=$(date "+%Y-%m-%d-%H-%M")
    $TAR cvzpPf $store_info_path/Mail-To-Developer_${date_time}.tar.gz $store_info_path/*.gz $store_info_path/*.log $store_info_path/*.csv --exclude=$store_info_path/Mail-To-Developer_${date_time}.tar.gz > /dev/null
    $RM $store_info_path/os_polydata_log_* $store_info_path/packet_* $store_info_path/*.csv > /dev/null
    $ECHO "Mail-To-Developer_${date_time}.tar.gz"

}

_collect_cpu () {

    $ECHO "Collect CPU Infomation ..."
    date_time=$(date "+%Y-%m-%d %H:%M:%S")
    cpu_usage=$($TOP -b -n $interval | grep "^%Cpu" | $TAIL -n 1 )
    $ECHO "$date_time  $cpu_usage" >> $store_info_path/cpu_usage.log

}

_collect_mem () {

    $ECHO "Collect Memory Infomation ..."
    date_time=$(date "+%Y-%m-%d %H:%M:%S")
    mem_usage=$($FREE | grep -P "^Mem:")
    $ECHO "$date_time  $mem_usage" >> $store_info_path/mem_usage.log

}

_collect_comp () {

    $ECHO "Collect Networksas Component Status ..."
    $network_stat_script > $store_info_path/component_stat.log 
}

_collect_disk_info () {
    
    $ECHO "Collect Disk Usage Infomation ..."
    date_time=$(date "+%Y-%m-%d %H:%M:%S")
    root_dir=$(df -Th | grep -P " /$")
    polydata_dir=$(df -Th | grep -P " /polydata$")
    $ECHO "$date_time  $root_dir" >> $store_info_path/disk_usage.log
    $ECHO "$date_time  $polydata_dir" >> $store_info_path/disk_usage.log

}

_convert_to_csv () {

    $ECHO "Convert $store_info_path/cpu_usage.log to /root/cpu_usage.csv"
    cat $store_info_path/cpu_usage.log | awk '{print $1,$2,","100 - $10}' > $store_info_path/cpu_usage.csv
    $CP $store_info_path/cpu_usage.csv /root/
    sleep 2
    $ECHO "Convert $store_info_path/mem_usage.log to /root/mem_usage.csv"
    cat $store_info_path/mem_usage.log | awk '{use=$5/1024000;free=$6/1024000;cached=$9/1024000;total=$4/1024000;print $1,$2,","use,","free,","100 - ((free + cached)/total)*100}' > $store_info_path/mem_usage.csv
    $CP $store_info_path/mem_usage.csv /root/

}

__main__ () {

    isgetlog=$1

    if [ "$isgetlog" = "-log" ];then
        clear
        _convert_to_csv
        _collect_os_polydata_log
        _collect_packet_info
        _collect_comp
        _make_log_package
        exit 0
    fi

    if [ "$isgetlog" = "-csv" ];then
        clear
        _convert_to_csv
        exit 0
    fi
    
    _collect_cpu
    _collect_mem
    _collect_disk_info

}

__main__ "$1"

