try:
     open("E:\python script\da1a.txt", "r")
except IOError:
     pass
else:
    print "open it"

try:
    print aa
except NameError,msg:
    print msg

