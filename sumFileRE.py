#!/usr/bin python
# -*- coding: UTF-8 -*-

import re
import os
import subprocess
from subprocess import Popen,PIPE
path='/root/pythonScript'
totalSize=0
os.chdir(path)

cmd = "ls -al"
pp=re.compile(r'\w+\.log?', re.IGNORECASE)
filelist=[]

for line in os.popen(cmd):
    print line
    if line.startswith('total'):
        continue
    if pp.search(line):
        subfile=pp.search(line).group()
        filelist.append(subfile)
        
    else:
        continue
print filelist
    
for name in filelist:
    for each in os.popen('du -sh {0}'.format(name)):
       ee=re.compile("\d+\.\d+K", re.I)
       sizen=ee.search(each).group().strip('K')
       totalSize=float(sizen)+totalSize

print "the totalsize is:", totalSize, "k"
    
