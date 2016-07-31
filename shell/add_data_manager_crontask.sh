#!/bin/bash

. /etc/profile

export PATH=/usr/sbin:/usr/bin:/bin:${PATH}
echo "PATH: ${PATH}"

TMP_PATH="${PRODUCT_HAWK_DATA}/tmp"
EXE_NAME=$0

error_exit()
{
	echo "FAILED"
	exit $1
}

usage()
{
	echo "Usage of adding cron task  : ${EXE_NAME} <product type> <cron task type> <backup interval type> <backup interval> <backup time>"
	echo "Usage of deleting cron task: ${EXE_NAME} <product type> <cron task type>"	
	echo "parameters specification:"
	echo "product type: 1-networksas; 2-soc"
	echo "cron task type: 1-ES data backup task; 2-database cold backup task; 3-system config rule task"
	echo "backup interval type: 0:hourly 1:daily 2:weekly"
	echo "backup interval: "
	echo "backup time: HH:MM"
}

add_crontask()
{
	#echo $FUNCNAME $@
	CRONTASK_FILE="${TMP_PATH}/crontask.$$"
	echo "param1: $1"
	echo "param2: $2"
	script_key="$2"
	script_content="$1"
	
	echo "${CRONTASK_FILE}"
	crontab -l > "${CRONTASK_FILE}"
	#first, delete the existed crontask
	sed -i "/${script_key}/d" "${CRONTASK_FILE}"
	
	#then, add new one
	echo "${script_content}" >> "${CRONTASK_FILE}"
	
	#echo "$$1 $1"
	#cat "${CRONTASK_FILE}"
	
	crontab -r
	crontab "${CRONTASK_FILE}"
	
	rm -f "${CRONTASK_FILE}"
}

delete_crontask()
{
	#echo $FUNCNAME $@
	CRONTASK_FILE="${TMP_PATH}/crontask.$$"
	echo "param1: $1"
	
	if [ $# -ne 2 ]
	then
		echo "Invalid parameter count"
		usage
		error_exit 1
	fi
	
	CRONTASK_TYPE="$2"
	if [ "${CRONTASK_TYPE}" -eq 1 ]
	then
		SCRIPT_NAME="apt_data_manager_service.sh"
	elif [ "${CRONTASK_TYPE}" -eq 2 ]
	then
		SCRIPT_NAME="sys_data_backup.sh"
	elif [ "${CRONTASK_TYPE}" -eq 3 ]
	then
		SCRIPT_NAME="sys_data_config_export"
	else
		echo "Invalid cron task type, please have a check"
		usage
		error_exit 1
	fi
	
	echo "${CRONTASK_FILE}"
	crontab -l > "${CRONTASK_FILE}"
	#first, delete the existed crontask
	sed -i "/${SCRIPT_NAME}/d" "${CRONTASK_FILE}"
	
	crontab -r
	crontab "${CRONTASK_FILE}"
	
	rm -f "${CRONTASK_FILE}"
}


main()
{
	echo $FUNCNAME $@
	
	if [ $# -eq 2 ]
	then
		# for delete cron task
		delete_crontask $@
		echo "OK"
		exit 0
	elif [ $# -ne 5 ]
	then
		echo "Invalid parameter count"
		usage
		error_exit 1
	fi
	
	mkdir -p "${TMP_PATH}"
		
	PRODUCT_TYPE="$1"
	CRONTASK_TYPE="$2"
	INTERVAL_TYPE="$3"
	INTERVAL="$4"
	BACKUP_TIME="$5"

	if [ "${PRODUCT_TYPE}" -eq 1 ]
	then
		DB_NAME=polydata
	elif [ "${PRODUCT_TYPE}" -eq 2 ]
	then
		DB_NAME=garuda
	else
		echo "can't get minute from backup time"
		usage
		error_exit 1
	fi


	#START_HOUR=$(echo "${BACKUP_TIME}" |cut -d ':' -f1|sed -e "s/^0\{1,\}//g" )
	START_HOUR=$(echo "${BACKUP_TIME}" |cut -d ':' -f1|sed -e "s/^0//g" )
	if [ x"${START_HOUR}" = x ]
	then
		echo "can't get hour from backup time"
		usage
		error_exit 1
	fi
	
	START_MINUTE=$(echo "${BACKUP_TIME}" |cut -d ':' -f2|sed -e "s/^0//g")
	if [ x"${START_MINUTE}" = x ]
	then
		echo "can't get minute from backup time"
		usage
		error_exit 1
	fi
	
	if [ "${CRONTASK_TYPE}" -eq 1 ]
	then
		SCRIPT_NAME="apt_data_manager_service.sh"
		CMD="${PRODUCT_HAWK_ROOT}/script/apt_data_manager_service.sh >/dev/null 2>&1"
	elif [ "${CRONTASK_TYPE}" -eq 2 ]
	then
		SCRIPT_NAME="sys_data_backup.sh"
				
		CMD="${PRODUCT_HAWK_ROOT}/script/sys_data_backup.sh ${DB_NAME} > ${PRODUCT_HAWK_DATA}/log/sys_data_backup.log 2>&1"		
	elif [ "${CRONTASK_TYPE}" -eq 3 ]
	then
		SCRIPT_NAME="sys_data_config_export"
		
		CMD="${PRODUCT_HAWK_ROOT}/script/sys_data_config_export.sh ${PRODUCT_TYPE} 2 > ${PRODUCT_HAWK_DATA}/log/sys_config_export.log 2>&1"
	else
		echo "Invalid cron task type, please have a check"
		usage
		error_exit 1
	fi
	
	if [ "${INTERVAL_TYPE}" -eq 0 ]
	then
		CRON_TASK_TIME="${START_MINUTE} ${START_HOUR}-23/${INTERVAL} * * * ${CMD}"
	elif [ "${INTERVAL_TYPE}" -eq 1 ]
	then
		CRON_TASK_TIME="${START_MINUTE} ${START_HOUR} */${INTERVAL} * * ${CMD}"
	elif [ "${INTERVAL_TYPE}" -eq 2 ]
	then
		WEEK_DAY=$(expr ${INTERVAL} % 7)
		CRON_TASK_TIME="${START_MINUTE} ${START_HOUR} * * ${WEEK_DAY} ${CMD}"
	else
		echo "Invalid backup interval type, please have a check"
		usage
		error_exit 1
	fi
	
	#add cron task
	add_crontask "${CRON_TASK_TIME}" "${SCRIPT_NAME}"
	
	echo "OK"
}

######################################################################
#  main entry                                                        #
######################################################################
echo "all parameters: $@"
main $@