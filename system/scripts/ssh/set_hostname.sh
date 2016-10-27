#/bin/sh

params=`cat -`

hostname=`echo $params | awk '{print $1}'`
domainname=`echo $params | awk '{print $2}'`

if ! test -z $domainname
 then
	sudo -n hostname $hostname
else
	sudo -n hostname $hostname.$domainname
fi
echo $params >/tmp/set_hostname
echo hostname $hostname.$domainname >> /tmp/set_hostname
