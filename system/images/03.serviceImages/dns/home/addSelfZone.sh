#!/bin/sh

	if test ! -f /etc/bind/named.conf.$1
		then
			cat /home/tmpls/selfzone.tmpl | sed "s/DOMAIN/$1/" "s/DOMAIN/$2/" > /etc/bind/named.conf.$1
			echo "include \"/etc/bind/named.conf.$1\";" >> /etc/bind/named.conf.local
		fi
		
service name reload		
