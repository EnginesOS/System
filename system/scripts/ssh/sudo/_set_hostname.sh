#/bin/sh
hostname=$1
domain_name=$2


sudo -n hostname $hostname

if ! test -z $domain_name
 then
	sudo -n domainname $domain_name

fi
echo params: $params >/tmp/set_hostname
echo hostname $hostname.$domain_name >> /tmp/set_hostname
