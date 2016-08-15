#!/usr/bin python
# -*- coding: UTF-8 -*-

import re
import os
import subprocess
from subprocess import Popen,PIPE
path='/root/pythonScript'
totalSize=0

cmd = "du -sh *.py|awk -F' ' '{ print $1 }'"
for line in os.popen(cmd):
    
# stdout11=Popen((cmd),stdout=PIPE).stdout
    sizen=line.strip('K\n')
    totalSize=float(sizen)+totalSize

print "the totalsize is:", totalSize, "k"
    
