#!/usr/bin/python
# -*- coding: UTF-8 -*-

import MySQLdb

# 打开数据库连接
db = MySQLdb.connect("localhost","root","root","susan" )

# 使用cursor()方法获取操作游标 
cursor = db.cursor()


sql = "Select * from EMPLOYEE where income > %d;" % (2066)

cursor.execute(sql)
fb = cursor.fetchall()

for row in fb:
	name = row[0]
	l_name = row[1]
	age = row[2]
	sex = row[3]
	income = row[4]

	print "name = %s, l_name = %s, age = %s, sex = %s, income = %s" \
	% (name, l_name , age , sex , income)

db.close()
