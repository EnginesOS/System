#!/bin/bash
. /home/engines/scripts/functions.sh

load_service_hash_to_environment
n=1

echo $1 |grep = >/dev/null
        if test $? -ne 0
        then
        		echo Error:No Arguments
                exit -1
        fi

res="${1//[^:]}"
echo $res
fcnt=${#res}
fcnt=`expr $fcnt + 1`

        while test $fcnt -ge $n
        do
                nvp="`echo $1 |cut -f$n -d:`"
                n=`expr $n + 1`
                name=`echo $nvp |cut -f1 -d=`
                export $name=`echo $nvp |cut -f2 -d=`
        done
#FIXME make engines.internal settable

	if test -z ${hostname}
	then
		echo Error:Missing hostname
        exit -1
    fi
  	if test -z ${ip}
	then
		echo Error:missing ip
        exit -1
    fi  
    

	fqdn_str=${hostname}.engines.internal
	echo server 127.0.0.1 > /tmp/.dns_cmd
	echo update delete $fqdn >> /tmp/.dns_cmd
	echo send >> /tmp/.dns_cmd
	echo update add $fqdn_str 30 A $ip >> /tmp/.dns_cmd
	echo send >> /tmp/.dns_cmd
	nsupdate -k /etc/bind/keys/ddns.private /tmp/.dns_cmd
	
	if test $? -ge 0
	then
		echo Success
	else
	file=`cat /tmp/.dns_cmd`
		echo Error:With nsupdate $file
		exit -1
	fi
	
