#!/bin/bash

. /etc/profile

PS="/bin/ps -ef"
PSA="/bin/ps aux"
ECHO="/bin/echo -e"
KILL="/bin/kill"

mysql_port=3306

polydata_home=/polydata
polyhawk_home=/polyhawk

network_gui_path=$polyhawk_home/gui/apache-tomcat/


lic_bin=$polyhawk_home/license/
lic_boot=$lic_bin/license_server_service.sh

mds_restapi_bin=$polyhawk_home/restapi/bin
mds_restapi_boot=$mds_restapi_bin/polydata_api.sh

keepalive_conf="/etc/keepalived/keepalived.conf"

Date=$(date "+%Y%m%d")

_watchdog () {

    if [ -f "$keepalive_conf" ];then
        virtual_ip=$(cat /etc/keepalived/keepalived.conf | grep virtual_ipaddress -A 1 | grep -Po "\d+.\d+.\d+.\d+")
        ip a | grep "$virtual_ip" > /dev/null 2>&1
        if [ "$?" -eq "0" ];then
            if [ -f "$polyhawk_home/bin/apt_watchdog" ];then
                curtime=$(date "+%Y/%m/%d %H:%M:%S.%3N")
                $ECHO "$curtime\tCheck Watchdog Status ..." >> /polydata/log/comm_monitor_${Date}.log
                $PS | grep "$polyhawk_home/bin/apt_watchdog" | grep -v grep > /dev/null 2>&1
                if [ "$?" -ne 0 ];then
                   $ECHO "$curtime\tWatchdog is Dead!" >> /polydata/log/comm_monitor_${Date}.log
                   $ECHO "$curtime\tStart booting Watchdog ..." >> /polydata/log/comm_monitor_${Date}.log
                   $ECHO "________________________________________________________________" >> /polydata/log/comm_monitor_${Date}.log
                   $polyhawk_home/bin/apt_watchdog -D >> /polydata/log/comm_monitor_${Date}.log
                   $ECHO "________________________________________________________________" >> /polydata/log/comm_monitor_${Date}.log
                else
                   $ECHO "$curtime\tWatchdog Live!" >> /polydata/log/comm_monitor_${Date}.log
                fi
            fi
        fi
    else
        if [ -f "$polyhawk_home/bin/apt_watchdog" ];then
            curtime=$(date "+%Y/%m/%d %H:%M:%S.%3N")
            $ECHO "$curtime\tCheck Watchdog Status ..." >> /polydata/log/comm_monitor_${Date}.log
            $PS | grep "$polyhawk_home/bin/apt_watchdog" | grep -v grep > /dev/null 2>&1
            if [ "$?" -ne 0 ];then
               $ECHO "$curtime\tWatchdog is Dead!" >> /polydata/log/comm_monitor_${Date}.log
               $ECHO "$curtime\tStart booting Watchdog ..." >> /polydata/log/comm_monitor_${Date}.log
               $ECHO "________________________________________________________________" >> /polydata/log/comm_monitor_${Date}.log
               $polyhawk_home/bin/apt_watchdog -D >> /polydata/log/comm_monitor_${Date}.log
               $ECHO "________________________________________________________________" >> /polydata/log/comm_monitor_${Date}.log
            else
               $ECHO "$curtime\tWatchdog Live!" >> /polydata/log/comm_monitor_${Date}.log
            fi
        fi
    fi
}

_restAPI () {

    curtime=$(date "+%Y/%m/%d %H:%M:%S.%3N")
    $ECHO "$curtime\tCheck MDS RestAPI Status ..." >> /polydata/log/mds_monitor_${Date}.log
    $mds_restapi_boot status > /dev/null 2>&1

    if [ "$?" -ne 0 ];then
        $ECHO "$curtime\tMDS RestAPI is Dead!" >> /polydata/log/mds_monitor_${Date}.log
        $ECHO "$curtime\tStart booting MDS RestAPI ..." >> /polydata/log/mds_monitor_${Date}.log
        $ECHO "________________________________________________________________" >> /polydata/log/mds_monitor_${Date}.log
        $mds_restapi_boot start >> /polydata/log/mds_monitor_${Date}.log
        $ECHO "________________________________________________________________" >> /polydata/log/mds_monitor_${Date}.log
    else
        $ECHO "$curtime\tMDS RestAPI is Live!" >> /polydata/log/mds_monitor_${Date}.log
    fi

}


_gui_monitor () {

    if [ -d "$network_gui_path" ];then
        curtime=$(date "+%Y/%m/%d %H:%M:%S.%3N")
        $ECHO "$curtime\tCheck NetWork Gui Status ..." >> /polydata/log/comm_monitor_${Date}.log
        
        $PS | grep $network_gui_path | grep -v grep > /dev/null 2>&1

        if [ "$?" -ne 0 ];then
            $ECHO "$curtime\tNetWork GUI is Dead!" >> /polydata/log/comm_monitor_${Date}.log
            $ECHO "$curtime\tStart booting NetWork GUI ..." >> /polydata/log/comm_monitor_${Date}.log
            $ECHO "________________________________________________________________" >> /polydata/log/comm_monitor_${Date}.log
            $network_gui_path/bin/startup.sh >> /polydata/log/comm_monitor_${Date}.log
            $ECHO "________________________________________________________________" >> /polydata/log/comm_monitor_${Date}.log
        else
            $ECHO "$curtime\tNetWork GUI is Live" >> /polydata/log/comm_monitor_${Date}.log
        fi
    else
        $ECHO "No install anyone GUI" >> /polydata/log/comm_monitor_${Date}.log
    fi

}

_lic_server () {

    $lic_boot start
}

_mysql () {

    curtime=$(date "+%Y/%m/%d %H:%M:%S.%3N")
    $ECHO "$curtime\tCheck MySQL Server Status ..." >> /polydata/log/comm_monitor_${Date}.log
    netstat -lantp | grep -P "$mysql_port.*0.0.0.0" | grep -v grep > /dev/null 2>&1
    
    if [ "$?" -ne 0 ];then
       $ECHO "$curtime\tMySQL Server is Dead!" >> /polydata/log/comm_monitor_${Date}.log
       $ECHO "$curtime\tStart booting MySQL Server ..." >> /polydata/log/comm_monitor_${Date}.log
       $ECHO "________________________________________________________________" >> /polydata/log/comm_monitor_${Date}.log
       service mysql start >> /polydata/log/comm_monitor_${Date}.log
       $ECHO "________________________________________________________________" >> /polydata/log/comm_monitor_${Date}.log
    else
       $ECHO "$curtime\tMySQL Server is Live!" >> /polydata/log/comm_monitor_${Date}.log
       ln -s /var/run/mysqld/mysqld.sock /polydata/log/mysql.sock > /dev/null 2>&1
    fi

}


__main__ () {

    $ECHO "******************************************************" >> /polydata/log/comm_monitor_${Date}.log
    _watchdog
    _gui_monitor
    _lic_server
    _restAPI
    _mysql

}

__main__

#END SCRIPT
