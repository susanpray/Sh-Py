#!/usr/bin/python
# -*- coding: UTF-8 -*-
import sys 
reload(sys)
sys.setdefaultencoding('utf-8')


import MySQLdb

# 打开数据库连接
db = MySQLdb.connect("192.168.24.101","root","polydata","garuda",charset='utf8')
print db

# 使用cursor()方法获取操作游标 
cursor = db.cursor()

ip1 = "192.168.24.153"

def insertMysql():
	for i in range(2,3):
		for j in range(2,10):
	        	date = ("2016-" + "%d" + "-" "%d" + " 14:18:29") % (i,j)
	        	print date
	        	sql = "INSERT INTO `garuda`.`t_sys_log` ( `componentName`, `ipAddress`, `logLevel`, `logContent`, `createTime`, `operatorUser`, `logType`, `regCode`)  \
VALUES ( 'web', '%s', '1', '显示查询条件列表成功', '%s', 'sysadmin', '2', NULL);" % (ip1, date)
	        	print sql
	        	try:
	                	cursor.execute(sql)
	                	db.commit()
			except:

	                	db.rollback()
def SelectMysql():
	sql = "select * from t_sys_log where ipAddress='%s';" % (ip1)
	print sql
	try:
            cursor.execute(sql)
            s = cursor.fetchall()
            for row in s:
                print ', '.join([str(i) for i in row])
            db.commit()
	except:

            db.rollback()

if __name__ == '__main__':
#	insertMysql()
	SelectMysql()
	db.close()

