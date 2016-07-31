#!/bin/bash
. /etc/profile

CONGIF_FILE="${PRODUCT_HAWK_ROOT}/conf/data_manager.conf"

CUR_DATE=$(date +"%Y-%m-%d %H:%M:%S")
CUR_MONTH=$(date +"%Y%m")

DB_IP=127.0.0.1
DB_USER=polydata
DB_PASSWORD=data_poly@\)\!%
DB_NAME=garuda

unalias df 2> /dev/null

if [ -f "$CONGIF_FILE" ]
then
	dos2unix "${CONGIF_FILE}"
	. "${PRODUCT_HAWK_ROOT}/conf/data_manager.conf"
else
	echo "$CONGIF_FILE is not existed, exit now!"
	exit 1
fi

expired_date=$(date -d -${recordHoldThreshold}day +%Y%m%d)
echo "expired_date: ${expired_date}"

clean_db_sql_file="/tmp/clean_db_data.sql"

drop_day_split_table()
{
	grep_exclude_condition="\+|CONCAT"
	
	if [ $# -eq 1 ]
	then
		other_condition=""
	elif [ $# -eq 2 ]
	then 
		other_condition="$2"
	elif [ $# -eq 3 ]
	then 
		other_condition="$2"
		if [ x"$3" != x ]
		then
			grep_exclude_condition="\+|CONCAT|$3"
		fi
	else
		echo "Invalid parameter count!"
		echo "Usage: $0 <table basename>"
		return
	fi

	#table basename
	table_basename="$1"
	sql="select CONCAT('DROP TABLE IF EXISTS ',table_name,';') FROM information_schema.TABLES where table_schema = '${DB_NAME}' and table_name like '${table_basename}%' and table_name not in ('${table_basename}', '${table_basename}_global') ${other_condition};" 
	#echo "${sql}"
	#echo "grep_exclude_condition: ${grep_exclude_condition}"
	
	mysql -u${DB_USER} -p${DB_PASSWORD} -e "${sql}" ${DB_NAME}|grep -v -E "${grep_exclude_condition}"  >> "${clean_db_sql_file}"
}

clean_data()
{
	echo "prepare clean data of deleteThresholdHigh ${deleteThresholdHigh}......"
	
	db_usage=$(python ${PRODUCT_HAWK_ROOT}/script/get_storage_status.py /polydata ${DB_IP} ${DB_USER} ${DB_PASSWORD} ${DB_NAME}|sed -rn "s/^DB_Percent *:(.*)/\1/p"| sed "s/[ %]//g")
	#db_usage=90
	echo "db_usage: ${db_usage}"
	echo "deleteThresholdHigh: ${deleteThresholdHigh}"
		
	if [ "${db_usage}" -lt "${deleteThresholdHigh}" ]
	then
		echo "current database usage rate is less than ${deleteThresholdHigh}, unnecessary to clean up!"
		return
	fi

	#drop_day_split_table "t_evt_event" "and CREATE_TIME < now() order by CREATE_TIME limit 1"
	#drop_day_split_table "t_mis_scanfile" "and CREATE_TIME < now() order by CREATE_TIME limit 1"
	#drop_day_split_table "t_sta_pkt_basicstatistics" "and CREATE_TIME < now() order by CREATE_TIME limit 1"
	#drop_day_split_table "t_sta_ssn_basicstatistics" "and CREATE_TIME < now() order by CREATE_TIME limit 1"

	drop_day_split_table "t_evt_event" "and table_name < 't_evt_event${expired_date}' order by table_name limit 1"
	drop_day_split_table "t_mis_scanfile" "and table_name < 't_mis_scanfile${expired_date}' order by table_name limit 1"
	drop_day_split_table "t_sta_pkt_basicstatistics" "and table_name < 't_sta_pkt_basicstatistics${expired_date}' order by table_name limit 1"
	drop_day_split_table "t_sta_ssn_basicstatistics" "and table_name < 't_sta_ssn_basicstatistics${expired_date}' order by table_name limit 1"

	
	#clean statistics day table data
	sql="select DISTINCT statisticsTable from t_pol_statistics_rule where reserved1='1'"
	record_set=$(mysql -u${DB_USER} -p${DB_PASSWORD} -e "${sql}" ${DB_NAME}|grep -v -E "\+|statisticsTable")
	
	for item in ${record_set}
	do
		#drop_day_split_table "${item}" "and CREATE_TIME < now() order by CREATE_TIME limit 1"
		drop_day_split_table "${item}" "and table_name < '${item}${expired_date}_global' order by table_name limit 1"
	done
	
	#clean statistics month table data
	sql="select DISTINCT statisticsTable from t_pol_statistics_rule where reserved1='2'"
	record_set=$(mysql -u${DB_USER} -p${DB_PASSWORD} -e "${sql}" ${DB_NAME}|grep -v -E "\+|statisticsTable")
	
	for item in ${record_set}
	do
		#drop_day_split_table "${item}" "and CREATE_TIME < now() order by CREATE_TIME limit 1" "${CUR_MONTH}"
		drop_day_split_table "${item}" "and table_name < '${item}${expired_date}_global' order by table_name limit 1" "${CUR_MONTH}"
	done
	
	echo "prepare clean data of deleteThresholdHigh ${deleteThresholdHigh}......[OK]"
}

clean_data_before_days()
{	
	echo "prepare clean data before ${recordHoldThreshold} days......"
	#drop_day_split_table "t_evt_event" "and DATE_FORMAT(CREATE_TIME,'%Y-%m-%d') <= DATE_SUB(CURRENT_DATE(),INTERVAL ${recordHoldThreshold} DAY)"
	#drop_day_split_table "t_mis_scanfile" "and DATE_FORMAT(CREATE_TIME,'%Y-%m-%d') <= DATE_SUB(CURRENT_DATE(),INTERVAL ${recordHoldThreshold} DAY)"
	#drop_day_split_table "t_sta_pkt_basicstatistics" "and DATE_FORMAT(CREATE_TIME,'%Y-%m-%d') <= DATE_SUB(CURRENT_DATE(),INTERVAL ${recordHoldThreshold} DAY)"
	#drop_day_split_table "t_sta_ssn_basicstatistics" "and DATE_FORMAT(CREATE_TIME,'%Y-%m-%d') <= DATE_SUB(CURRENT_DATE(),INTERVAL ${recordHoldThreshold} DAY)"

	drop_day_split_table "t_evt_event" "and table_name <= 't_evt_event${expired_date}'"
	drop_day_split_table "t_mis_scanfile" "and table_name <= 't_mis_scanfile${expired_date}'"
	drop_day_split_table "t_sta_pkt_basicstatistics" "and table_name <= 't_sta_pkt_basicstatistics${expired_date}'"
	drop_day_split_table "t_sta_ssn_basicstatistics" "and table_name <= 't_sta_ssn_basicstatistics${expired_date}'"

	
	#clean statistics day table data
	sql="select DISTINCT statisticsTable from t_pol_statistics_rule where reserved1='1'"
	record_set=$(mysql -u${DB_USER} -p${DB_PASSWORD} -e "${sql}" ${DB_NAME}|grep -v -E "\+|statisticsTable")
	
	for item in ${record_set}
	do
		#drop_day_split_table "${item}" "and DATE_FORMAT(CREATE_TIME,'%Y-%m-%d') <= DATE_SUB(CURRENT_DATE(),INTERVAL ${recordHoldThreshold} DAY)"	
		drop_day_split_table "${item}" "and table_name <= '${item}${expired_date}_global'"	
	done
	
	#clean statistics month table data
	sql="select DISTINCT statisticsTable from t_pol_statistics_rule where reserved1='2'"
	record_set=$(mysql -u${DB_USER} -p${DB_PASSWORD} -e "${sql}" ${DB_NAME}|grep -v -E "\+|statisticsTable")
	
	for item in ${record_set}
	do
		#drop_day_split_table "${item}" "and DATE_FORMAT(CREATE_TIME,'%Y-%m-%d') <= DATE_SUB(CURRENT_DATE(),INTERVAL ${recordHoldThreshold} DAY)" "${CUR_MONTH}"	
		drop_day_split_table "${item}" "and table_name <= '${item}${expired_date}_global'" "${CUR_MONTH}"	
	done
	
	#clean incident data
	sql="delete from t_inc_evt where EXISTS(select 1 from t_inc_incident WHERE incidentID=t_inc_evt.incidentID and DATE_FORMAT(createTime,'%Y-%m-%d') <= DATE_SUB(CURRENT_DATE(),INTERVAL ${recordHoldThreshold} DAY));"
	echo "${sql}"  >> "${clean_db_sql_file}"
	
	sql="delete from t_inc_incident WHERE DATE_FORMAT(createTime,'%Y-%m-%d') <= DATE_SUB(CURRENT_DATE(),INTERVAL ${recordHoldThreshold} DAY);"
	echo "${sql}"  >> "${clean_db_sql_file}"
	
	#clean sys log
	#sql="delete from t_sys_log WHERE DATE_FORMAT(createTime,'%Y-%m-%d') <= DATE_SUB(CURRENT_DATE(),INTERVAL ${recordHoldThreshold} DAY);"
	#echo "${sql}"  >> "${clean_db_sql_file}"
	
	echo "prepare clean data before ${recordHoldThreshold} days......[OK]"
} 


### main entry ###
echo "${CUR_DATE} cleanup data......"

echo "clean sys log before days......"
bash "${PRODUCT_HAWK_ROOT}/script/cleanup_table_data_t_sys_log.sh" "${DB_NAME}"
echo "clean sys log before days......[OK]"

echo "SET FOREIGN_KEY_CHECKS=0;" > "${clean_db_sql_file}"
sql="delete from t_cmp_serverstatus where createTime < CURRENT_DATE();"
echo "${sql}"  >> "${clean_db_sql_file}"

if [ "$recordHoldThreshold" -gt 0 ]
then
	clean_data_before_days
else
	echo "invalid value of recordHoldThreshold: $recordHoldThreshold"
fi

if [ "$deleteThresholdHigh" -gt 0 ]
then
	clean_data
else
	echo "invalid value of deleteThresholdHigh: $deleteThresholdHigh"
	echo "${CUR_DATE} cleanup data......[FAILED]"
fi

echo "commit;" >> "${clean_db_sql_file}"
echo "SET FOREIGN_KEY_CHECKS=1;" >> "${clean_db_sql_file}"

#finally, excute the generated sql file
mysql -f -u${DB_USER} -p${DB_PASSWORD} -D ${DB_NAME} < "${clean_db_sql_file}"
rm -f "${clean_db_sql_file}"

echo "${CUR_DATE} cleanup data......[OK]"
echo







