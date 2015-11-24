#/bin/bash

#FixMe check args

hostname=$1
domain_name=$1
ip=`ifconfig docker0  |grep "inet addr:" |cut -f2 -d: |awk '{print $1}'`
ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/set_hostname engines@$ip /opt/engines/bin/set_hostname.sh $hostname $domain_name