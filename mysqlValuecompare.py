#!/usr/bin/python
# -*- coding: UTF-8 -*-

import MySQLdb
import os


# 打开数据库连接
db2 = MySQLdb.connect("192.168.24.101","root","polydata","garuda" )
db1 = MySQLdb.connect("192.168.25.57","root","polydata","polydata" )
#print db1
#print db2

# 使用cursor()方法获取操作游标
cursor1 = db1.cursor()
cursor2 = db2.cursor()

date = "2016-04-20 13:59:59"
code57 = '0c470f3e8830353ba15364960a9fce7e'
code80 = '2d161c662cc0f0f2b3f642704d1b20ed'
#table = 't_sta_evt_basic20160401'
tablelist1 = ['t_sta_evt_basic20160401','t_sta_ssn_trend','t_sta_ssn_pkg','t_sta_ssn_oct','t_sta_ssn_domain']
tablelist2 = ['t_sta_evt_trend','t_sta_ssn_day_trend','t_sta_ssn_flow_basic','t_sta_ssn_domain','t_sta_ssn_alproto']

def SelectMysql():
    for table in tablelist1:
        sql1 = "select calcTime,count(calcTime) as VALUE from %s where calcTime ='%s'" % (table,date)
        sql_soc1 = "select calcTime,count(calcTime) as VALUE from %s_global where regcode= '%s' and calcTime ='%s'" % (table,code57,date)
        #print sql1
        #print sql_soc1
        f1 = open("sql1.log",'w')
        f2 = open("sql_soc1.log",'w')

        try:
            cursor1.execute(sql1)
            rows1 = cursor1.fetchone()
            cursor2.execute(sql_soc1)
            rows2 = cursor2.fetchone()

            if rows1[1] == rows2[1]:
                print "%s in soc and subsystem %s at %s is identical (pass)\n" %(table,code57,date)
            else:
                print "%s in soc and subsystem %s at %s is not identical (failed)\n" %(table,code57,date)

            print rows1
            print rows2

            db1.commit()
            db2.commit()

        except:
            db1.rollback()
            db2.rollback()
        finally:
            f1.close()
            f2.close()





if __name__ == '__main__':
        SelectMysql()
        db1.close()
        db2.close()

