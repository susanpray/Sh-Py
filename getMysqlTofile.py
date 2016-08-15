#!/usr/bin python
# -*- coding: UTF-8 -*-
import os
import sys
import logging
import sys,os,subprocess,commands
from subprocess import Popen,PIPE

import pymysql
host = "192.168.11.144"
cmd='mysqladmin -u root -proot create db'


logging.basicConfig(filename='mylog.log', level=logging.DEBUG,
        format='%(asctime)s - %(levelname)s - %(name)s - %(funcName)s - %(lineno)d : %(message)s')


logger = logging.getLogger(__name__)

class DatabaseError(Exception):
    def __init__(self,value):
        self.value=value
    def __str__(self, *args, **kwargs):
        return Exception.__str__(self, *args, **kwargs)
    
def create_db():
    try:
        fd=Popen(cmd,stderr=subprocess.PIPE,shell=True)
        output=fd.stderr.read()
        ss=output.split(':')[1].split(';')[1].lstrip()
        if ss=='error':
            print "the db is existed"
    except Exception as e:
        print "Exception:", e
    finally:
        pass    

            
def update_server_addr():

    try:
        conn = pymysql.connect(host,'root','root','db')
        cursor = conn.cursor()
    except Exception, e:
	print "expection:",e
        logger.error('DatabaseError: Connect to database failed: {0}'.format(str(e)))
        raise DatabaseError('Connect to database failed: {0}'.format(str(e)))
    finally:
        print " connect to mysql successfully"

if __name__ =="__main__":

        create_db()
        update_server_addr()

