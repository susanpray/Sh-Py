#!/bin/bash

export LANG=en_US.UTF-8
MYSQL=/usr/bin/mysql

_query_ip_exist () {

    exist_ip=$($MYSQL -uroot -p${DATABASE} --skip-column-names -e "SELECT reserved1 FROM t_obj_instance WHERE reserved1 = '$IP' AND status = 1" ${DATABASE})
    
    if [ "$exist_ip" != "" -a "$exist_ip" = "$IP" ];then
        echo 0
    else
        #not exist ipaddress in t_obj_instance
        echo 1
    fi

}

_query_mac_exist () {

    exist_mac=$($MYSQL -uroot -p${DATABASE} --skip-column-names -e "SELECT reserved5 FROM t_obj_instance WHERE reserved5 = '$MAC' AND status = 1" ${DATABASE})
    
    if [ "$exist_mac" != "" -a "$exist_mac" = "$MAC" ];then
        echo 0
    else
        #not exist MAC in t_obj_instance
        echo 1
    fi

}

_query_hostname_exist () {

    exist_hostname=$($MYSQL -uroot -p${DATABASE} --skip-column-names -e "SELECT instanceName FROM t_obj_instance WHERE instanceName = '$HOSTnAME' AND status = 1" ${DATABASE})
    
    if [ "$exist_hostname" != "" -a "$exist_hostname" = "$HOSTnAME" ];then
        echo 0
    else
        #not exist HostName in t_obj_instance
        echo 1
    fi

}

_insert_new_data () {
    
    _script_log "<$ret_host $ret_ip $ret_mac> Data not found, insert New Record ($HOSTnAME $IP $MAC) "
    $MYSQL -uroot -p${DATABASE} -e "INSERT INTO t_obj_instance (instanceGroupID, upperInstanceID, categoryID, instanceName, instanceNameEN, updatetime, isSysdefault, reserved1, reserved5) VALUE (14,0,14,'$HOSTnAME','$HOSTnAME',SYSDATE(),0,'$IP','$MAC');" ${DATABASE} > /dev/null 2>&1

}

_update_ip_hostname_data () {
    
    _script_log "<$ret_host $ret_ip $ret_mac> Update HOSTNAME and IP address ($HOSTnAME and $IP) "
    $MYSQL -uroot -p${DATABASE} -e "UPDATE t_obj_instance SET instanceName = '$HOSTnAME', reserved1 = '$IP' WHERE reserved5 = '$MAC' AND status = 1;" ${DATABASE} > /dev/null 2>&1

}

_update_ip_mac_data () {
    
    _script_log "<$ret_host $ret_ip $ret_mac> Update IP address and MAC address ($IP and $MAC) "
    $MYSQL -uroot -p${DATABASE} -e "UPDATE t_obj_instance SET reserved1 = '$IP', reserved5 = '$MAC' WHERE instanceName = '$HOSTnAME' AND status = 1;" ${DATABASE} > /dev/null 2>&1

}

_update_mac_hostname_data () {
    
    _script_log "<$ret_host $ret_ip $ret_mac> Update HOSTNAME and MAC address ($HOSTnAME and $MAC) "
    $MYSQL -uroot -p${DATABASE} -e "UPDATE t_obj_instance SET instanceName = '$HOSTnAME', reserved5 = '$MAC' WHERE reserved1 = '$IP' AND status = 1;" ${DATABASE} > /dev/null 2>&1

}

_update_hostname_data () {
    
    _script_log "<$ret_host $ret_ip $ret_mac> Update HOSTNAME ($HOSTnAME) "
    $MYSQL -uroot -p${DATABASE} -e "UPDATE t_obj_instance SET instanceName = '$HOSTnAME' WHERE reserved1 = '$IP' AND reserved5 = '$MAC' AND status = 1;" ${DATABASE} > /dev/null 2>&1

}
_update_ip_data () {
    
    _script_log "<$ret_host $ret_ip $ret_mac> Update IP ($IP) "
    $MYSQL -uroot -p${DATABASE} -e "UPDATE t_obj_instance SET reserved1 = '$IP' WHERE instanceName = '$HOSTnAME' AND reserved5 = '$MAC' AND status = 1;" ${DATABASE} > /dev/null 2>&1

}

_update_mac_data () {
    
    _script_log "<$ret_host $ret_ip $ret_mac> Update MAC ($MAC) "
    $MYSQL -uroot -p${DATABASE} -e "UPDATE t_obj_instance SET reserved5 = '$MAC' WHERE reserved1 = '$IP' AND instanceName = '$HOSTnAME' AND status = 1;" ${DATABASE} > /dev/null 2>&1

}

