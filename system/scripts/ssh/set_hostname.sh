#/bin/sh

params=`cat -`

hostname=`echo $params | cut -f1 -d. `
domain_name=`echo $params | cut -f 2- -d.`

sudo -n hostname $hostname

if ! test -z $domain_name
 then
	sudo -n domainname $domain_name

fi
echo params: $params >/tmp/set_hostname
echo hostname $hostname.$domain_name >> /tmp/set_hostname
