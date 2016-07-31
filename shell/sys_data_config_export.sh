#!/bin/bash

. /etc/profile

export PATH=/usr/sbin:/usr/bin:/bin:${PATH}
echo "PATH: ${PATH}"

BACKUP_PATH="${PRODUCT_HAWK_DATA}/backup"
EXE_NAME=$0
CONGIF_FILE="${PRODUCT_HAWK_ROOT}/conf/sys_data_manager.conf"

CUR_DATE=$(date +"%Y-%m-%d %H:%M:%S")
CUR_DAY=$(date +"%Y%m%d")
CUR_DATETIME=$(date +"%Y%m%d%H%M%S")

DB_USER=polydata

DB_PASSWORD=data_poly@\)\!%

#DB_NAME=polydata

PKG_PASSWD=""

MAX_PRESERVE_FILES=10

#SYS_TABLES="t_sys_param_init t_sys_usergroup t_sys_user t_sys_user_subsys t_sys_role t_sys_role_module t_sys_user"
SYS_TABLES_COMMON="t_sys_param_init t_sys_usergroup t_sys_role t_sys_role_module t_sys_user"
SYS_TABLES_SOC=""
SYS_TABLES_NETWORKSAS=""


POLICY_TABLES_COMMON="t_obj_instance_group t_obj_instance t_pol_group t_pol_filter t_pol_category \
t_pol_inc_status t_pol_inc_status_filter t_pol_inc_generator t_pol_inc_policy \
t_pol_statistics_rule t_pol_datamining t_cmp_packet_filter t_cmp_packet_saverule"

POLICY_TABLES_SOC=""
POLICY_TABLES_NETWORKSAS=""


CONFIG_FILES_COMMON="/polyhawk/conf \
/polyhawk/restapi/conf \
/polyhawk/gui/apache-tomcat/keystore \
/etc/profile \
/etc/bash.bashrc \
/etc/network/interfaces \
/etc/resolv.conf \
/etc/resolvconf/resolv.conf.d/base \
/etc/timezone \
/etc/ntp.conf \
/etc/hosts \
/etc/hostname \
/etc/mysql/my.cnf \
/root/.ssh \
/root/.bashrc"

CONFIG_FILES_SOC="/polyhawk/gui/apache-tomcat/webapps/garuda/WEB-INF/classes/config"
CONFIG_FILES_NETWORKSAS="/polyhawk/gui/apache-tomcat/webapps/hawk/WEB-INF/classes/config"

usage()
{
	echo "Usage: ${EXE_NAME} <product type> <export type>"
	echo "parameters specification:"
	echo "product type: 1-networksas; 2-soc"
	echo "export type: 1-manual export; 2-auto export"
}

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
		expect "${PRODUCT_HAWK_ROOT}/script/scp_upload.exp" $ipaddress $port $username $password $1 $path
	elif [ $transType -eq 2 ]
	then
		upload_with_ftp $ipaddress $port $username $password `basename $1` $path
	fi
}

error_exit()
{
	echo "FAILED"
	exit $1
}

