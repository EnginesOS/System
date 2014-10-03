#!/bin/bash
RUBY_VER=2.1.2
export RUBY_VER
. /opt/engos/installers/routines.sh


dpkg-reconfigure tzdata


make_dirs

set_permissions

install_docker_and_components


generate_ssl
configure_git 
generate_keys

set_os_flavor

setup_mgmt_git

echo "Building Images"
su -l dockuser /opt/engos/bin/buildimages.sh

create_services

echo "System startup"
/opt/engos/bin/mgmt_startup.sh 

sleep 180  # would be nice to tail docker logs -f mgmt and break when :8000 in log line
hostname=`hostname`
ln -s /opt/engos/bin/engines.rb /opt/engos/bin/engines

echo "Congratulations Engines OS is now installed please go to http://${hostname}:88/"


 