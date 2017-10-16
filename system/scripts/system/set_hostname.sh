#/bin/bash

#FixMe check args

hostname=`echo $1 | cut -f 1 -d.`
domain_name=`echo $1 | cut -f 2- -d.`
echo $hostname.$domain_name | ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/system/set_hostname engines@control /opt/engines/bin/set_hostname.sh 

echo ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/system/set_hostname engines@control /opt/engines/bin/set_hostname.sh $hostname $domain_name > /tmp/sethost.ssh