main()
{
	echo $FUNCNAME $@
	mkdir -p "${BACKUP_PATH}"
	
    server_ip=$(sed -rn "s/^ip *=(.*)/\1/p" ${PRODUCT_HAWK_ROOT}/conf/common.conf | sed "s/ //g")
    if [ x"${server_ip}" = x ]
    then
		echo "can't get ip from ${PRODUCT_HAWK_ROOT}/conf/common.conf"
		error_exit 1 
    fi
	
	product_version_file="${BACKUP_PATH}/my_product_version"
	db_data_sql_file="${BACKUP_PATH}/db_policy_data.sql"	
	db_config_sql_file="${BACKUP_PATH}/db_sys_data.sql"	
	if [ $# -ne 2 ]
	then
		echo "invalid parameter count"
		usage
		error_exit 1 
	fi
	
	if [ "$1" -eq 1 ]
	then
		BACKUP_FILE_LIST="${CONFIG_FILES_COMMON} ${CONFIG_FILES_NETWORKSAS} ${product_version_file} ${db_data_sql_file} ${db_config_sql_file}"

		backup_pkg="sys_backup${CUR_DATETIME}_${server_ip}_networksas.tar.gz"
		clean_files="${BACKUP_PATH}/sys_backup*_${server_ip}_networksas.tar.gz"
		current_file_number=$(ls ${clean_files}|wc -l)
		
		POLICY_TABLES="${POLICY_TABLES_COMMON} ${POLICY_TABLES_NETWORKSAS}"
		SYS_TABLES="${SYS_TABLES_COMMON} ${SYS_TABLES_NETWORKSAS}"
		COMMON_POLICY_TABLE="t_pol_common_policy"
		DB_NAME="polydata"
	elif [ "$1" -eq 2 ]
	then
		BACKUP_FILE_LIST="${CONFIG_FILES_COMMON} ${CONFIG_FILES_SOC} ${product_version_file} ${db_data_sql_file} ${db_config_sql_file}"

		backup_pkg="sys_backup${CUR_DATETIME}_${server_ip}_soc.tar.gz"
		clean_files="${BACKUP_PATH}/sys_backup*_${server_ip}_soc.tar.gz"
		current_file_number=$(ls ${clean_files}|wc -l)
		
		POLICY_TABLES="${POLICY_TABLES_COMMON} ${POLICY_TABLES_SOC}"
		SYS_TABLES="${SYS_TABLES_COMMON} ${SYS_TABLES_SOC}"
		COMMON_POLICY_TABLE="t_pol_common_policy"
		DB_NAME="garuda"
	else
		echo "unsupported product type"
		usage
		error_exit 1 
	fi

	cd "${BACKUP_PATH}"
	
	#export current product version
	#python ${PRODUCT_HAWK_ROOT}/script/upgrade_show_versions.py -t product|awk -F '：|:' '/版本|version/{print $NF}'|sed 's/^[[:space:]]*//' > "${product_version_file}"
	python ${PRODUCT_HAWK_ROOT}/script/upgrade_show_versions.py -t product|tail -n 1 > "${product_version_file}"
	
	#policy data
	#mysqldump -t --replace -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} ${POLICY_TABLES}|sed -r 's/REPLACE INTO (`[^`]+`)/TRUNCATE TABLE \1;\nREPLACE INTO \1/g' > "${db_data_sql_file}"
	mysqldump -t --replace -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} ${POLICY_TABLES} > "${db_data_sql_file}"
	
	if [ x"{COMMON_POLICY_TABLE}" != x ]
	then
		#export custom data from t_pol_common_policy
		#mysqldump -t --replace -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} t_pol_common_policy --where="isSysDefault=0"|sed -r 's/REPLACE INTO (`[^`]+`)/delete from \1 where isSysDefault=0;\nREPLACE INTO \1/g' >> "${db_data_sql_file}"
		mysqldump -t --replace -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} t_pol_common_policy --where="isSysDefault=0" >> "${db_data_sql_file}"
	fi
	
	#sys config data
	#mysqldump -t --replace -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} ${SYS_TABLES}|sed -r 's/REPLACE INTO (`[^`]+`)/TRUNCATE TABLE \1;\nREPLACE INTO \1/g' > "${db_config_sql_file}"
	mysqldump -t --replace -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} ${SYS_TABLES} > "${db_config_sql_file}"
		
	#pack
	tar -zcvf "${BACKUP_PATH}/${backup_pkg}" ${BACKUP_FILE_LIST}
	rm -f ${product_version_file} ${db_data_sql_file} ${db_config_sql_file}
		
	if [ "$2" -eq 2 ]
	then
		if [ -f "$CONGIF_FILE" ]
		then
			dos2unix "${CONGIF_FILE}"
			. "${CONGIF_FILE}"
		else
			echo "$CONGIF_FILE is not existed, exit now!"
			error_exit 1
		fi

        if [ "$transType" -eq 1 ]
    	then
        	expect "$PRODUCT_HAWK_ROOT/script/ssh_exe_cmd.exp" $ipaddress $port $username $password ". /etc/profile && mkdir -p ${path}"
    	fi

		if [ "$backupEnable" -eq 0 ]
		then
			echo "backupEnable is 0, so it doesn't need to backup, exit now!"
			error_exit 1
		fi
		
		#upload sys
		upload_data "${BACKUP_PATH}/${backup_pkg}"
		if [ $? -ne 0 ]
		then
			echo "upload ${BACKUP_PATH}/${backup_pkg} failed"
	
			#no remove backup package, for restoring from local disk
			#rm -f "${BACKUP_PATH}/${backup_pkg}"
			error_exit 1
		#else
		#	#remove backuped package if upload succeeded
		#	rm -f "${BACKUP_PATH}/${backup_pkg}"
		fi
	fi

	#keep last MAX_PRESERVE_FILES packages
	to_delete_file_number=$((${current_file_number} + 1 - ${MAX_PRESERVE_FILES}))
	echo "to_delete_file_number ${to_delete_file_number}"
	
	if [ "${to_delete_file_number}" -gt 0 ]
	then
		ls -rt ${clean_files}|head -n ${to_delete_file_number}|xargs -n1 rm -f
	fi
	
	echo "OK"
	echo "${BACKUP_PATH}/${backup_pkg}"
}

######################################################################
#  main entry                                                        #
######################################################################

echo "all parameters: $@"
main $@
