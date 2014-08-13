#!/bin/bash

cd /home/


hostname=`hostname`
ip=`grep $hostname /etc/hosts |cut -f1`
echo server  172.17.42.1 >ddnscmds
echo update delete ${hostname}.docker >> ddnscmds
echo "send"  >> ddnscmds
echo " update add ${hostname}.docker 30 A $ip" >> ddnscmds
echo "send"  >> ddnscmds

nsupdate -k /etc/ddns.key ddnscmds

