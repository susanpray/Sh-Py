#!/usr/bin/python
# -*- coding: UTF-8 -*-

import MySQLdb
import os

# 打开数据库连接
db1 = MySQLdb.connect("192.168.24.101","root","polydata","garuda" )
db2 = MySQLdb.connect("192.168.25.57","root","polydata","polydata" )
#print db

# 使用cursor()方法获取操作游标 
cursor1 = db1.cursor()
cursor2 = db2.cursor()

ip1 = "192.168.24.188"

def insertMysql():
        for i in range(2,3):
                for j in range(2,29):
                        date = ("2016-" + "%d" + "-" "%d" + " 14:18:29") % (i,j)
                        print date
                        sql1 = "INSERT INTO `t_sys_log` ( `componentName`, `ipAddress`, `logLevel`, `logContent`, `createTime`, `operatorUser`, `logType`, `regCode`)  \
VALUES ( 'web', '%s', '1', '显示查询条件列表成功', '%s', 'sysadmin', '2', NULL);" % (ip1, date)
			sql2 = "INSERT INTO `polydata`.`t_sys_log` (`componentName`, `ipAddress`, `logLevel`, `logContent`, `createTime`, `operatorUser`, `logType`) VALUES ('web', '%s', '1', '显示用户列表成功', '%s', 'sysadmin', '2');" % (ip1, date)
                        print sql1
			print sql2
                        try:
                                cursor1.execute(sql1)
				cursor2.execute(sql2)
                                db1.commit()
				db2.commit()
                        except:

                                db1.rollback()
				db2.rollback()
def SelectMysql():
        sql = "select * from t_sys_log where ipAddress='%s'" % (ip1)
        print sql
        f1 = open("mysql1.log",'w')
	f2 = open("mysql2.log",'w')
        try:
            cursor1.execute(sql)
            cursor2.execute(sql)
            rows1 = cursor1.fetchall()
            rows2 = cursor2.fetchall()
            for row1 in rows1:
            	f1.write((', '.join([str(i) for i in row1]))+ '\n')
            for row2 in rows2:
                f2.write((', '.join([str(i) for i in row2]))+ '\n')
          
            db1.commit()
            db2.commit()

        except:
            db1.rollback()
            db2.rollback()

        finally:
            f1.close()
            f2.close()


if __name__ == '__main__':
        insertMysql()
        SelectMysql()
        db1.close()
        db2.close()

