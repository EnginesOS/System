#!/bin/sh

#FIXME check arugments and verifice .crt is a pem
ca_cert_file=/opt/engines/etc/certs/ca/system_CA.pem 

file $ca_cert_file | grep PEM
 if test $? -eq 0
 	then
		cp $ca_cert_file /usr/local/share/ca-certificates/engines_internal_ca.crt
	else
		echo $ca_cert_file not a PEM certificate
		exit
	fi

update-ca-certificates

#force update-ca-certificates on containers and service next start

rm `find /opt/engines/*/*/run/flags/ -name ca-update`