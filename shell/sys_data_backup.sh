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

#DB_NAME=$(sed -rn "s/^binlog-do-db *=(.*)/\1/p" /etc/mysql/my.cnf | sed "s/ //g")
#if [ x"${DB_NAME}" = x ]
#then
#	echo "can't get database scheme to be backuped, exit now!"
#	exit 1
#fi



PKG_PASSWD="on9iEx2UvaG0HQBip0BvTU3XTE7T32"

DB_DATA_DIR=$(sed -rn "s/^datadir[ \t]*=[ \t]*(.*)[ \t]*/\1/p" /etc/mysql/my.cnf)
if [ x"${DB_DATA_DIR}" = x ]
then
	DB_DATA_DIR=/polydata/mysql
fi

echo "DB_DATA_DIR: ${DB_DATA_DIR}"

#NODE_ID=$(dmidecode -t 2  2>/dev/null | grep Serial | awk -F: '{printf $2}'|sed 's/^\s*//g'|tr A-Z a-z)
#if [ x"${NODE_ID}" = x ]
#then
#	echo "can't get serial of machine"
#	exit 1 
#fi

SERVER_IP=$(sed -rn "s/^ip[ \t]*=[ \t]*(.*)[ \t]*/\1/p" ${PRODUCT_HAWK_ROOT}/conf/common.conf)
if [ x"${SERVER_IP}" = x ]
then
	echo "can't get ip from ${PRODUCT_HAWK_ROOT}/conf/common.conf"
	error_exit 1 
fi

echo "SERVER_IP: ${SERVER_IP}"


IS_FULL_BACKUP=0

soc_data_backup_help()
{
	echo "Usage: ${EXE_NAME} <database name> <backup type>"
	echo "parameters specification:"
	echo "database name: garuda-soc db instance;polydata-networkasa,mail db instance"
	echo "backup type: 1-full backup; 2-Incremental Backup, default value: 2"
}


#check if it's necessary to backup data
if [ -f "$CONGIF_FILE" ]
then
	dos2unix "${CONGIF_FILE}"
	#. "$PRODUCT_HAWK_ROOT/conf/data_manager.conf"
	. "${CONGIF_FILE}"
else
	echo "$CONGIF_FILE is not existed, exit now!"
	exit 1
fi


if [ "$backupEnable" -eq 0 ]
then
	echo "backupEnable is 0, so it doesn't need to backup, exit now!"
	exit 1
fi

