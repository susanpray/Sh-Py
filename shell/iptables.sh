#!/bin/bash

###
#   iptables config 
###
export LANG=en_US.UTF-8

IPS="/sbin/iptables"
IFCON="/sbin/ifconfig"

_judge_IF () {

    $IFCON eth0 > /dev/null 2>&1
    if [ "$?" -eq 0 ];then
        nic="eth0"
    else
        $IFCON em1 > /dev/null 2>&1
        if [ "$?" -eq 0 ];then
            nic="em1"
        fi  
    fi          
}

#outside port, exampel: open_ports="443,3306"
if [ "$1" = "-c" -o "$1" = "-m" ]; then
  open_ports="443,3306,61616,61617,9300,9310,9200"
else
  open_ports="443"
fi

#clear
$IPS -t nat -F
$IPS -t nat -X

$IPS -t filter -F
$IPS -t filter -X


#set default policy
$IPS -P OUTPUT  ACCEPT 
$IPS -P FORWARD  DROP


#permit  all service 
$IPS -A INPUT -i lo -j ACCEPT
$IPS -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

#permit outside access localhost
$IPS -A INPUT -p tcp -m multiport --dport ${open_ports} -j ACCEPT

#stop brute force attacks to ssh
#disable_time=600
#$IPS -A INPUT -p tcp --dport 22  -m state --state NEW -m recent --set
#$IPS -A INPUT -p tcp --dport 22  -m state --state NEW -m recent --update --seconds ${disable_time} --hitcount 3 -j DROP
$IPS -A INPUT -p tcp --dport 22  -j ACCEPT

#permit icmp
$IPS -A INPUT -p icmp --icmp-type 8 -j ACCEPT

#permit vm to br0 interface
$IPS -A INPUT -i br0 -j ACCEPT

#for samba
$IPS -A INPUT -p udp --dport 137 -j ACCEPT
$IPS -A INPUT -p udp --dport 138 -j ACCEPT
$IPS -A INPUT -p tcp --dport 139 -j ACCEPT

#set default policy
$IPS -P INPUT  DROP

#output don't permit vm to internet
vm_br0_ip="10.14.24.0/24"
vm_virbr0_ip="192.168.122.0/24"

$IPS -A OUTPUT -s 127.0.0.0/8 -j ACCEPT

$IPS -A OUTPUT -s ${vm_br0_ip} -o $nic -j DROP
$IPS -A OUTPUT -s ${vm_virbr0_ip} -o $nic -j DROP


#save rule
/sbin/iptables-save > /etc/iptables.up.rules

#####
#note: start iptables by power
#
#edit: /etc/network/interfaces
#auto eth0
#iface eth0 inet dhcp
#pre-up /sbin/iptables-restore < /etc/iptables.up.rules
#####

###
# start and stop iptables service
# ufw disable
# ufw enable
###
