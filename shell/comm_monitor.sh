#!/bin/bash

m=`pgrep ^$(basename $0)$`
echo $m | grep -q " "
if [ $? -eq 0 ]
then
      echo "$0 is already running" 
      exit 1
fi

#get global var
.  /etc/profile

if [ "${PRODUCT_HAWK_ROOT}" == "x" ]
then
    PRODUCT_HAWK_ROOT="/polyhawk"
fi

if [ "${PRODUCT_HAWK_DATA}" == "x" ]
then
    PRODUCT_HAWK_DATA="/polydata"
fi

#define var
export LANG=en_US.UTF-8

PS="/bin/ps -ef"
PSA="/bin/ps aux"
ECHO="/bin/echo -e"
KILL="/bin/kill"
RM="/bin/rm"

#service 
index_service="${PRODUCT_HAWK_ROOT}/service/apt_index.sh"
es_service="${PRODUCT_HAWK_ROOT}/service/apt_es.sh"
lic_service="${PRODUCT_HAWK_ROOT}/license/license_server_service.sh"
gui_service="${PRODUCT_HAWK_ROOT}/service/apt_gui.sh"
 
#log file
Date=$(date "+%Y%m%d")
LOG_FILE="${PRODUCT_HAWK_DATA}/log/comm_monitor_${Date}.log"

#
# define function
#

_index () {

   
    curtime=$(date "+%Y/%m/%d %H:%M:%S.%3N")
    $ECHO "$curtime\tCheck Index Status ..." >> ${LOG_FILE}
    
    
    ${index_service} status &> /dev/null
    if [ "$?" -ne 0 ];then
       $ECHO "$curtime\tIndex is Dead!" >> ${LOG_FILE}
       $ECHO "$curtime\tStart booting Index ..." >> ${LOG_FILE}
       $ECHO "________________________________________________________________" >> ${LOG_FILE}
       
       ${index_service} restart >> ${LOG_FILE}
       printf "%-20s not running, restart\n" "index" 
    
    else
       $ECHO "$curtime\tIndex Live!" >> ${LOG_FILE}
       printf "%-20s ok\n" "index" 
    fi
    
}

_gui_monitor () {
    
    curtime=$(date "+%Y/%m/%d %H:%M:%S.%3N")
    $ECHO "$curtime\tCheck MDS Gui Status ..." >> ${LOG_FILE}

    ${gui_service} status >> ${LOG_FILE}
    if [ "$?" -ne 0 ];then
        $ECHO "$curtime\tGUI is Dead!" >> ${LOG_FILE}
        $ECHO "$curtime\tStart booting GUI ..." >> ${LOG_FILE}
        $ECHO "________________________________________________________________" >> ${LOG_FILE}
       
       ${gui_service} restart &> /dev/null
        printf "%-20s not running, restart\n" "gui" 
    else
        $ECHO "$curtime\tGUI is Live" >> ${LOG_FILE}
        printf "%-20s ok\n" "gui" 
    fi
    

}

_lic_server () {
   
    curtime=$(date "+%Y/%m/%d %H:%M:%S.%3N")
    $ECHO "$curtime\tCheck license Server Status ..." >> ${LOG_FILE}
        
    ${lic_service} status &> /dev/null
    if [ "$?" -ne 0 ];then
       $ECHO "$curtime\tLicense Server is Dead!" >> ${LOG_FILE}
       $ECHO "$curtime\tStart booting License Server ..." >> ${LOG_FILE}
       $ECHO "________________________________________________________________" >> ${LOG_FILE}
       
       ${lic_service} restart >> ${LOG_FILE}
       printf "%-20s not running, restart\n" "license" 
    else
       $ECHO "$curtime\tES Serveris Live!" >> ${LOG_FILE}
       printf "%-20s ok\n" "license" 
    fi
}

_es() {
    
    curtime=$(date "+%Y/%m/%d %H:%M:%S.%3N")
    $ECHO "$curtime\tCheck ES Server Status ..." >> ${LOG_FILE}
        
    ${es_service} status &> /dev/null
    if [ "$?" -ne 0 ];then
       $ECHO "$curtime\tES Server is Dead!" >> ${LOG_FILE}
       $ECHO "$curtime\tStart booting ES Server ..." >> ${LOG_FILE}
       $ECHO "________________________________________________________________" >> ${LOG_FILE}
       
       ${es_service} restart >> ${LOG_FILE}
       printf "%-20s not running, restart\n" "es" 
    else
       $ECHO "$curtime\tES Serveris Live!" >> ${LOG_FILE}
       printf "%-20s ok\n" "es" 
    fi
    
}

_mysql () {

    curtime=$(date "+%Y/%m/%d %H:%M:%S.%3N")
    $ECHO "$curtime\tCheck MySQL Server Status ..." >> ${LOG_FILE}
    
    service mysql status &> /dev/null
    
    if [ "$?" -ne "0" ];then
       $ECHO "$curtime\tMySQL Server is Dead!" >> ${LOG_FILE}
       $ECHO "$curtime\tStart booting MySQL Server ..." >> ${LOG_FILE}
       $ECHO "________________________________________________________________" >> ${LOG_FILE}
       
       service mysql restart >> ${LOG_FILE}
       printf "%-20s not running, restart\n" "mysql" 
    else
       $ECHO "$curtime\tmysql service is Live!" >> ${LOG_FILE}
       printf "%-20s ok\n" "mysql"            
       if [ ! -f "/tmp/mysql.sock" ];then
           ln -s /var/run/mysqld/mysqld.sock /tmp/mysql.sock > /dev/null 2>&1
       fi
    fi

}

_ssh () {

    curtime=$(date "+%Y/%m/%d %H:%M:%S.%3N")
    $ECHO "$curtime\tCheck SSH Service Status ..." >> ${LOG_FILE}
    service ssh status &> /dev/null
    if [ "$?" -ne 0 ];then
        $ECHO "$curtime\tSSH Service is Dead!" >> ${LOG_FILE}
        $ECHO "$curtime\tStart booting SSH Service ..." >> ${LOG_FILE}
        $ECHO "________________________________________________________________" >> ${LOG_FILE}
        
        service ssh restart >> ${LOG_FILE}
        printf "%-20s not running, restart\n" "ssh" 
    else
        $ECHO "$curtime\tSSH Service is Live!" >> ${LOG_FILE}
        printf "%-20s ok\n" "ssh" 
    fi

}

_ntp () {

    curtime=$(date "+%Y/%m/%d %H:%M:%S.%3N")
    $ECHO "$curtime\tCheck NTP Service Status ..." >> ${LOG_FILE}
    service ntp status &> /dev/null
    if [ "$?" -ne 0 ];then
        $ECHO "$curtime\tNTP Service is Dead!" >> ${LOG_FILE}
        $ECHO "$curtime\tStart booting NTP Service ..." >> ${LOG_FILE}
        $ECHO "________________________________________________________________" >> ${LOG_FILE}
        
        service ntp restart >> ${LOG_FILE}
        printf "%-20s not running, restart\n" "ntp" 
    else
        $ECHO "$curtime\tNTP Service is Live!" >> ${LOG_FILE}
        printf "%-20s ok\n" "ntp" 
    fi

}


__main__ () {

    $ECHO "******************************************************" >> ${LOG_FILE}
    if [ ! -d "/polydata/mail" ];then
         _es
         _index
         _mysql
         _gui_monitor
        
         _lic_server       
           
        _ntp
     
        
    else
        _lic_server
        _mysql
        _ntp        
      
    fi
}

__main__

#END SCRIPT
