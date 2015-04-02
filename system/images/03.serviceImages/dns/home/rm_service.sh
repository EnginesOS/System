#!/bin/bash

. /home/engines/scripts/functions.sh

load_service_hash_to_environment

#FIXME make engines.internal settable

	fqdn_str=${hostname}.engines.internal
	echo server 127.0.0.1 > /tmp/.dns_cmd
	echo update delete $fqdn >> /tmp/.dns_cmd
	echo send >> /tmp/.dns_cmd	
	nsupdate -k /etc/dns/keysddns.private /tmp/.dns_cmd
	if test $? -ge 0
	then
		echo Success
	else
		echo Error
	fi