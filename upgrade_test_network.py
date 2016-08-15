#!/usr/bin python
# -*- coding: UTF-8 -*-

import sys
import socket


PORT = 443


def net_connected(ip, port):
    """测试 ip 指定地址 port 端口的连通性
    """
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(1)
    address = (str(ip), int(port))
    net_status = sock.connect_ex(address)

    if net_status == 0:
        print 'Connection to server({0}:{1}) by TCP is OK.'.format(ip, port)
        return True
    else:
        print 'Connection to server({0}:{1}) by TCP is DOWN.'.format(ip, port)
        return False


if __name__ == '__main__':

    if len(sys.argv) == 2:
        server_ip = sys.argv[1]
        test_result = net_connected(server_ip, PORT)
        if test_result:
            print '0'
        else:
            print '1'
    else:
        print "Usage: {0} server_ip".format(sys.argv[0])
        print('2')
        sys.exit(2)
