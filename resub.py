#!/usr/bin/python
import re

phone = "2004-	959-559 # This is Phone Number"

# Delete Python-style comments
num = re.sub(r'\t', "", phone)
print "Phone Num : ", num

# Remove anything other than digits
num = re.sub(r'\D', "", phone)    
print "Phone Num : ", num
