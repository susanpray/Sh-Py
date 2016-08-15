#!/usr/bin python
# -*- coding: UTF-8 -*-
import sys


import requests
from requests.auth import HTTPBasicAuth


# PORT = '8000'


# def net_connected(ip, port):
#     u"""测试 ip 指定地址 port 端口的连通性"""
#     product_list_uri = "http://" + ip + ":" + port
def net_connected(product_list_uri):
    #print product_list_uri
    response = requests.head(product_list_uri,  auth=('user', 'pass'))
    print requests.head(product_list_uri)
 #   print response
    status_code = response.status_code
  #  print status_code
   # print requests.codes.ok
    return True if status_code == requests.codes.ok else False

if __name__ == '__main__':
    product_list_uri = "https://api.github.com/user"
    if len(sys.argv) == 1:
        #server_ip = sys.argv[1]
        test_result = net_connected(product_list_uri)
        if test_result:
            print '0'
        else:
            print '1'
    else:
        print "Usage: {0} server_ip".format(sys.argv[0])
        print('2')
        sys.exit(2)

                                         
