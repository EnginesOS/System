#!/bin/sh

	if test ! -f /opt/engines/etc/dns/config/zones/named.conf.$1
		then
			cat /opt/engines/etc/dns/tmpls/selfzone.tmpl | sed "s/DOMAIN/$1/" |sed  "s/IP/$2/" > /opt/engines/etc/dns/config/zones/named.conf.$1
			#echo "include \"/etc/bind/engines/zones/named.conf.$1\";" >> /opt/engines/etc/dns/config/named.conf.engines
			cat /opt/engines/etc/dns/tmpls/config_file_zone_entry.tmpl  | sed "s/DOMAIN/$1/" >> /opt/engines/etc/dns/config/named.conf.engines
		fi
		
#service name reload		
