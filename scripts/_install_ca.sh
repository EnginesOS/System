#!/bin/sh

#FIXME check arugments and verifice .crt is a pem
ca_cert_file=/opt/engines/etc/certs/ca/certs/system_CA.pem 

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
files=`find /opt/engines/*/*/run/flags/ -name ca-update`
	if ! test -z $files
		then
			rm $files
	fi
#rm `find /opt/engines/*/*/run/flags/ -name ca-update`