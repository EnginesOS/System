#!/bin/bash
RUBY_VER=2.2.2
export RUBY_VER

function complete_install {

create_services > /var/log/engines/install_startup

/opt/engines/bin/containers_startup.sh >> /var/log/engines/install_startup

echo "System startup"
/opt/engines/bin/engines_startup.sh

rm /opt/engines/.complete_install
touch /opt/engines/.installed

hostname=`hostname`


echo "Congratulations Engines OS is now installed please go to http://${hostname}:88/"
}

complete_install