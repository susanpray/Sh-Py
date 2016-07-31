#!/bin/bash

###########################################
#author:    xuhao
#date:      2015-11-03
#Modify:    2015-11-24
############################################

export LANG=en_US.UTF-8

. /etc/profile

#Alias Linux Command

CP="/bin/cp -a"
PS="/bin/ps -ef"
KILL="/bin/kill -9"
ECHO="/bin/echo -e"
CHMOD="/bin/chmod -R"
CHOWN="/bin/chown -R"
MKDIR="/bin/mkdir -p"
MV=/bin/mv
RM=/bin/rm
SED=/bin/sed
SLEEP=/bin/sleep
CLEAR=/usr/bin/clear

polyhawk_home=/polyhawk
polydata_home=/polydata

polyhawk_home_bin=$polyhawk_home/bin

polyhawk_script=$polyhawk_home/script

network_watchdog_boot=$polyhawk_home_bin/apt_watchdog
license_boot=$polyhawk_home/license/license_server_service.sh

restapi_boot=$polyhawk_home/restapi/bin/polydata_api.sh

crontab_path=$polyhawk_home/script

_stop_all () {

    $PS | grep "hawk" | awk '{print $2}' | xargs kill -9
    service mysql restart > /dev/null 2>&1

}

_watchdog () {

    AC=$1
    $ECHO "$AC APT Watchdog Server ..."
    $PS | grep "apt_watchdog" | grep -v grep > /dev/null 2>&1
    if [ "$?" -ne 0 -a "$AC" = "start" ];then
        $network_watchdog_boot -D > /dev/null 2>&1
    elif [ "$?" -eq 0 -a "$AC" = "stop" ];then
        $PS | grep "apt_watchdog" | grep -v grep | awk '{print $2}' | xargs kill -9
    elif [ "$?" -eq 0 -a "$AC" = "restart" ];then
        _watchdog "stop" > /dev/null 2>&1
        $SLEEP 3
        _watchdog "start" > /dev/null 2>&1
    fi
}

_restapi () {

    $ECHO "$AC Start RestAPI Server ..."
    $restapi_boot $AC > /dev/null 2>&1
    if [ "$AC" = "restart" ];then
        _restapi "stop" > /dev/null 2>&1
        $SLEEP 5
        _restapi "start" > /dev/null 2>&1
    fi

}

_license () {

    $ECHO "$AC Start License Server ..."
    $license_boot $AC > /dev/null 2>&1
    if [ "$AC" = "restart" ];then
        _license "stop" > /dev/null 2>&1
        $SLEEP 5
        _license "start" > /dev/null 2>&1
    fi
}

_record_crontab (){

    isnull=$(crontab -l)

    if [ ! -z "$isnull" ];then
        crontab -l > $crontab_path/crontask_bak
    fi

}

_del_crontab () {

    rm $crontab_path/crontask_bak > /dev/null 2>&1
    _record_crontab
    crontab -r

}

_write_crontab () {

    if [ -f "/polyhawk/script/crontask_bak" ];then
        crontab $crontab_path/crontask_bak
    else
        crontab $crontab_path/crontask
    fi

}


__main__ () {

    action=$1
    case $action in
            "start")
                    _write_crontab
                    /usr/bin/perl /polyhawk/script/get_nic_info.pl -u > /dev/null 2>&1 &
                    _watchdog $action
                    _license $action
                    _restapi $action
                    ;;
            "stop")
                    _del_crontab
                    _restapi $action
                    _watchdog $action
                    _license $action
                    _stop_all
                    ;;
            "restart")
                    _del_crontab
                    _restapi $action
                    _watchdog $action
                    _stop_all
                    _license $action
                    _write_crontab
                    ;;
            *)
                    $ECHO "Opps !!!"
                    ;;
    esac

}

__main__ $1

