#!/bin/bash

. /etc/profile

export PATH=/usr/sbin:/usr/bin:/bin:${PATH}
echo "PATH: ${PATH}"

BACKUP_PATH="${PRODUCT_HAWK_DATA}/backup"
EXE_NAME=$0
#CONGIF_FILE="${PRODUCT_HAWK_ROOT}/conf/sys_data_manager.conf"

CUR_DATE=$(date +"%Y-%m-%d %H:%M:%S")
CUR_DAY=$(date +"%Y%m%d")
CUR_DATETIME=$(date +"%Y%m%d%H%M%S")

DB_USER=polydata
DB_PASSWORD=data_poly@\)\!%
#DB_NAME=polydata

PKG_PASSWD=""

CLEAN_DB_SQL_FILE="${BACKUP_PATH}/data_clean_tmp.sql"

SYS_TABLES_COMMON="t_sys_param_init t_sys_usergroup t_sys_role t_sys_role_module t_sys_user"
SYS_TABLES_SOC=""
SYS_TABLES_NETWORKSAS=""


POLICY_TABLES_COMMON="t_obj_instance_group t_obj_instance t_pol_group t_pol_filter t_pol_category \
t_pol_inc_status t_pol_inc_status_filter t_pol_inc_generator t_pol_inc_policy \
t_pol_statistics_rule t_pol_datamining t_cmp_packet_filter t_cmp_packet_saverule"

POLICY_TABLES_SOC=""
POLICY_TABLES_NETWORKSAS=""

#if [ -f "$CONGIF_FILE" ]
#then
#	dos2unix "${CONGIF_FILE}"
#	. "${PRODUCT_HAWK_ROOT}/conf/data_manager.conf"
#else
#	echo "$CONGIF_FILE is not existed, exit now!"
#	error_exit 1
#fi


usage()
{
	echo "Usage: ${EXE_NAME} <product type> <package with full path> <type>"
	echo "parameters specification:"
	echo "product type: 1-networksas; 2-soc"
	echo "package with full path: exported package"
	echo "type: 1-policy 2-config 3-all"
}

error_exit()
{
	echo "FAILED"
	exit $1
}


clear_data_sql_bk()
{
    echo "SET FOREIGN_KEY_CHECKS=0;" > "${CLEAN_DB_SQL_FILE}"
    
	#import data to db
	for item in `ls ${BACKUP_PATH}/db*.sql`
	do
		echo "sql file: $item"
		T_POL_COMMON_POLICY_COUNT=$(grep -i -c "^replace into t_pol_common_policy" $item)
		if [ "${T_POL_COMMON_POLICY_COUNT}" -gt 0 ]
		then
		    echo "delete from t_pol_common_policy where isSysDefault=0;" >> "${CLEAN_DB_SQL_FILE}"
		    
		    TABLE_COUNT=$(grep -i -c "^replace into " $item |grep -i -v "t_pol_common_policy")
    		if [ "${TABLE_COUNT}" -gt 0 ]
    		then
    		    awk '/^REPLACE INTO /{print "truncate table "$3";"}' $item |uniq |grep -i -v t_pol_common_policy >> "${CLEAN_DB_SQL_FILE}"
    		fi
		else
		    TABLE_COUNT=$(grep -i -c "^replace into " $item)
    		if [ "${TABLE_COUNT}" -gt 0 ]
    		then
    		    awk '/^REPLACE INTO /{print "truncate table "$3";"}' $item |uniq >> "${CLEAN_DB_SQL_FILE}"
    		fi
		fi		
	done
	
    echo "commit;" >> "${CLEAN_DB_SQL_FILE}"
    echo "SET FOREIGN_KEY_CHECKS=1;" >> "${CLEAN_DB_SQL_FILE}"
    
	mysql -u${DB_USER} -p${DB_PASSWORD}	-D ${DB_NAME} < "${CLEAN_DB_SQL_FILE}"
	rm -f "${CLEAN_DB_SQL_FILE}"
}

