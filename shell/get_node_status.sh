#!/bin/bash
# Shell script to get uptime, disk usage, cpu usage, RAM usage,system load,etc. 
# from multiple Linux servers and output the information on a single server 
# in html format. Read below for usage/installation info
# *---------------------------------------------------------------------------*
# * dig_remote_linux_server_information.bash,v0.1, last updated on 25-Jul-2005*
# * Copyright (c) 2005 nixCraft project                                       *
# * Comment/bugs: http://cyberciti.biz/fb/                                    *
# * Ref url: http://cyberciti.biz/nixcraft/forum/viewtopic.php?t=97           *
# * This script is licensed under GNU GPL version 2.0 or above                *
# *---------------------------------------------------------------------------*
# *  Installation Info                                                        *
# ----------------------------------------------------------------------------*
# You need to setup ssh-keys to avoid password prompt, see url how-to setup 
# ssh-keys:
# cyberciti.biz/nixcraft/vivek/blogger/2004/05/ssh-public-key-based-authentication.html
# 
# [1] You need to setup correct VARIABLES script:
#
# (a) Change Q_HOST to query your host to get information
# Q_HOST="192.168.1.2 127.0.0.1 192.168.1.2"
#
# (b) Setup USR, who is used to connect via ssh and already setup to connect 
# via ssh-keys
# USR="nixcraft"
#
# (c)Show warning if server load average is below the limit for last 5 minute.
# setup LOAD_WARN as per your need, default is 5.0
#
# LOAD_WARN=5.0
#
# (d) Setup your network title using MYNETINFO
# MYNETINFO="My Network Info"
#
# (e) Save the file 
#
# Please refer to forum topic on this script: 
# Also download the .gif files and put them in your output dir
#
# ----------------------------------------------------------------------------
# Execute script as follows (and copy .gif file in this dir) :
# this.script.name > /var/www/html/info.html
# ============================================================================
# This script is part of nixCraft shell script collection (NSSC)
# Visit http://bash.cyberciti.biz/ for more information.
# -------------------------------------------------------------------------
 
# SSH SERVER HOST IPS, setup me 
# Change this to query your host
Q_HOST="127.0.0.1"
 
# SSH USER, change me
USR="nixcraft"
 
# Show warning if server load average is below the limit for last 5 minute
LOAD_WARN=5.0
 
# Your network info
MYNETINFO="My Network Info"
#
 
## main ##
 
_CMD=""
rhostname="$($_CMD hostname)"

ruptime="`uptime -p`"

rload="$($_CMD uptime |awk -F'average:' '{ print $2}')"
x="$(echo $rload | sed s/,//g | awk '{ print $2}')"
y="$(echo "$x >= $LOAD_WARN" | bc)"

rclock="$($_CMD date +"%r")"
rtotalprocess="$($_CMD ps axue | grep -vE "^USER|grep|ps" | wc -l)"
rdisktotal="$($_CMD df | grep -vE "^Filesystem|shm" | awk '{if($6 ~ /\/polydata$/) print $2}')"
rdiskused="$($_CMD df | grep -vE "^Filesystem|shm" | awk '{if($6 ~ /\/polydata$/) print $3}')"
rdiskfree="$($_CMD df | grep -vE "^Filesystem|shm" | awk '{if($6 ~ /\/polydata$/) print $4}')"

if [ "$rdisktotal" = "" ]; then
  rdisktotal="$($_CMD df | grep -vE "^Filesystem|shm" | awk '{if($1 ~ /sda1/) print $2}')"
fi

if [ "$rdiskused" = "" ]; then
  rdiskused="$($_CMD df | grep -vE "^Filesystem|shm" | awk '{if($1 ~ /sda1$/) print $3}')"
fi

if [ "$rdiskfree" = "" ]; then
  rdiskfree="$($_CMD df | grep -vE "^Filesystem|shm" | awk '{if($1 ~ /sda1/) print $4}')"
fi

rusedram="$($_CMD free -mto | grep Mem: | awk '{ print $3 }')"
rfreeram="$($_CMD free -mto | grep Mem: | awk '{ print $4 }')"
rbufram="$($_CMD free -mto | grep Mem: | awk '{ print $6 }')"
rcachedram="$($_CMD free -mto | grep Mem: | awk '{ print $7 }')"
rtotalram="$($_CMD free -mto | grep Mem: | awk '{ print $2 }')"


rusedram="`expr ${rtotalram} - ${rfreeram} - ${rbufram} - ${rcachedram}`"

rmemusage="`expr $rusedram \* 100 / $rtotalram`"
rcpuusage="`top -b -n 2 |grep ^%Cpu|awk 'NR==2 {print $2}'`"

rswaptotal="`top -b -n 1 |grep Swap|awk '{print $3}'`"
rswapusage="`top -b -n 1 |grep Swap|awk '{print $5}'`"

rifnames=`ls -lt /sys/class/net/|awk '{if ($9 ~ /^eth|^em/) print $9}'`
rreceivepkt_total=0
rrsendpkt_total=0
for i in `ls -lt /sys/class/net/|awk '{if ($9 ~ /^eth|^em/) print $9}'`
do
    rreceivepkt=`cat /sys/class/net/$i/statistics/rx_packets`
    rsendpkt=`cat /sys/class/net/$i/statistics/tx_packets`
    rreceivepkt_total="`expr $rreceivepkt_total + $rreceivepkt`"
    rsendpkt_total="`expr $rsendpkt_total + $rsendpkt`"
done

echo "dev_name: $rhostname" 
echo "dev_ip: $1" 
echo "serial:`awk -F= '{print $2}' /etc/sys.serial.txt`"
echo "mem_usage: $rmemusage" 
echo "os_name: `uname -sr`" 
echo "os_time: `date "+%Y-%m-%d %H:%M:%S"`" 
echo "run_time: $ruptime"
echo "cpu_usage: $rcpuusage"
echo "mem_total: $rtotalram" 
echo "mem_used: $rusedram"
echo "swap_total: $rswaptotal" 
echo "swap_used: $rswapusage"
# System is 1K block
echo "disk_total: `expr $rdisktotal / 1024`" 
echo "disk_used: `expr $rdiskused / 1024`"
echo "if_rxs: $rreceivepkt_total"
echo "if_txs: $rsendpkt_total"
if [ -f "/tmp/netstats.txt" ]; then
	cat /tmp/netstats.txt
fi
