#!/usr/bin/python
# -*- coding: UTF-8 -*-

import MySQLdb
import os
import sys


# 打开数据库连接
db2 = MySQLdb.connect("192.168.24.101","root","polydata","garuda" )
db1 = MySQLdb.connect("192.168.25.57","root","polydata","polydata" )
#print db1
#print db2

# 使用cursor()方法获取操作游标
cursor1 = db1.cursor()
cursor2 = db2.cursor()

datehour = "2016-04-28 14:59:59"
dateday = "2016-04-28 23:59:59"
code57 = 'b2282b15301dc9cff4b12dbe26d4dc35'
code80 = '249aeb9c333754186ff556a5581555d5'
soc_sys = "soc system"
#table = 't_sta_evt_basic20160401'
tablelist1 = ['t_sta_evt_basic20160401','t_sta_ssn_trend','t_sta_ssn_pkg','t_sta_ssn_oct','t_sta_ssn_domain']
tablelist2 = ['t_sta_evt_trend','t_sta_ssn_day_trend','t_sta_ssn_flow_basic','t_sta_ssn_domain','t_sta_ssn_alproto']

if not sys.argv[1]:
    print"please take 1 argument to execute"
else:
    pass

def SelectMysql(table,code,date):
    sql1 = "select calcTime,count(calcTime) as VALUE from %s where calcTime ='%s'" % (table,date)
    sql_soc1 = "select calcTime,count(calcTime) as VALUE from %s_global where regcode= '%s' and calcTime ='%s'" % (table,code,date)
    #print sql1
    #print sql_soc1
    # f1 = open("sql1.log",'w')
    # f2 = open("sql_soc1.log",'w')

    try:
        cursor1.execute(sql1)
        rows1 = cursor1.fetchone()
        cursor2.execute(sql_soc1)
        rows2 = cursor2.fetchone()

        if rows1[1] == rows2[1]:
	    print "\n\n\n"
            print "%s in soc and subsystem %s at %s is identical (pass)\n" %(table,code,date)
        else:
	    print "\n\n\n"
            print "%s in soc and subsystem %s at %s is not identical (failed)\n" %(table,code,date)

        print "%s is %s" %(code,rows1)
	print "%s is %s" %(soc_sys,rows2)

        db1.commit()
        db2.commit()

    except:
        db1.rollback()
        db2.rollback()
    # finally:
    #     f1.close()
    #     f2.close()

def SelectMysqlHour():
    for table in tablelist1:
        SelectMysql(table,code57,datehour)

def SelectMysqlday():
    for table in tablelist2:
        SelectMysql(table,code57,dateday)


if __name__ == '__main__':
    if sys.argv[1] == 'hour':
        SelectMysqlHour()
    elif sys.argv[1] == 'day':
        SelectMysqlday()
    else:
        print "please enter hour or day "
    db1.close()
    db2.close()

