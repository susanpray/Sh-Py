#!/usr/bin/python
import subprocess
import os
import sys


topfile=raw_input("please input the topfile path :")
# try:
#     top=open(topfile,"r")
# except IOError:
#     print "No such file,please check your input"
cpulist=[]
Memorylist=[]
# print "#"*50
# print "1. if you want to get the max cpu and memory,please input toptest.getMaxValue()\n"
# print "2. if you want to get the min cpu and memory,please input toptest.getMinValue()\n"
# print "3. if you want to get the average cpu and memory,please input toptest.getAvgValue()\n"
# print "#"*50

command = "more %s | awk '{print $10,$11}'" % topfile
print command
child = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=open(os.devnull, 'w'))
stdout, _ = child.communicate()

aaa = stdout.strip('\n').split('\n')
for mmm in aaa:
   sss=mmm.split()
   cpulist.append(float(sss[0]))
   Memorylist.append(float(sss[1]))

def getMaxValue():
    print "the max CPU use is :"+ str(max(cpulist))+"%"
    print "the max Memory use is:"+ str(max(Memorylist))+"%"

def getMinValue():
    print "the min CPU use is:"+str(min(cpulist))+"%"
    print "the min Memory use is:"+ str(min(Memorylist))+"%"
def getAvgValue():
    print "the average CPU use is:"+str(float(sum(cpulist))/len(cpulist)) +"%"
    print "the average Memory use is:"+ str(float(sum(Memorylist))/len(Memorylist))+"%"

if __name__ == '__main__':
    if sys.argv[1] == 'max':
        getMaxValue()
    elif sys.argv[1] == 'min':
        getMinValue()
    elif sys.argv[1] == 'avg':
        getAvgValue()
    else:
        print "please enter max , min or avg "

