#!/bin/bash

. /etc/profile

export PATH=/usr/sbin:/usr/bin:/bin:${PATH}
echo "PATH: ${PATH}"

LOCAL_BACKUP_PATH="${PRODUCT_HAWK_DATA}/backup"
EXE_NAME=$0
CONGIF_FILE="$PRODUCT_HAWK_ROOT/conf/data_manager.conf"

CUR_DATE=$(date +"%Y-%m-%d %H:%M:%S")
CUR_DAY=$(date +"%Y%m%d")

DB_USER=polydata
DB_PASSWORD=data_poly@\)\!%
#DB_NAME=garuda

#DB_NAME=$(sed -rn "s/^binlog-do-db *=(.*)/\1/p" /etc/mysql/my.cnf | sed "s/ //g")
#if [ x"${DB_NAME}" = x ]
#then
#	echo "can't get database scheme to be backuped, exit now!"
#	exit 1
#fi

#echo "DB_NAME: ${DB_NAME}"
SERVER_IP=$(sed -rn "s/^ip *=(.*)/\1/p" ${PRODUCT_HAWK_ROOT}/conf/common.conf | sed "s/ //g")
if [ x"${SERVER_IP}" = x ]
then
	echo "can't get ip from ${PRODUCT_HAWK_ROOT}/conf/common.conf"
	error_exit 1 
fi


PKG_PASSWD=""

#check if it's necessary to backup data
if [ -f "$CONGIF_FILE" ]
then
	dos2unix "${CONGIF_FILE}"
	. "$PRODUCT_HAWK_ROOT/conf/data_manager.conf"
else
	echo "$CONGIF_FILE is not existed, exit now!"
	exit 1
fi


download_with_ftp()
{
ftp -n $1 $2 <<!
user $3 $4
binary
cd $6
prompt off
get $5
close
bye
!
}

download_data()
{
	#upload
	if [ $transType -eq 1 ]
	then
		expect "$PRODUCT_HAWK_ROOT/script/scp_download.exp" $ipaddress $port $username $password "$1" "${LOCAL_BACKUP_PATH}"
	elif [ $transType -eq 2 ]
	then
		download_with_ftp $ipaddress $port $username $password "$1" "${LOCAL_BACKUP_PATH}"
	fi
}

soc_data_restore_help()
{
	echo "Usage: ${EXE_NAME} <database name> <restore password> [restore data source] [restore type] [restore start time] [restore stop time]"
	echo "parameters specification:"
	echo "database name: garuda-soc db instance;polydata-networkasa,mail db instance"
	echo "restore password: necessary parameter"
	echo "restore data source: 1-from local; 2-from backup server, Default value: 2"
	echo "restore type: 1-full restore; 2-Incremental restore, Default value: 2"
	echo "restore start/stop time: format %Y-%m-%d %H:%M:%S"
}


restore_all_data()
{
	echo "${CUR_DATE} start full restore......"
	
	if [ "${restore_data_source}" -ne 1 -a "${restore_data_source}" -ne 2 ]
	then
		echo "unknown restore data source"
		soc_data_restore_help
		echo "${CUR_DATE} start full restore......[FAILED]"
		exit 1
	fi
		
	backupName="db_full_bk_${SERVER_IP}.tar.gz"
	
	#priority of using backup package: local -> remote
	
	
	if [ "${restore_data_source}" -eq 2 ]
	then
		#download backup package from server if not in local backup dir
		download_data "${path}/${backupName}"
		#if [ $? -ne 0 ]
		#then
		#	echo "download ${path}/${backupName} failed"
		#	echo "${CUR_DATE} start full restore......[FAILED]"
		#	exit 1
		#fi
	fi
	
	if [ ! -f "${LOCAL_BACKUP_PATH}/${backupName}" ]
	then
		echo "there is no ${LOCAL_BACKUP_PATH}/${backupName} in disk."
		echo "${CUR_DATE} start full restore......[FAILED]"
		exit 1
	fi

	#backup t_sys_backuplog table
	#backuplog_dump_file="${PRODUCT_HAWK_DATA}/backup/t_sys_backuplog.dmp"
	#mysqldump -t --replace -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} t_sys_backuplog > "${backuplog_dump_file}"	
	
	mysql -u${DB_USER} -p${DB_PASSWORD} -e "DROP DATABASE IF EXISTS ${DB_NAME};CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
	
	cd "${LOCAL_BACKUP_PATH}"
	#tar -zxvf "${backupName}"
	openssl des3 -d -k "${PKG_PASSWD}" -salt -in "${backupName}" | tar xzf -
		
	echo "${LOCAL_BACKUP_PATH}/${backupName}"
	backup_file=$(echo ${LOCAL_BACKUP_PATH}/${backupName}|sed "s/tar.gz/dmp/")
	echo "backup file: ${backup_file}"
	
	mysql -u${DB_USER} -p${DB_PASSWORD}	-D ${DB_NAME} < "${backup_file}"
	
	rm -f "${backup_file}"
	
	#restore t_sys_backuplog table 
	#if [ -f "${PRODUCT_HAWK_DATA}/backup/t_sys_backuplog.dmp" ]
	#then
	#	mysql -u${DB_USER} -p${DB_PASSWORD} -D ${DB_NAME} < "${backuplog_dump_file}"
	#	rm -f "${backuplog_dump_file}"
	#fi

	echo "${CUR_DATE} start full restore......[OK]"
}