clear_data_sql()
{
    TABLE_LIST="$1"
    echo "SET FOREIGN_KEY_CHECKS=0;" > "${CLEAN_DB_SQL_FILE}"
	
	for i in ${TABLE_LIST}
	do
		echo "$i"
		echo "truncate table $i;" >> "${CLEAN_DB_SQL_FILE}"
	done
    
    echo "delete from t_pol_common_policy where isSysDefault=0;" >> "${CLEAN_DB_SQL_FILE}"
    
    echo "commit;" >> "${CLEAN_DB_SQL_FILE}"
    echo "SET FOREIGN_KEY_CHECKS=1;" >> "${CLEAN_DB_SQL_FILE}"
    
	mysql -u${DB_USER} -p${DB_PASSWORD}	-D ${DB_NAME} < "${CLEAN_DB_SQL_FILE}"
	rm -f "${CLEAN_DB_SQL_FILE}"
}



main()
{
	echo $FUNCNAME $@
	mkdir -p "${BACKUP_PATH}"
	rm -f ${BACKUP_PATH}/my_product_version ${BACKUP_PATH}/db*.sql
				
	if [ $# -ne 3 ]
	then
		usage
		error_exit 1	
	fi
	
	if [ "$1" -eq 1 ]
	then
		DB_NAME="polydata"
		POLICY_TABLES="${POLICY_TABLES_COMMON} ${POLICY_TABLES_NETWORKSAS}"
		SYS_TABLES="${SYS_TABLES_COMMON} ${SYS_TABLES_NETWORKSAS}"
	elif [ "$1" -eq 2 ]
	then
		DB_NAME="garuda"
		POLICY_TABLES="${POLICY_TABLES_COMMON} ${POLICY_TABLES_SOC}"
		SYS_TABLES="${SYS_TABLES_COMMON} ${SYS_TABLES_SOC}"
	else
		echo "unsupported product type"
		usage
		error_exit 1 
	fi
		

	package_to_import="$2"
	if [ ! -f "${package_to_import}" ]
	then
		echo "no ${package_to_import} in disk"
		error_exit 1
	fi
	
	
	if [ "$3" -eq 1 ]
	then
	    CLEAR_TABLES="${POLICY_TABLES}"
		#get specific file path in tar.gz
		target_list="my_product_version db_policy_data.sql"
		for i in ${target_list}
		do
			echo "$i"
			FULL_PATH_FILE_IN_TARGZ=$(tar -tzf "${package_to_import}" |grep $i)
			if [ x"${FULL_PATH_FILE_IN_TARGZ}" != x ]
			then
				tar -zxvf "${package_to_import}" -C / ${FULL_PATH_FILE_IN_TARGZ}
			fi
		done
	elif [ "$3" -eq 2 ]
	then
	    CLEAR_TABLES="${SYS_TABLES}"
		tar -zxvf "${package_to_import}" -C /
		rm -f ${PRODUCT_HAWK_DATA}/backup/db_policy_data.sql
	elif [ "$3" -eq 3 ]
	then
	    CLEAR_TABLES="${POLICY_TABLES} ${SYS_TABLES}"
		tar -zxvf "${package_to_import}" -C /
	else
		usage
		error_exit 1	
	fi
	
	#check version
	cur_version=$(python ${PRODUCT_HAWK_ROOT}/script/upgrade_show_versions.py -t product|tail -n 1)
	if [ x"${cur_version}" = x ]
	then
		echo "can't get current product version, exit now!"
		error_exit 1
	fi
	
	export_version=$(cat "${BACKUP_PATH}/my_product_version")
	if [ x"${export_version}" = x ]
	then
		echo "can't get exported product version, exit now!"
		error_exit 1
	fi

	if [ "${cur_version}" != "${export_version}" ]
	then
		echo "can't import, error: version is not identical, exit now!"
		error_exit 1
	fi
	
	#clear data
	clear_data_sql "${CLEAR_TABLES}"
	
	#import data to db
	for i in `ls ${BACKUP_PATH}/db*.sql`
	do
		echo "sql file: $i"
		mysql -u${DB_USER} -p${DB_PASSWORD}	-D ${DB_NAME} < "$i"
		rm -f "$i"
	done
	
	rm -f "${BACKUP_PATH}/my_product_version"
	echo "OK"
}

######################################################################
#  main entry                                                        #
######################################################################

echo "all parameters: $@"
main $@