#verify input parameters
if [ $# -eq 1 ]
then
	DB_NAME="$1"
	BACKUP_TYPE=2
elif [ $# -eq 2 ]
then
	DB_NAME="$1"
	BACKUP_TYPE=$2
else
	soc_data_backup_help
	exit 1
fi

upload_with_ftp()
{
ftp -n $1 $2 <<!
user $3 $4
binary
cd $6
prompt off
put $5
close
bye
!
}

upload_data()
{
	#upload
	if [ $transType -eq 1 ]
	then
		expect "$PRODUCT_HAWK_ROOT/script/scp_upload.exp" $ipaddress $port $username $password $1 $path
	elif [ $transType -eq 2 ]
	then
		upload_with_ftp $ipaddress $port $username $password `basename $1` $path
	fi
}

full_backup_data()
{
	echo "${CUR_DATE} start full backup......"
	
	backup_pkg="db_full_bk_${SERVER_IP}.tar.gz"
	record_count=$(mysql -u${DB_USER} -p${DB_PASSWORD} -e "select count(*) from t_sys_backuplog where backupName='${backup_pkg}';" ${DB_NAME}|grep -v "+"|grep -v count)
	echo "${backup_pkg} record_count: ${record_count}" 
	
	if [ "${record_count}" -gt 0 ]
	then 
		echo "this machine has been made full backup, so it doesn't need to backup"
		IS_FULL_BACKUP=1
		return
	fi
	
	cd ${LOCAL_BACKUP_PATH}
	backup_filename="db_full_bk_${SERVER_IP}.dmp"
	echo "file to backup: ${LOCAL_BACKUP_PATH}/${backup_filename}"
	
	#record backup log this time
	sql="INSERT INTO t_sys_backuplog (backupName, backupTime, backupFilePath) VALUES ('${backup_pkg}', now(), '${LOCAL_BACKUP_PATH}');commit;"
	echo "${sql}"
	mysql -u${DB_USER} -p${DB_PASSWORD} -e "${sql}"  ${DB_NAME}

	mysqldump -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} > "${backup_filename}"
	
	#tar -zcvf "${backup_pkg}" "${backup_filename}"
	tar -zcvf - "${backup_filename}" | openssl des3 -salt -k "${PKG_PASSWD}" -out "${backup_pkg}"
	rm -f "${backup_filename}"
	
	#upload
	upload_data "${LOCAL_BACKUP_PATH}/${backup_pkg}"
	if [ $? -ne 0 ]
	then
		echo "upload ${LOCAL_BACKUP_PATH}/${backup_pkg} failed"
		
		#no remove backup package, for restoring from local disk
		#rm -f "${LOCAL_BACKUP_PATH}/${backup_pkg}"
		
		#echo "${CUR_DATE} start full backup......[FAILED]"
		#exit 1
	fi
	
	rm -f "${LOCAL_BACKUP_PATH}/${backup_pkg}"
	IS_FULL_BACKUP=1
	
	echo "${CUR_DATE} start full backup......[OK]"
}

incremental_backup_data()
{
	echo "${CUR_DATE} start Incremental backup......"
	backup_filename="${PRODUCT_HAWK_DATA}/backup/db_inc_bk${CUR_DAY}_${SERVER_IP}.dmp"

	backup_pkg="db_inc_bk${CUR_DAY}_${SERVER_IP}.tar.gz"
	record_count=$(mysql -u${DB_USER} -p${DB_PASSWORD} -e "select count(*) from t_sys_backuplog where backupName='${backup_pkg}';" ${DB_NAME}|grep -v "+"|grep -v count)
	
	echo "${backup_pkg} record_count: ${record_count}" 
	#if [ -f "${backup_filename}" ]
	if [ "${record_count}" -gt 0 ]
	then 
		echo "${backup_filename} is existed, so it doesn't need to backup"
		return
	fi

	cd ${LOCAL_BACKUP_PATH}
	
	#rm -f ${DB_DATA_DIR}/soc_db_data.*
	
	#get lastest backupfile
	#binlog_backup_filename=$(find ${DB_DATA_DIR} -name soc_db_data.* -print)
	binlog_data_prefix=$(sed -rn "s/^log-bin[ \t]*=[ \t]*(.*)[ \t]*/\1/p" /etc/mysql/my.cnf)
	if [ x"${binlog_data_prefix}" = x ]
	then
		echo "can't get log-bin value from /etc/mysql/my.conf"
		exit 1	
	fi
	
	echo "binlog_data_prefix: ${binlog_data_prefix}"
	
	binlog_backup_filename=$(ls -lt ${DB_DATA_DIR}/${binlog_data_prefix}*| head -n 1|awk '{print $NF}')
	echo "binlog_backup_filename ${binlog_backup_filename}"
	
	if [ x"${binlog_backup_filename}" = x ]
	then
		echo "There is no any file to backup"
		echo "${CUR_DATE} start Incremental backup......[FAILED]"
		exit 1
	fi
	
	#delete other binlog file except the lastest one
	ls ${DB_DATA_DIR}/${binlog_data_prefix}*|grep -v "${binlog_backup_filename}"|xargs rm -f
		
	#record backup log this time
	sql="INSERT INTO t_sys_backuplog (backupName, backupTime, backupFilePath) VALUES ('${backup_pkg}', now(), '${LOCAL_BACKUP_PATH}');commit;"
	echo "${sql}"
	mysql -u${DB_USER} -p${DB_PASSWORD} -e "${sql}" ${DB_NAME}


	#mysqldump --flush-logs -u${DB_USER} -p${DB_PASSWORD}  ${DB_NAME} > /dev/null
	mysqladmin -u${DB_USER} -p${DB_PASSWORD} flush-logs

	echo "file to backup: ${backup_filename}"
	
	if [ -f "${binlog_backup_filename}" ]
	then
		mv "${binlog_backup_filename}" "${backup_filename}"
	else
		echo "${binlog_backup_filename} is not existed!"
		echo "${CUR_DATE} start Incremental backup......[FAILED]"
		exit 1
	fi

	#tar -zcvf "${backup_pkg}" "db_inc_bk${CUR_DAY}_${SERVER_IP}.dmp"
	tar -zcvf - "db_inc_bk${CUR_DAY}_${SERVER_IP}.dmp" | openssl des3 -salt -k "${PKG_PASSWD}" -out "${backup_pkg}"
	rm -f "${backup_filename}"
	
	#upload
	upload_data "${LOCAL_BACKUP_PATH}/${backup_pkg}"
	if [ $? -ne 0 ]
	then
		echo "upload ${LOCAL_BACKUP_PATH}/${backup_pkg} failed"
		
		#no remove backup package, for restoring from local disk
		#rm -f "${LOCAL_BACKUP_PATH}/${backup_pkg}"
		#echo "${CUR_DATE} start Incremental backup......[FAILED]"
		#exit 1
	fi
		
	rm -f "${LOCAL_BACKUP_PATH}/${backup_pkg}"
	
	echo "${CUR_DATE} start Incremental backup......[OK]"
}

main()
{
	#create backup dir of local and remote host
	mkdir -p "${LOCAL_BACKUP_PATH}"

    if [ "$transType" -eq 1 ]
	then
    	expect "$PRODUCT_HAWK_ROOT/script/ssh_exe_cmd.exp" $ipaddress $port $username $password ". /etc/profile && mkdir -p ${path}"
	fi
		
	if [ "${BACKUP_TYPE}" -eq 1 ]
	then
		full_backup_data
	elif [ "${BACKUP_TYPE}" -eq 2 ]
	then
		full_backup_data
		if [ "${IS_FULL_BACKUP}" -eq 1 ]
		then
			incremental_backup_data	
		fi
	else
		echo "invalid backup type"
		soc_data_backup_help
	fi
}

######################################################################
#  main entry                                                        #
######################################################################
main
