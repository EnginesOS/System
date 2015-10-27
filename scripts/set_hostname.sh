#/bin/bash

#FixMe check args

hostname=$1
domain_name=$1
ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/set_hostname engines@172.17.42.1 /opt/engines/bin/set_hostname.sh $hostname $domain_name