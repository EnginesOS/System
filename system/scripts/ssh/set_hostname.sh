#/bin/sh
 
params=`cat -`

hostname=`echo $params | cut -f1 -d. `
domain_name=`echo $params | cut -f 2- -d.`

sudo -n /opt/engines/system/scripts/ssh/sudo/_set_hostname.sh $hostname $domain_name
 