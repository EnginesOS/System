#/bin/sh

params=`cat -`

hostname=`echo $params | cut -f1 -d. `
domainname=`echo $params | cut -f 2- -d.`

if ! test -z $domainname
 then
	sudo -n hostname $hostname.$domainname
else
	sudo -n hostname $hostname
	
fi
echo params: $params >/tmp/set_hostname
echo hostname $hostname.$domainname >> /tmp/set_hostname