_check_ip () {

    cnt_ip=0
    for chk_ip in $(cat $CSVFILE | grep -Pv "^IP" | awk -F',' '{print $1}')
    do
        ((cnt_ip++))
        if [[ $(echo $chk_ip | grep -Po "^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])$") ]];then
            continue
        else
            echo -e "IP地址格式错误, 在文件第 $cnt_ip 行"
            _script_log "IP地址格式错误, 在文件第 $cnt_ip 行"
            exit 1
        fi
    done
}

_check_mac () {

    cnt_mac=0
    for chk_mac in $(cat $CSVFILE | grep -Pv "^IP" | awk -F',' '{print $2}')
    do
        ((cnt_mac++))
        if [[ $(echo $chk_mac | grep -Po "^[0-9A-F]{2}([-:]?)([0-9A-F]{2}\1){4}[0-9A-F]{2}$") ]];then
            continue
        else
            echo -e "MAC地址格式错误, 在文件第 $cnt_mac 行"
            _script_log "MAC地址格式错误, 在文件第 $cnt_mac 行"
            exit 1
        fi
    done
}


_parser_csv () {

    _script_log "Parser  $CSVFILE "
    
    DOS2UNIX $CSVFILE
    
    TMP_CSV_FILE="/tmp/$(basename $CSVFILE)_${RANDOM}.csv"
    cat $CSVFILE | grep -Pv "^IP" | awk -F',' '{print $1"|"$2"|"$3}' > $TMP_CSV_FILE
    sed -i "s/ /_/g" $TMP_CSV_FILE
    i=0
    while read Line
    do
        CSV_INFO[$i]="$Line"
        ((i++))
    done < $TMP_CSV_FILE
    
    _script_log "Parser $CSVFILE Success."

}

_script_log () {

    msg="$1"
    Time=$(date "+%Y/%m/%d %H:%M:%S.%3N")
    if [ "$LOGSHOW" = "--debug" ];then
        echo -e "${Time}\t$msg"
    fi
    echo -e "${Time}\t$msg" >> $LOGFile

}


__main__ () {
    
    rm /tmp/*.csv /tmp/*.log > /dev/null 2>&1

    DOS2UNIX="/usr/bin/dos2unix"
    
    declare -a CSV_INFO
    CSVFILE=$1
    DATABASE="polydata"
    
    LOGSHOW=${2:-""}
    
    SCRIPT_NAME=$(basename $0 | awk -F'.' '{print $1}')
    LOGFile="/tmp/${SCRIPT_NAME}_${RANDOM}.log"

    if [ -e "$CSVFILE" ];then
        suffix=$(echo $(basename $CSVFILE | awk -F'.' '{print $NF}'))
        if [ "$suffix" != "csv" ];then
            echo -e "$(basename $CSVFILE) 非CSV文件"
            _script_log "$(basename $CSVFILE) 非CSV文件"
            exit 1
        fi
    else
        echo -e "$CSVFILE 文件不存在"
        _script_log "$CSVFILE 文件不存在"
        exit 1
    fi

    _check_ip
    _check_mac
    
    _parser_csv
    
    for linebyline in ${CSV_INFO[*]}
    do
        IP=$(echo $linebyline | awk -F'|' '{print $1}')
        MAC=$(echo $linebyline | awk -F'|' '{print $2}')
        HOSTnAME=$(echo $linebyline | awk -F'|' '{print $3}')
        
        if [ -z "$HOSTnAME" ];then
            HOSTnAME=$IP
        fi

        ret_host=$(_query_hostname_exist)
        ret_ip=$(_query_ip_exist)
        ret_mac=$(_query_mac_exist)
        
        if [ "$ret_host" -eq 0 -a "$ret_ip" -eq 0 -a "$ret_mac" -eq 1 ];then
            _update_mac_data
        elif [ "$ret_host" -eq 0 -a "$ret_ip" -eq 1 -a "$ret_mac" -eq 0 ];then
            _update_ip_data
        elif [ "$ret_host" -eq 0 -a "$ret_ip" -eq 1 -a "$ret_mac" -eq 1 ];then
            _update_ip_mac_data
        elif [ "$ret_host" -eq 1 -a "$ret_ip" -eq 0 -a "$ret_mac" -eq 0 ];then
            _update_hostname_data
        elif [ "$ret_host" -eq 1 -a "$ret_ip" -eq 0 -a "$ret_mac" -eq 1 ];then
            _update_mac_hostname_data
        elif [ "$ret_host" -eq 1 -a "$ret_ip" -eq 1 -a "$ret_mac" -eq 0 ];then
            _update_ip_hostname_data
        elif [ "$ret_host" -eq 1 -a "$ret_ip" -eq 1 -a "$ret_mac" -eq 1 ];then
            _insert_new_data
        else
            _script_log "<$ret_host $ret_ip $ret_mac> Data already exists ($HOSTnAME $IP $MAC)"
        fi
    done
    
    echo -e "OK"
    _script_log "OK"

}

__main__ $1

#End Script
