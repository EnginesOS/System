#!/bin/bash

RUBY_VER=2.1.2

export RUBY_VER

. /tmp/203.14.203.141/EnginesInstaller/routines.sh
 if test -f /opt/engines/installers/routines.sh
 then
		. /opt/engines/installers/routines.sh
 fi


dpkg-reconfigure tzdata


configure_git 

install_docker_and_components
chown -R engines /opt/engines/
passwd engines  

generate_ssl


make_dirs

set_permissions

cp -r /opt/engines/system/install_source/* /
#cat /opt/engines/system/install_source/etc/sudoers >> /etc/sudoers

chmod +x /tmp/203.14.203.141/EnginesInstaller/complete_install.sh

su -l engines -c /tmp/203.14.203.141/EnginesInstaller/complete_install.sh


 