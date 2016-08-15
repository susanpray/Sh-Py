
#!/usr/bin/python
# -*- coding: UTF-8 -*-
import commands
import os
def filesize(file):
#file = '/susan/textbig'
    status,output = commands.getstatusoutput ('du -sh %s' % file)
    print output
def filelen(file):
    chfile=open(file,"r")
    return len(chfile.readlines())
#filesize('/susan/textbig')
#filelen('/susan/textbig')
