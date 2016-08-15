#!/usr/bin/python
# -*- coding: UTF-8 -*-

import MySQLdb

# 打开数据库连接
db = MySQLdb.connect("localhost","root","root","susan" )

# 使用cursor()方法获取操作游标 
cursor = db.cursor()


for i in range(100):
	name="susan" + str(i)
	l_name="wang" + str(i)
	age= int(20+i)
	sex="F"
	income=int(2000+i)
	sql = "INSERT INTO EMPLOYEE(FIRST_NAME, \
	   LAST_NAME, AGE, SEX, INCOME) \
	   VALUES ('%s', '%s', '%d', '%c', '%d' )" % \
	   (name, l_name, age, sex, income)
	try:
		cursor.execute(sql)
		db.commit()
	except:
   
   		db.rollback()

db.close()
