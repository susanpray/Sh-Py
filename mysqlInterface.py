#!/use/bin/env python
# -*- coding: UTF-8 -*-
import os
from random import randrange as rrange
from _bsddb import DB_EXCL
host = "192.168.11.144"
CoLSIZ=10
RDBMSs={'s':'sqlite','m':'mysql','g':'gadfly'}
DB_EXC=None

def setup():
    return RDBMSs[raw_input('''
    Choose a database system:
    (M)ySql
    (G)adfly
    (S)QLite
    enter choise:''').strip().lower()[0]]
def connect(db,dbname):
    global DB_EXC
    dbDir = '%s_%s' % (db,dbname)
    if db == 'sqlite':
        try:
            import sqlite3
        except ImportError,e:
            try:
                from pysqlite2 import dbapi2 as sqlite3
            except ImportError,e:
                return None
            DB_EXC=sqlite3
            if not os.path.isdir(dbDir):
                os.mkdir(dbDir)
            cxn = sqlite3.connect(os.path.join(dbDir,dbname))
    elif db == 'mysql':
        try:
            import MySqldb
            import _mysql_exceptions as DB_EXC
        except ImportError,e:
            return None
        
        try:
            cxn = MySqldb.connect(db=dbname)
              
        except DB_EXC.OperationalError,e:
            cxn = MySqldb.connect(user='root')
            
        try:
            cxn.query('DROP DATABASE %s' % dbname)
        except DB_EXC.OperationalError,e:
            pass
        
        cxn.query('CREATE DATABASE %s' % dbname)
        cxn.query("GRANT ALL ON %s.* to ''@'localhost'" % dbname)
        cxn.commit()
        cxn.close()
        cxn = MySqldb.connect(db=dbname)
        
    elif db == 'gadfly':
        try:
            from gadfly import gadfly
            DB_EXC = gadfly
        except ImportError,e:
            return None
        try:
            cxn=gadfly(dbname,dbDir)
        except IOError,e:
            cxn=gadfly()
            if not os.path.isdir(dbDir):
                os.mkdir(dbDir)
            cxn.startup(dbname,dbDir)
        else:
            return None
        return cxn
def create(cur):
    try:
        cur.execute('''
        CREATE TABLE users(
        login VARCHAR(8),
        uid INTEGER,
        prid INTEGER)
        ''')
    except DB_EXC.OperationError,e:
        drop(cur)
        create(cur)
drop = lambda cur:cur.execute('DROP TABLE users')
# NAMES = (
#          ('susan',83121),('susan11',83133),('susan22',83144),
#          ('susan33',83166),('susan44',831773),('susan55',83199),
#          )    
# def randname():
#     pick = list(NAMES)
#     while len(pick) > 0:
#         yield pick.po(rrange(len(pick)))
        
def main():
    db =setup()
    print '*** connecting to %r databases'% db
    cxn=connect(db,'mysql')
    
    if not cxn:
        print 'error:%r not supported,exiting'% db
        return
    cur=cxn.cursor()
    print '\n*** creating users table'
    create(cur)
    cxn.commit()
    cxn.close()
if __name__=='__main__':
    main()