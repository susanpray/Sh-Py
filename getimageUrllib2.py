#!/usr/bin/python
# -*- coding: UTF-8 -*-

import urllib2
import re
response = urllib2.urlopen("http://www.imooc.com/course/list?c=python")
html = response.read()
urllist = re.findall(r"http.+\.jpg", html)
print urllist
i = 0
for url in urllist:
	f = open(str(i) + '.jpg', 'w')
	urlopen = urllib2.urlopen(url)
	buf = urlopen.read()
	f.write(buf)
	i += 1
        f.close()
