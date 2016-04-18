#!/bin/bash

apt-get -y update
env DEBIAN_FRONTEND=noninteractive   apt-get -q -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" upgrade
#DEBIAN_PRIORITY=critical
apt-get install -y apt-transport-https linux-image-extra-$(uname -r) lvm2 thin-provisioning-tools
cp /etc/os-release /opt/engines/etc/os-release-host 
/opt/engines/bin/update_system_status_flags.sh