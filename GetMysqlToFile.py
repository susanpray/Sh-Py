#!/usr/bin python
# -*- coding: UTF-8 -*-
import os
import sys
import logging
import sys,os,subprocess,commands
from subprocess import Popen,PIPE

import pymysql
import MySQLdb
import datetime
starttime = datetime.datetime.now()
print starttime
date = "2016-04-20 13:59:59"



host = "192.168.11.144"
cmd='mysqladmin -u root -proot create db'


logging.basicConfig(filename='mylog.log', level=logging.DEBUG,
        format='%(asctime)s - %(levelname)s - %(name)s - %(funcName)s - %(lineno)d : %(message)s')


logger = logging.getLogger(__name__)

class DatabaseError(Exception):
    def __init__(self,value,msg,length):
        self.value=value
        self.msg=msg
        self.length=length
    def __str__(self):
        return repr(self.value,self.msg,self.length)

def create_db():
    try:
        fd=Popen(cmd,stderr=subprocess.PIPE,shell=True)
        output=fd.stderr.read()
        ss=output.split(':')[1].split(';')[1].lstrip()
        if ss=='error':
            print "the db is existed"
            raise DatabaseError(2*2,'go to bedroom',28)
          
    except DatabaseError as e:
        print 'My exception occurred, value:', e.value,e.msg,e.length
    finally:
        pass


def createTable():
    sql= "CREATE TABLE susan33(runoob_id INT NOT NULL AUTO_INCREMENT,\
    runoob_title VARCHAR(100) NOT NULL,\
    runoob_author VARCHAR(40) NOT NULL,\
    submission_date DATETIME,\
    PRIMARY KEY (runoob_id));"
    insertsqp="INSERT INTO susan33(runoob_id,runoob_title,runoob_author,submission_date) VALUES (55,'testTitle','susanwang','%s');" % starttime
    selectsql="SELECT * FROM susan33"
    
    try:
        try:
            ff=open("mysqllog.log","w+")
            conn = MySQLdb.connect(host,'root','root','db')
            dbc = conn.cursor()
#             dbc.execute(sql)
#             conn.commit()
#             
#             dbc.execute(insertsqp)
#             conn.commit()
            dbc.execute(selectsql)
            row1=dbc.fetchone()
            print row1
         
            ff.write((','.join([str(i) for i in row1]))+ '\n')
            conn.commit()
        except:
            conn.rollback()

    except Exception, e:
        print "expection:",e
#         logger.error('DatabaseError: Connect to database failed: {0}'.format(str(e)))
#         raise DatabaseError('Connect to database failed: {0}'.format(str(e)))
    finally:
        dbc.close()
        ff.close()
    
    

    
if __name__ =="__main__":
        create_db()
        #createTable()

