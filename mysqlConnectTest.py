#!/usr/bin python
# -*- coding: UTF-8 -*-
import os
import sys
import logging
import sys,os,subprocess,commands
from subprocess import Popen,PIPE

import pymysql
host = '192.168.11.144' 
#host = '127.0.0.1'
#host = 'localhost'
cmd='mysqladmin -u root -proot create db'
try:
    conn = pymysql.connect(host,'root','root','db')
    cursor = conn.cursor()
except Exception, e:
    print "expection:",e
