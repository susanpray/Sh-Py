#!/bin/bash

. /etc/profile

if [ $# -ne 1 ]
then
	echo "Invalid parameter count!"
	echo "Usage: $0 <db name>!"
	exit 1
fi

DB_USER=polydata
DB_PASSWORD=data_poly@\)\!%
DB_NAME="$1"

echo "DB_NAME: ${DB_NAME}"

#test_sql="set @value := (select paramValue from t_sys_param_init t where t.paramName='paramLogConservation');select @value;select * from t_sys_log where DATE_FORMAT(createTime,'%Y-%m-%d') <= DATE_SUB(CURRENT_DATE(),INTERVAL @value DAY) limit 10;"
#echo "test_sql: ${test_sql}"
#mysql -u${DB_USER} -p${DB_PASSWORD} -e "${sql}" ${DB_NAME}

sql="set @value := (select paramValue from t_sys_param_init t where t.paramName='paramLogConservation');delete from t_sys_log where DATE_FORMAT(createTime,'%Y-%m-%d') <= DATE_SUB(CURRENT_DATE(),INTERVAL @value DAY);commit;"
echo "sql: ${sql}"

mysql -u${DB_USER} -p${DB_PASSWORD} -e "${sql}" "${DB_NAME}"