restore_action()
{
	cd "${LOCAL_BACKUP_PATH}"
	
	item="$1"
	
	if [ ! -f "${LOCAL_BACKUP_PATH}/${item}" ]
	then
		echo "there is no ${LOCAL_BACKUP_PATH}/${item} in local disk!!!"
		continue
	fi

	#tar -zxvf "${item}"
	openssl des3 -d -k "${PKG_PASSWD}" -salt -in "${item}" | tar xzf -
		
	backup_file=$(echo "${LOCAL_BACKUP_PATH}/${item}"|sed "s/tar.gz/dmp/")
	echo "mysqlbinlog --stop-datetime=\"${restore_stop_time}\" \"${backup_file}\"|mysql -u${DB_USER} -p -f"
	mysqlbinlog --stop-datetime="${restore_stop_time}" "${backup_file}"|mysql -u${DB_USER} -p${DB_PASSWORD} -f

	rm -f "${backup_file}"
}

restore_incremental_data()
{
	echo "${CUR_DATE} start incremental restore......"
	
	if [ "${restore_data_source}" -ne 1 -a "${restore_data_source}" -ne 2 ]
	then
		echo "unknown restore data source"
		soc_data_restore_help
		echo "${CUR_DATE} start full restore......[FAILED]"
		exit 1
	fi
	
	cd "${LOCAL_BACKUP_PATH}"
	
	restore_start_time=""
	
	if [ $# -eq 0 ]
	then 
		restore_stop_time=$(date +"%Y-%m-%d %H:%M:%S")
	elif [ $# -eq 1 ]
	then
		restore_stop_time="$1"
	elif [ $# -eq 2 ]
	then
		restore_start_time="$1"
		restore_stop_time="$2"
	else
		echo "restore_incremental_data(): invalid parameter count "
		echo "${CUR_DATE} start incremental restore......[FAILED]"
		exit 1
	fi

	if [ "${restore_data_source}" -eq 2 ]
	then
		#get all incremental backup package from server
		backupPkg="${path}/db_inc_bk*_${SERVER_IP}.tar.gz"
		download_data "${backupPkg}"
		#if [ $? -ne 0 ]
		#then
		#	echo "download ${backupPkg} failed"
		#	echo "${CUR_DATE} start incremental restore......[FAILED]"
		#	exit 1
		#fi
	fi
	
	if [ x"${restore_start_time}" = x ]
	then
		begin_bk_package=$(ls -rt db_inc_bk*_${SERVER_IP}.tar.gz|head -n 1)
	else
		begin_bk_package=$(echo "${restore_start_time}"|sed 's/-//g'|awk '{print "db_inc_bk"$1"_${SERVER_IP}.tar.gz"}')
	fi

	if [ ! -f "${begin_bk_package}" ]
	then
		begin_bk_package=$(ls -rt db_inc_bk*_${SERVER_IP}.tar.gz|head -n 1)
	fi
		
	end_bk_package=$(echo "${restore_stop_time}"|sed 's/-//g'|awk '{print "db_inc_bk"$1"_${SERVER_IP}.tar.gz"}')
	if [ ! -f "${end_bk_package}" ]
	then
		end_bk_package=$(ls -t db_inc_bk*_${SERVER_IP}.tar.gz|head -n 1)
	fi
	
	echo "begin_bk_package: ${begin_bk_package}"
	echo "end_bk_package: ${end_bk_package}"
	
	
	restore_action "${begin_bk_package}"
	
	filelist=$(find . -name "db_inc_bk*_${SERVER_IP}.tar.gz" -newer "${begin_bk_package}" ! -newer "${end_bk_package}"|sort -n)
		
	for item in ${filelist}
	do
    	echo "item: ${item}"
		restore_action "${item}"
	done
		
	echo "${CUR_DATE} start incremental restore......[OK]"	
}


######################################################################
#  main entry                                                        #
######################################################################
mkdir -p "${PRODUCT_HAWK_DATA}/backup"

#stop all the service of soc
#ps -ef | grep /polyhawk | grep -v grep | awk '{print $2}' | xargs kill -9
ps -ef | grep /polyhawk | grep -v -E 'grep|sys_data_restore' | awk '{print $2}' | xargs kill -9

if [ $# -eq 2 ]
then
	#parameter list: <database name> <restore password>
	DB_NAME="$1"
	PKG_PASSWD="$2"
	restore_data_source=2
	#restore type:2
	restore_incremental_data 
elif [ $# -eq 4 ]
then
	#parameter list: <database name> <restore password> <restore data source> <restore type>
	DB_NAME="$1"
	PKG_PASSWD="$2"
	restore_data_source=$3
	
	#restore type
	if [ "$4" -eq 1 ]
	then
		restore_all_data
	elif [ "$4" -eq 2 ]
	then
		restore_incremental_data
	else
		echo "first parmeter is not 1 or 2, exit now!"
		exit 1
	fi
elif [ $# -eq 5 ]
then
	#parameter list: <database name> <restore password> <restore data source> <restore type> <restore stop time>
	DB_NAME="$1"
	PKG_PASSWD="$2"

	restore_data_source=$3
	
	restore_incremental_data "$5"
elif [ $# -gt 6 ]
then
	#parameter list: <database name> <restore password> <restore data source> <restore type> <restore start time> <restore stop time>
	DB_NAME="$1"
	PKG_PASSWD="$2"
	
	restore_data_source=$3
	
	restore_incremental_data "$5" "$6"
else
	soc_data_restore_help
	exit 1
fi

#restart machine
/sbin/shutdown -r now
