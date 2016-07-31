#!/bin/bash

. /etc/profile

LOG_FILE="${PRODUCT_HAWK_DATA}/log/change_local_restapi_server_ip.log"
CUR_DATE=$(date +'%F %T')
MAX_TIMEOUT=60

check_restapi_server_port_status()
{
    echo "`date +'%F %T'` check port status......" >> "${LOG_FILE}"
    
    CHECK_STATUS="OK"
    start_sec=$(date +%s)
    while :
    do
        cur_sec=$(date +%s)
        
        diff_sec=$(( ${cur_sec} - ${start_sec} ))
        echo "diff sec: ${diff_sec}"
        if [ "${diff_sec}" -gt "${MAX_TIMEOUT}" ]
        then
            CHECK_STATUS="FAILED"
            echo "`date +'%F %T'` check port status timeout(${MAX_TIMEOUT}s)" >> "${LOG_FILE}"
            break
        fi
        
        status=$(netstat -npl|grep 8989)
        echo "`date +'%F %T'` status ${status}" >> "${LOG_FILE}"
        
        count=$(netstat -npl|grep -c 8989)
        echo "`date +'%F %T'` count ${count}"  >> "${LOG_FILE}"
        
        
        if [ "${count}" -gt 0 ]
        then
            break
        fi
        
        sleep 1
    done
    echo "`date +'%F %T'` check port status......[${CHECK_STATUS}]" >> "${LOG_FILE}"
}


echo "start to change restapi server ip......" > "${LOG_FILE}"

#change restapi server ip to 0.0.0.0
sed -i -r "s/^host *=.*/host=0\.0\.0\.0/g" ${PRODUCT_HAWK_ROOT}/restapi/conf/rest.properties

dos2unix ${PRODUCT_HAWK_ROOT}/restapi/conf/rest.properties
echo "start to change restapi server ip......[OK]" >> "${LOG_FILE}"

#restart restapi server
echo "restart restapi server......" >> "${LOG_FILE}"
bash ${PRODUCT_HAWK_ROOT}/restapi/bin/polydata_api.sh restart
echo "restart restapi server......[OK]" >> "${LOG_FILE}"

#check port status
check_restapi_server_port_status


