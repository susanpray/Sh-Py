#!/usr/bin/python
# -*- coding: UTF-8 -*-

import MySQLdb
import os

# 打开数据库连接
db1 = MySQLdb.connect("192.168.24.101","root","polydata","garuda" )
print db1

# 使用cursor()方法获取操作游标 
cursor1 = db1.cursor()

ip1 = "11.11.11.11"
ip2 = "22.22.22.22"

def insertMysql():
        for i in range(3,4):
                for j in range(2,29):
                        date = ("2016-" + "%d" + "-" "%d" + " 14:18:29") % (i,j)
                        print date
                        sql1 = "INSERT INTO `t_sys_log` ( `componentName`, `ipAddress`, `logLevel`, `logContent`, `createTime`, `operatorUser`, `logType`, `regCode`)  \
VALUES ( 'web', '%s', '1', '显示查询条件列表成功', '%s', 'sysadmin', '2', NULL);" % (ip1, date)
                        sql2 = "INSERT INTO `t_sys_log` ( `componentName`, `ipAddress`, `logLevel`, `logContent`, `createTime`, `operatorUser`, `logType`, `regCode`)  \
VALUES ( 'web', '%s', '1', '显示查询条件列表成功', '%s', 'sysadmin', '2', '82b47d933d752aa552a770a907f7c720');" % (ip2, date)
                        print sql1
                        print sql2
                        try:
                                cursor1.execute(sql1)
                                cursor1.execute(sql2)
                                db1.commit()
                                
                        except:

                                db1.rollback()
                                
def SelectMysql():
        sql1 = "select * from t_sys_log where ipAddress='%s'" % (ip1)
        sql2 = "select * from t_sys_log where ipAddress='%s'" % (ip2)
        f1 = open("mysql1.log",'w')
        f2 = open("mysql2.log",'w')
        try:
            cursor1.execute(sql1)
            rows1 = cursor1.fetchall()
            cursor1.execute(sql2)
            rows2 = cursor1.fetchall()
           
            for row1 in rows1:
                f1.write((', '.join([str(i) for i in row1]))+ '\n')
            for row2 in rows2:
                f2.write((', '.join([str(i) for i in row2]))+ '\n')

            db1.commit()
           
        except:
            db1.rollback()
            

        finally:
            f1.close()
            f2.close()


if __name__ == '__main__':
        insertMysql()
        SelectMysql()
        db1.close()
     
