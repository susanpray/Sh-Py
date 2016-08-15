#!/usr/bin/python
# -*- coding: UTF-8 -*-
##把一个文件里面的英语单词首字母大写
import os
import sys
file = "testdata/22"
newfile = "testdata/newsusan.txt"

def read_file(file,newfile):
    try:
        f_open=open(file,'r+')
    except IOError, e:
        print "No such file"
	sys.exit()
    else:
	print "%s is existed" %(file)
    nf_open=open(newfile,'w')
    lines = f_open.readlines()
    for line in lines:
	ListSub =[]
        linelist = line.split(',')
        memberEnglist = linelist[1].split()
#        print memberEnglist

        for memberEng in memberEnglist:
            l = list(memberEng)
            l[-1] = l[-1].upper()
            memberstr =''.join(l)
#            print memberstr
            ListSub.append(memberstr)

 #       print ListSub
        memberstrall = ' '.join(ListSub)

#        print memberstrall
        linelist[1] = memberstrall
        strlinelist = ','.join(linelist)
        nf_open.write(strlinelist + '\n')
    nf_open.close()
    f_open.close()


read_file(file,newfile)
os.rename(newfile,"testdata/renamefile")

