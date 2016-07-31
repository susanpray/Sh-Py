#!/bin/bash

. /etc/profile

export PATH=/usr/bin:/bin:/sbin:$PATH
echo "PATH: $PATH"

new_ip=$1

_judge_IF () {

    /sbin/ifconfig eth0 > /dev/null 2>&1
    if [ "$?" -eq 0 ];then
        nic_a_name="eth0"
        nic_b_name="eth1"
        old_ip=$(/sbin/ifconfig eth0 | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')
    else
        nic_a_name="em1"
        nic_b_name="em2"
        old_ip=$(/sbin/ifconfig em1 | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')
    fi
    sed -i "s/$old_ip/$new_ip/g" /polyhawk/conf/common.conf
    sed -i "s/$old_ip/$new_ip/g" /polyhawk/gui/apache-tomcat/webapps/garuda/WEB-INF/classes/config/licrest.properties > /dev/null 2>&1
}

update_nw_if_stat_info()
{
    #update network interface status information
    if [ -f "${PRODUCT_HAWK_ROOT}/script/get_nic_info.pl" ]
    then
        perl "${PRODUCT_HAWK_ROOT}/script/get_nic_info.pl" -u
    fi
}

_judge_IF

#obsolete here
#update_nw_if_stat_info

/sbin/reboot
