#!/bin/bash
export PATH=/bin:/usr/sbin:/usr/bin:$PATH
if [ $# -ne 1 ]
then
        echo "Invalid parameter count!"
        echo "Usage: $0 timezone"
        exit 1;
fi


echo "$1" | tee /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata
