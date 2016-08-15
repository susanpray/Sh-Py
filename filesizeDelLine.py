
#!/usr/bin/python
# -*- coding: UTF-8 -*-
import commands
import os
file = '/susan/text'
status,output = commands.getstatusoutput ('du -sh %s' % file)
print output
def deletelines(keep):
    fin=open(file)
    a=fin.readlines()
    fout=open(file,'w')
    b=''.join(a[len(a)-keep:])
    fout.write(b)
    fin.close()
    fout.close()
def filelen():
    chfile=open(file,"r")
    print len(chfile.readlines())

    #fileleft = commands.getoutput ('cat /susan/text1') 
    #print fileleft

if output > '2M':
        filelen()
	deletelines(1000)
	filelen()
else:
	print " this file if not big than 2M"
