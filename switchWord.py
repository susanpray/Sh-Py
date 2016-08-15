#!/usr/bin/python
# -*- coding: UTF-8 -*-
#把一个文件里面的英语单词首字母大写
import os

file = "testdata/2"
newfile = "testdata/newsusan.txt"


def read_file(file,newfile):
    f_open=open(file,'r+')
    nf_open=open(newfile,'w')
    lines = f_open.readlines()
    for line in lines:
	ListSub =[]
        linelist = line.split(',')
        memberEnglist = linelist[1].split()
        print memberEnglist

        for memberEng in memberEnglist:
            l = list(memberEng)
            l[0] = l[0].lower()
            memberstr =''.join(l)
            print memberstr
            ListSub.append(memberstr)

        print ListSub
        memberstrall = ' '.join(ListSub)

        print memberstrall
        linelist[1] = memberstrall
        strlinelist = ','.join(linelist)
        nf_open.write(strlinelist + '\n')
    nf_open.close()
    f_open.close()


read_file(file,newfile)
