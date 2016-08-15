#!/bin/bash

apt-get -y update
env DEBIAN_FRONTEND=noninteractive   apt-get -q -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" upgrade
#DEBIAN_PRIORITY=critical
touch /opt/engines/run/system/flags/run_post_system_update
cp /etc/os-release /opt/engines/etc/os-release-host 
#/opt/engines/system/scripts/system/update_system_status_flags.sh