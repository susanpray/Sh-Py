#!/bin/bash

. /etc/profile

_read_conf () {

    isreset=$(cat $PRODUCT_HAWK_ROOT/conf/common.conf | grep -Po "^reset_AMS.*" | grep -Po "\d+")
    return $isreset

}

_restart_activemq () {

    $PRODUCT_HAWK_ROOT/3rdparty/apache-activemq/bin/activemq restart > $PRODUCT_HAWK_DATA/log/reset_AMS.log

}

_restart_apt_mining () {

    ps -ef | grep -P "mining" | grep -v grep | awk '{print $2}'
    sleep 5
    $PRODUCT_HAWK_ROOT/bin/apt_mining -D

}

_restart_sandbox () {

    $PRODUCT_HAWK_ROOT/service/sandbox.sh restart >> $PRODUCT_HAWK_DATA/log/reset_AMS.log

}

__main__ () {

    _read_conf

    if [ "$?" -eq "1" ];then
        _restart_activemq
        _restart_apt_mining
        _restart_sandbox
    elif [ "$?" -eq "0" ];then
        echo -e "Reset Function is disable." >> $PRODUCT_HAWK_DATA/log/reset_AMS.log
    else
        echo -e "[$?] is Unknown Value for Configuration." >> $PRODUCT_HAWK_DATA/log/reset_AMS.log
    fi

}

__main__
