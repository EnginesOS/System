#/bin/bash

apt-get install -y  linux-image-extra-$(uname -r) 

 rm /opt/engines/run/system/flags/run_post_system_update
 service engines stop
 shutdown -r now
 

