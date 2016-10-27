#/bin/sh

params=`cat -`

hostname=`echo $params | cut -f1 -d. `
domainname=`echo $params | cut -f 2- -d.`

sudo -n hostname $hostname

if ! test -z $domainname
 then
	sudo -n domainname $domainname
else
	
	
fi
echo params: $params >/tmp/set_hostname
echo hostname $hostname.$domainname >> /tmp/set_hostname
