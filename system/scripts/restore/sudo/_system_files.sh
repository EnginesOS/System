#!/bin/sh

cd /
tar -xzpf - opt/engines

for config in `find /opt/engines/ -name running.yaml`
 do
  sed -i.bak  "s/container_id.*//" $config
done
#need to reset stuff that is dynamic

/opt/engines/system/scripts/startup/set_ip.sh
