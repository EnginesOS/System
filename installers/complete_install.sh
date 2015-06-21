#!/bin/bash
RUBY_VER=2.2.2
export RUBY_VER
. /tmp/203.14.203.141/EnginesInstaller/routines.sh

rbenv install 2.2.2
rbenv  local 2.2.2
 	~/.rbenv/shims/gem install multi_json rspec rubytree git 
#gem install multi_json rspec rubytree git 





#set_os_flavor

setup_mgmt_git

#echo "Building Images"
# /opt/engines/bin/buildimages.sh

touch /opt/engines/.complete_install

sudo reboot


