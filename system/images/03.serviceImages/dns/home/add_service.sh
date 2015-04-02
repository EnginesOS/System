#!/bin/bash
. /home/engines/scripts/functions.sh

load_service_hash_to_environment

#FIXME make engines.internal settable

	fqdn_str=${hostname}.engines.internal
	echo server 127.0.0.1 > /tmp/.dns_cmd
	echo update delete $fqdn >> /tmp/.dns_cmd
	echo send >> /tmp/.dns_cmd
	echo update add $fqdn_str 30 A $ip >> /tmp/.dns_cmd
	echo send >> /tmp/.dns_cmd
	nsupdate -k /etc/dns/keysddns.private /tmp/.dns_cmd
	if test $? -ge 0
	then
		echo Success
	else
		echo Error
	fi
	
#     fqdn_str = top_level_hostname + "." + SysConfig.internalDomain
#       #FIXME need unique name for temp file
#       dns_cmd_file_name="/tmp/.dns_cmd_file"
#       dns_cmd_file = File.new(dns_cmd_file_name,"w+")
#       dns_cmd_file.puts("server " + SysConfig.defaultDNS)
#       dns_cmd_file.puts("update delete " + fqdn_str)
#       dns_cmd_file.puts("send")
#       dns_cmd_file.puts("update add " + fqdn_str + " 30 A " + ip_addr_str)
#       dns_cmd_file.puts("send")
#       dns_cmd_file.close
#       cmd_str = "nsupdate -k " + SysConfig.ddnsKey + " " + dns_cmd_file_name
#       retval = run_system(cmd_str)
#       #File.delete(dns_cmd_file_name)
#       return retval
#     rescue  Exception=>e
#       SystemUtils.log_exception(e)
#       return false