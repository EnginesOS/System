#!/bin/sh

#FIXME check arugments and verifice .crt is a pem

file $1 | grep PEM
 if test $? -eq 0
 	then
		cp $1 /usr/local/share/ca-certificates/engines_internal_ca.crt
	else
		echo $1 not a PEM certificate
		exit
	fi

update-ca-certificates

#force update-ca-certificates on containers and service next start

rm `find /opt/engines/*/*/run/flags/ -name ca-update`