#!/usr/bin/python
# -*- coding: UTF-8 -*-

import MySQLdb

# 打开数据库连接
db = MySQLdb.connect("localhost","root","root","susan" )

# 使用cursor()方法获取操作游标 
cursor = db.cursor()

name="susan11"
l_name="wang11"

# SQL 插入语句
sql = "INSERT INTO EMPLOYEE(FIRST_NAME, \
       LAST_NAME, AGE, SEX, INCOME) \
       VALUES ('%s', '%s', '%d', '%c', '%d' )" % \
       (name, l_name, 20, 'M', 2000)

#sql = """INSERT INTO EMPLOYEE(FIRST_NAME,
 #        LAST_NAME, AGE, SEX, INCOME)
  #       VALUES ("%s", "%s", 20, 'M', 2000)""" % (name,l_name)
try:
   # 执行sql语句
   cursor.execute(sql)
   # 提交到数据库执行
   db.commit()
except:
   # Rollback in case there is any error
   db.rollback()

# 关闭数据库连接
db.close()
