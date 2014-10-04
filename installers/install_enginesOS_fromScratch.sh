#!/bin/bash

RUBY_VER=2.1.2

export RUBY_VER

. /tmp/203.14.203.141/EnginesInstaller/routines.sh


dpkg-reconfigure tzdata

install_docker_and_components

make_dirs

set_permissions



passwd dockuser  

chmod +x /tmp/203.14.203.141/EnginesInstaller/complete_install.sh

su -l dockuser -c /tmp/203.14.203.141/EnginesInstaller/complete_install.sh


 