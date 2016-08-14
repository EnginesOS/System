#/bin/bash

apt-get install -y  linux-image-extra-$(uname -r) |grep "0 newly"

if ! test $? -ne 0
 then
 rm /opt/engines/run/system/flags/run_post_system_update
    shutdown -r now
fi 

rm /opt/engines/run/system/flags/run_post_system_update