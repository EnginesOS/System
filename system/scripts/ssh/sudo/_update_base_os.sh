#!/bin/bash

apt-get -y update
env DEBIAN_FRONTEND=noninteractive apt-get -q -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" upgrade
sudo apt-get -y autoremove
#DEBIAN_PRIORITY=cri
#tical
#Always do this ???

env DEBIAN_FRONTEND=noninteractive  apt-get -q -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold"  dist-upgrade
touch /opt/engines/run/system/flags/run_post_system_update
cp /etc/os-release /opt/engines/etc/os-release-host 

#/opt/engines/system/scripts/system/update_system_status_flags.sh
rm /opt/engines/run/system/flags/base_os_update_pending