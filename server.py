#!/usr/bin/python
# -*- coding: UTF-8 -*-
if __name__ == '__main__':
	import socket
	sock = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
	sock.bind(('192.168.24.106',55001))
	sock.listen(5)
	while True:
		connection,address = sock.accept()
                print 'got connected from', address
#                connection.send('hello,enter something')
		try:
			connection.settimeout(5)
			buf = connection.recv(1024)
			if buf == '1':
				connection.send('welcome to server!')
			else:
				connection.send('please go out')
		except socket.timeout:
			print 'timeout'
		connection.close
