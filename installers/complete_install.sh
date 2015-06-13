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


create_services

/opt/engines/bin/containers_startup.sh 

echo "System startup"
/opt/engines/bin/mgmt_startup.sh 

sleep 180  # would be nice to tail docker logs -f mgmt and break when :8000 in log line
hostname=`hostname`


echo "Congratulations Engines OS is now installed please go to http://${hostname}:88/"
