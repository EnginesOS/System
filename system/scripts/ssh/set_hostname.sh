#/bin/sh

hostname=`echo  $SSH_ORIGINAL_COMMAND | awk '{print $2}'`
domainname=`echo  $SSH_ORIGINAL_COMMAND | awk '{print $3}'`
if ! test -z $domainname
 then
	sudo -n hostname $hostname
else
	sudo -n hostname $hostname.$domainname
fi

echo hostname $hostname.$domainname > /tmp/set_hostname
