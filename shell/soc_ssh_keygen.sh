#!/bin/bash

/bin/rm -rf /root/.ssh/id_rsa*
/usr/bin/ssh-keygen -t rsa -f /root/.ssh/id_rsa -P ''