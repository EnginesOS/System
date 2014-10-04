#!/bin/bash
RUBY_VER=2.1.2
export RUBY_VER
. /tmp/203.14.203.141/EnginesInstaller/routines.sh

generate_ssl
configure_git 
generate_keys

set_os_flavor

setup_mgmt_git

echo "Building Images"
 /opt/engos/bin/buildimages.sh

create_services

/opt/engos/bin/containers_startup.sh 

echo "System startup"
/opt/engos/bin/mgmt_startup.sh 

sleep 180  # would be nice to tail docker logs -f mgmt and break when :8000 in log line
hostname=`hostname`


echo "Congratulations Engines OS is now installed please go to http://${hostname}:88/"
