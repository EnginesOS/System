#!/bin/bash
RUBY_VER=2.2.2
export RUBY_VER

function complete_install {

#create_services > /var/log/engines/install_startup




rm ~/.complete_install
echo "System startup"

touch ~/.installed

hostname=`hostname`


echo "Congratulations Engines OS is now installed please go to http://${hostname}:88/"
}

complete_install