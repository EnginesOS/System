#/bin/bash

apt-get install -y  linux-image-extra-$(uname -r) 

 rm /opt/engines/run/system/flags/run_post_system_update
 shutdown -r now
 

